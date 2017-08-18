#include <stdlib.h>
#include "mex.h"
#include <math.h>

void compute_totalvariation(double *input,double *output,unsigned nbrRows,unsigned nbrCols){
    unsigned x = 0, y = 0, crnt2 = nbrRows*nbrCols, crnt1 = 0;
    double div = sqrt(2);
    
    for( x = 0; x < nbrCols; ++x )
    {
        for( y = 0; y < nbrRows; ++y,++crnt1,++crnt2)
        {
            /* Difference in x direction */
            unsigned pos = x*nbrRows+y;
            
            if(x == nbrCols-1)
                output[crnt1]         = -input[pos]/div;
            else
                output[crnt1]         = (input[pos+nbrRows]-input[pos])/div;
            
            /* Difference in y direction */
            if( y == nbrRows-1)
                output[crnt2] = -input[pos]/div;
            else
                output[crnt2] = (input[pos+1]-input[pos])/div;
        }
    }
}
/* Compute the adjoint/Transposed of the totalvariation thing */
void compute_totalvariation_transposed(double *input,double *output,unsigned nbrRows,unsigned nbrCols){
    unsigned x = 0, y = 0, crnt2 = nbrRows*nbrCols, crnt1 = 0;
    double div = sqrt(2);
    
    for( x = 0; x < nbrCols; ++x )
    {
        for( y = 0; y < nbrRows; ++y, ++crnt1, ++crnt2)
        {
            double dx = 0, dy =  0;
            unsigned pos = x*nbrRows+y;
            /* Difference in x direction */
            if(x == 0)
                dx = -input[crnt1];
            else
                dx = input[pos-nbrRows]-input[pos];
            
            /* Difference in y direction */
             if(y == 0)
                 dy = -input[crnt2];
            else
                dy = input[crnt2-1]-input[crnt2];
            
            output[crnt1] = (dx+dy)/div;
        }
    }
}




/* The gateway routine. */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  double *input, *output;
  unsigned nbrRows, nbrCols;
  mwSignedIndex dims[3];  
  mwSize cDim;
  /* Check for the proper number of arguments. */
  if (nrhs != 1) {
    mexErrMsgTxt("One and only one input required.");
  }
  if (nlhs > 1) {
    mexErrMsgTxt("Too many output arguments.");
  }

  /* input size */
  /* m equals the number of rows */
  nbrRows = mxGetM(prhs[0]);
  /* Number of Columns */
  nbrCols = mxGetN(prhs[0]);
  
  
  cDim = mxGetNumberOfDimensions(prhs[0]);
  

  
  
  if(cDim == 2)
    dims[2] = 2;
  else
  {
    dims[2] = 1;
    nbrCols /=2;
  }   
  dims[0] = nbrRows;
  dims[1] = nbrCols;

  plhs[0] = mxCreateNumericArray(3,dims,mxDOUBLE_CLASS,mxREAL);
  
  /* Create matrix for the return argument. */
  
  /* Assign pointers to each input and output. */
  input = mxGetPr(prhs[0]);
  output = mxGetPr(plhs[0]);
  
  /* Call the C subroutine. */
  if(cDim == 2)
    compute_totalvariation(input,output,nbrRows, nbrCols);
  else
    compute_totalvariation_transposed(input,output,nbrRows, nbrCols);
  
  return;
}
