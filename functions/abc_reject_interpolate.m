function [] = abc_reject_interpolate(setPath, preprocPath)
% ABC_REJECT_INTERPOLATE reject components using pop_subcomp()
% and interpolate channels using pop_interp() (both from EEGLAB Toolbox).
%
% Usage: abc_reject_interpolate(setPath, preprocPath)
% 
% Inputs:
%   'setPath'       - [string] a path to the folder where .set files are to be
%                     imported.
%   'preprocPath'   - [string] a path to a .csv file with the following
%                     columns (each row is a .set file). 'file_name': .set
%                     file names, 'toDo': files that have components to
%                     reject and channels to inteporlate should
%                     'rejectInter' on this column, 'duplicated_channels':
%                     channels to interpolate (in this case, duplicated
%                     channels), 'bad_channs': channels to interpolate for
%                     any reason. And the following columns indicating
%                     components to reject ('comp_eyemove', 'comp_muscle',
%                     'comp_50hz', 'comp_ecg', 'comp_headmove',
%                     'comp_blerp'. A filled example of this .csv file can
%                     be found on /resources/examplePreprocTable.csv.
%
% Note: EEGLAB toolbox must be installed.

%% Read preprocessing table
preprocTable = readtable(preprocPath);
% Filter rows to keep files to reject/interpolate
preprocTable = preprocTable(contains(preprocTable.toDO, 'rejectInter'), :);

% Cell with file names
setFiles = preprocTable.file_name';

%% Get channels to interpolate and components to reject
% Create a 1x1 cell with all channels to interpolate (paste columns 'duplicated_channs'
% and 'bad_channs'.
badChann = cell2table(strcat(char(preprocTable{:, 'duplicated_channs'}), {','}, ...
    char(preprocTable{:, 'bad_channs'})), ...
    'VariableNames', {'allBad'});
% Create a 1x1 cell with all components to reject (paste columns 'comp_eyemove',
% 'bad_channs', 'comp_50hz', 'comp_ecg', 'comp_headmove', 'comp_blerp'.
badComp  = cell2table(strcat(char(preprocTable{:, 'comp_eyemove'}), {','}, ...
    char(preprocTable{:, 'comp_muscle'}), {','}, ...
    char(preprocTable{:, 'comp_50hz'}), {','}, ...
    char(preprocTable{:, 'comp_ecg'}), {','}, ...
    char(preprocTable{:, 'comp_headmove'}), {','}, ...
    char(preprocTable{:, 'comp_blerp'})));

%% Reject/interpolate
parfor i = 1:numel(setFiles)
    currSet = [setFiles{i} '.set'];
    
    % Load dataset
    tmpEEG = pop_loadset('filename', currSet, 'filepath', setPath);
    
    %% Get current bad components
    currBadComp = char(badComp{i, :});
    % Remove extra commas
    while contains(currBadComp, ',,')
        currBadComp = strrep(currBadComp, ',,', ',');
    end
    
    %% Reject components
    tmpEEG = pop_subcomp(tmpEEG, currBadComp, 0);
    
    %% Interpolate channels
    tmpEEG = pop_interp(tmpEEG, str2num(char(badChann{i,:})), 'spherical');
    
    %% Save dataset
    pop_saveset(tmpEEG  , 'filename', currSet,'filepath', setPath);
    
end

end
