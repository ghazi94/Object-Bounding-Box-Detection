name_  = {'/home/UserName/Downloads/green_screen/1.JPG',...
    '/home/UserName/Downloads/green_screen/2.JPG',...
    '/home/UserName/Downloads/green_screen/3.JPG',...
    '/home/UserName/Downloads/green_screen/4.JPG',...
    '/home/UserName/Downloads/green_screen/5.JPG'};

white_image = imread('/home/UserName/Downloads/green_screen/white.jpg');

for name = name_
    name = cell2mat(name);
    % Read any two images for background (bg) and foreground (fg)
    main_image = imread(name);
    outDims = [size(main_image, 1) size(main_image, 2)];
    % Background
    white_image = imresize(white_image, outDims);
    bg=double(white_image);
    
    fg=double(main_image);
    
    % extract 3 different color channels
    % and luminance matrix
    fgR = fg(:,:,1);
    fgG = fg(:,:,2);
    fgB = fg(:,:,3);
    fgY = 0.3*fgR+0.59*fgG+0.11*fgB;

    % subtract luminance from green
    fgG_Y=mat2gray(fgG-fgY);

    % Calculate and plot histogram
    histo=hist(fgG_Y(:),256);
    plot([0:255],histo);

    % Define and normalise a reasonable threshold to try to avoid the spills
    % too high will trim the image
    % too low will let some green through the borders
    thres = 80/255;

    % set to 1 in your mask all those values where
    % fg(G-Y) is lower than the threshold
    mask = fgG_Y < thres;

    % finally, save channel by channel the foreground where mask = 1
    % and the background where mask = 0 (1-mask = 1)
    final(:,:,1)=fg(:,:,1).*mask + bg(:,:,1).*(1-mask);
    final(:,:,2)=fg(:,:,2).*mask + bg(:,:,2).*(1-mask);
    final(:,:,3)=fg(:,:,3).*mask + bg(:,:,3).*(1-mask);
    figure, imshow(mat2gray(final));
end