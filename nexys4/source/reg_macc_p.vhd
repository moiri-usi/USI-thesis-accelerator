library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity reg_macc_p is
    port ( 
        clk     : in  std_logic;
        reset_n : in  std_logic;
        load    : in  std_logic;
        shift   : in  std_logic;
        in_a    : in  std_logic_vector (MACC_WIDTH);
        in_s    : in  std_logic_vector (MACC_WIDTH);
        out_a   : out std_logic_vector (MACC_WIDTH)
    );
end reg_macc_p;

architecture reg of reg_macc_p is
begin
    process(clk, reset_n, load)
    begin
        if reset_n = '0' then
            out_a <= (others => '0');
        else
            if load = '1' and rising_edge(clk) then
                if shift = '1' then
                    out_a <= in_s;
                else
                    out_a <= in_a;
                end if;
            end if;
        end if;
    end process;
end reg_macc_p;
