function [] = abc_filtering(setFiles, setPath, highPassFilter, lowPassFilter)
% ABC_FILERING apply fitlers using pop_eegfiltnew() (EEGLAB Toolbox). A low
% and/or high pass filter can be applied in different calls
% (non-simultaneously).
%
% Usage: abc_filtering(setFiles, setPath, highPassFilter, lowPassFilter)
%
% Inputs:
%   'setPath'       - [string] a path to the folder where .set files are to be
%                     imported.
%   'highPassFilter'- [integer] number indicating lower edge of filter.
%   'lowPassFilter' - [integer] number indicating higher edge of filter.
%
% Optional inputs:
%   'setFiles'  - [cell array] list of .set files (files have to be within
%                 setPath folder).
%
% Note: EEGLAB toolbox must be installed.

if isempty(saveOrNotToSave)
    saveOrNotToSave = 1;
end

if isempty(setFiles)
    setFile = dir([setPath '/*.set']);
    setFile = {setFile.name};
end

parfor i = 1:size(setFile, 2)
    currSet = setFile(i);
    
    tempEEG = pop_loadset('filename',char(currSet), 'filepath', char(setPath));
    
    %     filtering
    %     tempEEG = pop_eegfiltnew(tempEEG, [],lowPassEnd,846,1,[],0);
    %     tempEEG = pop_eegfiltnew(tempEEG, [],lowPassEnd,1690,1,[],0); % 256
    
    filtOrderHighpass = filtorderCalc(tempEEG.srate, lowPassEnd, []);
    tempEEG = pop_eegfiltnew(tempEEG, [],lowPassEnd, filtOrderHighpass,1,[],0); % 256
    
    %     tempEEG = pop_eegfiltnew(tempEEG, [],highPassEnd,58,0,[],0);
    %     tempEEG = pop_eegfiltnew(tempEEG, [],highPassEnd, 114,0,[],0); % 256
    
    filtOrderLowpass = filtorderCalc(tempEEG.srate, [], highPassEnd);
    tempEEG = pop_eegfiltnew(tempEEG, [],highPassEnd, filtOrderLowpass,0,[],0); % 256
    
    %     EDIT NAME
    tempEEG = pop_editset(tempEEG, 'setname', [tempEEG.setname 'f']);
    
    if (saveOrNotToSave == 0)
        filteredEEG = tempEEG;
    elseif (saveOrNotToSave == 1)
        pop_saveset(tempEEG, 'filename', char(currSet),'filepath', char(setPath));
    end
    
    disp('*****************************************')
    disp(['highpass: ' num2str(filtOrderHighpass)])
    disp(['lowpass: ' num2str(filtOrderLowpass)])
    disp([num2str(i) '/' num2str(size(setFile, 2))])
    disp('*****************************************')
    
end

end
