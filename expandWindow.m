function [ newWindow ] = expandWindow( window, direction )
%EXPANDWINDOW expands rectangular patch by a row of pixels in a given
% direction. NEWWINDOW is normalized.
%   DIRECTION:
%           1 - add row above
%           2 - add column on the right
%           3 - add row below
%           4 - add column on the left

width = size(window,1);
heigth = size(window,2);

if direction == 1 || direction == 3
    newWindow = 1/(width*(height+1)) * ones(width, heigth+1);
else
    newWindow = 1/((width+1)*height) *ones(width+1, height);
end

