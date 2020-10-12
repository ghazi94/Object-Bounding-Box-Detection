function[logical] = zone_check(image, pointSet, type)
    logical = false;
    % Checks whether a given set of points lie within a particular zone or not
    % type determines, whether the points are 'bb_center' or 'wall_edge'
    if (strcmp(type, 'bb_center'))
        reference_scale_width = 6000;
        reference_scale_height = 4000;
        reference_scale_bb = [2100 1000 2000 1900];
    end
    if (strcmp(type, 'wall_edge'))
        reference_scale_width = 2248;
        reference_scale_height = 1500;
        reference_scale_bb = [494.4 192.5 1228.1 1164];
    end
    imageWidth = size(image, 2);
    imageHeight = size(image, 1);
    ratio_x = (imageWidth/reference_scale_width);
    ratio_y = (imageHeight/reference_scale_height);
    current_scale_bb = [reference_scale_bb(1,1)*ratio_x ...
        reference_scale_bb(1,2)*ratio_y ...
        reference_scale_bb(1,3)*ratio_x ...
        reference_scale_bb(1,4)*ratio_y];
%     delta_width = reference_scale_bb(1,3) - expected_bb_width;
%     delta_height = reference_scale_bb(1,4) - expected_bb_height;
%     current_scale_bb = [reference_scale_bb(1,1) - delta_width/2 ...
%         reference_scale_bb(1,2) - delta_height/2 ...
%         reference_scale_bb(1,3) + delta_width/2 ...
%         reference_scale_bb(1,4) + delta_height/2];
    % Check whether the given points lie inside this zone or not
    [current_scale_bb_xs, current_scale_bb_ys] = extract_clockwise_point_bb(current_scale_bb);
    current_bb_boundary = horzcat(current_scale_bb_xs', current_scale_bb_ys');
    pointInPolyCheck = inpoly(pointSet, current_bb_boundary);
    logical = all(pointInPolyCheck);
end