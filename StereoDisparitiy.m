%% Lab: Stereo Disparity
% Authors: 
% Vasilisa Bashlovkina (Box 3077)
% Renn Jervis (Box 3762)
% 
% CSC 262

%% Introduction
% In this lab we will develop a method to infer the depth of objects in a
% scene, based on two images of the same scene from slightly different
% viewpoints. We will compare our depth prediction to true values of depth,
% and attempt to reduce the difference between the two disparity 
% representations. 


%% Initial Work
% We begin by loading 2 rectified stereo images -- displayed below -- as
% well as a record of ground truth disparity between the two images. We
% want to ensure that our images are the same size -- even though one is
% offset by a disparity -- and so we 'pad' our images with rows of zeros
% (black pixels). This padding is added to the right side of our picture,
% and so we translate the actual image 50 pixels to the right to allow
% padding on both right and left edges. Our initial padding is equal to the
% maximum disparity recorded in the ground truth data. 

%%
% Because we have ensured that our two images are the same size, we now
% generate an image that contains the squared differences between the two
% stereo images (one shifted and one not). Lastly, we calculate the sum of
% these differences over each 5 X 5 patch. To calculate these sums we use a
% separable boxcar filter. The two original image as well as the translated
% and padded image are shown below.

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

% shift second image
shiftedView2 = imtranslate(padView2, 0, -50, 0);
figure, imshow(shiftedView2), title('Shifted and Padded View 2');

squaredDiffs = (padView1-shiftedView2).^2; % squared differences

