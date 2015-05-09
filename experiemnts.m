% experiments

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


window = Window;
oldWin = window;
x = 238;
y = 193;
uncert = uncertainty(stereoImg, x, y, window);
rowAbove = Window.expand(window, 1);

colRigth = Window.expand(window, 2);
rowBelow = Window.expand(window, 3);
colLeft = Window.expand(window, 4);
wins = [colRigth, rowBelow, colRigth, rowAbove];
for i = 1:4
    uncerts(i) = uncertainty(stereoImg, x, y, wins(i));
end
uncerts