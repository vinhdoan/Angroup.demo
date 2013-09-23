/*************************************************************************
Copyright (c) 1992-2007 The University of Tennessee.  All rights reserved.

Contributors:
    * Sergey Bochkanov (ALGLIB project). Translation from FORTRAN to
      pseudocode.

See subroutines comments for additional copyrights.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

- Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

- Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer listed
  in this license in the documentation and/or other materials
  provided with the distribution.

- Neither the name of the copyright holders nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*************************************************************************/

using System;

class rcond
{
    /*************************************************************************
    Estimate of a matrix condition number (1-norm)

    The algorithm calculates a lower bound of the condition number. In this case,
    the algorithm does not return a lower bound of the condition number, but an
    inverse number (to avoid an overflow in case of a singular matrix).

    Input parameters:
        A   -   matrix. Array whose indexes range within [0..N-1, 0..N-1].
        N   -   size of matrix A.

    Result: 1/LowerBound(cond(A))
    *************************************************************************/
    public static double rmatrixrcond1(ref double[,] a,
        int n)
    {
        double result = 0;
        int i = 0;
        double[,] a1 = new double[0,0];
        int i_ = 0;
        int i1_ = 0;

        System.Diagnostics.Debug.Assert(n>=1, "RMatrixRCond1: N<1!");
        a1 = new double[n+1, n+1];
        for(i=1; i<=n; i++)
        {
            i1_ = (0) - (1);
            for(i_=1; i_<=n;i_++)
            {
                a1[i,i_] = a[i-1,i_+i1_];
            }
        }
        result = rcond1(a1, n);
        return result;
    }


    /*************************************************************************
    Estimate of the condition number of a matrix given by its LU decomposition (1-norm)

    The algorithm calculates a lower bound of the condition number. In this case,
    the algorithm does not return a lower bound of the condition number, but an
    inverse number (to avoid an overflow in case of a singular matrix).

    Input parameters:
        LUDcmp      -   LU decomposition of a matrix in compact form. Output of
                        the RMatrixLU subroutine.
        N           -   size of matrix A.

    Result: 1/LowerBound(cond(A))
    *************************************************************************/
    public static double rmatrixlurcond1(ref double[,] ludcmp,
        int n)
    {
        double result = 0;
        int i = 0;
        double[,] a1 = new double[0,0];
        int i_ = 0;
        int i1_ = 0;

        System.Diagnostics.Debug.Assert(n>=1, "RMatrixLURCond1: N<1!");
        a1 = new double[n+1, n+1];
        for(i=1; i<=n; i++)
        {
            i1_ = (0) - (1);
            for(i_=1; i_<=n;i_++)
            {
                a1[i,i_] = ludcmp[i-1,i_+i1_];
            }
        }
        result = rcond1lu(ref a1, n);
        return result;
    }


    /*************************************************************************
    Estimate of a matrix condition number (infinity-norm).

    The algorithm calculates a lower bound of the condition number. In this case,
    the algorithm does not return a lower bound of the condition number, but an
    inverse number (to avoid an overflow in case of a singular matrix).

    Input parameters:
        A   -   matrix. Array whose indexes range within [0..N-1, 0..N-1].
        N   -   size of matrix A.

    Result: 1/LowerBound(cond(A))
    *************************************************************************/
    public static double rmatrixrcondinf(ref double[,] a,
        int n)
    {
        double result = 0;
        int i = 0;
        double[,] a1 = new double[0,0];
        int i_ = 0;
        int i1_ = 0;

        System.Diagnostics.Debug.Assert(n>=1, "RMatrixRCondInf: N<1!");
        a1 = new double[n+1, n+1];
        for(i=1; i<=n; i++)
        {
            i1_ = (0) - (1);
            for(i_=1; i_<=n;i_++)
            {
                a1[i,i_] = a[i-1,i_+i1_];
            }
        }
        result = rcondinf(a1, n);
        return result;
    }


    /*************************************************************************
    Estimate of the condition number of a matrix given by its LU decomposition
    (infinity norm).

    The algorithm calculates a lower bound of the condition number. In this case,
    the algorithm does not return a lower bound of the condition number, but an
    inverse number (to avoid an overflow in case of a singular matrix).

    Input parameters:
        LUDcmp  -   LU decomposition of a matrix in compact form. Output of
                    the RMatrixLU subroutine.
        N       -   size of matrix A.

    Result: 1/LowerBound(cond(A))
    *************************************************************************/
    public static double rmatrixlurcondinf(ref double[,] ludcmp,
        int n)
    {
        double result = 0;
        int i = 0;
        double[,] a1 = new double[0,0];
        int i_ = 0;
        int i1_ = 0;

        System.Diagnostics.Debug.Assert(n>=1, "RMatrixLURCondInf: N<1!");
        a1 = new double[n+1, n+1];
        for(i=1; i<=n; i++)
        {
            i1_ = (0) - (1);
            for(i_=1; i_<=n;i_++)
            {
                a1[i,i_] = ludcmp[i-1,i_+i1_];
            }
        }
        result = rcondinflu(ref a1, n);
        return result;
    }


