from utils import *

#Load the small system
A, b = get_small_system()

#Load the large system from the respective files and its solution x.
A, b, x = get_large_system("A.csv", "b.csv", "x.csv")

#Print the infinity norm of the matrix A for the large system.
print(matrix_infinity_norm(A))