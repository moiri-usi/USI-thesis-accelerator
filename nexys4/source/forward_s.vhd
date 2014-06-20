library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity forward_s is
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
end forward_s;

architecture forward_arch of forward_s is
signal s_b, s_tp, s_op2, s_op2_reg : std_logic_vector(OP2_WIDTH);
signal s_pi : std_logic_vector(OP1_WIDTH);
signal s_pi_addr : std_logic_vector(N_LOG_RANGE);
signal s_alpha : ARRAY_OP1(L_RANGE);
signal s_lzc : ARRAY_OP2_LOG(L_RANGE);
signal s_reg_lzc : ARRAY_OP2_LOG(1 to L_CNT-1);
signal s_add_lzc : ARRAY_SCALE(L_RANGE);
signal s_reg_add_lzc : ARRAY_SCALE(1 to L_CNT-1);
signal s_pi_we : std_logic_vector(0 downto 0);
signal s_mux8_op1 : std_logic_vector(2 downto 0);
signal s_mux2_op2 : std_logic;
signal s_shift_alpha_in, s_shift_alpha_out, s_shift_acc, s_read_op, s_read_tp,
    s_enable_macc, s_enable_mul, s_enable_shift1, s_enable_shift2, s_enable_shift,
    s_enable_acc, s_enable_acc_d, s_enable_cnt, s_enable_init, s_enable_step, s_enable_final,
    s_conciliate, s_flush, s_flush_acc, s_reset,
    s_sel_read_fifo : std_logic;

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

component reg_op2 is
    port ( 
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        load     : in  std_logic;
        data_in  : in  std_logic_vector(OP2_WIDTH);
        data_out : out std_logic_vector(OP2_WIDTH)
    );
end component;

