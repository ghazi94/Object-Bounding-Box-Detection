function[originalImage, mediumOriginalImage, originalGrayScale, mediumGrayScale, margins] = generate_image_set(originaImageString, mediumImageString, aspect_width, aspect_height)
    originalImage = imread(originaImageString);
    mediumOriginalImage = imread(mediumImageString);
    originalGrayScale = rgb2gray(originalImage);
    mediumGrayScale = rgb2gray(mediumOriginalImage);
    aspect_width = str2double(aspect_width);
    aspect_height = str2double(aspect_height);
    margins = [aspect_width, aspect_height];
end