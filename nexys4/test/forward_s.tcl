isim force add clk 0 -time 0 -value 1 -time 5ns -repeat 10ns
isim force add reset_n 0
isim force add tp_we 0
isim force add pi_we 0
isim force add b_we 0
isim force add shift_in 2
isim force add data_ready 0
run 10ns
isim force add reset_n 1
run 30ns
isim force add pi_we 1
isim force add tp_we 1
isim force add b_we 1
isim force add pi_in 6301857
isim force add b_in 87244
isim force add tp_in 191627
run 10ns
isim force add data_ready 1
isim force add pi_in 11998393
isim force add b_in 12928
isim force add tp_in 3386
run 10ns
isim force add pi_in 15254180
isim force add b_in 161970
isim force add tp_in 67129
run 10ns
isim force add pi_we 0
isim force add b_we 0
isim force add tp_in 41300
run 10ns
isim force add tp_in 119888
run 10ns
isim force add tp_in 100954
run 10ns
isim force add tp_in 34
run 10ns
isim force add tp_in 7636
run 10ns
isim force add tp_in 254473
run 10ns
isim force add tp_we 0
run 190ns

for {set i 0} {$i < 3} {incr i} {
    isim force add tp_we 1
    isim force add b_we 1
    isim force add tp_in 191627
    isim force add b_in 87244
    run 10ns
    isim force add tp_in 3386
    isim force add b_in 12928
    run 10ns
    isim force add tp_in 67129
    isim force add b_in 161970
    run 10ns
    isim force add b_we 0
    isim force add tp_in 41300
    run 10ns
    isim force add tp_in 119888
    run 10ns
    isim force add tp_in 100954
    run 10ns
    isim force add tp_in 34
    run 10ns
    isim force add tp_in 7636
    run 10ns
    isim force add tp_in 254473
    run 10ns
    isim force add tp_we 0
    run 190ns
}
run 40ns
