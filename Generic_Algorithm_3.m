function [bounding_box, non_upscaled_bb, processed_binary] = Generic_Algorithm_3 (mediumResizedImage, mediumGrayScale, originalGrayScale, extra_properties)
%% This function implements the regular magic wand assisted separation algorithms %%
    tic;
    orgWidth = size(mediumResizedImage, 2);
    orgHeight = size(mediumResizedImage, 1);
    bottomXlist = 1 : ceil(orgWidth/5) : orgWidth - orgWidth/10;
    bottomYlist = zeros(size(bottomXlist)) + ceil((orgHeight - orgHeight/25));
    topXlist = bottomXlist;
    topYlist = zeros(size(topXlist)) + ceil(orgHeight/25);
    binaryMaskBottom = bin_mask(mediumResizedImage, 60, bottomYlist, bottomXlist);
    binaryMaskTop = bin_mask(mediumResizedImage, 50, topYlist, topXlist);
    topMaskInversion = (binaryMaskTop*0.5) + 0.5;
    bottomMaskInversion = (binaryMaskBottom*0.5) + 0.5;
    scalarAddition = topMaskInversion + bottomMaskInversion;
    invertedBlend = (scalarAddition - 1)*2;
    finalRaster = 1 - invertedBlend;
    erosion = strel('line', 20, 90);
    finalRaster = imerode(finalRaster, erosion);
    finalRaster = imclearborder(finalRaster, 4);
    regionPropAreaThreshold = extra_properties.RegionPropAreaThreshold;
    edgeVerticalProximity = 5;
    edgeHorizontalProximity = 5;
    thresholds = [regionPropAreaThreshold, edgeVerticalProximity, edgeHorizontalProximity];
    [boundBoxOriginClosestX, boundBoxOriginClosestY, boundingRectW, boundingRectH] = super_boundingbox(finalRaster, thresholds);
    bounding_box = [boundBoxOriginClosestX, boundBoxOriginClosestY, boundingRectW, boundingRectH];
    margins = [0, 0, 0, 0];
    non_upscaled_bb = bounding_box;
    bounding_box = Upscale_BoundingBox(bounding_box, mediumGrayScale, originalGrayScale, margins);
    processed_binary = finalRaster;
    elapsed = toc;
    disp(strcat('Algorithm 3 finished in: ', string(elapsed)));
end