--------------------------------------------------------------------------------
-- Multiplicator                                                              --
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

entity mul is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        enable  : in  std_logic;
        op1     : in  std_logic_vector (OP1_WIDTH);
        op2     : in  std_logic_vector (OP2_WIDTH);
        mul     : out std_logic_vector (MUL_WIDTH)
    );
end mul;

architecture arch of mul is
    signal s_reg_op1 : std_logic_vector (OP1_WIDTH);
    signal s_reg_op2 : std_logic_vector (OP2_WIDTH);
    signal s_reg_mul : std_logic_vector (MUL_WIDTH);
begin
    mul <= s_reg_mul;
    process(clk, reset_n, enable)
    begin
        if reset_n = '0' then
            s_reg_op1 <= (others => '0');
            s_reg_op2 <= (others => '0');
            s_reg_mul <= (others => '0');
        else
            if enable = '1' and clk = '1' and clk'event then
                s_reg_op1 <= op1;
                s_reg_op2 <= op2;
                s_reg_mul <= s_reg_op1 * s_reg_op2;
            end if;
        end if;
    end process;
end arch;