    /*************************************************************************
    Obsolete 1-based version, see RMatrixRCond1 for 0-bases replacement
    *************************************************************************/
    public static double rcond1(double[,] a,
        int n)
    {
        double result = 0;
        int i = 0;
        int j = 0;
        double v = 0;
        double nrm = 0;
        int[] pivots = new int[0];

        a = (double[,])a.Clone();

        nrm = 0;
        for(j=1; j<=n; j++)
        {
            v = 0;
            for(i=1; i<=n; i++)
            {
                v = v+Math.Abs(a[i,j]);
            }
            nrm = Math.Max(nrm, v);
        }
        lu.ludecomposition(ref a, n, n, ref pivots);
        internalestimatercondlu(ref a, n, true, true, nrm, ref v);
        result = v;
        return result;
    }


    /*************************************************************************
    Obsolete 1-based subroutine, see RMatrixLURCond1 for 0-based replacement.
    *************************************************************************/
    public static double rcond1lu(ref double[,] ludcmp,
        int n)
    {
        double result = 0;
        double v = 0;

        internalestimatercondlu(ref ludcmp, n, true, false, 0, ref v);
        result = v;
        return result;
    }


    /*************************************************************************
    Obsolete 1-based subroutine, see RMatrixRCondInf for 0-based replacement.
    *************************************************************************/
    public static double rcondinf(double[,] a,
        int n)
    {
        double result = 0;
        int i = 0;
        int j = 0;
        double v = 0;
        double nrm = 0;
        int[] pivots = new int[0];

        a = (double[,])a.Clone();

        nrm = 0;
        for(i=1; i<=n; i++)
        {
            v = 0;
            for(j=1; j<=n; j++)
            {
                v = v+Math.Abs(a[i,j]);
            }
            nrm = Math.Max(nrm, v);
        }
        lu.ludecomposition(ref a, n, n, ref pivots);
        internalestimatercondlu(ref a, n, false, true, nrm, ref v);
        result = v;
        return result;
    }


    /*************************************************************************
    Obsolete 1-based subroutine, see RMatrixLURCondInf for 0-based replacement
    *************************************************************************/
    public static double rcondinflu(ref double[,] ludcmp,
        int n)
    {
        double result = 0;
        double v = 0;

        internalestimatercondlu(ref ludcmp, n, false, false, 0, ref v);
        result = v;
        return result;
    }


