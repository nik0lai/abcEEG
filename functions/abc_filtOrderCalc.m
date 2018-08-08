function [filtorder] = abc_filtOrderCalc(sRate, highPassEnd, lowPassEnd)
% ABC_FILTORDERCALC calculates EEG filter order. This is usually calculated
% internally by EEGLAB. The following lines were taken from
% 'pop_eegfiltnew.m' (eeglab script). Use with one filter end at the time.
%

% Usage: abc_filtOrderCalc(sRate, lowEND, highEND)
%
% Inputs:
%   'sRate'         - [integer] number indicating EEG sampling rate.
%   'highPassEnd'   - [integer] number indicating lower edge of filter.
%   'lowPassend'    - [integer] number indicating higher edge of filter.
% 
% Outputs:
%   'filtorder'  - [integer] number indicating filt order to feed
%   pop_eegfiltnew().
%
% Note: EEGLAB toolbox must be installed.

%% Check min arguments
% Sampling rate
if ~isempty(sRate) && ~isnumeric(sRate)
    error(['Sampling rate (sRate) must be numeric.' newline...
        'You feed the function with a ' class(sRate)])
elseif isempty(sRate)
    error('A sampling rate (sRate) is needed to calculate filter order.')
end

% Filter thresholds
if isempty(highPassEnd) && isempty(lowPassEnd)
    error('One filter end (highPassEnd or lowPassend) must be set.')
elseif ~isempty(highPassEnd) && isempty(lowPassEnd)
    if ~isnumeric(highPassEnd)
        error(['Filter threshold end (highPassEnd) must be numeric.' newline...
        'You feed the function with a ' class(highPassEnd)])
    end
    
elseif isempty(highPassEnd) && ~isempty(lowPassEnd)
    if ~isnumeric(lowPassEnd)
        error(['Filter threshold end (lowPassEnd) must be numeric.' newline...
        'You feed the function with a ' class(lowPassEnd)])
    end
end
    
%% Calculate filter order

% Filter threshold
edgeArray = [highPassEnd lowPassEnd];

% Check if high pass or low pass filter
if isempty(highPassEnd) && ~isempty(lowPassEnd)
    revfilt = 0;
elseif ~isempty(highPassEnd) && isempty(lowPassEnd)
    revfilt = 1;
end

% Static parameters
TRANSWIDTHRATIO = 0.25;
fNyquist = sRate / 2;

maxTBWArray = edgeArray;
if revfilt == 0 % lowpass
    maxTBWArray = fNyquist - edgeArray;
end
maxDf = maxTBWArray;

% Default filter order heuristic
if revfilt == 1 % Highpass
    df = min([max([maxDf * TRANSWIDTHRATIO 2]) maxDf]);
else % Lowpass
    df = min([max([edgeArray * TRANSWIDTHRATIO 2]) maxDf]);
end

filtorder = 3.3 / (df / sRate); % Hamming window
filtorder = ceil(filtorder / 2) * 2; % Filter order must be even.

end