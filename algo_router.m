function[exit_code, destinationFile] = algo_router(commandSplit, rootFolder)
    % Not using exit_code for now
    exit_code = 1;
    S3_KEY = commandSplit{1};
    FILE_MEDIUM_SIZED = commandSplit{2};
    ASPECT_WIDTH = string('4');
    ASPECT_HEIGHT = string('3');
    % -------------------------------------------------------- %
    % Convert into program's sense of variables
    downloadedFilePath = S3_KEY;
    mediumResizedFile = FILE_MEDIUM_SIZED;
    destinationFile = commandSplit{4};
    if (determine_if_tv(S3_KEY))
       % Send the processing to the tv algorithm(s)
       TV_Algorithm(strcat(rootFolder, downloadedFilePath), ...
            strcat(rootFolder, mediumResizedFile), ...
            ASPECT_WIDTH, ASPECT_HEIGHT, ...
            strcat(rootFolder, strtrim(destinationFile)));
    else
        % Send the processing to the general algorithm(s)
        generic_algorithm(strcat(rootFolder, downloadedFilePath), ...
            strcat(rootFolder, mediumResizedFile), ...
            ASPECT_WIDTH, ASPECT_HEIGHT, ...
            strcat(rootFolder, strtrim(destinationFile)));
    end
    
    % -------------------- UTILS 1 ------------------------------ %
    function[is_tv] = determine_if_tv(s3key)
        is_tv = false;
        whProductIdToken = regexpi(s3key, '.*/(.*)/RAW.*', 'tokens');
        if (size(whProductIdToken) == 1)
           whProductId = string(cell2mat(whProductIdToken{1}));
           try
               queryUrl = strcat('http://54.179.176.239:9090/qc/product/', whProductId);
               categoryQuery = webread(queryUrl);
               if (isfield(categoryQuery, 'category'))
                   category = categoryQuery.category;
               else
                   category = '';
               end
               if (strcmp(category, 'TV'))
                  is_tv = true;
               end
           catch tv_exception
                display(strcat('TV Exception: ', tv_exception.message));
           end
        end
    end
end