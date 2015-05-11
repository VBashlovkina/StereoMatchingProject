%% Questions
% as of mon 1 pm

% Window.m:
 % why 
 %      obj.XCenter = 2;
 %      obj.YCenter = 2;
 % Do we want to construct windows given specific x and y
        % coordinates?
        % I was under the impression we want 3x3 centered at starting pixel
        % also do we need to handle windows that extend outside
 % what is the mod function?
 % Also i am unsure we want to update the window center, we instead
 % keep considering the same pixel at the center and expand around it
 % (unsure)
        
% Related notes on Uncertainty.m
% We want this to calculate uncertainty over entire window, yes?
% So can we include the specific pixel coordinates when we create a 
% window and simplify the loops here? (See comment in function)
% 
% Why do we only calculate disparity fluctuation if we are passing through
% the center.
%
% What is padding for flat disparity?
%

% Banchmark3.m
% I think that we dont want to expand our window until we have verified
% that the direction is not only not flagged but also the best possible
% direction. See notes.

% Refactoring into InitialDisparity function looks good, 
% I cleaned up bechmark1 a bit.