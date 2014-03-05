function [lPs] = logLikelihood (alpha)
    % compute the log-likelihood
    % alpha: scaled coefficients of the forward algorithm. size 1,L
    % result: log-likelihood of a sequence
    lPs = -sum(log(alpha), 1); % eq. 6.19
end;
