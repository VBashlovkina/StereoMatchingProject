% load two images
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

% pad images
padView1 = padarray(view1, [0 maxDisparity], 'post');
padView2 = padarray(view2, [0 maxDisparity], 'post');

% extract linear indices > 0 and < 0 from ground truth image
nonZeroIndices = find(groundTruth);
zeroIndices = find(groundTruth <= 0);

% create 9 different window shapes
N=16;
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
shapes(:, :, 8) = flipdim(triu(one), 3)/numel(find(flipdim(triu(one), 3)));
shapes(:, :, 9) = flipdim(tril(one), 3)/numel(find(flipdim(tril(one), 3))); 

%% V for odd kernels V
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
Results = zeros(1, length(shapes));
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

%  % compute the min along 3rd dim
% [mins, minIndices] = min(result(:, 1:end-maxDisparity, :), [], 3);
% 
% % calculate RMS error between prediction and real disparity
% disparityDiff = bsxfun(@minus, groundTruth(nonZeroIndices), minIndices(nonZeroIndices));
% 
% % rms2 = rms(disparityDiff2); % function rms yields same value
% squaredDDif = disparityDiff.^2;
% meanSquared = mean(squaredDDif(:));
% RMS = sqrt(meanSquared);
% 
% % store RMS in result array
% Results(j) = RMS;
end 

[minShape, ShapeIndices] = min(result(:, 1:end-maxDisparity, :, :), [], 4);

[minDisp, dispIndices] = min(minShape, [], 3);
BestShapeIndices = ShapeIndices(dispIndices);



% calculate RMS error between prediction and real disparity
disparityDiff = bsxfun(@minus, groundTruth(nonZeroIndices), dispIndices(nonZeroIndices));

% rms2 = rms(disparityDiff2); % function rms yields same value
squaredDDif = disparityDiff.^2;
meanSquared = mean(squaredDDif(:));
RMS = sqrt(meanSquared);




% shapeNames = {'Sq', 'LR' , 'RR' ,'UR','LoR', 'ULD','LRD','URD','LLD'};
% figure, bar(Results), title('RMS vs SSD Window Shapes');
%  xlabel('Window Shape'), ylabel('RMS');
%  set(gca, 'XTick', 1:length(shapes), 'XTickLabel', shapeNames);

% display 2d versions
%figure, imshow(groundTruth, []), title('True Disparity 2d'), colormap jet;

% % set predicted disparity to zero in appropriate places
disparityPrediction = dispIndices;
disparityPrediction(zeroIndices) = 0;

figure, imshow(BestShapeIndices, []), colorbar;

figure, imshow(disparityPrediction, []), colormap(jet), colorbar;
% display 2d versions
%figure, imshow(disparityPrediction2, []), title('Predicted Disparity 2d');
%colormap jet;
% 
% 
% % noise reduction 1: gaussian convolution
% gauss = gkern(5);
% reducedNoise1 = conv2(gauss, gauss', disparityPrediction, 'same');
% reducedNoise1(zeroIndices) = 0;
% figure, imshow(reducedNoise1, []), title('Reduced Noise Disparity- Gaussian Filter');
% colormap jet;
% 
% % calculate RMS error between prediction and real disparity
% 
% disparityDiff = bsxfun(@minus, groundTruth(nonZeroIndices), reducedNoise1(nonZeroIndices));
% squaredDDif = disparityDiff.^2;
% meanSquared = mean(squaredDDif(:));
% RMS = sqrt(meanSquared);
% 
% 
% % Our second noise reduction technique is to blur with a median filter. In
% % this case, our RMS is 9.90. We see that this is not as effective as the
% % Gaussian filter, thus we choose to enhance our first noise reduction
% % approach.
% 
% % noise reduction 2, median
% disparityPrediction3 = disparityPrediction;
% reducedNoise2 = medfilt2(disparityPrediction3);
% 
% figure, imshow(reducedNoise2, []), title('Reduced Noise Disparity- Median Filter');
% colormap jet;
% 
% disparityDiff = bsxfun(@minus, groundTruth(nonZeroIndices), reducedNoise2(nonZeroIndices));
% squaredDDif = disparityDiff.^2;
% meanSquared = mean(squaredDDif(:));
% RMS = sqrt(meanSquared);
% 
% %%
% % To determine the best approach for blurring with a Gaussian, we now
% % attempt to determine the relationship between the size of our Gaussian
% % filter and the RMS error between the disparities. We vary the kernel size
% % from 1 to 51, considering only odd kernels, and plot the resulting
% % relationship below.
% 
% % vary parameters of reduction 1
% kernelSize = [1:2:51];
% RMSvsKernel = zeros(1, length(kernelSize));
% % for k=1:length(kernelSize)
% %    
% %     gauss = gkern(kernelSize(k));
% %     reducedNoise1 = conv2(gauss, gauss', disparityPrediction, 'same');
% %     reducedNoise1(zeroIndices) = 0;
% %     
% %     disparityDiff = bsxfun(@minus, groundTruth(nonZeroIndices), reducedNoise1(nonZeroIndices));
% %     squaredDDif = disparityDiff.^2;
% %     meanSquared = mean(squaredDDif(:));
% %     RMS = sqrt(meanSquared);
% %     
% %     RMSvsKernel(k) = RMS;
% %     
% %     % save best image
% %     if(kernelSize(k) == 11)
% %         bestDisparity = reducedNoise1;
% %     end
% %     
% % end
% %     
% % figure, plot(kernelSize, RMSvsKernel), title('RMS vs Kernel Size');
% % xlabel('Blurring Kernel Size'), ylabel('RMS');
% 
% openfig('RMS_vs_KernelSize.fig');
% 
% %%
% % We see that in this graph we have a local minimum at 11. Using this as
% % the kernel size for the Gaussian filter, we display the best version of
% % our disparity image below.
% 
% figure,imshow(bestDisparity, []), colormap jet;
% title('Best Reduced Noise Disparity Prediction');
% 
% % 3d predicted disparity
% % figure, surf(bestDisparity, 'EdgeColor','none'), title('Predicted Disparity');
% % axis ij;

RMS
