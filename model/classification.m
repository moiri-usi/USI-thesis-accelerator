function [res] = classification (lPs0, lPsu, Pc, cost)
    % classifies the sequence either as failure (true) or as non-failure (false)
    % lPs0: Sequence log-likelihood of the non-failure model
    % lPsu: vector of sequence log-likelihood of u failure models. size u
    % Pc: object with class probabilities {f, f_}
    % cost: object with cost values {rff, rf_f_, rf_f, rff_}
    % return: true if failure, false if non-failure

    theta = log((cost.rf_f - cost.rf_f_) / (cost.rff_ - cost.rff))...
        + log(Pc.f_ / Pc.f) % eq. 7.19
    res = max(lPsu) - lPs0 > theta; % eq. 7.22
end;
