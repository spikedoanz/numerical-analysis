set_option linter.unusedVariables false
namespace Project1
open List(range zipWith)
open Float (abs exp)

def V0 : Float := 12.0     -- Initial voltage (12V)
def R : Float := 12000.0   -- Resistance (12 kOhms)
def C : Float := 0.0001    -- Capacitance (100 microFarads)
def RC : Float := R * C    -- Time constant

def f (t : Float) (V : Float) : Float := -V / RC

def exactSolution (t : Float) : Float := V0 * exp (-t / RC)

def euler (f : Float → Float → Float)
          (t0 : Float) (y0 : Float) (h : Float)
          : Nat → List (Float × Float)
  | 0 => [(t0, y0)]
  | n + 1 => (t0, y0) :: euler f (t0 + h) (y0 + h * f t0 y0) h n

def rk4 (f : Float → Float → Float)
        (t0 : Float) (y0 : Float) (h : Float)
        : Nat → List (Float × Float)
  | 0 => [(t0, y0)]
  | n + 1 =>
    let k₁ := h * f t0 y0
    let k₂ := h * f (t0 + h/2) (y0 + k₁/2)
    let k₃ := h * f (t0 + h/2) (y0 + k₂/2)
    let k₄ := h * f (t0 + h) (y0 + k₃)
    let y_next := y0 + (k₁ + 2*k₂ + 2*k₃ + k₄)/6
    (t0, y0) :: rk4 f (t0 + h) y_next h n

def ab3 (f : Float → Float → Float)
        (t0 : Float) (y0 : Float) (h : Float)
        : Nat → List (Float × Float)
  | 0 => [(t0, y0)]
  | 1 =>
    let t1 := t0 + h
    let y1 := y0 + h * f t0 y0  -- Use Euler for first step
    (t0, y0) :: [(t1, y1)]
  | 2 =>
    let t1 := t0 + h
    let y1 := y0 + h * f t0 y0  -- Use Euler for first step
    let t2 := t1 + h
    let y2 := y1 + h * f t1 y1  -- Use Euler for second step
    (t0, y0) :: (t1, y1) :: [(t2, y2)]
  | n + 1 =>
    let prev := ab3 f t0 y0 h n
    match prev with
    | (tn, yn) :: (tn_1, yn_1) :: (tn_2, yn_2) :: rest =>
      -- We have at least 3 points, can use AB3 formula
      let tn_plus_1 := tn + h
      -- AB3 formula: y_{n+1} = y_n + h/12 * (23f_n - 16f_{n-1} + 5f_{n-2})
      let yn_plus_1 := yn + h/12 * (23 * f tn yn - 16 * f tn_1 yn_1 + 5 * f tn_2 yn_2)
      (tn_plus_1, yn_plus_1) :: prev
    | _ =>
      -- This happens for n=2, but we've handled it with a specific pattern above
      prev

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

  -- Extract values in correct time order
  let eulerValues := eulerResults.reverse.map (λ (_, y) => y)
  let rk4Values := rk4Results.reverse.map (λ (_, y) => y)
  let ab3Values := ab3Results.reverse.map (λ (_, y) => y)

  -- Calculate exact values
  let exactValues := timePoints.map exact

  -- Calculate differences
  let eulerDiffs := zipWith (λ x y => abs (x - y)) exactValues eulerValues
  let rk4Diffs := zipWith (λ x y => abs (x - y)) exactValues rk4Values
  let ab3Diffs := zipWith (λ x y => abs (x - y)) exactValues ab3Values

  [timePoints, exactValues, eulerValues, rk4Values, ab3Values, eulerDiffs, rk4Diffs, ab3Diffs]

-- Function to generate CSV output
def generateCSV (results : List (List Float)) : String :=
  let timePoints := results[0]!
  let exactValues := results[1]!
  let eulerValues := results[2]!
  let rk4Values := results[3]!
  let ab3Values := results[4]!

  -- Build the header row with time points
  let headerRow := "time," ++
                   String.intercalate "," (timePoints.map toString)

  -- Build the data rows
  let exactRow := "explicit," ++
                  String.intercalate "," (exactValues.map toString)
  let eulerRow := "euler," ++
                  String.intercalate "," (eulerValues.map toString)
  let rk4Row := "rk4," ++
                String.intercalate "," (rk4Values.map toString)
  let ab3Row := "ab3," ++
                String.intercalate "," (ab3Values.map toString)

  -- Combine all rows
  String.intercalate "\n" [headerRow, exactRow, eulerRow, rk4Row, ab3Row]

-- Function to generate CSV for differences
def generateDiffCSV (results : List (List Float)) : String :=
  let timePoints := results[0]!
  let eulerDiffs := results[5]!
  let rk4Diffs := results[6]!
  let ab3Diffs := results[7]!

  -- Build the header row with time points
  let headerRow := "function," ++
                   String.intercalate "," (timePoints.map toString)

  -- Build the data rows
  let eulerRow := "euler_diff," ++
                  String.intercalate "," (eulerDiffs.map toString)
  let rk4Row := "rk4_diff," ++
                String.intercalate "," (rk4Diffs.map toString)
  let ab3Row := "ab3_diff," ++
                String.intercalate "," (ab3Diffs.map toString)

  -- Combine all rows
  String.intercalate "\n" [headerRow, eulerRow, rk4Row, ab3Row]

-- Main simulation function
def runSimulation (t0 : Float) (tMax : Float) (h : Float) : IO Unit := do
  -- Hilariously, lean4 also doesn't have a Float->Nat function so
  --this has to be done instead.
  let steps := ((tMax - t0) / h).toUInt32.toNat

  -- Calculate all solutions
  let results := calculateAllSolutions f exactSolution t0 V0 h steps

  -- Generate CSV outputs
  let solutionsCSV  := generateCSV results
  let diffsCSV      := generateDiffCSV results

  -- Print the results
  IO.println "<solutions>"
  IO.println solutionsCSV
  IO.println "</solutions>"
  IO.println ""
  IO.println "<differences>"
  IO.println diffsCSV
  IO.println "</differences>"

-- Run the simulation with specific parameters
def main : IO Unit :=
  runSimulation 0.0 1.0 0.1

end Project1

-- Uncomment for interactive result in the window
-- #eval Project1.main
