# Numerical Analysis

## Project 1

The code for the project sits in NumericalAnalysis/Project1.lean

The outputs of the implementations are in results.txt (which contain 2 csvs),
and visualized in result.png

---

### Instructions

1. Install Lean

Follow the official instructions from the [documentation](https://leanprover-community.github.io/get_started.html)

2. Build and run project

This will compile the project and also 
```
git clone git@github.com:spikedoanz/numerical-analysis.git
cd numerical-analysis
lake build
./.lake/build/bin/numericalanalysis > result.txt
```

3. Vizualize results

Create python environment

```
python3 -m venv .venv
source .venv/bin/activate
pip install matplotlib pandas prettytable
```

Run visualization script (will read result.txt file)
```
python viz.py
```

In short, to rerun the experiments with changed parameters (this is run.sh)
```
lake build
./.lake/build/bin/numericalanalysis
python viz.py
```