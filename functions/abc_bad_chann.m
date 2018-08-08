function [] = abc_bad_chann(setFiles, setPath, specFreqRange, channExclude)
% ABC_BAD_CHANN pop-up plots to identify bad channels using pop_eegplot(),
% pop_spectopo() (EEGLAB Toolbox).
%
% Usage: abc_bad_chann(setFiles, setPath, specFreqRange, channExclude)
%
% Inputs:
%   'setPath'       - [string] a path to the folder where .set files are
%                     to be imported.
%   'specFreqRange' - [integer] two numbers indicating a frequency range to
%                     plot spectra maps.
%
% Optional inputs:
%   'setFiles'      - [cell array] list of .set files (files have to be
%                     within setPath folder).
%   'channExclude'  - [integer] one or more numbers to plot a second scroll
%                     and spectra map without them.
%
% Note: EEGLAB toolbox must be installed.

%% Check min arguments
% .set files
if isempty(setPath)
    error(['A path to the folder with .set files has to be set.' newline ...
        'Your parth is: ' setPath])
end

% Frequency range
if isempty(specFreqRange)
    error(['Two numbers to use as frequency range are needed to plot a spectra maps.'])
elseif ~isempty(specFreqRange) && ~isnumeric(specFreqRange)
    error(['Frequency range must be numeric.' newline ...
        'You feed the function with a ' class(specFreqRange)])
end

%% Files to create ECG
setFiles = abc_check_files(setFiles, setPath, 'set');

%% Plot!
for i = 1:numel(setFiles)
    currSet = setFiles{i};
    
    % Read EEG
    tmpEEG = pop_loadset('filename', currSet, 'filepath', setPath);
    
    %% Complete EEG
    % Scroll
    pop_eegplot(tmpEEG, 1, 1, 1); title(tmpEEG.setname, 'Interpreter', 'none') % Plot scroll to inspect EEG
    % Spectra map
    figure; pop_spectopo(tmpEEG, 1, [0 tmpEEG.xmax], 'EEG' , 'freq', [6 10 22], 'freqrange', specFreqRange, 'electrodes', 'off'); title(tmpEEG.setname, 'Interpreter', 'none')
    
    %% Exclude channels
    if ~isempty(channExclude)
        
        % remove external channs
        excludedEEG = pop_select(tmpEEG, 'channel', setdiff(1:tmpEEG.nbchan, channExclude));
        
        % Scroll
        pop_eegplot(excludedEEG, 1, 1, 1); title(['EXCLUDED_' excludedEEG.setname], 'Interpreter', 'none') % Plot scroll to inspect EEG
        % Spectra map
        figure; pop_spectopo(excludedEEG, 1, [0 excludedEEG.xmax], 'EEG' , 'freq', [6 10 22], 'freqrange', specFreqRange, 'electrodes', 'off'); title(['EXCLUDED_' excludedEEG.setname], 'Interpreter', 'none')
        
    end
    
    %% Duplicated channels?
    [~, ia, ~] = unique(tmpEEG.data, 'rows');
    
    % who's duplicated?
    disp(['****************************' newline ...
        'DISPLAYING: ' setFiles{i} newline ...
        'DUPLICATED CHANNS: ' strrep(num2str(setdiff(1:tmpEEG.nbchan, ia)), '  ', ',') newline ...
        '***************************']);
    
    %% Wait to check
    pause()
    
    %% Close figures
    close all
    
end
end