function [ incr ] = incrementDisp( stereoImg, window , uncert )
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
x = window.x;
y = window.y;

% loop for phi1 and phi2
for i = window.edges(4):window.edges(2)
    for j = window.edges(1):window.edges(3)
        
        shiftedX = i - stereoImg.DisparityMap(y,x);
        if (shiftedX >= 1) % if a valid index
            
            % calculate phi1
            intensityDiff = stereoImg.View1(j, i) - stereoImg.View2(j, shiftedX);
            
            phi1phi2num = intensityDiff*stereoImg.DerivView2(j, shiftedX);
            
            genNum = genNum + phi1phi2num/...
                window.normalizerMap(j - window.edges(1) +1, i - window.edges(4) + 1);
            
            %denom = sqrt(noiseSigma + (p+dispFluct)*(p+intensFluct)*sqrt(xi^2 +eta^2));
            %phi1 = phi1 + intensityDiff/denom;
            
            % calc phi1  
            %dervIntensity = stereoImg.DerivView2(j, shiftedX);
            %phi2 = phi2 + (dervIntensity/denom)^2;
            
            %genNum = genNum+ (phi1 * phi2);
            %genDenom = genDenom + phi2;
            
        end
    end
end
    
incr = genNum * uncert;
return
end
