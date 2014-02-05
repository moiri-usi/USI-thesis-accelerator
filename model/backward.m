function [beta] = backward (N, L, V, B)
    % computation of the backward variable
    % N: number of states
    % L: number of observation symbols
    % V: size N, N
    % B: matrix of emission probabilities. size N, L
    % result: matrix of coefficients. size N,L

    % initialize variables
    beta = zeros(N, L+1);
    k = L;

    % compute first elements
    beta(:, L+1) = ones(N, 1); % eq. 6.40

    % compute backward variable
    while (k > 0),
        beta(:, k) = V * (B(:, k) .* beta(:, k+1)); % eq 6.40
        k--;
    end;
    beta = beta(:, 2:end);
end;
