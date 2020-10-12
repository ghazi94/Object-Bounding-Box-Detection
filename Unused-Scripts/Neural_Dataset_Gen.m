fileList = getAllFiles('C:\Users\UserName\Desktop\VMShare\ImageProc\DryRuns\');
saveDestination = 'C:\Users\UserName\Desktop\VMShare\ImageProc\nnet_wall_strips\';

% Strip thickness
horizontalDivisor = 24;

% For creating wall strips
if 0
figure;
for fileCount = 1 : size(fileList)
    fileCell = fileList(fileCount);
    fileName = fileCell{1};
    search1 = strfind(fileName, 'Result');
    search2 = strfind(fileName, 'EDITED');
    search3 = strfind(fileName, '.JPG');
    search4 = strfind(fileName, '.jpg');
    if isempty([search1,search2]) && ~isempty([search3,search4])
        originalImage = imread(fileName);
        imshow(originalImage);
        dragRet = imrect;
        position = wait(dragRet);
        if (position(3) > 0 && position(4) > 0)
            fileStripPos = [strfind(fileName, 'BLR'), strfind(fileName, 'DELHI'), strfind(fileName, 'MUM')];
            try
                fileStripName = fileName(1, fileStripPos : end-4);
                fileStripName = regexprep(fileStripName, '\\', '$');
                fileStripName = regexprep(fileStripName, '/', '$');
                extract_strips(originalImage, position, strcat(saveDestination, fileStripName), horizontalDivisor);
            catch exception
               display(strcat('Unable to process wall strips for file: ', fileName)); 
            end
        end
    end
end
end

% For generating data set
fileList = getAllFiles('C:\Users\UserName\Desktop\VMShare\ImageProc\nnet_wall_strips\');
strip_height = 2000;
strip_width = 124;
horizontalScanStrips = uint8(zeros(500, strip_height, strip_width));
expected_output = zeros(500, 1);
for fileCount = 1 : size(fileList)
    fileCell = fileList(fileCount);
    fileName = fileCell{1};
    search3 = strfind(fileName, '.JPG');
    search4 = strfind(fileName, '.jpg');
    if ~isempty([search3,search4])
        wall_strip = imread(fileName);
        if (size(wall_strip, 1) == strip_height && size(wall_strip, 2) == strip_width)
            horizontalScanStrips(fileCount, :, :) = wall_strip;
            expected_output(fileCount, 1) = 1;
        end
    end
end