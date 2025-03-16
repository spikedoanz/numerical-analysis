#!/bin/sh
lake build
./.lake/build/bin/numericalanalysis > result.txt
python viz.py
