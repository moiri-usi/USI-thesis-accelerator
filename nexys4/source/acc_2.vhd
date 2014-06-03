library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity acc_2 is
    port(
        in11 : in  std_logic_vector(OP1_WIDTH);
        in12 : in  std_logic_vector(OP2_WIDTH);
        in21 : in  std_logic_vector(OP1_WIDTH);
        in22 : in  std_logic_vector(OP2_WIDTH);
        acc1 : out std_logic_vector(MUL_RES_WIDTH);
        acc2 : out std_logic_vector(MUL_RES_WIDTH);
        res  : out std_logic_vector(ACC_RES_WIDTH)
    );
end acc_2;

architecture acc_2_arch of acc_2 is
signal s_acc1 : std_logic_vector (MUL_RES_WIDTH);
signal s_acc2 : std_logic_vector (MUL_RES_WIDTH);
begin
    s_acc1 <= in11 * in12;
    s_acc2 <= in21 * in22;
    acc1 <= s_acc1;
    acc2 <= s_acc2;
    res <= s_acc1 + s_acc2;
end acc_2_arch;
