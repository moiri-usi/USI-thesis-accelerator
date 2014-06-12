library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity counter_N is
    port ( 
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        enable   : in  std_logic;
        count    : out std_logic_vector(N_LOG_RANGE)
    );
end counter_N;

architecture counter of counter_N is
signal s_count : std_logic_vector(N_LOG_RANGE);
begin
    count <= s_count;
    process(clk, reset_n, enable)
    begin
        if reset_n = '0' then
            s_count <= (others => '0');
        else
            if enable = '1' and rising_edge(clk) then
                s_count <= s_count + 1;
                if s_count = N_CNT-1 then
                    s_count <= (others => '0');
                end if;
            end if;
        end if;
    end process;
end counter;
