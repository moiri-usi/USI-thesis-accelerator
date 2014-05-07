library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity scale_2 is
    port(
        clk        : in std_logic;
        reset_n    : in std_logic;
        coeff_in   : in std_logic_vector (COEFF_WIDTH);
        alpha_in1  : in std_logic_vector (ALPHA_WIDTH);
        alpha_in2  : in std_logic_vector (ALPHA_WIDTH);
        coeff_out  : out std_logic_vector (COEFF_WIDTH);
        alpha_out1 : out std_logic_vector (ALPHA_WIDTH);
        alpha_out2 : out std_logic_vector (ALPHA_WIDTH)
    );
end scale_2;

architecture scale_2_arch of scale_2 is
signal s_coeff : std_logic_vector (COEFF_WIDTH);
begin
    s_coeff <= 1 /  unsigned( coeff_in );
    alpha_out1 <= s_coeff * alpha_in1;
    alpha_out2 <= s_coeff * alpha_in2;
    coeff_out = s_coeff;
end scale_2_arch;
