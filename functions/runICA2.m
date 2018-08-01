%% (Second run) Run ICA using preprocessing table

% Read preprocessing table
preprocTable = readtable('/home/niki/midgard/fondecyt/agustin/docs/preprocTracking.csv');
% Keep interest cols
preprocTable = preprocTable(:, {'file_name', 'toDO' 'duplicated_channs', 'bad_channs'});

% Keep file to run ICA with
preprocTable = preprocTable(contains(preprocTable.toDO, 'ICA'), :);

% Create all bad channels column
allBad       = cell2table(strcat(char(preprocTable{:, 'duplicated_channs'}), {','}, char(preprocTable{:, 'bad_channs'})), 'VariableNames', {'allBad'});
% Update table
preprocTable = [preprocTable allBad];

% Cell with file names
files = preprocTable.file_name';
% Cell with bad channels
badChannels = preprocTable.allBad';

% Path to files
setPath = '/home/niki/Documents/eegeses/fdcyt_agustin/newset/ICA';

parfor i = 1:size(files, 2)
    
    % Current file to ICA
    currFile = [files{i} '.set'];
    % Channels to include when ICA
    gutChannels  = setdiff(1:128, str2num(char(badChannels{i})));
    
    % read dataset
    tempEEG = pop_loadset('filename', currFile, 'filepath', setPath);
    
    % run ICA
    tempEEG = pop_runica(tempEEG, 'extended',1, 'interupt', 'on', 'chanind', gutChannels); % run ICA
        
    %     Save dataset
    pop_saveset(tempEEG  , 'filename', currFile,'filepath', setPath);
            
end