    private static void internalestimatercondlu(ref double[,] ludcmp,
        int n,
        bool onenorm,
        bool isanormprovided,
        double anorm,
        ref double rc)
    {
        double[] work0 = new double[0];
        double[] work1 = new double[0];
        double[] work2 = new double[0];
        double[] work3 = new double[0];
        int[] iwork = new int[0];
        double v = 0;
        bool normin = new bool();
        int i = 0;
        int im1 = 0;
        int ip1 = 0;
        int ix = 0;
        int kase = 0;
        int kase1 = 0;
        double ainvnm = 0;
        double ascale = 0;
        double sl = 0;
        double smlnum = 0;
        double su = 0;
        bool mupper = new bool();
        bool mtrans = new bool();
        bool munit = new bool();
        int i_ = 0;

        
        //
        // Quick return if possible
        //
        if( n==0 )
        {
            rc = 1;
            return;
        }
        
        //
        // init
        //
        if( onenorm )
        {
            kase1 = 1;
        }
        else
        {
            kase1 = 2;
        }
        mupper = true;
        mtrans = true;
        munit = true;
        work0 = new double[n+1];
        work1 = new double[n+1];
        work2 = new double[n+1];
        work3 = new double[n+1];
        iwork = new int[n+1];
        
        //
        // Estimate the norm of A.
        //
        if( !isanormprovided )
        {
            kase = 0;
            anorm = 0;
            while( true )
            {
                internalestimatenorm(n, ref work1, ref work0, ref iwork, ref anorm, ref kase);
                if( kase==0 )
                {
                    break;
                }
                if( kase==kase1 )
                {
                    
                    //
                    // Multiply by U
                    //
                    for(i=1; i<=n; i++)
                    {
                        v = 0.0;
                        for(i_=i; i_<=n;i_++)
                        {
                            v += ludcmp[i,i_]*work0[i_];
                        }
                        work0[i] = v;
                    }
                    
                    //
                    // Multiply by L
                    //
                    for(i=n; i>=1; i--)
                    {
                        im1 = i-1;
                        if( i>1 )
                        {
                            v = 0.0;
                            for(i_=1; i_<=im1;i_++)
                            {
                                v += ludcmp[i,i_]*work0[i_];
                            }
                        }
                        else
                        {
                            v = 0;
                        }
                        work0[i] = work0[i]+v;
                    }
                }
                else
                {
                    
                    //
                    // Multiply by L'
                    //
                    for(i=1; i<=n; i++)
                    {
                        ip1 = i+1;
                        v = 0.0;
                        for(i_=ip1; i_<=n;i_++)
                        {
                            v += ludcmp[i_,i]*work0[i_];
                        }
                        work0[i] = work0[i]+v;
                    }
                    
                    //
                    // Multiply by U'
                    //
                    for(i=n; i>=1; i--)
                    {
                        v = 0.0;
                        for(i_=1; i_<=i;i_++)
                        {
                            v += ludcmp[i_,i]*work0[i_];
                        }
                        work0[i] = v;
                    }
                }
            }
        }
        
        //
        // Quick return if possible
        //
        rc = 0;
        if( anorm==0 )
        {
            return;
        }
        
        //
        // Estimate the norm of inv(A).
        //
        smlnum = AP.Math.MinRealNumber;
        ainvnm = 0;
        normin = false;
        kase = 0;
        while( true )
        {
            internalestimatenorm(n, ref work1, ref work0, ref iwork, ref ainvnm, ref kase);
            if( kase==0 )
            {
                break;
            }
            if( kase==kase1 )
            {
                
                //
                // Multiply by inv(L).
                //
                trlinsolve.safesolvetriangular(ref ludcmp, n, ref work0, ref sl, !mupper, !mtrans, munit, normin, ref work2);
                
                //
                // Multiply by inv(U).
                //
                trlinsolve.safesolvetriangular(ref ludcmp, n, ref work0, ref su, mupper, !mtrans, !munit, normin, ref work3);
            }
            else
            {
                
                //
                // Multiply by inv(U').
                //
                trlinsolve.safesolvetriangular(ref ludcmp, n, ref work0, ref su, mupper, mtrans, !munit, normin, ref work3);
                
                //
                // Multiply by inv(L').
                //
                trlinsolve.safesolvetriangular(ref ludcmp, n, ref work0, ref sl, !mupper, mtrans, munit, normin, ref work2);
            }
            
            //
            // Divide X by 1/(SL*SU) if doing so will not cause overflow.
            //
            ascale = sl*su;
            normin = true;
            if( ascale!=1 )
            {
                ix = 1;
                for(i=2; i<=n; i++)
                {
                    if( Math.Abs(work0[i])>Math.Abs(work0[ix]) )
                    {
                        ix = i;
                    }
                }
                if( ascale<Math.Abs(work0[ix])*smlnum | ascale==0 )
                {
                    return;
                }
                for(i=1; i<=n; i++)
                {
                    work0[i] = work0[i]/ascale;
                }
            }
        }
        
        //
        // Compute the estimate of the reciprocal condition number.
        //
        if( ainvnm!=0 )
        {
            rc = 1/ainvnm;
            rc = rc/anorm;
        }
    }


