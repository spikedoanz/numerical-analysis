namespace List

def euler (f : Float → Float → Float)
          (t0 : Float) (y0 : Float) (h : Float)
          : Nat → List (Float × Float)
  | 0 => [(t0, y0)]
  | n + 1 => (t0, y0) :: euler f (t0 + h) (y0 + h * f t0 y0) h n


-- Exact y(t)
def _y (t: Float) := 1 + 0.5 * t^2
def _ts := range 11 |>.map (λ n => n.toFloat * 0.1)
def _ys := _ts |>.map (_y)

-- Euler's approximation of y(t) given y' = f(t,y) and y_0
def _f (t : Float) (y : Float) := t
def _y_0 := 1
def _approx := euler (_f) 0.0 1.0 0.1 10 |>.map (λ (_, x) => x)

def abs (a : Float) := a^2^0.5

def _diff (a b : List Float) : List Float := zipWith (λ x y => (abs (x - y))) a b

#eval _ys
#eval _approx
#eval _diff _ys _approx
