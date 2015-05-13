% experiments

%import StereoImage;
%import Window;
% load two images
view1 = im2double(imread('/home/weinman/courses/CSC262/images/view1.png')); 
view2 = im2double(imread('/home/weinman/courses/CSC262/images/view5.png'));
% convert to grayscale
view1 = rgb2gray(view1);
view2 = rgb2gray(view2);
height = size(view1,1);
width = size(view1,2);

stereoImg = StereoImage(view1, view2);
% cols of 1,2,3 ...
grid = meshgrid(1:width, 1:height);
% based on curr versions of disparity, has to be updated whenever disp map is
shiftedXIndices = grid - stereoImg.DisparityMap;


%% Making a test image
w = 70;
h = 50;
linGrad = meshgrid(1:w, 1:h); % linear gradient
gradient1 = imnoise(linGrad/(size(linGrad,2)),'gaussian'); % add noise
% make up ground truth disparity 
dispBox = 3*ones(h, w); % most things displaced by 3
dispBox(15:h-15,20:w-20) = 8; % central piece is displaced by 7

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
%# preassign C to the right size and interpolate
gradient2  = gradient1;
%gradient2(:) = interp2(xx,yy,gradient1(:),xxShifted,yy);
gradient2(:) = griddata(xx,yy,gradient1(:),xxShifted,yyShifted);
%gradient2(:) = griddata(xx,yy,gradient1(:),xxShifted,yy);

% initialize new stereo image set based in gradients
testStImg = StereoImage(gradient1,gradient2);
% cheat: get the actual dispairty ground truth with some noise
testStImg.DisparityMap = dispBox + round(rand(h,w));


%% Testing increment
x = 34;
y = 13;
[uncert, win] = uncertainty(testStImg, NewWindow(x,y));
incr = incrementDisp(testStImg, win, uncert);

%% Estimating uncertainty on the edges of the central square
xCoords = [34 52 38 18];
yCoords = [13 19 37 25];
edgeCoords = [xCoords' yCoords'];
edgeNames = {'top edge', 'right edge','bottom edge','left edge'};
smallWinUncerts = ones(1, length(xCoords));
bigWinUncerts = ones(length(xCoords));
for k = 1:length(xCoords)
    x = edgeCoords(k,1);
    y = edgeCoords(k,2);
    window = NewWindow(x,y);
    smallWinUncerts(k) = uncertainty(testStImg, window);
    fprintf('%s, 3X3 uncert = %f\n',edgeNames{k}, smallWinUncerts(k));
    for i = 1:4
        bigWinUncerts(k,i) = uncertainty(testStImg, NewWindow.expand(window,i));
        fprintf('\t %s expansion uncert = %f\n', edgeNames{i}, bigWinUncerts(k,i));
    end
end

%% Estimating uncertainty in the corners of the central square
xCoords = [49 49 21 21];
yCoords = [16 34 16 34];
edgeCoords = [xCoords' yCoords'];
edgeNames = {'top edge', 'right edge','bottom edge','left edge'};
smallWinUncerts = ones(1, length(xCoords));
bigWinUncerts = ones(length(xCoords));
for k = 1:length(xCoords)
    x = edgeCoords(k,1);
    y = edgeCoords(k,2);
    window = NewWindow(x,y);
    smallWinUncerts(k) = uncertainty(testStImg, window);
    fprintf('%s, 3X3 uncert = %f\n',edgeNames{k}, smallWinUncerts(k));
    for i = 1:4
        bigWinUncerts(k,i) = uncertainty(testStImg, NewWindow.expand(window,i));
        fprintf('\t %s expansion uncert = %f\n', edgeNames{i}, bigWinUncerts(k,i));
    end
end