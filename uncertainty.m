function [ uncert ] = uncertainty( stereoImg, x, y, window)
%UNCERTAINTY estimates the uncertainty of the disparity estimate for a
% given pixel  

width = window.width;
height = window.height;
N = width * height;
% compute disparity and intensity fluctuations

dispFluct = 0;
intensFluct = 0;

%cache shifted!
for i = x-window.XCenter + 1:x+window.XCenter -1
    for j = y-window.YCenter + 1:y+window.YCenter -1
        
        shiftedX = i - stereoImg.DisparityMap(y,x);
        
        if (shiftedX > 1)
            
            %intensity
            intensFluct = intensFluct + ...
                stereoImg.DerivView2(j, shiftedX);
            
            %disparity
            dispDiff = (stereoImg.DisparityMap(j,i) - ...
                stereoImg.DisparityMap(y,x))^2;
            % if passing through the center
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
% computing uncertainty
for i = x-window.XCenter + 1:x+window.XCenter -1
    for j = y-window.YCenter + 1:y+window.YCenter -1
        shiftedX = i - stereoImg.DisparityMap(y,x);
        
        if (shiftedX > 1)
            % window coordinates
            xi = i - x;
            eta = j - y;
            % computing numerator and denominator of phi2
            num = stereoImg.DerivView2(j, i - stereoImg.DisparityMap(y,x));
            denom = noiseSigma + (p+dispFluct)*(p+intensFluct)*sqrt(xi^2 + eta^2);
            uncert = uncert + denom/num^2;
        end
    end
end

% for stubbing
%uncert = Inf;

end

