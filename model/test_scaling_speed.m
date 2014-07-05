% initialisation of test values
% ==============================================================================
%N = 1000; % number of states
M = 1000; % number of observation symbols
%L = 50; % sequence lengt
seq_e = randint(1, L, [1 M]); % example sequence
alphabet = [1:M]; % alphabet (list of observation symbols)
% PI: initial state probability vector. size N
PI = abs(rand(N, 1));
PI = PI./sum(PI);
% B: matrix of emission probabilities
B = abs(rand(N, M)); % size N, M
B = B./repmat(sum(B, 2), 1, M);
% P: matrix of limiting tansmission probabilities
TP = abs(rand(N, N)); % size N, N
TP = TP./repmat(sum(TP, 2), 1, N);

% sequence detection
% ==============================================================================
tic;
for i=1:1000,
    seq_e = randint(1, L, [1 M]); % example sequence
    Ps = forward_p_scaling(N, L, PI, B, TP, seq_e);
end
toc;
