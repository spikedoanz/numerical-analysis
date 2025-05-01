from typing import List 

a : List[List[float]] = [
    [1,2,3],
    [4,5,6],
    [7,8,10],
]
b : List[float] = [0,0,0]

def augment (a : List[List[float]], b : List[float]) -> List[List[float]]:
  return [_a + [_b] for _a, _b in zip(a, b)]

def gaussian_elimination(A : List[List[float]]) -> List[List[float]]:
  if len(A) == 0: return []
  N, M = len(A), len(A[0])
  for k in range(N):
    for i in range(k+1, N):
      if A[k][k] == 0: continue
      m = A[i][k]/A[k][k]
      for j in range(k, M):
        A[i][j] = A[i][j] - m * A[k][j]
  return A


print(gaussian_elimination(augment(a,b)))
