from typing import List, Any 
from time import time
from functools import reduce
from utils import (
  get_small_system,
  get_large_system
)

l1   = lambda x, x_hat : sum([abs(_x - _x_hat) for _x, _x_hat in zip(x, x_hat)])
l2   = lambda x, x_hat : sum([(_x - _x_hat)**2 for _x, _x_hat in zip(x, x_hat)]) ** (0.5)
linf = lambda x, x_hat : max([abs(_x - _x_hat) for _x, _x_hat in zip(x, x_hat)])

def augment (a : List[List[float]], b : List[float]) -> List[List[float]]:
  return [_a + [_b] for _a, _b in zip(a, b)]

def gaussian_elimination(a: List[List[float]], b : List[float]) -> List[List[float]]:
  A = augment(a,b) 
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

def residual(a : List[List[float]], b : List[float], x : List[float]) -> List[float]:
  N = len(a)-1
  y = [sum([a[i][j] * x[j] for j in range(N)]) for i in range(N)]
  return [_y - _b for _y, _b in zip(y,b)]

def gauss_seidel(a: List[List[float]], b : List[float], 
                 max_iter = 10000, ε = 1e-10) -> List[float]:
  A = augment(a,b)
  N, M = len(A)-1, len(A[0])-1
  x : List[float]  = [0.0 for _ in range(N+1)]
  for k in range(max_iter):
    x_last = [_x for _x in x] # just in case reference semantics fail me
    for i in range(N):
      Σ1 = sum(A[i][j] * x[j] for j in range(i))
      Σ2 = sum(A[i][j] * x_last[j] for j in range(i+1, N))
      x[i] = (A[i][M] - Σ1 - Σ2) / A[i][i]
    if linf(x, x_last) < ε: break
    if linf(x, residual(a,b,x)) < ε: break
  return x


if __name__ == "__main__":
  print("  == SMALL SYSTEM ==")
  a, b = get_small_system()
  x = [8, 6, 7, 5, 3]

  ge_start = time()
  ge_x = backsubstitution(gaussian_elimination(a,b))
  ge_time = time() - ge_start

  print("== Gaussian elimination with partial pivoting ==")
  print("L1 : " + str(l1(x, ge_x)))
  print("L2 : " + str(l2(x, ge_x)))
  print("L∞ : " + str(linf(x, ge_x)))
  print("Solve time : " + str(ge_time))

  gs_start = time()
  gs_x = gauss_seidel(a,b)
  gs_time = time() - gs_start
  print("== Gauss Seidel ================================")
  print("L1 : " + str(l1(x, gs_x)))
  print("L2 : " + str(l2(x, gs_x)))
  print("L∞ : " + str(linf(x, gs_x)))
  print("Solve time : " + str(gs_time))

  print("\n\n  == BIG SYSTEM ==")
  a, b, x = get_large_system("A.csv", "b.csv", "x.csv")

  ge_start = time()
  ge_x = backsubstitution(gaussian_elimination(a,b))
  ge_time = time() - ge_start
  print("== Gaussian elimination with partial pivoting ==")
  print("L1 : " + str(l1(x, ge_x)))
  print("L2 : " + str(l2(x, ge_x)))
  print("L∞ : " + str(linf(x, ge_x)))
  print("Solve time : " + str(ge_time))

  gs_start = time()
  gs_x = gauss_seidel(a,b)
  gs_time = time() - gs_start
  print("== Gauss Seidel ================================")
  print("L1 : " + str(l1(x, gs_x)))
  print("L2 : " + str(l2(x, gs_x)))
  print("L∞ : " + str(linf(x, gs_x)))
  print("Solve time : " + str(gs_time))
