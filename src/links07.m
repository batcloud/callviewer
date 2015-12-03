function linkOutput = links07(XAll,parameters,linksModel),
% function linkOutput = links07(X,fftRes,parameters,linksModel),
% This function finds links of local ridges in a spectrogram.
% Input: 
%        XAll -- struct, contains spectrogram and time/frequency infor
%            .X -- MxN spectrogram (pre-processed with median scaling, HPF)
%            .f -- kHz, Mx1 vector of frequency for each row of X
%            .t -- ms, 1xN vector of time for each column of X
%        parameters -- struct, parameters from callViewer
%           .links.linkLengthMinFrames -- frames, links less than threshold are not saved (default: 0)
%           .links.baselineThreshold -- dB, echo filter threshold (5)
%           .links.trimThreshold -- dB, local peaks below threshold are removed (10)
%        linksModel -- struct, contains Gaussian model parameters for evaluateGMM.m
%           .mu -- mean vectors, dx1, d features
%           .sig -- covariance matrices, dxd
%           .w -- mixture weight vector, 1x1
%           .sigInv -- covariance inverse, dxd
%           .prefactor -- -1/2*log(det(sig))+log(w), 1x1
% Output: linkOutput -- Nx1 cell array, N detected calls
%            linkOutput{n} -- Lx3 matrix [FFT bin,frame,dB] of n^th call, L frames

% Based on version 6, this file uses model parameters for the links algorithm.  Local peaks
% are connected, not based on the cost function in version 6, but according to the likelihood
% from the Gaussian model.  Connections between local peaks most likely to be between part of 
% a bat call are linked if reciprocal.  For feature extraction purposes, time and frequency 
% information is also added to the input sequence.
% Mark Skowronski, August 29, 2007

% Based on version 5, this file includes smoothness between left and right neighboring
% local peaks in determining links.
% Mark Skowronski, August 28, 2007

% Based on version 4, this file uses a cost function to link neighboring local peaks.  The cost
% function maximizes energy and minimizes |delta E| and |delta F| between adjacent peaks.
% Mark Skowronski, August 27, 2007

% Based on version 3, this file changes the format of the output.  The output is a cell array
% with one entry per detected link, not one entry per spectrogram column.
% Mark Skowronski, August 20, 2007

% Based on version 2, this file includes filtering out links and trimming links using
% thresholds.
% Mark Skowronski, August 17, 2007

% Based on version 1, this file looks to speed up execution by replacing find() statements
% with logical indexing.
% Mark Skowronski, July 25, 2007

% Based on peakEdges02.m, this file converts the code into a function call.
% Mark Skowronski, July 25, 2007

% peakEdges02.m: Based on version 1, this file adds local feature extraction
% for each link and uses clustering to find centroids for models for calls, 
% echoes, and background noise.
% Mark Skowronski, July 15, 2007

% peakEdges01.m: This file investigates detecting calls using
% local peak information.
% Mark Skowronski, July 13, 2007

% Parameters:
linksThresh = -25; % dB, links likelihood must exceed threshold

% Check inputs:
if nargin<3,
   error(['ERROR: no model parameters input. Quitting...']);
else
   % Create model to use with one-sided links (left or right only...no smoothness features):
   linksModelLR = linksModel;
   linksModelLR.mu = linksModel.mu(1:2);
   linksModelLR.sig = linksModel.sig([1:2],[1:2]);
   linksModelLR.sigInv = inv(linksModelLR.sig);
   linksModelLR.prefactor = -1/2*log(det(linksModelLR.sig))+log(linksModelLR.w);

   linksModelTemp = linksModel;
   linksModelTemp.mu = linksModel.mu([1,2,4]);
   linksModelTemp.sig = linksModel.sig([1,2,4],[1,2,4]);
   linksModelTemp.sigInv = inv(linksModelTemp.sig);
   linksModelTemp.prefactor = -1/2*log(det(linksModelTemp.sig))+log(linksModelTemp.w);
   linksModel = linksModelTemp;
end;
if nargin<2,
   parameters = struct([]);
   parameters(1).links = struct([]);
   parameters.links(1).linkLengthMinFrames = 5;
   parameters.links.baselineThreshold = 5; % dB
   parameters.links.trimThreshold = 10; % dB
