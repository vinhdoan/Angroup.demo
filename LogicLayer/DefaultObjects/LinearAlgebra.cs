using System;
using System.Collections.Generic;
using System.Text;

namespace LogicLayer.Statistics
{
    class LinearAlgebra
    {
        //boundary condition number inverse value
        const double conditionBoundary = 1E-20;

        //Solves a square upper triangular matrix by backward substitution. 
        public static double[] SolveByBackwardSubstitution(ref double[,] X, ref double[] y)
        {
            if (X.GetLength(0) != X.GetLength(1))
                throw new ArgumentException("The matrix is not square. ");

            int order = X.GetLength(0);
            double[] result = new double[order];

            for (int i = order - 1; i >= 0; --i)
            {
                result[i] = y[i];
                for (int j = i + 1; j < order; ++j)
                    result[i] -= X[i, j] * result[j];
                result[i] /= X[i, i];
            }
            return result;
        }

        //Solves a square lower triangular matrix by forward substitution. 
        public static double[] SolveByForwardSubstitution(ref double[,] X, ref double[] y)
        {
            if (X.GetLength(0) != X.GetLength(1))
                throw new ArgumentException("The matrix is not square. ");

            int order = X.GetLength(0);
            double[] result = new double[order];

            for (int i = 0; i < order; ++i)
            {
                result[i] = y[i];
                for (int j = 0; j < i; ++j)
                    result[i] -= X[i, j] * result[j];
                result[i] /= X[i, i];
            }
            return result;
        }

        //Returns b in least squares equation Xb = y. 
        public static double[] SolveLeastSquares(ref double[,] X, ref double[] y)
        {
            double[,] Xt = TransposeMatrix(ref X);
            double[,] XtX = MultiplyMatrix(ref Xt, ref X);
            int order = X.GetLength(1);
            double conditionNumberInverse = rcond.rmatrixrcond1(ref XtX, order); //1-norm condition number

            if (conditionNumberInverse >= conditionBoundary) //rcond is large, cond is small, matrix is well-conditioned.
                return SolveByCholesky(ref X, ref Xt, ref XtX, ref y, order);
            else
                return SolveBySVD(ref X, ref y);
        }

        //solve for b by Cholesky decomposition using Alglib
        static double[] SolveByCholesky(ref double[,] X, 
            ref double[,] Xt, 
            ref double[,] XtX, 
            ref double[] y, 
            int order)
        {
            if (!cholesky.spdmatrixcholesky(ref XtX, order, true))
                return SolveBySVD(ref X, ref y);

            double[,] R = XtX;
            double[,] Rt = TransposeMatrix(ref XtX);
            double[] Xty = MultiplyMatrix(ref Xt, ref y); 
            double[] z = SolveByForwardSubstitution(ref Rt, ref Xty);
            return SolveByBackwardSubstitution(ref R, ref z);
        }

        //solve for b by singular value decomposition using Alglib
        static double[] SolveBySVD(ref double[,] X, ref double[] y)
        {
            int rows = X.GetLength(0);
            int columns = X.GetLength(1);
   
            double[] s = new double[Math.Max(rows, columns)];
            double[,] U = new double[rows, rows];
            double[,] Vt = new double[columns, columns];

            //Parameters: svd.rmatrixsvd(X, m, n, uneeded, vtneeded, memory, w, u, vt)
            if (!svd.rmatrixsvd(X, rows, columns, 2, 2, 2, ref s, ref U, ref Vt))
                throw new ArgumentException("SVD decomposition failure."); 

            double[,] SInverse = new double[columns, rows];
            int order = Math.Min(columns, rows);
            for (int i = 0; i < order; ++i)
            {
                if (s[i] == 0) break;
                SInverse[i, i] = 1 / s[i];
            }
            double[,] Ut = TransposeMatrix(ref U);
            double[,] V = TransposeMatrix(ref Vt);

            double[,] MoorePenrosePseudoinverse = MultiplyMatrix(ref V, ref SInverse);
            MoorePenrosePseudoinverse = MultiplyMatrix(ref MoorePenrosePseudoinverse, ref Ut); 
            return MultiplyMatrix(ref MoorePenrosePseudoinverse, ref y); 
        }

