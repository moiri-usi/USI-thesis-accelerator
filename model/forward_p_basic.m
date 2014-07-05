%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% computation of the forward algorithm without scaling with matrix operations
%
% @param N:             number of states
% @param L:             number of observation symbols
% @param PI:            initial state probability vector. size N
% @param B:             matrix of emission probabilities. size N, L
% @param TP:            transistion probabilities. size N, N
% @param oL:            indices of all observed symbols. size 1, L
% @return Ps:           probability likelihood
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Ps] = forward_p_basic(N, L, PI, B, TP, oL)
    % initialize forward variables
    alpha = PI .* B(:, oL(1));
    % forward algorithm
    for k=2:L,
        alpha_new = (TP * alpha) .* B(:, oL(k));
        alpha = alpha_new;
    end
    % compute likelihood
    Ps = sum(alpha_new);
end
