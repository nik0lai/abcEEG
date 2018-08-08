function [] = abc_ecg(setFile, setPath, chann1, chann2)
% ABC_ECG create a new ECG channel (using pop_eegchanoperator() (ERPLAB 
% Toolbox) by substracting chann2 to chann1. 
%
% Usage: abc_ecg(setFile, setPath, chann1, chann2)
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

%% Files to filter
setFile = abc_check_files(setFile, setPath, 'set');

%% Create ECG
for i = 1:numel(setFile)
    currSet = setFile{i};
    
    % Load dataset
    tempEEG = pop_loadset('filename', currSet, 'filepath', setPath);
    
    % Check if EKG already exists (FIX THIS)
    channNames = {tempEEG.chanlocs.labels};
    
    if sum(strcmp(channNames, 'EKG')) > 1
        disp('************************************************')
        disp([tempEEG.setname ' has more than one EKG channel.'])
        disp([num2str(i) '/' num2str(size(setFile, 2))])
        disp('************************************************')
    elseif sum(strcmp(channNames, 'EKG')) == 1
        disp('************************************************')
        disp([tempEEG.setname ' already has an EKG channel.'])
        disp([num2str(i) '/' num2str(size(setFile, 2))])
        disp('************************************************')
    elseif sum(strcmp(channNames, 'EKG')) == 0
        disp('************************************************')
        disp(['Creating EKG channel on channel ' num2str(tempEEG.nbchan+1)])
        disp([num2str(i) '/' num2str(size(setFile, 2))])
        disp('************************************************')
        
        % Create EKG chann
        tempEEG = pop_eegchanoperator(tempEEG, {[['ch' int2str(tempEEG .nbchan + 1)] ' = ch' num2str(chann1) ' - ch' num2str(chann2) ' label EKG']} , 'ErrorMsg', 'popup', 'Warning', 'on');
        % Save dataset
        pop_saveset(tempEEG  , 'filename', char(currSet),'filepath', char(setPath));
        
    end 
    
    
end
end