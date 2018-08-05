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

for i = 1:size(setFile, 2)
    currSet = setFile(i);
    %     Read dataset
    tempEEG = pop_loadset('filename',char(currSet), 'filepath', char(setPath));
    %     Add channel location
    tempEEG = pop_editset(tempEEG, 'chanlocs', channLocPath);
    %     Save dataset
    pop_saveset(tempEEG  , 'filename', char(currSet),'filepath', char(setPath));
    %     Progress indicator
    disp([num2str(i) '/' num2str(size(setFile, 2))])    
    
end

end