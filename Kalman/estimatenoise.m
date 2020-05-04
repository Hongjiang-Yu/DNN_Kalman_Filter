function noisevar = estimatenoise(X,varargin)
% estimatenoise: additive noise estimation from a time series
% usage: noisevar = estimatenoise(X)
% arguments: (input)
%  X - (REQUIRED) (numeric vector of length n, or any n-dimensional
%        numeric array)
%
%        X must be at least of length 5 in the specified dimension.
%
%        WARNING: Estimation of any variance will be suspect with
%        few data points in your sample.
%
%        If X is complex, then I treat the problem as two parallel
%        sequences in parallel. The variance returned will be the
%        sum of the variances for the real and complex parts.
%
%  t - (OPTIONAL) - list of "time" steps if X was sampled at an
%        non-uniform spacing. If supplied, then t must be a vector
%        of the same length as X is in dimension dim.
%        
%  dim - specifies the dimension of the array to act on
%        If dim is not provided, then the first non-singleton
%        dimension will be used.
%
%
% arguments: (output)
%  noisevar - scalar (or vector or array as appropriate)
%        estimated variance of additive noise in the data
%        along dimension dim.

% if no input arguments provided, just dump out the help
if nargin<1
  help estimatenoise
  return
end

% complex sequences are split into real and imaginary parts.
if ~isreal(X)
  noisevar = estimatenoise(real(X)) + estimatenoise(imag(X));
  return
end

% get the size of X, so we can pick the value for
% dim if it was not supplied. We will also need to
% make sure the length in that dimension is large
% enough.
sx = size(X);

% were t and/or dim supplied? In which order?
if (nargin>3)
  error('Too many inputs supplied. Maximum of 3 inputs are allowed.')
elseif nargin == 1
  % use defaults
  dim = [];
  t = [];
elseif (nargin == 2) && isempty(varargin{1})
  % use defaults
  dim = [];
  t = [];
elseif (nargin==2) && (length(varargin{1}) == 1)
  % dim was supplied
  dim = varargin{1};
  t = [];
elseif (nargin==2)
  % t must have been specified
  t = varargin{1};
  t = t(:);
  dim = [];
elseif (nargin==3) && (length(varargin{1}) == 1)
  % dim and t were supplied, in that order
  dim = varargin{1};
  t = varargin{2};
  t = t(:);
elseif (nargin==3) && (length(varargin{2}) == 1)
  % t and dim were supplied, in that order
  dim = varargin{2};
  t = varargin{1};
  t = t(:);
else
  % there is a problem with the arguments
  error('A and t arguments are of inconsistent size')
end

% get dim if it was not supplied
if isempty(dim)
  dim = find(sx~=1,1,'first');
  if isempty(dim)
    error('X did not have at least one dimension of length >1')
  end
end

% check the length in the dim dimension
nX = sx(dim);
if nX<5
  error('The length of X in the specified dimension was less than 5')
end

% permute the dimensions so that the chosen dimension
% of X is moved to the end of the line.
ndim = length(sx);
nx = 1:ndim;
nx(dim) = [];
nx = [nx,dim];
Xp = permute(X,nx);
% then just reshape it to be a 2-d array
Xp = reshape(Xp,[],sx(dim));

% was t actually equally spaced anyway? If it was, then we
% want to use the equal spaced code.
equispaced = true;
if ~isempty(t)
  % first sort t, just in case
  [t,tags] = sort(t);
  % and shuffle Xp in the first dimension
  Xp = Xp(:,tags);
  
  % check for equal spacing in t
  dt = diff(t);
  
  % average spacing
  avespace = (t(end) - t(1))/(nX-1);
  if (avespace == 0)
    error('Invalid t vector: t was identically zero.')
  end
  tol = 10*eps(avespace);
  if tol < (max(dt) - min(dt))
    % unequal spacing
    equispaced = false;
  end
end

% estimate the measurement variability in the (now) second dimension
% later we will undo this reshape.

% The idea here is to form a linear combination of successive elements
% of the series. If the underlying form is locally nearly linear, then
% a [1 -2 1] combination (for equally spaced data) will leave only
% the noise remaining. Next, if we assume the measurement noise was
% iid, N(0,s^2), then we can try to back out the noise variance.
fda{1} = [1 -1];
fda{2} = [1 -2 1];
fda{3} = [1 -3 3 -1];
fda{4} = [1 -4 6 -4 1];
fda{5} = [1 -5 10 -10 5 -1];
fda{6} = [1 -6 15 -20 15 -6 1];
nfda = length(fda);
for i = 1:nfda
  % normalize to unit norm
  fda{i} = fda{i}/norm(fda{i});
