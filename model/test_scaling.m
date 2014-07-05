% initialisation of test values
% ==============================================================================
%N = 100; % number of states
%L = 200; % sequence lengt
load("../nexys4/test/seq_e.mat");
load("../nexys4/test/b.mat");
load("../nexys4/test/pi.mat");
load("../nexys4/test/tp.mat");
alpha = zeros(N, L);

% sequence detection
% ==============================================================================
Ps = forward_p_scaling(N, L, PI, B, TP, repmat(seq_e(1), 1, L))