component reg_op2_log is
    port ( 
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        load     : in  std_logic;
        data_in  : in  std_logic_vector(OP2_LOG_WIDTH);
        data_out : out std_logic_vector(OP2_LOG_WIDTH)
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

component add_scale is
    port (
        scale_in  : in  std_logic_vector(SCALE_WIDTH);
        lzc_in    : in  std_logic_vector(OP2_LOG_WIDTH);
        scale_out : out std_logic_vector(SCALE_WIDTH)
    );
end component;

component forward_ctrl is
    port(
        clk             : in  std_logic;
        reset_n         : in  std_logic;
        enable          : in  std_logic;
        flush           : out std_logic;
        flush_acc       : out std_logic;
        sel_read_fifo   : out std_logic;
        conciliate      : out std_logic;
        shift_alpha_in  : out std_logic;
        shift_alpha_out : out std_logic;
        shift_acc       : out std_logic;
        read_op         : out std_logic;
        read_tp         : out std_logic;
        enable_macc     : out std_logic;
        enable_mul      : out std_logic;
        enable_shift1   : out std_logic;
        enable_shift2   : out std_logic;
        enable_acc      : out std_logic
    );
end component;

component forward_init_s is
    port (
        clk             : in  std_logic;
        reset_n         : in  std_logic;
        enable          : in  std_logic;
        store_scale_new : in  std_logic;
        store_scale_ok  : in  std_logic;
        flush           : in  std_logic;
        pi_in           : in  std_logic_vector(OP1_WIDTH);
        b_in            : in  std_logic_vector(OP2_WIDTH);
        lzc_out         : out std_logic_vector(OP2_LOG_WIDTH);
        alpha_out       : out std_logic_vector(OP1_WIDTH)
    );
end component;

component forward_step_s is
    port (
        clk             : in  std_logic;
        reset_n         : in  std_logic;
        sel_read_fifo   : in  std_logic;
        sel_op1         : in  std_logic_vector(2 downto 0);
        sel_op2         : in  std_logic;
        shift_alpha_in  : in  std_logic;
        shift_alpha_out : in  std_logic;
        enable          : in  std_logic;
        flush_macc      : in  std_logic;
        flush_acc       : in  std_logic;
        shift_acc       : in  std_logic;
        flush_fifo      : in  std_logic;
        op2_in          : in  std_logic_vector(OP2_WIDTH);
        alpha_in        : in  std_logic_vector(OP1_WIDTH);
        lzc_in          : in  std_logic_vector(OP2_LOG_WIDTH);
        lzc_out         : out std_logic_vector(OP2_LOG_WIDTH);
        alpha_out       : out std_logic_vector(OP1_WIDTH)
    );
end component;

component likelihood is
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
end component;

begin
    s_reset <= not(reset_n);
    s_pi_we(0) <= pi_we;
    s_enable_init <= data_ready and s_enable_mul;
    s_enable_step <= data_ready and (s_enable_macc or s_enable_mul
        or s_enable_shift1 or s_enable_shift2 or s_conciliate);
    s_enable_final <= data_ready and s_enable_acc;
    s_enable_shift <= s_enable_shift1 or s_enable_shift2;

    s_mux8_op1 <= s_enable_mul & (s_enable_shift1 or s_conciliate)
                  & (s_enable_shift2 or s_conciliate);
    s_mux2_op2 <= s_enable_mul;

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

    with s_mux2_op2 select
        s_op2 <= s_tp when '0',
                 s_b  when others;

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
        flush_acc       => s_flush_acc,
        sel_read_fifo   => s_sel_read_fifo,
        conciliate      => s_conciliate,
        shift_alpha_in  => s_shift_alpha_in,
        shift_alpha_out => s_shift_alpha_out,
        shift_acc       => s_shift_acc,
        read_op         => s_read_op,
        read_tp         => s_read_tp,
        enable_macc     => s_enable_macc,
        enable_mul      => s_enable_mul,
        enable_shift1   => s_enable_shift1,
        enable_shift2   => s_enable_shift2,
        enable_acc      => s_enable_acc
    );

    s_add_lzc(0) <= ((SCALE_CNT-OP2_LOG_CNT-1 downto 0 => '0') & s_lzc(0));

    u1: for k in L_RANGE generate
        if0: if k = 0 generate
            init: forward_init_s port map (
                clk             => clk,
                reset_n         => reset_n,
                enable          => s_enable_init,
                store_scale_new => s_shift_alpha_out,
                store_scale_ok  => s_enable_acc,
                flush           => s_flush,
                pi_in           => s_pi,
                b_in            => s_b,
                lzc_out         => s_lzc(k),
                alpha_out       => s_alpha(k)
            );
        end generate if0;
        ifk: if k > 0 generate
            stepk: forward_step_s port map (
                clk             => clk,
                reset_n         => reset_n,
                sel_read_fifo   => s_sel_read_fifo,
                sel_op1         => s_mux8_op1,
                sel_op2         => s_enable_shift,
                shift_alpha_in  => s_shift_alpha_in,
                shift_alpha_out => s_shift_alpha_out,
                enable          => s_enable_step,
                flush_macc      => s_flush,
                flush_acc       => s_flush_acc,
                shift_acc       => s_shift_acc,
                flush_fifo      => s_enable_acc,
                op2_in          => s_op2_reg,
                alpha_in        => s_alpha(k-1),
                lzc_in          => s_lzc(k-1),
                lzc_out         => s_lzc(k),
                alpha_out       => s_alpha(k)
            );
            reg_lzc_k: reg_op2_log port map (
                clk      => clk,
                reset_n  => reset_n,
                load     => s_enable_acc_d,
                data_in  => s_lzc(k),
                data_out => s_reg_lzc(k)
            );
            reg_scale_k: reg_scale port map (
                clk      => clk,
                reset_n  => reset_n,
                load     => s_enable_acc,
                data_in  => s_add_lzc(k-1),
                data_out => s_reg_add_lzc(k)
            );
            addk: add_scale port map (
                scale_in    => s_reg_add_lzc(k),
                lzc_in      => s_reg_lzc(k),
                scale_out   => s_add_lzc(k)
            );

        end generate ifk;
    end generate u1;

    process(clk)
    begin
        if(clk = '1' and clk'event) then
            s_enable_acc_d <= s_enable_acc;
        end if;
    end process;

    u2: likelihood port map (
        clk             => clk,
        reset_n         => reset_n,
        load            => s_shift_alpha_out,
        enable          => s_enable_final,
        ps_scale_in     => s_add_lzc(L_CNT-1),
        alpha_in        => s_alpha(L_CNT-1),
        ps_scale_out    => ps_scale_out,
        ps_out          => ps_out
    );

end forward_arch;
