import matplotlib.pyplot as plt
import pandas as pd
import re
from io import StringIO
from prettytable import PrettyTable

# Read data
with open('result.txt', 'r') as f:
    content = f.read()
    
solutions_data = pd.read_csv(StringIO(re.search(r'<solutions>(.*?)</solutions>', content, re.DOTALL).group(1)), index_col=0)
differences_data = pd.read_csv(StringIO(re.search(r'<differences>(.*?)</differences>', content, re.DOTALL).group(1)), index_col=0)

# Create plots
fig, (ax1, ax2, ax3) = plt.subplots(3, 1, figsize=(10, 12))
solutions_data.T.plot(ax=ax1, grid=True)
ax1.set_title('Solutions'); ax1.set_xlabel('Time'); ax1.set_ylabel('Value')

differences_data.T.plot(ax=ax2, grid=True)
ax2.set_title('Error'); ax2.set_xlabel('Time'); ax2.set_ylabel('L1 Error')

# Normalized error
normalized_error = pd.DataFrame(index=differences_data.index, columns=differences_data.columns)
for method in differences_data.index:
    for col in differences_data.columns:
        solution_val = solutions_data.loc[method, col] if method in solutions_data.index and col in solutions_data.columns else 0
        normalized_error.loc[method, col] = 0 if solution_val == 0 else 100 * differences_data.loc[method, col] / abs(solution_val)

normalized_error.T.plot(ax=ax3, grid=True)
ax3.set_title('Normalized % Error'); ax3.set_xlabel('Time'); ax3.set_ylabel('Error (%)')

# Find half value points and mark them
half_value_points = {}
times = [float(col.split('=')[1]) if '=' in col else float(col.replace('t', '')) for col in solutions_data.columns]
for method in solutions_data.index:
    values = solutions_data.loc[method].values
    half_value = values[0] / 2
    
    for i in range(len(values)-1):
        if (values[i] >= half_value >= values[i+1]) or (values[i] <= half_value <= values[i+1]):
            t1, t2 = times[i], times[i+1]
            v1, v2 = values[i], values[i+1]
            if v1 != v2:
                t_half = t1 + (t2 - t1) * (half_value - v1) / (v2 - v1)
                half_value_points[method] = t_half
                ax1.plot(t_half, half_value, 'ro', markersize=8)
                ax1.annotate(f"t={t_half:.2f}", (t_half, half_value), xytext=(10, 0), textcoords='offset points')
            break

# Create metrics table
metrics_table = PrettyTable()
metrics_table.field_names = ["Method", "Initial Value", "50% at Time", "Total Error", "Avg % Error"]
for method in solutions_data.index:
    total_error = differences_data.loc[method].sum() if method in differences_data.index else None
    avg_pct = normalized_error.loc[method].mean() if method in normalized_error.index else None
    metrics_table.add_row([
        method, 
        f"{solutions_data.loc[method].values[0]:.4f}", 
        f"{half_value_points.get(method, 'N/A'):.4f}" if method in half_value_points else "N/A",
        f"{total_error:.4f}" if total_error is not None else "N/A",
        f"{avg_pct:.4f}" if avg_pct is not None else "N/A"
    ])

plt.tight_layout()
plt.savefig("result.png", dpi=300)
print("Method Performance Metrics:")
print(metrics_table)
print("\nFigure has been saved to result.png")