function [rotated_x, rotated_y] = rotate_points(centerX, centerY, inputX, inputY, angleInDegree)
    rotated_x = zeros(size(inputX, 2), 1);
    rotated_y = zeros(size(inputX, 2), 1);
    for iter=1:size(inputX, 2)
        apparentX = centerX - inputX(iter);
        apparentY = centerY - inputY(iter);
        apparentAngle = atan2d(apparentY, apparentX);
        apparentRadius = sqrt(apparentX^2 + apparentY^2);
        newAngle = apparentAngle - angleInDegree;
        rotated_x(iter) = centerX - apparentRadius*cosd(newAngle);
        rotated_y(iter) = centerY - apparentRadius*sind(newAngle);
    end
end