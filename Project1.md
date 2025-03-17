# Implementation details

The ODE solver implementations sit in 
NumericalAnalysis/ODESolvers.lean

The main entry script to run and configure parameters for experiments
themselves are in NumericalAnalysis/Project1.lean

Since lean doesn't really have libraries for data processing,
I've opted to just have the script output to a file, then 
processed by python with the usual pandas matplotlib combo (see
viz.py)

As a bonus, I also tossed in implementations for Euler and AB3. These
can be toggled on or off by taking them out of the METHODS array
in viz.py

For a guide to set up and run the implementaiton / visualizations,
please read the attached README.md in this repository.

---

# Algorithm descriptions

> For all of the algorithms implemented, I've split them
> into both the single step pass of the algorithm (rk4_step)
> , as well as the main entry function which does the 
> structural iteration function (rk4). 

> The reason for this is obviously code reuse, but also partially
> necessary to implement certain optimizations in a functional
> language, like tail-end recursion. This will be detailed in
> a tangent about Lean4 specifics later.

## RK4

### Single step (rk4_step)

```
def rk4_step (f : Float → Float → Float) (t : Float) (y : Float) (h : Float) : Float :=
  let k₁ := h * f t y
  let k₂ := h * f (t + h/2) (y + k₁/2)
  let k₃ := h * f (t + h/2) (y + k₂/2)
  let k₄ := h * f (t + h) (y + k₃)
  y + (k₁ + 2*k₂ + 2*k₃ + k₄)/6
```

Takes in the partial derivative and its parameters, evaluates
it on some magical constants, spits out the approximation for
the current time step.

### Structural iteration (rk4)

```
def rk4 (f : Float → Float → Float)
        (t0 : Float) (y0 : Float) (h : Float)
        (n : Nat) : List (Float × Float) :=
  let rec aux : Nat → List (Float × Float) → List (Float × Float)
    | 0, acc => acc
    | n+1, acc =>
        match acc with
        | (tn, yn) :: _ =>
            let tnew := tn + h
            let ynew := rk4_step f tn yn h
            aux n ((tnew, ynew) :: acc)
        | _ => acc
  aux n [(t0, y0)]
```

Exactly the same as Euler's method, runs through the number
of requested points (n), iterating t by adding h on each iteration,
and evaluating f at the current point before appending it to
the list of answers and using that evaluation for the next step.

---
