base_path = '/home/UserName/Desktop/Images/set-1/';
image1 = imread(strcat(base_path, 'DSC_0148.jpg'));
product_images = {...
    strcat(base_path, 'DSC_0151.jpg') ...
%     strcat(base_path, 'DSC_0150.jpg'), ...
%     strcat(base_path, 'DSC_0151.jpg') ...
%     strcat(base_path, 'DSC_0152.jpg'), ...
%     strcat(base_path, 'DSC_0153.jpg'), ...
%     strcat(base_path, 'DSC_0154.jpg'), ...
%     strcat(base_path, 'DSC_0155.jpg'), ...
%     strcat(base_path, 'DSC_0156.jpg'), ...
%     strcat(base_path, 'DSC_0157.jpg'), ...
%     strcat(base_path, 'DSC_0158.jpg')...
    };
fontSize = 8;

for product_image = product_images
    image_path = cell2mat(product_image);
    image2 = imread(image_path);
    % image3 = imread('/home/UserName/Desktop/3.jpg');
    pos = imsubtract(image2, image1);
    neg = imsubtract(image1, image2);
    combined_mask = pos + neg;
   
%     subplot(1, 3, 1);
%     imshow(pos);
%     subplot(1, 3, 2);
    
%     subplot(1, 3, 3);
%     imshow(combined_mask);
    object_mask_phase_0 = neg;
    figure;
    imshow(object_mask_phase_0);
    grayImage = rgb2gray(object_mask_phase_0);
    % Now get some threshold for noise
    meanGL = mean(grayImage(:));
    sd = std(double(grayImage(:)));
    whiteThreshold = meanGL + 1.7 * sd;
    % Threshold the image to find noise.
    object_mask_ph_1 = grayImage >= whiteThreshold;
    % Display the noise pixels.
    figure;
    subplot(1, 1, 1);
    imshow(object_mask_ph_1, []);
    caption = sprintf('Pixels above white threshold of %.2f', whiteThreshold);
    title(caption, 'FontSize', fontSize);
    
%     remove edge connected border elements
%     object_mask_ph_2 = imclearborder(object_mask_ph_1);
%     figure;
%     subplot(1, 1, 1);
%     imshow(object_mask_ph_2, []);
%     caption = sprintf('final');
%     title(caption, 'FontSize', fontSize);
%   Overlay mask into the original image
    % Mask the image using bsxfun() function
%     maskedRgbImage = bsxfun(@times, image2, cast(object_mask_ph_1, 'like', image2));
%     figure;
%     imshow(maskedRgbImage);
    alpha_mask = double(object_mask_ph_1);
    imwrite(image2, strcat(base_path, 'output_1.png'), 'Alpha', alpha_mask);
%     horizontal_dilation_elem = strel('line', 30, 0);
%     object_mask_ph_2 = imdilate(object_mask_ph_1, horizontal_dilation_elem);
%     subplot(2, 3, 2);
%     imshow(object_mask_ph_2, []);
%     caption = sprintf('Horz Dilation');
%     title(caption, 'FontSize', fontSize);
%     
%     object_mask_ph_3 = imerode(object_mask_ph_2, horizontal_dilation_elem);
%     subplot(2, 3, 3);
%     imshow(object_mask_ph_3, []);
%     caption = sprintf('Horz Erosion');
%     title(caption, 'FontSize', fontSize);
%     
%     
%     ver_dilation_elem = strel('line', 30, 90);
%     object_mask_ph_4 = imdilate(object_mask_ph_3, ver_dilation_elem);
%     subplot(2, 3, 4);
%     imshow(object_mask_ph_4, []);
%     caption = sprintf('Ver Dilation');
%     title(caption, 'FontSize', fontSize);
%     
%     object_mask_ph_5 = imerode(object_mask_ph_4, ver_dilation_elem);
%     subplot(2, 3, 5);
%     imshow(object_mask_ph_5, []);
%     caption = sprintf('Ver Erosion');
%     title(caption, 'FontSize', fontSize);
%     
%     [bw_width, bw_height] = size(object_mask_ph_5);
%     area_of_image = bw_width * bw_height;
%     threshold_area = area_of_image/100;
%     object_mask_ph_6 = bwareaopen(object_mask_ph_5 , threshold_area);
%     subplot(2, 3, 6);
%     imshow(object_mask_ph_6, []);
%     caption = sprintf('White patches removed with less than %.2f area', threshold_area);
%     title(caption, 'FontSize', fontSize);
    % Divide regionprops areas by 8 point connected objects only
