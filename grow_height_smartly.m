function [bounding_box_new_aspect, aspectable_image] = grow_height_smartly(bb_new_height_delta, expansion_steps, finalPoly, bounding_box_new_aspect)
%% Grows height intelligently by sliding the bounding box up or down
topInPoly = true;
bottomInPoly = true;
sub_delta = bb_new_height_delta/expansion_steps;

% Start allocating delta to both top and bottom
while (bb_new_height_delta > 0) && (topInPoly || bottomInPoly)
    if (topInPoly)
       % Expand the top part and subtract it from bb_new_height_delta
        bounding_box_new_aspect = [bounding_box_new_aspect(1) (bounding_box_new_aspect(2) - sub_delta) bounding_box_new_aspect(3) (bounding_box_new_aspect(4) + sub_delta)];
        [bb_new_aspect_xs, bb_new_aspect_ys] = extract_clockwise_point_bb(bounding_box_new_aspect);
        finalBbAspectPoints = horzcat(bb_new_aspect_xs', bb_new_aspect_ys');
        insidePolyCheckAspect = inpoly(finalBbAspectPoints, finalPoly);
        upperLayerPolyPoints = insidePolyCheckAspect(1:floor(size(insidePolyCheckAspect,1)/2));
        topInPoly = all(upperLayerPolyPoints);
        bb_new_height_delta = bb_new_height_delta - sub_delta;
    end

    if (bottomInPoly)
        final_delta = sub_delta;
        % Expand the top part and subtract it from bb_new_height_delta
        bounding_box_new_aspect = [bounding_box_new_aspect(1) bounding_box_new_aspect(2) bounding_box_new_aspect(3) (bounding_box_new_aspect(4) + final_delta)];
        [bb_new_aspect_xs, bb_new_aspect_ys] = extract_clockwise_point_bb(bounding_box_new_aspect);
        finalBbAspectPoints = horzcat(bb_new_aspect_xs', bb_new_aspect_ys');
        insidePolyCheckAspect = inpoly(finalBbAspectPoints, finalPoly);
        bottomLayerPolyPoints = insidePolyCheckAspect((floor(size(insidePolyCheckAspect,1)/2) + 1):size(insidePolyCheckAspect,1));
        bottomInPoly = all(bottomLayerPolyPoints);
        bb_new_height_delta = bb_new_height_delta - final_delta;
    end
end
if ~topInPoly
    % Retrace back one step
    bounding_box_new_aspect = [bounding_box_new_aspect(1) (bounding_box_new_aspect(2) + sub_delta) bounding_box_new_aspect(3) (bounding_box_new_aspect(4) - sub_delta)];
end
if ~bottomInPoly
    % Retrace back one step
    bounding_box_new_aspect = [bounding_box_new_aspect(1) bounding_box_new_aspect(2) bounding_box_new_aspect(3) (bounding_box_new_aspect(4) - sub_delta)];
end

if bb_new_height_delta <= 0
    aspectable_image = true;
else
    aspectable_image = false;
end
end