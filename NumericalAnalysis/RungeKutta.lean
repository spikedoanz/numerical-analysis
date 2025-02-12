def euler (f : Float → Float → Float)
          (t0 : Float) (y0 : Float) (h : Float)
          : Nat → List (Float × Float)
  | 0 => [(t0, y0)]
  | n + 1 => (t0, y0) :: euler f (t0 + h) (y0 + h * f t0 y0) h n

def f (t : Float) (y : Float) := 1 + y/t
