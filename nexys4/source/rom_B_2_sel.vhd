library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.param_pkg.all;

entity rom_B_2_sel is
    port (
        idx  : in std_logic_vector (1 downto 0);
        out1 : out std_logic_vector (B_WIDTH);
        out2 : out std_logic_vector (B_WIDTH)
    );
end rom_B_2_sel;

architecture rom_B_2_sel_arch of rom_B_2_sel is
type rom_type is array(0 to 1) of std_logic_vector(B_WIDTH);
constant val_B1 : rom_type := ( 
    "00000001",
    "00000011"
);
constant val_B2 : rom_type := ( 
    "00000010",
    "00000100"
);
begin
    out1 <= val_B1(to_integer( unsigned( idx ) ));
    out2 <= val_B2(to_integer( unsigned( idx ) ));
end rom_B_2_sel_arch;
