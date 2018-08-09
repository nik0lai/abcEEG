function [] = abc_reject_interpolate(setPath, preprocPath)
% ABC_REJECT_INTERPOLATE reject components using pop_subcomp()
% and interpolate channels using pop_interp() (both from EEGLAB Toolbox).
%
% Usage: abc_reject_interpolate(setPath, preprocPath)

% Read preprocessing table
preprocTable = readtable('/home/niki/midgard/fondecyt/agustin/docs/preprocTracking.csv');
% Keep file to run ICA with
preprocTable = preprocTable(contains(preprocTable.toDO, 'rejectInter'), :);
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

