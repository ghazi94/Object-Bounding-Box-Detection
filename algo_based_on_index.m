function [bounding_box, non_upscaled_bb, processed_binary] = algo_based_on_index(algoNum, mediumOriginalImage, mediumGrayScale, originalGrayScale)
    if algoNum == 1
        [bounding_box, non_upscaled_bb, processed_binary] = Algorithm_1(mediumOriginalImage, mediumGrayScale, originalGrayScale);
    elseif algoNum == 2
        [bounding_box, non_upscaled_bb, processed_binary] = Algorithm_2(mediumOriginalImage, mediumGrayScale, originalGrayScale);
    elseif algoNum == 3
        [bounding_box, non_upscaled_bb, processed_binary] = Algorithm_3(mediumOriginalImage, mediumGrayScale, originalGrayScale);
    elseif algoNum == 4
        [bounding_box, non_upscaled_bb, processed_binary] = Algorithm_4(mediumOriginalImage, mediumGrayScale, originalGrayScale);
    elseif algoNum == 5
        [bounding_box, non_upscaled_bb, processed_binary] = Algorithm_5(mediumOriginalImage, mediumGrayScale, originalGrayScale);
    elseif algoNum == 6
        [bounding_box, non_upscaled_bb, processed_binary] = Algorithm_6(mediumOriginalImage, mediumGrayScale, originalGrayScale);
    elseif algoNum == 7
        [bounding_box, non_upscaled_bb, processed_binary] = Algorithm_7(mediumOriginalImage, mediumGrayScale, originalGrayScale);
    else
        [bounding_box, non_upscaled_bb, processed_binary] = Algorithm_8(mediumOriginalImage, mediumGrayScale, originalGrayScale);
    end
end