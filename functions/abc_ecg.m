function [] = abc_ecg(setFiles, setPath, chann1, chann2)
% ABC_ECG create a new ECG channel (using pop_eegchanoperator() (ERPLAB
% Toolbox) by substracting chann2 to chann1.
%
% Usage: abc_ecg(setFiles, setPath, chann1, chann2)
%
% Inputs:
%   'setPath'       - [string] a path to the folder where .set files are to be
%                     imported.
%   'chann1'        - [integer] number indicating channel 1.
%   'chann2'        - [integer] number indicating channel 2.
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

% Channel numbers
if isempty(chann1) || isempty(chann2)
    error('Two numbers indicating two channels must be set.')
elseif ~isnumeric(chann1) && ~isnumeric(chann2)
    error(['Both channel numbers (chann1 and chann2) must be numbers' newline ...
        'You feed the function with ' class(chann1) ' and ' class(chann2)])
end

%% Files to create ECG
setFiles = abc_check_files(setFiles, setPath, 'set');

%% Create ECG
for i = 1:numel(setFiles)
    currSet = setFiles{i};
    
    % Load dataset
    tmpEEG = pop_loadset('filename', currSet, 'filepath', setPath);
    
    % channel labels
    channNames = {tmpEEG.chanlocs.labels};
    
    % Check if ECG channel already exists
    if ~isempty(find(strcmp(channNames, 'EKG'), 1)) || ...
            ~isempty(find(strcmp(channNames, 'ECG'), 1)) || ...
            ~isempty(find(strcmp(channNames, 'ekg'), 1)) || ...
            ~isempty(find(strcmp(channNames, 'ecg'), 1))
        
        % Progress message
        disp(['************************************************' newline ...
            tmpEEG.setname newline ...
            'ECG channel already exists.' newline ...
            num2str(i) '/' num2str(size(setFiles, 2)) newline ...
            '************************************************'])
    else
        % Progress message
        disp(['************************************************' newline ...
            tmpEEG.setname newline ...
            'Creating ECG channel on index ' num2str(tmpEEG.nbchan+1) newline ...
            num2str(i) '/' num2str(size(setFiles, 2)) newline ...
            '************************************************'])
        
        % Create ECG chann
        tmpEEG = pop_eegchanoperator(tmpEEG, {[['ch' int2str(tmpEEG .nbchan + 1)] ' = ch' num2str(chann1) ' - ch' num2str(chann2) ' label EKG']} , 'ErrorMsg', 'popup', 'Warning', 'on');
        
        % Save dataset
        pop_saveset(tmpEEG  , 'filename', currSet,'filepath', setPath);
        
    end
end
end
