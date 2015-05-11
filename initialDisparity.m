function [ dispIndices ] = initialDisparity( view1, view2 )
% INITIALDISPARITY compute initial estimates for disparity between two 
%   stereo images.
%   This function solves the correspondence problem and computes the
%   disparity for each pixel in an image by varying over possible disparities
%   and 9 window shapes and choosing the combination that minimizes SSD.

% to generalize, extract the max disparity from the ground truth data?
maxDisparity = 75;
% pad images with max disparity
padView1 = padarray(view1, [0 maxDisparity], 'post');
padView2 = padarray(view2, [0 maxDisparity], 'post');

height = size(padView1,1);
width = size(padView1,2);

N=16;
mid = floor(N/2);

% initialize 9 different shapes
shapes = zeros( N, N, 9);
shapes(:, :, 1) = 1/(N^2);
% 4 vertically and horozontally divided kernels, normalized
% left and right kernels
shapes( :, 1:mid, 3) = ones(N, mid) / (N*mid); % magic kernel
shapes( :, mid+1:end, 2) = ones( N, mid)/ (N*(mid));
% top and bottom kernels
shapes(1:mid, :, 4) = ones(mid, N)/ (N*mid);
shapes(mid+1:end, :, 5) = ones(mid, N)/ (N*(mid));
% diagonal kernels
one = ones(N);
shapes(:, :, 6) = triu(one) /  numel(find(triu(one))); %magic kernel 2
shapes(:, :, 7) = tril(one) / numel(find(tril(one))) ;
shapes(:, :, 8) = flipdim(triu(one), 3)/numel(find(flipdim(triu(one), 3)));
shapes(:, :, 9) = flipdim(tril(one), 3)/numel(find(flipdim(tril(one), 3)));

% preallocating 4D matrix of SSD results
result = zeros(height, width, maxDisparity, size(shapes, 3)); %% <- HARDCODE

% for each of the 9 shapes
for j = 1:size(shapes, 3)
    
    % check every disparity up to max
    for i=maxDisparity:-1:1
        % create shifted view based on disparity
        shiftedView2 = imtranslate(padView2, 0, -i, 0);
        
        % computing squared differences
        squaredDiffs = (padView1-shiftedView2).^2;
        
        % convolution to get patch SSDs, vary patch shape
        kernel = shapes(:,:,j);
        % place in appropriate 'slice' of result array
        result(:,:,i, j) = conv2(squaredDiffs, kernel, 'same');
    end
end


[minShape, ShapeIndices] = min(result(:, 1:end-maxDisparity, :, :), [], 4);
% which disparities minimized SSD
[minDisp, dispIndices] = min(minShape, [], 3);
% which shapes got used for each pixel
BestShapeIndices = ShapeIndices(dispIndices);

end




