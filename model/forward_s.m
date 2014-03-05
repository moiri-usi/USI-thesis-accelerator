function [alpha scale_coeff] = forward_s (N, L, PI, V, B)
    alpha = zeros(N, L);
    scale_coeff = zeros(L, 1);
    k = 1;
    for i=1:N, % this loop is parallelizable with vector instructions
        alpha(i, 1) = PI(i) * B(i, 1);
    end;
    scale_coeff(1) = 1 / sum(alpha(:, 1), 1);
    alpha(:, 1) *= scale_coeff(1);
    while (k < L),
        for j=1:N, % this loop is parallelizable with vector instructions
            for i=1:N,
                % this loop could be replaced by an accumulator
                % (its a scalar product, B is constant)
                alpha(j, k+1) += alpha(i, k) * V(i, j, k) * B(j, k);
                %alpha(j, k+1) += (alpha(i, k) * V(i, j));
            end;
            %alpha(j, k+1) *= B(j, k+1);
        end;
        scale_coeff(k+1) = 1 / sum(alpha(:, k+1), 1);
        alpha(:, k+1) *= scale_coeff(k+1);
        k++;
    end;
end
