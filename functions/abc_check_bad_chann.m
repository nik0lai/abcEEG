
% path to datasets
setPath = '/home/niki/Documents/eegeses/fdcyt_agustin/newset/preIca/';
% datasets
% setFiles = dir(fullfile(setPath, '*411*.set'));
setFile = [];

%%
% if no set files received, look for them.
if isempty(setFile)
    setFile = dir([setPath '/*.set']);
    setFile = {setFile.name};
end

%%
for i = 1:size(setFile,2)
        
    % Read EEG
    tempEEG = pop_loadset('filename', setFile{i}, 'filepath', char(setPath));    
    %%
    % Plot scroll
    pop_eegplot( tempEEG, 1, 1, 1); title(tempEEG.setname, 'Interpreter', 'none') % plot scroll to inspect EEG
    %%
    % remove external channs
    intEEG = pop_select( tempEEG, 'channel', 1:128);
    
    % Plot spectra map
    % 1 - 50HZ
    figure; pop_spectopo(intEEG, 1, [0 intEEG.xmax], 'EEG' , 'freq', [6 10 22], 'freqrange',[1 50],'electrodes','off'); title(intEEG.setname, 'Interpreter', 'none')
    % 1 - 35HZ
    figure; pop_spectopo(intEEG, 1, [0 intEEG.xmax], 'EEG' , 'freq', [6 10 22], 'freqrange',[1 35],'electrodes','off'); title(intEEG.setname, 'Interpreter', 'none')
    
    %% Duplicated
    [~, ia, ~] = unique(tempEEG.data, 'rows');
    
    %% who's?
    disp(['****************************' newline 'DISPLAYING: ' setFile{i} newline 'DUPLICATED CHANNS: ' strrep(num2str(setdiff(1:137, ia)), '  ', ',') newline '***************************']);
    
    %%
    pause()
    
    %%
    close all
end