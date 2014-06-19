library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity lzc_op2 is
    port (
        data_in  : in  std_logic_vector(OP2_WIDTH);
        data_out : out std_logic_vector(OP2_WIDTH)
    );
end lzc_op2;


architecture arch of lzc_op2 is
begin
    process(data_in)
        variable leading_zeros, shift_fact : integer;
    begin
        leading_zeros := 0;
        shift_fact := 1;
        L1: loop
            exit L1 when leading_zeros = OP2_CNT;
            exit L1 when data_in(OP2_CNT-leading_zeros-1) = '1';
            leading_zeros := leading_zeros+1;
            shift_fact := 2*shift_fact;
        end loop;
        data_out <= std_logic_vector(to_unsigned(shift_fact, OP2_CNT));
    end process;
end arch;
