isim force add clk 0 -time 0 -value 1 -time 5ns -repeat 10ns
isim force add reset_n 0
isim force add b_in 87244
isim force add tp_in 60555
isim force add pi_in 6301857
run 100ns
isim force add reset_n 1
run 2000ns
