library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity forward_init_s is
    port (
        clk             : in  std_logic;
        reset_n         : in  std_logic;
        flush           : in  std_logic;
        PI_in           : in  std_logic_vector (OP1_WIDTH);
        B_in            : in  std_logic_vector (OP2_WIDTH);
        shift_alpha_out : in  std_logic;
        load_mul        : in  std_logic;
        alpha_out       : out ARRAY_OP1(N_RANGE)
    );
end forward_init_s;

architecture forward_init_arch of forward_init_s is
signal s_reg_out : ARRAY_OP1(0 to N_CNT);
signal s_mul : std_logic_vector(MUL_WIDTH);
signal s_reset : std_logic;

component mul_s is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        load    : in  std_logic;
        op1     : in  std_logic_vector(OP1_WIDTH);
        op2     : in  std_logic_vector(OP2_WIDTH);
        mul     : out std_logic_vector(MUL_WIDTH)
    );
end component;

component reg_op1 is
    port ( 
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        load     : in  std_logic;
        data_in  : in  std_logic_vector(OP1_WIDTH);
        data_out : out std_logic_vector(OP1_WIDTH)
    );
end component;

begin
    s_reset <= reset_n and not(flush);

    mul: mul_s port map (
        clk     => clk,
        reset_n => s_reset,
        load    => load_mul,
        op1     => PI_in,
        op2     => B_in,
        mul     => s_mul
    );

    --s_mul(MUL_LEAST_WIDTH) <= (others => '0');
    s_reg_out(0) <= s_mul(MUL_MOST_WIDTH);

    shift_reg: for i in 1 to N_CNT generate
        regk: reg_op1 port map(
            clk      => clk,
            reset_n  => reset_n,
            load     => shift_alpha_out,
            data_in  => s_reg_out(i-1),
            data_out => s_reg_out(i)
        );
    end generate shift_reg;
    alpha_out <= s_reg_out(1 to N_CNT);

end forward_init_arch;
