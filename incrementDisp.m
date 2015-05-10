function [ incr ] = incrementDisp( view1, view2, d, x, y, window )
% INCREMENTDISP produces a value by which the current measure of disparity
% at given pixel (D(Y,X)) should be incremented to minimize uncertainty for
% the given WINDOW.

% equation 20:
% numerator: sum over window (phi1(x, y) * phi2(x, y))
% denominator: sum over all pixels phi2^2 -> use in uncertainty as well



%% STUB
incr = 0;
for i = 0:window.width
	for j = 0:window.height
		% calc phi 1
		% intensity diff / scary square root
		% scary denom = sqrt(2* additive noise coeff^2 ....
		% *(dispVariation * intenVariation coeffs) ...
		% *sqrt(i^2 + j^2)

		% calc phi2
		% num = derivative intensity function 2
		% denom = scary denom above

		% genNum = phi1 * phi2
		% genDenom = 


end

