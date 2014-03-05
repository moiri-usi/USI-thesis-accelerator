function [scale_coeff beta] = backward (N, L, V, B)
    % computation of the backward variable
    % N: number of states
    % L: number of observation symbols
    % V: size N, N, L
    % B: matrix of emission probabilities. size N, L
    % result: matrix of coefficients. size N, L

    % initialize variables
    beta = zeros(N, L);
    scale_coeff = zeros(L, 1);
    k = L;

    % compute first elements
    beta(:, L) = ones(N, 1); % eq. 6.40
    scale_coeff(L) = 1 / sum(beta(:, L), 1);
    beta(:, L) *= scale_coeff(L);

    % compute backward variable
    while (k > 1),
        k--;
        beta(:, k) = V(:, :, k) * (B(:, k) .* beta(:, k+1)); % eq 6.40
        scale_coeff(k) = 1 / sum(beta(:, k), 1);
        beta(:, k) *= scale_coeff(k);
    end;
end;
