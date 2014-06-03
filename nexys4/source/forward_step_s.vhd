library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity forward_step_s is
    port ( 
        clk             : in  std_logic;
        reset_n         : in  std_logic;
        sel_op1         : in  std_logic;
        load_alpha_in   : in  std_logic;
        shift_alpha_in  : in  std_logic;
        shift_alpha_out : in  std_logic;
        load_macc       : in  std_logic;
        op2_in          : in  std_logic_vector(OP2_WIDTH);
        alpha_in        : in  ARRAY_OP1(N_RANGE);
        alpha_out       : out ARRAY_OP1(N_RANGE)
    );
end forward_step_s;

Architecture forward_step_arch of forward_step_s is
signal s_feed_back : std_logic_vector(MACC_WIDTH);
signal s_mux : ARRAY_OP1(N_RANGE);
signal s_reg_in : ARRAY_OP1(N_RANGE);
signal s_reg_out : ARRAY_OP1(N_RANGE);
signal s_op1 : std_logic_vector(OP1_WIDTH);
signal s_op2 : std_logic_vector(OP2_WIDTH);
signal s_mul : std_logic_vector(MUL_WIDTH);

component macc_s is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        load    : in  std_logic;
        op1     : in  std_logic_vector(OP1_WIDTH);
        op2     : in  std_logic_vector(OP2_WIDTH);
        mul     : out std_logic_vector(MUL_WIDTH);
        macc    : out std_logic_vector(MACC_WIDTH)
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
    mux_op1: mux_2_op1 port map (
        sel       => sel_op1,
        data_in_1 => s_feed_back(MACC_MOST_WIDTH),
        data_in_2 => s_reg_in(N_CNT-1),
        data_out  => s_op1
    );

    macc: macc_s port map (
        clk     => clk,
        reset_n => reset_n,
        load    => load_macc,
        op1     => s_op1,
        op2     => op2_in,
        mul     => s_mul,
        macc    => s_feed_back
    );

    --s_feed_back(MACC_LEAST_WIDTH) <= (others => '0');

    shift_reg1: for i in N_RANGE generate
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
    end generate shift_reg1;

    --s_mul(MUL_LEAST_WIDTH) <= (others => '0');

    shift_reg2: for i in N_RANGE generate
        if0_out: if i = 0 generate
            regk: reg_op1 port map(
                clk      => clk,
                reset_n  => reset_n,
                load     => shift_alpha_out,
                data_in  => s_mul(MUL_MOST_WIDTH),
                data_out => s_reg_out(i)
            );
        end generate if0_out;
        ifi_out: if i > 0 generate
            regk: reg_op1 port map(
                clk      => clk,
                reset_n  => reset_n,
                load     => shift_alpha_out,
                data_in  => s_reg_out(i-1),
                data_out => s_reg_out(i)
            );
        end generate ifi_out;
    end generate shift_reg2;
    alpha_out <= s_reg_out;

end forward_step_arch;
