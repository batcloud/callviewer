function y = evaluateGMM(x,model),
% function y = evaluateGMM(x,model)
% This function efficiently evaluates a GMM.
% Input: x -- input matrix, dxN, d features, N frames 
%        model -- structure of model parameters
%           .mu -- mean vectors, dxM, d features, M mixtures
%           .sig -- covariance matrices, dxdxM
%           .w -- mixture weight vector, 1xM
%           .sigInv -- covariance inverse, dxdxM
%           .prefactor -- -1/2*log(det(sig))+log(w), 1xM
% Output: y -- log likelihood, 1xN

% Mark Skowronski, June 21, 2007

% Get sizes:
[d,N] = size(x);
M = size(model.mu,2); % number of mixtures

if M==1, % single Gaussian kernel, special case
   xx = x - model.mu(1:d,ones(1,N));
   y = model.prefactor - sum((model.sigInv*xx).*xx,1)/2;
else
   z = zeros(M,N);
   for p=1:M,
      xx = x - model.mu(1:d,p)*ones(1,N);
      z(p,1:N) = model.prefactor(p) - sum((model.sigInv(1:d,1:d,p)*xx).*xx,1)/2;
   end;
   y = log(sum(exp(z),1)); % convert to log likelihood
end;

% Bye!