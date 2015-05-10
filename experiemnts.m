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
    uncerts(i) = uncertainty(stereoImg, x, y, wins(i));
end
uncerts