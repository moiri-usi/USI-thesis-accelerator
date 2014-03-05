% initialisation of test values
% ==============================================================================
N = 300; % number of states
M = 30; % number of observation symbols
L = 300; % sequence length
seq_e = randint(1, L, [1 M]); % example sequence
seq_d = ones(1, L); % relative delays of the events
alphabet = [1:M]; % alphabet (list of observation symbols)
% PI: initial state probability vector. size N
PI = abs(rand(N, 1))/N;
% B: matrix of emission probabilities
B = abs(rand(N, M))/N; % size N, M
% parameters for gaussian distribution kernel
mu = abs(rand(N, N)); % size N, N
sigma = abs(rand(N, N)); % size N, N
% P: matrix of limiting tansmission probabilities
P = abs(rand(N, N))/N; % size N, N
alpha = zeros(N, L);
scale_coeff = zeros(L, 1);

% sequence detection
% ==============================================================================
% compute B_comp (matrix to facilitate online/offline computation)
B_comp = B(:, lookup(alphabet, seq_e)); % size N, L
% compute first elements of forward algorithm
alpha(:, 1) = PI .* B_comp(:, 1); % eq. 6.16
scale_coeff(1) = sum(alpha(:, 1), 1);
alpha(:, 1) /= scale_coeff(1);
% compute V, eq. 6.13
V = zeros(N, N, L);
for k=[1:L-1],
    V(:, :, k) = 1 ./ (sigma * sqrt(2*pi)) .* ...
        exp(-0.5 * power((seq_d(k) - mu) ./ sigma, 2)) .* P; %size N, N, L
    for i=[1:N],
        V(i, i, k) = 0;
        V(i, i, k) = 1 - sum(V(i, :, k), 2);
    end;
    % compute all other elements of forward algorithm
    alpha(:, k+1) = B_comp(:, k) .* (alpha(:, k)' * V(:, :, k))'; % eq. 6.16
    scale_coeff(k+1) = sum(alpha(:, k+1), 1);
    alpha(:, k+1) /= scale_coeff(k+1);
end;
% compute log likelihood
lPs = logLikelihood(1 / scale_coeff);
