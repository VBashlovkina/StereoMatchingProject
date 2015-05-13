function [ uncert ] = uncertainty( stereoImg, window)
%UNCERTAINTY estimates the uncertainty of the disparity estimate for the
% pair of images within STEREOIMAGE over a WINDOW centered at the X, Y.  
% Authors:
% Renn Jervis 
% Vasilisa Bashlovkina
%
% CSC 262 Final Project
% get dimensions of window

width = window.edges(2) - window.edges(4) + 1;
height = window.edges(3) - window.edges(1) + 1;
N = width * height; % number of elements, for future normalization

% initialize both diparity and intensity fluctuations
dispFluct = 0;
intensFluct = 0;

x = window.x;
y = window.y;
% compute disparity and intensity fluctuations over pixels in window
for i = window.edges(4):window.edges(2)
    for j = window.edges(1):window.edges(3)

        % estimate for corresponding x in second view
	% x' = x - disparity
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
intensFluct = intensFluct/N; % right!

% What is noise power?
noiseSigma = .0001;

uncert = 0;
% padding for flat disparity
p = .0001;
p=0;
% computing uncertainty; for each pixel in window...
for i = window.edges(4):window.edges(2)
    for j = window.edges(1):window.edges(3)

	% get x coord in second image estimated by current disparity
        shiftedX = i - stereoImg.DisparityMap(y,x);
        
        if (shiftedX >= 1) % if a valid index
            % window coordinates
            xi = i - x;
            eta = j - y;
            % computing numerator and denominator of phi2:
	       % intensity derivs of view 2 / normalizer
            numSq = (stereoImg.DerivView2(j, i - stereoImg.DisparityMap(y,x)))^2;
            denomSq = noiseSigma + (p+dispFluct)*(p+intensFluct)*sqrt(xi^2 + eta^2);
	        %denom = sqrt(noiseSigma + (p+dispFluct)*(p+intensFluct)*sqrt(xi^2 + eta^2));
            %uncert = uncert + num/denom; % create sum of phi2 over window
	        uncert = uncert + numSq/denomSq;
        end
    end
end


% square our sum and find inverse (eqn 21)
uncert = 1/uncert;
return
end

