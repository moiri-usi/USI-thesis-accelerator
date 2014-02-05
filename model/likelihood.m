function [ps] = likelihood (alpha)
    % compute the likelihood
    % alpha: coefficients of the forward algorithm. size N,L
    % result: likelihood of a sequence
    ps = sum(alpha(:,end)); % eq. 6.17
end;
