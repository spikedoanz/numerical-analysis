import csv

def get_small_system():
    """
        Returns the coefficient matrix A and vector b for solving the linear system Ax = b.

        The solution x to this system should be [8, 6, 7, 5, 3]
    """
    A = [
        [10, 2, 2, 2, 1],
        [1, 11, 2, 1, 1],
        [1, 1, 12, 1, 1],
        [2, 1, 2, 13, 2],
        [2, 2, 2, 2, 14]
    ]

    b = [119, 96, 106, 107,  94]

    return A, b

def get_large_system(A_csv_path, b_csv_path, x_csv_path):
    """
        Returns the coefficient matrix A and vector b for solving the linear system Ax = b.
    """

    A = read_matrix_csv(A_csv_path)
    b = read_vector_csv(b_csv_path)
    x = read_vector_csv(x_csv_path)

    if len(A) != len(b):
        raise ValueError(f"A has {len(A)} rows, but b has {len(b)} elements. The linear system is not correctly defined.")
    
    return A, b, x

def vector_infinity_norm(vector):
    """
        Returns the infinity norm of a vector represented by a list.
    """
    return max(vector)

def matrix_infinity_norm(matrix):
    """
        Returns the infinity norm of a matrix represented by a list of lists.
    """
    max_row_sum = float("-inf")
    for i in range(len(matrix)):
        row_sum = 0
        for j in range(len(matrix[i])):
            row_sum += abs(matrix[i][j])
        if row_sum > max_row_sum:
            max_row_sum = row_sum

    return max_row_sum


def read_matrix_csv(matrix_csv_path):
    """
    Read a coefficient matrix from a CSV file into a list of lists
    
    Args:
        matrix_csv_path (str): Path to the CSV file containing the coefficient matrix.
    
    Returns:
        A (list of lists): coefficient matrix for linear system
    
    Raises:
        ValueError: If the CSV file is empty, or contains non-numeric data
    """
    #Read the CSV file and dump it into a list of lists
    A = []
    try:
        with open(matrix_csv_path, newline='') as csvfile:
            reader = csv.reader(csvfile)
            
            for row in reader:
                if not row:
                    continue
            
                try:
                    A.append([float(x) for x in row])
            
                except ValueError:
                    raise ValueError("Matrix CSV contains non-numeric data.")
        
        #Check the list is non-empty
        if len(A) == 0:
            raise ValueError("Matrix CSV is empty.")
        
        #Check if the matrix is square.
        number_of_rows = len(A)
        number_of_columns = len(A[0]) if A else 0
        
        if any(len(row) != number_of_columns for row in A):
            raise ValueError("Matrix is not rectangular (rows have inconsistent lengths).")
        
        if number_of_rows != number_of_columns:
            raise ValueError(f"Matrix is not square (has {number_of_rows} rows and {number_of_columns} columns).")
        
        return A
    
    except FileNotFoundError:
        raise FileNotFoundError(f"Matrix CSV file not found: {matrix_csv_path}")

def read_vector_csv(vector_csv_path):
    """
    Read a vector from a CSV file into a list
    
    Args:
        vector_csv_path (str): Path to the CSV file containing the vector.
    
    Returns:
        vector (list): vector in CSV file
    
    Raises:
        ValueError: If the CSV file is empty, or contains non-numeric data
    """
    #Read the CSV file and dump it into a list
    b = []
    try:
        with open(vector_csv_path, newline='') as csvfile:
            reader = csv.reader(csvfile)
            
            for row in reader:
                if not row:
                    continue
                
                if len(row) != 1:
                    raise ValueError("Vector CSV should have exactly one column.")
                
                try:
                    b.append(float(row[0]))
                
                except ValueError:
                    raise ValueError("Vector CSV contains non-numeric data.")
        
        if len(b) == 0:
            raise ValueError("Vector CSV is empty.")
    
        return b
    
    except FileNotFoundError:
        raise FileNotFoundError(f"Vector CSV file not found: {vector_csv_path}")
