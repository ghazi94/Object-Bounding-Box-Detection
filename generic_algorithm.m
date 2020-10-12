function [success] = generic_algorithm(originaImageString, mediumImageString, aspect_width, aspect_height, destination_file)
    disp('Generic algorithm is processing the image');
    [originalImage, ...
        mediumOriginalImage, ...
        originalGrayScale, ...
        mediumGrayScale, margins] = generate_image_set(originaImageString, ...
        mediumImageString, aspect_width, aspect_height);
    extra_properties = struct('RegionPropAreaThreshold', 400, 'RegionPropAreaThresholdAlgo7', 600, 'RegionPropAreaThresholdAlgo8', 600);
    % Start the processing
    algorithmBaseString = 'Generic_Algorithm_';
    numberOfAlgos = 8;
%     rotation_array = zeros(1, numberOfAlgos);
    algoProcHolder = cell(numberOfAlgos, 4);
    for algoNum = 1 : numberOfAlgos
       algo = str2func(strcat(algorithmBaseString, num2str(algoNum)));
       [bounding_box, non_upscaled_bb, processed_binary] = algo(mediumOriginalImage, mediumGrayScale, originalGrayScale, extra_properties);
       if bounding_box(3) > 0 && bounding_box(4) > 0
           algoProcHolder{algoNum, 1} = bounding_box;
           algoProcHolder{algoNum, 2} = non_upscaled_bb;
           algoProcHolder{algoNum, 3} = processed_binary;
%            rotation_array(1, algoNum) = regionprops_rota_detect(processed_binary);
       else
           algoProcHolder{algoNum, 1} = 0;
       end
    end
    
    % Detect the best image out of the lot
    tic;
    [chosen_index, best_selected_image] = best_algorithm_detector(algoProcHolder, numberOfAlgos, originalImage);
    elapsed = toc;
    disp(strcat('Best algorithm image output detection finished in: ', string(elapsed)));
%     figure;
%     for best_pic = 1:8
%         subplot(4,2,best_pic);
%         try
%             imshow(algoProcHolder{best_pic, 3});
%             rectangle('Position', algoProcHolder{best_pic, 2}, 'EdgeColor', 'red');
%         catch
%         end
% %         display(num2str(rotation_array(1, best_pic)));
%         if chosen_index == best_pic
%             title('Chosen');
% % %                display(strcat('Chosen rotation: ', num2str(rotation_array(1, algoNum))));
%         end
%     end
%     figure;
%     imshow(originalImage);
%     rectangle('Position', algoProcHolder{chosen_index, 1}, 'EdgeColor', 'red');
      tic;
      final_rotation_angle = rotation_module(mediumOriginalImage);
      elapsed = toc;
      disp(strcat('Best rotation angle detection finished in: ', string(elapsed)));
%     display(rotation_array);
%     display(num2str(final_rotation_angle));
%     prompt = 'Press enter to continue:';
%     input(prompt);

    % Do the rotational cropping in the safest way possible
    % --------------------------------------------------------------------------------------------------
    bounding_box = algoProcHolder{chosen_index, 1};
    % Fully exception handled call. Obtaining an image is guaranteed
    tic;
    final_cropped_image = rotational_cropping(originalImage, final_rotation_angle, bounding_box, margins, 'normal');
    % Increase the brightness a little for darker images
%     if (mean2(im2bw(originalImage)) < 0.92)
%         final_cropped_image = imadjust(final_cropped_image, [0 1], [0.15 1]);
%     else
%         final_cropped_image = imadjust(final_cropped_image, [0 1], [0.2 1]);
%     end
    elapsed = toc;
    disp(strcat('Rotation cropping finshed in: ', string(elapsed)));
    % final_cropped_image = auto_enhance(final_cropped_image);
    imwrite(final_cropped_image, destination_file, 'jpg');
    success = true;
end