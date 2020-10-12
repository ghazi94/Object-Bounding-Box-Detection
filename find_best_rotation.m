function [final_rotation_angle] = find_best_rotation(input_image)
%% Finds the best rotation bases on blob outputs of all the eight algorithms
% % % Default
final_rotation_angle = 0;
% % % Sub Function
  function [houghLines] = generate_hough_lines(vertResponse)
      [HoughP,Theta,Rho] = hough(vertResponse);
      HoughPeaks  = houghpeaks(HoughP,5,'threshold',ceil(0.3*max(HoughP(:))));
      XHP = Theta(HoughPeaks(:,2)); YHP = Rho(HoughPeaks(:,1));
      houghLines = houghlines(vertResponse,Theta,Rho,HoughPeaks,'FillGap',5,'MinLength',7);
  end
% % % Thresholds
thresholdLength = 300;
minVerLineRatio = 120/2000;
minHorLineRatio = 240/3000;

% METHOD -1 ----------------------------------------------- %
% Apply Haar Wavelet Filter for Filtering out vertical edges
intImage = integralImage(input_image);
horiH = integralKernel([1 1 4 3; 1 4 4 3],[-1, 1]);
vertH = horiH.';
vertResponse = integralFilter(intImage,vertH);
horzResponse = integralFilter(intImage,horiH);
end