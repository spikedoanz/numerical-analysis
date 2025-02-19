###### chatper 1

*definition 1.1*: a function f defined on a set X of real numbers has the limit L at x_0 written

$$lim_{x\to x_0} f(x) = L$$
if, given any real number $\varepsilon > 0$  there exiss a real number $\delta > 0$ such that

$$ | f(x) - L | < \varepsilon$$ whevever $x \in X$ and $0 < |x - x_0| < \delta$

> a function has a limit there exists a bound for its evaluation about a point, as you get arbitrarily close to that point


*definition 1.2*: let f be a function defined on a set X of real numbers and x0 \in X. then f is continuous at x_0 if

lim x->x0 f(x) = f(x_0)

> a function is continuous over a set if 
> 1. it is defined for every point in that set
> 2. the limit exists for every point in that set
> 3. the limit is the same as the function evaluation

*definition 1.3* a sequence has the limit x (converges to x) if:
> it has an arbitrarily small lower bound a difference between the function evaluation and there exists some number n s.t every point larger than n will be different by at most epsilon

*theorem 1.4* : if f is a function defined on a set X of reals and x0 \in X, then the following statements are equivalent:
- f is continuous at x0
- there exists a convergent sequence from x->x0 and lim f(x) -> f(x)

*definition 1.5* a function is differentiable at x if it is linearly approximable at x

*theorem 1.6* if function is differentiable at x then it is continuous at x

*theorem 1.7* rolle's theorem. if a function is differentiable over (a,b) and f(a) == f(b) then there exists a number c within (a,b) such that f'(c) = 0

*theorem 1.8* mean value theorem: if f in C[a,b] and f is differentiable on (a,b) then a number exists in (a,b) such that it linearly approximates the relationship between f(a) and f(b).

$$f'(c) = \frac {f(b)-f(a)}{b-a}$$
*theorem 1.9* extreme value theorem: if $f \in C[a,b]$, then c1, c2 in [a,b] exists with f(c1) <= f(x) <= f(c2), for all x in [a,b]. in addition, if f is differentiable on (a,b), then the numbers c1 c2 occur either at the endpoints of [a,b] or where f' is zero.

*theorem 1.10* generalized rolle's theorem:  