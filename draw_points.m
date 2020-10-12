function [null] = draw_points (pointSet, originalImage, color)
    rows = size(pointSet, 1);
    height = size(originalImage, 1);
    width = size(originalImage, 2);
    hold on;
    for row = 1 : rows
        xcor = pointSet(row, 1);
        ycor = pointSet(row, 2);
        if xcor == 0
            xcor = xcor + 2;
        end
        if xcor == width
            xcor = xcor -2;
        end
        if ycor == 0
            ycor = ycor + 2;
        end
        if ycor == height
            ycor = ycor -2;
        end
        plot(xcor, ycor, color);
    end
    hold off;
end