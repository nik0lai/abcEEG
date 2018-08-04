function [resampleTrack] = abc_resample(setFiles, setPath, newSrate)
% ABC_RESAMPLE change sampling rate using pop_resample() (EEGLAB toolbox).
% New sampling rate must be lower than current sampling rate.
%
% Usage: abc_resample(setFiles, setPath, newSrate)
%
% Inputs:
%   'setPath'   - [string] a path to the folder where .set files are to be
%                 imported.
%   'newSrate'  - [integer] a number indicating new sampling rate
%
% Optional inputs:
%   'setFiles'  - [cell array] list of .set files to resample (files have
%                 to be within setPath folder).
%
% Outputs:
%   resampleTrack - table with information about resampled .set files.
%
% Note: EEGLAB toolbox must be installed.

%% Check min arguments
% .set files
if isempty(setPath)
    error(['A path to the folder with .set files has to be set.' newline ...
        'Your parth is: ' setPath])
end

% New sampling rate (check if empty, if number)
if isempty(newSrate)
    error(['New sampling rate is empty.' newline ...
        'Indicate a new sampling rate using a number'])
elseif ~isempty(newSrate) && ~isnumeric(newSrate)
    error(['New sampling rate must be a number.' newline ...
        'You feed the function with a ' class(newSrate)])
end

%% Files to resample:

% If list with files is not empty, check if it's a cell
if ~isempty(setFiles)
    if ~iscell(setFiles)
        error(['List with .set files names must be a cell.' newline ...
            'You feed the function with a ' class(setFiles)])
    end
    % If empty, get everything within the bdf folder.
elseif isempty(setFiles)
    setFiles = dir(fullfile(setPath, '/*.set'));
    setFiles = {setFiles.name};
end

%% Begin resampling:

% No files within the folder?
if ~numel(setFiles) > 0
    error(['There are no .set files within: ' newline setPath])
    
elseif numel(setFiles) > 0
    
    % resampleTrack info. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    oldRate = zeros(size(setFiles, 2), 1); % Original sampling rate
    newRate = zeros(size(setFiles, 2), 1); % New sampling rate
    date    = cell(size(setFiles, 2), 1);  % Date
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    parfor i = 1:numel(setFiles)
        % Current file
        setFileTmp = setFiles{i};
        
        % Read dataset, change name
        tmpEEG = pop_loadset('filename',char(setFileTmp), 'filepath', char(setPath));
        
        % Tracking info
        oldRate(i) = tmpEEG.srate;        % original sample-rate
        date(i)    = {datetime('now')};   % date
        
        % Check current sampling rate (must be lower than current sampling rate)
        if tmpEEG.srate < newSrate
            warning(['On file ' setFileTmp ', new sampling rate is higher than actual sampling rate.' newline ...
                'Skipping file.'])
            
            % Tracking info - New sampling rate
            newRate(i) = tmpEEG.srate;
            
        elseif tmpEEG.srate == newSrate
            warning(['On file ' setFileTmp ', new sampling rate is equal to actual sampling rate'  newline ...
                'Skipping file.'])
            
            % Tracking info - New sampling rate
            newRate(i) = tmpEEG.srate;
            
            % Lower than current sampling rate
        elseif tmpEEG.srate > newSrate
            
            % Change sampling rate
            tmpEEG = pop_resample(tmpEEG, newSrate);
            
            % Tracking info - New sampling rate
            newRate(i) = tmpEEG.srate;
            
            % Export resampled file
            mkdir(setPath); % create dir, if already exists gives a warning
            pop_saveset(tmpEEG, 'filename', setFileTmp,'filepath', setPath); % save dataset
            
        end
        
        %% Message. Old/new sampling rate
        disp(['**********************************' newline ...
            'On ' setFileTmp ':' newline ...
            'Old sample rate is: ' num2str(oldRate(i)) ' Hz' newline ...
            'New sample rate is: ' num2str(newRate(i)) ' Hz' newline ...
            '**********************************'])
        
    end
end

% Build resamplingtracking table
resampleTrack = [cell2table(setFiles', 'VariableNames', {'files'}) ... % file names
    cell2table(num2cell([oldRate newRate]), 'VariableNames', {'oldSrate', 'newSrate'}) ... % tracking info
    table(date)]; % date
end