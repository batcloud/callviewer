function [outputGlobal,outputLocal,s] = getCallEndpoints18(x,fs,parameters),
% function output = getCallEndpoints18(x,fs,parameters),
% This function uses rules-based links to outline calls in x and also extracts local/global features.
% Input: 
%        x -- single-channel audio, int or double
%        fs -- sampling rate, Hz (default: 250000)
%        parameters -- structure of detection parameters, in same format used by callViewer program.
%            parameters.detection.windowSize -- ms, size of analysis frame (default: 1 ms)
%            parameters.detection.frameRate -- number of analysis frames per second (2000)
%            parameters.detection.chunkSize -- sec, chunk of data to process at one time (10 sec)
%            parameters.detection.HPFcutoff -- kHz, high-pass filter cutoff frequency (20 kHz)
%            parameters.detection.windowType -- 'Hamming', 'Hanning', 'Blackman', or 'Rectangle', ('Hamming') 
%            parameters.detection.deltaSize -- frames, +/- number of frames around F0 used to estimate linear regression error (3)
%            parameters.links.linkLengthMinFrames -- frames, minimum link length
%            parameters.links.baselineThreshold -- dB, minimum link peak energy
%            parameters.links.trimThreshold -- dB, link endpoints below threshold are trimmed off
% Output: 
%        outputGlobal -- Nx1 structure of global features, N detected links
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
%            outputGlobal.numCall -- index of call in sequence of N detected links
%            outputGlobal.numHarmonic -- estimated harmonic number; 1==fundamental, 2==2nd harmonic, etc.
%        outputLocal -- cell array of local features, same size as outputGlobal
%            outputLocal{n} -- Lx9 matrix of local features, L frames:
%            [Freq(Hz),time(sec),energy(dB),dF(kHz/ms),dE(dB/ms),ddF(kHz/ms/ms),ddE(dB/ms/ms),sF(dB),sE(dB)]

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
windowPreviousLinks = 70e-3; % sec, window to look back for max E, for echoes
harmonicThresh = 1e-4; % squared standard error threshold for assigning harmonic ratio

load linksModel.mat linksModel;
load echoModel.mat echoModel;

% Check inputs:
if nargin<3,
   parameters = struct([]);
   parameters(1).detection = struct([]);
   parameters.detection(1).windowSize = .3; % ms
   parameters.detection.frameRate = 10000; % fps
   parameters.detection.chunkSize = 2; % sec
   parameters.detection.HPFcutoff = 15; % kHz
   parameters.detection.windowType = 'Blackman'; % 'Hamming', 'Hanning', 'Blackman', or 'Rectangle'
   parameters.detection.deltaSize = 1; % +/- frames
   parameters.detection.SMS = 0; % 1==use spectral mean subtraction; 0==use median scaling
   parameters(1).links = struct([]);
   parameters.links(1).linkLengthMinFrames = 6; % frames
   parameters.links.baselineThreshold = 20; % dB
   parameters.links.trimThreshold = 10; % dB
end;
if nargin<2,
   fs = 250000; % Hz
end;
if min(size(x))~=1,
   error('ERROR: x must be single channel.');
   return;
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
numChunks = max(1,floor(length(x)/fs/chunkSize)); % Last bit in x used in last chunk

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

