#include <math.h>
#include "mex.h"

/* function y = fastIIR01(b,a,x);
* Fast IIR (or FIR, if a==1) filter solver, using direct form II transposed:
* a(0)*y(n) = Sum_{i=0}^{Nb-1} b(i)*x(n-i) - Sum_{j=1}^{Na-1} a(j)*y(n-j)
* Inputs:
* b - vector of filter numerator, length Nb, COLUMN or ROW
* a - vector of filter denominator, length Na, COLUMN or ROW
* x - vector of data, length N, COLUMN or ROW
* Outputs:
* y - COLUMN vector of filtered data, length N

* Mark Skowronski, December 11, 2007
*/
void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
double *y;
int i, j, n;

/* Init */
int Nb = (mxGetN(prhs[0])>=mxGetM(prhs[0])) ? mxGetN(prhs[0]) : mxGetM(prhs[0]);
int Na = (mxGetN(prhs[1])>=mxGetM(prhs[1])) ? mxGetN(prhs[1]) : mxGetM(prhs[1]);
int N = (mxGetN(prhs[2])>=mxGetM(prhs[2])) ? mxGetN(prhs[2]) : mxGetM(prhs[2]);
double *b = mxGetPr(prhs[0]);
double *a = mxGetPr(prhs[1]);
double *x = mxGetPr(prhs[2]);

plhs[0] = mxCreateDoubleMatrix(N,1,0);
y = mxGetPr(plhs[0]);

if (Na>Nb){
   for (n = 0; n < Nb; n++) {
      for (i = 0; i <= n; i++) {
         y[n] += b[i]*x[n-i];
      }
   }
   for (n = Nb; n < Na; n++) {
      for (i = 0; i < Nb; i++) {
         y[n] += b[i]*x[n-i];
      }
   }
   for (n = 0; n < Na; n++) {
      for (j = 1; j <= n; j++) {
         y[n] -= a[j]*y[n-j];
      }
   }
   for (n = Na; n < N; n++) {
      for (i = 0; i < Nb; i++) {
         y[n] += b[i]*x[n-i];
      }
      for (j = 1; j < Na; j++) {
         y[n] -= a[j]*y[n-j];
      }
   }
}
else {
   for (n = 0; n < Nb; n++) {
      for (i = 0; i <= n; i++) {
         y[n] += b[i]*x[n-i];
      }
   }
   for (n = 0; n < Na; n++) {
      for (j = 1; j <= n; j++) {
         y[n] -= a[j]*y[n-j];
      }
   }
   for (n = Na; n < Nb; n++) {
      for (j = 1; j < Na; j++) {
         y[n] -= a[j]*y[n-j];
      }
   }
   for (n = Nb; n < N; n++) {
      for (i = 0; i < Nb; i++) {
         y[n] += b[i]*x[n-i];
      }
      for (j = 1; j < Na; j++) {
         y[n] -= a[j]*y[n-j];
      }
   }
}


}

/* Bye! */