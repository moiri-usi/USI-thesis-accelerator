%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to convert fixed-point to floating-point representation
%
% @param d:         decimal number to convert
% @param width:     width of d (in bits)
% @return f:        floating point number
% @return bin_arr:  binary representation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [f, bin_arr] = myDec2float(d, width)
    bin_arr = de2bi(d, width, 'left-msb');
    f = 0;
    for n=1:width,
        f += bin_arr(n)*0.5^n;
    end
end
