function [] = abc_reref(setFiles, setPath, reRefChann, excludeChann)
% ABC_REREF re-reference channels using pop_reref() (EEGLAB Toolbox)
%
% Usage: abc_reref(setFile, setPath, reRefChann, excludeChann)
% 
% Inputs:
%   'setPath'       - [string] a path to the folder where .set files are to 
%                     be imported.
%   'reRefChann'    - [integer] one or more numbers indicating new
%                     reference channels.
%   'excludeChann'  - [integer] one or more numbers indicating channels to
%                     exclude.
% 
% Optional inputs:
%   'setFiles'  - [cell array] list of .set files (files have to be within
%                 setPath folder).
%
% Note: EEGLAB toolbox must be installed.

% if setFiles are not feeded, look for them
if isempty(setFiles)
    setFile = dir([setPath '/*.set']);
    setFile = {setFile.name};
end
   
for i = 1:size(setFile, 2)
    currSet = setFile(i);
    %     Load dataset
    tempEEG = pop_loadset('filename',char(currSet), 'filepath', char(setPath));
    %     Re-reference
    tempEEG  = pop_reref(tempEEG, reRefChann, 'exclude', excludeChann, 'keepref','on');    
    %     Save dataset
    pop_saveset(tempEEG  , 'filename', char(currSet),'filepath', fullfile(char(setPath)));
    
    %     Pogress indicator
    disp([num2str(i) '/' num2str(size(setFile, 2))])    
    
end

end