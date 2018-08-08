function [trackTable] = abc_trimm(setFiles, setPath, firstEvent, lastEvent, edgesMargins, trimmDir)
% ABC_TRIM remove non-relevant recorded data using pop_select() (EEGLAB
% Toolbox).
%
% Usage: abc_trimm(setFiles, setPath, firstEvent, lastEvent, edgesMargins, trimmDir)
%
% Inputs:
%   'setPath'       - [string] a path to the folder where .set files are to
%                     be imported.
%   'edgesMargins'  - [integer] a number, or two, indicating seconds after
%                     and before first and last event.
%
% Optional inputs:
%   'setFiles'   - [cell array] list of .set files (files have to be within
%                 setPath folder).
%   'firstEvent' - [integer] number indicating the first event after
%                  edgesMargins.
%   'lastEvent'  - [integer] number indicating the last event before
%                  edgesMargins.
%   'trimmDir'   - [string] a path to the folder where trimmed .set files
%                  are to be saved
%
% Note: EEGLAB toolbox must be installed.

%% Check min arguments
% .set files
if isempty(setPath)
    error(['A path to the folder with .set files has to be set.' newline ...
        'Your parth is: ' setPath])
end

% Events (number or string?)

% Edge margins

if isempty(edgesMargins)
    error(['At least one number indicating the number of seconds to keep after/before the first and last event.'])
elseif ~isempty(edgesMargins) && ~isnumeric(edgesMargins)
    error(['The number of seconds to keep after/before the first and last event must be a number' newline ...
        'You feed the function with ' class(edgesMargins)])
end

%% Files to trimm
setFiles = abc_check_files(setFiles, setPath, 'set');

%% Trimm dir
if isempty(trimmDir)
    % Set dir
    newDir = setPath;
    % Message
    warning(['No trimmDir folder set. Exporting trimmed datasets to origin folder: ' newline ...
        newDir newline])
elseif ~isempty(trimmDir)
    % Set dir
    newDir = trimmDir;
    % Message
    disp(['***************************' newline ...
        'Exporting trimmed datasets to folder: ' newline ...
        newDir newline ...
        '***************************'])
end

%% Tracktable

