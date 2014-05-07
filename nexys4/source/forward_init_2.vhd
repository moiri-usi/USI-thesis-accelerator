library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all

entity forward_init_2 is
    port ( 
        clk     : in std_logic;
        reset_n : in std_logic;
        PI1     : in std_logic_vector (PI_WIDTH);
        PI2     : in std_logic_vector (PI_WIDTH);
        B1      : in std_logic_vector (PI_WIDTH);
        B2      : in std_logic_vector (PI_WIDTH);
        coeff   : out std_logic_vector (COEFF_WIDTH);
        alpha1  : out std_logic_vector (ALPHA_WIDTH);
        alpha2  : out std_logic_vector (ALPHA_WIDTH)
    );
end forward_init_2;

architecture forward_init_2_arch of forward_init_2 is
signal s_alpha1, s_alpha2 : std_logic_vector (7 downto 0);
signal s_coeff : std_logic_vector (7 downto 0);

component acc_2 is
port (
    in11 : in std_logic_vector(MUL_OP1_WIDTH);
    in12 : in std_logic_vector(MUL_OP2_WIDTH);
    in21 : in std_logic_vector(MUL_OP1_WIDTH);
    in22 : in std_logic_vector(MUL_OP2_WIDTH);
    acc1 : out std_logic_vector(MUL_RES_WIDTH);
    acc2 : out std_logic_vector(MUL_RES_WIDTH);
    res  : out std_logic_vector(ACC_RES_WIDTH)
);
end component;

component scale_2 is
port (
    clk        : in std_logic;
    reset_n    : in std_logic;
    coeff_in   : in std_logic_vector (COEFF_WIDTH);
    alpha_in1  : in std_logic_vector (ALPHA_WIDTH);
    alpha_in2  : in std_logic_vector (ALPHA_WIDTH);
    coeff_out  : out std_logic_vector (COEFF_WIDTH);
    alpha_out1 : out std_logic_vector (ALPHA_WIDTH);
    alpha_out2 : out std_logic_vector (ALPHA_WIDTH)
);
end component;

begin 
    acc: acc_2 port map (
        in11 => B1,
        in12 => PI1,
        in21 => B2,
        in22 => PI2,
        acc1 => s_alpha1,
        acc2 => s_alpha2,
        res  => s_coeff
    );

    scale: scale_2 port map (
        clk        => clk,
        reset_n    => reset_n,
        coeff_in   => s_coeff,
        alpha_in1  => s_alpha1,
        alpha_in2  => s_alpha2,
        coeff_out  => coeff,
        alpha_out1 => alpha1,
        alpha_out2 => alpha2
    );

end forward_init_2_arch;
