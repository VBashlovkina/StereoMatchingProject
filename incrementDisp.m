function [ incr ] = incrementDisp( stereoImg, window )
% INCREMENTDISP produces INCR, a value by which the current measure of
% disparity at given pixel (D(Y,X)) should be incremented. STEREOIMAGE is a
% member of our StereoImage class which contains 2 stereo view, a disparity
% map, and the derivative of the intensities of the second image. WINDOW is
% the current window we wish to calculate the increment for.
%
% The equations used in this function are from Kanade and Okutomi's
% model for stereo matching. First we calculate our coefficients, which
% represent the intensity and disparity fluctuations within a window, 
% respectively. We then use these data to calculate phi1 and phi1
% over the window. We then use this to calculate the increment.
%
% Authors:
% Renn Jervis 
% Vasilisa Bashlovkina
%
% CSC 262 Final Project

% we calculate this incremeint with equation 20:
% numerator: sum over window (phi1(x, y) * phi2(x, y))
% denominator: sum over all pixels phi2^2 -> use in uncertainty as well

%width = window.width;
%height = window.height;
width = window.edges(2) - window.edges(4) + 1;
height = window.edges(3) - window.edges(1) + 1;
N = width * height; % number of elements, for future normalization

incr = 0;
% initialize variables

dispFluct = 0;
intensFluct = 0;
phi1 = 0;
phi2 = 0;
genNum = 0;
genDenom = 0;
p=0;
% consider refactoring phi 1 and 2 into functions?
% first calculate disparity and intensity fluctuation

for i = x-window.XCenter + 1:x+window.XCenter -1
    for j = y-window.YCenter + 1:y+window.YCenter -1
        
        shiftedX = i - stereoImg.DisparityMap(y,x); % note y is row
        
        if (shiftedX > 1) % if this point is an index
            % sum over all pixels of intensity derivative of image 2 squared
            intensFluct = intensFluct + ...
                stereoImg.DerivView2(j, shiftedX).^2;
            
            % calculate difference in disparity
            dispDiff = (stereoImg.DisparityMap(j,i) - ...
                stereoImg.DisparityMap(y,x))^2;
            dispDiff = dispDiff.^2;
            
            % if we are not at center pixel, calculate distance
            if ~(i == x && j == y)
                distanceFromCenter = sqrt((i-x)^2 + (j-y)^2);
                dispFluct = dispFluct + dispDiff/distanceFromCenter;
            end
        end
    end
end

% scale for number of elements
dispFluct = dispFluct/N;
intensFluct = intensFluct/N;

% What is noise power?
noiseSigma = .5;

% loop for phi1 and phi2
for i = x-window.XCenter + 1:x+window.XCenter -1
    for j = y-window.YCenter + 1:y+window.YCenter
        
        if (shiftedX > 1) % if a valid index
            % window coordinates
            xi = i - x;
            eta = j - y;
            
            % calculate phi1
            intensityDiff = stereoImg.View1(j, i) - stereoImg.View2(j, i-shiftedX);
            denom = sqrt(noiseSigma + (p+dispFluct)*(p+intensFluct)*sqrt(xi^2 +eta^2));
            phi1 = phi1 + intensityDiff/denom;
            
            % calc phi1  
            dervIntensity = stereoImg.DerivView2(j, i - shiftedX);
            phi2 = phi2 + (dervIntensity/denom)^2;
            
            genNum = genNum+ (phi1 * phi2);
            genDenom = genDenom + phi2;
            
        end
    end
end
    
incr = genNum / genDenom;
return
end
