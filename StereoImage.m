classdef StereoImage
    %STEREOIMAGE is a class that holds information pertinent to working
    %with a pair of stereo images, like their disparity and derivative
    %maps.
    properties
        View1 % first stereo image
        View2 % second stereo image
        DisparityMap % current estimate of disparity
        DerivView2 % derivative of intensity values of view 2
    end
    
    methods
        % constructor
        function obj = StereoImage(view1, view2)
            obj.View1 = view1;
            obj.View2 = view2;
            % initial disparity calculation using the algorithm developped
            % in lab
            obj.DisparityMap = initialDisparity(view1, view2);
            % computing the deriv map FIXME, ONLY NEED X DIRECTION
            derivGauss = gkern(2,1); % gaussian derivative kernel
            gauss = gkern(2); % gaussian kernel
            % yderivMap = conv2(derivGauss, gauss', view2, 'same');
            xderivMap = conv2(gauss, derivGauss', view2, 'same');
            obj.DerivView2 = xderivMap;
	    % obj.DerivView2 = sqrt(yderivMap.^2 + xderivMap.^2);
        end %constructor
        
        
    end %methods
    
end %StereoImage

