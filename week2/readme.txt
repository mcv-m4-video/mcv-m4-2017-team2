README for week 2
=================

Task 1
------
The main file of task 1 is task1.m, the one to be executed.

Settings:

-First select the dataset in wich you desire to work by assigning variable 'data' its name in string format, for example: data = 'highway';

-Grountruth values for background and foreground are assigned in the variables of the same name.

-Then yout may choose to run detection using a particular alpha value, or may sweep through a series of alphas in order to compare results.

For using a single alpha simply give variable 'alpha_vect' a single value, check that 'single_alpha()' function is uncommented and 'alpha_sweep() is commented.


For sweeping, assign 'alpha_vect' a vector containing the values to evaluate, check that function 'alpha_sweep()' is uncommented and 'single_alpha()' is commented.

 



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


Task 4
------

Task4 has 2 main files: 
	* task4_adaptative.m for color adapted bg detection adaptative 
	* task4_non_adaptative.m for color adapted bg detection non_adaptative
	
* train_background_color: for training mu_matrix and sigma_matrix for each channel
* alpha_sweep_color: for finding the best alpha for color bg detection non_adaptative
