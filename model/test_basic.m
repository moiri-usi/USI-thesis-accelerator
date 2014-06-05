% initialisation of test values
% ==============================================================================
N = 3; % number of states
M = 1; % number of observation symbols
L = 3; % sequence length
seq_e = randint(1, L, [1 M]); % example sequence
alphabet = [1:M]; % alphabet (list of observation symbols)
% PI: initial state probability vector. size N
%PI = abs(rand(N, 1))/N;
PI = ones(N, 1)*0.18781;
% B: matrix of emission probabilities
%B = abs(rand(N, M))/N; % size N, M
B = ones(N, M)*0.33281;
% P: matrix of limiting tansmission probabilities
%TP = abs(rand(N, N))/N; % size N, N
TP = ones(N, N)*0.23100; % size N, N
alpha = zeros(N, L);

% sequence detection
% ==============================================================================
tic;
for i=1:10,
    % initialize forward variables
    for i=1:N,
        alpha(i, 1) = PI(i)*B(i, seq_e(1));
    end
    % forward algorithm
    for k=2:L,
        for j=1:N,
            alpha(j, k) = 0;
            for i=1:N,
                alpha(j, k) += alpha(i, k-1) * TP(i, j);
            end
            alpha(j, k) *= B(j, seq_e(k));
        end
    end
    % compute likelihood
    Ps = 0;
    for i=1:N,
        Ps += alpha(i, end);
    end
    Ps
end
toc;
