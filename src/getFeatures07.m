function [outputGlobal,outputLocal] = getFeatures07(outputLinks,parameters),
%function [outputGlobal,outputLocal] = getFeatures07(outputLinks,parameters),
% This function extracts local/global call features from links.  The features are described
% as part of the output.  See links04.m for links description.
% Input:
%        outputLinks -- Nx1 cell array, N detected calls
%            outputLinks{n} -- Lx3 matrix [Hz,sec,dB] of n^th call, L frames
%        parameters -- structure of feature extraction parameters, in same format used by callViewer program.
%            parameters.detection.frameRate -- number of analysis frames per second (10000 fps)
%            parameters.detection.deltaSize -- frames, +/- number of frames around F0 used to estimate delta and smoothness features (3)
%        Note: any extra fields in parameters are ignored.
% Output:
%        outputGlobal -- structure of global features, same size as outputLinks
%            outputGlobal.startTime -- ms, time to center of first frame in link
%            outputGlobal.stopTime -- ms, time to center of last frame in link
%            outputGlobal.duration -- ms, link duration
%            outputGlobal.Fmin -- Hz, minimum link frequency
%            outputGlobal.Fmax -- Hz, maximum link frequency
%            outputGlobal.FPercentile -- Hz, 10th, 20th, ..., 90th percentile of frequency
%            outputGlobal.E -- dB, maximum energy
%            outputGlobal.FME -- Hz, frequency of maximum energy
%            outputGlobal.FMETime -- ms, time to E measured from link start
%            outputGlobal.dFmed -- kHz/ms, median frequency slope
%            outputGlobal.dEmed -- dB/ms, median energy slope
%            outputGlobal.ddFmed -- kHz/ms/ms, median frequency concavity
%            outputGlobal.ddEmed -- dB/ms/ms, median energy concavity
%            outputGlobal.sFmed -- dB, median frequency smoothness
%            outputGlobal.sEmed -- dB, median energy smoothness
%        outputLocal -- cell array of local features, same size as outputLinks
%            outputLocal{n} -- Lx9 matrix of local features, L frames:
%            [Freq(Hz),time(sec),energy(dB),dF(kHz/ms),dE(dB/ms),ddF(kHz/ms/ms),ddE(dB/ms/ms),sF(dB),sE(dB)]

% Based on version 5, this file extracts local/global features from links generated from links04.m and later.
% Mark Skowronski, August 20, 2007

% Based on version 4, this file adds uniform noise to F0 when making dF0, ddF0, and sF0 estimates.  Also,
% SMS uses *all* frames in a chunk to estimate the average power spectrum.
% Mark Skowronski, February 14, 2007

% Based on version 2 (not version 3), this file expands the local neighborhood used to find the "smoothest" combination
% of FME harmonic numbers.
% Mark Skowronski, January 18, 2007

% Based on getFeatures01, this file adds cepstral analysis to determine the presence of harmonics in a call.
% The FME for each frame may be the fundamental frequency or one of the first several harmonics.
% Mark Skowronski, January 8, 2007

% Based on getCallEndpoints10.m, this file drops the rules-based detector and only extracts frame-based features.
% Mark Skowronski, December 6, 2006

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
if nargin<2,
   parameters = struct([]);
   parameters(1).detection = struct([]);
   parameters.detection(1).frameRate = 10000; % fps
   parameters.detection.deltaSize = 1; % +/- frames
end;
if nargin<1,
   error('ERROR: no input links.');
   return;
end;

% Store detection parameters locally:
frameRate = parameters.detection.frameRate;
deltaSize = parameters.detection.deltaSize;

