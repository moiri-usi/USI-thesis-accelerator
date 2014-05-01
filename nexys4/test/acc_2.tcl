onerror {resume}
wave add /
isim force add in11 0000 -radix bin
isim force add in12 0000 -radix bin
isim force add in21 0000 -radix bin
isim force add in22 0000 -radix bin
run
isim force add in11 0001 -radix bin
isim force add in12 0000 -radix bin
isim force add in21 0001 -radix bin
isim force add in22 0000 -radix bin
run
isim force add in11 0001 -radix bin
isim force add in12 0001 -radix bin
isim force add in21 0001 -radix bin
isim force add in22 0001 -radix bin
run
isim force add in11 0001 -radix bin
isim force add in12 0011 -radix bin
isim force add in21 0001 -radix bin
isim force add in22 0101 -radix bin
run
