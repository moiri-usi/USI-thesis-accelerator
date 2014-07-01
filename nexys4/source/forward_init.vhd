library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity forward_init is
    port (
        clk             : in  std_logic;
        reset_n         : in  std_logic;
        enable          : in  std_logic;
        store_scale_new : in  std_logic;
        store_scale_ok  : in  std_logic;
        flush           : in  std_logic;
        pi_in           : in  std_logic_vector(OP1_WIDTH);
        b_in            : in  std_logic_vector(OP2_WIDTH);
        lzc_out         : out std_logic_vector(OP2_LOG_WIDTH);
        alpha_out       : out std_logic_vector(OP1_WIDTH)
    );
end forward_init;

architecture forward_init_arch of forward_init is
signal s_mul : std_logic_vector(MUL_WIDTH);
signal s_reset : std_logic;

component mul is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        enable  : in  std_logic;
        op1     : in  std_logic_vector(OP1_WIDTH);
        op2     : in  std_logic_vector(OP2_WIDTH);
        mul     : out std_logic_vector(MUL_WIDTH)
    );
end component;

component lzc_op2 is
    port(
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        load     : in  std_logic;
        load_out : in  std_logic;
        data_in  : in  std_logic_vector(OP2_WIDTH);
        data_out : out std_logic_vector(OP2_LOG_WIDTH)
    );
end component;

begin
    s_reset <= reset_n and not(flush);

    mul_u: mul port map (
        clk     => clk,
        reset_n => s_reset,
        enable  => enable,
        op1     => PI_in,
        op2     => B_in,
        mul     => s_mul
    );

    lzc: lzc_op2 port map (
        clk      => clk,
        reset_n  => reset_n,
        load     => store_scale_new,
        load_out => store_scale_ok,
        data_in  => s_mul(MUL_LZC_WIDTH),
        data_out => lzc_out
    );

    alpha_out <= s_mul(MUL_MOST_WIDTH);

end forward_init_arch;
