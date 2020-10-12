function [rotation_angle] = rotation_module(image)
%% An advanced module to compute rotational correction of primary object in an image
%% Makes use of wall and floor edge detection
    vertical_line_length_thresh = 180/2000;
    horizontal_line_length_thresh = 240/3000;
    
    % How close a horizontal floor line should be detected to a wall
    ver_x_edge_threshold = 300/1500;

    verticalTolerableTheta = 10;
    horizontalTolerableThetha = 10;
       
    % Rotation Rule Chart
    % MATLAB rotates positive angles as CCW
    % MATLAB rotates negative angles as CW
    
    % General Line Rules
    % L->R, Pointing Up, Z = abs(90 - abs(theta)), -Z
    % L->R, Pointind Down, Z = abs(90 - abs(theta)), Z
    % R->L, Pointing Up, Z = abs(theta), Z
    % R->L, Pointing Down, Z = abs(theta), -Z (Inferred) 
    
%     imageArray = {'_DSC0394.JPG', 'DSC_7510.JPG', 'DSC_5481.JPG', 'DSC_5480.JPG', 'DSC_5464.JPG', 'DSC_1144.JPG', 'DSC_1145.JPG', 'DSC_9834.JPG', 'DSC_3877.JPG'};
%     desktop = 'C:\Users\UserName\Desktop\';

%     for i = 1 : size(imageArray, 2)
%         image = imread(strcat(desktop, imageArray{i}));
%         [x_filtered_bw, y_filtered_bw] = floor_wall_enhance_preproc(image);
%         [XverticalHoughLines, XhorizontalHoughLines] = detect_lines(x_filtered_bw, vertical_line_length_thresh, horizontal_line_length_thresh);
%         [YverticalHoughLines, YhorizontalHoughLines] = detect_lines(y_filtered_bw, vertical_line_length_thresh, horizontal_line_length_thresh);
% %         three_plot_display(image, x_filtered_bw, y_filtered_bw, XverticalHoughLines, XhorizontalHoughLines, YverticalHoughLines, YhorizontalHoughLines);
% %         disp('--------------------------------------Image Finished ^----------------------------------------------');
%         rotation_angle = determine_rotation(image, x_filtered_bw,  y_filtered_bw, XverticalHoughLines, XhorizontalHoughLines, YverticalHoughLines, YhorizontalHoughLines);
%     end
    [x_filtered_bw, y_filtered_bw] = floor_wall_enhance_preproc(image);
    [XverticalHoughLines, XhorizontalHoughLines] = detect_lines(x_filtered_bw, vertical_line_length_thresh, horizontal_line_length_thresh);
    [YverticalHoughLines, YhorizontalHoughLines] = detect_lines(y_filtered_bw, vertical_line_length_thresh, horizontal_line_length_thresh);
    rotation_angle = determine_rotation(image, x_filtered_bw,  y_filtered_bw, XverticalHoughLines, XhorizontalHoughLines, YverticalHoughLines, YhorizontalHoughLines);
    function [rotation_angle] = determine_rotation(image, x_filtered_bw, y_filtered_bw, XverticalHoughLines, XhorizontalHoughLines, YverticalHoughLines, YhorizontalHoughLines)
        rotation_angle = 0;
        centerX = size(x_filtered_bw);
        centerY = size(y_filtered_bw);
        [vertically_seived_lines, vertical_score_matrix] = filter_vertical_lines(image, XverticalHoughLines);
        [horizontall_seived_lines, horizontal_score_matrix] = filter_horizontal_lines(image, YhorizontalHoughLines);
        % Case 1 -> Ony horizontal lines are present (Wall guided
        % correction)
        if (size(vertically_seived_lines,1) == 0 && size(horizontall_seived_lines,1) ~= 0)
            % Rotation angle gets computed by bottom lines itself
            % Find the longest line, and use its angle to correct the
            % rotation
            longest_hor_line = [];
            for line_index = 1 : size(horizontall_seived_lines,1)
                if (line_index == 1)
                    longest_hor_line = horizontall_seived_lines(line_index);
                end
                if (compute_line_length(longest_hor_line) ...
                        < compute_line_length(horizontall_seived_lines(line_index)))
                    longest_hor_line = horizontall_seived_lines(line_index);
                end
            end
            % Avoid wild rotations
            if (abs(90 - abs(longest_hor_line.theta)) < 3)
                rotation_angle = longest_hor_line.theta - 90;
                % Make sure opposite signs don't make the rotation wild
                if (abs(rotation_angle) > 3)
                    rotation_angle = 0;
                end
            end
