README for week 2
=================

Task 1
------


Task 2
------

The main file of task 2 is task2.m and is directly executable.

Settings (function.param):
    * task2.data
        'highway', 'fall' or 'traffic'; sets the dataset over which we want to perform the algorithms.
    * task2.exhaustive_search
        * true; will run an exhaustive serahc over alpha and rho parameters, to look for the best ocmbination, and will plot the results in a 3D mesh;
        * false; will run the adaotive model with the previously found best alpha and rho parameters, and will print the value of alpha and rho and the mean values of precision, recall and F1.
    * adaptive_model.create_animated_gif
        * true; creates and shows an animated gif showing the ground truth and the foreground/background detection with the adaptive model.


Task 3
------

    * task3.m
        Computes the detection with Stauffer and Grimson for the specified parameters and video seuqence.

    * task3_tune.m
        Adjust the parameters for Stauffer and Grimson, for a given number of gaussians, doing a search over a grid.

    * task3_tune2.m
        Adjust the parameters for Stauffer and Grimson, for a given number of gaussians, with gradient ascent.


Task 4
------

Task4 has 2 main files: 
	* task4_adaptative.m for color adapted bg detection adaptative 
	* task4_non_adaptative.m for color adapted bg detection non_adaptative
	
* train_background_color: for training mu_matrix and sigma_matrix for each channel
* alpha_sweep_color: for finding the best alpha for color bg detection non_adaptative
