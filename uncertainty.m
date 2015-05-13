function [ uncert ] = uncertainty( stereoImg, x, y, window)
%UNCERTAINTY estimates the uncertainty of the disparity estimate for the
% pair of images within STEREOIMAGE over a WINDOW centered at the X, Y.  

% get dimensions of window
width = window.width;
height = window.height;
N = width * height; % number of elements, for future normalization

% initialize both diparity and intensity fluctuations
dispFluct = 0;
intensFluct = 0;

% compute disparity and intensity fluctuations over pixels in window
for i = x-window.XCenter + 1:x+window.XCenter -1
    for j = y-window.YCenter + 1:y+window.YCenter -1

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
dispFluct = dispFluct/N
intensFluct = intensFluct/N

% What is noise power?
noiseSigma = .5;

uncert = 0;
% padding for flat disparity
p = .0001;
p=0;
% computing uncertainty; for each pixel in window...
for i = x-window.XCenter + 1:x+window.XCenter -1
    for j = y-window.YCenter + 1:y+window.YCenter -1

	% get x coord in second image estimated by current disparity
        shiftedX = i - stereoImg.DisparityMap(y,x);
        
        if (shiftedX > 1) % if a valid index
            % window coordinates
            xi = i - x;
            eta = j - y;
            % computing numerator and denominator of phi2:
	    % intensity derivs of view 2 / normalizer
            num = stereoImg.DerivView2(j, i - stereoImg.DisparityMap(y,x));
            %denom = noiseSignma + (p+dispFluct)*(p+intensFluct)*sqrt(xi^2 + eta^2);
	    denom = sqrt(noiseSigma + (p+dispFluct)*(p+intensFluct)*sqrt(xi^2 + eta^2));
            uncert = uncert + num/denom; % create sum of phi2 over window
	    %uncert = uncert + denom/num^2;
        end
    end
end


% square our sum and find inverse (eqn 21)
uncert = 1/(uncert^2);
return
end

