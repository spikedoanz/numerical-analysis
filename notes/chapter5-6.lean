/-

2025-02-19
deriving a multi step method


the solution of some ivp pde has the following property:

[[fundamental theorem of calculus]]
we can approximate f(t,y) with an interpolating polynomial and integrate that!

let p(t) interpolate f(t,y) and p(t) be determined by points (t0, w0), (t1, w2), ..., (ti,wi)
and y(ti) ≈ wi

* y(t{i+1}) = wi + ∫{ti→ti+1} p(t)dt   [this equation will show up on next next week]

pn(x) = a0 + a1(x-x0) + a2(x-x0)(x-x1) + ... + an(x-x0)(x-x1)...(x-xn)

extra: lagrange polynomials

polynomials of degree n are uniquely defined by n+1 points

f(x1) = f(x0) + a1 * (x1-x0)

f[xi] = f(xi)

and

f[xi,xi+1] = f[xi+1] - f[xi] := first dividied difference
             ------------
              xi+1  - xi


f[xi, xi+1, xi+2] = f[xi+1, xi+2] - f[xi, xi+1]  :second divided difference
                    ---------------------------
                    xi+2 - xi


nth: f[x0, xi, ... , xn] = f[x1, x2, ... xn] - f[x0, x1, ... xn-1]
                            -------------------------------------
                            xn - x0


pn(x) = a0 + a1(x-x0) + ... + an(x-x0) ... (x - xn-1)
        ak = f[x0, x1 ... xk]


if the nodes are equally spaced:
x = xn + sh
h = xi+1 - xi

pn(x) = pn(xn+sh) = f[xn] + sh*f[xn,xn-1] + s(s+1)h^2*f[xn, xn-1, xn-2] + ... + s(s+1)...(s+n-1)h^n f[xn,xn-1,...,x0]
-/



/-
DIVIDED DIFFERENCE:
backward difference
def given sequence: {Pn}^∞_n=0
the backwards difference is:
        ∇pn : ∇pn = pn - pn-1 n >= 1, with
        ∇²pn = ∇(∇pn)   = ∇pn - ∇pn-1
                        = pn-pn-1 - (pn-1 - pn-2)
                        = pn - 2pn-1 + pn-2

in general, ∇ᵏ = ∇(∇ᵏ⁻¹pₙ)


Pₙ(x) = f[⬝xₙ] + ∑ⁿₖ₌₁(-1)ᵏ(⁻ˢₖ)∇ᵏf(xₙ)


Pₙ(t) is an interpolating polynomial (tᵢ, f(tᵢ, y(tᵢ)), (tᵢ₋₁), y(tᵢ₋₁))

∃εᵢ∈(tᵢ₍ₘ₋₁₎, tᵢ) wᵢ+h




let t = tᵢ + sh
x = xₙ+sh


MULTI STEP METHODS: weird constants in RK4 pop up due to integrating random polynomials



-/
