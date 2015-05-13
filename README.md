# StereoMatchingProject
A Matlab project implementing Kanade's stereo matching algorithm with 
adaptive window shape.

Index of files:

benchmark1.m - initial work on varying over 9 window shapes, and
		the best size for these windows.  
		
benchmark3.m - primary implementation of our algorithm. This uses functions:
	uncertainty.m
	incrementDisp.m
	initialDisparity - a refactoring of benchmark 1's results
				into a function


To Run:

