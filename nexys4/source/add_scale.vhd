library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity add_scale is
    port (
        scale_in  : in  std_logic_vector(SCALE_WIDTH);
        lzc_in    : in  std_logic_vector(OP2_LOG_WIDTH);
        scale_out : out std_logic_vector(SCALE_WIDTH)
    );
end add_scale;

architecture add of add_scale is
begin
    process(scale_in, lzc_in)
    begin
        scale_out <= scale_in
            + ((SCALE_CNT-OP2_LOG_CNT-1 downto 0 => '0') & lzc_in);
    end process;
end add;
