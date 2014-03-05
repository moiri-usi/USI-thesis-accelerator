function [scale_coeff alpha] = forward (N, L, PI, V, B)
    % computation of the forward variable
    % N: number of states
    % L: number of observation symbols
    % PI: initial state probability vector. size N
    % V: size N, N, L
    % B: matrix of emission probabilities. size N, L
    % result: matrix of coefficients. size N, L

    % initialize variables
    alpha = zeros(N, L);
    scale_coeff = zeros(L, 1);
    k = 1;

    % compute first elements
    alpha(:, 1) = PI .* B(:, 1); % eq. 6.16
    scale_coeff(1) = 1 / sum(alpha(:, 1), 1);
    alpha(:, 1) *= scale_coeff(1);

    % compute forward algorithm
    while (k < L),
        %    (N, 1)   =  (N, 1)   .*       (1, N)  *  (N, N)
        %             =  (N, 1)   .* (N, 1)
        alpha(:, k+1) = B(:, k) .* (alpha(:, k)' * V(:, :, k))'; % eq. 6.16
        scale_coeff(k+1) = 1 / sum(alpha(:, k+1), 1);
        alpha(:, k+1) *= scale_coeff(k+1);
        k++;
    end;
end;
