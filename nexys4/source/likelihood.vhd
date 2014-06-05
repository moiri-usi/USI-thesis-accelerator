library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.param_pkg.all;

entity likelihood is
    port (
        clk             : in  std_logic;
        reset_n         : in  std_logic;
        enable          : in  std_logic;
        flush           : in  std_logic;
        alpha_in        : in  ARRAY_OP1(N_RANGE);
        load_alpha_in   : in  std_logic;
        shift_alpha_in  : in  std_logic;
        Ps              : out std_logic_vector(OP1_WIDTH)
    );
end likelihood;

architecture likelihood_arch of likelihood is
signal s_mux    : ARRAY_OP1(N_RANGE);
signal s_reg_in : ARRAY_OP1(N_RANGE);
signal s_reset  : std_logic;

component acc_s is
    port (
        clk     : in  std_logic;
        reset_n : in  std_logic;
        enable  : in  std_logic;
        alpha   : in  std_logic_vector(OP1_WIDTH);
        Ps      : out std_logic_vector(OP1_WIDTH)
    );
end component;

component mux_2_op1 is
    port(
        sel       : in  std_logic;
        data_in_1 : in  std_logic_vector(OP1_WIDTH);
        data_in_2 : in  std_logic_vector(OP1_WIDTH);
        data_out  : out std_logic_vector(OP1_WIDTH)
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

    acc: acc_s port map (
        clk     => clk,
        reset_n => s_reset,
        enable  => enable,
        alpha   => s_reg_in(N_CNT-1),
        Ps      => Ps
    );

    shift_reg: for i in N_RANGE generate
        if0: if i = 0 generate
            mux0: mux_2_op1 port map (
                sel       => load_alpha_in,
                data_in_1 => s_reg_in(N_CNT-1),
                data_in_2 => alpha_in(i),
                data_out  => s_mux(i)
            );
        end generate if0;
        ifi: if i > 0 generate
            muxi: mux_2_op1 port map (
                sel       => load_alpha_in,
                data_in_1 => s_reg_in(i-1),
                data_in_2 => alpha_in(i),
                data_out  => s_mux(i)
            );
        end generate ifi;
        regi: reg_op1 port map(
            clk      => clk,
            reset_n  => reset_n,
            load     => shift_alpha_in,
            data_in  => s_mux(i),
            data_out => s_reg_in(i)
        );
    end generate shift_reg;

end likelihood_arch;
