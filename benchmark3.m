%% Benchmark 3
% This script began as a shell for implementing the mechanics of our
% algorithm. Now the (previously) stubbed functions are functional
% Authors:
% Renn Jervis 
% Vasilisa Bashlovkina
%
% CSC 262 Final Project

% import some classes
import StereoImage;
import Window;
% load two images
view1 = im2double(imread('/home/weinman/courses/CSC262/images/view1.png')); 
view2 = im2double(imread('/home/weinman/courses/CSC262/images/view5.png'));
% convert to grayscale
view1 = rgb2gray(view1);
view2 = rgb2gray(view2);
height = size(view1,1);
width = size(view1,2);

stereoImg = StereoImage(view1, view2);
% load disparity data
groundTruth = imread('/home/weinman/courses/CSC262/images/truedisp.png');

% scale ground truth (after casting to double to eliminate chance of zero
% distance) to match scaled images.
groundTruth = double(groundTruth)/3;

% get the initial disparity map via class and functional form of benchmark
% 1 (ie vary over all disparities and 9 window shapes)
originalDisparity = stereoImg.DisparityMap;

% We don't have to vary over all disparities -- we already have estimates!
% Instead, we vary over each pixel
for x = 2:width-1
    for y = 2:height-1
        newD = 0;
        oldD = 1;
        while newD ~= oldD % until disparity estimate converges
            oldD = 0;
            % start with normalized window of size 3x3 centered at x, y
            window = NewWindow(x, y);
            % compute uncertainty
            curUncert = uncertainty(stereoImg, window);
            
            % initialize boolean flags for possible expansion
            flags = [1 1 1 1];
            winSize = (window.edges(3) - window.edges(1)) ...
                *(window.edges(4) - window.edges(2)); 
            while  winSize < 257 % until window reaches max size
                gotBetter = 0; % assume uncertainty did not get better
                for k = 1:length(flags)
                    
                    if flags(k)
                        newWindow = NewWindow.expand(window, k);
                     
                         newUncert=uncertainty(stereoImg, newWindow);
			
                     if newUncert < curUncert
                           uncerts(k) = newUncert
                     else
                    	flags(k) = 0; % prohibit direction
                     end
                    end % if direction not prohibited
                end % check all directions
                
                % stop looping through each direction, choose best
                 direction = find(min(uncerts));
                % set new window
                 window = NewWindow.expand(window, direction);
                 currentUncert = uncerts(direction);
                 
                
                % compute the disparity increment
                oldD = newD;
                newD = stereoImg.DisparityMap(y,x) + incrementDisp(stereoImag, window);
                stereoImg.DisparityMap(y,x) = newD;
                
                winSize = (window.edges(3) - window.edges(1)) ...
                *(window.edges(4) - window.edges(2)); 
                
            end % until window reaches max size 
            
         end % while the disparity estimate hasn't converged
     
    end % for each y
end % for each x



