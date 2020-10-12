function [bounding_box, non_upscaled_bb, processed_binary] = Generic_Algorithm_6 (mediumResizedImage, mediumGrayScale, originalGrayScale, extra_properties)
%% This function implements the regular magic wand assisted separation algorithm %%
    tic;
    BWcanny = edge(mediumGrayScale,'canny');
    se0 = strel('line', 6, 0);
    preprocessedImage = BWcanny;
    preprocessedImage = imdilate(preprocessedImage, se0);
    preprocessedImage = imerode(preprocessedImage,strel('line', 6, 90));
    preprocessedImage = imdilate(preprocessedImage, strel('line', 12, 90));
    preprocessedImage = imclearborder(preprocessedImage, 4);
    preprocessedImage = imdilate(preprocessedImage, strel('line', 4, 0));
    regionPropAreaThreshold = extra_properties.RegionPropAreaThreshold;
    edgeVerticalProximity = 5;
    edgeHorizontalProximity = 5;
    thresholds = [regionPropAreaThreshold, edgeVerticalProximity, edgeHorizontalProximity];
    [boundBoxOriginClosestX, boundBoxOriginClosestY, boundingRectW, boundingRectH] = super_boundingbox(preprocessedImage, thresholds);
    if boundingRectW > 0 && boundingRectH > 0
        boundBoxResized = [boundBoxOriginClosestX, boundBoxOriginClosestY, boundingRectW, boundingRectH];
        margins = [0, 0, 0, 0];
        non_upscaled_bb = boundBoxResized;
        bounding_box = Upscale_BoundingBox(boundBoxResized, mediumGrayScale, originalGrayScale, margins);
    else
        bounding_box = [0, 0, 0, 0];
        non_upscaled_bb = bounding_box;
    end
    processed_binary = preprocessedImage;
    elapsed = toc;
    disp(strcat('Algorithm 6 finished in: ', string(elapsed)));
end