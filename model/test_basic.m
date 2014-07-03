% initialisation of test values
% ==============================================================================
OP1_WIDTH = 25;
OP2_WIDTH = 18;
N = 100; % number of states
M = 1; % number of observation symbols
%L = 10; % sequence lengt
seq_e = randint(1, L, [1 M]); % example sequence
alphabet = [1:M]; % alphabet (list of observation symbols)
% PI: initial state probability vector. size N
%PI = abs(rand(N, 1))/N;
%PI(1) = 0.18781;
%PI(2) = 0.35758;
%PI(3) = 0.45461;
%for i=1:N,
%    PI_dec(i) = float2myDec(PI(i), OP1_WIDTH);
%end
%% B: matrix of emission probabilities
%%B = abs(rand(N, M))/N; % size N, M
%B(1, 1) = 0.33281;
%B(2, 1) = 0.04932;
%B(3, 1) = 0.61787;
%%B(1, 1) = 0.50000;
%%B(2, 1) = 0.50000;
%%B(3, 1) = 0.50000;
%for i=1:N,
%    for j=1:M,
%        B_dec(i, j) = float2myDec(B(i, j), OP2_WIDTH);
%    end
%end
%% P: matrix of limiting tansmission probabilities
%%TP = abs(rand(N, N))/N; % size N, N
%TP(1,1) = 0.73100; % size N, N
%TP(1,2) = 0.01292; % size N, N
%TP(1,3) = 0.25608; % size N, N
%TP(2,1) = 0.15755; % size N, N
%TP(2,2) = 0.45734; % size N, N
%TP(2,3) = 0.38511; % size N, N
%TP(3,1) = 0.00013; % size N, N
%TP(3,2) = 0.02913; % size N, N
%TP(3,3) = 0.97074; % size N, N
%for i=1:N,
%    for j=1:N,
%        TP_dec(i, j) = float2myDec(TP(i, j), OP2_WIDTH);
%    end
%end
load("../nexys4/test/b.mat");
load("../nexys4/test/pi.mat");
load("../nexys4/test/tp.mat");
alpha = zeros(N, L);

% sequence detection
% ==============================================================================
tic;
%for i=1:10,
    Ps = forward_s_basic(N, L, PI, B, TP, seq_e)
%end
toc;
%
%for i=1:N,
%    for j=1:L,
%        alpha_dec(i, j) = float2myDec(alpha(i, j), OP1_WIDTH);
%    end
%end
