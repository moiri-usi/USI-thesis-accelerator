function [lPs] = logLikelihood (alpha)
    % compute the log-likelihood
    % alpha: scaled coefficients of the forward algorithm. size 1,L
    % result: log-likelihood of a sequence
    lPs = -log(sum(alpha)); % eq. 6.19
end;
