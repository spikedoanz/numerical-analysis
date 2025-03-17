import matplotlib.pyplot as plt
import pandas as pd
import re
import os
from io import StringIO
from prettytable import PrettyTable

# Global parameters
METHODS = ["euler", "rk4", "ab3", "ab3am2"]
SELECTED_STEP_SIZES = [0.01, 0.02, 0.08, 0.32, 0.64]
FONT_SIZE = 14
FIGURE_DIR = "figures/"

# Ensure figures directory exists
os.makedirs(FIGURE_DIR, exist_ok=True)
plt.rcParams.update({'font.size': FONT_SIZE})

# Read and extract experiments
with open('result.txt', 'r') as f:
    content = f.read()

experiments = {}
for step_size, exp_content in re.findall(r'<experiment stepsize=(.*?)>(.*?)</experiment>', content, re.DOTALL):
    step_size = float(step_size)
    try:
        solutions_df = pd.read_csv(StringIO(re.search(r'<solutions>(.*?)</solutions>', exp_content, re.DOTALL).group(1)), index_col=0)
        differences_df = pd.read_csv(StringIO(re.search(r'<differences>(.*?)</differences>', exp_content, re.DOTALL).group(1)), index_col=0)
        
        # Filter to selected methods
        solutions_df = solutions_df.loc[[m for m in METHODS + ["explicit"] if m in solutions_df.index]]
        differences_df = differences_df.loc[[m for m in METHODS if m in differences_df.index]]
        
        experiments[step_size] = {
            'solutions': solutions_df,
            'differences': differences_df
        }
    except Exception as e:
        print(f"Error processing experiment with step size {step_size}: {e}")

# Function to calculate relative error
def calculate_relative_error(solutions_df, differences_df):
    relative_error_df = pd.DataFrame(index=differences_df.index, columns=differences_df.columns)
    if "explicit" in solutions_df.index:
        exact_values = solutions_df.loc["explicit"]
        for method in differences_df.index:
            for col in differences_df.columns:
                exact_val = exact_values[col]
                relative_error_df.loc[method, col] = differences_df.loc[method, col] / abs(exact_val) if exact_val != 0 else 0
    return relative_error_df

# Plot solutions and errors for selected step sizes
for step_size in SELECTED_STEP_SIZES:
    if step_size not in experiments:
        continue
    
    exp = experiments[step_size]
    solutions_df = exp['solutions']
    differences_df = exp['differences']
    relative_error_df = calculate_relative_error(solutions_df, differences_df)
    
    # Create solution plots (normal and log scale)
    fig, axes = plt.subplots(2, 1, figsize=(12, 10))
    solutions_df.T.plot(ax=axes[0], grid=True)
    solutions_df.T.plot(ax=axes[1], grid=True, logy=True)
    
    axes[0].set_title(f'Solutions (h={step_size})', fontsize=FONT_SIZE+2)
    axes[1].set_title(f'Solutions (Log Scale, h={step_size})', fontsize=FONT_SIZE+2)
    for ax in axes:
        ax.set_xlabel('Time', fontsize=FONT_SIZE)
        ax.set_ylabel('Value', fontsize=FONT_SIZE)
        ax.legend(fontsize=FONT_SIZE-2)
    
    plt.tight_layout()
    plt.savefig(f"{FIGURE_DIR}solutions_h{step_size}.png", dpi=300)
    plt.close()
    
    # Create error plots (absolute and relative)
    fig, axes = plt.subplots(2, 1, figsize=(12, 10))
    differences_df.T.plot(ax=axes[0], grid=True)
    relative_error_df.T.plot(ax=axes[1], grid=True)
    
    axes[0].set_title(f'Absolute Error (h={step_size})', fontsize=FONT_SIZE+2)
    axes[1].set_title(f'Relative Error (h={step_size})', fontsize=FONT_SIZE+2)
    axes[0].set_ylabel('L1 Error', fontsize=FONT_SIZE)
    axes[1].set_ylabel('Relative Error', fontsize=FONT_SIZE)
    for ax in axes:
        ax.set_xlabel('Time', fontsize=FONT_SIZE)
        ax.legend(fontsize=FONT_SIZE-2)
    
    plt.tight_layout()
    plt.savefig(f"{FIGURE_DIR}errors_h{step_size}.png", dpi=300)
    plt.close()
    
    # Metrics table
    times = [float(col) for col in solutions_df.columns]
    metrics_table = PrettyTable()
    metrics_table.field_names = ["Method", "Initial Value", "50% at Time", "99% at Time", "Total Error", "Avg Relative Error"]
    
    for method in differences_df.index:
        values = solutions_df.loc[method].values
        initial_value = values[0]
        
        # Find half value point
        half_value_time = "N/A"
        decay_99_time = "N/A"
        
        for i in range(len(values)-1):
            if values[i] >= initial_value/2 >= values[i+1] or values[i] <= initial_value/2 <= values[i+1]:
                t1, t2 = times[i], times[i+1]
                v1, v2 = values[i], values[i+1]
                half_value_time = f"{t1 + (t2-t1)*(initial_value/2-v1)/(v2-v1):.4f}" if v1 != v2 else "N/A"
                break
        
        for i in range(len(values)-1):
            if values[i] >= initial_value*0.01 >= values[i+1] or values[i] <= initial_value*0.01 <= values[i+1]:
                t1, t2 = times[i], times[i+1]
                v1, v2 = values[i], values[i+1]
                decay_99_time = f"{t1 + (t2-t1)*(initial_value*0.01-v1)/(v2-v1):.4f}" if v1 != v2 else "N/A"
                break
        
        # Calculate errors (skip first point)
        total_error = f"{differences_df.loc[method].iloc[1:].sum():.6f}"
        avg_relative_error = f"{relative_error_df.loc[method].iloc[1:].mean():.6f}"
        
        metrics_table.add_row([
            method, 
            f"{initial_value:.4f}", 
            half_value_time,
            decay_99_time,
            total_error,
            avg_relative_error
        ])
    
    print(f"\n--- Metrics for Step Size {step_size} ---")
    print(metrics_table)

