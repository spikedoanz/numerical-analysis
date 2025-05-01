from typing import List 

a : List[List[float]] = [
    [1,2,3],
    [4,5,6],
    [7,8,9],
]
b : List[float] = [0,0,0]

def augment (a : List[List[float]], b : List[float]) -> List[List[float]]:
  return [_a + [_b] for _a, _b in zip(a, b)]

print(augment(a,b))
