%% Run ICA using preprocessing table

% Read preprocessing table
preprocTable = readtable('/home/niki/midgard/fondecyt/agustin/docs/preprocTracking.csv');
% Keep interest cols
preprocTable = preprocTable(:, {'file_name', 'duplicated_channs', 'bad_channs'});

% Create all bad channels column
allBad       = cell2table(strcat(char(preprocTable{:, 'duplicated_channs'}), {','}, char(preprocTable{:, 'bad_channs'})), 'VariableNames', {'allBad'});
% Update table
preprocTable = [preprocTable allBad];

%% Loop through files to ICA

setPath = '/home/niki/Documents/eegeses/fdcyt_agustin/newset/preIca';
setFile = [];

% if no set files received, look for them.
if isempty(setFile)
    setFile = dir([setPath '/*.set']);
    setFile = {setFile.name};
end

setPathICA = '/home/niki/Documents/eegeses/fdcyt_agustin/newset/ICA';

parfor i = 1:size(setFile, 2)
    
    % Channels to include when ICA
    gutChannels  = setdiff(1:128, str2num(char(allBad{i,:})));
    
    currFile = setFile{i};
    
    % read dataset
    tempEEG = pop_loadset('filename', currFile, 'filepath', setPath);
    
    % run ICA
    tempEEG = pop_runica(tempEEG, 'extended',1, 'interupt', 'on', 'chanind', gutChannels); % run ICA
        
    %     Save dataset
    pop_saveset(tempEEG  , 'filename', currFile,'filepath', setPathICA);
    
    % remove file ICAED
    system(['rm ' strrep(fullfile(setPath, currFile), '.set', '*')])
    
end
