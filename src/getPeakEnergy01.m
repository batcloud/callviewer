function outputEnergy = getPeakEnergy01(x,fs,parameters),
% function outputEnergy = getPeakEnergy01(x,fs,parameters),
% This function finds the peak energy in each spectrogram frame (after normalization) and calculates
% average peak energy.
% Input:
%        x -- single- or multi-channel audio, int or double, 1 channel per COLUMN
%        fs -- sampling rate, Hz (default: 250000)
%        parameters -- structure of detection parameters, in same format used by callViewer program.
%            parameters.detection.windowSize -- ms, size of analysis frame (default: 1 ms)
%            parameters.detection.frameRate -- number of analysis frames per second (2000)
%            parameters.detection.chunkSize -- sec, chunk of data to process at one time (10 sec)
%            parameters.detection.HPFcutoff -- kHz, high-pass filter cutoff frequency (20 kHz)
%            parameters.detection.windowType -- 'Hamming', 'Hanning', 'Blackman', or 'Rectangle', ('Hamming') 
%            parameters.detection.SMS -- 1==use spectral mean subtraction; 0==use median scaling
% Output:
%        outputEnergy -- structure of energy peaks and average energy
%            outputEnergy.peakEnergy -- dB, 1xL vector of peak spectral energy, L frames 
%            outputEnergy.sTime -- sec, 1xL vector of time at center of each frame 
%            outputEnergy.meanEnergy -- dB, sum of peak energy across all frames / L (arithmetic mean)
%            outputEnergy.meanEnergydB -- dB, sum of log-compressed energy /L (geometric mean)

% Based on getCallEndpoints18.m, this file removes the links algorithm and echo filter and calculates
% average energy from spectral peaks.  All signal processing (spectrogram creation, SMS or median scaling)
% are retained.
% Mark Skowronski, November 15, 2007

% Based on version 17, this file uses links07.m, which uses the model-based links algorithm, using model
% parameters from linksTrainer05.m and linksModel.mat.  Also, a model-based echo filter, in echoModel.mat
% is used to remove echo links, and a rules-based harmonic detector from linksTrainer05.m is also included.
% Mark Skowronski, September 11, 2007

% Based on version 16, this file uses links06.m, which includes smoothness info in the cost function.
% Mark Skowronski, August 29, 2007

% Based on version 15, this file replaces the rules-based detector in previous versions with a 
% links detector.  Input and output have been adjusted accordingly.
% Mark Skowronski, August 20, 2007

% Based on version 14, this file uses getFeatures05.m, which changes how SMS and slope/concavity estimates
% are made.
% Mark Skowronski, February 14, 2007

% Based on version 13, this file includes more call statistics in output.callStatistics.
% Mark Skowronski, February 8, 2007

% Based on version 12, this file uses getFeatures04.m, which increases the neighborhood size used to find
% "smoothest" combo of FME harmonic numbers.
% Mark Skowronski, January 18, 2007

% Based on version 11, this file uses getFeatures02.m, which uses cepstral analysis to estimate F0 for each
% group of FMEs with the same harmonic number.
% Mark Skowronski, January 11, 2007

% Based on version 10, this file uses the latest version of getFeatures.m for feature extraction, including
% harmonic info (F0-F3) as well as delta features and smoothness features for F0 and A0.  Harmonic features
% are not determined by FMEJumpThresh or harmonicHopThresh, so harmonicHopThresh has been dropped and 
% FMEJumpThresh is used to determine the end of the call, similar to callStartThresh.
% Mark Skowronski, December 15, 2006

% Based on version 9, this file changes how spectral mean subtraction is performed.
% Mark Skowronski, November 29, 2006

% Based on version 8, this file cleans up the input/output parameters.  Also, the noise level is automatically
% determined and is used to automatically find frames to use to estimate the background for SMS.
% Mark Skowronski, November 7, 2006

% Based on version 7, this file includes sMean as input and output.  Useful for detecting calls in short files
% or files with lots of CF calls.
% Mark Skowronski, August 10, 2006

% Based on version 6, this file improves the echo masking by performing the masking on each bin of the spectrogram
% before finding [A0,F0] instead of performing masking on A0.  Also, the spectrogram output (before log compression)
% is truncated to the 5th percentile of non-zero magnitude values in order to avoid log(zero) warnings.
% Mark Skowronski, August 1, 2006

% Based on version 5, this file considers only a single dB level for determining endpoints.  Also, a simple
% call-trimming algorithm is used to find call onset and offset samples.  Call statistics are determined
% for each call with detected endpoints.  Values, such as duration, Fmin, Fmax, are determined for the part
% of the call between the detected endpoints, NOT between the onset and offset of the call.
% Mark Skowronski, July 31, 2006

% Based on version 4, this file includes an extra rule to the valid-call algorithm.  Regression around each
% F0 yields a regression error which is relatively low during an echolocation call since freq. modulation is
% relatively smooth.  Also, the masker was modified to consider all spectral values before a candidate peak, not
% just prior spectral peaks.
% Mark Skowronski, July 27, 2006

% Based on version 3, this file combines spectral mean estimates as the processing of each chunk proceeds.
% Also, the statistics of the spectral peaks of the noise are better estimated (used in adaptive threshold
% for rejected spectral peaks).
% Mark Skowronski, July 18, 2006

% Based on getCallEndpoints02.m, this file includes more input parameters in the argument list.
% Mark Skowronski, July 16, 2006

% Based on getCallEndpoints01.m, this file finds the -5, -10, -15, and -20 dB points from the peak level
% in order to establish timing events from which to calculate time delays and 3D positions.
% Mark Skowronski, July 15, 2006

% Version 1
% Mark Skowronski, July 14, 2006

