sparse-depth-sensing
==============

## Introduction
This repository contains MATLAB codes and data for sparse depth sensing, the problem of dense depth image reconstruction from very limited amount of measurements. Please refer to [our paper](http://www.mit.edu/~fcma/publications/Ma.Carlone.IROS16.pdf) for more details.

## Installation
 - Please install [CVX](http://cvxr.com/cvx/) before running our codes. CVX is a Matlab-based modeling system for convex optimization, which is being utilized in our algorithm for solving l1 optimizatiion problems. We highly recommend obtaining an [academic license](http://cvxr.com/cvx/academic/) for the most optimized performance.

## Usage
 - run `example.m` for a simple demo of the reconstruction algorithm.

## Data
The `data/zed` folder contains both rgb images and depth images (scaled to 0-255) collected from the [ZED Stereo Camera](https://www.stereolabs.com/).

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