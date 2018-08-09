function [] = abc_chann_loc(setFiles, setPath, channLocPath)
% ABC_CHANN_LOC add channel locations using pop_editset() (EEGLAB).
%
% Usage: abc_chann_loc(setFiles, setPath, channLocPath)
%
% Inputs:
%   'setPath'       - [string] a path to the folder where .set files are to be
%                     imported.
%   'channLocPath'  - [string] a path to a channel locations file.
%
% Optional inputs:
%   'setFiles'  - [cell array] list of .set files (files have to be within
%                 setPath folder).
%
% Note: EEGLAB toolbox must be installed.

%% Check min arguments
% .set files
if isempty(setPath)
    error(['A path to the folder with .set files has to be set.' newline ...
        'Your parth is: ' setPath])
end

% Path to channels location files (check if empty, if number)
if isempty(channLocPath)
    error('Path to channel locations is empty.')
elseif ~isempty(channLocPath) && ~(exist(channLocPath, 'file') == 2)
    error(['Channel locations does not exist.' newline ...
        'You feed the function with the following path: ' newline ...
        channLocPath])
end

%% Files to add channel locations
setFiles = abc_check_files(setFiles, setPath, 'set');

%% Add channels
for i = 1:numel(setFiles)
    currSet = setFiles{i};
    % Read dataset
    tmpEEG = pop_loadset('filename', currSet, 'filepath', setPath);
   
    % Check if dataset have channel locations
    if isempty(tmpEEG.chanlocs)
        oldChannLoc = 'noChannLoc';
    elseif ~isempty(tmpEEG.chanlocs)
        oldChannLoc = tmpEEG.chanlocs;
    end
    
    % Add channel location
    tmpEEG = pop_editset(tmpEEG, 'chanlocs', channLocPath);
    
    %% Check if new channel locations were added
    if isempty(tmpEEG.chanlocs)
        newChannLoc = 'noChannLoc';
    elseif ~isempty(tmpEEG.chanlocs)
        newChannLoc = tmpEEG.chanlocs;
    end
    
    % Compare old and new channel locations
    if strcmp(oldChannLoc, 'noChannLoc') && ~strcmp(newChannLoc, 'noChannLoc')
        statusMSG = 'Channel locations imported.';
    elseif strcmp(oldChannLoc, 'noChannLoc') && strcmp(newChannLoc, 'noChannLoc')
        statusMSG = ['Channel locations not imported.' newline ... 
            'Check if number of channels is different in dataset and channel file.'];
    elseif ~strcmp(oldChannLoc, 'noChannLoc') && ~strcmp(newChannLoc, 'noChannLoc')
        if isequal(oldChannLoc, newChannLoc)
            statusMSG = ['Channel locations did not change.'];
        end        
    end
    
    %% Save dataset
    pop_saveset(tmpEEG, 'filename', currSet,'filepath', setPath);
    
    %% Progress indicator
    disp(['**************************' newline ...
        'File ' num2str(i) ' out of ' num2str(numel(setFiles)) '.' newline ...
        currSet newline ...
        statusMSG newline ...
        '**************************'])
        
end

end