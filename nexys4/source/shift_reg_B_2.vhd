library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity shift_reg_B_2 is
    port ( 
        clk     : in std_logic;
        reset_n : in std_logic;
        load    : in std_logic;
        B_in    : in std_logic_vector (B_WIDTH);
        B_out   : out std_logic_vector (B_WIDTH)
    );
end shift_reg_B_2;

architecture shift_reg_B_2_arch of shift_reg_B_2 is
signal s_B : std_logic_vector (B_WIDTH);
signal s_clk, s_reset_n, s_load : std_logic;
component reg_B is
port (
    clk     : in std_logic;
    reset_n : in std_logic;
    load    : in std_logic;
    B_in    : in std_logic_vector (B_WIDTH);
    B_out   : out std_logic_vector (B_WIDTH)
);
end component;

begin
    s_clk     <= clk;
    s_reset_n <= reset_n;
    s_load    <= load;

    reg1: reg_B port map (
        clk     => s_clk,
        reset_n => s_reset_n,
        load    => s_load,
        B_in    => B_in,
        B_out   => s_B
    );

    reg2: reg_B port map (
        clk     => s_clk,
        reset_n => s_reset_n,
        load    => s_load,
        B_in    => s_B,
        B_out   => B_out
    );
end shift_reg_B_2_arch;
