import NumericalAnalysis.ODESolvers
set_option linter.unusedVariables false
namespace Project1
open List(range zipWith)
open Float (abs exp)
open NumericalAnalysis.ODESolvers (euler rk4 ab3 ab3am2)

def V0 : Float := 12.0     -- Initial voltage (12V)
def R : Float := 12000.0   -- Resistance (12 kOhms)
def C : Float := 0.0001    -- Capacitance (100 microFarads)
def RC : Float := R * C    -- Time constant (to avoid recomputation)

def f (t : Float) (V : Float) : Float := -V / RC

def exactSolution (t : Float) : Float := V0 * exp (-t / RC)


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
  let eulerRow  := "euler,"  ++ String.intercalate "," (eulerDiffs.map toString)
  let rk4Row    := "rk4,"    ++ String.intercalate "," (rk4Diffs.map toString)
  let ab3Row    := "ab3,"    ++ String.intercalate "," (ab3Diffs.map toString)
  let ab3am2Row := "ab3am2," ++ String.intercalate "," (ab3am2Diffs.map toString)

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
  -- runSimulations t_start t_end step_size
  runSimulation 0.0 10.0 0.1

end Project1
