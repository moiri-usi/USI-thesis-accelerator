library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

constant LEN_B : integer := 7;

entity forward_2x2 is
    port ( 
        clk     : in std_logic;
        reset_n : in std_logic;
        idx_os  : in std_logic_vector (1 downto 0);
        load    : in std_logic;
        lPs     : out std_logic_vector (7 downto 0);
    );
end forward_2x2;

architecture forward_2x2_arch of forward_2x2 is
signal s_B1_rom, s_B2_rom, s_B1_reg, s_B2_reg : std_logic_vector (LEN_B downto 0);
signal s_PI1, s_PI2 : std_logic_vector (7 downto 0);
signal s_TP11, s_TP12, s_TP21, s_TP22 : std_logic_vector (7 downto 0);
signal s_alpha1, s_alpha2 : std_logic_vector (7 downto 0);
signal s_coeff1, s_coeff2 : std_logic_vector (7 downto 0);
signal s_clk, s_reset_n, s_load : std_logic;

component rom_2_sel is
port (
    idx  : in std_logic_vector (1 downto 0);
    out1 : out std_logic_vector (7 downto 0);
    out2 : out std_logic_vector (7 downto 0);
);
end component;

component rom_2 is
port (
    out1 : out std_logic_vector (7 downto 0);
    out2 : out std_logic_vector (7 downto 0);
);
end component;

component rom_22 is
port (
    out11 : out std_logic_vector (7 downto 0);
    out12 : out std_logic_vector (7 downto 0);
    out21 : out std_logic_vector (7 downto 0);
    out22 : out std_logic_vector (7 downto 0);
);
end component;

component shift_reg_B_2 is
port (
    clk   : in std_logic;
    reset : in std_logic;
    load  : in std_logic;
    B_in  : in std_logic_vector (7 downto 0);
    B_out : out std_logic_vector (7 downto 0);
);
end component;

component forward_init_2 is
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
end component;

component forward_step_2 is
port (
    clk        : in std_logic;
    reset_n    : in std_logic;
    alpha_in1  : in std_logic_vector (7 downto 0);
    alpha_in2  : in std_logic_vector (7 downto 0);
    TP11       : in std_logic_vector (7 downto 0);
    TP12       : in std_logic_vector (7 downto 0);
    TP21       : in std_logic_vector (7 downto 0);
    TP22       : in std_logic_vector (7 downto 0);
    B1         : in std_logic_vector (7 downto 0);
    B2         : in std_logic_vector (7 downto 0);
    alpha_out1 : out std_logic_vector (7 downto 0);
    alpha_out2 : out std_logic_vector (7 downto 0);
    coeff      : out std_logic_vector (7 downto 0);
);
end component;

component likelihood_2 is
port (
    clk   : in std_logic;
    reset : in std_logic;
    in1   : in std_logic_vector (7 downto 0);
    in2   : in std_logic_vector (7 downto 0);
    lPs   : out std_logic_vector (7 downto 0);
);
end component;

begin 
    romB: rom_2_sel port map (
        idx  => idx_os,
        out1 => s_B1_rom,
        out2 => s_B2_rom
    );

    romPI: rom_2 port map (
        out1 => s_PI1,
        out2 => s_PI2
    );

    romTP: rom_22 port map (
        out11 => s_TP11,
        out12 => s_TP12
        out21 => s_TP21,
        out22 => s_TP22
    );

    regB1: shift_reg_B_2 port map (
        clk     => s_clk,
        reset_n => s_reset_n,
        load    => s_load,
        B_in    => s_B1_rom,
        B_out   => s_B1_reg
    );

    regB2: shift_reg_B_2 port map (
        clk     => s_clk,
        reset_n => s_reset_n,
        load    => s_load,
        B_in    => s_B2_rom,
        B_out   => s_B2_reg
    );

    u1: forward_init_2 port map (
        clk     => s_clk,
        reset_n => s_reset_n,
        PI1     => s_PI1,
        PI2     => s_PI2,
        B1      => s_B1_reg,
        B2      => s_B2_reg,
        coeff   => s_coeff1,
        alpha1  => s_alpha1,
        alpha2  => s_alpha2
    );

    u2: forward_step_2 port map (
        clk        => s_clk,
        reset_n    => s_reset_n,
        alpha_in1  => s_alpha1,
        alpha_in2  => s_alpha2,
        TP11       => s_TP11,
        TP12       => s_TP12,
        TP21       => s_TP21,
        TP22       => s_TP22,
        B1         => s_B1_reg,
        B2         => s_B2_reg,
        alpha_out1 => open,
        alpha_out2 => open,
        coeff      => s_coeff2
    );

    u3: likelihood_2 port map (
        clk   => s_clk,
        reset => s_reset_n,
        in1   => s_coeff1,
        in2   => s_coeff2,
        lPs   => lPs
    );
    
end forward_2x2_arch;
