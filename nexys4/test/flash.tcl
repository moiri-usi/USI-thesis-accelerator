isim force add clk 0 -time 0 -value 1 -time 10ns -repeat 20ns
run 300ns
isim force add reset_n 0
isim force add read_reg 0
isim force add reg_type 0
run 300ns
isim force add reset_n 1
run 300ns
isim force add read_reg 1
run 40ns
isim force add read_reg 0
run 500ns
