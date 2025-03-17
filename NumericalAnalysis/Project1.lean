set_option linter.unusedVariables false
namespace Project1
open List(range zipWith)
open Float (abs exp)

def V0 : Float := 12.0     -- Initial voltage (12V)
def R : Float := 12000.0   -- Resistance (12 kOhms)
def C : Float := 0.0001    -- Capacitance (100 microFarads)
def RC : Float := R * C    -- Time constant (to avoid recomputation)

def f (t : Float) (V : Float) : Float := -V / RC

def exactSolution (t : Float) : Float := V0 * exp (-t / RC)

-- Euler single step
def euler_step (f : Float → Float → Float) (t : Float) (y : Float) (h : Float) : Float :=
  y + h * f t y

-- RK4 single step
def rk4_step (f : Float → Float → Float) (t : Float) (y : Float) (h : Float) : Float :=
  let k₁ := h * f t y
  let k₂ := h * f (t + h/2) (y + k₁/2)
  let k₃ := h * f (t + h/2) (y + k₂/2)
  let k₄ := h * f (t + h) (y + k₃)
  y + (k₁ + 2*k₂ + 2*k₃ + k₄)/6

-- AB3 single step (requires previous points)
def ab3_step (f : Float → Float → Float)
            (tn : Float) (yn : Float)
            (tn_1 : Float) (yn_1 : Float)
            (tn_2 : Float) (yn_2 : Float)
            (h : Float) : Float :=
  -- AB3 formula: y_{n+1} = y_n + h/12 * (23f_n - 16f_{n-1} + 5f_{n-2})
  yn + h/12 * (23 * f tn yn - 16 * f tn_1 yn_1 + 5 * f tn_2 yn_2)

-- AM2 single step (requires predicted value and previous points)
def am2_step (f : Float → Float → Float)
            (tn : Float) (yn : Float)
            (tn_1 : Float) (yn_1 : Float)
            (tn_plus_1 : Float) (yn_plus_1_pred : Float)
            (h : Float) : Float :=
  -- AM2 formula: y_{n+1} = y_n + h/12 * (5*f(t_{n+1}, y_{n+1}^{(p)}) + 8*f(t_n, y_n) - f(t_{n-1}, y_{n-1}))
  yn + h/12 * (5 * f tn_plus_1 yn_plus_1_pred + 8 * f tn yn - f tn_1 yn_1)

-- Full method implementations using the individual steps

-- Euler method implementation
def euler (f : Float → Float → Float)
          (t0 : Float) (y0 : Float) (h : Float)
          : Nat → List (Float × Float)
  | 0 => [(t0, y0)]
  | n + 1 =>
      let prev := euler f t0 y0 h n
      match prev with
      | (tn, yn) :: _ =>
          let tn_plus_1 := tn + h
          let yn_plus_1 := euler_step f tn yn h
          (tn_plus_1, yn_plus_1) :: prev
      | _ => prev  -- This shouldn't happen, but handle just in case

-- RK4 method implementation
def rk4 (f : Float → Float → Float)
        (t0 : Float) (y0 : Float) (h : Float)
        : Nat → List (Float × Float)
  | 0 => [(t0, y0)]
  | n + 1 =>
      let prev := rk4 f t0 y0 h n
      match prev with
      | (tn, yn) :: _ =>
          let tn_plus_1 := tn + h
          let yn_plus_1 := rk4_step f tn yn h
          (tn_plus_1, yn_plus_1) :: prev
      | _ => prev  -- Lean4 requires all cases in a pattern match to be caught

-- AB3 method implementation
def ab3 (f : Float → Float → Float)
        (t0 : Float) (y0 : Float) (h : Float)
        : Nat → List (Float × Float)
  | 0 => [(t0, y0)]
  | 1 =>
    let t1 := t0 + h
    let y1 := euler_step f t0 y0 h  -- Use Euler for first step
    (t0, y0) :: [(t1, y1)]
  | 2 =>
    let prev := ab3 f t0 y0 h 1
    match prev with
    | (t1, y1) :: _ =>
      let t2 := t1 + h
      let y2 := euler_step f t1 y1 h  -- Use Euler for second step
      (t2, y2) :: prev
    | _ => prev
  | n + 1 =>
    let prev := ab3 f t0 y0 h n
    match prev with
    | (tn, yn) :: (tn_1, yn_1) :: (tn_2, yn_2) :: rest =>
      -- We have at least 3 points, can use AB3 formula
      let tn_plus_1 := tn + h
      let yn_plus_1 := ab3_step f tn yn tn_1 yn_1 tn_2 yn_2 h
      (tn_plus_1, yn_plus_1) :: prev
    | _ => prev

-- Predictor-Corrector (AB3-AM2) method (use RK4 for inital steps)
def ab3am2 (f : Float → Float → Float)
          (t0 : Float) (y0 : Float) (h : Float)
          : Nat → List (Float × Float)
  | 0 => [(t0, y0)]
  | 1 =>
    let t1 := t0 + h
    let y1 := rk4_step f t0 y0 h
    (t0, y0) :: [(t1, y1)]
  | 2 =>
    let prev := ab3am2 f t0 y0 h 1
    match prev with
    | (t1, y1) :: _ =>
      let t2 := t1 + h
      let y2 := rk4_step f t1 y1 h
      (t2, y2) :: prev
    | _ => prev
  | 3 =>
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
    | (tn, yn) :: (tn_1, yn_1) :: (tn_2, yn_2) :: rest =>
      -- We have at least 3 points, can use AB3-AM2
      let tn_plus_1 := tn + h

      -- AB3 Predictor
      let yn_plus_1_pred := ab3_step f tn yn tn_1 yn_1 tn_2 yn_2 h

      -- AM2 Corrector
      let yn_plus_1 := am2_step f tn yn tn_1 yn_1 tn_plus_1 yn_plus_1_pred h

      (tn_plus_1, yn_plus_1) :: prev
    | _ => prev

