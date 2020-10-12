name_  = {'/home/UserName/Downloads/green_screen/1.JPG',...
    '/home/UserName/Downloads/green_screen/2.JPG',...
    '/home/UserName/Downloads/green_screen/3.JPG',...
    '/home/UserName/Downloads/green_screen/4.JPG',...
    '/home/UserName/Downloads/green_screen/5.JPG',...
    '/home/UserName/Downloads/green_screen/6.JPG'};

white_image = imread('/home/UserName/Downloads/green_screen/white.jpg');

for name = name_
    name = cell2mat(name);
    % Main Image
    main_image = imread(name);
    outDims = [size(main_image, 1) size(main_image, 2)];
    % Background
    x = imresize(white_image, outDims);
    % Foreground
    y = main_image;
    % Mix them together
    z = y;  % Preallocate space for the result
    % Find the green pixels in the foreground (y)
    yd = double(y)/255;
    % Greenness = G*(G-R)*(G-B)
    greenness = yd(:,:,2).*(yd(:,:,2)-yd(:,:,1)).*(yd(:,:,2)-yd(:,:,3));
    % Threshold the greenness value
    thresh = 0.3*mean(greenness(greenness>0));
    isgreen = greenness > thresh;
    isnotgreen = ~isgreen;
    isnotgreen = imfill(isnotgreen, 'holes');
    isnotgreen = imclearborder(isnotgreen);
    figure, imshow(isnotgreen);
    % Thicken the outline to expand the greenscreen mask a little
    outline = edge(isgreen,'roberts');
    figure, imshow(outline);
    se = strel('disk',1);
    dil_outline = imdilate(outline,se);
    figure, imshow(dil_outline);
%     PSF = fspecial('gaussian',60,10);
%     edgesTapered = edgetaper(outline,PSF);
%     imshow(outline);
%     isgreen = isgreen | outline;
    % Blend the images
    % Loop over the 3 color planes (RGB)
    for j = 1:3
        rgb1 = x(:,:,j);  % Extract the jth plane of the background
        rgb2 = y(:,:,j);  % Extract the jth plane of the foreground
        % Replace the green pixels of the foreground with the background
        rgb2(isgreen) = rgb1(isgreen);
        % Put the combined image into the output
        z(:,:,j) = rgb2;
    end
    break;
    imwrite(z, strrep(name,'/home/UserName/Downloads/green_screen/','/home/UserName/Desktop/output/'), 'jpg');
end