end;
if nargin<1,
   error('ERROR: no input data.');
end;

% Get variables from XAll:
X = XAll.X; % spectrogram, may be HPFed
f = XAll.f(:); % kHz, COLUMN vector
t = XAll.t(:)'; % ms, ROW vector

% Get size of X, sanity check:
[M,N] = size(X);
if length(f)~=M || length(t)~=N,
   error(['ERROR: size mismatch between X and f and t.']);
end;

% Find local peaks above trim threshold in each frame:
localPeaks = false(M,N);
localPeaks(2:M-1,1:N) = X(2:M-1,1:N)>=X(1:M-2,1:N) & X(2:M-1,1:N)>X(3:M,1:N) & X(2:M-1,1:N)>=parameters.links.trimThreshold;

if 0,
   figure(20);
   imagesc(t,f,X.*localPeaks);axis xy;
end;

% Init smoothness variables:
deltaSize = 1;
z = [[-deltaSize:deltaSize]'*(t(2)-t(1))*1e-3,ones(2*deltaSize+1,1)]; % generic abscissa matrix, [sec,unity]
C = inv(z'*z)*z'; % Hz, prefactor
C1 = C(1,:); % Hz, linear regression slope from first row of C
A = z*C; % unitless
B = (A-eye(2*deltaSize+1))'*(A-eye(2*deltaSize+1)); % unitless, used to find sum-of-squares error

% Find neighbor to the right and left of each frame:
nnRight = zeros(M,N); % row index of nn to the right; ==0 if no nn to the right
nnLeft = zeros(M,N); % row index of nn to the left; ==0 if no nn to the left
for p=2:N-1, % for each frame
   % Get indeces for current peaks not adjacent to valleys to the right:
   leftPeaks = find(localPeaks(1:M,p-1)); % row indeces, neighbor to the LEFT
   currentPeaks = find(localPeaks(1:M,p)); % row indeces
   rightPeaks = find(localPeaks(1:M,p+1)); % row indeces, neighbor to the RIGHT
   
   if ~isempty(currentPeaks),
      if isempty(leftPeaks) && ~isempty(rightPeaks), % right link only
         neighborPeaks = rightPeaks;
         for p1=1:length(currentPeaks),
            % Construct features between current peak and all neighboring peaks
            E = X(currentPeaks(p1),p)*ones(1,length(neighborPeaks)); % dB
            dF = (f(currentPeaks(p1))-f(neighborPeaks)')/(t(p)-t(p+1)); % kHz/ms, dithered
%            dE = (X(currentPeaks(p1),p)-X(neighborPeaks,p+1)')/(t(p)-t(p+1)); % dB/ms
            
            % Find log likelihoods:
%            LL = evaluateGMM([E;dF;dE],linksModelLR);
            LL = evaluateGMM([E;dF],linksModelLR);

            % Link to neighbor with maximum likelihood:
            [a,b] = max(LL);
            if a>linksThresh,
               nnRight(currentPeaks(p1),p) = neighborPeaks(b);
            end;
         end;
      elseif ~isempty(leftPeaks) && isempty(rightPeaks), % left link only
         neighborPeaks = leftPeaks;
         for p1=1:length(currentPeaks),
            % Construct features between current peak and all neighboring peaks
            E = X(currentPeaks(p1),p)*ones(1,length(neighborPeaks)); % dB
            dF = (f(currentPeaks(p1))-f(neighborPeaks)')/(t(p)-t(p-1)); % kHz/ms
%            dE = (X(currentPeaks(p1),p)-X(neighborPeaks,p-1)')/(t(p)-t(p-1)); % dB/ms
            
            % Find log likelihoods:
%            LL = evaluateGMM([E;dF;dE],linksModelLR);
            LL = evaluateGMM([E;dF],linksModelLR);

            % Link to neighbor with maximum likelihood:
            [a,b] = max(LL);
            if a>linksThresh,
               nnLeft(currentPeaks(p1),p) = neighborPeaks(b);
            end;
         end;
      elseif ~isempty(leftPeaks) && ~isempty(rightPeaks), % left and right link
         [bbb,aaa] = meshgrid([1:length(rightPeaks)],[1:length(leftPeaks)]);
         F1 = [f(leftPeaks(aaa(:))),ones(length(aaa(:)),1),f(rightPeaks(bbb(:)))]'*1e3;
         for p1=1:length(currentPeaks),
            F1(2,:) = f(currentPeaks(p1))*1e3;
            dF = C1*F1*1e-6; % kHz/ms
%            sF = sum(F1.*(B*F1),1); % Hz^2
            sF = max(40,10*log10(sum(F1.*(B*F1),1)/(2*deltaSize+1)+1)); % dB, averaged
            gmmFeatures = [X(currentPeaks(p1),p)*ones(1,length(dF));dF;sF];
            
            if 0,
               for p2=1:length(leftPeaks),
                  for p3=1:length(rightPeaks),
                     % Get slope/smoothness:
                     F1 = f([leftPeaks(p2);currentPeaks(p1);rightPeaks(p3)])*1e3; % Hz, COLUMN vector
   %                  E1 = [X(leftPeaks(p2),p-1);X(currentPeaks(p1),p);X(rightPeaks(p3),p+1)]; % dB, COLUMN vector
                     dF = C1*F1*1e-6; % kHz/ms
   %                  dE = C1*E1*1e-3; % dB/ms
                     sF = F1'*B*F1; % Hz^2, frequency smoothness
   %                  sE = E1'*B*E1; % dB^2, energy smoothness

                     % Convert to dB:
                     sF = max(40,10*log10(sF/(2*deltaSize+1)+1)); % dB, averaged
   %                  sE = 10*log10(sE/(2*deltaSize+1)); % dB, averaged

                     % Store features:
                     gmmFeatures(2:3,p2+(p3-1)*length(leftPeaks)) = [dF;sF];
                  end; % for each right peak
               end; % for each left peak
            end;

            % Find log likelihood:
%            LL(p2,p3) = evaluateGMM([E;dF;dE;sF;sE],linksModel);
            LL = evaluateGMM(gmmFeatures,linksModel);

            % Link to neighbor with lowest cost:
            [a,b] = max(LL);
            if a>linksThresh,
               nnLeft(currentPeaks(p1),p) = leftPeaks(mod(b-1,length(leftPeaks))+1);
               nnRight(currentPeaks(p1),p) = rightPeaks(floor((b-1)/length(leftPeaks))+1);
            end;
         end;
      end;
   end; % if any current peaks
end; % for each frame

% Find reciprocal nearest neighbors, link together:
nnBoth = zeros(M,N);
for p=2:N-1,
   currentPeaks = find(localPeaks(1:M,p)); % row indeces
   for p1=1:length(currentPeaks),
      if nnRight(currentPeaks(p1),p)>0,
         if nnLeft(nnRight(currentPeaks(p1),p),p+1)==currentPeaks(p1),
            nnBoth(currentPeaks(p1),p) = nnRight(currentPeaks(p1),p);
         end;
      end;
   end;
end;

% Create links output, filtering out links using thresholds:
linkOutput = cell(0,1);
nnRight = nnBoth;
for p=1:N-1,
   % Get indeces of links starting in current frame:
   g = find(nnRight(:,p)>0);
   
   % Find all local peaks in each link:
   for p1=1:length(g),
      tempLink = [g(p1),p,X(g(p1),p)];
      while nnRight(tempLink(end,1),tempLink(end,2))>0,
         % Update temp link:
         tempLink(end+1,1:3) = [nnRight(tempLink(end,1),tempLink(end,2)),tempLink(end,2)+1,X(nnRight(tempLink(end,1),tempLink(end,2)),tempLink(end,2)+1)];
         
         % Remove from nnRight:
         nnRight(tempLink(end-1,1),tempLink(end-1,2)) = 0;
      end;
      
      % Filter out short links:
      if size(tempLink,1)>=parameters(1).links.linkLengthMinFrames,
         linkOutput{end+1} = tempLink;
      end;
   end;
end;

   
return;

% Bye!