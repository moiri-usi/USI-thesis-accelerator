function [c] = scale (val)
    % scale values
    % alpha: input value to scale
    % result: scaled values
    c = 1 ./ sum(val); % eq. 6.18
end;
