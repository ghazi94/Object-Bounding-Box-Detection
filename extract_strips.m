function [] = extract_strips(originalImage, position, saveDestination, horizontalDivisor)
    [objectXs, objectYs] = extract_clockwise_point_bb(position);
    analysedImage = rgb2gray(originalImage);
    % Row count is height (1 is the dimension along rows)
    imageRowsAliasHeight = size(analysedImage, 1);
    % Column count is width (2 is the dimension along columns)
    imageColumnsAliasWidth = size(analysedImage, 2);
    
%     figure;
%     imshow(originalImage);
%     draw_points([objectXs', objectYs'], originalImage, 'r+');
    
    % Scanner moves along columns (horizontally)
    horizontalScanDelta = floor(imageColumnsAliasWidth/horizontalDivisor);

    % Do horizontal white pixel scans along a vertical column
    % horizontalScanWidth denotes the continously increasing scan width
    horizontalScanWidth = horizontalScanDelta;
    scanCount = 0;
    while horizontalScanWidth < imageColumnsAliasWidth
        scanCount = scanCount + 1;
        startWidth = horizontalScanWidth - horizontalScanDelta + 1;
        if horizontalScanWidth == horizontalScanDelta
            startWidth = 1;
        end
        submatrix = analysedImage(1:imageRowsAliasHeight, startWidth : horizontalScanWidth);
        if (horizontalScanWidth < objectXs(1) || (horizontalScanWidth - horizontalScanDelta) > objectXs(3))
            imwrite(submatrix, strcat(saveDestination,'_',num2str(scanCount), '.jpg'), 'jpg');
        end
        horizontalScanWidth = horizontalScanWidth + horizontalScanDelta;
    end
end