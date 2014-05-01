isim force add clk 0 -time 0 -value 1 -time 100 -repeat 200
isim force add reset_n 0
isim force add load 0
isim force add B_in 0
run 250 ps
isim force add reset_n 1
run 140 ps
isim force add B_in 1
run 30 ps
isim force add load 1
run 200 ps
isim force add load 0
run 570 ps
isim force add B_in 3
run 30 ps
isim force add load 1
run 200 ps
isim force add load 0
run 480 ps
