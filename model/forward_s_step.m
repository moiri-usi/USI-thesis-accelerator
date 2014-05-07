%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% computation of one step of the extended forward algorithm
%
% @param N:             number of states
% @param dk:            delay of k-th observation symbol
% @param alpha:         forward variables of step k-1. size N
% @param B:             emission probabilities of step k. size N
% @param cdf_param:     parameters for the cdf
% @param alpha_new:     forward variables of step k. size N
% @return scale_coeff:  scaling coefficient of step k
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [alpha_new scale_coeff] = forward_s_step.m(N, dk, alpha, B, cdf_param)
    % compute transistion probabilities
    tp = compute_tp(N, dk, cdf_param);
    % compute forward algorithm
    for j=1:N,
        alpha_new(j) = 0;
        for i=1:N,
            alpha_new(j) += alpha(i) * tp(i, j);
        end
        alpha_new(j) *= B(j);
    end
    % scaling
    alpha_sum = 0;
    for i=1:N,
        alpha_sum += alpha_new(i);
    end
    scale_coeff = 1 / alpha_sum;
    for i=1:N,
        alpha_new(i) *= scale_coeff;
    end
end
