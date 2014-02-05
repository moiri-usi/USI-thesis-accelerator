function [beta] = backward (N, L, V, B)
    % computation of the backward variable
    % N: number of states
    % L: number of observation symbols
    % V: size N, N
    % B: matrix of emission probabilities. size N, L
    % result: matrix of coefficients. size N,L

    % initialize variables
    beta = zeros(N, L);
    k = L-1;

    % compute first elements
    beta(:, L) = ones(N, 1); % eq. 6.40

    % compute backward variable
    while (k > 0),
        beta(:, k) = V * (B(:, k+1) .* beta(:, k+1)); % eq 6.40
        k--;
    end;
end;
