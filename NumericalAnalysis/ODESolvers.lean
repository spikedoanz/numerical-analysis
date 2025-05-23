namespace NumericalAnalysis.ODESolvers

-- Euler single step
def euler_step (f : Float → Float → Float) (t : Float) (y : Float) (h : Float) : Float :=
  y + h * f t y

def euler (f : Float → Float → Float)
          (t0 : Float) (y0 : Float) (h : Float)
          (n : Nat) : List (Float × Float) :=
  let rec aux : Nat → List (Float × Float) → List (Float × Float)
    | 0, acc => acc
    | n+1, acc =>
        match acc with
        | (tn, yn) :: _ =>
            let tnew := tn + h
            let ynew := euler_step f tn yn h
            aux n ((tnew, ynew) :: acc)
        | _ => acc
  aux n [(t0, y0)]

def rk4_step (f : Float → Float → Float) (t : Float) (y : Float) (h : Float) : Float :=
  let k₁ := h * f t y
  let k₂ := h * f (t + h/2) (y + k₁/2)
  let k₃ := h * f (t + h/2) (y + k₂/2)
  let k₄ := h * f (t + h) (y + k₃)
  y + (k₁ + 2*k₂ + 2*k₃ + k₄)/6

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

-- AB3 single step (requires previous points)
def ab3_step (f : Float → Float → Float)
            (tn : Float) (yn : Float)
            (tn_1 : Float) (yn_1 : Float)
            (tn_2 : Float) (yn_2 : Float)
            (h : Float) : Float :=
  -- AB3 formula: y_{n+1} = y_n + h/12 * (23f_n - 16f_{n-1} + 5f_{n-2})
  yn + h/12 * (23 * f tn yn - 16 * f tn_1 yn_1 + 5 * f tn_2 yn_2)

-- AB3 method implementation
def ab3 (f : Float → Float → Float)
        (t0 : Float) (y0 : Float) (h : Float)
        : Nat → List (Float × Float)
  | 0 => [(t0, y0)]
  | 1 =>
    let t1 := t0 + h
    let y1 := rk4_step f t0 y0 h  -- Use rk4 for first step
    (t1, y1) :: [(t0, y0)]
  | 2 =>
    let prev := ab3 f t0 y0 h 1
    match prev with
    | (t1, y1) :: _ =>
      let t2 := t1 + h
      let y2 := rk4_step f t1 y1 h  -- Use rk4 for second step
      (t2, y2) :: prev
    | _ => prev
  | n + 1 =>
    let prev := ab3 f t0 y0 h n
    match prev with
    | (tn, yn) :: (tn_1, yn_1) :: (tn_2, yn_2) :: _rest =>
      -- We have at least 3 points, can use AB3 formula
      let tnew := tn + h
      let ynew := ab3_step f tn yn tn_1 yn_1 tn_2 yn_2 h
      (tnew, ynew) :: prev
    | _ => prev

-- AM2 single step (requires predicted value and previous points)
def am2_step (f : Float → Float → Float)
            (tn : Float) (yn : Float)
            (tn_1 : Float) (yn_1 : Float)
            (tnew : Float) (ynew_pred : Float)
            (h : Float) : Float :=
  -- AM2 formula: y_{n+1} = y_n + h/12 * (5*f(t_{n+1}, y_{n+1}^{(p)}) + 8*f(t_n, y_n) - f(t_{n-1}, y_{n-1}))
  yn + h/12 * (5 * f tnew ynew_pred + 8 * f tn yn - f tn_1 yn_1)

-- Predictor-Corrector (AB3-AM2) method
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

end NumericalAnalysis.ODESolvers
