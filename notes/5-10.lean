/-

one step methods

def: a one step difference equation method with local truncation error τi_1(h) at step i is said
to be ocnsistent if:

lim{h->0}   max {1<=i<=N}  |τi(h)| = 0


def: a 1 step method is convergent wrt the ODE if

lim{h->0}   max {1<=i<=N}  |wi - y(ti)| = 0



euler's method is convergent!

max {1<=i<=N} |wi - y(ti)| <= Mh/2L |e^{L(b-a)} -1|

lim{h->0} [Mh/2L |e^{L(b-a)} -1|] = 0



def: a method is stable if a small change in the initial conditions produce
correspondingly small changes in the approximation


theorem: suppose the ivp y'=f(t,y), a<=t<=b, y(a)=α
is approximated by a one-step difference method:

wi+1 = wi + hΦ(ti,wi,h)


also suppose ∃h0 >0 and Φ(t,w,h) is continuous and satisfies a lipschitz condition
in w on:

D = {(t,w,h) | a<=t<=b, w∈(-∞,∞), 0<=h<=h0}

then:
  (i): the method is stable
  (ii): the method is convergent <=> the method is consistent



-/
