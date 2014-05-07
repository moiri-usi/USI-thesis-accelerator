N = 100;
L = 100;
PI = read_PI();
B = read_B();
cdf_param = read_cdf();

while(symb = read_next())
    dL = [dL(2:end); symb.d];
    oL = [oL(2:end); symb.o];
    lPs = forward_s(N, L, PI, B, dL, oL, cdf_param);
end
