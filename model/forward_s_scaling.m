%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% computation of the forward algorithm with scaling
%
% @param N:             number of states
% @param L:             number of observation symbols
% @param PI:            initial state probability vector. size N
% @param B:             matrix of emission probabilities. size N, L
% @param TP:            transistion probabilities. size N, N
% @param oL:            indices of all observed symbols. size 1, L
% @return Ps:           probability likelihood
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [lPs] = forward_s_scaling(N, L, PI, B, TP, oL)
    % initialize forward variables
    for i=1:N,
        alpha(i) = PI(i)*B(i, oL(1));
    end
    % scaling
    alpha_sum = 0;
    for i=1:N,
        alpha_sum += alpha(i);
    end
    scale_coeff(1) = 1 / alpha_sum;
    for i=1:N,
        alpha(i) *= scale_coeff(1);
    end
    % forward algorithm
    for k=2:L,
        for j=1:N,
            alpha_new(j) = 0;
            for i=1:N,
                alpha_new(j) += alpha(i) * TP(i, j);
            end
            alpha_new(j) *= B(j, oL(k));
        end
        % scaling
        alpha_sum = 0;
        for i=1:N,
            alpha_sum += alpha_new(i);
        end
        scale_coeff(k) = 1 / alpha_sum;
        for i=1:N,
            alpha_new(i) *= scale_coeff(k);
        end
    end
    % compute log likelihood
    lPs = 0;
    for i=1:L,
        lPs -= log(scale_coeff(i));
    end
end
