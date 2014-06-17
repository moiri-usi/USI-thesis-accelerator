library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.param_pkg.all;

entity forward_step_L is
    port ( 
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        b_in     : in  std_logic_vector(OP2_WIDTH);
        tp_in    : in  std_logic_vector(OP2_WIDTH);
        tp_idx   : in  std_logic_vector(N_LOG_RANGE);
        pi_in    : in  std_logic_vector(OP1_WIDTH);
        b_idx    : in  std_logic_vector(M_LOG_RANGE);
        ps       : out std_logic_vector(OP1_WIDTH)
    );
end forward_L;

architecture forward_arch of forward_L is

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

component fifo_N_op2 is
    port(
           clk   : in  std_logic;
           rst   : in  std_logic;
           wr_en : in  std_logic;
           rd_en : in  std_logic;
           din   : in  std_logic_vector(OP2_WIDTH);
           dout  : out std_logic_vector(OP2_WIDTH);
           full  : out std_logic;
           empty : out std_logic
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

component mux_2_op2 is
    port(
        sel       : in  std_logic;
        data_in_1 : in  std_logic_vector(OP2_WIDTH);
        data_in_2 : in  std_logic_vector(OP2_WIDTH);
        data_out  : out std_logic_vector(OP2_WIDTH)
    );
end component;

component macc_p is
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        enable    : in  std_logic;
        op1_in    : in  std_logic_vector (OP1_WIDTH);
        op2_in    : in  std_logic_vector (OP2_WIDTH);
        macc_out  : out std_logic_vector (MACC_WIDTH)
    );
end component;

component mul_p is
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        enable    : in  std_logic;
        op1_in    : in  std_logic_vector (OP1_WIDTH);
        op2_in    : in  std_logic_vector (OP2_WIDTH);
        mul_out   : out std_logic_vector (MUL_WIDTH)
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
    s_reset <= not(reset_n);

    fifo_pi: fifo_N_op1 port map (
        clk   => clk,
        rst   => s_reset,
        wr_en => ,
        rd_en => ,
        din   => pi_in,
        dout  => s_pi_out,
        full  => open,
        empty => open
    );

    b: for m in M_RANGE generate
        fifo_tpi: fifo_N_op2 port map (
            clk      => clk,
            rst      => s_reset,
            wr_en    => ,
            rd_en    => ,
            din      => b_in,
            dout     => s_b_out(i),
            full     => open,
            empty    => open
        );
    end generate b;

    mul: mul_p port map (
        clk       => clk,
        reset_n   => reset_n,
        enable    => ,
        op1_in    => s_pi_out,
        op2_in    => s_b_out(to_integer( unsigned(b_idx) )),
        mul_out   => s_alpha_init
    );

    mux_op1: mux_2_op1 port map (
        sel       => s_init,
        data_in_1 => s_alpha,
        data_in_2 => s_alpha_init,
        data_out  => s_op1
    );

    step: for i in N_RANGE generate
        fifo_tpi: fifo_N_op2 port map (
            clk      => clk,
            rst      => s_reset,
            wr_en    => ,
            rd_en    => ,
            din      => tp_in,
            dout     => s_tp_out(i),
            full     => open,
            empty    => open
        );
        macci: macc_p port map (
            clk      => clk,
            reset_n  => reset_n,
            enable   => ,
            op1_in   => s_op1,
            op2_in   => s_tp_out(i),
            macc_out => s_macc(i)
        );
        if0: if i = 0 generate
            reg0: reg_op1 port map (
                clk       => clk,
                reset_n   => reset_n,
                load      => ,
                data_in   => s_macc(i),
                data_out  => s_macc_reg(i)
            );
        end generate if0;
        ifi: if i > 0 generate
            mux_macci: mux_2_op1 port map (
                sel       => ,
                data_in_1 => s_macc(i),
                data_in_2 => s_macc_reg(i-1),
                data_out  => s_macc_mux(i)
            );
            regi: reg_op1 port map (
                clk       => clk,
                reset_n   => reset_n,
                load      => ,
                data_in   => s_macc_mux(i),
                data_out  => s_macc_reg(i)
            );
        end generate ifi;
    end generate step;

    macc_b: macc_p port map (
        clk        => clk,
        reset_n    => reset_n,
        enable     => ,
        enable_acc => ,
        op1_in     => s_macc_reg(N_CNT-1),
        op2_in     => s_b_out(to_integer( unsigned(b_idx) )),
        macc_out   => s_alpha
    );

end forward_arch;
