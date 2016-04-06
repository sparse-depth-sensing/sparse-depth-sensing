sparse-sensing
==============

This repo contains MATLAB codes and data for a simple demo of sparse depth sensing. Please install CVX (http://cvxr.com/cvx/) before running our codes, since CVX is used for solving l1 optimizatiion problems. We highly recommend obtaining an academic license (request one at http://cvxr.com/cvx/academic/) of CVX for the most optimized performance.

There are two examples:

1. example_uniform_sampling.m: example of uniformly random depth samples
2. example_edge_sampling.m: example of depth samples around edges (extracted from RGB images)
