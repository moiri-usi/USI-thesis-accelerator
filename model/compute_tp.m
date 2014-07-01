%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% computation of the extended transition probabilities
%
% @param N:         number of states
% @param dk:        delay of k-th observation symbol
% @param cdf_param: parameters for the cdf
% @param P:         transmission probabilities
% @return V:        extended transition probabilities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [V] = compute_tp(N, dk, cdf_param, P)
    % compute all elements of v
    for i=1:N,
        for j=1:N,
            V(i, j) = P(i, j)*normcdf(dk, cdf_param.mu(i, j), cdf_param.sigma(i, j));
        end
    end
    % correct diagonal elemnts of v
    for i=1:N,
        for j=1:N,
            V_sum(i) += V(i, j);
        end
    end
    for i=1:N,
        V_sum(i) -= V(i, i);
        V(i, i) = 1 - V_sum(i);
    end
end
