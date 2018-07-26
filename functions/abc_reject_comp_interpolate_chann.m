%% Reject bad components. Interpolate bad channels.

% Read preprocessing table
preprocTable = readtable('/home/niki/midgard/fondecyt/agustin/docs/preprocTracking.csv');
% Keep file to run ICA with
preprocTable = preprocTable(contains(preprocTable.toDO, 'rejectInter'), :);

% Bad channels and Bad components
badChann = cell2table(strcat(char(preprocTable{:, 'duplicated_channs'}), {','}, char(preprocTable{:, 'bad_channs'})), 'VariableNames', {'allBad'});
badComp  = cell2table(strcat(char(preprocTable{:, 'comp_eyemove'}), {','}, char(preprocTable{:, 'comp_muscle'}), {','}, char(preprocTable{:, 'comp_50hz'}), ...
    {','}, char(preprocTable{:, 'comp_ecg'}), {','}, char(preprocTable{:, 'comp_headmove'}), {','}, char(preprocTable{:, 'comp_blerp'})));

% Cell with file names
files = preprocTable.file_name';

% Path to files
setPath = '/home/niki/Documents/eegeses/fdcyt_agustin/newset/ICA';

parfor i = 1:size(files, 2)
    
    % Get current bad components
    currBadComp = char(badComp{i, :});
    % Remove extra commas
    while contains(currBadComp, ',,')
        currBadComp = strrep(currBadComp, ',,', ',');
    end
        
    % Current file to ICA
    currFile = [files{i} '.set'];
    
    % read dataset
    tempEEG = pop_loadset('filename', currFile, 'filepath', setPath);
    
    % Reject bad components
    tempEEG = pop_subcomp( tempEEG, currBadComp, 0);
    
    % Interpolate bad channels
    tempEEG = pop_interp(tempEEG, str2num(char(badChann{i,:})), 'spherical');
    
    % Save dataset
    pop_saveset(tempEEG  , 'filename', currFile,'filepath', setPath);
    
end

