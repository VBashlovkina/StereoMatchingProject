%% Making a test image
w = 20;
h = 20;
linGrad = meshgrid(1:w, 1:h); % linear gradient
gradient1 = imnoise(linGrad/(size(linGrad,2)),'gaussian'); % add noise
% make up ground truth disparity 
dispBox = 3*ones(h, w); % most things displaced by 3
dispBox(round(h/4):h-round(h/4),round(w/4):w-round(w/4)) = 8; % central piece is displaced by 8

% from http://stackoverflow.com/questions/7132863/non-uniform-shifting-of-pixels
%# create coordinate grid for image gradient1
[xx,yy] = ndgrid(1:h,1:w);
%# linearize the arrays, and add the offsets
xx = xx(:);
yy = yy(:);
linDispBox = dispBox(:);
B(:,2) = linDispBox; 
B(:,1) = 0; 
xxShifted = xx + B(:,1);
yyShifted = yy + B(:,2);
%# preassign gradient2 to the right size and interpolate
gradient2  = gradient1;
gradient2(:) = griddata(xx,yy,gradient1(:),xxShifted,yyShifted);

% initialize new stereo image set based in gradients
testStImg = StereoImage(gradient1,gradient2);
% cheat: get the actual dispairty ground truth with some noise
testStImg.DisparityMap = dispBox + round(rand(h,w));

oldDisp = testStImg.DisparityMap;

figure, imshow(oldDisp), title('old disp');
width = size(gradient1,2);
height = size(gradient1,1);

for x = 2:width - 1
    for y = 2:height - 1
        fprintf('pixel %d %d\n', x,y);
        if (x == 7 && y ==2)
           fprintf('wow\n');
        end
        newD = Inf;
        while abs(newD - testStImg.DisparityMap(y,x)) > 1 % until disparity estimate converges
            
            % start with normalized window of size 3x3
            window = NewWindow(x,y);
            % compute uncertainty
            [curUncert, window] = uncertainty(testStImg, window);
            % initialize boolean flags for (im)possible expansion
            flags = [1 1 1 1];
            winSize = (window.edges(3) +1 - window.edges(1)) ...
                *(window.edges(2) - window.edges(4)+1);
            while winSize < 27 % until window reaches max size
                gotBetter = 0; % assume certainty did not get better
                counter = 1;
                for k = 1:length(flags)
                    %fprintf('pixel %d %d, direction %d\n', x,y,k);
                    if flags(k)
                        newWindow = NewWindow.expand(window, k);
                        [newUncert, win] = uncertainty(testStImg, newWindow);
                        if newUncert < curUncert
                            wins(counter) = win;
                            uncerts(counter) = newUncert;
                            gotBetter = 1;
                            counter = counter + 1;
                        else
                            flags(k) = 0;
                        end % evaluating the new uncertainty value
                    end % if this expansion is allowed
                end % for each expansion
                
                % pick the best direction for window and uncertainty
                if gotBetter
                    m = min(uncerts);
                    bestDir = find(uncerts == m);
                    % if multiple, pick first
                    if length(bestDir > 1)
                        bestDir = bestDir(1);
                    end
                    window = wins(bestDir);
                    curUncert = uncerts(bestDir);
                end
                % compute the disparity increment
                newD = testStImg.DisparityMap(y,x) + incrementDisp(testStImg, window, curUncert);
                testStImg.DisparityMap(y,x) = newD;
                if ~gotBetter
                    break %from current while loop and move on to diff x,y
                end % if the window converged
                
            end % while we can keep expanding the window
         end % while the disparity estimate hasn't converged
    end % for each y
end % for each x

figure, imshow(testStImg.DisparityMap,[]), title('new disp');

