function outputQuick = getQuickSummary01(x,fs,parameters),
% function outputQuick = getQuickSummary01(x,fs,parameters),
% This function performs a fast search for bat calls using energy calculated in the
% time domain and thresholds.  High-pass and band-pass filtering options are available.
% Input: 
%        x -- audio input, int or double, single- or multi-channel
%        fs -- sampling rate, Hz (default: 250000)
%        parameters -- structure of detection parameters, in same format used by callViewer program.
%            parameters.detection.LPFcutoff -- kHz, low-pass filter cutoff frequency, inf==Nyquist (inf)
%            parameters.detection.HPFcutoff -- kHz, high-pass filter cutoff frequency (15 kHz)
% Output:

% Based on fastDetect02.m, this file incorporates the methods in fastDetect02 into a callViewer-ready
% function call.
% Mark Skowronski, December 14, 2007

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

% Parameters:
windowSize = 5; % ms, energy frame
callWindow = 3; % frames, +/- local peak window
passWindow = 150; % frames, minimum inter-pass interval
detectThreshAll = [5,10,15,20,30,40,50]; % dB, above the noise floor
Rp = 2; % dB, passband ripple
Rs = 80; % dB, stopband suppression for HPF/BPF

numCh = size(x,2);

% Check inputs:
if nargin<3,
   parameters = struct([]);
   parameters(1).detection = struct([]);
   parameters.detection(1).LPFcutoff = inf; % kHz
   parameters.detection.HPFcutoff = 15; % kHz
end;
if nargin<2,
   fs = 250000; % Hz
end;

% Store detection parameters locally:
LPFcutoff = parameters.detection.LPFcutoff;
HPFcutoff = parameters.detection.HPFcutoff;

% Design filter:
if isinf(LPFcutoff), % HPF only
   [N,Ws] = ellipord(HPFcutoff*1e3/fs*2,max(5*1e3/fs*2,(HPFcutoff-5)*1e3/fs*2),Rp,Rs);
   [b,a] = ellip(N,Rp,Rs,Ws,'high');
else
   [N,Ws] = ellipord([HPFcutoff,LPFcutoff]*1e3/fs*2,...
      [max(5*1e3/fs*2,(HPFcutoff-5)*1e3/fs*2),min((fs/2-5e3)/fs*2,(LPFcutoff+5)*1e3/fs*2)],Rp,Rs);
   [b,a] = ellip(N,Rp,Rs,Ws);
end;

% Find energy using non-overlapping frames:
numFrames = floor((size(x,1)/fs)/(windowSize*1e-3)); % Drop last little bit
eFrame = zeros(numFrames,numCh);
L = round(windowSize*1e-3*fs); % samples
for p1=1:numCh,
   for p=1:numFrames,
      xFrame = fastIIR01(b,a,double(x([1:L]+round((p-1)*windowSize*1e-3*fs),p1))); % COLUMN vector, HPFed
      eFrame(p,p1) = xFrame'*xFrame;
   end;
end;

% Estimate noise floor:
mFrame = median(eFrame);
for p1=1:numCh,
   if mFrame(p1)==0,
      mFrame(p1) = median(eFrame(eFrame(:,p1)>0,p1));
      if isnan(mFrame(p1)), % if all eFrame values are zero
         mFrame(p1) = 1;
      end;
   end;
end;
   
% Scale:
if numCh==1,
   eNorm = eFrame/mFrame; % Noise floor at unity
else
   eNorm = eFrame./repmat(mFrame,numFrames,1);
end;
eNorm = 10*log10(eNorm); % dB
eNorm(eNorm<-10) = -10; % clip outliers

% Count calls/passes:
numCalls = zeros(length(detectThreshAll),numCh);
numPasses = zeros(length(detectThreshAll),numCh);
callIndexAll = cell(length(detectThreshAll),numCh);
for p1=1:numCh,
   for p2=1:length(detectThreshAll),
      detectThresh = detectThreshAll(p2);
      callIndex = []; % grow dynamically

      % Find frames above energy threshold:
      k = find(eNorm(:,p1) >= detectThresh); % COLUMN, index into eNorm(:,p1)

      if ~isempty(k),
         % Find contiguous sets of indeces:
         kStart = find(diff([-10;k])>1); % Index into k
         kEnd = [kStart(2:end)-1;length(k)];
         kStart = k(kStart); % Index into eNorm(:,p1)
         kEnd = k(kEnd);

         % Find segment maxima:
         callIndex = []; % ROW vector, dynamically grown
         for p=1:length(kStart),
            [junk,tempIndex] = max(eNorm(kStart(p):kEnd(p),p1));
            tempIndex = tempIndex+kStart(p)-1; % Index into eNorm
            if eNorm(tempIndex,p1) == max(eNorm(max(1,tempIndex-callWindow):min(size(eNorm,1),tempIndex+callWindow),p1)),
               callIndex(end+1) = tempIndex;
            end;
         end;
         callIndexAll{p2,p1} = callIndex;

         % Count calls:
         numCalls(p2,p1) = length(callIndex);

         % Count passes:
         callIndexDiff = diff([-1000,callIndex]);
         numPasses(p2,p1) = sum(callIndexDiff>=passWindow);
      end;
   end;
end;

% Store output:
outputQuick = struct([]);
outputQuick(1).numCalls = numCalls;
outputQuick.numPasses = numPasses;
outputQuick.detectThreshAll = detectThreshAll;
outputQuick.eNorm = eNorm;
outputQuick.t = ([1:numFrames]-1/2)*windowSize*1e-3; % sec
outputQuick.callIndexAll = callIndexAll; % index into eNorm, t

return;

% Bye!
