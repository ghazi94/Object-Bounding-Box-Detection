function[] = TV_Algorithm(originaImageString, mediumImageString, aspect_width, aspect_height, destination_file)
%     Blur the image a little bit to smoothen out the features
    disp('TV Algorithm is processing the image');
    [originalImage, ...
        ~, ...
        ~, ...
        ~, margins] = generate_image_set(originaImageString, ...
        mediumImageString, aspect_width, aspect_height);
%     [originalImage, ...
%         ~, ...
%         ~, ...
%         ~, margins] = generate_image_set('C:\Users\UserName\Desktop\DSC_3877.JPG', 'C:\Users\UserName\Desktop\DSC_3877.JPG', '4', '3');
%     destination_file = 'C:\Users\UserName\Desktop\out.JPG';
    % Detect the TV region
    selected_region = detect_tv(originalImage);
    if (~isempty(selected_region))
        % Find how much correctional rotation has to be made
        if (selected_region.Orientation > 79 && selected_region.Orientation < 90)
            rotated_image = rotate_with_whites(originalImage, 90 - selected_region.Orientation);
        elseif (selected_region.Orientation > 0 && selected_region.Orientation < 11)
            rotated_image = rotate_with_whites(originalImage, -1*selected_region.Orientation);
        else
            rotated_image = originalImage;
        end
        % Find the TV again in the rotated image
        selected_region = detect_tv(rotated_image);
        % Make a very very narrow crop for the television
        final_cropped_image = rotational_cropping(rotated_image, 0, selected_region.BoundingBox, margins, 'thin');
        % To make the backgroound even purer white, increase the brightness
%         final_cropped_image = imadjust(final_cropped_image, [0 1], [0.16 1]);
        imwrite(final_cropped_image, destination_file, 'jpg');
    end
    
    function[rotated_image] = rotate_with_whites(input_image, angle)
        rotated_image = imrotate(input_image,angle);
        Mrot = ~imrotate(true(size(input_image)),angle);
        rotated_image(Mrot&~imclearborder(Mrot)) = 255; 
    end
    
    function [selected_region] = detect_tv(image)
        blurredImage = imgaussfilt(image, 10);
        blackWhite = im2bw(blurredImage);
        regions = regionprops(bwconncomp(not(blackWhite)),'Area', 'Orientation', 'BoundingBox');
        max_area_region = [];
        for regionIndex = 1:length(regions)
           if(regionIndex == 1)
              max_area_region = regions(regionIndex);
           end
           if max_area_region.Area < regions(regionIndex).Area
               max_area_region = regions(regionIndex);
           end
        end
        selected_region = max_area_region;
    end
end