%             three_plot_display(image, x_filtered_bw, y_filtered_bw, XverticalHoughLines, XhorizontalHoughLines, YverticalHoughLines, YhorizontalHoughLines);
        else
        % Case 2 -> Vertical Dividers are present
            % Check for partitioned presence of lines
            % Case 2a
            % Two partitioned dividers on the two sides of the center of the
            % image
            % Case 2b
            % Single partition divider is present
        end
    end

    function [vertically_seived_lines, verticalScoreMatrix] = filter_vertical_lines(image, XverticalHoughLines)
        vertically_seived_lines = [];
        verticalScoreMatrix = [];
        for iterV = 1 : size(XverticalHoughLines,2)
            if ((abs(XverticalHoughLines(1,iterV).theta) < (verticalTolerableTheta+1)) && ...
                    ~zone_check(image,...
                    [...
                        [XverticalHoughLines(1,iterV).point1(1,1) XverticalHoughLines(1,iterV).point2(1,1)]' ...
                        [XverticalHoughLines(1,iterV).point1(1,2) XverticalHoughLines(1,iterV).point2(1,2)]' ...
                    ], ...
                    'wall_edge'))
                vertically_seived_lines = [vertically_seived_lines;XverticalHoughLines(1,iterV)];
                verticalScoreMatrix = [verticalScoreMatrix;compute_line_score(image, XverticalHoughLines(1,iterV), 'wall')];
            end
        end
    end

    function [horizontally_seived_lines, horizontalScoreMatrix] = filter_horizontal_lines(image, YhorizontalHoughLines)
        horizontally_seived_lines = [];
        horizontalScoreMatrix = [];
        ver_x_proximity_barrier = ver_x_edge_threshold*size(image,1);
        for iterH = 1 : size(YhorizontalHoughLines,2)
            if (abs(abs(YhorizontalHoughLines(1,iterH).theta) - 90) < (horizontalTolerableThetha+1))
                % Lines should roughly lie along the middle
                if ~((abs(YhorizontalHoughLines(1,iterH).point1(1,2) - size(image,1)) < ver_x_proximity_barrier) ...
                        || (abs(YhorizontalHoughLines(1,iterH).point2(1,2) - size(image,1)) < ver_x_proximity_barrier) ...
                        || (YhorizontalHoughLines(1,iterH).point1(1,2) < ver_x_proximity_barrier) ...
                        || (YhorizontalHoughLines(1,iterH).point2(1,2) < ver_x_proximity_barrier))
                    horizontally_seived_lines = [horizontally_seived_lines;YhorizontalHoughLines(1,iterH)];
                end
