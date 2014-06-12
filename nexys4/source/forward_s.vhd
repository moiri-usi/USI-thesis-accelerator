library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity forward_s is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        b_in       : in  std_logic_vector(OP2_WIDTH);
        b_we       : in  std_logic;
        tp_in      : in  std_logic_vector(OP2_WIDTH);
        tp_we      : in  std_logic;
        pi_in      : in  std_logic_vector(OP1_WIDTH);
        pi_we      : in  std_logic;
        data_ready : in  std_logic;
        ps_out     : out std_logic_vector(OP1_WIDTH)
    );
end forward_s;

architecture forward_arch of forward_s is
signal s_b, s_tp, s_op2, s_op2_reg : std_logic_vector(OP2_WIDTH);
signal s_pi : std_logic_vector(OP1_WIDTH);
signal s_pi_addr : std_logic_vector(N_LOG_RANGE);
signal s_alpha : ARRAY_OP1(L_RANGE);
signal s_pi_we : std_logic_vector(0 downto 0);
signal s_conciliate, s_shift_alpha_in, s_shift_alpha_out, s_sel_read_fifo,
    s_enable_step, s_enable_step_c, s_enable_init, s_enable_init_c,
    s_enable_final, s_enable_final_c, s_flush, s_reset,
    s_read_op, s_read_tp, s_enable_cnt : std_logic;

component ram_N_op1 is
    port(
        wea   : in  std_logic_vector(0 downto 0);
        addra : in  std_logic_vector(N_LOG_RANGE);
        dina  : in  std_logic_vector(OP1_WIDTH);
        douta : out std_logic_vector(OP1_WIDTH);
        clka  : in  std_logic
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

component fifo_NN_op2 is
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

component counter_N is
    port ( 
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        enable   : in  std_logic;
        count    : out std_logic_vector(N_LOG_RANGE)
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

component reg_op2 is
    port ( 
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        load     : in  std_logic;
        data_in  : in  std_logic_vector(OP2_WIDTH);
        data_out : out std_logic_vector(OP2_WIDTH)
    );
end component;

component forward_ctrl is
    port(
        clk             : in  std_logic;
        reset_n         : in  std_logic;
        enable          : in  std_logic;
        flush           : out std_logic;
        sel_read_fifo   : out std_logic;
        conciliate      : out std_logic;
        shift_alpha_in  : out std_logic;
        shift_alpha_out : out std_logic;
        read_op         : out std_logic;
        read_tp         : out std_logic;
        enable_step     : out std_logic;
        enable_init     : out std_logic;
        enable_final    : out std_logic
    );
end component;

component forward_init_s is
    port (
        clk             : in  std_logic;
        reset_n         : in  std_logic;
        enable          : in  std_logic;
        flush           : in  std_logic;
        pi_in           : in  std_logic_vector(OP1_WIDTH);
        b_in            : in  std_logic_vector(OP2_WIDTH);
        alpha_out       : out std_logic_vector(OP1_WIDTH)
    );
end component;

component forward_step_s is
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
end component;

component likelihood is
    port (
        clk            : in  std_logic;
        reset_n        : in  std_logic;
        load           : in  std_logic;
        enable         : in  std_logic;
        alpha_in       : in  std_logic_vector(OP1_WIDTH);
        ps             : out std_logic_vector(OP1_WIDTH)
    );
end component;

begin 
    s_reset <= not(reset_n);
    s_pi_we(0) <= pi_we;

    ram_pi: ram_N_op1 port map (
        clka  => clk,
        wea   => s_pi_we,
        addra => s_pi_addr,
        dina  => pi_in,
        douta => s_pi
    );

    fifo_b: fifo_N_op2 port map (
        clk   => clk,
        rst   => s_reset,
        wr_en => b_we,
        rd_en => s_read_op,
        din   => b_in,
        dout  => s_b,
        full  => open,
        empty => open
    );

    fifo_tp: fifo_NN_op2 port map (
        clk   => clk,
        rst   => s_reset,
        wr_en => tp_we,
        rd_en => s_read_tp,
        din   => tp_in,
        dout  => s_tp,
        full  => open,
        empty => open
    );

    s_enable_cnt <= s_read_op or pi_we;

    cnt: counter_N port map (
        clk      => clk,
        reset_n  => reset_n,
        enable   => s_enable_cnt,
        count    => s_pi_addr
    );

    mux_op2: mux_2_op2 port map (
        sel             => s_enable_init,
        data_in_1       => s_tp,
        data_in_2       => s_b,
        data_out        => s_op2
    );

    reg: reg_op2 port map (
        clk             => clk,
        reset_n         => reset_n,
        load            => s_enable_step,
        data_in         => s_op2,
        data_out        => s_op2_reg
    );

    ctrl: forward_ctrl port map (
        clk             => clk,
        reset_n         => reset_n,
        enable          => data_ready,
        flush           => s_flush,
        sel_read_fifo   => s_sel_read_fifo,
        conciliate      => s_conciliate,
        shift_alpha_in  => s_shift_alpha_in,
        shift_alpha_out => s_shift_alpha_out,
        read_op         => s_read_op,
        read_tp         => s_read_tp,
        enable_step     => s_enable_step,
        enable_init     => s_enable_init,
        enable_final    => s_enable_final
    );

    s_enable_init_c <= data_ready and s_enable_init;
    s_enable_step_c <= data_ready and s_enable_step;
    s_enable_final_c <= data_ready and s_enable_final;

    u1: for k in L_RANGE generate
        if0: if k = 0 generate
            init: forward_init_s port map (
                clk             => clk,
                reset_n         => reset_n,
                flush           => s_flush,
                pi_in           => s_pi,
                b_in            => s_b,
                enable          => s_enable_init_c,
                alpha_out       => s_alpha(k)
            );
        end generate if0;
        ifk: if k > 0 generate
            stepk: forward_step_s port map (
                clk             => clk,
                reset_n         => reset_n,
                sel_read_fifo   => s_sel_read_fifo,
                sel_op1         => s_enable_init_c,
                conciliate      => s_conciliate,
                shift_alpha_in  => s_shift_alpha_in,
                shift_alpha_out => s_shift_alpha_out,
                enable          => s_enable_step_c,
                flush_macc      => s_flush,
                flush_fifo      => s_enable_final_c,
                op2_in          => s_op2_reg,
                alpha_in        => s_alpha(k-1),
                alpha_out       => s_alpha(k)
            );
        end generate ifk;
    end generate u1;

    u2: likelihood port map (
        clk             => clk,
        reset_n         => reset_n,
        load            => s_shift_alpha_out,
        enable          => s_enable_final_c,
        alpha_in        => s_alpha(L_CNT-1),
        ps              => ps_out
    );

end forward_arch;
