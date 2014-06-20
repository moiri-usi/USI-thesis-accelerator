library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity likelihood is
    port (
        clk             : in  std_logic;
        reset_n         : in  std_logic;
        load            : in  std_logic;
        enable          : in  std_logic;
        ps_scale_in     : in  std_logic_vector(SCALE_WIDTH);
        alpha_in        : in  std_logic_vector(OP1_WIDTH);
        ps_scale_out    : out std_logic_vector(SCALE_WIDTH);
        ps_out          : out std_logic_vector(OP1_WIDTH)
    );
end likelihood;

architecture likelihood_arch of likelihood is
signal s_ps1, s_ps2 : std_logic_vector(OP1_WIDTH);
signal s_reset, s_reset_delay, s_enable_delay : std_logic;
signal s_ps_scale : std_logic_vector(SCALE_WIDTH);

component acc_s is
    port (
        clk     : in  std_logic;
        reset_n : in  std_logic;
        enable  : in  std_logic;
        alpha   : in  std_logic_vector(OP1_WIDTH);
        ps      : out std_logic_vector(OP1_WIDTH)
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

component reg_scale is
    port ( 
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        load     : in  std_logic;
        data_in  : in  std_logic_vector(SCALE_WIDTH);
        data_out : out std_logic_vector(SCALE_WIDTH)
    );
end component;

begin
    s_reset <= reset_n and s_reset_delay;

    acc: acc_s port map (
        clk     => clk,
        reset_n => s_reset,
        enable  => load,
        alpha   => alpha_in,
        ps      => s_ps1
    );

    reg00: reg_op1 port map (
        clk      => clk,
        reset_n  => reset_n,
        load     => enable,
        data_in  => s_ps1,
        data_out => s_ps2
    );

    reg01: reg_op1 port map (
        clk      => clk,
        reset_n  => reset_n,
        load     => s_enable_delay,
        data_in  => s_ps2,
        data_out => ps_out
    );

    s_ps_scale <= ps_scale_in
        - std_logic_vector(to_unsigned(OP2_CNT, SCALE_CNT));
    reg1: reg_scale port map (
        clk      => clk,
        reset_n  => reset_n,
        load     => s_enable_delay,
        data_in  => s_ps_scale,
        data_out => ps_scale_out
    );

    process(clk)
    begin
        if rising_edge(clk) then
            s_reset_delay <= not(enable);
            s_enable_delay <= enable;
        end if;
    end process;

end likelihood_arch;
