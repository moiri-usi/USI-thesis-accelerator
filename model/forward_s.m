function [alpha] = forward_s (N, L, PI, V, B)
    alpha = zeros(N, L+1);
    k = 1;
    for i=1:N, % this loop is parallelizable with vector instructions
        alpha(i, 1) = PI(i) * B(i, 1);
    end;
    while (k <= L),
        for j=1:N, % this loop is parallelizable with vector instructions
            for i=1:N,
                % this loop could be replaced by an accumulator
                % (its a scalar product, B is constant)
                alpha(j, k+1) += (alpha(i, k) * V(i, j) * B(j, k+1));
                %alpha(j, k+1) += (alpha(i, k) * V(i, j));
            end;
            %alpha(j, k+1) *= B(j, k+1);
        end;
        k++;
    end;
end
