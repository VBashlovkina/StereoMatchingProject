%% Benchmark 1
% Follow instructions in "Project Starter Idea" section of stereo 
% disparity lab to see how window shapes effect disparity prediction.
% We create 9 different shapes and vary over all pos
% Authors:
% Renn Jervis 
% Vasilisa Bashlovkina
%
% CSC 262 Final Project

% load two stereo images
view1 = im2double(imread('/home/weinman/courses/CSC262/images/view1.png')); 
view2 = im2double(imread('/home/weinman/courses/CSC262/images/view5.png'));
% convert to grayscale
view1 = rgb2gray(view1);
view2 = rgb2gray(view2);

%figure, imshow(view1), title('View 1');
%figure, imshow(view2), title('View 2');

% load disparity
groundTruth = imread('/home/weinman/courses/CSC262/images/truedisp.png');

% scale ground truth (after casting to double to eliminate chance of zero
% distance ) to match scaled images.
groundTruth = double(groundTruth)/3;
% calculate max disparity for padding
maxDisparity = max(groundTruth(:));

% pad images with max disparity
padView1 = padarray(view1, [0 maxDisparity], 'post');
padView2 = padarray(view2, [0 maxDisparity], 'post');

% extract linear indices > 0 and < 0 from ground truth image
nonZeroIndices = find(groundTruth);
zeroIndices = find(groundTruth <= 0);

% create 9 different window shapes
N=22;
mid = floor(N/2);

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
zero = zeros(N);
shapes(:, :, 6) = triu(one) /  numel(find(triu(one))); %magic kernel 2
shapes(:, :, 7) = tril(one) / numel(find(tril(one))) ;
shapes(:, :, 8) = flipdim(triu(one), 2)/numel(find(flipdim(triu(one), 2)));
shapes(:, :, 9) = flipdim(tril(one), 2)/numel(find(flipdim(tril(one), 2))); 

%%  for odd kernels 
% % 4 vertically and horozontally divided kernels, normalized
% % left and right kernels
% shapes( :, 1:mid, 2) = ones(N, mid) / (N*mid);
% shapes( :, mid+1:end, 3) = ones( N, mid+1)/ (N*(mid+1));
% % top and bottom kernels
% shapes(1:mid, :, 4) = ones(mid, N)/ (N*mid);
% shapes(mid+1:end, :, 5) = ones(mid+1, N)/ (N*(mid+1));
% % diagonal kernels
% one = ones(N);
% zero = zeros(N);
% shapes(:, :, 6) = triu(one) /  numel(find(triu(one)));
% shapes(:, :, 7) = tril(one) / numel(find(tril(one))) ;
% shapes(:, :, 8) = flipdim(triu(one), 3)/numel(find(flipdim(triu(one), 3)));
% shapes(:, :, 9) = flipdim(tril(one), 3)/numel(find(flipdim(tril(one), 3))); 

% choose best disparity and shape at each pixel

% create 4d results array
% Results = zeros(1, length(shapes));
result = zeros(370, 538, 75, 9);

% for each of the 9 shapes
for j = 1:size(shapes, 3)
        
% check every disparity up to max
for i=maxDisparity:-1:1
    % create shifted view based on disparity
    shiftedView2 = imtranslate(padView2, 0, -i, 0);
    
    % computing squared differences
    squaredDiffs = (padView1-shiftedView2).^2;

    % convolution to get patch SSDs, vary patch size
    kernel = shapes(:,:,j);
    % place in appropriate 'slice' of result array
    result(:,:,i, j) = conv2(squaredDiffs, kernel, 'same');     
end

end

% extract shape choices
[minShape, ShapeIndices] = min(result(:, 1:end-maxDisparity, :, :), [], 4);

% extract best disparity choices 
[minDisp, dispIndices] = min(minShape, [], 3);
BestShapeIndices = ShapeIndices(dispIndices);

% set predicted disparity to zero in appropriate places
disparityPrediction = dispIndices;
disparityPrediction(zeroIndices) = 0;

figure, imshow(BestShapeIndices, []), colormap(jet),colorbar, title('Window Shapes Used');
figure, imshow(disparityPrediction, []), colormap(jet), colorbar;
title('Disparity Prediction with 9 Window Shapes');

% optional noise reduction: gaussian convolution gauss = gkern(1);
% reducedNoise1 = conv2(gauss, gauss', disparityPrediction, 'same');
% disparityPrediction(zeroIndices) = 0; figure, imshow(disparityPrediction,
% []), title('Noise Reduced Disparity Predicted with 9 Window Shapes');
% colormap jet;

% calculate RMS error between prediction and real disparity
disparityDiff = bsxfun(@minus, groundTruth(nonZeroIndices), disparityPrediction(nonZeroIndices));
squaredDDif = disparityDiff.^2;
meanSquared = mean(squaredDDif(:));
RMS = sqrt(meanSquared);

fullDispDiff = groundTruth - disparityPrediction;
fullDispDiff(zeroIndices) = 0;

%3d predicted error
figure, surf(fullDispDiff, 'EdgeColor','none'), title('Depth Error Produced with 9 Window Shapes');
axis ij;
view(48,52);

%error3D1 = imread('3Derror1shape.jpg');
%figure;
%subplot(1,2,1), imshow(error3D1);
%subplot(1,2,2), imshow(fullDispDiff);
%truesize;
