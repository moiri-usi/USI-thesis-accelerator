library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity macc_p is
    port(
        clk:     in  std_logic;
        reset_n: in  std_logic;
        load:    in  std_logic;
        op1:     in  std_logic_vector (OP1_WIDTH);
        op2:     in  std_logic_vector (OP2_WIDTH);
        res:     out std_logic_vector (MACC_WIDTH)
    );
end macc_p;

architecture macc of macc_p is
    signal s_reg_op1 : std_logic_vector (OP1_WIDTH);
    signal s_reg_op2 : std_logic_vector (OP2_WIDTH);
    signal s_reg_mul : std_logic_vector (MUL_WIDTH);
    signal s_reg_acc : std_logic_vector (MACC_WIDTH);
begin
    res <= s_reg_acc;
    process(clk, reset_n, load)
    begin
        if reset_n = '0' then
            s_reg_op1 <= (others => '0');
            s_reg_op2 <= (others => '0');
            s_reg_mul <= (others => '0');
            s_reg_acc <= (others => '0');
        else
            if load = '1' and clk = '1' and clk'event then
                s_reg_op1 <= op1;
                s_reg_op2 <= op2;
                s_reg_mul <= s_reg_op1 * s_reg_op2;
                s_reg_acc <= s_reg_acc + s_reg_mul;
            end if;
        end if;
    end process;
end macc;
