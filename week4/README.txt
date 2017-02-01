README for week 4
=================

Task 1.1
--------
Function grid_search (TO BE LAUNCHED INSTEAD OF task1_1):

This function develops a grid search through block size and search area 
parameters to obtain the best optical flow calculation performance with 
this naive approach of block matching. This functions calls the block 
matching ones from within so it's the only function to be manually 
launched.
Inside, a forward calculated block matching is performed in order to 
obtain the optical flow of the sequence selected, returning performance 
measures such as mean square error in non-occluded areas (MSEN), and 
also the percentage of erroneous pixels in such areas (PEPN). The Grid 
search plots results and points out the best in terms of minimal PEPN.

Input parameters are:
   'seq_id'  =   the sequence which will be tested, between KITTI's
                 dataset sequences 45 and 157.
   
   'iter_bs' =   amount of block sizes to test.
   'iter_sa' =   amount of search area sizes to test.
   NOTE: block sizes are tested starting from 20 pixels and jumping by 10,
   in the case of search area, it starts at 2, and doubles each iteration.
   It's needed to update the desired block sizes in the 'legend' item from
   the graph in order to keep consistency with the desired output.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Task 1.2
--------



Task 1.3
--------



Task 2.1
--------



Task 2.2: Block matching stabilization vs Other techniques
----------------------------------------------------------

Implementation 1:   Video Stabilization Using Point Feature Matching
Source:             http://es.mathworks.com/help/vision/examples/video-stabilization-using-point-feature-matching.html
Code:               week4 > task_2_2 > VSBlockBasedParametricMotionModel
Dataset:            put your images in week4 > task_2_2 > VSBlockBasedParametricMotionModel > traffic
Execution:          directly execute main.m
Observations:       at some point the program is not able to find matching points and it fails with an error.


Implementation 2:   Block-Based Parametric Motion Model
Source:             http://twiki.cis.rit.edu/twiki/pub/Main/HongqinZhang/chen_report.pdf
Code:               week4 > task_2_2 > VSPointFeatureMatching
Dataset:            put your images in week4 > task_2_2 > VSPointFeatureMatching > traffic
Execution:          directly execute main.m
Observations:       


Implementation 3:   Target Tracking Video Stabilization
Source:             https://es.mathworks.com/help/vision/examples/video-stabilization.html
Code:               week4 > task_2_2 > VSTargetTracking
Dataset:            put your images in week4 > task_2_2 > VSTargetTracking > traffic.avi
Execution:          execute videoStabilization.m
Observations:       reads the video and generates two image sequences: the stabilized input and the stabilized ground truth.


Video Stabilization pipeline
----------------------------
Allows to execute the foreground substraction using an adaptive model on any video sequence, computing all metrics and plotting all graphs and results if indicated by parameters plot_detection and plot_graphs.

Code: week4 > videoStabilizationPipeline.m
Execution: execute function alpha_sweep to plot precission recall curves sweeping over alpha values; execute alpha_rho_sweep to compute best alpha and rho (see main funciton of file).

