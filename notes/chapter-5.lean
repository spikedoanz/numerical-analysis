/-
Taylor's theorem statement:

(t0, y0) ∈ D
f(t,y) ∈ D
f(t,y) = Pn(t,y) + Rn(t,y), where

Pn(t,y) = f(t0, y0) + (t-t0) * ∂f/∂t (t0, y0) + ...
-/


--================================================================--


/-
Note: A taylor method of order n requires n-1 derivatives of f

What if we could find constants α1, β1, a1 s.t

a1, f(t+α1, y+β1) is an approximation to

  T^(2) (t,y) = f(t,y) + h/2 f'(t,y)

Example: f'(t,y)  = df/dt (t,y) = ∂f/∂t * dt/dt + ∂f/∂y * dty/dt
                  = ∂f/∂t  + ∂f/∂y * dy/dt
                                     ^^^^^
                                     y' = f(t,y)
  ∴ f'(t,y) = ∂f/∂t  + ∂f/∂y * f(t,y)

  T^(2) (t,y) =  f(t,y) + h/2  (∂f/∂t(t,y)  + ∂f/∂y(t,y) * f(t,y))

The 2D Taylor polynomial of order 1 for f(t+α, y+β):

a1 * f(t+α, y+β1) = a1 * f(t,y) + a1 *
                    * (t+α - t) ∂f/∂t (t,y) +
                    a1 (y+β1 - y) ∂f/∂y (t,y)

                  = a1 * f(t,y) + a1α1 * ∂f/∂t (t,y) + a1β1 * ∂f/∂y(t,y)
                  = T^(2)
                  = f(t,y) + h/2  (∂f/∂t(t,y)  + ∂f/∂y(t,y) * f(t,y))

a1 * f(t,y)         = f(t,y)
a1α1 * ∂f/∂t (t,y)  = h/2 * ∂f/∂t (t,y)
a1β1 * ∂f/∂t (t,y)  = h/2 f(t,y) * ∂f/∂y(t,y)


T^(2) = f(t+h/2, y+h/2*f(t,y)) - R1 (t+h/2, y+h/2*f(t,y))

R1 = h^2 / 8 f_tt (ξ, μ) + h^2 / 4 * f_ty (ξ, μ) + h^2/8 f_yy(ξ,μ)

ξ is between t, t + h/2
μ is between y, y + h/2 * f(t,y)

∴ assuming all second order partials are bounded. R1 is O(h^2)
-/


--================================================================--


/-
2nd order taylor method:

y' = f(t,y) a ≤ y ≤ b, y(a) = α

w0 = α
w{i+1} = wi + h*T^(2) (ti, wi), i ∈ [0..N-1]

Midpoint method:

y' = f(t,y) a ≤ t ≤ b, y(a) = α
w0 = α
w{i+1} = wi + h*[ f(ti + h/2, wi + h/2 * f(ti, wi)) ], i ∈ [0..N-1]
-/

-- Exam : Might be asked to derive runge kutta


/-
Approximate y(1) with y' = f(t,y) = y - t^2 + 1 ; 0 ≤ t ≤ 2 ; y(0) = 0.5
Using Runge Kutta

w0 = 0.5
t1 = 0.5
h = 0.5

K1  = w0 + h/2 * f(t0, w0)
    = 0.5 + 0.25 * (1.5) = 0.875

w1  = 0.5 + 0.5 * f (0 + 0.5, 0.875)
    = 1.406

K1_2  = 1.406 + 0.25 * f(t1, w1)
      =                f(.5, 1.406)
      = 1.945
w2  = 1.406 + 0.5 * f(0.5, 1.945)
    = 2.59725

Euler's : y(1) ≈ 2.25
Actual  : y(1) = 2.64
-/

/-
You can also use the following to approximate T^(2)

a1 f(t,y)  + a2 f(t+α2, y+δ2 f(t,y))

Modified Euler's method:

w0    = α
wi+1  = wi + h/2 [ f(ti,wi) + f(ti+1, wi + h f(ti, wi)) ]

Practice: Do this method for the previous example
-/