end

% compute an interquantile range, like the distance between the 25%
% and 75% points. This trims off the trash at each end, potentially
% corrupted if there are discontinuities in the curve. It also deals
% simply with a non-zero mean in this data. Actually do this for
% several different interquantile ranges, then take a median.
% NOTE: While I could have used other methods for the final variance
% estimation, this method was chosen to avoid outlier issues when
% the curve may have isolated discontinuities in function value or
% a derivative.

% The following points correspond to the central 90, 80, 75, 70, 65,
% 60, 55, 50, 45, 40, 35, 30, 25, and 20 percent ranges.
perc = [0.05, 0.1:0.025:0.40];
z = erfinv((1-perc)*2-1)*sqrt(2);

sigmaest = nan(size(Xp,1),nfda);
for i = 1:nfda
  % Apply each difference to the data series with convn
  % the 'valid' option will trim off the junk at the ends
  % from the convolution.
  
  % did we have equal spacing?
  if equispaced
    % If so, then conv will do the trick.
    
    % These convolutions will yield noise of the desired variance,
    % although it will be colored noise.
    noisedata = conv2(Xp,fda{i},'same');
    ntrim = size(noisedata,2);
  else
    % unequal spacing. do it the hard way
    F = 1./gamma(1:i);
    ntrim = nX - i;
    noisedata = zeros(size(Xp,1),ntrim);
    for j = 1:ntrim
      tj = t(j+(0:i));
      tj = tj - mean(tj);
      if all(abs(tj) <= tol)
        % be careful if all points were reps!
        coef = rem((0:i)',2)*2-1;
        coef = coef - mean(coef);
        % and normalize
        coef = coef/norm(coef);
      else
        % use null to choose the linear combination
        % of the elements of Xp.
        tj = tj/norm(tj);
        A = repmat(tj,1,i).^repmat(0:(i-1),i+1,1);
        A = A.*repmat(F,i+1,1);
        nullvecs = null(A');
        % already normalized to have unit norm by null
        coef = nullvecs(:,1);
      end
      
      % form the appropriate linear combination of Xp
      noisedata(:,j) = Xp(:,j+(0:i))*coef;
    end
  end  % if equispaced
  
  % were there enough points to even try anything?
  if ntrim >= 2
    % sorting will provide the necessary percentiles after
    % interpolation.
    noisedata = sort(noisedata,2);
    
    p = 0.5 + (1:ntrim)';
    p = p/(ntrim + 0.5);
    
    Q = zeros(size(noisedata,1),length(perc));
    for j = 1:length(perc)
      Qj = interp1q(p,noisedata',1-perc(j)) - interp1q(p,noisedata',perc(j));
      Qj = Qj/(2*z(j));
      Q(:,j) = Qj';
    end

    % Trim off any nans first, since if the series was short enough,
    % some of those percentiles were not present.
    wasnan = isnan(Q(1,:));
    Q(:,wasnan) = [];
    
    % Our noise std estimate is given by the median of the interquantile
    % range(s). This is an ad hoc, but hopefully effective, way of
    % estimating the measurement noise present in the signal.
    sigmaest(:,i) = median(Q,2);
    
  end
  
end % for i = 1:nfda

% drop those estimates which failed for lack of enough data
sigmaest(:,isnan(sigmaest(1,:))) = [];

% use median of these estimates to get a noise estimate.
noisevar = median(sigmaest,2).^2;

% Use an adhoc correction to remove the bias in the noise estimate.
% This correction was determined by examination of a large number of
% random samples.
noisevar = noisevar/(1+15*(sx(dim)+1.225)^-1.245);

% The first order difference might be used to guesstimate the
% process noise.
% if nargout>1
%   processvar = max(0,sigmaest(:,1).^2 - noisevar);
% end

% finally, reshape the result to be consistent with the input shape
sx(dim) = 1;
noisevar = reshape(noisevar,sx);
% if nargout>1
%   processvar = reshape(processvar,sx);
% end


