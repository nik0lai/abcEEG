function [importTrack] = abc_import_bdf(bdfPath, setPath, newSrate, bdfFiles, bdfDoneDir)
% ABC_IMPORT_BDF import data using pop_biosig() (BIOSIG toolbox) and,
% optionally, change the sampling rate of the imported data. Parallel
% processing available if possible.
%
% Usage: abc_import_bdf(bdfPath, setPath, newSrate, bdfFiles, bdfDoneDir)
%
% Inputs:
%   'bdfPath'   - [string] a path to the folder with .bdf files to import.
%   'setPath'   - [string] a path to the folder where .set files are to be
%                 imported.
%
% Optional inputs:
%   'newSrate'  - [integer] number indicating new sampling rate. Must be
%                 lower than current sampling rate.
%   'bdfFiles'  - [cell array] list of .bdf files to import (files have to
%                 be within bdfPath folder).
%   'bdfDoneDir'- [string] a path to the folder where imported .bdf files
%                 are to be moved.
% Outputs:
%   importTrack - table with information about imported .bdf files.
%
% Note: EEGlab and BIOSIG toolbox must be installed.

%% Check min arguments
% .bdf files
if isempty(bdfPath)
    error(['A path to the folder with .bdf files has to be set.' newline ...
        'Your parth is: ' bdfPath])
end

% .set files
if isempty(setPath)
    error(['A path to the folder were .set files are to be saved.' newline ...
        'Your path is: ' setPath])
end
%% Files to import:

% If list with files is not empty, check if it's a cell
if ~isempty(bdfFiles)
    if ~iscell(bdfFiles)
        error(['List with .bdf files names must be a cell.' newline ...
            'You feed the function with a ' class(bdfFiles)])
    end
    % If empty, get everything within the bdf folder.
elseif isempty(bdfFiles)
    bdfFiles = dir(fullfile(bdfPath, '/*.bdf'));
    bdfFiles = {bdfFiles.name};
end


%% Begin import:

% No files within the folder?
if ~numel(bdfFiles) > 0
    error(['There are no .bdf files within: ' newline bdfPath])
    
% Iterate through .bdf files
elseif numel(bdfFiles) > 0
    
    % importTrack info. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    oldRate = zeros(size(bdfFiles, 2), 1); % Original sampling rate
    newRate = zeros(size(bdfFiles, 2), 1); % New sampling rate
    chanNum = zeros(size(bdfFiles, 2), 1); % Number of channels of imported EEG
    eegDur  = zeros(size(bdfFiles, 2), 1); % EEG duration (seconds)
    date    = cell(size(bdfFiles, 2), 1);  % Date
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    parfor i = 1:numel(bdfFiles)
        % Current file
        bdfFileTmp = bdfFiles{i};
        
        % Read dataset, change name
        tmpEEG = pop_biosig(fullfile(bdfPath, bdfFileTmp));
        tmpEEG = pop_editset(tmpEEG, 'setname', strtok(bdfFileTmp, '.')); % asign dataset name using bdf file name
        
        % Tracking info
        oldRate(i) = tmpEEG.srate;        % original sample-rate
        chanNum(i) = tmpEEG.nbchan;       % number of channels
        eegDur(i)  = fix(tmpEEG.xmax);         % EEG duration (seconds)
        date(i)    = {datetime('now')};   % date
        
        % Change sample rate?
        if ~isempty(newSrate) % If new sampling rate is not empty, do the following:
            
            % Check if new sampling rate if lower than current sampling rate
            if tmpEEG.srate < newSrate
                warning(['On file ' bdfFileTmp ', new sampling rate is higher than actual sampling rate'])
            elseif tmpEEG.srate == newSrate
                warning(['On file ' bdfFileTmp ', new sampling rate is equal to actual sampling rate'])
                
            % Lower than current sampling rate
            elseif tmpEEG.srate > newSrate
                
                % Change sampling rate
                tmpEEG = pop_resample(tmpEEG, newSrate);
                
                % Tracking info - New sampling rate
                newRate(i) = tmpEEG.srate;
                
                %% Messages if sample-rate changed
                disp(['**********************************' newline ...
                    'On ' bdfFileTmp ':' newline ...
                    'Old sample rate is: ' num2str(oldRate(i)) ' Hz' newline ...
                    'New sample rate is: ' num2str(newRate(i)) ' Hz' newline ...
                    'Number of channels: ' num2str(chanNum(i)) newline ...
                    'EEG duration: ' num2str(eegDur(i)) ' seconds' newline ...
                    '**********************************'])
                % disp([num2str(i) '/' num2str(size(bdfFiles, 2))])
                % size(EEG.times,2)/EEG.srate
                                
            end
            
        elseif isempty(newSrate)
            
            % Tracking info - New sampling rate (no resampled, should be
            % equal to original sampling rate
            newRate(i) = tmpEEG.srate;
            
            %% Messages if sample-rate (didn't) changed
            disp(['**********************************' newline ...
                    'On ' bdfFileTmp ':' newline ...
                    'Old sample rate is: ' num2str(oldRate(i)) ' Hz' newline ...
                    'New sample rate is: ' num2str(newRate(i)) ' Hz' newline ...
                    'Number of channels: ' num2str(chanNum(i)) newline ...
                    'EEG duration: ' num2str(eegDur(i)) ' seconds' newline ...
                    '**********************************'])
                            
        end 
            %% save dataset
            
            mkdir(setPath); % create dir, if already exists gives a warning
            
            pop_saveset(tmpEEG, 'filename', bdfFileTmp,'filepath', setPath); % save dataset
            
            % If folder to move imported .bdf files is not empty, move file.
            if ~isempty(bdfDoneDir)
                movefile(fullfile(bdfPath, bdfFileTmp), bdfDoneDir)
            end
    end
end

% Build resamplingtracking table
importTrack = [cell2table(bdfFiles', 'VariableNames', {'files'}) ... % file names
    cell2table(num2cell([oldRate newRate chanNum eegDur]), 'VariableNames', {'oldRate', 'newRate', 'chanNum', 'eegDuration'}) ... % tracking info
    table(date)]; % date

end
