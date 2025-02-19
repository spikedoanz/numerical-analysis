/-
error control and the runge kutta fehlerg method
------------------------------------------------

IVP: y' = f(t,y) a <= t <= b
y(a) = α


"one step" methods:

w{i+1} = wi + hi Φ (ti, wi, hi)

ideally, for any ε > 0 we want to choose n such that
|y(ti) - wi| < ε ∀ i ∈ [0..n]

recall: the order n taylor method of the form:

y(ti+1) = y(ti) + h Φ (ti, yi, h) + O(h^{n_1})

generates the approximations

w{i+1} = h Φ (ti, wi, h) ; i ∈ [0..N-1]

T{i+1} = O(h^n)

--------------------------------------------
"truncation error" difference between y and
the approximation over the meshpoints
--------------------------------------------

---------------------------------------------------
"floating point error" is the difference between
a real number and its floating point representation
also called "rounding error"
---------------------------------------------------


Let Φ be derived using a runge kutta method of order n


for w{i+1} ≈ y(ti+1):  T{i+1}(h)  = {y(ti+1) - y(ti)/h} / {Φ (ti, yi, h)}

wi ≈ yi                           ≈ {y(ti+1) - wi/h} / {Φ (ti, wi, h)}
                                  = {y(ti+1) - wi - h Φ (ti, wi, h)} / h
where wi - h Φ (ti, wi, h) is just w{i+1}
                                  = {y(ti+1) - w{i+1}} / h
τ{hat}{t+1}(h) ≈ {y(ti+1) - w{hat}{i+1}}/h
where {hat} denotes higher order methods


τ{i+1} (h)  = 1/h * (y{i+1} - w{i+1})
            = 1/h (y{i+1} - w{i+1} + w{hat}{i+1} - w{hat}{i+1}
            = 1/h (y{i+1} - w{hat}{i+1} + w{hat}{i+1} - w{i+1})
              ^^^^^^^^^^^^^^^^^^^^^^^^^ := τ{i+1}(h)
            = τ{i+1}(h) + 1/h * (w{hat}{i+1} - w{i+1})

τ{i+1}(h)   ≈ 1/h * (w{hat}{i+1} - w{i+1})
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ := R

Since τ{i+1}(h) is O(h^n) assume ∃K, s.t τ{i+1} ≈ Kh^n

τ{i+1}(qh) ≈ K(qh)^n  = q^n K h^n
      ^^^^ := new step size
                      ≈ q^n τ{i+1}(h)
                      ≈ q^n / h (w{hat}{i+1} - w{i+1})

if we want to bound our truncation error:

| τ{i+1}(qh) | <= ε

≈ |q^n / h (w{hat}{i+1} - w{i+1}) |  <= ε

= q^n / h * |w{hat}{i+1} - w{i+1} | <= ε

=> q <= (hε / |w{hat}{i+1} - w{i+1}|)^1/n

------------------------------
q is the step size peturbation
------------------------------


------------------------------------------------
Fourth-Order Runge-Kutta Method (RK4)
------------------------------------------------

IVP:
  y' = f(t, y),   a ≤ t ≤ b,   y(a) = α

One-step method:
  w_{i+1} = w_i + h_i * Φ(t_i, w_i, h_i)

Increment function Φ:
  Φ(t, w, h) = (1/6) * (k1 + 2k2 + 2k3 + k4)

Stages:
  k1 = f(t, w)
  k2 = f(t + h/2, w + (h/2)*k1)
  k3 = f(t + h/2, w + (h/2)*k2)
  k4 = f(t + h, w + h*k3)

Algorithm:
  At each step t_i:
    1. Compute k1, k2, k3, k4 using the stages above.
    2. Update w_{i+1} = w_i + (h/6)*(k1 + 2k2 + 2k3 + k4).

Properties:
  - Local Truncation Error: O(h^4)
  - Global Error: O(h^4) (fourth-order accuracy)

------------------------------------------------

R-K-F uses a similar method but derives a 4th order and 5th
order R-K method that use combined 6 function evaluations
and can approximate τ{hat}(h) at each step.


-/
