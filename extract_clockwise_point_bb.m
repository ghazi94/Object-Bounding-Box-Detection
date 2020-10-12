function [x_set, y_set] = extract_clockwise_point_bb(bounding_box)
    bbUpperLeftX = bounding_box(1); 
    bbUpperLeftY = bounding_box(2);
    bbWidth = bounding_box(3);
    bbHeight = bounding_box(4);
    bbLowerLeftX = bbUpperLeftX;
    bbLowerLeftY = bbUpperLeftY + bbHeight;
    bbUpperRightX = bbUpperLeftX + bbWidth;
    bbUpperRightY = bbUpperLeftY;
    bbLowerRightX = bbUpperRightX;
    bbLowerRightY = bbLowerLeftY;
    x_set = [bbUpperLeftX, bbUpperRightX, bbLowerRightX, bbLowerLeftX];
    y_set = [bbUpperLeftY, bbUpperRightY, bbLowerRightY, bbLowerLeftY];
end