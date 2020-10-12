function[] = Start_Image_Proc(type)
%% Runs shell scripts to download the file and then processes the image
    setenv('LD_LIBRARY_PATH','./lib/x86_64-linux-gnu/');
    if (exist('Unused-Scripts', 'dir') == 7)
        addpath('Unused-Scripts');
    end
    rootFolder = '/tmp/MATRUN/';
    if (~isempty(type) && strcmp(type, 'on-demand'))
        scriptDirectory = strcat('/tmp/Automated-Image-Processing-On-Demand/');
        disp('Starting on-demand processing');
    else
        scriptDirectory = strcat('/tmp/Automated-Image-Processing/');
        disp('Starting real-time processing');
    end
    downloadScript = 'download.sh';
    uploadScript = 'upload.sh';
    % To disbale MATLAB's output buffering
    % system_dependent(7);
    while(1)
         try
             downloadCommand = strcat(scriptDirectory, downloadScript);
             uploadCommmand = strcat(scriptDirectory, uploadScript);
             tic;
             [~,cmdout] = unix(downloadCommand);
             elapsed = toc;
             if isempty(strfind(cmdout, 'this.Messages is undefined'))
                 disp(cmdout);
                 disp(strcat('Matlab received download image option after: ', string(elapsed)));
                 drawnow();
                 commandSplit = strsplit(cmdout, '   ');
                 [~, destination_file] = algo_router(commandSplit, rootFolder);
                 disp(strcat('Matlab finished processing in: ', string(elapsed)));
                 drawnow();
                 uploadCommandWithInputArgs = strcat(uploadCommmand, {' '}, destination_file, {' '}, commandSplit{2}, {' '}, commandSplit{1}, {' '}, commandSplit{3});
                 tic;
                 [~,cmdout] = unix(cell2mat(uploadCommandWithInputArgs));
                 elapsed = toc;
                 disp(strcat('Matlab received upload image success code after: ', string(elapsed)));
                 disp(cmdout);
                 drawnow();
             else
                % This is a common message -> When no SQS Messages are left! No need
                %  to print it
             end
             clearvars -except downloadScript rootFolder scriptDirectory uploadScript type
         catch MainException
             disp(MainException.message);
         end
    end
end