% configuration / initialisation
N = 100; % states
L = 200; %observations
PI = rand(N, 1)/N;
P = rand(N)/N;
D = rand(N)/N;
B = rand(N,L+1)/N;

% offline
%%%%%%%%%
% data processing

% model training

% online
%%%%%%%%
% data processing

% sequence processing with one model
alpha = forward(N, L, PI, P, D, B);
lPs = logLikelihood(alpha);

% classification