% Init linear regression variables:
z = [[-deltaSize:deltaSize]'/frameRate,ones(2*deltaSize+1,1)]; % generic abscissa matrix, [sec,unity]
C = inv(z'*z)*z'; % Hz, prefactor
C1 = C(1,:); % Hz, linear regression slope from first row of C
A = z*C; % unitless
B = (A-eye(2*deltaSize+1))'*(A-eye(2*deltaSize+1)); % unitless, used to find sum-of-squares error

% Get local/global features for each link:
outputLocal = cell(size(outputLinks));
%outputGlobal = struct('startTime',0,'stopTime',0,'duration',0,'Fmin',0,'Fmax',0,'FPercentile',[1:9],...
%   'E',0,'FME',0,'FMETime',0,'dFmed',0,'dEmed',0,'ddFmed',0,'ddEmed',0,'sFmed',0,'sEmed',0);
outputGlobal = struct([]);
for pOL=1:length(outputLinks),
   % Get local features:
   F0 = outputLinks{pOL}(:,1)'; % Hz, ROW vector
   A0 = outputLinks{pOL}(:,3)'; % dB, ROW vector
   F1 = [F0(ones(1,deltaSize)),F0,F0(length(F0)*ones(1,deltaSize))]; % pad endings
   A1 = [A0(ones(1,deltaSize)),A0,A0(length(A0)*ones(1,deltaSize))]; % pad endings
   dF0 = zeros(1,length(F0)); % Slope of F0
   dA0 = zeros(1,length(A0)); % Slope of A0
   ddF0 = zeros(1,length(F0)); % Concavity of F0
   ddA0 = zeros(1,length(A0)); % Concavity of A0
   sF0 = zeros(1,length(F0)); % Smoothness of F0
   sA0 = zeros(1,length(A0)); % Smoothness of A0
%   FNoisy = F1+(rand(size(F1))-.5)*fftRes; % Hz, dithered for non-zero smoothness
   FNoisy = F1; % Hz
   for p=1:length(dF0),
      F = FNoisy([0:2*deltaSize]+p)'; % COLUMN vector
      dF0(p) = C1*F; % slope for linear regression
      sF0(p) = F'*B*F; % sum-of-squares error for linear regression
      F = A1([0:2*deltaSize]+p)'; % COLUMN vector
      dA0(p) = C1*F;
      sA0(p) = F'*B*F;
   end;
   sF0 = max(40,10*log10(sF0/(2*deltaSize+1)+1)); % linear regression error, dB (averaged)
   sA0 = 10*log10(sA0/(2*deltaSize+1)); % linear regression error, dB (averaged)
   F1 = [dF0(ones(1,deltaSize)),dF0,dF0(length(dF0)*ones(1,deltaSize))]; % pad endings
   A1 = [dA0(ones(1,deltaSize)),dA0,dA0(length(dA0)*ones(1,deltaSize))]; % pad endings
   for p=1:length(dF0),
      F = F1([0:2*deltaSize]+p)'; % COLUMN vector
      ddF0(p) = C1*F; % concavity is slope of slope for linear regression
      F = A1([0:2*deltaSize]+p)'; % COLUMN vector
      ddA0(p) = C1*F;
   end;

   % Convert units on slope, concavity values:
   dF0 = dF0/1e6; % Hz/sec --> kHz/ms
   ddF0 = ddF0/1e9; % Hz/sec/sec --> kHz/ms/ms
   dA0 = dA0/1e3; % dB/sec --> dB/ms
   ddA0 = ddA0/1e6; % dB/sec/sec --> dB/ms/ms
   
   % Save local features -- Hz,sec,dB,kHz/ms,dB/ms,kHz/ms/ms,dB/ms/ms,dB,dB,echo dB:
   outputLocal{pOL} = [outputLinks{pOL}(:,1:3),dF0',dA0',ddF0',ddA0',sF0',sA0',outputLinks{pOL}(:,4)];
   
   % Save global features:
   % Start time(ms),End time(ms),Duration(ms),Fmin(Hz),Fmax(Hz),F0 percentiles(Hz),
   % FME(Hz),E(dB),FMETime(ms),median dF0(kHz/ms),median dA0(dB/ms),median ddF0(kHz/ms/ms),
   % median ddA0(dB/ms/ms), median sF0(dB), median sA0(dB)
   outputGlobal(pOL).startTime = outputLinks{pOL}(1,2)*1e3;
   outputGlobal(pOL).stopTime = outputLinks{pOL}(end,2)*1e3;
   outputGlobal(pOL).duration = outputLinks{pOL}(end,2)*1e3-outputLinks{pOL}(1,2)*1e3;
   outputGlobal(pOL).Fmin = min(F0);
   outputGlobal(pOL).Fmax = max(F0);
   fSort = sort(F0); % small to large
   outputGlobal(pOL).FPercentile = fSort(max(1,round([.1:.1:.9]*length(fSort))));
   [outputGlobal(pOL).E,temp] = max(A0);
   outputGlobal(pOL).FME = F0(temp);
   outputGlobal(pOL).FMETime = outputLinks{pOL}(temp,2)*1e3-outputLinks{pOL}(1,2)*1e3;
   outputGlobal(pOL).dFmed = median(dF0);
   outputGlobal(pOL).dEmed = median(dA0);
   outputGlobal(pOL).ddFmed = median(ddF0);
   outputGlobal(pOL).ddEmed = median(ddA0);
   outputGlobal(pOL).sFmed = median(sF0);
   outputGlobal(pOL).sEmed = median(sA0);
end;

% Bye!
