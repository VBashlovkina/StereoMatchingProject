function [ uncert, window ] = uncertainty( stereoImg, window)
%UNCERTAINTY estimates the uncertainty of the disparity estimate for the
% pair of images within STEREOIMAGE over a WINDOW. STEREOIMG is a member
% of our StereoImage class and window is a member of NewWindow class.
% WINDOW is updated with a normalizer map used for caching.
%
% This function estimates the uncertainity of the disparity over the window
% based on Kanade and Okutomi's statistical model for stereo matching. This
% model relates the uncertainty of the disparity to the intensity and 
% disparity variations within a window

% Authors:
% Renn Jervis 
% Vasilisa Bashlovkina
%
% CSC 262 Final Project

% get dimensions of window
top = window.edges(1);
right = window.edges(2);
bottom = window.edges(3);
left = window.edges(4);

% if window is out of bounds, stop
if top < 1 || left < 1 || bottom > size(stereoImg.View1,1) || ...
        right > size(stereoImg.View1,2)
    uncert = Inf;
    return
end

width = right - left + 1;
height = bottom - top + 1;

N = width * height; % number of elements, for future normalization

% initialize both diparity and intensity fluctuations
dispFluct = 0;
intensFluct = 0;

x = window.x;
y = window.y;
% compute disparity and intensity fluctuations over pixels in window
for i = left:right
    for j = top:bottom

        % estimate for corresponding x in second view
	% x' = x - disparity
        shiftedX = i - round(stereoImg.DisparityMap(y,x)); % note y is row
        
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
intensFluct = intensFluct/N; % right!

% What is noise power?
noiseSigma = .0001;

uncert = 0;
% padding for flat disparity
p = .0001;
p=0;


window.normalizerMap = ones(height,width);

% computing uncertainty; for each pixel in window...
for i = left:right
    for j = top:bottom

	% get x coord in second image estimated by current disparity
        shiftedX = i - round(stereoImg.DisparityMap(y,x));
        
        if (shiftedX >= 1) % if a valid index
            % window coordinates
            xi = i - x;
            eta = j - y;
            % computing numerator and denominator of phi2:
	        % intensity derivs of view 2 / normalizer
            numSq = (stereoImg.DerivView2(j, shiftedX))^2;
            denomSq = noiseSigma + (p+dispFluct)*(p+intensFluct)*sqrt(xi^2 + eta^2);
	        %denom = sqrt(noiseSigma + (p+dispFluct)*(p+intensFluct)*sqrt(xi^2 + eta^2));
            %uncert = uncert + num/denom; % create sum of phi2 over window
            % cache normalizer
            window.normalizerMap(j - top +1, i - left + 1) = numSq/denomSq;
	        uncert = uncert + window.normalizerMap(j - top + 1, i - left + 1);
        end
    end
end


% find inverse (eqn 21)
uncert = 1/uncert;
return
end