% Process each chunk:
outputGlobal = struct([]);
outputLocal = cell(0,1);
for pCh = 1:numChunks,
   % Get next chunk indeces:
   if pCh<numChunks,
      chunkIndex = [1:round(chunkSize*fs)]+round((pCh-1)*chunkSize*fs); % Index into x
   else
      chunkIndex = [1+round((pCh-1)*chunkSize*fs):length(x)]; % Go to end of x
   end;

   % Get spectrogram/link of chunk:
   x1 = double(x(chunkIndex));
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
      sTimetemp = ([0:numColumns-1]*frameIncrement+frameSize/2)/fs; % sec, center of frame

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
      
      % Get links:
      XAll = struct([]);
      XAll(1).X = s;
      XAll.f = ([1:size(s,1)]'-1+hpfRow)*fs/fftSize*1e-3; % kHz
      XAll.t = sTimetemp*1e3; % ms
      outputLinks = links07(XAll,parameters,linksModel);

      % For each link, find spectral max in previous window:
      for p=1:length(outputLinks), % for each link
         t = [outputLinks{p},zeros(size(outputLinks{p},1),1)]; % [FFT bin,frame,dB,mask dB]
         for p1=1:size(t,1), % for each frame
            t(p1,4) = max(s(t(p1,1),[max(1,t(p1,2)-round(windowPreviousLinks*frameRate)):t(p1,2)]));
         end;
         outputLinks{p} = t; % save
      end;

      % Adjust time/frequency for each link:
      for p=1:length(outputLinks),
         outputLinks{p}(:,1) = (outputLinks{p}(:,1)+hpfRow-1)/fftSize*fs; % Hz
         outputLinks{p}(:,2) = sTimetemp(outputLinks{p}(:,2))'+(pCh-1)*chunkSize; % sec
      end;
      
      % Get local/global features:
      [outputGlobalTemp,outputLocalTemp] = getFeatures07(outputLinks,parameters);
      
      % Update outputs:
      if isempty(outputGlobal),
         outputGlobal = outputGlobalTemp;
         outputLocal = outputLocalTemp;
      else
         for p=1:length(outputGlobalTemp),
            outputGlobal(end+1) = outputGlobalTemp(p);
            outputLocal{end+1} = outputLocalTemp{p};
         end;
      end;
   end; % if not all zeros in chunk
end; % for each chunk

if ~isempty(outputLocal),
   % Count number of links:
   numLinks = length(outputLocal);

   % Collect (global) cost terms for echo filter:
   costTerms = zeros(5,numLinks); % duration(sec),E(dB),sFmed(dB),maskEnergyMed(dB),dFmed(kHz/ms)
   for p=1:numLinks, % first link assumed not an echo
      % F(Hz),time(sec),E(dB),dF(kHz/ms),dE(dB/ms),ddF(kHz/ms/ms),ddE(dB/ms/ms),sF(dB),sE(dB),echo energy(dB):
      z = outputLocal{p};

      % Adjust sF, truncate values at 40 so that sF appears more Gaussian in distribution:
      z(z(:,8)<40,8) = 40;

      costTerms(1:5,p)=[(size(z,1)-1)/parameters.detection.frameRate;max(z(:,3));median(z(:,8));...
         median(z(:,10)-z(:,3));median(z(:,4))];
   end;

   % Compute likelihoods:
   LLcall = evaluateGMM(costTerms,echoModel(1));
   LLecho = evaluateGMM(costTerms,echoModel(2));
   isCallModel = LLcall>=(LLecho+parameters.links.baselineThreshold); % 1==link is a call (fundamental or harmonic); 0==not a call (echo or harmonic)

   % Get endpoints for each link:
   linkEndpoints = zeros(numLinks,2); % sec, [start,end]
   for p=1:numLinks,
      % F(Hz),time(sec),E(dB),dF(kHz/ms),dE(dB/ms),ddF(kHz/ms/ms),ddE(dB/ms/ms),sF(dB),sE(dB),echo energy(dB):
      z = outputLocal{p};
      linkEndpoints(p,1:2) = [z(1,2),z(end,2)];
   end;

   % Determine harmonic relationships among overlapping calls:
   harmonicStats = struct([]);
   for p=1:numLinks,
      h = linkEndpoints(p,:); % sec, [start time, end time]
      overlappingCalls = find([1:numLinks]'~=p & ...
         ((linkEndpoints(:,1)<=h(1) & linkEndpoints(:,2)>=h(1)) | ...
         (linkEndpoints(:,1)>=h(1) & linkEndpoints(:,2)<=h(2)) | ...
         (linkEndpoints(:,1)<=h(2) & linkEndpoints(:,2)>=h(2)))); % not self-referenced, straddle t(1)/t(2) or in between
      harmonicStats(p).overlappingCalls = overlappingCalls';

      if isempty(overlappingCalls),
         harmonicStats(p).ratioMean = 1;
         harmonicStats(p).ratioVar = 0;
         harmonicStats(p).ratioN = 0;
         harmonicStats(p).overlapPercentage = 0;
         harmonicStats(p).FratioOverlap = []; % Fratio = FoverlappingLink/FcurrentLink
         harmonicStats(p).FratioCurrent = [];
         harmonicStats(p).ratioSE = [];
      else
         % Determine harmonic ratio mean and variance w/ all overlapping links:
         ratioMean = zeros(1,length(overlappingCalls));
         ratioVar = zeros(1,length(overlappingCalls));
         ratioN = zeros(1,length(overlappingCalls)); % frames
         overlapPercentage = zeros(1,length(overlappingCalls));
         FratioOverlap = zeros(1,length(overlappingCalls)); % Fratio
         FratioCurrent = zeros(1,length(overlappingCalls)); % Fratio
         ratioSE = zeros(1,length(overlappingCalls)); % ratioVar/ratioN

         % Get frequencies of current link:
         Fcurrent = outputLocal{p}(:,1); % F(Hz),time(sec),E(dB),dF(kHz/ms),dE(dB/ms),ddF(kHz/ms/ms),ddE(dB/ms/ms),sF(dB),sE(dB),echo energy(dB)
         for p1=1:length(overlappingCalls),
            hOverlap = linkEndpoints(overlappingCalls(p1),1:2);

            % Get frequencies of overlapping link:
            Foverlap = outputLocal{overlappingCalls(p1)}(:,1); % Hz

            % Compute ratio of overlapping parts:
            FcurrentStart = max(1,1+round((hOverlap(1)-h(1))*parameters.detection.frameRate)); % frames
            FcurrentEnd = min(length(Fcurrent),length(Fcurrent)+round((hOverlap(2)-h(2))*parameters.detection.frameRate));
            FoverlapStart = max(1,1+round((h(1)-hOverlap(1))*parameters.detection.frameRate));
            FoverlapEnd = min(length(Foverlap),length(Foverlap)+round((h(2)-hOverlap(2))*parameters.detection.frameRate));
            Fratio = Foverlap(FoverlapStart:FoverlapEnd)./Fcurrent(FcurrentStart:FcurrentEnd);

            % Save stats:
            if length(Fratio)>1,
               ratioMean(p1) = median(Fratio); % more robust to outliers due to untrimmed endpoints
               if ratioMean(p1)>1,
                  [FratioOverlap(p1),FratioCurrent(p1)] = rat(ratioMean(p1),.1);
                  ratioVar(p1) = var(Fratio);
               else % Find ratio and variance of higher harmonic divided by lower harmonic
                  [FratioCurrent(p1),FratioOverlap(p1)] = rat(1/ratioMean(p1),.1); % use rat(x) w/ x>=1
                  ratioVar(p1) = var(1./Fratio);
               end;
               ratioN(p1) = length(Fratio);
               overlapPercentage(p1) = length(Fratio)/min(length(Fcurrent),length(Foverlap))*100;
               ratioSE(p1) = ratioVar(p1)/length(Fratio);
            else
               ratioMean(p1) = median(Fratio);
               ratioVar(p1) = 10; % var=0 otherwise, so artificially inflate
               ratioN(p1) = length(Fratio);
               overlapPercentage(p1) = 0;
               FratioOverlap(p1) = -1;
               FratioCurrent(p1) = -1;
               ratioSE(p1) = 10;
            end;
         end;

         % Save stats:
         harmonicStats(p).ratioMean = ratioMean;
         harmonicStats(p).ratioVar = ratioVar;
         harmonicStats(p).ratioN = ratioN;
         harmonicStats(p).overlapPercentage = overlapPercentage;
         harmonicStats(p).FratioOverlap = FratioOverlap;
         harmonicStats(p).FratioCurrent = FratioCurrent;
         harmonicStats(p).ratioSE = ratioSE;
      end;
   end;

   % Assign harmonic numbers and indeces of minimum harmonic:
   harmonicNumberAll = zeros(numLinks,2); % [harmonic number, minimum harmonic index]
   for p=1:numLinks,
      if isCallModel(p),
         q = harmonicStats(p);
         h = find(q.ratioSE<=harmonicThresh & q.overlapPercentage>=50);

         if isempty(q.overlappingCalls) | isempty(h),
            harmonicNumberAll(p,1:2) = [1,p]; % Is a call and no overlapping links --> fundamental frequency
         else
            % Set harmonic number of current link to max determined by harmonic links:
            maxNum = max(q.FratioCurrent(h));
            if maxNum==1,
               minHarmonicIndex = p;
            else
               % Determine minimum harmonic:
               FME = zeros(1,length(h)+1); % all overlapping FME, plus current FME at end
               previousMinHarmonicIndex = zeros(1,length(h)+1); % min harmonic index previous assigned, if any
               for p1=1:length(h),
                  FME(p1) = outputGlobal(q.overlappingCalls(h(p1))).FME; % Hz
                  previousMinHarmonicIndex(p1) = harmonicNumberAll(q.overlappingCalls(h(p1)),2);
               end;
               FME(end) = outputGlobal(p).FME; % Hz
               previousMinHarmonicIndex(end) = harmonicNumberAll(p,2);
               [FMEsort,FMEsortIndex] = sort(FME); % small to large
               
               if max(previousMinHarmonicIndex)>0,
                  minHarmonicIndex = min(previousMinHarmonicIndex(previousMinHarmonicIndex>0));
               elseif FMEsortIndex(1)==length(FME), % current link is lowest harmonic
                  minHarmonicIndex = p;
               else
                  minHarmonicIndex = q.overlappingCalls(h(FMEsortIndex(1)));
               end;
            end;
            harmonicNumberAll(p,1:2) = [maxNum,minHarmonicIndex];
            
            % Set harmonic number of overlapping harmonic links:
            for p1=1:length(h),
               harmonicNumberAll(q.overlappingCalls(h(p1)),1:2) = ...
                  [round(q.FratioOverlap(h(p1))*maxNum/q.FratioCurrent(h(p1))),minHarmonicIndex];
            end;
         end;
      end;
   end;

   if 0,
      % Assign harmonics to F0s:
      for p=1:numLinks,
         if harmonicNumberAll(p,1)==1,
            q = harmonicStats(p);

            if ~isempty(q.overlappingCalls), % Check overlapping links,
               % Harmonic: ratio SE is low, overlap is high, harmonic number not assigned, and current link is F0.
               h = find(q.ratioSE<=harmonicThresh & q.overlapPercentage>=50 & ...
                  harmonicNumberAll(q.overlappingCalls,1)'==0 & q.FratioCurrent==1); % index into q.ratioSE
               for p1=1:length(h), % For each harmonic
                  harmonicNumberAll(q.overlappingCalls(h(p1)),1:2) = [q.FratioOverlap(h(p1)),p];
               end;
            end;
         end;
      end;

      % Assign harmonic numbers to detected calls w/ harmonics that may not have F0:
      for p=1:numLinks,
         if isCallModel(p) & harmonicNumberAll(p,1)==0,
            q = harmonicStats(p);

            % Get list of calls with 50% overlap or more and are harmonically related:
            overlappedUnassigned = find(q.overlapPercentage>=50 & q.ratioSE<harmonicThresh); % index into q.overlappingCalls

            if isempty(overlappedUnassigned),
               harmonicNumberAll(p,1:2) = [1,p]; % Doesn't meet above criteria --> fundamental frequency
            else
               % Find best-fitting harmonic, based on standard error of Fratio:
               [bestHarmonicSE,bestHarmonicIndex] = min(q.ratioSE(overlappedUnassigned)); % index into overlappedUnassigned

               % Update current/overlapping links:
               if harmonicNumberAll(q.overlappingCalls(overlappedUnassigned(bestHarmonicIndex)),1)==0,
                  % If unassigned, set minimum harmonic index to that of lowest harmonic:
                  if q.FratioOverlap(overlappedUnassigned(bestHarmonicIndex))>q.FratioCurrent(overlappedUnassigned(bestHarmonicIndex)),
                     harmonicNumberAll(p,1:2) = [q.FratioCurrent(overlappedUnassigned(bestHarmonicIndex)),p];
                     harmonicNumberAll(q.overlappingCalls(overlappedUnassigned(bestHarmonicIndex)),1:2) = ...
                        [q.FratioOverlap(overlappedUnassigned(bestHarmonicIndex)),p];
                  else
                     harmonicNumberAll(p,1:2) = [q.FratioCurrent(overlappedUnassigned(bestHarmonicIndex)),...
                        q.overlappingCalls(overlappedUnassigned(bestHarmonicIndex))];
                     harmonicNumberAll(q.overlappingCalls(overlappedUnassigned(bestHarmonicIndex)),1:2) = ...
                        [q.FratioOverlap(overlappedUnassigned(bestHarmonicIndex)),...
                        q.overlappingCalls(overlappedUnassigned(bestHarmonicIndex))];
                  end;
               else
                  % Set minimum harmonic index to that of already assigned overlapping harmonic:
                  harmonicNumberAll(p,1:2) = [q.FratioCurrent(overlappedUnassigned(bestHarmonicIndex)),...
                     harmonicNumberAll(q.overlappingCalls(overlappedUnassigned(bestHarmonicIndex)),2)];
               end;

               % Fill in any other overlapping links:
               for p1=1:length(overlappedUnassigned),
                  if harmonicNumberAll(q.overlappingCalls(overlappedUnassigned(p1)),1)==0,
                     harmonicNumberAll(q.overlappingCalls(overlappedUnassigned(p1)),1:2) = ...
                        [q.FratioOverlap(overlappedUnassigned(p1)),harmonicNumberAll(p,2)];
                  end;
               end;
            end;
         end;
      end;
   
      % Assign detected calls w/ no harmonic label yet to be F0:
      for p=1:numLinks,
         if isCallModel(p) & harmonicNumberAll(p,1)==0,
            harmonicNumberAll(p,1:2) = [1,p];
         end;
      end;
   end;
   
   % Remove links w/ a harmonic number of zero:
   saveLink = find(harmonicNumberAll(:,1)>0); % index into outputLocal/outputGlobal
   if ~isempty(saveLink),
      % Save only links w/ non-zero harmonic numbers:
      outputLocalTemp = cell(length(saveLink),1);
      outputLocalTemp{1} = outputLocal{saveLink(1)};
      outputGlobalTemp = outputGlobal(saveLink(1));
      for p=2:length(saveLink),
         outputLocalTemp{p} = outputLocal{saveLink(p)};
         outputGlobalTemp(p) = outputGlobal(saveLink(p));
      end;
      outputLocal = outputLocalTemp;
      outputGlobal = outputGlobalTemp;
      
      % Create list of call numbers and harmonic numbers, save to outputGlobal:
      numList = sort(harmonicNumberAll(saveLink,2)); % small to large
      uniqueCallIndex = diff([0;numList])>0; % logical index into numList
      lowestHarmonicIndex = numList(uniqueCallIndex); % index into outputLocal/outputGlobal of unique lowest harmonics (usually F0)
      for p=1:length(saveLink),
         outputGlobal(p).numCall = find(harmonicNumberAll(saveLink(p),2)==lowestHarmonicIndex);
         outputGlobal(p).numHarmonic = harmonicNumberAll(saveLink(p),1);
      end;
   else
      outputGlobal = struct([]);
      outputLocal = cell(0,1);
   end;
end;

return;

% Bye!
