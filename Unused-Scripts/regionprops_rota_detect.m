function [rotation_angle] = regionprops_rota_detect (binaryImage) 
    %% Detects skew in images and suggests angle of rotation based on that
    % ------ FIND HOW MUCH ROTATIONAL CORRECTION IS TO BE MADE ------ %
    
%     [rows, columns, numberOfColorBands] = size(rgbImage);
%     grayImage = rgb2gray(rgbImage);
%     binaryImage = grayImage > 128;
%     binaryImage = imfill(binaryImage, 'holes');
    max_area = 0;
    rotation_angle = 0;
    RegionProp = regionprops(bwconncomp(binaryImage), 'all');
    for regionPropI = 1:length(RegionProp)
        if RegionProp(regionPropI).Area > max_area
            max_area = RegionProp(regionPropI).Area;
            rotation_angle = RegionProp(regionPropI).Orientation;
        end
    end
end