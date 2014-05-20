library ieee; 
use ieee.std_logic_1164.all; 
use work.param_pkg.all;

entity mux_2_op2 is
    port(
        sel       : in  std_logic;
        data_in_1 : in  std_logic_vector(OP2_WIDTH);
        data_in_2 : in  std_logic_vector(OP2_WIDTH);
        data_out  : out std_logic_vector(OP2_WIDTH)
    );
end mux_2_op2;

architecture mux of mux_2_op2 is
begin
    process(sel, data_in_1, data_in_2)
    begin
        if sel = '0' then
            data_out <= data_in_1;
        elsif sel = '1' then
            data_out <= data_in_2;
        else
            data_out <= (others => '0');
        end if;
    end process;
end mux;
