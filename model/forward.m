function [alpha] = forward (N, L, PI, P, D, B)
    % computation of the forward algorithm
    % N: number of states
    % L: number of observation symbols
    % PI: initial state probability vector. size N
    % P: matrix of limiting tansmission probabilities. size N, N
    % D: matrix of cumulative transition duration distribution functions. size N,N
    % B: matrix of emission probabilities. size N, L
    % result: matrix of coefficients. size N,L

    % initialize variables
    alpha = zeros(N, L+1);
    k = 1;

    % compute of V
    V = P.*D; % eq. 6.7
    V = V.*(ones(N)-eye(N)) + diag(1-(sum(V')' - diag(V))); % eq. 6.13

    % compute first elements
    alpha(:, 1) = PI .* B(:, 1); % eq. 6.16

    % compute forward algorithm
    while (k <= L),
        %    (N, 1)   =  (N, 1)   .*       (1, N)  *  (N, N)
        %             =  (N, 1)   .* (N, 1)
        alpha(:, k+1) = B(:, k+1) .* (alpha(:, k)' * V)'; % eq. 6.16
        k++;
    end;
end
