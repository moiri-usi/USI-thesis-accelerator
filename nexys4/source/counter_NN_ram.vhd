library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity counter_NN_ram is
    port ( 
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        enable   : in  std_logic;
        max_val  : in  std_logic_vector(NN_LOG_RAM_RANGE);
        count    : out std_logic_vector(NN_LOG_RAM_RANGE)
    );
end counter_NN_ram;

architecture counter of counter_NN_ram is
signal s_count : std_logic_vector(NN_LOG_RAM_RANGE);
begin
    count <= s_count;
    process(clk, reset_n, enable)
    begin
        if reset_n = '0' then
            s_count <= (NN_LOG_RAM_CNT-1 downto 1 => '0') & '1';
        else
            if enable = '1' and rising_edge(clk) then
                if s_count = max_val then
                    s_count <= (NN_LOG_RAM_CNT-1 downto 1 => '0') & '1';
                else
                    s_count <= s_count + 1;
                end if;
            end if;
        end if;
    end process;
end counter;
