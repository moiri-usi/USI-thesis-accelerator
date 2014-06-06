library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.param_pkg.all;

entity likelihood is
    port (
        clk             : in  std_logic;
        reset_n         : in  std_logic;
        load            : in  std_logic;
        enable          : in  std_logic;
        alpha_in        : in  std_logic_vector(OP1_WIDTH);
        Ps              : out std_logic_vector(OP1_WIDTH)
    );
end likelihood;

architecture likelihood_arch of likelihood is
signal s_Ps : std_logic_vector(OP1_WIDTH);
signal s_reset, s_reset_delay : std_logic;

component acc_s is
    port (
        clk     : in  std_logic;
        reset_n : in  std_logic;
        enable  : in  std_logic;
        alpha   : in  std_logic_vector(OP1_WIDTH);
        Ps      : out std_logic_vector(OP1_WIDTH)
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
    s_reset <= reset_n and s_reset_delay;

    acc: acc_s port map (
        clk     => clk,
        reset_n => s_reset,
        enable  => load,
        alpha   => alpha_in,
        Ps      => s_Ps
    );

    reg2: reg_op1 port map (
        clk      => clk,
        reset_n  => reset_n,
        load     => enable,
        data_in  => s_Ps,
        data_out => Ps
    );

    process(clk)
    begin
        if rising_edge(clk) then
            s_reset_delay <= not(enable);
        end if;
    end process;

end likelihood_arch;