        //Transpose of Matrix[,]
        public static double[,] TransposeMatrix(ref double[,] X)
        {
            int rows = X.GetLength(0); 
            int columns = X.GetLength(1);
            double[,] result = new double[columns, rows];
            for (int i = 0; i < columns; ++i)
            {
                for (int j = 0; j < rows; ++j)
                    result[i, j] = X[j, i]; 
            }
            return result;
        }
        
        //Matrix[,] product AB. 
        public static double[,] MultiplyMatrix(ref double[,] A, ref double[,] B)
        {
            int Arows = A.GetLength(0); 
            int Acolumns = A.GetLength(1); 
            int Brows = B.GetLength(0); 
            int Bcolumns = B.GetLength(1); 

            if (Acolumns != Brows)
                throw new ArgumentException("Matrices have invalid dimensions."); 

            double[,] result = new double[Arows, Bcolumns];

            for (int row = 0; row < Arows; ++row)
            {
                for (int column = 0; column < Bcolumns; ++column)
                {
                    double s = 0;
                    for (int i = 0; i < Acolumns; ++i)
                        s += A[row, i] * B[i, column];
                    result[row, column] = s; 
                }
            }
			return result; 
        }

        //Matrix[,]-vector[] multiplication
        public static double[] MultiplyMatrix(ref double[,] A, ref double[] y)
        {
            int rows = A.GetLength(0);
            int columns = A.GetLength(1); 
            if (y.Length != columns)
                throw new ArgumentException("Matrix and vector dimensions are not valid.");

            double[] result = new double[rows];
            for (int i = 0; i < rows; ++i)
            {
                double s = 0;
                for (int j = 0; j < columns; ++j)
                    s += A[i, j] * y[j];
                result[i] = s; 
            }
            return result;
        }

        //Converts matrix[,] to printable string form
        public static String MatrixToString(ref double[,] X)
        {
            int rows = X.GetLength(0);
            int columns = X.GetLength(1);
            StringBuilder builder = new StringBuilder();
            for (int i = 0; i < rows; ++i)
            {
                for (int j = 0; j < columns; ++j)
                    builder.Append(X[i, j] + " ");
                builder.Append(Environment.NewLine); 
            }
            return builder.ToString(); 
        }

        //Converts vector[] to printable form
        public static String MatrixToString(ref double[] y)
        {
            int rows = y.Length;
            StringBuilder builder = new StringBuilder();
            for (int i = 0; i < rows; ++i)
                builder.Append(y[i] + " "); 
            builder.Append(Environment.NewLine);
            return builder.ToString(); 
        }

        //Returns true if matrix is square
        public static bool IsSquare(ref double[,] X)
        {
            return (X.GetLength(0) == X.GetLength(1)); 
        }

        //Creates a copy of a matrix
        public static double[,] CloneMatrix(ref double[,] X)
        {
            int rows = X.GetLength(0); 
            int columns = X.GetLength(1);
            double[,] result = new double[rows, columns];
            for (int i = 0; i < rows; ++i)
            {
                for (int j = 0; j < columns; ++j)
                    result[i, j] = X[i, j]; 
            }
            return result; 
        }

        //Generates random matrix[,]
        public static double[,] GenerateRandomMatrix(int rows, int columns, int maxValue)
        {
            Random generator = new Random();
            double[,] result = new double[rows, columns];

            for (int i = 0; i < rows; ++i)
            {
                for (int j = 0; j < columns; ++j)
                {
                    double p = generator.NextDouble();
                    if (p >= 0.5)
                    {
                        result[i, j] = p / maxValue;
                    }
                    else
                        result[i, j] = generator.Next(maxValue) + p;
                }
            }
            return result;
        }

        //Generates random vector[]
        public static double[] GenerateRandomVector(int rows, int maxValue)
        {
            Random generator = new Random();
            double[] result = new double[rows];

            for (int i = 0; i < rows; ++i)
            {
                double p = generator.NextDouble();
                if (p >= 0.5)
                {
                    result[i] = p / maxValue;
                }
                else
                    result[i] = generator.Next(maxValue) + p;
            }
            return result;
        }

    }

}