function [c] = scale (val)
    % scale values
    % alpha: input value to scale
    % result: log-likelihood of a sequence
    c = 1 ./ sum(val); % eq. 6.18
end;
