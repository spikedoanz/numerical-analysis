# Project 1

```
numerical-analysis § tree
.
├── NumericalAnalysis
│   ├── ODESolvers.lean
│   └── Project1.lean
├── NumericalAnalysis.lean
├── Project1.md
├── README.md
├── figures
│   ├── ...
├── run.sh
└── viz.py
```

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

Uses 4 total function evaluations. All at the current step,
so no fancy caching required.

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

## AB3-AM2

### Single step (am2_step)

```
def am2_step (f : Float → Float → Float)
            (tn : Float) (yn : Float)
            (tn_1 : Float) (yn_1 : Float)
            (tnew : Float) (ynew_pred : Float)
            (h : Float) : Float :=
  -- AM2 formula: y_{n+1} = y_n + h/12 * (5*f(t_{n+1}, y_{n+1}^{(p)}) + 8*f(t_n, y_n) - f(t_{n-1}, y_{n-1}))
  yn + h/12 * (5 * f tnew ynew_pred + 8 * f tn yn - f tn_1 yn_1)
```

Uses multiple function evaluations, at different timesteps.
Uses the prediction evaluation for the current timestep from a
different method (in this case AB3), and then further refines that
prediction using an implicit method.

Uses 2 total function evaluations (excluding cached steps
from AB3)

## Structural iteration (ab3am2)

```
def ab3am2 (f : Float → Float → Float)
          (t0 : Float) (y0 : Float) (h : Float)
          : Nat → List (Float × Float)
  | 0 => [(t0, y0)]
  | 1 => -- RK4 for first step
    let t1 := t0 + h
    let y1 := rk4_step f t0 y0 h
    (t1, y1) :: [(t0, y0)]
  | 2 => -- RK4 for 2nd step
    let prev := ab3am2 f t0 y0 h 1
    match prev with
    | (t1, y1) :: _ =>
      let t2 := t1 + h
      let y2 := rk4_step f t1 y1 h
      (t2, y2) :: prev
    | _ => prev
  | 3 => -- Use RK4 for third step
    let prev := ab3am2 f t0 y0 h 2
    match prev with
    | (t2, y2) :: _ =>
      let t3 := t2 + h
      let y3 := rk4_step f t2 y2 h
      (t3, y3) :: prev
    | _ => prev
  | n + 1 =>
    let prev := ab3am2 f t0 y0 h n
    match prev with
    | (tn, yn) :: (tn_1, yn_1) :: (tn_2, yn_2) :: _rest =>
      -- We have at least 3 points, can use AB3-AM2
      let tnew := tn + h
      -- AB3 Predictor
      let ynew_pred := ab3_step f tn yn tn_1 yn_1 tn_2 yn_2 h
      -- AM2 Corrector
      let ynew := am2_step f tn yn tn_1 yn_1 tnew ynew_pred h
      (tnew, ynew) :: prev
    | _ => prev
```

This algorithm first uses 2 function approximations (using RK4)
to achieve 3 points (for AB3 mostly, the predictor corrector method
can work without cached points).

It then plugs those 3 points into AB3, obtaining the predictor
step of the evaluation, which is then plugged into the AM2_step,
which does the fancy implicit method.

For efficiency, the extra 2 function evaluations only has to be
done once at the start of the iteration. For future iterations,
it will only have to use 2 evaluations: one for the predictor
step, and the other for the corrector step.