%     RegionProp = regionprops(bwconncomp(object_mask_ph_3), 'BoundingBox', 'Area');
%     for regionPropI = 1:length(RegionProp)
%         if RegionProp(regionPropI).Area > threshold_area
%             rectangle('Position', RegionProp(regionPropI).BoundingBox, 'EdgeColor', 'red');
%         else
%             rectangle('Position', RegionProp(regionPropI).BoundingBox, 'EdgeColor', 'blue');
%         end
%     end
    
%     imshow(object_mask_ph_4, []);
%     caption = sprintf('White patches removed with less than %.2f area', area_of_image/100);
%     title(caption, 'FontSize', fontSize);
    
    
%     % I don't want regions lesser than the noise to be displayed, rather they should be rendered white
%     % Find pixels less than the noise threshold
%     lessThanNoise = grayImage < whiteThreshold;
%     % Display the less than noise pixels.
%     subplot(2, 2, 3);
%     imshow(lessThanNoise, []);
%     title('Pixels less than the Noise', 'FontSize', fontSize);
%     % Set those pixels to white in the original image
%     outputImage = grayImage; % Initialize.
%     outputImage(lessThanNoise) = 255;
%     % Display the less than noise pixels.
%     subplot(2, 2, 4);
%     imshow(outputImage, []);
%     caption = sprintf('Pixels less than the Noise set to White\nMore than noise is unchanged (original)');
%     title(caption, 'FontSize', fontSize);
% %     figure, imshow(image1);
% %     figure, imshow(image2);
%     figure, imshow(pos + neg);
end

% grayImage = image1;
% % Get the dimensions of the image.  numberOfColorBands should be = 1.
% [rows,columns,numberOfColorBands] = size(grayImage);
% % Display the original gray scale image.
% subplot(2, 2, 1);
% imshow(grayImage, []);
% % title('Original Grayscale Image - Spatial Domain', 'FontSize', fontSize);
% title('Original Grayscale Image - Spatial Domain');
% % Enlarge figure to full screen.
% % set(gcf, 'Position', get(0,'Screensize')); 
% set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% set(gcf,'name','Edge Detection and ','numbertitle','off')
% % Take the FFT.
% fftImage = fft2(grayImage);
% % Shift it and take log so we can see it easier.
% centeredFFTImage = log(fftshift(real(fftImage)));
% % Display the FFT image.
% subplot(2, 2, 2);
% imshow(centeredFFTImage, []);
% % title('log(FFT Image) - Frequency Domain', 'FontSize', fontSize);
% title('log(FFT Image) - Frequency Domain');
% % Zero out the corners
% window = 30;
% fftImage(1:window, 1:window) = 0;
% fftImage(end-window:end, 1:window) = 0;
% fftImage(1:window, end-window:end) = 0;
% fftImage(end-window:end, end-window:end) = 0;
% % Display the filtered FFT image.
% % Shift it and take log so we can see it easier.
% centeredFFTImage = log(fftshift(real(fftImage)));
% subplot(2, 2, 3);
% imshow(centeredFFTImage, []);
% % title('Filtered log(FFT Image) - Frequency Domain', 'FontSize', fontSize);
% title('Filtered log(FFT Image) - Frequency Domain');
% % Inverse FFT to get high pass filtered image.
