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



%stereoImg = StereoImage(view1, view2);
stereoImg = testStImg;

height = size(stereoImg.View1,1);
width = size(stereoImg.View1,2);

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
        x
        y
        newD = 0;
        oldD = originalDisparity(y, x);
         % initialize boolean flags for possible expansion
        flags = [1 1 1 1];
        winSize = 1;
        while abs(newD-oldD) > 5 && winSize < 27 % until disparity estimate converges or we reach max size
            %abs(newD-oldD)
            
            % start with normalized window of size 3x3 centered at x, y
            window = NewWindow(x, y);
            % compute uncertainty
            curUncert = uncertainty(stereoImg, window);
     
            
            for k = 1:length(flags)
                
                if flags(k)
                    newWindow = NewWindow.expand(window, k);
                    [newUncert, winReturned] = uncertainty(stereoImg, newWindow);
                    
                    if newUncert < curUncert
                        uncerts(k) = newUncert;
                        win(k) = winReturned;
                    else
                        uncerts(k) = Inf;
                        flags(k) = 0; % prohibit direction
                    end
                end % if direction not prohibited
            end % check all directions
            
            % stop looping through each direction, choose best
            
            m = min(uncerts);
            if m == Inf
                break
            end
            direction = find(uncerts == m);
            if(length(direction) > 1) % if find returns multiple mins
                break
            end
            % set new window
            expandedWindow = win(direction);
            currentUncert = uncerts(direction);
            window = expandedWindow;
            
            % compute the disparity increment
            
            newD = stereoImg.DisparityMap(y,x) + incrementDisp(stereoImg, expandedWindow, currentUncert);
            newD
            stereoImg.DisparityMap(y,x) = round(newD);
            
            winSize = (expandedWindow.edges(3) +1 - expandedWindow.edges(1)) ...
                *(expandedWindow.edges(2) - expandedWindow.edges(4)+1);
          
        end % while the disparity estimate hasn't converged
        
    end % for each y
end % for each x



