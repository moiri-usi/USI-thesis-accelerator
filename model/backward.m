function [beta] = backward (N, L, PI, P, D, B)
    % computation of the backward variable
    % N: number of states
    % L: number of observation symbols
    % PI: initial state probability vector. size N
    % P: matrix of limiting tansmission probabilities. size N, N
    % D: matrix of cumulative transition duration distribution functions. size N,N
    % B: matrix of emission probabilities. size N, L
    % result: matrix of coefficients. size N,L

    % initialize variables
    beta = zeros(N, L+1);
    k = L;

    % compute V
    V = P.*D; % eq. 6.7
    V = V.*(ones(N)-eye(N)) + diag(1-(sum(V')' - diag(V))); % eq. 6.13

    % compute first elements
    beta(:, L+1) = ones(N, 1); % eq. 6.40

    % compute backward variable
    while (k > 0),
        beta(:, k) = V * (B(:, k+1) .* beta(:, k+1)); % eq 6.40
        k--;
    end;
end;
