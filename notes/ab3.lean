/-
A-B3

wi+1 = wi + h/12 [23 f(ti,wi) - 16 f(ti-1, wi-1) + 5 f(ti-2,wi-2)]

w0 = α, w1 = α1, w2 = α2


ex: consider y' = y - t²+1, 0 <= t <= 2

h = 0.2, find y(0.6)

use y(t) = (t+1)² - 0.5eᵗ to obtain α{0..2}


τi+1(h) = 3/8 y^(4) (μi) h^3

** adams-moulton 3 step method

w0 = α, w1 = α1, w2 = α2

wi+1 = wi + h/24 [9 f(ti+1, wi+1) + 19 f(ti, wi) - 5(ti-2,wi-2)]

τi+1(h) = -19/720 y^(5)(μi)h^4


=> wi+1 is solvable if y' is linear in y



predictor corrector method
--------------------------

use an A-B explicit method to find wi+1 and then use the approximation
in an Adams Moulton implicit method to refine




-/
