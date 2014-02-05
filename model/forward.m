function [alpha] = forward (N, L, PI, V, B)
    % computation of the forward variable
    % N: number of states
    % L: number of observation symbols
    % PI: initial state probability vector. size N
    % V: size N, N
    % B: matrix of emission probabilities. size N, L
    % result: matrix of coefficients. size N,L

    % initialize variables
    alpha = zeros(N, L+1);
    k = 1;

    % compute first elements
    alpha(:, 1) = PI .* B(:, 1); % eq. 6.16

    % compute forward algorithm
    while (k <= L),
        %    (N, 1)   =  (N, 1)   .*       (1, N)  *  (N, N)
        %             =  (N, 1)   .* (N, 1)
        alpha(:, k+1) = B(:, k) .* (alpha(:, k)' * V)'; % eq. 6.16
        k++;
    end;
    alpha = alpha(:, 1:end-1);
end;
