%% Testing the uncertainty function on a synthesized stereo pair.
% We replicate the pair of test images described by Kanade and Okutomi to
% test how our uncertainty function changes with disparity variation under
% the window.

%% Making a test image
w = 70;
h = 50;
linGrad = meshgrid(1:w, 1:h); % linear gradient
gradient1 = imnoise(linGrad/(size(linGrad,2)),'gaussian'); % add noise
% make up ground truth disparity 
dispBox = 3*ones(h, w); % most things displaced by 3
dispBox(15:h-15,20:w-20) = 8; % central piece is displaced by 8

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

figure;
subplot(1,3,1),imshow(gradient1), title('synthetic view 1');
subplot(1,3,2),imshow(testStImg.DisparityMap,[]), title('synthetic disp map');
subplot(1,3,3),imshow(gradient2), title('synthetic view 2');

%% Estimating uncertainty on the edges of the central square
% We pick pixels where the initial 3X3 window covers a relatively even
% disparity distribution, but a window expanded in one of the directions
% captures a big disparity variation and thus should have bigger
% uncertainty. In particular, the pixel just above the central rectangle of
% the disparity map is unlikely to expand downward, a pixel just to the
% left of the central rectangle shouldn't expand to the right, and so on.
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
    [smallWinUncerts(k), win] = uncertainty(testStImg, window);
    fprintf('%s, 3X3 uncert = %f\n',edgeNames{k}, smallWinUncerts(k));
    for i = 1:4
        bigWinUncerts(k,i) = uncertainty(testStImg, NewWindow.expand(window,i));
        fprintf('\t %s expansion uncert = %f\n', edgeNames{i}, bigWinUncerts(k,i));
    end
end

%% Estimating uncertainty in the corners of the central square
% Similarly, we look at uncertainty's behavior inside the corners of the
% central rectangle. Here, the expansion is unlikely in two directions.
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