One nice thing about functional languages is that the optimization
mentioned above can be expressed very elegantly using 
[pattern matching](https://en.wikipedia.org/wiki/Pattern_matching).


# Analysis of the numerics

```
--- Metrics for Step Size 0.01 ---
+--------+---------------+-------------+-------------+-------------+--------------------+
| Method | Initial Value | 50% at Time | 99% at Time | Total Error | Avg Relative Error |
+--------+---------------+-------------+-------------+-------------+--------------------+
| euler  |    12.0000    |    0.8283   |    5.5032   |   5.995124  |      0.017275      |
|  rk4   |    12.0000    |    0.8318   |    5.5262   |   0.000000  |      0.000000      |
|  ab3   |    12.0000    |    0.8318   |    5.5262   |   0.000282  |      0.000000      |
| ab3am2 |    12.0000    |    0.8318   |    5.5262   |   0.000000  |      0.000000      |
+--------+---------------+-------------+-------------+-------------+--------------------+


--- Metrics for Step Size 0.08 ---
+--------+---------------+-------------+-------------+-------------+--------------------+
| Method | Initial Value | 50% at Time | 99% at Time | Total Error | Avg Relative Error |
+--------+---------------+-------------+-------------+-------------+--------------------+
| euler  |    12.0000    |    0.8039   |    5.3404   |   6.055020  |      0.133276      |
|  rk4   |    12.0000    |    0.8324   |    5.5264   |   0.000028  |      0.000000      |
|  ab3   |    12.0000    |    0.8323   |    5.5257   |   0.018755  |      0.000485      |
| ab3am2 |    12.0000    |    0.8324   |    5.5265   |   0.002415  |      0.000065      |
+--------+---------------+-------------+-------------+-------------+--------------------+


--- Metrics for Step Size 0.64 ---
+--------+---------------+-------------+-------------+-------------+--------------------+
| Method | Initial Value | 50% at Time | 99% at Time | Total Error | Avg Relative Error |
+--------+---------------+-------------+-------------+-------------+--------------------+
| euler  |    12.0000    |    0.6000   |    3.8782   |   6.525223  |      0.749062      |
|  rk4   |    12.0000    |    0.8696   |    5.5699   |   0.023134  |      0.004509      |
|  ab3   |    12.0000    |    0.8696   |    5.2821   |   0.975950  |      1.666252      |
| ab3am2 |    12.0000    |    0.8696   |    5.6848   |   0.194688  |      0.111148      |
+--------+---------------+-------------+-------------+-------------+--------------------+
```

At the small step size (0.01), almost all methods
except Euler are performing excellently. RK4 and 
AB3AM2 show essentially perfect results within
floating point precision, while AB3 shows only
microscopic errors. Poor Euler still lags with a
noticeable total error of ~5.995, though it's
not catastrophically off.

As we increase to the medium step size (0.08), the
hierarchy becomes more apparent. RK4 holds strong
with negligible error, while AB3 begins showing 
weakness. The predictor-corrector approach of
AB3AM2 proves valuable here, keeping its error
about 7-8 times lower than pure AB3. Euler is
already in serious trouble, showing its
inability to handle the 8x step size 
increase gracefully.

The large step size (0.64) really stress-tests these
methods with revealing results. Euler completely loses
the plot, with its 50% time estimate way off at
0.6000 versus the ~0.87 suggested by other methods.
The real surprise is AB3, which actually
performs worse than Euler in terms of relative
error!

In brief, RK4 shows impressive resilience 
despite the large step size, while 
AB3AM2 hangs in there with reasonable
accuracy. These results demonstrate why choosing the
right numerical method isn't just about theoretical
order of accuracy, but requires understanding
stability properties and practical performance
at your target step size.


# Notes on efficiency

In terms of raw number of function evaluations, the tier list is
as follows:

1. Euler : 1 eval per step

2. AB3 : 1ish eval per step

3. AB3-AM2: 2ish evals per step

4. RK4 : 4 evals per step

Because all of the methods don't really do anything special to the 
evaluated functions beyond just some basic extra scalar operations,
the main component of the cost will be the function evaluation itself.

Another note though, is that both AB3 and AB3-AM2 require caching as a
part of their evaluation scheme. So, if the function being evaluated
has extremely large outputs (say, 10 million dimensional vector), then
there is that memory cost. It is a constant multiple though, so 
ultimately even this is not that significant of a cost.


# Tangent on lean as a language 

> Many (if not most) of these issues may go away with if handed
> to a more experienced programmer, as this is my first time
> using Lean in a practical setting.

> This is mostly to explain the weirdness of my implementation, 
> please feel free to skip if you feel that it is 
> unrelated to the rubric.

## 1. No mutability (for variables)

Because functional languages forbid the changing of state, (if a
number i is set to 0, it cannot be changed after), this also means
that certain things that come naturally in other languages 
become somewhat awkward in Lean.

For loops cannot be used (since there can be no variable we can
use for counting), though structural iteration is possible (by 
iterating a function over a foldable structure like a list)

This is why all of the algorithms implemented for this project
have been written as a recursive form.

## 2. No mutability (for other data structures)

Again due to immutability, it is impossible to express something like

```
a := some list of length n
a.set some index less than n to be some value
```

Since this would implicitly mutate the variable inside the array.

So the solution is to structurally build up the array using the
function itself. Here is an extremely consise version of euler's
method:

```
def euler (f : Float → Float → Float)
          (t0 : Float) (y0 : Float) (h : Float)
          : Nat → List (Float × Float)
  | 0 => [(t0, y0)]
  | n + 1 => (t0, y0) :: euler f (t0 + h) (y0 + h * f t0 y0) h n
```

As we can see, there is no array being mutated, but instead the array
is built up step by step as a consequence of following through the 
recursive evaluation of the function.

[Skill issue] Because I am inexperienced and do not know how to
write good functional code, all of the methods implemented actually
build the list in reverse (only prepend). This is easily
fixed at evaluation time by reversing them, which is fortunately
a free action in lean4 (since the reversal also doesn't mutate
the list, only changes how it is accessed later)

## 3. Very young languages don't have libraries

Lean4 doesn't have many libraries for much of anything at all.
I probably would fail the experiment if I had to do an http call.
Included in this statement is the fact that Lean4 also doesn't have
a library for naturally parsing and creating csvs, nor does it 
have a library for plotting or creating tables.

I briefly considered writing these myself for the project, but
promptly reconsidered when I realized that I had better things to
do with my time than implementing a png compatible spec.

So I regretfully relied on Python for this portion of the project.
My sincerest apologies for this show of programming ineptitude.

