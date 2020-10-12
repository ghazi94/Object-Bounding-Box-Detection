function [x_set, y_set] = extract_boundary_polygon(originalImage, rotationAngle)
    height = size(originalImage, 1);
    width = size(originalImage, 2);
    x_set = zeros(8, 1);
    y_set = zeros(8, 1);
    if rotationAngle < 0
        % Extract the four corners along with the 30 degree intersection

        % 0, h/2 30 degree to (x, 0)
        x_set(1) = -1*((height/2 - 0)*tand(rotationAngle));
        y_set(1) = 0;

        % w/2, 0
        x_set(2) = width/2;
        y_set(2) = 0;

        % w/2, 0 30 degree to (w, y)
        x_set(3) = width;
        y_set(3) = (width/2 - width)*tand(rotationAngle);
        
        % w, h/2
        x_set(4) = width;
        y_set(4) = height/2;
        
        % w, h/2 30 degree to (x, h)
        x_set(5) = -1*((height/2 - height)*tand(rotationAngle) - width);
        y_set(5) = height;
        
        % w/2, h
        x_set(6) = width/2;
        y_set(6) = height;
        
        % w/2, h 30 degree to (0, y)
        x_set(7) = 0;
        y_set(7) = (width/2)*tand(rotationAngle) + height;
        
        % 0, h/2
        x_set(8) = 0;
        y_set(8) = height/2;
    elseif rotationAngle > 0
        % Extract the four corners along with the 30 degree intersection

        % w/2, 0
        x_set(1) = width/2;
        y_set(1) = 0;

        % w, h/2 30 degree to (x, 0)
        x_set(2) = width - tand(rotationAngle)*height/2;
        y_set(2) = 0;
        
        % w, h/2
        x_set(3) = width;
        y_set(3) = height/2;
        
        % w/2, h 30 degree to (w, y)
        x_set(4) = width;
        y_set(4) = height - tand(rotationAngle)*width/2;
        
        % w/2, h
        x_set(5) = width/2;
        y_set(5) = height;
        
        % 0, h/2 30 degree to (x, h)
        x_set(6) = height/2*tand(rotationAngle);
        y_set(6) = height;
        
        % 0, h/2
        x_set(7) = 0;
        y_set(7) = height/2;
        
        % w/2, 0 30 degree to (0, y)
        x_set(8) = 0;
        y_set(8) = (width - width/2)*tand(rotationAngle);
    else
        x_set(1) = 0;
        y_set(1) = 0;

        x_set(2) = width/2;
        y_set(2) = 0;

        x_set(3) = width;
        y_set(3) = 0;
        
        x_set(4) = width;
        y_set(4) = height/2;
        
        x_set(5) = width;
        y_set(5) = height;
        
        x_set(6) = width/2;
        y_set(6) = height;
        
        x_set(7) = 0;
        y_set(7) = height;
        
        x_set(8) = 0;
        y_set(8) = height/2;
    end
end