library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity forward_step is
    port ( 
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        load      : in  std_logic;
        B_in      : in  std_logic_vector(OP2_WIDTH);
        TP_in     : in  ARRAY_TP(N_RANGE);
        alpha_in  : in  std_logic_vector(OP1_WIDTH);
        alpha_out : out std_logic_vector(OP1_WIDTH)
    );
end forward_step;

Architecture forward_step_arch of forward_step is
signal s_alpha_out : ARRAY_A(N_RANGE);
signal s_reg_out   : ARRAY_A(N_CONST+1 downto 0);

component macc_p is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        load    : in  std_logic;
        op1     : in  std_logic_vector (OP1_WIDTH);
        op2     : in  std_logic_vector (OP2_WIDTH);
        res     : out std_logic_vector (OP2_WIDTH)
    );
end component;

component reg_macc_p is
    port ( 
        clk     : in  std_logic;
        reset_n : in  std_logic;
        load    : in  std_logic;
        shift   : in  std_logic;
        in_a    : in  std_logic_vector (OP1_WIDTH);
        in_s    : in  std_logic_vector (OP1_WIDTH);
        out_a   : out std_logic_vector (OP1_WIDTH)
    );
end component;

begin 
    s_reg_out(0) <= (others => '0');

    g1: for i in 0 to N_CONST generate
        maccx: macc_p port map (
            clk     => clk,
            reset_n => reset_n,
            load    => load,
            op1     => alpha_in,
            op2     => TP_in(i),
            res     => s_alpha_out(i)
        );
    end generate g1;

    g2: for i in 0 to N_CONST generate
        shift_reg: reg_macc_p port map (
            clk     => clk,
            reset_n => reset_n,
            load    => load,
            shift   => not(load),
            in_a    => s_alpha_out(i),
            in_s    => s_reg_out(i),
            out_a   => s_reg_out(i+1)
        );
    end generate g2;

    maccB: macc_p port map (
        clk     => clk,
        reset_n => reset_n,
        load    => not(load),
        op1     => s_reg_out(N_CONST+1),
        op2     => B_in,
        res     => alpha_out
    );
end forward_step_arch;
