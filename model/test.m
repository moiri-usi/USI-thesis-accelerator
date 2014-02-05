% configuration / initialisation
% N: number of states
N = 100;
% M: number of observation symbols
M = 30;
% L: sequence length
L = 200;
% example sequence
seq = randint(1, L, [1 M]);
% alphabet (list of observation symbols)
alphabet = [1:M];
% PI: initial state probability vector. size N
PI = rand(N, 1)/N;
% P: matrix of limiting tansmission probabilities. size N, N
P = rand(N)/N;
% D: matrix of cumulative transition duration distribution functions. size N, N
D = rand(N)/N;
% B: matrix of emission probabilities. size N, M
B = rand(N,M)/N;

%compute B_comp (matrix to facilitate computation)
B_comp = B(:, lookup(alphabet, seq));


% compute V
V = P.*D; % eq. 6.7
V = V.*(ones(N)-eye(N)) + diag(1-(sum(V, 2) - diag(V))); % eq. 6.13

% offline
%%%%%%%%%
% data processing

% model training
% compute alpha
alpha = forward(N, L, PI, V, B_comp);
% compute beta
beta = backward(N, L, V, B_comp);
% compute gamma
gamma = alpha .* beta ./ repmat(diag(alpha' * beta)', N, 1);
% compute xi
alpha_ = shiftdim(repmat(alpha(:, 1:end-1)', [1 1 N]),1);
V_ = repmat(V, [1 1 L-1]);
B_comp_ = shiftdim(repmat(B_comp(:, 2:end), [1 1 N]),2);
beta_ = shiftdim(repmat(beta(:, 2:end), [1 1 N]),2);
xi_n = alpha_ .* V_ .* B_comp_ .* beta_;
xi_q = repmat(sum(sum(xi_n, 2)), [N N 1]);
xi = xi_n ./ xi_q;
% compute sequence likelihood
ps = likelihood(alpha);
% reassign PI
PI = gamma(:, 1);
% reassign B

% online
%%%%%%%%
% data processing

% sequence processing with one model
alpha = forward(N, L, PI, V, B_comp);
lPs = logLikelihood(scale(alpha));

% classification
