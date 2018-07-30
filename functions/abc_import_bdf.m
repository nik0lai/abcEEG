function [importTrack] = abc_import_bdf(bdfPath, setPath, newSrate, bdfFiles, bdfDoneDir)
% ABC_IMPORT_BDF import data using pop_biosig() (BIOSIG toolbox) and,
% optionally, change the sampling rate of the imported data. Parallel
% processing available if possible.
% 
% Usage: abc_import_bdf(64, bdfFiles, bdfPath, setPath, bdfDoneDir)
% 
% Inputs:
%   'bdfPath'   - [string] a path to the folder with .bdf files to import.
%   'setPath'   - [string] a path to the folder where .set files are to be
%                 imported.
% 
% Optional inputs:
%   'newSrate'  - [integer] number indicating new sampling rate. Must be
%                 lower than current sampling rate.
%   'bdfFiles'  - [cell array] list of .bdf files to import (files have to 
%                 be within bdfPath folder).
%   'bdfDoneDir'- [string] a path to the folder where imported .bdf files
%                 are to be moved.
% Outputs:
%   importTrack - table with information about imported .bdf files.
% 
% Note: EEGlab and BIOSIG toolbox must be installed.

%% Files to import:

% If list with files is not empty, check if it's a cell
if ~isempty(bdfFiles)
    if ~iscell(bdfFiles)
        error(['List with .bdf files names must be a cell.' newline ...
            'You feed the function with a ' class(bdfFiles)])
    end
    % If empty, get everything within the bdf folder.
elseif isempty(bdfFiles)
    bdfFiles = dir(fullfile(bdfPath, '/*.bdf'));
    bdfFiles = {bdfFiles.name};
end

if ~size(bdfFiles, 2) > 0
    error(['Are you messing with me? No bdf files within ' bdfPath])
    
% Iterate through bdf files
elseif size(bdfFiles, 2) > 0
    
    % Track pre-processing info.
    % % Old rate
    % % New rate
    % % Number of channels
    % % EEG duration
    
    %     srateCols   = array2table(zeros(size(bdfFiles, 2), 4),'VariableNames', {'oldRate', 'newRate', 'channNum', 'eegDur'});
    %     resampTrack = [table(bdfFiles', 'VariableNames', {'name'}) srateCols];
    %     resampTrack = zeros(size(bdfFiles, 2), 4);    
    
    oldRate = zeros(size(bdfFiles, 2), 1);
    newRate = zeros(size(bdfFiles, 2), 1);
    chanNum = zeros(size(bdfFiles, 2), 1);
    eegDur  = zeros(size(bdfFiles, 2), 1);
        
    % date only
    date = cell(size(bdfFiles, 2), 1);
    
    parfor i = 1:size(bdfFiles, 2)
        bdfFileTmp = char(bdfFiles(i));
        
        % read dataset, change name
        tmpEEG = pop_biosig(fullfile(bdfPath, bdfFileTmp));
        tmpEEG = pop_editset(tmpEEG, 'setname', bdfFileTmp(:,1:length(bdfFileTmp)-4)); % asign dataset name using bdf file name
        
        
        if tmpEEG.srate < newSrate
            warning(['On ' bdfFileTmp ' subject. New sampling rate is bigger than actual sampling rate'])
        elseif tmpEEG.srate == newSrate
            warning(['On ' bdfFileTmp ' subject. New sampling rate is equal to actual sampling rate'])
        elseif tmpEEG.srate > newSrate            
            
            oldRate(i) = tmpEEG.srate; % track info: original sample rate
%             resampTrack(i, 1) = tmpEEG.srate; % track info: original sample rate
            
            tmpEEG = pop_resample(tmpEEG, newSrate); % re-sample eeg.
            
            newRate(i) = tmpEEG.srate;       % track info: new sample rate
            chanNum(i) = tmpEEG.nbchan;      % track info: number of channels
            eegDur(i)  = round(tmpEEG.xmax); % track info: eeg duration
%             resampTrack(i, 2) = tmpEEG.srate;       % track info: new sample rate
%             resampTrack(i, 3) = tmpEEG.nbchan;      % track info: number of channels
%             resampTrack(i, 4) = round(tmpEEG.xmax); % track info: eeg duration
            date(i, 1)        = {char(datetime)};     % date
            
            %% Messages
            disp('**********************************')
            disp(['On ' bdfFileTmp ' the sample rate is: ' num2str(tmpEEG.srate) ' Hz'])
            disp(['number of channels: ' num2str(tmpEEG.nbchan)])
            disp(['eeg duration: ' num2str(fix(tmpEEG.xmax)) ' seconds'])
            disp([num2str(i) '/' num2str(size(bdfFiles, 2))])
            % size(EEG.times,2)/EEG.srate
            disp('**********************************')
            
            %% save dataset
            [~, ~, ~] = mkdir(setPath);
            pop_saveset( tmpEEG, 'filename', bdfFileTmp,'filepath',setPath);
            
            % Move bdf file to done folder
            comandMove = ['mv ' fullfile(bdfPath, bdfFileTmp) ' ' bdfDirDonner];
            system(comandMove);            
            
        end
    end
end

% Build resamplingtracking table    
    resampTrack = [cell2table(bdfFiles', 'VariableNames', {'files'}) cell2table(num2cell([oldRate newRate chanNum eegDur]), 'VariableNames', {'oldRate', 'newRate', 'chanNum', 'eegDuration'}) table(date)];  
    
% resampTrack = [resampTrack table(date)];

end