% convolution to get patch SSDs, 5 by 5 patch
kernel = ones(1,5);
convolved = conv2(kernel, kernel', squaredDiffs, 'same');

%% Considering All Possible Disparities
% Our goal now is to generate the sum of squared differences for every
% possible disparity, and select the best one at each point. We will use
% approach described above, but we will vary the amount by which we shift
% the second view each time. We then stack the sums of square differences
% calculated for various disparities in a 3D array, with each layer along
% the third dimension corresponding to the next disparity.

% count down from largest disparity to 1
for i=maxDisparity:-1:1
    % shifting by current disparity
    shiftedView2 = imtranslate(padView2, 0, -i, 0);
    
    % computing squared differences
    squaredDiffs = (padView1-shiftedView2).^2;

    % convolution to get patch SSDs
    kernel = ones(1,7);
    % place in appropriate 'slice' of result array
    result(:,:,i) = conv2(kernel, kernel', squaredDiffs, 'same');    
end
  
%% Choosing the Optimal Disparity at Each Point
% Now that we have all possible disparities for each point, we want to
% choose the best one at each point. To do this we search across the third
% dimension of our array to locate the minimum sum of squared differences
% at every point.

% compute the min along 3rd dim, using original indices
[mins, disparityPrediction] = min(result(:, 1:end-maxDisparity, :), [], 3);

% extract linear indices > 0 and < 0 from ground truth image
nonZeroIndices = find(groundTruth);
zeroIndices = find(groundTruth <= 0);

%%
% We will now calculate the root mean square error between the original
% disparity and our predicted disparity. For our initial patch size of 5 X
% 5 our calculated root mean square difference is 13.72, which seems
% reasonably small.

% calculate RMS error between prediction and real disparity
disparityDiff = bsxfun(@minus, groundTruth(nonZeroIndices), disparityPrediction(nonZeroIndices));
squaredDDif = disparityDiff.^2;
meanSquared = mean(squaredDDif(:));
RMS = sqrt(meanSquared);


%% Changing Parameters
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
% % extract our best disparity prediction (used later)
% if(windowSizes(j) == 7)
%     disparityPrediction = minIndices;
% end
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

%% 
% We see from our plot that the RMS varies with window size. In particular
% as we increase from 1 to 7, the RMS decreases. We see a local minimum at
% window size 7 X 7, and above this size the RMS increases. We can conclude
% that the local minimum is the optimal window size, which minimizes our
% error to 10.36. The trade-off for using increasingly large window sizes is
% that run time of the convolution increases. Another trade-off is that
% with a larger kernel, the size of the valid convolved image gets smaller,
% while the zero padding on the edges expands. Finally, as we increase our
% kernel size we effectively blur the image, thus losing detail.


%% Visualizing Results
% We will now create a 2D visualization of the original and the
% predicted disparity. 

% 3d version original disparity
% figure, surf(groundTruth, 'EdgeColor','none'), title('True Disparity');
% axis ij;


% 3d predicted disparity
% figure, surf(disparityPrediction, 'EdgeColor','none'), title('Predicted Disparity');
% axis ij;

%%
% Displayed below is the original disparity as a 2d image (the color
% indicates depth), and our predicted disparity. To account for occluded
% regions, i.e. regions visible in one picture and not the other, we zero
% points we know to be occluded based on the ground truth data.  In these
% images colder colors represent distant regions and warmer colors indicate
% closer regions. 

% display 2d versions
figure, imshow(groundTruth, []), title('True Disparity 2d'), colormap jet;

% set predicted disparity to zero in appropriate places
disparityPrediction2 = disparityPrediction;
disparityPrediction2(zeroIndices) = 0;
% display 2d versions
figure, imshow(disparityPrediction2, []), title('Disparity Prediction with Single 7x7 Window');
colormap jet;
RMS % 10.3655 

fullDispDiff = groundTruth - disparityPrediction;
fullDispDiff(zeroIndices) = 0;
figure, imshow(fullDispDiff), title('Disparity Error Produced with Single Window');

% 3d predicted disparity
figure, surf(fullDispDiff, 'EdgeColor','none'), title('Depth Error Produced with Single Window');
axis ij;
view(48,52);
%%
% In comparing our predicted disparity with the true disparity, we observe
% that our prediction represents a reasonable approximation of reality. We
% can recognize large objects, such as the figure head and the huge crayon.
% At the same time, smaller objects such as the sticks that hold the rings
% appear less clearly and are distorted. Since we manually zeroed all the 
% occluded points in our image, we see that these regions match the true
% disparity perfectly. We note that in our disparity prediction, we see
% much more color variation (indicating depth variation) within larger
% shapes. For instance, the figure head in the true disparity appears as a
% flat (uniformly yellow) region, whereas in our prediction we see a larger
% color variation going from the eye (which is slightly farther away) to 
% the cheek region (which is lightly closer). In this example, our
% prediction is perhaps detecting a higher resolution of depth variation in
% the scene. However, our prediction is tricked by the stripes on the
% crayon, which ought to be at the same depth but are shown with different
% depths. Similarly our method is tricked by the freckle on the figure's
% cheek; in our disparity image this freckle is interpreted as a point 
% deeper in the image, and so appears blue. We do not see this artifact in
% the original. 

%%
% We note that overall objects that are closer to the camera are
% interpreted more correctly than those deeper in the background by our
% prediction. We expect that this is related to the fact that disparity is
% inversely related to depth. We also see a correlation between the
% frequency of the region and the accuracy of its depth inference: the
% lower the frequency the better the result. This may be due to our
% approach for calculating the SSD for each pixel: we convolve with a
% separable filter, effectively reducing the frequency of the image.

%% Dealing with Noise
% The dissimilarity between our original and predicted disparity images
% could be explained by some amount of noise that was introduced in our
% processing. We will implement 2 noise reduction techniques to try to
% improve our RMS error and the appearance of our predicted disparity.

%%
% Our first approach is to blur with a Gaussian kernel, thus decreasing the
% frequency of the disparity image. We choose to blur first and then zero
% the occluded points; if we were to zero the occluded points first, we
% would lose information. The noise reduced image is shown below.

% noise reduction 1: gaussian convolution
gauss = gkern(11);
reducedNoise1 = conv2(gauss, gauss', disparityPrediction, 'same');
reducedNoise1(zeroIndices) = 0;
figure, imshow(reducedNoise1, []), title('Reduced Noise Disparity- Gaussian Filter');
colormap jet;

% calculate RMS error between prediction and real disparity

disparityDiff = bsxfun(@minus, groundTruth(nonZeroIndices), reducedNoise1(nonZeroIndices));
squaredDDif = disparityDiff.^2;
meanSquared = mean(squaredDDif(:));
RMS = sqrt(meanSquared);

%%
% Our original noise RMS error was 10.36, and after noise reduction we
% achieve an error level 8.64. We see that this image has much less clearly
% defined edges, for example the head and center cone appear to be
% surrounded by a yellow 'halo' effect.

%%
% Our second noise reduction technique is to blur with a median filter. In
% this case, our RMS is 9.90. We see that this is not as effective as the
% Gaussian filter, thus we choose to enhance our first noise reduction
% approach.

% noise reduction 2, median
disparityPrediction3 = disparityPrediction;
reducedNoise2 = medfilt2(disparityPrediction3);

figure, imshow(reducedNoise2, []), title('Reduced Noise Disparity- Median Filter');
colormap jet;

disparityDiff = bsxfun(@minus, groundTruth(nonZeroIndices), reducedNoise2(nonZeroIndices));
squaredDDif = disparityDiff.^2;
meanSquared = mean(squaredDDif(:));
RMS = sqrt(meanSquared);

%%
% To determine the best approach for blurring with a Gaussian, we now
% attempt to determine the relationship between the size of our Gaussian
% filter and the RMS error between the disparities. We vary the kernel size
% from 1 to 51, considering only odd kernels, and plot the resulting
% relationship below.

% vary parameters of reduction 1
kernelSize = [1:2:51];
RMSvsKernel = zeros(1, length(kernelSize));
% for k=1:length(kernelSize)
%    
%     gauss = gkern(kernelSize(k));
%     reducedNoise1 = conv2(gauss, gauss', disparityPrediction, 'same');
%     reducedNoise1(zeroIndices) = 0;
%     
%     disparityDiff = bsxfun(@minus, groundTruth(nonZeroIndices), reducedNoise1(nonZeroIndices));
%     squaredDDif = disparityDiff.^2;
%     meanSquared = mean(squaredDDif(:));
%     RMS = sqrt(meanSquared);
%     
%     RMSvsKernel(k) = RMS;
%     
%     % save best image
%     if(kernelSize(k) == 11)
%         bestDisparity = reducedNoise1;
%     end
%     
% end
%     
% figure, plot(kernelSize, RMSvsKernel), title('RMS vs Kernel Size');
% xlabel('Blurring Kernel Size'), ylabel('RMS');

openfig('RMS_vs_KernelSize.fig');

%%
% We see that in this graph we have a local minimum at 11. Using this as
% the kernel size for the Gaussian filter, we display the best version of
% our disparity image below.

figure,imshow(bestDisparity, []), colormap jet;
title('Best Reduced Noise Disparity Prediction');

% 3d predicted disparity
% figure, surf(bestDisparity, 'EdgeColor','none'), title('Predicted Disparity');
% axis ij;

%% Conclusion
% In this lab we developed a technique to infer depth from a pair of images
% of the same scene. We created and refined our prediction of depth by
% first finding the optimal window size for computing the Sum of Squared
% Differences. We then refined our representation further by experimenting
% with noise reduction methods. We were able to assess our prediction
% thanks to the ground truth data, minimizing the root mean square error
% between our prediction and the original data. Our best prediction of the
% depth of the image is adequate, but could be improved. 

%% Acknowledgements
%
% The stereo and disparity images are courtesy of the 2005 Middlebury
% stereo dataset (Art image). The corresponding paper is:
% Christopher J. Pal, Jerod J. Weinman, Lam C. Tran and Daniel Scharstein. 
% (2012). On Learning Conditional Random Fields for Stereo: Exploring Model
% Structures and Approximate Inference. International Journal of Computer 
% Vision, 99(3), 319-337. 

