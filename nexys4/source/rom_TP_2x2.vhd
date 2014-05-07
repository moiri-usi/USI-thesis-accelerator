library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.param_pkg.all;

entity rom_TP_2x2 is
    port (
        out11 : out std_logic_vector (TP_WIDTH);
        out12 : out std_logic_vector (TP_WIDTH);
        out21 : out std_logic_vector (TP_WIDTH);
        out22 : out std_logic_vector (TP_WIDTH)
    );
end rom_TP_2x2;

architecture rom_TP_2x2_arch of rom_TP_2x2 is
type rom_type is array(0 to 3) of std_logic_vector(TP_WIDTH);
constant val_TP : rom_type := ( 
    "00000001",
    "00000010",
    "00000011",
    "00000100"
);
begin
    out11 <= val_TP(0);
    out12 <= val_TP(1);
    out21 <= val_TP(2);
    out22 <= val_TP(3);
end rom_TP_2x2_arch;