-- Function to generate time points
def generateTimePoints (t0 : Float) (h : Float) (n : Nat) : List Float :=
  range (n+1) |>.map (λ i => t0 + i.toFloat * h)

-- Function to calculate solutions from all methods and exact solution
def calculateAllSolutions (f : Float → Float → Float)
                          (exact : Float → Float)
                          (t0 : Float) (y0 : Float) (h : Float) (steps : Nat)
                          : List (List Float) :=
  -- Generate time points
  let timePoints := generateTimePoints t0 h steps

  -- Calculate results from each method
  let eulerResults := euler f t0 y0 h steps
  let rk4Results := rk4 f t0 y0 h steps
  let ab3Results := ab3 f t0 y0 h steps
  let ab3am2Results := ab3am2 f t0 y0 h steps

  -- Extract values in correct time order
  let eulerValues := eulerResults.reverse.map (λ (_, y) => y)
  let rk4Values   := rk4Results.reverse.map (λ (_, y) => y)
  let ab3Values   := ab3Results.reverse.map (λ (_, y) => y)
  let ab3am2Values := ab3am2Results.reverse.map (λ (_, y) => y)

  -- Calculate exact values
  let exactValues := timePoints.map exact
  let eulerDiffs  := zipWith (λ x y => abs (x - y)) exactValues eulerValues
  let rk4Diffs    := zipWith (λ x y => abs (x - y)) exactValues rk4Values
  let ab3Diffs    := zipWith (λ x y => abs (x - y)) exactValues ab3Values
  let ab3am2Diffs := zipWith (λ x y => abs (x - y)) exactValues ab3am2Values

  [timePoints, exactValues, eulerValues, rk4Values, ab3Values, ab3am2Values,
   eulerDiffs, rk4Diffs, ab3Diffs, ab3am2Diffs]

-- Function to generate CSV output
def generateCSV (results : List (List Float)) : String :=
  let timePoints := results[0]!
  let exactValues := results[1]!
  let eulerValues := results[2]!
  let rk4Values := results[3]!
  let ab3Values := results[4]!
  let ab3am2Values := results[5]!

  -- Build the csv
  let headerRow := "time,"      ++ String.intercalate "," (timePoints.map toString)
  let exactRow  := "explicit,"  ++ String.intercalate "," (exactValues.map toString)
  let eulerRow  := "euler,"     ++ String.intercalate "," (eulerValues.map toString)
  let rk4Row    := "rk4,"       ++ String.intercalate "," (rk4Values.map toString)
  let ab3Row    := "ab3,"       ++ String.intercalate "," (ab3Values.map toString)
  let ab3am2Row := "ab3am2,"    ++ String.intercalate "," (ab3am2Values.map toString)

  String.intercalate "\n" [headerRow, exactRow, eulerRow, rk4Row, ab3Row, ab3am2Row]

-- Function to generate CSV for differences
def generateDiffCSV (results : List (List Float)) : String :=
  let timePoints := results[0]!
  let eulerDiffs := results[6]!
  let rk4Diffs := results[7]!
  let ab3Diffs := results[8]!
  let ab3am2Diffs := results[9]!

  -- Build the csv
  let headerRow := "function,"    ++ String.intercalate "," (timePoints.map toString)
  let eulerRow  := "euler_diff,"  ++ String.intercalate "," (eulerDiffs.map toString)
  let rk4Row    := "rk4_diff,"    ++ String.intercalate "," (rk4Diffs.map toString)
  let ab3Row    := "ab3_diff,"    ++ String.intercalate "," (ab3Diffs.map toString)
  let ab3am2Row := "ab3am2_diff," ++ String.intercalate "," (ab3am2Diffs.map toString)

  String.intercalate "\n" [headerRow, eulerRow, rk4Row, ab3Row, ab3am2Row]

-- Main simulation function (keeping as before)
def runSimulation (t0 : Float) (tMax : Float) (h : Float) : IO Unit := do
  -- Hilariously, lean4 also doesn't have a Float->Nat function so
  -- this has to be done instead.
  let steps := ((tMax - t0) / h).toUInt32.toNat

  -- Calculate results
  let results := calculateAllSolutions f exactSolution t0 V0 h steps
  let solutionsCSV  := generateCSV results
  let diffsCSV      := generateDiffCSV results

  -- Print the results (no built in csv library so i have to do jank)
  IO.println "<solutions>"
  IO.println solutionsCSV
  IO.println "</solutions>"
  IO.println ""
  IO.println "<differences>"
  IO.println diffsCSV
  IO.println "</differences>"

def main : IO Unit :=
  -- 1e-5 [0..1] seems to be the limit. Stack size limit on most
  -- computers is 10k, so this tracts
  runSimulation 0.0 10.0 0.1

end Project1
