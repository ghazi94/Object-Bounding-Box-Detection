function[final_bounding_box, rotation_angle] = grow_bounding_box(originalImage, finalPoly, bounding_box, ...
    aspect_width, aspect_height, constrained, rotation_angle, margin_type)
   %% Advanced side based check - expansion with subsequent cropping to be done here
   % Safe execution check
   % !! Whole code is written on the assumption that the passed
   % bounding_box is already in the perfect aspect ratio for constrained ==
   % 1
   % Also critical to the assumption is that aspect_width > aspect_height
   % For cases where you want the aspect_height > aspect_width, kindly
   % reverse them
   
   exception_encountered = false;
   if (constrained == 1)
%        try
        originalImageWidth = size(originalImage, 2);
        originalImageHeight = size(originalImage, 1);
        if strcmp(margin_type, 'thin')
            maxWidthDeltaStrip = ([1/20 1/19 1/18 1/17 1/16 1/15 1/14 1/13 1/12])*bounding_box(3);
        else
            maxWidthDeltaStrip = ([1/5 1/5.1 1/5.2 1/5.5 1/5.7 1/5.9 1/6.3 1/6.7 1/7 1/8 1/9 1/10 ...
                1/11 1/12 1/13 1/14 1/15 1/16])*bounding_box(3);
        end
        expansion_steps = 30;
        heightAdjustSuccess = false;
        for i = 1 : size(maxWidthDeltaStrip,2)
            wdelta = maxWidthDeltaStrip(1,i);
            % Expand horizontally
            bounding_box_current = [(bounding_box(1) - wdelta/2) bounding_box(2) (bounding_box(3) + wdelta) bounding_box(4)];
            if (~check_in_poly(finalPoly, bounding_box_current))
                continue;
            else
               hdelta = (aspect_height/aspect_width)*bounding_box_current(3) - bounding_box_current(4);
               [bounding_box_current, heightAdjustSuccess] = grow_height_smartly(hdelta, expansion_steps, ...
                   finalPoly, bounding_box_current);
               if (heightAdjustSuccess)
                  break; 
               else
                  continue;
               end
            end
        end
%        catch
%            % Do nothing
%            exception_encountered = true;
%        end
       % End of catch statement
   end
   % End of if statement
   if (constrained == 0 || ~heightAdjustSuccess || exception_encountered)
       rotation_angle = 0;
       % Discard all attemps to fit a box
       % Crop out the original image width to fit the aspect ratio
       requiredWidth = originalImageHeight*(aspect_width/aspect_height);
       requiredHeight = originalImageWidth*(aspect_height/aspect_width);
       if (originalImageWidth > requiredWidth)
           % Shorten the width to fit the aspect ratio
           forceWDelta = originalImageWidth - requiredWidth;
           bounding_box_current = [forceWDelta/2 0 originalImageWidth-forceWDelta/2 originalImageHeight];
       else
           % Shorten the height to fit the aspect ratio
           forceHDelta = originalImageHeight - requiredHeight;
           bounding_box_current = [0 forceHDelta/2 originalImageWidth originalImageHeight - forceHDelta/2];
       end
   end
   final_bounding_box = bounding_box_current;
end