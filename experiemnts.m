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
% based on curr versions of disparity, has to be updatet whenever disp are
shiftedXIndices = grid - stereoImg.DisparityMap;


window = Window;
oldWin = window;
x = 392;
y = 202;
uncert = uncertainty(stereoImg, x, y, window);

colRigth = Window.expand(window, 2);
window = Window;
rowAbove = Window.expand(window, 1);
window = Window;
rowBelow = Window.expand(window, 3);
window = Window;
colLeft = Window.expand(window, 4);

wins = [colRigth, rowBelow, rowAbove, colRigth];
for i = 1:4
    %uncerts(i) = uncertainty(stereoImg, x, y, wins(i));
    uncerts(i) = uncertainty(stereoImg, x, y, Window.expand(window,i));
end
uncerts


%% Making a test image
w = 70;
h = 50;
linGrad = meshgrid(1:w, 1:h); % linear gradient
gradient1 = imnoise(linGrad/(size(linGrad,2)),'gaussian'); % add noise
% make up ground truth disparity
dispBox = 3*ones(h, w); % most things displaced by 3
dispBox(15:h-15,20:w-20) = 7; % central piece is displaced by 7



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

% initialize new stereo image set based in gradients
testStImg = StereoImage(gradient1,gradient2);
% cheat: get the actual dispairty ground truth with some noise
testStImg.DisparityMap = dispBox + round(rand(h,w));

x = 52; y = 20; % on the right edge of the center rectangle
% estimate its uncert
window = Window;
uncert = uncertainty(testStImg, x, y, window);
uncertLeft = uncertainty(testStImg, x, y, Window.expand(window, 4)); % big
uncertRight = uncertainty(testStImg, x, y, Window.expand(window, 2)); % same
%% conclusion: it kinda works!