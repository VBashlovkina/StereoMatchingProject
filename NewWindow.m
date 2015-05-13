classdef NewWindow
    % WINDOW encapsulates information about convolution windows
    
    properties
        x
        y
        edges % array of edge coordinates
               % edges(1) = y coordinate of the top row
               % edges(2) = x coordinate of the right column
               % edges(3) = y coordinate of the bottom row
               % edges(4) = x coordiante of the left column
       normalizerMap % noiseSigma + intensFluct*dispFluct*distance)
       phi2sum % phi2 over the window 
    end
    
    methods
       % default constructor - 3X3 window
        function obj = NewWindow(x,y) 
            obj.x = x;
            obj.y = y;
            obj.edges = [y-1 x+1 y+1 x-1];
        end
        
    end
    methods (Static)
        function newWin = expand(win, direction)
          %EXPAND expands rectangular patch by a row of pixels in a given
          % direction. WIN is modified.
          %   DIRECTION:
          %           1 - add row above
          %           2 - add column on the right
          %           3 - add row below
          %           4 - add column on the left
          
          if direction == 2 || direction == 3 %incrementing directions
              win.edges(direction) = win.edges(direction) + 1;
          else %decrementing directions
              win.edges(direction) = win.edges(direction) - 1;
          end
          newWin = win;
        end
    end
    
end

