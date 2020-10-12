function [final_cropped_image] = rotational_cropping (originalImage, rotation_angle, bounding_box, margins, margin_type) 
%% Detects how much the image should be rotated and then returns the final rotated and cropped picture

% Variable used to signify a successful bounding_box found or not
aspectable_image = false;

% Original Image Width and Height
originalImageWidth = size(originalImage, 2);
originalImageHeight = size(originalImage, 1);
centerY = (originalImageHeight/2); centerX = (originalImageWidth/2);

% Original Image boundary points
[polygonXs, polygonYs] = extract_boundary_polygon(originalImage, 0);
originalPoly = horzcat(polygonXs, polygonYs);

% Safe Execution Check
exception_encountered = false;

% We run the cropping on rotated-image as well as non-rotated image (If
% rotational croppping is possible, it is kept, otherwise, original
% croppped image is kept (denoted by satisfactory_rotation)

% aspect_ratio
aspect_width = margins(1);
aspect_height = margins(2);
satisfactory_rotation = false;

try
    if ~(size(bounding_box, 2) > 3 && bounding_box(3) > 0 && bounding_box(4) > 0)
        throw(MException('rotational_cropping:inputError', 'Input does not have the expected format'));
    end
    if rotation_angle ~= 0
        % Generate coordinates for bounding box, rotate the points, and find new
        % maximal bounding box
        [imageBoundingBoxXs, imageBoundingBoxYs] = extract_clockwise_point_bb(bounding_box);
        [bb_x_rotated, bb_y_rotated] = rotate_points(centerX, centerY, imageBoundingBoxXs, imageBoundingBoxYs, rotation_angle);
        [bounding_box_new] = extract_maximal_bb(bb_x_rotated, bb_y_rotated);
        [bb_new_xs, bb_new_ys] = extract_clockwise_point_bb(bounding_box_new);
        [polygonXs, polygonYs] = extract_boundary_polygon(originalImage, rotation_angle);
        finalPoly = horzcat(polygonXs, polygonYs);
        finalBbPoints = horzcat(bb_new_xs', bb_new_ys');
        insidePolyCheck = inpoly(finalBbPoints, finalPoly);
        satisfactory_rotation = all(insidePolyCheck);
    end

    if rotation_angle == 0 || ~satisfactory_rotation
        rotation_angle = 0;
        bounding_box_new = bounding_box;
        [bb_new_xs, bb_new_ys] = extract_clockwise_point_bb(bounding_box_new);
        finalPoly = originalPoly;
        finalBbPoints = horzcat(bb_new_xs', bb_new_ys');
    end

    % Change bounding box to fit aspect ratio
    if (bounding_box(4) > bounding_box(3))
        % Increase width till aspect ratio is met
        bb_new_width_delta = ((aspect_width/aspect_height)*bounding_box_new(4)) - bounding_box_new(3);
        % Divide the extra width equally both the sides
        bounding_box_new_aspect = [(bounding_box_new(1) - bb_new_width_delta/2) bounding_box_new(2) (bounding_box_new(3) + bb_new_width_delta) bounding_box_new(4)];
        [bb_new_aspect_xs, bb_new_aspect_ys] = extract_clockwise_point_bb(bounding_box_new_aspect);
        finalBbAspectPoints = horzcat(bb_new_aspect_xs', bb_new_aspect_ys');
        insidePolyCheckAspect = inpoly(finalBbAspectPoints, finalPoly);
        aspectable_image = all(insidePolyCheckAspect);
    end

    if (bounding_box(3) > bounding_box(4))
        bounding_box_new_aspect = bounding_box_new;
        % Increase height till aspect ratio is met
        % This is different from increasing the width because height can be
        % increased in one direction, if the other has hit the boundary. The
        % concept of centering is only horizontal
        bb_new_height_delta = ((aspect_height/aspect_width)*bounding_box_new(3)) - bounding_box_new(4);
        expansion_steps = 60;
        [bounding_box_new_aspect, aspectable_image] = grow_height_smartly(bb_new_height_delta, expansion_steps, finalPoly, bounding_box_new_aspect);
    end
catch
   % Do nothing
   exception_encountered = true;
end

% Now, two scenarios remain --> Aspectable image was found and aspectable
% image was not found
if (aspectable_image || ~exception_encountered)
   [final_bounding_box, rotation_angle] = grow_bounding_box(originalImage, finalPoly, ...
       bounding_box_new_aspect, aspect_width, aspect_height, 1, rotation_angle, margin_type);
else
   if (exist(finalPoly, 'var') == 0)
       finalPoly = originalPoly;
   end
   rotation_angle = 0;
   [final_bounding_box, rotation_angle] = grow_bounding_box(originalImage, finalPoly, ...
       [0 0 0 0], aspect_width, aspect_height, 0, rotation_angle, margin_type);
end
rota_image = imrotate(originalImage, rotation_angle, 'crop');
final_cropped_image = imcrop(rota_image, final_bounding_box);
end