% importTrack info. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
oldDur     = zeros(size(setFiles, 2), 1); % Original EEG duration (seconds).
newDur     = zeros(size(setFiles, 2), 1); % New EEG duration (seconds).
durDiff    = zeros(size(setFiles, 2), 1); % seconds trimmed.
frstEvent  = zeros(size(setFiles, 2), 1); % first event
lstEvent   = zeros(size(setFiles, 2), 1); % last event
date       = cell(size(setFiles, 2), 1);  % Date
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:numel(setFiles)
    currSet = setFiles{i};
    
    % Progress indicator
    disp(['***********************************' newline ...
        'Trimming' newline ...
        currSet newline ...
        num2str(i) '/' num2str(numel(setFiles)) newline ...
        '***********************************'])
    
    % Load dataset
    tmpEEG = pop_loadset('filename', currSet, 'filepath', setPath);
    
    % Original eeg duration
    oldDur(i) = fix(tmpEEG.xmax);
    
    
    %% Check events and get times (also trimm)
    if isempty(firstEvent) && isempty(lastEvent)
        
        % Get labels of first and last event
        firstEdgeType = tmpEEG.event(1).type;
        lastEdgeType  = tmpEEG.event(size(tmpEEG.event, 2)).type;
        
        % Get latencies of first and last event
        firstEdgeSec = (tmpEEG.event(1).latency/tmpEEG.srate) - edgesMargins(1);                      % first event latency
        lastEdgeSec  = (tmpEEG.event(size(tmpEEG.event, 2)).latency/tmpEEG.srate) + edgesMargins(2);  % last event latency
        
    elseif ~isempty(firstEvent) && ~isempty(lastEvent)
        
        % First event (set) index
        isFirst = cellfun(@(x)isequal(x,firstEvent), {tmpEEG.event.type});
        firstTriggI = find(isFirst);
        
        % Last event (set) index
        isLast = cellfun(@(x)isequal(x,lastEvent), {tmpEEG.event.type});
        lastTriggI   = find(isLast);
        
        % Get labels of first and last event
        firstEdgeType = tmpEEG.event(firstTriggI(1)).type;
        lastEdgeType  = tmpEEG.event(lastTriggI(size(lastTriggI, 2))).type;
        
        % Get latencies of first and last event
        firstEdgeSec = (tmpEEG.event(firstTriggI(1)).latency/tmpEEG.srate)-edgesMargins(1);     % first event latency
        lastEdgeSec  = (tmpEEG.event(lastTriggI(size(lastTriggI, 2))).latency/tmpEEG.srate)+(2);  % last event latency
        
    elseif ~isempty(firstEvent) && isempty(lastEvent)
        
        % First event (set) index
        isFirst = cellfun(@(x)isequal(x,firstEvent), {tmpEEG.event.type});
        firstTriggI = find(isFirst);
        
        % Get labels of first and last event
        firstEdgeType = tmpEEG.event(firstTriggI(1)).type;
        lastEdgeType  = tmpEEG.event(size(tmpEEG.event, 2)).type;
        
        % Get latencies of first and last event
        firstEdgeSec = (tmpEEG.event(firstTriggI(1)).latency/tmpEEG.srate)-edgesMargins(1);     % first event latency
        lastEdgeSec  = (tmpEEG.event(size(tmpEEG.event, 2)).latency/tmpEEG.srate)+edgesMargins(2);  % last event latency
        
    elseif isempty(firstEvent) && ~isempty(lastEvent)
        
        % Last event (set) index
        isLast = cellfun(@(x)isequal(x,lastEvent), {tmpEEG.event.type});
        lastTriggI   = find(isLast);
        
        % Get labels of first and last event
        firstEdgeType = tmpEEG.event(1).type;
        lastEdgeType  = tmpEEG.event(lastTriggI(size(lastTriggI, 2))).type;
        
        % Get latencies of first and last event
        firstEdgeSec = (tmpEEG.event(1).latency/tmpEEG.srate)-edgesMargins(1);     % first event latency
        lastEdgeSec  = (tmpEEG.event(lastTriggI(size(lastTriggI, 2))).latency/tmpEEG.srate)+(2);  % last event latency
        
    end
    
    %% Trimm!
    tmpEEG    = pop_select(tmpEEG, 'time', [firstEdgeSec lastEdgeSec]);  % select data between min max (in seconds)
    
    % Save dataset
    [~, ~, ~] = mkdir(fullfile(char(setPath), newDir));
    
    pop_saveset(tmpEEG  , 'filename', char(currSet),'filepath', fullfile(char(setPath), newDir));
    
    
    % If event labels are char, convert to num (for tracking)
    % First
    if isnumeric(firstEdgeType)
        a = firstEdgeType;
    elseif ischar(firstEdgeType)
        a = str2num(firstEdgeType);
    end
    % Last
    if isnumeric(lastEdgeType)
        b = lastEdgeType;
    elseif ischar(lastEdgeType)
        b = str2num(lastEdgeType);
    end
    
    % Set information of trackTable
    newDur(i)     = fix(tmpEEG.xmax);      % New EEG duration (seconds).
    durDiff(i)    = oldDur(i) - newDur(i); % Seconds trimmed.
    frstEvent(i) = a; % first event
    lstEvent(i)  = b; % last event
    date(i)       = {char(datetime)}; % date
    
end

% Build resamplingtracking table
trackTable = [cell2table(setFiles', 'VariableNames', {'files'}) ... % file names
    cell2table(num2cell([oldDur newDur durDiff frstEvent lstEvent]), 'VariableNames', {'oldDur', 'newDur', 'durDiff', 'firstEvent', 'lastEvent'}) ... % Tracking info
    table(date)]; % date

end

