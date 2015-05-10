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

originalDisparity = stereoImg.DisparityMap;

% We don't have to vary over all disparities -- we already have estimates!
% Instead, we vary over each pixel
for x = 1:width
    for y = 1:height
        newD = Inf;
        while newD ~= d(y,x) % until disparity estimate converges
            
            % start with normalized window of size 3x3
            window = Window;
            % compute uncertainty
            %STUB:curUncert = uncertainty(view1, view2, d, x, y, window);
            curUncert = 0;
            % initialize boolean flags for (im)possible expansion
            flags = [1 1 1 1];
            while length(window.Matrix(:)) < 257 % until window reaches max size
                gotBetter = 0; % assume certainty did not get better
                for k = 1:length(flags)
                    %fprintf('pixel %d %d, direction %d\n', x,y,k);
                    if flags(k)
                        newWindow = Window.expandWindow(window, k);
                     
			% I think that we want to check all directions, 
			% and choose min uncertainty of these
			% possible code:
			%
			% newUncert=uncertainty(stereoImg, x, y, newWindow);
			%
			%
			% if newUncert < curUncert
                        %    uncerts(k) = newUncert
			% else
			% 	flags(k) = 0; //prohibit direction
			% % stop looping through each direction, choose best
			% direction = find(max(uncerts));
			% set new window
			% window = Window.expandWindow(window, direction);
			% currentUncert = uncerts(k)
			% gotBetter = 1
			
			newUncert = uncertainty(stereoImg, x, y, newWindow);
                        if newUncert < curUncert
                            window = newWindow;
                            curUncert = newUncert;
                            gotBetter = 1;
                        else
                            flags(k) = 0;
                        end % evaluating the new uncertainty value
                    end % if this expansion is allowed
                end % for each expansion
                
                % compute the disparity increment
                newD = d(y,x) + incrementDisp(stereoImag, x, y, window);

                if ~gotBetter
                    break %from current while loop and move on to diff x,y
                end % if the window converged
                
            end % while we can keep expanding the window
         end % while the disparity estimate hasn't converged
    end % for each y
end % for each x

str = 'good';
if originalDisparity == d
    str
else
    size(d);
end
