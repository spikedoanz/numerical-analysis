/-
chapter 6: direct methods for solving linear equations
------------------------------------------------------

aij, bj are constants and we want to find x[1..n] that satisfy the equations.

the methods being direct means that we use methods that theoretically give
exact solutions.


section 6.1 : linear systems of equations
-----------------------------------------

### valid operations for linear systems: (elementary row operations)

a) scalar multiplication for non-zero λ. Ei : λEi -> Ei

b) adding a multiple of another equation. Ei : (Ei + λEj) -> Ei

c) transposition: exchange equations in any order. Ei <-> Ej

Ex: 

E1 := x1 + x2 + 3x3  = 4
E2 := 2x1 + x2 - x3   = 1
E3 := -x1 + 2x2 - x3 = 4

apply E2 := E2 - 2E1 = 2x1 - 2x1 + x2 - x2 - x3 - 6x3 + 1 - 8 = -x2 - 7x3 - 7
      E3 := E3 + E1  = -x1 + x1 +2x2 + x2 - x3 + 3x3 + 4 + 4  = 3x2 + 2x3 + 8

apply E3 := E3 + 3E2 = 3x2 - 3x2 +2x3 - 21x3 + 8 - 21 = -19x3 - 13

This is called backward substitution:
  => x3 = 13/19
  => x2 = 7 - 7x3
  => x1 = 4 - x2 - 3x3

### Matrices and vectors:


The process of obtaining row echelon form is called gaussian eliminiation.


General methodology for doing gaussian eliminiation
1. Convert the system into an augmented matrix
2. If a11 != 0 perform the following:
  Ej - (aj1 / a11) E1 -> Ej 
  j ∈ [2..n]
  => this eliminates x1 entries in each row
3. for all columns i := i in [1..n]
    for all columns j := j in [i+1 .. n]
      Ej - (aji / aii) Ei -> Ej
  assuming each aii != 0, this yields a row echelon form matrix.
4. backsubstitution: each xi can be found using bs
xn    = an,n+1 / ann
xn-1  =  a{n-1, n+1}  - a{n-1,n} xn / a{n-1, n-1}

xi  = a{i,n+1} - a{i,i+1} x{i+1} - ... a{in}xn
      ----------------------------------------
        aii
    = a{i,n+1} - ∑ⁿⱼaijxj j ∈ [i+1]
      -----------------------------
        aii
These ai,j are from the final augmented matrix

Ex: Express the following system using an augmented matrix
    and apply gaussian elimination to it to solve.

  1   -1    2   -1    -8
  2   -2    3   -3    -20
  1   1     1         -2
  1   -1    4   -3    4


  1   -1    2   -1    -8
  0   -3    -1  -1    -4
  0   2     -1  1     6     +2/3 [0  -3  -1  -1 -4] = + [0 -2 -2/3 -2/3 -8/3] = 0 0 -5/3  1/3  10/3
  0   0     2   -2    12    + 0 


  1   -1    2     -1    -8
  0   -3    -1    -1    -4
  0   0     -5/3  1/3   10/3
  0   0     2     -2    12     + 6/5 [0 0 -5/3 1/3 10/3] = [0 0 -2 2/5 4]


  1   -1    2     -1    -8
  0   -3    -1    -1    -4
  0   0     -5/3  1/3   10/3
  0   0     0     -12/5 16






Σ{i:=1..m} i = m

Σ{i:=1..m} i = (m)(m+1)/2

Σ{i:=1..m} i²= (m)(m+1)(2m+1)/6

for i:= 1..n-1:
  for j:= i+1..n:
    Ej := Ej - mji*Ei

mji         has (n-i) divisions
mji*Ei      has (n-i+2) multiplications
  this is done n-i times
Ej - mji*Ei has (n-i+1) subtractions (pivot is zero)
  this is done n-i times

inner loop: total muls/divs = (n-i) + (n-i)(n-i+2) = n^2 - 2ni + i^2 + 2n -2i
inner loop: total adds/subs = (n-i)(n-i+1) = n^2 + n - 2ni + i^2 -i

outer loop: Σ{i:=1..n-1} n^2 - 2ni + i^2 + 2n -2i


-/
