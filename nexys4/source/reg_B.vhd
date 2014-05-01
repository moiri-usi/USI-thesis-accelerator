library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity reg_B is
    port ( 
        clk     : in std_logic;
        reset_n : in std_logic;
        load    : in std_logic;
        B_in    : in std_logic_vector (B_WIDTH);
        B_out   : out std_logic_vector (B_WIDTH)
    );
end reg_B;

architecture reg_B_arch of reg_B is
begin
    process(clk, reset_n, load)
    begin
        if reset_n = '0' then
            B_out <= (others => '0');
        else
            if load = '1' and rising_edge(clk) then
                B_out <= B_in;
            end if;
        end if;
    end process;
end reg_B_arch;
