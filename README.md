# StereoMatchingProject
A Matlab project implementing Kanade's stereo matching algorithm with 
adaptive window shape.

Index of files:

+ benchmark1.m - initial work on varying over 9 window shapes, and
		the best size for these windows.  
		
+ benchmark3.m - primary implementation of our algorithm. This uses functions:
	- uncertainty.m function to calculate the uncertainty estimate over 
		the given window.
	- incrementDisp.m: a function to calculates the disparity increment
		after we have expanded a window.
	- initialDisparity - a refactoring of benchmark 1's results
				into a function which produces an initial
				estimate of the disparity map

+ originalLab.m - contains code needed to run algorithm that calculated the
		SSD by simply varying over all disparities. This code also
		produces our RMS vs Window Size graph

+ NewWindow.m - a wrapper class for info about the window over which we are 
		doing our calculations 
+ StereoImage.m - another wrapper class to encompass the aspects of a set o
			of stereo images
 
To Run:
To see the results of our final implementation of Kanade and Okutomi's
algorithm, run benchmark3. The stereo image inputs may be changed to 
any image.
