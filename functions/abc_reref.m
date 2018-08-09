function [] = abc_reref(setFiles, setPath, reRefChann, excludeChann)
% ABC_REREF re-reference channels using pop_reref() (EEGLAB Toolbox)
%
% Usage: abc_reref(setFile, setPath, reRefChann, excludeChann)
%
% Inputs:
%   'setPath'       - [string] a path to the folder where .set files are to
%                     be imported.
%   'reRefChann'    - [integer] one or more numbers indicating new
%                     reference channels.
%   'excludeChann'  - [integer] one or more numbers indicating channels to
%                     exclude.
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

% New reference channel
if isempty(reRefChann)
    error(['A new reference channel(s) has to be set.'])
elseif ~isempty(reRefChann) && ~isnumeric(reRefChann)
    error(['New reference channel(s) is not a number.'])
end

% Channels to exclude
if isempty(excludeChann)
    error(['A new reference channel(s) has to be set.'])
elseif ~isempty(excludeChann) && ~isnumeric(excludeChann)
    error(['New reference channel(s) is not a number.'])
end

%% Files to filter
setFiles = abc_check_files(setFiles, setPath, 'set');

%% Re-reference
for i = 1:numel(setFiles)
    currSet = setFiles{i};
    
    % Load dataset
    tmpEEG = pop_loadset('filename', currSet, 'filepath', setPath);
    
    % Re-reference
    tmpEEG = pop_reref(tmpEEG, reRefChann, 'exclude', excludeChann, 'keepref','on');
    
    % Save dataset
    pop_saveset(tmpEEG  , 'filename', currSet,'filepath', setPath);
    
    % Pogress indicator
    disp([num2str(i) '/' num2str(numel(setFiles))])
    
end

end