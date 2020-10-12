function [final_index, leastNoisyImage] = best_algorithm_detector (algoProcHolder, numberOfAlgos, originalImage)
    scores = zeros(numberOfAlgos,1);
    current_noise = -1;
    % Bounding box centers are stored here
    CenterXBB = zeros(numberOfAlgos, 1);
    % Pre-processor
    for algoNum = 1 : numberOfAlgos
        if algoProcHolder{algoNum, 1} ~= 0
            non_upscaled_bb = algoProcHolder{algoNum, 2};
            processed_binary = algoProcHolder{algoNum, 3};
            
            edgeHProximityLimit = size(processed_binary,2)/20;
            edgeVProximityLimit = size(processed_binary,1)/14;
            % The bounding box should not be too close to the edges
            HCheck1 = non_upscaled_bb(1) < edgeHProximityLimit;
            HCheck2 = (size(processed_binary,2) - (non_upscaled_bb(1) + non_upscaled_bb(3))) < edgeHProximityLimit;
            if (HCheck1 || HCheck2)
                edgeProximityCheck = -10;
            else
                edgeProximityCheck = 0;
            end
            
            VCheck1 = non_upscaled_bb(2) < edgeVProximityLimit;
            VCheck2 = (size(processed_binary,1) - (non_upscaled_bb(2) + non_upscaled_bb(4))) < edgeVProximityLimit;
            if (VCheck1 || VCheck2)
                edgeProximityCheck = edgeProximityCheck - 10;
            else
                edgeProximityCheck = edgeProximityCheck - 0;
            end

            % The bounding box should corners should be roughly equidistant from the
            % centre of mass of all the white regions
            % Scan the entire image for while pixels
            centroidX = 0;
            centroidY = 0;
            centroidCount = 0;
            for iteri = 1 : size(processed_binary,1)
               for iterj = 1 : size(processed_binary,2)
                   if (processed_binary(iteri, iterj) == 1)
                       centroidCount = centroidCount + 1;
                       centroidX = centroidX + iterj;
                       centroidY = centroidY + iteri;
                   end
               end
            end
            centroidX = centroidX/centroidCount;
            centroidY = centroidY/centroidCount;
            non_ups_bb_centreX = non_upscaled_bb(1) + non_upscaled_bb(3)/2;
            non_ups_bb_centreY = non_upscaled_bb(2) + non_upscaled_bb(4)/2;
            CenterXBB(algoNum, 1) = non_ups_bb_centreX;
    %         figure;
    %         imshow(processed_binary);
    %         hold on;
    %             plot(centroidX, centroidY, 'r*');
    %             plot(non_ups_bb_centreX, non_ups_bb_centreY, 'g*');
    %         hold off;
            absCentroidCentreDist = sqrt((non_ups_bb_centreX-centroidX)^2 + (non_ups_bb_centreY-centroidY)^2);
            % Fuzzy levels of centroid scoring
            if (absCentroidCentreDist < 100)
                centerOfMassScore = 8;
            elseif (absCentroidCentreDist < 200)
                centerOfMassScore = 6;
            elseif (absCentroidCentreDist < 300)
                centerOfMassScore = 4;
            else
                centerOfMassScore = 400/absCentroidCentreDist;
            end
            
            % The center of the bounding box should lie in the recommended
            % zone
            safeZoneScore = 0;
            safe_zone = zone_check(processed_binary, [non_ups_bb_centreX non_ups_bb_centreY], 'bb_center');
            if (safe_zone)
                safeZoneScore = 5;
            end
            
            % Noisiness Penalty
            RegionProp = regionprops(bwconncomp(processed_binary), 'Centroid');
            RegionCentroids = [RegionProp.Centroid];
            noiseCount = size(RegionCentroids,2);
            noisePenalty = -1*noiseCount*(0.01);
            
            % This is for returning the least noisy image -- Nothing to do
            % with this context ---------------------------
            if (current_noise == -1)
                current_noise = noiseCount;
                leastNoisyImage = processed_binary;
            end
            if noiseCount < current_noise
                leastNoisyImage = processed_binary;
            end
            % ---------------------------------------------

            % The cropped image should have a high symmetry value
            tempMat = imcrop(processed_binary, non_upscaled_bb);
            if islogical(tempMat)
              tempMat = im2double(tempMat);
            end
            width = size(tempMat,2);
            height = size(tempMat, 1);
            if (mod(width,2) ~= 0)
              width = width - 1; 
            end
            tempMatLeft = tempMat(1:height, 1:width/2);
            tempMatRight = tempMat(1:height, width/2 + 1 : width);
            tempMatLeftFlipped = fliplr(tempMatLeft);
            [ssimval, ~] = ssim(tempMatLeftFlipped, tempMatRight);
            symmetryScore = ssimval*10;

            % Having high contigous area with least noise is rewarded
            numberOfOnes = sum(sum(tempMat));
            noiselessAreaReward = (numberOfOnes - 1000*noiseCount)/50000;
            
            % Bright/Whitish objects have a bias for being better processed
            % by algo 8
            whiteMean = mean2(im2bw(originalImage));
            whiteBiasScore = 0;
            if (whiteMean > 0.98 && algoNum == 8)
               whiteBiasScore = 5;
            end
            % Display the figure with their final scores
            scores(algoNum, 1) = edgeProximityCheck + centerOfMassScore + ...
                symmetryScore + noisePenalty + noiselessAreaReward + safeZoneScore + whiteBiasScore;
            % Mandatory filters
            if (non_upscaled_bb(3) > 50 && non_upscaled_bb(4) > 30)
                display(strcat('edgeProximityCheck: ', num2str(edgeProximityCheck),...
                    ' centerOfMassScore: ', num2str(centerOfMassScore),' symmetryScore: ',...
                    num2str(symmetryScore), ' noisePenalty: ', num2str(noisePenalty),...
                    ' noiselessAreaReward: ', num2str(noiselessAreaReward),...
                    ' safeZoneScore: ', num2str(safeZoneScore),...
                    ' whiteBiasScore: ', num2str(whiteBiasScore),...
                    'final: ', num2str(scores(algoNum, 1))));
            else
                scores(algoNum, 1) = -99999;
            end
            
            % Disregard bounding boxes below a certain threshold -- Should
            % be the last line
%             numberOfOnes = sum(sum(tempMat));
%             if numberOfOnes < 3000
%                 scores(algoNum, 1) = -99999;
%             end
    %         figure;
    %         imshow(tempMat);
%             title(strcat('edgeProximityCheck: ', num2str(edgeProximityCheck),' centerOfMassScore: ', num2str(centerOfMassScore),' symmetryScore: ', num2str(symmetryScore), ' noisePenalty: ', num2str(noisePenalty), ' final: ', num2str(scores(algoNum, 1))), 'FontSize', 8);
        else
            scores(algoNum, 1) = -99999;
        end
%         subplot(4,2,algoNum);
%         try
%         imshow(processed_binary);
%         rectangle('Position', non_upscaled_bb, 'EdgeColor', 'red');
%         catch
%         end
    end
    
    % Post-processor
    % The final bounding box should not be a horizontal position outlier
    % Calculate standard deviation of the X-Centers of the bounding boxes
    deviation_threshold = 120;
    Median_Deviations = abs(CenterXBB - median(CenterXBB));
    for dev = 1 : size(Median_Deviations)
        if Median_Deviations(dev) > deviation_threshold
            scores(dev) = scores(dev) - 10;
        end
    end
    display(scores);
    [max_score, final_index] = max(scores);
end