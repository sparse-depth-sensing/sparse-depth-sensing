sparse-depth-sensing
==============

## Introduction
This repository contains MATLAB codes and data for sparse depth sensing, the problem of dense depth image reconstruction from very limited amount of measurements. Please refer to [our paper](http://www.mit.edu/~fcma/publications/Ma.Carlone.IROS16.pdf) for more details.

## Installation
 - The code is self-contained. No installation is required.
 - However, if you are interested in trying out a differnet solver [CVX](http://cvxr.com/cvx/), please download it from this [link](http://cvxr.com/cvx/download/) and follow the installation instructions there. CVX is a Matlab-based modeling system for convex optimization and it has slight higher accuracy than our fast solver NESTA. We recommend obtaining an [academic license](http://cvxr.com/cvx/academic/) for the most optimized performance.

## Usage
 - run `demo_single_frame.m` for a simple demo of the reconstruction algorithm on each single frame of depth images.

## Data
The `data` folder contains two datasets, including
 - ZED: rgb images and depth images collected from the [ZED Stereo Camera](https://www.stereolabs.com/).
 - lids_floor6: rgb and depth images collected from the Kinect sensor, along with odometry information obtained from a odometer.

## Citing Sparse Depth Sensing

If you use our code in your research, please consider citing:

	@inproceedings{ma2016sparse,
	  title={Sparse sensing for resource-constrained depth reconstruction},
	  author={Ma, Fangchang and Carlone, Luca and Ayaz, Ulas and Karaman, Sertac},
	  booktitle={Intelligent Robots and Systems (IROS), 2016 IEEE/RSJ International Conference on},
	  pages={96--103},
	  year={2016},
	  organization={IEEE}
	}

## Contact

Please email Fangchang Ma (fcma@mit.edu) for problems and bugs. Thanks!