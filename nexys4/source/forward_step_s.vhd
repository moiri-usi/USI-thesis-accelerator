library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity forward_step_s is
    port ( 
        clk             : in  std_logic;
        reset_n         : in  std_logic;
        sel_read_fifo   : in  std_logic;
        sel_op1         : in  std_logic;
        conciliate      : in  std_logic;
        shift_alpha_in  : in  std_logic;
        shift_alpha_out : in  std_logic;
        enable          : in  std_logic;
        flush_macc      : in  std_logic;
        flush_fifo      : in  std_logic;
        op2_in          : in  std_logic_vector(OP2_WIDTH);
        alpha_in        : in  std_logic_vector(OP1_WIDTH);
        alpha_out       : out std_logic_vector(OP1_WIDTH)
    );
end forward_step_s;

Architecture forward_step_arch of forward_step_s is
signal s_feed_back : std_logic_vector(MACC_WIDTH);
signal s_mul : std_logic_vector(MUL_WIDTH);
signal s_fifo_out, s_fifo0_out, s_fifo1_out, s_fifo0_in, s_fifo1_in, s_op1,
    s_op1z : std_logic_vector(OP1_WIDTH);
signal sel_read_fifo_n, s_fifo0_we, s_fifo1_we, s_fifo0_re, s_fifo1_re,
    s_reset_macc, s_fifo0_rst, s_fifo1_rst : std_logic;

component macc_s is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        enable  : in  std_logic;
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

component fifo_N_op1 is
    port(
           clk   : in  std_logic;
           rst   : in  std_logic;
           wr_en : in  std_logic;
           rd_en : in  std_logic;
           din   : in  std_logic_vector(OP1_WIDTH);
           dout  : out std_logic_vector(OP1_WIDTH);
           full  : out std_logic;
           empty : out std_logic
    );
end component;

begin
    sel_read_fifo_n <= not(sel_read_fifo);

    mux_fb: mux_2_op1 port map (
        sel       => sel_op1,
        data_in_1 => s_fifo_out,
        data_in_2 => s_feed_back(MACC_MOST_WIDTH),
        data_out  => s_op1
    );

    mux_fifo0_in: mux_2_op1 port map (
        sel       => sel_read_fifo,
        data_in_1 => s_fifo0_out,
        data_in_2 => alpha_in,
        data_out  => s_fifo0_in
    );

    mux_fifo1_in: mux_2_op1 port map (
        sel       => sel_read_fifo_n,
        data_in_1 => s_fifo1_out,
        data_in_2 => alpha_in,
        data_out  => s_fifo1_in
    );

    mux_fifo_out: mux_2_op1 port map (
        sel       => sel_read_fifo,
        data_in_1 => s_fifo0_out,
        data_in_2 => s_fifo1_out,
        data_out  => s_fifo_out
    );

    mux_op1z: mux_2_op1 port map (
        sel       => conciliate,
        data_in_1 => s_op1,
        data_in_2 => (others => '0'),
        data_out  => s_op1z
    );

    s_reset_macc <= reset_n and not(flush_macc);

    macc: macc_s port map (
        clk     => clk,
        reset_n => s_reset_macc,
        enable  => enable,
        op1     => s_op1z,
        op2     => op2_in,
        mul     => s_mul,
        macc    => s_feed_back
    );

    s_fifo0_we <= (shift_alpha_in and sel_read_fifo_n)
                  or (shift_alpha_out and sel_read_fifo);
    s_fifo0_re <= shift_alpha_in and sel_read_fifo_n;
    s_fifo0_rst <= not(reset_n) or (not(sel_read_fifo) and flush_fifo);

    fifo0: fifo_N_op1 port map (
        clk   => clk,
        rst   => s_fifo0_rst,
        wr_en => s_fifo0_we,
        rd_en => s_fifo0_re,
        din   => s_fifo0_in,
        dout  => s_fifo0_out,
        full  => open,
        empty => open
    );

    s_fifo1_we <= (shift_alpha_in and sel_read_fifo)
                  or (shift_alpha_out and sel_read_fifo_n);
    s_fifo1_re <= shift_alpha_in and sel_read_fifo;
    s_fifo1_rst <= not(reset_n) or (sel_read_fifo and flush_fifo);

    fifo1: fifo_N_op1 port map (
        clk   => clk,
        rst   => s_fifo1_rst,
        wr_en => s_fifo1_we,
        rd_en => s_fifo1_re,
        din   => s_fifo1_in,
        dout  => s_fifo1_out,
        full  => open,
        empty => open
    );

    alpha_out <= s_mul(MUL_MOST_WIDTH);

end forward_step_arch;
