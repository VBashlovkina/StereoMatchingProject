classdef Window
    %WINDOW encapsulates information about convolution windows
    
    properties
        % the window itself
        Matrix
        % center coordinates
        XCenter
        YCenter
        width
        height
    end
    
    methods
        % default constructor - 3X3 window
        function obj = Window
           obj.Matrix = ones(3)/9; 
           obj.XCenter = 2;
           obj.YCenter = 2;
           obj.width = 3;
           obj.height = 3;
        end
        
        function boolean = eq(win1, win2)
           boolean = win1.Matrix == win2.Matrix && ...
               win1.XCenter == win2.XCenter &&  win1.YCenter == win2.YCenter;
        end
    end
    
    methods (Static)
        function newWin = expand(oldWin, direction)
          %EXPANDWINDOW expands rectangular patch by a row of pixels in a given
          % direction. NEWWINDOW is normalized. Coordinates of the center are updated
          % if necessary.
          %   DIRECTION:
          %           1 - add row above
          %           2 - add column on the right
          %           3 - add row below
          %           4 - add column on the left
          
          newWin = Window;
          % update window shape
          if mod(direction,2) == 1
              newWin.Matrix = 1/(oldWin.width*(oldWin.height+1)) * ...
                  ones(oldWin.height+1, oldWin.width);
              newWin.height = oldWin.height+1;
              newWin.width = oldWin.width;
          else
              newWin.Matrix = 1/((oldWin.width+1)*oldWin.height) * ...
                  ones(oldWin.height, oldWin.width+1);
              newWin.width = oldWin.width + 1;
              newWin.height = oldWin.height;
          end

          % update window center
          if direction == 1
              newWin.YCenter = oldWin.YCenter + 1;
              newWin.XCenter = oldWin.XCenter;
          elseif direction == 4
              newWin.YCenter = oldWin.YCenter;
              newWin.XCenter = oldWin.XCenter + 1;
          else
              newWin.YCenter = oldWin.YCenter;
              newWin.XCenter = oldWin.XCenter;
          end
        end % function expand
        
        
    end
    
end

