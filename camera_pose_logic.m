% [relativeOrientation,relativeLocation] = relativeCameraPose(M,cameraParams,inlierPoints1,inlierPoints2);
% detectCheckerboardPoints(imageFileNames);
load '/home/UserName/Desktop/Images/checkerboard-dslr/cameraParamsDSLR.mat'
base_path = '/home/UserName/Desktop/Images/camera-pose-1/';
image1 = imread(strcat(base_path, 'DSC_0161.JPG'));
image2 = imread(strcat(base_path, 'DSC_0162.JPG'));
fontSize = 8;

[checkPoints1,boardSize1,imagesUsed1] = detectCheckerboardPoints(image1);
[checkPoints2,boardSize2,imagesUsed2] = detectCheckerboardPoints(image2);

inlierPoints1 = checkPoints1;
inlierPoints2 = checkPoints2;

fundamental_matrix = estimateFundamentalMatrix(inlierPoints1,inlierPoints2);

[relativeOrientation,relativeLocation] = relativeCameraPose(fundamental_matrix, cameraParamsDSLR, inlierPoints1, inlierPoints2);
[rotationMatrix,translationVector] = cameraPoseToExtrinsics(relativeOrientation,relativeLocation);

plot_point = [1, 1, 1];
orientation_vector = [1, 1, 1];
dummy_orientation_vector = [orientation_vector(1, 1), orientation_vector(1, 2), orientation_vector(1, 3);...
                                0,0,0;...
                                0,0,0];

figure;
quiver3(orientation_vector(1, 1), orientation_vector(1, 2), orientation_vector(1, 3), ...
                            plot_point(1, 1), plot_point(1, 2), plot_point(1, 3));

translated_point = plot_point + translationVector;
new_orientation_vector = dot(dummy_orientation_vector, rotationMatrix);

quiver3(new_orientation_vector(1, 1), new_orientation_vector(1, 2), new_orientation_vector(1, 3), ...
                            translated_point(1, 1), translated_point(1, 2), translated_point(1, 3));
                        
figure;
subplot(2, 2, 1);
imshow(image1, []);
caption = sprintf('First image taken from location 1');
title(caption, 'FontSize', fontSize);

subplot(2, 2, 2);
imshow(image2, []);
caption = sprintf('First image taken from location 2');
title(caption, 'FontSize', fontSize);

subplot(2, 2, 3);
quiver3(orientation_vector(1, 1), orientation_vector(1, 2), orientation_vector(1, 3), ...
                            plot_point(1, 1), plot_point(1, 2), plot_point(1, 3));
caption = sprintf('Vector of camera 1 orientation - from origin with 45 degrees');
title(caption, 'FontSize', fontSize);

subplot(2, 2, 4);
quiver3(new_orientation_vector(1, 1), new_orientation_vector(1, 2), new_orientation_vector(1, 3), ...
                            translated_point(1, 1), translated_point(1, 2), translated_point(1, 3));
caption = sprintf('Vector of camera 2 orientation - relative to vector 1');
title(caption, 'FontSize', fontSize);