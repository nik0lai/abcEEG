function [] = abc_ica(setPath, preprocPath, excludeChanns)
% ABC_ICA run ICA using pop_runica() (EEGLAB Toolbox).
%
% Usage: abc_ica(setPath, preprocPath)
% 
% Inputs:
%   'setPath'       - [string] a path to the folder where .set files are to
%                     be imported.
%   'preprocPath'   - [string] a path to a .csv file with the following
%                     columns (each row is a .set file). 'file_name': .set
%                     file names, 'toDo': files to run ICA with should have
%                     'doIca' on this column, 'duplicated_channels':
%                     channels to exclude from ICA (in this case, duplicated
%                     channels), 'bad_channs': channels to exclude from ICA
%                     for any reason. A filled example of this .csv file can
%                     be found on /resources/examplePreprocTable.csv.
%
% Note: EEGLAB toolbox must be installed.

%% Read preprocessing table
preprocTable = readtable(preprocPath);
% Filter rows to keep files to reject/interpolate
preprocTable = preprocTable(contains(preprocTable.toDO, 'doIca'), :);

% Cell with file names
setFiles = preprocTable.file_name';

%% Get channels to interpolate and components to reject
% Create a 1x1 cell with all channels to interpolate (paste columns 'duplicated_channs'
% and 'bad_channs'.
badChann = cell2table(strcat(char(preprocTable{:, 'duplicated_channs'}), {','}, ...
    char(preprocTable{:, 'bad_channs'})), ...
    'VariableNames', {'allBad'});

%% do ICA
parfor i = 1:numel(setFiles)    
    currSet = [setFiles{i} '.set'];
%     currSet = ['CH_F17_CN_117_NEGATION' '.set'];
    
    % Load dataset
    tmpEEG = pop_loadset('filename', currSet, 'filepath', setPath);
    
    %% Channels to include when ICA
    gutChanns  = setdiff(1:tmpEEG.nbchan, [str2num(char(badChann{i,:})) excludeChanns]);
    
    %% run ICA
    tmpEEG = pop_runica(tmpEEG, 'extended',1, 'interupt', 'on', 'chanind', gutChanns); % run ICA
        
    %% Save dataset
    pop_saveset(tmpEEG, 'filename', currSet,'filepath', setPath);
    
end
