function [ incr ] = incrementDisp( stereoImg, d, x, y, window )
% INCREMENTDISP produces a value by which the current measure of disparity
% at given pixel (D(Y,X)) should be incremented.r

% we calculate this incremeint with equation 20:
% numerator: sum over window (phi1(x, y) * phi2(x, y))
% denominator: sum over all pixels phi2^2 -> use in uncertainty as well

% ** I am really unsure how many loops we need here, still very much in 
% progress, maybe we should combine with other function so we do not have to 
% re-calculate our coefficients?

width = window.width;
height = window.height;
N = width * height; % number of elements, for future normalization

incr = 0;
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
dispFluct = dispFluct/N
intensFluct = intensFluct/N

% What is noise power?
noiseSigma = .5;	

%demoninator for phi 1 and 2
denom = sqrt(noiseSigma + (p+dispFluct)*(p+intensFluct)*sqrt(xi^2 +eta^2));
	% calc phi 1
		% intensity diff / scary square root
		% numPhi1 = difference in intensities of two images over
			%  window 

	% calc phi2
		% num = derivative intensity function 2
		% denom = scary denom above

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
            num = stereoImg.DerivView2(j, i - shiftedX);
            %denom = noiseSignma + (p+dispFluct)*(p+intensFluct)*sqrt(xi^2 + eta^2))$
            denom = sqrt(noiseSigma + (p+dispFluct)*(p+intensFluct)*sqrt(xi^2 +eta^2);$
end
end

incr = num / denom
return
end
