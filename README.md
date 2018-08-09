# Automatic Batch EEG-signal Cleaning (abcEEG) Toolbox

__This is a work in progress__. If you are using this toolbox and have any suggestion, problem, bug report, etc., please open an issue.  

Some time ago I started to work collecting and preprocessing EEG data. My first approach was to use EEGLAB's GUI. Although this was a good first approach for learning, the process of repeating the same several steps through a long list of files was too error-prone for me. Because of this, I create several scripts on MATLAB to automatize most parts of the process.  

This Toolbox is the result of that process of automatization and learning. People familiar with coding and MATLAB will consider the Toolbox trivial, and they're right. The toolbox will be useful for people that need to preprocess EEG data without actually knowing how to code using MATLAB. Also, it can be used to keep an organization and clean framework when preprocessing several EEG files.  

The current form of the toolbox pretends to satisfy my particular needs when preprocessing. Some other functionalities can be implemented in the future. Feel free to suggest whatever you think it could be a good improvement.  

I do not own any of the EEGLAB functions called within this Toolbox. As result, EEGLAB and ERPLAB Toolboxes have to installed along abcEEG.  
