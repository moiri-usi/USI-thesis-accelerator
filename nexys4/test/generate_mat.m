source("../../model/float2myDec.m");

% initialisation of test values
% ==============================================================================
OP1_WIDTH = 25;
OP2_WIDTH = 18;
N = 100; % number of states
M = 1000; % number of observation symbols
L = 200; % sequence lengt
seq_e = randint(1, L, [1 M]); % example sequence
alphabet = [1:M]; % alphabet (list of observation symbols)
% PI: initial state probability vector. size N
PI = abs(rand(N, 1));
PI = PI./sum(PI);
PI_dec = zeros(N, 1);
PI_bin = zeros(N, OP1_WIDTH);
for i=1:N,
    [PI_dec(i) PI_bin(i, :)] = float2myDec(PI(i), OP1_WIDTH);
end
save pi.mat PI_bin;
% B: matrix of emission probabilities
B = abs(rand(N, M)); % size N, M
B = B./repmat(sum(B, 2), 1, M);
B_dec = zeros(N);
B_bin = zeros(N, OP2_WIDTH);
for i=1:N,
    [B_dec(i) B_bin(i, :)] = float2myDec(B(i, seq_e(1)), OP2_WIDTH);
end
save b.mat B_bin;
% TP: matrix of tansition probabilities
TP = abs(rand(N, N)); % size N, N
TP = TP./repmat(sum(TP, 2), 1, N);
TP_list = reshape(TP, [], 1);
TP_dec = zeros(length(TP_list), 1);
TP_bin = zeros(length(TP_list), OP2_WIDTH);
for i=1:length(TP_list),
    [TP_dec(i) TP_bin(i, :)] = float2myDec(TP_list(i), OP2_WIDTH);
end
save tp.mat TP_bin;
