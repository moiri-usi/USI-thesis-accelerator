library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity mul_p is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        enable  : in  std_logic;
        op1_in  : in  std_logic_vector (OP1_WIDTH);
        op2_in  : in  std_logic_vector (OP2_WIDTH);
        mul_out : out std_logic_vector (MUL_WIDTH)
    );
end mul_p;

architecture mul of mul_p is
    signal s_reg_op1 : std_logic_vector (OP1_WIDTH);
    signal s_reg_op2 : std_logic_vector (OP2_WIDTH);
    signal s_reg_mul : std_logic_vector (MUL_WIDTH);
begin
    mul_out <= s_reg_mul;
    process(clk, reset_n, enable)
    begin
        if reset_n = '0' then
            s_reg_op1 <= (others => '0');
            s_reg_op2 <= (others => '0');
            s_reg_mul <= (others => '0');
        else
            if enable = '1' and clk = '1' and clk'event then
                s_reg_op1 <= op1_in;
                s_reg_op2 <= op2_in;
                s_reg_mul <= s_reg_op1 * s_reg_op2;
            end if;
        end if;
    end process;
end mul;
