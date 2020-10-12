function [bounding_box, non_upscaled_bb, processed_binary] = Generic_Algorithm_7 (mediumResizedImage, mediumGrayScale, originalGrayScale, extra_properties)
%% This function implements the composite masking algorithm %%
    tic;
    orgWidth = size(mediumResizedImage, 2);
    orgHeight = size(mediumResizedImage, 1);
    bottomXlist = 1 : ceil(orgWidth/5) : orgWidth - orgWidth/10;
    bottomYlist = zeros(size(bottomXlist)) + ceil((orgHeight - orgHeight/25));
    topXlist = bottomXlist;
    topYlist = zeros(size(topXlist)) + ceil(orgHeight/25);
    binaryMaskBottom = bin_mask(mediumResizedImage, 30, bottomYlist, bottomXlist);
    binaryMaskBottomFringe = edge(binaryMaskBottom,'canny');
    binaryMaskBottomFringe = imdilate(binaryMaskBottomFringe, strel('line', 36, 0));
    binaryMaskBottomFringe = imerode(binaryMaskBottomFringe, strel('line', 16, 90));
    binaryMaskBottomFringe = imclearborder(binaryMaskBottomFringe,4);
    regionPropAreaThreshold = extra_properties.RegionPropAreaThresholdAlgo7;
    edgeVerticalProximity = 10;
    edgeHorizontalProximity = 10;
    thresholds = [regionPropAreaThreshold, edgeVerticalProximity, edgeHorizontalProximity];
    [ boundBoxOriginClosestX, boundBoxOriginClosestY, boundingRectW, boundingRectH ] = super_boundingbox(binaryMaskBottomFringe, thresholds);
    boundBoxResizedFloor = [boundBoxOriginClosestX, boundBoxOriginClosestY, boundingRectW, boundingRectH];
    
    binaryMaskTop = bin_mask(mediumResizedImage, 25, topYlist, topXlist);
    binaryMaskTopFringe = edge(binaryMaskTop,'canny');
    binaryMaskTopFringe = imdilate(binaryMaskTopFringe, strel('line', 45, 0));
    binaryMaskTopFringe = imerode(binaryMaskTopFringe, strel('line', 24, 90));
    binaryMaskTopFringe = imclearborder(binaryMaskTopFringe,4);
        
    if boundingRectW > 0 && boundingRectH > 0
        regionPropAreaThreshold = 600;
        edgeVerticalProximity = 20;
        edgeHorizontalProximity = 100;
        thresholds = [regionPropAreaThreshold, edgeVerticalProximity, edgeHorizontalProximity];
        [ boundBoxOriginClosestX, boundBoxOriginClosestY, boundingRectW, boundingRectH ] = super_boundingbox(binaryMaskTopFringe, thresholds);
        boundBoxResizedCeiling = [boundBoxOriginClosestX, boundBoxOriginClosestY, boundingRectW, boundingRectH];
        algorithmCompensation = 35;
        heightDifference = abs(boundBoxResizedFloor(2) - boundBoxResizedCeiling(2)) + algorithmCompensation;
        newBoundingBoxHeight = boundBoxResizedFloor(4) + heightDifference;
        bounding_box = [boundBoxResizedFloor(1), boundBoxResizedFloor(2) - heightDifference, boundBoxResizedFloor(3), newBoundingBoxHeight];
        margins = [0, 0, 0, 0];
        non_upscaled_bb = bounding_box;
        bounding_box = Upscale_BoundingBox(bounding_box, mediumGrayScale, originalGrayScale, margins);
    else
        bounding_box = [0, 0, 0, 0];
        non_upscaled_bb = bounding_box;
    end
    processed_binary = binaryMaskTopFringe + binaryMaskBottomFringe;
    elapsed = toc;
    disp(strcat('Algorithm 7 finished in: ', string(elapsed)));
end