%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to convert floating-point to fixed-point representation
%
% @param f:         floating-point number to convert
% @param width:     width of d (in bits)
% @return d:        fixed-point number as decimal
% @return bin_arr:  binary representation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