% Check inputs:
if nargin<3,
   parameters = struct([]);
   parameters(1).detection = struct([]);
   parameters.detection(1).windowSize = .3; % ms
   parameters.detection.frameRate = 10000; % fps
   parameters.detection.chunkSize = 2; % sec
   parameters.detection.HPFcutoff = 15; % kHz
   parameters.detection.windowType = 'Blackman'; % 'Hamming', 'Hanning', 'Blackman', or 'Rectangle'
   parameters.detection.SMS = 0; % 1==use spectral mean subtraction; 0==use median scaling
end;
if nargin<2,
   fs = 250000; % Hz
end;

% Store detection parameters locally:
windowSize = parameters.detection.windowSize;
frameRate = parameters.detection.frameRate;
chunkSize = parameters.detection.chunkSize;
HPFcutoff = parameters.detection.HPFcutoff;
windowType = parameters.detection.windowType;
SMS = parameters.detection.SMS;

% Find parameters used to calculate spectrogram:
frameSize = round(windowSize/1000*fs); % samples
fftSize = 2^(nextpow2(frameSize)+2); % Increase FFT size for interpolation
frameIncrement = fs/frameRate; % samples/frame, fractional
hpfRow = round(HPFcutoff*1e3/fs*fftSize); % spectrogram row, rows 1..hpfRow removed from spectrogram for speed/memory

% Find number of chunks to process, non-overlapping:
numChunks = max(1,floor(size(x,1)/fs/chunkSize)); % Last bit in x used in last chunk

% Init spectrogram windowing function:
switch lower(windowType)
   case 'hamming'
      hamWindow = hamming(frameSize);
   case 'hanning'
      hamWindow = hanning(frameSize);
   case 'blackman'
      hamWindow = blackman(frameSize);
   case 'rectangle'
      hamWindow = ones(frameSize,1);
   otherwise
      hamWindow = hamming(frameSize);
end;

outputEnergy = struct([]); % init output struct
for pChannel = 1:size(x,2), % for each channel
   % Process each chunk:
   numFrames = 0; % used to find average energy across chunks
   peakEnergySum = 0; % not log-compressed, arithmetic mean
   peakEnergydBSum = 0; % dB, geometric mean
   peakEnergy = []; % dB, energy in each frame
   for pCh = 1:numChunks,
      % Get next chunk indeces:
      if pCh<numChunks,
         chunkIndex = [1:round(chunkSize*fs)]+round((pCh-1)*chunkSize*fs); % Index into x
      else
         chunkIndex = [1+round((pCh-1)*chunkSize*fs):size(x,1)]; % Go to end of x
      end;

      % Get spectrogram of chunk:
      x1 = double(x(chunkIndex,pChannel));
      x1 = x1-mean(x1);
      if sum(abs(x1))>0, % Process only if non zero.
         % Arrange x1 into a matrix of frames:
   %      [s,junk,sTimetemp] = spectrogram(x1,hamWindow,windowOverlap,fftSize,fs,'yaxis');
         numColumns = ceil(length(x1)/frameIncrement); % Number of frames in spectrogram
         x2 = [x1(:);zeros(frameSize,1)]; % Zero-pad to fit in m*l matrix
         x3 = zeros(frameSize,numColumns); % matrix of frames
         for pF=1:numColumns,
            x3(1:frameSize,pF) = x2([1:frameSize]+round((pF-1)*frameIncrement)).*hamWindow;
         end;
         s = fft(x3,fftSize,1);
         s = s(hpfRow+1:fftSize/2+1,1:numColumns); % Remove low-freq rows, faster computation, less memory
         s = real(s.*conj(s)); % Faster than abs(s).^2, removes residual imag part
         sTimeTemp = ([0:numColumns-1]*frameIncrement+frameSize/2)/fs; % sec, center of frame
         sTimeTemp = sTimeTemp+(pCh-1)*chunkSize; % sec, adjust time for current chunk

         if SMS==1, % apply spectral mean subtraction:
            sSort = sort(s(s>0));
            sCutoff = sSort(max(1,round(length(sSort)*.05))); % Truncate at 5th percentile of non-zero values
            s(s<sCutoff) = sCutoff;
            s = 10*log10(s); % dB
            clear sSort;

            % Perform SMS:
            s = s - mean(s,2)*ones(1,size(s,2));
         else % apply median scaling
            s = 10*log10(s);
            sMed = median(s(:));
            s(s<sMed) = sMed;
            s = s-sMed; % Place noise floor at 0 dB
         end;

         % Find peak energy, accumulate running variables:
         peakEnergyTemp = max(s); % dB, all frames in chunk
         peakEnergy1 = 10.^(peakEnergyTemp/10); % not log-compressed
         peakEnergySum = peakEnergySum + sum(peakEnergy1);
         peakEnergydBSum = peakEnergydBSum + sum(peakEnergyTemp); % dB
         numFrames = numFrames + length(peakEnergy1);

         % Update outputs:
         if isempty(peakEnergy),
            peakEnergy = peakEnergyTemp;
            sTime = sTimeTemp;
         else
            peakEnergy = [peakEnergy,peakEnergyTemp];
            sTime = [sTime,sTimeTemp];
         end;
      end; % if not all zeros in chunk
   end; % for each chunk

   % Save output:
   outputEnergy(pChannel).peakEnergy = peakEnergy; % dB
   outputEnergy(pChannel).sTime = sTime;
   outputEnergy(pChannel).meanEnergy = 10*log10(peakEnergySum/numFrames); % dB, averaged
   outputEnergy(pChannel).meanEnergydB = peakEnergydBSum/numFrames; % dB, averaged
end; % for each channel

return;

% Bye!
