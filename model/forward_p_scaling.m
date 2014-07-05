%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% computation of the forward algorithm with scalingi with matrix operations
%
% @param N:             number of states
% @param L:             number of observation symbols
% @param PI:            initial state probability vector. size N
% @param B:             matrix of emission probabilities. size N, L
% @param TP:            transistion probabilities. size N, N
% @param oL:            indices of all observed symbols. size 1, L
% @return Ps:           probability likelihood
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [lPs] = forward_p_scaling(N, L, PI, B, TP, oL)
    % initialize forward variables
    alpha = PI .* B(:, oL(1));
    % scaling
    alpha_sum = sum(alpha);
    scale_coeff = zeros(L, 1);
    scale_coeff(1) = 1 / alpha_sum;
    alpha *= scale_coeff(1);
    % forward algorithm
    for k=2:L,
        alpha_new = (TP * alpha) .* B(:, oL(k));
        % scaling
        alpha_sum = sum(alpha_new);
        scale_coeff(k) = 1 / alpha_sum;
        alpha = alpha_new .* scale_coeff(k);
    end
    % compute log likelihood
    lPs = -sum(log(scale_coeff));
end
