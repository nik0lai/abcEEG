function [files] = abc_check_files(files, path, fileType)
% ABC_CHECK_FILES check files (set/bdf) feeded to function. If empty vector
% is feeded as file list, search for files on feeded path.
% 
% Usage: abc_check_files(files, path, fileType)
% 
% Inputs:
%   'setPath'       - [string] a path to the folder where .set files are to be
%                     imported.
%   'fileType'      - [string] file extension (set, or bdf).
%
% Optional inputs:
%   'setFiles'  - [cell array] list of .set files (files have to be within 
%                 setPath folder).
%

% If is not empty, must be a cell
if ~isempty(files)
    
    % Check if file list is a cell
    if ~iscell(files)
        error(['List with .set files names must be a cell.' newline ...
            'You feed the function with a ' class(files)])
    end
    
  
elseif isempty(files)  % If empty, get everything within the files folder.
    
    % Get files
    files = dir(fullfile(path, ['*.' fileType]));
    files = {files.name};
    
    % Break if no files founded
    if numel(files) == 0
        error(['There are no .' fileType ' files on ' newline ...
            path])
    end
    
end

end