function [ boundBoxOriginClosestX, boundBoxOriginClosestY, boundingRectW, boundingRectY ] = super_boundingbox( Image, thresholds )
%Creates a bounding box around the detected objects using regionprops
%function

regionPropAreaThreshold = thresholds(1);
edgeVerticalProximity = thresholds(2);
edgeHorizontalProximity = thresholds(3);

resizedPictureWidth = size(Image, 2);
resizedPictureHeight = size(Image, 1);

% All measurements with a trasformed ordinate system where origin is as top
% left
boundBoxOriginClosestX = resizedPictureWidth;
boundBoxOriginClosestY= resizedPictureHeight;
boundBoxOriginFarthestX = 0;
boundBoxOriginFarthestY = 0;

% Divide regionprops areas by 8 point connected objects only
RegionProp = regionprops(bwconncomp(Image), 'BoundingBox', 'Area');
for regionPropI = 1:length(RegionProp)
    if RegionProp(regionPropI).Area > regionPropAreaThreshold
        %rectangle('Position', RegionProp(regionPropI).BoundingBox, 'EdgeColor', 'red');
        rectW = RegionProp(regionPropI).BoundingBox(3);
        rectH = RegionProp(regionPropI).BoundingBox(4);
        diagX1 = RegionProp(regionPropI).BoundingBox(1);
        diagY1 = RegionProp(regionPropI).BoundingBox(2);
        diagX2 = RegionProp(regionPropI).BoundingBox(1) + rectW;
        diagY2 = RegionProp(regionPropI).BoundingBox(2) + rectH;
        
        if (diagX1 > edgeHorizontalProximity) && (diagX1 < boundBoxOriginClosestX)
            boundBoxOriginClosestX = diagX1;
        end
        
        if (diagY1 > edgeVerticalProximity) && (diagY1 < boundBoxOriginClosestY)
            boundBoxOriginClosestY = diagY1;
        end
        
        virOrgX = resizedPictureWidth;
        virOrgY = resizedPictureHeight;
        
        if (virOrgX-diagX2) > edgeHorizontalProximity && ((virOrgX-diagX2) < (virOrgX - boundBoxOriginFarthestX))
            boundBoxOriginFarthestX = diagX2;
        end
        
        if (virOrgY - diagY2) > edgeVerticalProximity && ((virOrgY-diagY2) < (virOrgY - boundBoxOriginFarthestY))
            boundBoxOriginFarthestY = diagY2;
        end
    end
end
boundingRectW = boundBoxOriginFarthestX - boundBoxOriginClosestX;
boundingRectY = boundBoxOriginFarthestY - boundBoxOriginClosestY;
end

