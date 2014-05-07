%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% computation of the extended forward algorithm
%
% @param N:             number of states
% @param L:             number of observation symbols
% @param PI:            initial state probability vector. size N
% @param B:             matrix of emission probabilities. size N, L
% @param cdf_param:     parameters for the cdf
% @return alpha:        forward variables. size N, L
% @return scale_coeff:  scaling coefficients (needed for log likelihood). size L
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [alpha lPs] = forward_s(N, L, PI, B, dL, oL, cdf_param)
    k = 1;
    % read o0: index of first observation symbol
    % initialize forward variables
    [alpha(:, 1) scale_coeff(1)] = forward_s_init(N, PI, B(:, oL(1)));
    % forward algorithm
    while (k < L),
        % read ok: index of k-th observation symbol
        % read dk: delay of k-th observation symbol
        % compute one step of forward algorithm
        [alpha(:, k+1) scale_coeff(k+1)] = ...
            forward_s_step(N, dL(k), alpha(:, k), B(:, oL(k)), cdf_param);
        k++;
    end
    % compute log likelihood
    lPs = 0;
    for i=1:N,
        lPs -= log(scale_coeff(i));
    end
end
