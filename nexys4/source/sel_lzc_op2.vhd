library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity sel_lzc_op2 is
    port (
        data_in : in  std_logic_vector(OP2_LOG_WIDTH);
        ref_in  : in  std_logic_vector(OP2_LOG_WIDTH);
        sel_new : out std_logic
    );
end sel_lzc_op2;

architecture arch of sel_lzc_op2 is
begin
    process(data_in, ref_in)
    begin
        if (data_in < ref_in) or ((data_in > (OP2_LOG_WIDTH => '0'))
            and ref_in = (OP2_LOG_WIDTH => '0')) then
            sel_new <= '1';
        else
            sel_new <= '0';
        end if;
    end process;
end arch;
