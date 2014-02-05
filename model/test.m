% configuration / initialisation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = 100; % number of states
M = 30; % number of observation symbols
L = 200; % sequence length
seq = randint(1, L, [1 M]); % example sequence
alphabet = [1:M]; % alphabet (list of observation symbols)
% PI: initial state probability vector. size N
PI = rand(N, 1)/N;
% P: matrix of limiting tansmission probabilities. size N, N
% D: matrix of cumulative transition duration distribution functions. size N, N
% G = P .* D;
G = rand(N)/N;
% B: matrix of emission probabilities. size N, M
B = rand(N,M);
% compute B_comp (matrix to facilitate online/offline computation)
B_comp = B(:, lookup(alphabet, seq));
% compute V
V = G.*(ones(N)-eye(N)) + diag(1-(sum(G, 2) - diag(G))); % eq. 6.13

% offline computation
%%%%%%%%%%%%%%%%%%%%%
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
for m=1:M,
    mask = repmat(seq == alphabet(m), [N, 1]);
    B(:, m) = sum((gamma .* mask), 2) ./ sum(gamma, 2);
end;
% compute B_comp (matrix to facilitate online/offline computation)
B_comp = B(:, lookup(alphabet, seq));

% online computation
%%%%%%%%%%%%%%%%%%%%
% data processing

% sequence processing with one model
alpha = forward(N, L, PI, V, B_comp);
lPs = logLikelihood(scale(alpha));

% classification
