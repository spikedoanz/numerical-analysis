def a : Array (Array Float) := 
  #[
    #[3, 2, -1],
    #[1, -1, 2],
    #[2, 4, -3]
  ]

def b : Array Float :=
  #[7, 3, 4]

#eval a[0]

def identity (a: Array (Array Float))
  : Array (Array Float) := a

def getAugmentedMatrix 
  (a: Array (Array Float)) 
  (b: Array Float) :=
    ((List.range a.size).map fun i => a[i]!.push b[i]!).toArray


#eval getAugmentedMatrix a b

def m := 0.5
def E0 := a[0]
def E1 := a[1]

#eval (E0.zip E1).map (λ t => t.1 - t.2)


/-

let ret := #[]
for i in List.range a.size
  -- partial pivot
  for j in List.range i a.size
    let m     := a[j][i] / a[i][i] -- this can be precalculated?
    ret.push (a[j].zip a[i]).map (λ t => t.1 - m * t.2)
-/


