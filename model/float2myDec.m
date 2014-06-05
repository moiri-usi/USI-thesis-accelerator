function [d, bin_arr] = float2myDec(f, width)
    rest = f;
    bin_arr = zeros(1, width);
    n = 0;
    while (rest > 0),
        n = ceil(log2(1/rest));
        if n>width,
            break;
        end
        bin_arr(n) = 1;
        rest -= 0.5^n;
    end
    d = bi2de(bin_arr, 'left-msb');
end
