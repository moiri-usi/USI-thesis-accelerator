library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.param_pkg.all;

entity rom_TP is
    port (
        TP_out : out std_logic_vector (OP2_WIDTH)
    );
end rom_TP;

architecture rom of rom_TP is
type rom_type is array(0 to 1) of std_logic_vector(OP2_WIDTH);
constant val_TP : rom_type := ( 
    "010000000000000001",
    "010000000000000100"
);
begin
    TP_out <= val_TP(0);
end rom;