%                 horizontalScoreMatrix = [horizontalScoreMatrix;compute_line_score(image, YhorizontalHoughLines(1,iterH), 'floor')];
            end
        end
    end
    
    function[length] = compute_line_length(houghLine)
        length = norm(houghLine.point1 - houghLine.point2);
    end

    function [final_score] = compute_line_score(image, houghLine, type)
        % Check line length
        final_score = norm(houghLine.point1 - houghLine.point2);
        imageWidth = size(image,2);
        % Check line proximity to the boundary (the closest
        if (strcmp(type, 'wall'))
            valuable_proximity = (houghLine.point1(1,2) + houghLine.point2(1,2))/2;
            final_score = final_score/valuable_proximity;
        elseif (strcmp(type, 'floor'))
            % For horizontal lines, the longer the line, better the
            % accuracy
%             midXpoint = (houghLine.point1(1,1) + houghLine.point2(1,1))/2;
%             if (midXpoint > imageWidth/2)
%                 valuable_proximity = abs(imageWidth - midXpoint);
%             else
%                 valuable_proximity = midXpoint;
%             end
%             final_score = final_score/valuable_proximity;
        end
    end

    function [logicalVal] = point_side_with_line(houghLine, pointX, pointY)
        X1 = houghLine.point1(1,1);
        Y1 = houghLine.point1(1,2);
        X2 = houghLine.point2(1,1);
        Y2 = houghLine.point2(1,2);
        logicalVal (pointX-X1)*(Y2-Y1)-(pointY-Y1)*(X2-X1);
    end

    function [x_filtered_bw, y_filtered_bw] = floor_wall_enhance_preproc(rgbImage)
        blurredImage = imgaussfilt(rgbImage,14);
        grayscale = rgb2gray(blurredImage);
        [Gx, Gy] = imgradientxy(grayscale, 'Sobel');
        resultGx = imclearborder(Gx);
        resultGy = imclearborder(Gy);
        resultGxsub = Gx - resultGx;
        resultGysub = Gy - resultGy;
        resultGxsub = im2bw(resultGxsub);
        resultGysub = im2bw(resultGysub);
        se0 = strel('line', 4, 0);
        se90 = strel('line', 4, 90);
        resultGxSubErode = imerode(resultGxsub, se0);
        resultGySubErode = imerode(resultGysub, se90);
        sediamond = strel('diamond',8);
        resultGxSubErodeDilate = imdilate(resultGxSubErode, sediamond);
        resultGySubErodeDilate = imdilate(resultGySubErode, sediamond);

        % Finally assign them back for output
        x_filtered_bw = resultGxSubErodeDilate;
        y_filtered_bw = resultGySubErodeDilate;
    end
    function [verticalHoughLines, horizontalHoughLines] = detect_lines(input_image, vertical_line_length_thresh, horizontal_line_length_thresh)
        % % % Thresholds
        imageHeight = size(input_image, 1);
        imageWidth = size(input_image, 2);
        % METHOD -1 ----------------------------------------------- %
        % Apply Haar Wavelet Filter for Filtering out vertical edges
        intImage = integralImage(input_image);
        horiH = integralKernel([1 1 4 3; 1 4 4 3],[-1, 1]);
        vertH = horiH.';
        vertResponse = integralFilter(intImage,vertH);
        horzResponse = integralFilter(intImage,horiH);

        % Apply hough transform on verticalResponse to detect lines
        verticalHoughLines = generate_hough_lines(vertResponse, vertical_line_length_thresh*imageHeight);
        horizontalHoughLines = generate_hough_lines(horzResponse, horizontal_line_length_thresh*imageWidth);
    end
    function [houghLines] = generate_hough_lines(vertResponse, minLength)
        [HoughP,Theta,Rho] = hough(vertResponse);
        HoughPeaks  = houghpeaks(HoughP,5,'threshold',ceil(0.3*max(HoughP(:))));
        XHP = Theta(HoughPeaks(:,2)); YHP = Rho(HoughPeaks(:,1));
        houghLines = houghlines(vertResponse,Theta,Rho,HoughPeaks,'FillGap',5,'MinLength',minLength);
    end
    function [] = display_lines(verticalHoughLines, horizontalHoughLines)
        hold on;
        for k = 1:length(verticalHoughLines)
           len = norm(verticalHoughLines(k).point1 - verticalHoughLines(k).point2);
               xy = [verticalHoughLines(k).point1; verticalHoughLines(k).point2];
               plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
               %%%%%
               theta = verticalHoughLines(k).theta;
%                display(xy(:,1)), display(xy(:,2));
               display(strcat('k-ver: ',num2str(k), ' len: ', num2str(len), ' theta: ' ,num2str(theta)));
               texti = text((xy(1,1) + xy(2,1))/2, (xy(1,2) + xy(2,2))/2, num2str(k));
               texti.Color = 'blue';
               %%%%%
               % Plot beginnings and ends of lines
               plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','blue');
               plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','yellow');
        end
        disp('------------------------------------------------------------------------------');
        for k = 1:length(horizontalHoughLines)
           len = norm(horizontalHoughLines(k).point1 - horizontalHoughLines(k).point2);
               xy = [horizontalHoughLines(k).point1; horizontalHoughLines(k).point2];
               plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','red');
               %%%%%
               theta = horizontalHoughLines(k).theta;
%                display(xy(:,1)), display(xy(:,2));
               display(strcat('k-hor: ',num2str(k), ' len: ', num2str(len), ' theta: ' ,num2str(theta)));
               texti = text((xy(1,1) + xy(2,1))/2, (xy(1,2) + xy(2,2))/2, num2str(k));
               texti.Color = 'blue';
               %%%%%
               % Plot beginnings and ends of lines
               plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','blue');
               plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','yellow');
        end
        hold off;
    end
    function [] = three_plot_display(originalImage, final_x_bw, final_y_bw, XverticalHoughLines, XhorizontalHoughLines, YverticalHoughLines, YhorizontalHoughLines)
        figure;
        subplot(2,2,1);
        imshow(originalImage);
        subplot(2,2,2);
        imshow(final_x_bw), title('x_bw');
        display_lines(XverticalHoughLines, XhorizontalHoughLines);
        subplot(2,2,3);
        imshow(final_y_bw), title('y_bw');
        display_lines(YverticalHoughLines, YhorizontalHoughLines);
    end
end