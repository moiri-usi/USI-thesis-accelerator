library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.param_pkg.all;

entity rom_PI is
    port (
        PI_out : out std_logic_vector (OP1_WIDTH)
    );
end rom_PI;

architecture rom of rom_PI is
type rom_type is array(0 to 1) of std_logic_vector(OP1_WIDTH);
constant val_PI : rom_type := ( 
    "0100000000000000000000001",
    "0100000000000000000000001"
);
begin
    PI_out <= val_PI(0);
end rom;
