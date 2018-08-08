function [] = abc_filtering(setFiles, setPath, highPassFilter, lowPassFilter)
% ABC_FILERING apply fitlers using pop_eegfiltnew() (EEGLAB Toolbox). A low
% and/or high pass filter can be applied in different calls
% (non-simultaneously).
%
% Usage: abc_filtering(setFiles, setPath, highPassFilter, lowPassFilter)
%
% Inputs:
%   'setPath'       - [string] a path to the folder where .set files are to be
%                     imported.
%   'highPassFilter'- [integer] number indicating lower edge of filter.
%   'lowPassFilter' - [integer] number indicating higher edge of filter.
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
if isempty(highPassFilter) && isempty(lowPassFilter)
    error('At least one filter has to be set.')
elseif ~isempty(highPassFilter) || ~isempty(lowPassFilter)
    
    % Check if highPassFilter is a number
    if ~isempty(highPassFilter) && ~isnumeric(highPassFilter)
        error(['highPassFilter is not a number.' newline ...
            'Is a ' class(highPassFilter)])
    end
    % Check if lowPassFilter is a number
    if ~isempty(lowPassFilter) && ~isnumeric(lowPassFilter)
        error(['lowPassFilter is not a number.' newline ...
            'Is a ' class(lowPassFilter)])
    end
end

%% Files to filter
setFiles = abc_check_files(setFiles, setPath, 'set');

%% Filter
parfor i = 1:numel(setFiles)
    currSet = setFiles{i};
    
    % Load dataset
    tmpEEG = pop_loadset('filename', currSet, 'filepath', setPath);
    
    % Get highPassFilter filter order (this is usually calculated when
    % applying a fitler through EEGLAB's GUI. The following function is an
    % extraction of EEGLAB's GUI.
    filtOrderHighpass = abc_filtOrderCalc(tmpEEG.srate, highPassFilter, []); % 2112
    
    tempEEG = pop_eegfiltnew(tempEEG, [],lowPassEnd, filtOrderHighpass,1,[],0); % 256
    
    % Get lowPassFilter filter order (this is usually calculated when
    % applying a fitler through EEGLAB's GUI. The following function is an
    % extraction of EEGLAB's GUI.
    filtOrderLowpass = abc_filtOrderCalc(tmpEEG.srate, [], lowPassFilter); % 106
    
    tempEEG = pop_eegfiltnew(tempEEG, [],highPassEnd, filtOrderLowpass,0,[],0); % 256
    
    %     EDIT NAME
    tempEEG = pop_editset(tempEEG, 'setname', [tempEEG.setname 'f']);
    
    if (saveOrNotToSave == 0)
        filteredEEG = tempEEG;
    elseif (saveOrNotToSave == 1)
        pop_saveset(tempEEG, 'filename', char(currSet),'filepath', char(setPath));
    end
    
    disp('*****************************************')
    disp(['highpass: ' num2str(filtOrderHighpass)])
    disp(['lowpass: ' num2str(filtOrderLowpass)])
    disp([num2str(i) '/' num2str(size(setFile, 2))])
    disp('*****************************************')
    
end

end
