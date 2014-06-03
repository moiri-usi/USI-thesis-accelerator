library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity acc_s is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        alpha   : in  std_logic_vector (OP1_WIDTH);
        Ps      : out std_logic_vector (OP1_WIDTH)
    );
end acc_s;

architecture acc of acc_s is
    signal s_reg_op : std_logic_vector (OP1_WIDTH);
begin
    Ps <= s_reg_op;
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            s_reg_op <= (others => '0');
        else
            if clk = '1' and clk'event then
                s_reg_op <= s_reg_op + alpha;
            end if;
        end if;
    end process;
end acc;
