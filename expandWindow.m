function [ newWindow, wCenterX, wCenterY ] = expandWindow( window, direction, wCenterX, wCenterY )
%EXPANDWINDOW expands rectangular patch by a row of pixels in a given
% direction. NEWWINDOW is normalized. Coordinates of the center are updated
% if necessary.
%   DIRECTION:
%           1 - add row above
%           2 - add column on the right
%           3 - add row below
%           4 - add column on the left

width = size(window,2);
height = size(window,1);

% update window shape
if mod(direction,2) == 1
    newWindow = 1/(width*(height+1)) * ones(width, height+1);
else
    newWindow = 1/((width+1)*height) *ones(width+1, height);
end

% update window center, if necessary
if direction == 1
   wCenterY = wCenterY + 1;
elseif direction == 4
    wCenterX = wCenterX + 1;
end

end

