%% Pre-processing table

% Read table
preprocTable = readtable('/home/niki/midgard/fondecyt/agustin/docs/preprocTracking.csv');
% Create all bad channels column
allBad       = cell2table(strcat(char(preprocTable{:, 'duplicated_channs'}), {','}, char(preprocTable{:, 'bad_channs'})), 'VariableNames', {'allBad'});
% Update table
preprocTable = [preprocTable allBad];

% Keep file to run ICA with
preprocTable = preprocTable(contains(preprocTable.toDO, 'checkICA'), :);

%% Set files

% path to datasets
setPath = '/home/niki/Documents/eegeses/fdcyt_agustin/newset/ICA/';

% Select files:

% by file name (use subject number to select particular subjects
setFiles = dir(fullfile(setPath, '*304*INT*.set'));
setFiles = {setFiles.name};
% by toDo column of preprocTracking.csv
% setFiles = strcat(preprocTable.file_name(contains(preprocTable.toDO, 'checkICA'), :), '.set')';
% setFiles = strcat(preprocTable.file_name, '.set')';

% if no set files received, take all of them.
if isempty(setFiles)
    setFile = dir([setPath '/*.set']);
    setFile = {setFile.name};
end

%% Start comp checking
close all
for i = 1:size(setFiles,2)
    
    % Read EEG
    tempEEG = pop_loadset('filename', setFiles{i}, 'filepath', char(setPath));
    
    %% Components plots
    % Components to reject
    pop_selectcomps(tempEEG, 1:32);
    
    % Components scroll
    pop_eegplot(tempEEG, 0, 1, 1); title(tempEEG.setname, 'Interpreter', 'none')
    % Components spectra power
    figure; pop_spectopo(tempEEG, 0, [0      tempEEG.xmax], 'EEG' , 'freq', [10], 'plotchan', 0, 'icacomps', 1:size(tempEEG.icachansind, 2), 'nicamaps', 5, 'freqrange',[2 25],'electrodes','off'); title(tempEEG.setname, 'Interpreter', 'none')
    %% Channels plots (read bad channels and plot scroll without them)
    % get bad channels
    currBad = str2num(char(preprocTable{strcmp(preprocTable.file_name, erase(setFiles{i}, '.set')), 'allBad'}));
    % get good channels
    currGut = setdiff(1:128, currBad);
    
    % create EEG with good channels
    gutEEG = pop_select( tempEEG, 'channel', currGut);
    
    % Plot scroll with good channels
    pop_eegplot( gutEEG, 1, 1, 1); title(gutEEG.setname, 'Interpreter', 'none') % plot scroll to inspect EEG
    
    % Plot spectra map
    % 1 - 35HZ
    figure; pop_spectopo(gutEEG, 1, [0 gutEEG.xmax], 'EEG' , 'freq', [6 10 22], 'freqrange',[1 35],'electrodes','off'); title(gutEEG.setname, 'Interpreter', 'none')
    
    %% Duplicated
    [~, ia, ~] = unique(gutEEG.data, 'rows');
    
    %% who's?
    disp(['****************************' newline ...
        'DISPLAYING: ' setFiles{i} newline ...
        'DUPLICATED CHANNS: ' strrep(num2str(setdiff(1:gutEEG.nbchan, ia)), '  ', ',') newline ...
        'BAD CHANNS: ' num2str(currBad) newline '***************************'])
    
    %%
    pause()
    
    %%
    close all
end


