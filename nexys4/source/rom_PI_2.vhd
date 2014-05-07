library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.param_pkg.all;

entity rom_PI_2 is
    port (
        out1 : out std_logic_vector (PI_WIDTH);
        out2 : out std_logic_vector (PI_WIDTH)
    );
end rom_PI_2;

architecture rom_PI_2_arch of rom_PI_2 is
type rom_type is array(0 to 1) of std_logic_vector(PI_WIDTH);
constant val_PI : rom_type := ( 
    "00000001",
    "00000011"
);
begin
    out1 <= val_PI(0);
    out2 <= val_PI(1);
end rom_PI_2_arch;
