% initialisation of test values
% ==============================================================================
N = 100; % number of states
M = 30; % number of observation symbols
L = 200; % sequence length
R = 10; % number of cumulative probability distributions
seq = randint(1, L, [1 M]); % example sequence
alphabet = [1:M]; % alphabet (list of observation symbols)
weights = rand(N, N, R)/R; % sum(weights, 3) == 1, eq. 6.9
weights_ = repmat(weights, [1 1 1 L]);
kernel = rand(N, N, R, L);

% offline computation
% ==============================================================================
% data processing
% ------------------------------------------------

% model training: step 1
% ------------------------------------------------
% PI: initial state probability vector. size N
PI = rand(N, 1);
% D: matrix of cumulative transition duration distribution functions. size N, N
D = reshape(sum((weights_ .* kernel), 3), [N N L]); % eq. 6.8
% G = P .* D;
G = rand(N, N, L)/N; % sum(G, 1) <= 1, eq. 6.10
% P: matrix of limiting tansmission probabilities. size N, N
P = G ./ D; % eq. 6.7, sum(P, 1) == 1, eq. 6.4                                  <- verify this!
% B: matrix of emission probabilities. size N, M
B = rand(N,M);
% compute B_comp (matrix to facilitate online/offline computation)
B_comp = B(:, lookup(alphabet, seq));
B_comp_ = shiftdim(repmat(B_comp, [1 1 N]),2);
% compute V, eq. 6.13
V_s = G.*(ones(N, N, L) - repmat(eye(N), [1 1 L])); % i != j
V_d = repmat(1 - sum(V_s, 2), [1 N 1]) .* repmat(eye(N), [1 1 L]); % i == j
V = V_s + V_d;

% model training: step 2
% ------------------------------------------------
% compute alpha
alpha = forward(N, L, PI, V, B_comp);
alpha_ = shiftdim(repmat(alpha', [1 1 N]), 1);
% compute beta
beta = backward(N, L, V, B_comp);
beta_ = shiftdim(repmat(beta, [1 1 N]), 2);
% compute gamma
gamma = alpha .* beta ./ repmat(diag(alpha' * beta)', N, 1);
% compute xi
xi_n = alpha_ .* V .* B_comp_ .* beta_;
xi_q = repmat(sum(sum(xi_n, 2)), [N N 1]);
xi = xi_n ./ xi_q;

% model training: step 3
% ------------------------------------------------
% compute sequence likelihood
ps = likelihood(alpha);

% model training: step 4
% ------------------------------------------------
% reassign PI
PI = gamma(:, 1);
% reassign B
for m=1:M,
    mask = repmat(seq == alphabet(m), [N, 1]);
    B(:, m) = sum((gamma .* mask), 2) ./ sum(gamma, 2);
end;
% compute B_comp (matrix to facilitate online/offline computation)
B_comp = B(:, lookup(alphabet, seq));

% model training: step 5
% ------------------------------------------------
%grad_Qp = sum((), 3);

% online computation
% ==============================================================================
% data processing
% ------------------------------------------------

% sequence processing with one model
% ------------------------------------------------
alpha = forward(N, L, PI, V, B_comp);
lPs = logLikelihood(scale(alpha));

% classification
% ------------------------------------------------
