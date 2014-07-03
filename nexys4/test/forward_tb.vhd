library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity forward_tb is
    port(
        clk          : in  std_logic;
        reset_n      : in  std_logic;
        --ps           : out std_logic_vector(OP1_WIDTH);
        seg_o        : out std_logic_vector(7 downto 0);
        an_o         : out std_logic_vector(7 downto 0);
        ps_scale     : out std_logic_vector(SCALE_WIDTH)
    );
end forward_tb;

architecture tb of forward_tb is
signal s_dispVal : std_logic_vector(63 downto 0);
signal s_ps_scale : std_logic_vector(SCALE_WIDTH);
signal s_ps : std_logic_vector(OP1_WIDTH);
signal reseti, clk_int : std_logic;
type ARRAY_VAL is array (natural range <>) of std_logic_vector(3 downto 0);
signal s_seg : ARRAY_VAL(0 to 7);
type ARRAY_SEG is array (natural range <>) of std_logic_vector(7 downto 0);
constant SEG_DEF : ARRAY_SEG(0 to 15) := (
    "11000000",
    "11111001",
    "10100100",
    "10110000",
    "10011001",
    "10010010",
    "10000010",
    "11111000",
    "10000000",
    "10010000",
    "10001000",
    "10000011",
    "11000110",
    "10100001",
    "10000110",
    "10001110"
);

component clk_100_85 is
    port(
       CLK_IN1       : in  std_logic;
       CLK_OUT1      : out std_logic
    );
end component;

component forward is
    port(
        clk          : in  std_logic;
        reset_n      : in  std_logic;
        b_in         : in  std_logic_vector(OP2_WIDTH);
        b_we         : in  std_logic;
        tp_in        : in  std_logic_vector(OP2_WIDTH);
        tp_we        : in  std_logic;
        pi_in        : in  std_logic_vector(OP1_WIDTH);
        pi_we        : in  std_logic;
        data_ready   : in  std_logic;
        ps_scale_out : out std_logic_vector(SCALE_WIDTH);
        ps_out       : out std_logic_vector(OP1_WIDTH)
    );
end component;

component sSegDisplay is
    port(
       ck       : in  std_logic;                     -- 100Mhz system clock
       number   : in  std_logic_vector(63 downto 0); -- eght digit hex data to be displayed, active-low
       seg      : out std_logic_vector(7 downto 0);  -- display cathodes
       an       : out std_logic_vector(7 downto 0)   -- display anodes, active-low
   );
end component;

begin
    ps_scale <= s_ps_scale;

    clk_u : clk_100_85 port map(
        CLK_IN1   => clk,
        CLK_OUT1  => clk_int
    );

    seq1: forward port map(
        clk          => clk_int,
        reset_n      => reset_n,
        b_in         => (others => '0'),
        b_we         => '0',
        tp_in        => (others => '0'),
        tp_we        => '0',
        pi_in        => (others => '0'),
        pi_we        => '0',
        data_ready   => '1',
        ps_scale_out => s_ps_scale,
        ps_out       => s_ps
    );

    s_seg(0) <= "0000";
    s_seg(1) <= "000" & s_ps(OP1_CNT-1);
    s_seg(2) <= s_ps(OP1_CNT-2 downto OP1_CNT-5);
    s_seg(3) <= s_ps(OP1_CNT-6 downto OP1_CNT-9);
    s_seg(4) <= s_ps(OP1_CNT-10 downto OP1_CNT-13);
    s_seg(5) <= s_ps(OP1_CNT-14 downto OP1_CNT-17);
    s_seg(6) <= s_ps(OP1_CNT-18 downto OP1_CNT-21);
    s_seg(7) <= s_ps(OP1_CNT-22 downto OP1_CNT-25);

    s_dispVal <= SEG_DEF(to_integer(unsigned(s_seg(0))))
        & SEG_DEF(to_integer(unsigned(s_seg(1))))
        & SEG_DEF(to_integer(unsigned(s_seg(2))))
        & SEG_DEF(to_integer(unsigned(s_seg(3))))
        & SEG_DEF(to_integer(unsigned(s_seg(4))))
        & SEG_DEF(to_integer(unsigned(s_seg(5))))
        & SEG_DEF(to_integer(unsigned(s_seg(6))))
        & SEG_DEF(to_integer(unsigned(s_seg(7))));

    Disp: sSegDisplay port map(
        ck       => clk_int,
        number   => s_dispVal, -- 64-bit
        seg      => seg_o,
        an       => an_o
    );

end tb;
