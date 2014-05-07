%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% computation of the initial values of the forward algorithm
%
% @param N:             number of states
% @param PI:            initial state probability vector. size N
% @param B:             matrix of emission probabilities of step 0. size N
% @return alpha:        initial forward variables. size N
% @return scale_coeff:  initial scaling coefficient
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [alpha scale_coeff] = forward_s_init(N, PI, B)
    for i=1:N,
        alpha(i) = PI(i)*B(i);
    end
    % scaling
    alpha_sum = 0;
    for i=1:N,
        alpha_sum += alpha(i);
    end
    scale_coeff = 1 / alpha_sum;
    for i=1:N,
        alpha(i) *= scale_coeff;
    end
end