# Collect errors for each step size
l1_errors = {method: [] for method in METHODS}
rel_errors = {method: [] for method in METHODS}

for step_size, exp in sorted(experiments.items()):
    differences_df = exp['differences']
    solutions_df = exp['solutions']
    relative_error_df = calculate_relative_error(solutions_df, differences_df)
    
    for method in METHODS:
        if method in differences_df.index:
            # Skip first point
            l1_errors[method].append((step_size, differences_df.loc[method].iloc[1:].sum()))
            rel_errors[method].append((step_size, relative_error_df.loc[method].iloc[1:].mean()))

# Error decay plots (normal and log-log)
for log_scale in [False, True]:
    fig, axes = plt.subplots(2, 1, figsize=(12, 10))
    
    for method in METHODS:
        if l1_errors[method]:
            step_sizes, errors = zip(*l1_errors[method])
            if log_scale:
                axes[0].loglog(step_sizes, errors, 'o-', label=method, linewidth=2, markersize=8)
            else:
                axes[0].plot(step_sizes, errors, 'o-', label=method, linewidth=2, markersize=8)
        
        if rel_errors[method]:
            step_sizes, errors = zip(*rel_errors[method])
            if log_scale:
                axes[1].loglog(step_sizes, errors, 'o-', label=method, linewidth=2, markersize=8)
            else:
                axes[1].plot(step_sizes, errors, 'o-', label=method, linewidth=2, markersize=8)
    
    scale_desc = "Log-Log" if log_scale else ""
    axes[0].set_title(f'Total L1 Error vs Step Size {scale_desc}', fontsize=FONT_SIZE+2)
    axes[1].set_title(f'Average Relative Error vs Step Size {scale_desc}', fontsize=FONT_SIZE+2)
    
    for ax in axes:
        ax.set_xlabel('Step Size (h)', fontsize=FONT_SIZE)
        ax.grid(True)
        ax.legend(fontsize=FONT_SIZE-2)
    
    axes[0].set_ylabel('Total L1 Error', fontsize=FONT_SIZE)
    axes[1].set_ylabel('Average Relative Error', fontsize=FONT_SIZE)
    
    plt.tight_layout()
    plt.savefig(f"{FIGURE_DIR}error_vs_stepsize{'_loglog' if log_scale else ''}.png", dpi=300)
    plt.close()

print(f"\nAll figures have been saved to the {FIGURE_DIR} directory")