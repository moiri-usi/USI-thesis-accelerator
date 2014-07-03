source("../../model/float2myDec.m");
OP1_WIDTH = 25;
OP2_WIDTH = 18;

load("b.mat");
load("pi.mat");
load("tp.mat");
load("seq_e.mat");

for i=1:length(PI),
    [PI_dec(i) PI_bin(i, :)] = float2myDec(PI(i)*32, OP1_WIDTH);
end
save pi_bin_scale.mat PI_bin;

for i=1:length(B(:, 1)),
    [B_dec(i) B_bin(i, :)] = float2myDec(B(i, seq_e(1))*256, OP2_WIDTH);
end
save b_bin_scale.mat B_bin;

TP_list = reshape(TP, [], 1);
for i=1:length(TP_list),
    [TP_dec(i) TP_bin(i, :)] = float2myDec(TP_list(i)*32, OP2_WIDTH);
end
save tp_bin_scale.mat TP_bin;
