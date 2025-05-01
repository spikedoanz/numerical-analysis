from typing import List 
from functools import reduce
from utils import (
  get_small_system,
  get_large_system
)

def augment (a : List[List[float]], b : List[float]) -> List[List[float]]:
  return [_a + [_b] for _a, _b in zip(a, b)]


def gaussian_elimination(A: List[List[float]]) -> List[List[float]]:
    if len(A) == 0: return []
    N, M = len(A), len(A[0])
    row_idx = list(range(N))
    for k in range(N):
        max_row = k
        max_val = abs(A[row_idx[k]][k])
        
        for i in range(k+1, N):
            if abs(A[row_idx[i]][k]) > max_val:
                max_val = abs(A[row_idx[i]][k])
                max_row = i
        
        if max_row != k:
            row_idx[k], row_idx[max_row] = row_idx[max_row], row_idx[k]
        if abs(A[row_idx[k]][k]) < 1e-10: continue
            
        for i in range(k+1, N):
            m = A[row_idx[i]][k] / A[row_idx[k]][k]
            for j in range(k, M):
                A[row_idx[i]][j] = A[row_idx[i]][j] - m * A[row_idx[k]][j]
    result = [A[row_idx[i]][:] for i in range(N)]
    return result

def backsubstitution(A : List[List[float]]) -> List[float]:
  N, M = len(A)-1, len(A[0])-1
  x : List[float]  = [0.0 for _ in range(N+1)]
  x[N] = A[N][M]/A[N][N]
  for i in range(N,-1,-1):
    Σaijxj = sum([ A[i][j] * x[j] for j in range(i+1, N+1)])
    x[i] = (A[i][M] - Σaijxj)/A[i][i]
  return x

a, b, x = get_large_system("A.csv", "b.csv", "x.csv")

ge_x = backsubstitution(
  gaussian_elimination(
    augment(a,b)
  )
)

l1 = lambda x, x_hat : sum([abs(_x - _x_hat) for _x, _x_hat in zip(x, x_hat)])
l2 = lambda x, x_hat : sum([(_x - _ge_x)**2 for _x, _ge_x in zip(ge_x, x)]) ** (0.5)
l∞ = lambda x, x_hat : max([abs(_x - _x_hat) for _x, _x_hat in zip(x, x_hat)])

print(l1(x, ge_x))
print(l2(x, ge_x))
print(l∞(x, ge_x))
