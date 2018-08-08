function [] = abc_bad_comp(setFiles, setPath, specFreqRange, plotComp, badChanns)
% ABC_BAD_COMP pop-up plots to identify bad channels using pop_eegplot(),
% pop_spectopo() (EEGLAB Toolbox).
%
% Usage: abc_bad_comp(setFiles, setPath, specFreqRange, channExclude)
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
%   'plotComp'      - [integer] number of components to plot (no more than
%                     number of channels).
%   'badChanns'     - [integer] number or numbers indicating artifactual
%                     channels to exclude from scroll plot.
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

%% Files to check
setFiles = abc_check_files(setFiles, setPath, 'set');

%% Plot
for i = 1:numel(setFiles)
    currSet = setFiles{i};
    
    % Read EEG
    tmpEEG = pop_loadset('filename', currSet, 'filepath', setPath);
    
    %% Components
    % Number of components to plot
    pop_selectcomps(tmpEEG, 1:plotComp);
    % Components scroll
    pop_eegplot(tmpEEG, 0, 1, 1); title(tmpEEG.setname, 'Interpreter', 'none')
    % Components spectra power
    figure; pop_spectopo(tmpEEG, 0, [0 tmpEEG.xmax], 'EEG' , 'freq', [10], 'plotchan', 0, 'icacomps', 1:size(tmpEEG.icawinv, 2), 'nicamaps', 5, 'freqrange', specFreqRange,'electrodes','off'); title(tmpEEG.setname, 'Interpreter', 'none')      
    
    %% Channels plots (remove bad channels)
    
    % Get good channels
    currGut = setdiff(1:128, badChanns);
    
    % create EEG with good channels
    gutEEG = pop_select(tmpEEG, 'channel', currGut);
    
    % Plot scroll with good channels
    pop_eegplot(gutEEG, 1, 1, 1); title(gutEEG.setname, 'Interpreter', 'none') % plot scroll to inspect EEG
    
    % Plot spectra map
    figure; pop_spectopo(gutEEG, 1, [0 gutEEG.xmax], 'EEG' , 'freq', [6 10 22], 'freqrange', specFreqRange,'electrodes','off'); title(gutEEG.setname, 'Interpreter', 'none')
    
    %% Duplicated channels
    [~, ia, ~] = unique(gutEEG.data, 'rows');
    
    % who's duplicated?
    disp(['****************************' newline ...
        'DISPLAYING: ' setFiles{i} newline ...
        'DUPLICATED CHANNS: ' strrep(num2str(setdiff(1:gutEEG.nbchan, ia)), '  ', ',') newline ...
        'BAD CHANNS: ' num2str(badChanns) newline '***************************'])
    
    %% Pause to check things
    pause()
    
    %% Close all figures
    close all
end