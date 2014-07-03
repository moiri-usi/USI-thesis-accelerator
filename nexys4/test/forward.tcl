isim force add clk 0 -time 0 -value 1 -time 5ns -repeat 10ns
run 10ns
isim force add reset_n 0
isim force add tp_we 0
isim force add pi_we 0
isim force add b_we 0
isim force add data_ready 0
run 10ns
isim force add reset_n 1
run 30ns
run 10ns
isim force add data_ready 1
run 10ns
