import matplotlib.pyplot as plt
import pandas as pd
import re
from io import StringIO
from prettytable import PrettyTable

with open('result.txt', 'r') as f:
    content = f.read()

solutions_match = re.search(r'<solutions>(.*?)</solutions>', content, re.DOTALL)
differences_match = re.search(r'<differences>(.*?)</differences>', content, re.DOTALL)

solutions_data = pd.read_csv(StringIO(solutions_match.group(1)), index_col=0)
differences_data = pd.read_csv(StringIO(differences_match.group(1)), index_col=0)

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 12))

solutions_data.T.plot(ax=ax1)
ax1.set_title('Solutions')
ax1.set_xlabel('Time')
ax1.set_ylabel('Value')
ax1.legend(loc='upper right')
ax1.grid(True)

differences_data.T.plot(ax=ax2)
ax2.set_title('Differences')
ax2.set_xlabel('Time')
ax2.set_ylabel('Difference')
ax2.legend(loc='upper right')
ax2.grid(True)

plt.tight_layout()

decimals = 4  # Change this to adjust decimal places

sol_table = PrettyTable()
sol_table.field_names = ["Method"] + list(solutions_data.columns)
for idx, row in solutions_data.iterrows():
    sol_table.add_row([idx] + [round(val, decimals) for val in row])
    
diff_table = PrettyTable()
diff_table.field_names = ["Method"] + list(differences_data.columns)
for idx, row in differences_data.iterrows():
    diff_table.add_row([idx] + [round(val, decimals) for val in row])

print("Solutions Table:")
print(sol_table)
print("\nDifferences Table:")
print(diff_table)

plt.savefig("result.png")
#plt.show()