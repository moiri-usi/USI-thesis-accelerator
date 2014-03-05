% initialisation of test values
% ==============================================================================
N = 100; % number of states
M = 30; % number of observation symbols
L = 100; % sequence length
R = 1; % number of cumulative probability distributions
seq_e = randint(1, L, [1 M]); % example sequence
seq_d = randint(1, L, [1 9]); % relative delays of the events
alphabet = [1:M]; % alphabet (list of observation symbols)
dk = repmat(shiftdim(seq_d, -1), [N N 1]); % size N, N, L
eta = 0.01;
bound = 1;
lPs_old = 0;
lPs = bound + 1;

% offline computation
% ==============================================================================
% data processing
% ------------------------------------------------

% model training: step 1
% ------------------------------------------------
% PI: initial state probability vector. size N
PI = abs(rand(N, 1));
% B: matrix of emission probabilities
B = abs(rand(N, M)); % size N, M
B = B ./ repmat(sum(B, 2), [1 M]);
% compute B_comp (matrix to facilitate online/offline computation)
B_comp = B(:, lookup(alphabet, seq_e)); % size N, L
B_comp_ = shiftdim(repmat(transpose(B_comp), [1 1 N]), 1); % size N, N, L
% parameters for gaussian distribution kernel
mu = abs(rand(N, N)); % size N, N
sigma = abs(rand(N, N)); % size N, N
% P: matrix of limiting tansmission probabilities
P = abs(rand(N, N)); % size N, N
P = P ./ repmat(sum(P, 2), [1 N]); % satisfy eq. 6.4
P_ = repmat(P, [1 1 L]); % size N, N, L

