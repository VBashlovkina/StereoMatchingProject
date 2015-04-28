% load two images
view1 = im2double(imread('/home/weinman/courses/CSC262/images/view1.png')); 
view2 = im2double(imread('/home/weinman/courses/CSC262/images/view5.png'));
% convert to grayscale
view1 = rgb2gray(view1);
view2 = rgb2gray(view2);
height = size(view1,1);
width = size(view1,2);

% load disparity
groundTruth = imread('/home/weinman/courses/CSC262/images/truedisp.png');

% scale ground truth (after casting to double to eliminate chance of zero
% distance ) to match scaled images.
groundTruth = double(groundTruth)/3;

% compute initial disparity estimates using the algorithm developped in lab
d = initialDisparity(view1, view2);

% We don't have to vary over all disparities -- we already have estimates!
% Instead, we vary over each pixel
for x = 1:width
    for y = 1:height
        while newD ~= d(y,x) % until disparity estimate converges
            
            % start with normalized window of size 3x3
            window = 1/9*ones(3);
            % compute uncertainty
            curUncert = uncertainty(view1, view2, d, x, y, window);
            % initialize boolean flags for (im)possible expansion
            flags = [1 1 1 1];
            while length(window(:)) < 257 % until window reaches max size
                gotBetter = 0;
                for k = 1:length(flags)
                    if flags(k)
                        newWindow = expandWindow(window, k);
                        newUncert = uncertainty(view1, view2, d, x, y, newWindow);
                        if newUncert < curUncert
                            window = newWindow;
                            curUncert = newUncert;
                            gotBetter = 1;
                        else
                            flags(k) = 0;
                        end % evaluating the new uncertainty value
                    end % if this expansion is allowed
                end % for each expansion
                if ~gotBetter
                    break;
                end % if the window converged
                
                % compute the disparity increment
                newD = d(y,x) + incrementDisp(newWindow); % what arguments        
            end % while we can keep expanding the window
         end % while the disparity estimate hasn't converged
    end % for each y
end % for each x
