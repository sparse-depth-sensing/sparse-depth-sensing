sparse-depth-sensing
==============

## Introduction
This repository contains MATLAB codes and data for sparse depth sensing, the problem of dense depth image reconstruction from very limited amount of measurements. Please refer to our paper [*Sparse Depth Sensing for Resource-Constrained Robots*](https://arxiv.org/abs/1703.01398) and click on the [YouTube video](https://www.youtube.com/watch?v=vE56akCGeJQ) below for more details.
[![Demo CountPages alpha](https://j.gifs.com/k5N49X.gif)](https://www.youtube.com/watch?v=vE56akCGeJQ)

## Installation
 - The code is self-contained. **No installation required**.
 - However, if you are interested in trying out a differnet solver [CVX](http://cvxr.com/cvx/), please download it from this [link](http://cvxr.com/cvx/download/) and follow the installation instructions there. CVX is a Matlab-based modeling system for convex optimization and it has slightly higher accuracy than our fast solver NESTA. We recommend obtaining an [academic license](http://cvxr.com/cvx/academic/) for the most optimized performance.

## Usage
 - run `demo_single_frame.m` for a demo of the reconstruction algorithm on samples from each individual frame of depth images.
 - run `demo_multi_frame.m` for a demo of the reconstruction algorithm on samples collected across multiple frames, given odometry information.

## Code
The code is structured as follows.
 - `lib/algorithm` contains the core code, i.e., the formulation of our optimization problem (in `l1ReconstructionOnImage.m`).
 - `lib/nesta_solver` is the implementation of the NESTA fast solver tailored to our problem.
 - `lib/geometry` handles all geometry related implementations (e.g., rigid body transformation, image projection).
 - `lib/sampling` provides functions for create a small set of measurements from the ground truth depth image.
 - `lib/utility` contains other helper functions.

## Data
The `data` folder contains two datasets, including
 - `ZED`: rgb images and depth images collected from the [ZED Stereo Camera](https://www.stereolabs.com/).
 - `lids_floor6`: rgb and depth images collected from the Kinect sensor, along with odometry information obtained from a odometer.

## Citing Sparse Depth Sensing

If you use our code in your research, please consider citing:

	@article{Ma2017SparseDepthSensing,
	  title={Sparse Depth Sensing for Resource-Constrained Robots},
	  author={Ma, Fangchang and Carlone, Luca and Ayaz, Ulas and Karaman, Sertac},
	  journal={arXiv preprint arXiv:1703.01398},
	  year={2017}
	}

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
