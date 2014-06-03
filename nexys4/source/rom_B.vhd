library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.param_pkg.all;

entity rom_B is
    port (
        B_out : out std_logic_vector (OP2_WIDTH)
    );
end rom_B;

architecture rom of rom_B is
type rom_type is array(0 to 1) of std_logic_vector(OP2_WIDTH);
constant val_B : rom_type := ( 
    "010000000000000001",
    "010000000000000001"
);
begin
    B_out <= val_B(0);
end rom;
