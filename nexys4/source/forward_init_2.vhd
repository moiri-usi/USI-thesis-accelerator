library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity forward_init_2 is
    port ( 
        clk     : in std_logic;
        reset_n : in std_logic;
        PI1     : in std_logic_vector (7 downto 0);
        PI2     : in std_logic_vector (7 downto 0);
        B1      : in std_logic_vector (7 downto 0);
        B2      : in std_logic_vector (7 downto 0);
        coeff   : out std_logic_vector (7 downto 0);
        alpha1  : out std_logic_vector (7 downto 0);
        alpha2  : out std_logic_vector (7 downto 0);
    );
end forward_init_2;

architecture forward_init_2_arch of forward_init_2 is
signal s_alpha1, s_alpha2 : std_logic_vector (7 downto 0);
signal s_coeff : std_logic_vector (7 downto 0);

component acc_2 is
port (
    in11 : in std_logic_vector(3 downto 0);
    in12 : in std_logic_vector(3 downto 0);
    in21 : in std_logic_vector(3 downto 0);
    in22 : in std_logic_vector(3 downto 0);
    acc1 : out std_logic_vector(7 downto 0)
    acc2 : out std_logic_vector(7 downto 0)
    res  : out std_logic_vector(7 downto 0)
);
end component;

component scale_2 is
port (
    clk        : in std_logic;
    reset_n    : in std_logic;
    coeff_in   : in std_logic_vector (7 downto 0);
    alpha_in1  : in std_logic_vector (7 downto 0);
    alpha_in2  : in std_logic_vector (7 downto 0);
    coeff_out  : out std_logic_vector (7 downto 0);
    alpha_out1 : out std_logic_vector (7 downto 0);
    alpha_out2 : out std_logic_vector (7 downto 0);
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
