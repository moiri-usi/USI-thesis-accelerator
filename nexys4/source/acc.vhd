--------------------------------------------------------------------------------
-- Accumulator with Asyncronous Reset                                         --
--                                                                            --
-- Master's Thesis Project 2014                                               --
-- Università della Svizzera Italiana                                         --
-- Master of Science in Informatics, Embedded System Design                   --
--                                                                            --
-- 05.07.2014, Simon Maurer                                                   --
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity acc is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        enable  : in  std_logic;
        alpha   : in  std_logic_vector (OP1_WIDTH);
        ps      : out std_logic_vector (OP1_WIDTH)
    );
end acc;

architecture arch of acc is
    signal s_reg_op : std_logic_vector (OP1_WIDTH);
begin
    ps <= s_reg_op;
    process(clk, reset_n, enable)
    begin
        if reset_n = '0' then
            s_reg_op <= (others => '0');
        else
            if enable = '1' and clk = '1' and clk'event then
                s_reg_op <= s_reg_op + alpha;
            end if;
        end if;
    end process;
end arch;
