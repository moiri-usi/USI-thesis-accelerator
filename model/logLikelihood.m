function [lPs] = logLikelihood (alpha)
    % compute the log-likelihood
    % alpha: coefficients of the forward algorithm. size N,L
    % result: log-likelihood of a sequence
    c = 1 ./ sum(alpha); % eq. 6.18
    lPs = -log(sum(c)); % eq. 6.19
end;
