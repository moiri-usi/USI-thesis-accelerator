% initialisation of test values
% ==============================================================================
N = 100; % number of states
M = 30; % number of observation symbols
L = 200; % sequence length
R = 10; % number of cumulative probability distributions
r = 1; % choice of kernel
seq = randint(1, L, [1 M]); % example sequence
alphabet = [1:M]; % alphabet (list of observation symbols)
weights = rand(N, N, R)/R; % sum(weights, 3) == 1, eq. 6.9                      <- define!
kernel = rand(N, N, R); %                                                       <- define!
distr = rand(N, N, R); %                                                        <- define!

% offline computation
% ==============================================================================
% data processing
% ------------------------------------------------

% model training: step 1
% ------------------------------------------------
% PI: initial state probability vector. size N
PI = rand(N, 1);
% D: matrix of cumulative transition duration distribution functions. size N, N
D = sum((weights .* kernel), 3); % eq. 6.8
D_ = repmat(D, [1 1 L]);
% G = P .* D;
G = rand(N, N)/N; % sum(G, 1) <= 1, eq. 6.10
% P: matrix of limiting tansmission probabilities. size N, N
P = G ./ D; % eq. 6.7, sum(P, 1) == 1, eq. 6.4                                  <- verify this!
P_ = repmat(P, [1 1 L]);
% B: matrix of emission probabilities. size N, M
B = rand(N,M);
% compute B_comp (matrix to facilitate online/offline computation)
B_comp = B(:, lookup(alphabet, seq));
B_comp_ = shiftdim(repmat(B_comp, [1 1 N]),2);
% compute V, eq. 6.13
V_s = G.*(ones(N) - eye(N)); % i != j
V_d = diag(1 - sum(V_s, 2)); % i == j
V = V_s + V_d;
V_ = repmat(V, [1 1 L]);

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
xi_n = alpha_ .* V_ .* B_comp_ .* beta_;
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
% start itereation
% step 5a
% -------
% eq. 6.49
G_s = G.*(ones(N) - eye(N));
fact_d = D ./ repmat(1 - sum(G_s, 2), [1 N]);
fact_p = P ./ repmat(1 - sum(G_s, 2), [1 N]);
xi_diag = repmat(reshape(xi, [N*N, 1, L])(1:N+1:end, 1, :), [1, N, 1]);
grad_Qp = sum((xi ./ P_ - xi_diag .* repmat(fact_d, [1 1 L])), 3);
grad_Qp = grad_Qp .* (ones(N) - eye(N));
% eq. 6.52
grad_Qd = sum((xi ./ D_ - xi_diag .* repmat(fact_p, [1 1 L])), 3);
grad_Qd = grad_Qd .* (ones(N) - eye(N));
% eq. 6.50, 6.51
grad_Qw = grad_Qd .* kernel(:, :, r);
% eq. 6.53
grad_Qth = grad_Qd .* weights(:, :, r) .* distr(:, :, r);
grad_Q = [grad_Qp grad_Qw grad_Qth];

% step 5b
%--------
M = ones(3*N, N); % eq. 6.61                                                    <- define M!
grad_Q = ((M * M') * grad_Q')'; % eq. 6.62

%% step 5c
%% -------
%s_n = grad_Q; % eq. 6.57
%% compute nu by line search
%nu = 1 %                                                                        <- todo
%lambdaG_new = lambdaG_old + nu * grad_Q;

% step 5 finalize
% ---------------

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
