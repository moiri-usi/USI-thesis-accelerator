% initialisation of test values
% ==============================================================================
OP1_WIDTH = 25;
OP2_WIDTH = 18;
N = 3; % number of states
M = 1; % number of observation symbols
L = 3; % sequence length
seq_e = randint(1, L, [1 M]); % example sequence
alphabet = [1:M]; % alphabet (list of observation symbols)
% PI: initial state probability vector. size N
%PI = abs(rand(N, 1))/N;
PI(1) = 0.18781;
PI(2) = 0.35758;
PI(3) = 0.45461;
for i=1:N,
    PI_dec(i) = float2myDec(PI(i), OP1_WIDTH);
end
% B: matrix of emission probabilities
%B = abs(rand(N, M))/N; % size N, M
B(1, 1) = 0.33281;
B(2, 1) = 0.04932;
B(3, 1) = 0.61787;
for i=1:N,
    for j=1:M,
        B_dec(i, j) = float2myDec(B(i, j), OP2_WIDTH);
    end
end
% P: matrix of limiting tansmission probabilities
%TP = abs(rand(N, N))/N; % size N, N
TP(1,1) = 0.73100; % size N, N
TP(2,1) = 0.01292; % size N, N
TP(3,1) = 0.25608; % size N, N
TP(1,2) = 0.15755; % size N, N
TP(2,2) = 0.45734; % size N, N
TP(3,2) = 0.38511; % size N, N
TP(1,3) = 0.00013; % size N, N
TP(2,3) = 0.02913; % size N, N
TP(3,3) = 0.97074; % size N, N
for i=1:N,
    for j=1:N,
        TP_dec(i, j) = float2myDec(TP(i, j), OP2_WIDTH);
    end
end
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

for i=1:N,
    for j=1:L,
        alpha_dec(i, j) = float2myDec(alpha(i, j), OP1_WIDTH);
    end
end
