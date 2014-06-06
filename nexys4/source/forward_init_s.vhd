library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity forward_init_s is
    port (
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        flush     : in  std_logic;
        enable    : in  std_logic;
        PI_in     : in  std_logic_vector(OP1_WIDTH);
        B_in      : in  std_logic_vector(OP2_WIDTH);
        alpha_out : out std_logic_vector(OP1_WIDTH)
    );
end forward_init_s;

architecture forward_init_arch of forward_init_s is
signal s_mul : std_logic_vector(MUL_WIDTH);
signal s_reset : std_logic;

component mul_s is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        enable  : in  std_logic;
        op1     : in  std_logic_vector(OP1_WIDTH);
        op2     : in  std_logic_vector(OP2_WIDTH);
        mul     : out std_logic_vector(MUL_WIDTH)
    );
end component;

begin
    s_reset <= reset_n and not(flush);

    mul: mul_s port map (
        clk     => clk,
        reset_n => s_reset,
        enable  => enable,
        op1     => PI_in,
        op2     => B_in,
        mul     => s_mul
    );

    alpha_out <= s_mul(MUL_MOST_WIDTH);

end forward_init_arch;