    private static void internalestimatenorm(int n,
        ref double[] v,
        ref double[] x,
        ref int[] isgn,
        ref double est,
        ref int kase)
    {
        int itmax = 0;
        int i = 0;
        double t = 0;
        bool flg = new bool();
        int positer = 0;
        int posj = 0;
        int posjlast = 0;
        int posjump = 0;
        int posaltsgn = 0;
        int posestold = 0;
        int postemp = 0;
        int i_ = 0;

        itmax = 5;
        posaltsgn = n+1;
        posestold = n+2;
        postemp = n+3;
        positer = n+1;
        posj = n+2;
        posjlast = n+3;
        posjump = n+4;
        if( kase==0 )
        {
            v = new double[n+3+1];
            x = new double[n+1];
            isgn = new int[n+4+1];
            t = (double)(1)/(double)(n);
            for(i=1; i<=n; i++)
            {
                x[i] = t;
            }
            kase = 1;
            isgn[posjump] = 1;
            return;
        }
        
        //
        //     ................ ENTRY   (JUMP = 1)
        //     FIRST ITERATION.  X HAS BEEN OVERWRITTEN BY A*X.
        //
        if( isgn[posjump]==1 )
        {
            if( n==1 )
            {
                v[1] = x[1];
                est = Math.Abs(v[1]);
                kase = 0;
                return;
            }
            est = 0;
            for(i=1; i<=n; i++)
            {
                est = est+Math.Abs(x[i]);
            }
            for(i=1; i<=n; i++)
            {
                if( x[i]>=0 )
                {
                    x[i] = 1;
                }
                else
                {
                    x[i] = -1;
                }
                isgn[i] = Math.Sign(x[i]);
            }
            kase = 2;
            isgn[posjump] = 2;
            return;
        }
        
        //
        //     ................ ENTRY   (JUMP = 2)
        //     FIRST ITERATION.  X HAS BEEN OVERWRITTEN BY TRANDPOSE(A)*X.
        //
        if( isgn[posjump]==2 )
        {
            isgn[posj] = 1;
            for(i=2; i<=n; i++)
            {
                if( Math.Abs(x[i])>Math.Abs(x[isgn[posj]]) )
                {
                    isgn[posj] = i;
                }
            }
            isgn[positer] = 2;
            
            //
            // MAIN LOOP - ITERATIONS 2,3,...,ITMAX.
            //
            for(i=1; i<=n; i++)
            {
                x[i] = 0;
            }
            x[isgn[posj]] = 1;
            kase = 1;
            isgn[posjump] = 3;
            return;
        }
        
        //
        //     ................ ENTRY   (JUMP = 3)
        //     X HAS BEEN OVERWRITTEN BY A*X.
        //
        if( isgn[posjump]==3 )
        {
            for(i_=1; i_<=n;i_++)
            {
                v[i_] = x[i_];
            }
            v[posestold] = est;
            est = 0;
            for(i=1; i<=n; i++)
            {
                est = est+Math.Abs(v[i]);
            }
            flg = false;
            for(i=1; i<=n; i++)
            {
                if( x[i]>=0 & isgn[i]<0 | x[i]<0 & isgn[i]>=0 )
                {
                    flg = true;
                }
            }
            
            //
            // REPEATED SIGN VECTOR DETECTED, HENCE ALGORITHM HAS CONVERGED.
            // OR MAY BE CYCLING.
            //
            if( !flg | est<=v[posestold] )
            {
                v[posaltsgn] = 1;
                for(i=1; i<=n; i++)
                {
                    x[i] = v[posaltsgn]*(1+((double)(i-1))/((double)(n-1)));
                    v[posaltsgn] = -v[posaltsgn];
                }
                kase = 1;
                isgn[posjump] = 5;
                return;
            }
            for(i=1; i<=n; i++)
            {
                if( x[i]>=0 )
                {
                    x[i] = 1;
                    isgn[i] = 1;
                }
                else
                {
                    x[i] = -1;
                    isgn[i] = -1;
                }
            }
            kase = 2;
            isgn[posjump] = 4;
            return;
        }
        
        //
        //     ................ ENTRY   (JUMP = 4)
        //     X HAS BEEN OVERWRITTEN BY TRANDPOSE(A)*X.
        //
        if( isgn[posjump]==4 )
        {
            isgn[posjlast] = isgn[posj];
            isgn[posj] = 1;
            for(i=2; i<=n; i++)
            {
                if( Math.Abs(x[i])>Math.Abs(x[isgn[posj]]) )
                {
                    isgn[posj] = i;
                }
            }
            if( x[isgn[posjlast]]!=Math.Abs(x[isgn[posj]]) & isgn[positer]<itmax )
            {
                isgn[positer] = isgn[positer]+1;
                for(i=1; i<=n; i++)
                {
                    x[i] = 0;
                }
                x[isgn[posj]] = 1;
                kase = 1;
                isgn[posjump] = 3;
                return;
            }
            
            //
            // ITERATION COMPLETE.  FINAL STAGE.
            //
            v[posaltsgn] = 1;
            for(i=1; i<=n; i++)
            {
                x[i] = v[posaltsgn]*(1+((double)(i-1))/((double)(n-1)));
                v[posaltsgn] = -v[posaltsgn];
            }
            kase = 1;
            isgn[posjump] = 5;
            return;
        }
        
        //
        //     ................ ENTRY   (JUMP = 5)
        //     X HAS BEEN OVERWRITTEN BY A*X.
        //
        if( isgn[posjump]==5 )
        {
            v[postemp] = 0;
            for(i=1; i<=n; i++)
            {
                v[postemp] = v[postemp]+Math.Abs(x[i]);
            }
            v[postemp] = 2*v[postemp]/(3*n);
            if( v[postemp]>est )
            {
                for(i_=1; i_<=n;i_++)
                {
                    v[i_] = x[i_];
                }
                est = v[postemp];
            }
            kase = 0;
            return;
        }
    }
}
