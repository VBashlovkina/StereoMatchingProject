%% Code from original lab on StereoDisparity
% Authors:
% Renn Jervis 
% Vasilisa Bashlovkina
%
% CSC 262 Final Project

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

% choose best disparity and shape at each pixel
        
% check every disparity up to max
for i=maxDisparity:-1:1
    % create shifted view based on disparity
    shiftedView2 = imtranslate(padView2, 0, -i, 0);
    
    % computing squared differences
    squaredDiffs = (padView1-shiftedView2).^2;

    % convolution to get patch SSDs, vary patch size
    kernel = ones(1, 7);
    % place in appropriate 'slice' of result array
    result(:,:, i) = conv2(squaredDiffs, kernel, 'same');     
end

%  % compute the min along 3rd dim
[mins, minIndices] = min(result(:, 1:end-maxDisparity, :), [], 3);

% % set predicted disparity to zero in appropriate places
disparityPrediction = minIndices;
disparityPrediction(zeroIndices) = 0;

% calculate RMS error between prediction and real disparity
disparityDiff = bsxfun(@minus, groundTruth(nonZeroIndices), disparityPrediction(nonZeroIndices));
% squaredDDif = disparityDiff.^2;
% meanSquared = mean(squaredDDif(:));
% RMS = sqrt(meanSquared);
figure;
openfig('RMS_vs_WinSize.fig');
figure, imshow(disparityPrediction, []), colormap(jet), colorbar;
title('Original Disparity Map Produced');

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

%% Varying Parameters
% In an attempt to minimize our root mean square error, we will examine the
% effects of calculating the sum of squared differences with varying patch
% sizes. We plot the resulting relationship between the root mean square
% and the window size below.

% windowSizes = [1:2:51];
% windowResults = zeros(1, length(windowSizes));
% for j = 1:length(windowSizes)
%         
% % count down from largest disparity to 1
% for i=maxDisparity:-1:1
%     % shifting by current disparity
%     shiftedView2 = imtranslate(padView2, 0, -i, 0);
%     
%     % computing squared differences
%     squaredDiffs = (padView1-shiftedView2).^2;
% 
%     % convolution to get patch SSDs, vary patch size
%     kernel = ones(1,windowSizes(j));
%     % place in appropriate 'slice' of result array
%     result(:,:,i) = conv2(kernel, kernel', squaredDiffs, 'same');     
% end
% 
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
% windowResults(j) = RMS;
% end 

% note: we manually saved figure
% figure, plot( windowSizes, windowResults),title('RMS vs SSD Window Sizes');
%  xlabel('Window Size'), ylabel('RMS');

% doesnt need new figure
%openfig('RMS_vs_WinSize.fig');

%% Acknowledgements
%
% The stereo and disparity images are courtesy of the 2005 Middlebury
% stereo dataset (Art image). The corresponding paper is:
% Christopher J. Pal, Jerod J. Weinman, Lam C. Tran and Daniel Scharstein. 
% (2012). On Learning Conditional Random Fields for Stereo: Exploring Model
% Structures and Approximate Inference. International Journal of Computer 
% Vision, 99(3), 319-337. 