% model training: step 2
% ------------------------------------------------
% start iteration 1
%while ((lPs-lPs_old) > bound),
    % compute kernels
    mu_ = repmat(mu, [1 1 L]); % size N, N, L
    sigma_ = repmat(sigma, [1 1 L]); % size N, N, L
    %% gaussian distribution kernel
    %kernel_1 = 1 ./ (sigma_ * sqrt(2*pi)) .* ...
    %    exp(-0.5 * power((dk - mu_) ./ sigma_, 2)); %size N, N, L
    % gaussian cumulative distribution function
    kernel_1 = repmat(0.5 + 1 / pi, [N, N, L]) - ...
        1/pi * exp((mu_ - dk) ./ (sqrt(2) * sigma_)); %size N, N, L
    weights_1 = ones(N, N)/R; % sum(weights, 4) == 1, eq. 6. size N, N
    weights_1_ = repmat(weights_1, [1 1 L]); % size N, N, L

    % other kernels (increase R for each additional kernel)
    %kernel_2 = ...
    %weights_2 = ones(N, N, L)/R; % sum(weights, 4) == 1, eq. 6.
        %...
    %kernel_R = ...
    %weights_R = ones(N, N, L)/R; % sum(weights, 4) == 1, eq. 6.

    % concatenate kernels and weights
    %kernel = cat(4, kernel_1, kernel_2, ..., kernel_R);
    %wights = cat(4, weights_1, weights_2, ..., weights_R);
    kernel = cat(4, kernel_1);
    weights = cat(4, weights_1_);
    % D: matrix of cumulative transition duration distribution functions.
    D = sum((weights .* kernel), 4); % eq. 6.8, size N, N, L
    % compute V, eq. 6.13
    V_s = (D.*P_).*repmat((ones(N) - eye(N)), [1 1 L]); % i != j
    V_d = repmat(1 - sum(V_s, 2), [1 N 1]) .* repmat(eye(N), [1 1 L]); % i == j
    V = V_s + V_d; % size N, N, L
    % compute alpha
    [sacale_ceoff alpha] = forward(N, L, PI, V, B_comp); % size N, L
    alpha_ = shiftdim(repmat(transpose(alpha), [1 1 N]), 1); % size N, N, L
    % compute beta
    [scale_coeff beta] = backward(N, L, V, B_comp); % size N, L
    beta_ = shiftdim(repmat(transpose(beta), [1 1 N]), 1); % size N, N, L
    % compute gamma, size N, L
    gamma = alpha .* beta ./ repmat(transpose(diag(transpose(alpha) * beta)), N, 1);
    %gamma_scale = alpha_scale .* beta_sclale ./ sum(alpha .* beta, 1);
    % compute xi
    xi_n = alpha_ .* V .* B_comp_ .* beta_;
    xi_q = repmat(sum(sum(xi_n, 2), 1), [N N 1]);
    xi = xi_n ./ xi_q; % size N, N, L

    % model training: step 3
    % ------------------------------------------------
    % compute sequence likelihood
    lPs_old = lPs;
    lPs = logLikelihood(alpha);

    % model training: step 4
    % ------------------------------------------------
    % reassign PI
    PI = gamma(:, 1);
    % reassign B
    for m=1:M,
        mask = repmat(seq_e == alphabet(m), [N, 1]);
        B(:, m) = sum((gamma .* mask), 2) ./ sum(gamma, 2);
    end;
    % compute B_comp (matrix to facilitate online/offline computation)
    B_comp = B(:, lookup(alphabet, seq_e)); % size N, L
    B_comp_ = shiftdim(repmat(transpose(B_comp), [1 1 N]), 1); % size N, N, L

    % model training: step 5
    % ------------------------------------------------

    P_new = P;
    mu_new = mu;
    sigma_new = sigma;
    % start itereation 2
    max_it = 100;
    my_plot = zeros(max_it, 1);
    for iteration = [1:max_it],
        % step 5a
        % -------
        % eq. 6.49
        P_ = repmat(P_new, [1 1 L]); % size N, N, L
        mu_ = repmat(mu_new, [1 1 L]); % size N, N, L
        sigma_ = repmat(sigma_new, [1 1 L]); % size N, N, L
        fact_d = D ./ repmat(1 - sum(V_s, 2), [1 N 1]);
        fact_p = P_ ./ repmat(1 - sum(V_s, 2), [1 N 1]);
        xi_diag = repmat(sum(xi .* repmat(eye(N), [1 1 L]), 2), [1 N 1]); % xi(i,i)
        grad_Qp = sum((xi ./ P_ - xi_diag .* fact_d), 3);
        grad_Qp = grad_Qp .* (ones(N) - eye(N)); % set values i == j to 0
        % eq. 6.52
        grad_Qd = sum((xi ./ D - xi_diag .* fact_p), 3);
        grad_Qd = grad_Qd .* (ones(N) - eye(N)); % set values i == j to 0
        % eq. 6.50, 6.51
        %grad_Qw_1 = grad_Qd .* kernel_1; % not needed because R=1

        % compute gradients of kernel by parameter mu
        %grad_kernel_1_mu = sum( ...
        %    (mu_ - dk) ./ power(sigma_, 2) .* kernel_1, 3);
        grad_kernel_1_mu = sum(-1 ./ (sqrt(2) * pi * sigma_) .*...
            exp((mu_ - dk) ./ (sqrt(2) * sigma_)), 3);
        % compute gradients of kernel by parameter sigma
        %grad_kernel_1_sigma = sum( ... 
        %    (-power(sigma_, 2) + power(mu_, 2) - 2 * mu_ .* dk + power(dk, 2)) ./ ...
        %    power(sigma_, 3) .* kernel_1, 3);
        grad_kernel_1_sigma = sum(1 ./ (sqrt(2) * pi * power(sigma_, 2)) .*...
            (mu_ - dk) .* exp((mu_ - dk) ./ (sqrt(2) * sigma_)), 3);

        % eq. 6.53
        grad_Qmu_1 = grad_Qd .* weights_1 .* grad_kernel_1_mu; % size N, N
        grad_Qsigma_1 = grad_Qd .* weights_1 .* grad_kernel_1_sigma; % size N, N

        % other kernels
        %% eq. 6.50, 6.51
        %grad_Qw_2 = grad_Qd .* kernel_2;
        %% eq. 6.53
        %grad_Qparam1_2 = grad_Qd .* weights_2 .* grad_kernel_2_param1;
        %grad_Qparam2_2 = grad_Qd .* weights_2 .* grad_kernel_2_param2;
        %...
        %grad_QparamX_2 = grad_Qd .* weights_2 .* grad_kernel_2_paramX;
        %...
        %grad_Qparam1_R = grad_Qd .* weights_R .* grad_kernel_R_param1;
        %grad_Qparam2_R = grad_Qd .* weights_R .* grad_kernel_R_param2;
        %...
        %grad_QparamX_R = grad_Qd .* weights_R .* grad_kernel_R_paramX;

        %      
        %      % step 5b
        %      %--------
        %      % somehow define M in order to implement constraints (such as sum(P)=1)
        %      M = ones(3*N, N); % eq. 6.61
        %      grad_Q = ((M * M') * grad_Q')'; % eq. 6.62

        % step 5c
        % -------
        % compute eta by line search
        P_new = P_new + eta * grad_Qp;
        mu_new = mu_new + eta * grad_Qmu_1;
        sigma_new = sigma_new + eta * grad_Qsigma_1;
        my_plot(iteration) = P_new(1, 1, 1);
    end
    % stop condition iteration 2
%end
% stop condition iteration 1

% online computation
% ==============================================================================
% data processing
% ------------------------------------------------

% sequence processing with one model
% ------------------------------------------------
alpha = forward(N, L, PI, V, B_comp);
lPs = logLikelihood(scale(alpha));

% classification
% ------------------------------------------------
