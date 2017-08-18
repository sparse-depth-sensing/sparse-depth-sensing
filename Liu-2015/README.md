This folder contains a lean version of the code for "Depth reconstruction from sparse samples: Representation, algorithm, and sampling". I made simple modifications (including change of file paths and additional timing commands) without touching the main code.

The original version of the code can be downloaded from [this link](http://videoprocessing.ucsd.edu/~leekang/SoftwareData/Liu_Chan_Nguyen_TIP2015_Matlab_Code/2015TIP_MATLAB_ToolBox_v1.zip). Please consider citing their paper if you use their code in your work.

See below for their original README.
___

# Reproducible Package 
for "Depth Reconstruction from Sparse Samples: Representation, Algorithm, and Sampling"
submitted to Trans. Image Process.

This MATLAB package includes functions that are used in the above titled 
journal submission.

Lee-Kang Liu and Stanley Chan

This is experimental software. It is provided for non-commercial research purposes only. 
No warranty is implied by this distribution. 

Copyright © 2014 by University of California




## Part 1: Reproducible Routines
We provide scripts that reproduce results presented in the paper. 
For example, "Figure2.m" is the script for reproducing Figure 2 shown in 
our journal paper. The list of MATLAB codes include:

"Figure1.m", "Figure2.m", "Figure3.m", "Figure4.m", "Figure6.m", 
"Figure7.m", "Figure8.m", "Figure9.m", "Figure10.m", "Figure11.m",and 
"Figure12.m"


## Part 2: Demo Files
We provide self-supported demo files for users who like to use the proposed
algorithm. 

Example: Try "Demo_ADMM_WT.m" to test the proposed ADMM algorithm 
with a single wavelet dictionary.

Brief describtions for each Demonstration code are as follows:
 1. "Demo_ADMM_WT.m" : example code for running ADMM algorithm with single wavelet dictionary.
 2. "Demo_ADMM_WT_CT": example code for running ADMM algorithm with combined wavelet and contourlet dictionary.
 3. "Demo_Multiscale_ADMM_WT_CT.m": example code for running Multiscale ADMM algorithm with combined wavelet and Contourlet dictionary.
 4. "Demo_Hawe_WT_Subgradient.m": MATLAB script for running subgradient algorithm with single wavelet dictionary.
For detailed information, please refer to the paper [1].
 5. "Demo_WT_CT_Subgradient.m" : example code for running subgradient algorithm with combined wavelet and contourlet dictionary. This is the modified version of our preliminary work in ICASSP [2].

## References:
 1. S. Hawe, M. Kleinsteuber, and K. Diepold, "Dense disparity maps from sparse disparity measurements," in Proc. IEEE Int. Conf. 
   Computer Vision (ICCV'11), Nov. 2011, p.p. 2126-2133.
 2.  Lee-Kang Liu and Truong Nguyen, "Sparse Reconstruction For Disparity Maps using Combined Wavelet and Contourlet Transforms,"
   in Proc. of the 39th IEEE International Conference on Acoustics, Speech, and Signal Processing (ICASSP'14), May 2014.

