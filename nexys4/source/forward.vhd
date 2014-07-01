library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity forward is
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
end forward;

architecture forward_arch of forward is
signal s_b, s_tp, s_op2, s_op2_reg : std_logic_vector(OP2_WIDTH);
signal s_pi : std_logic_vector(OP1_WIDTH);
signal s_op_r_addr, s_b_w_addr, s_pi_w_addr,
    s_max_n_val : std_logic_vector(N_LOG_RAM_RANGE);
signal s_ctrl_cnt1, s_ctrl_cnt2 : std_logic_vector(N_LOG_RANGE);
signal s_tp_w_addr, s_tp_r_addr, s_max_nn_val : std_logic_vector(NN_LOG_RAM_RANGE);
signal s_alpha : ARRAY_OP1(L_RANGE);
signal s_lzc : ARRAY_OP2_LOG(L_RANGE);
signal s_reg_lzc : ARRAY_OP2_LOG(1 to L_CNT-1);
signal s_add_lzc : ARRAY_SCALE(L_RANGE);
signal s_reg_add_lzc : ARRAY_SCALE(1 to L_CNT-1);
signal s_pi_we, s_b_we, s_tp_we : std_logic_vector(0 downto 0);
signal s_mux8_op1 : std_logic_vector(2 downto 0);
signal s_mux2_op2 : std_logic;
signal s_shift_alpha_in, s_shift_alpha_out, s_shift_acc, s_read_op, s_read_tp,
    s_enable_macc, s_enable_mul, s_enable_shift1, s_enable_shift2, s_enable_shift,
    s_enable_acc, s_enable_acc_d, s_enable_op_addr,
    s_enable_init, s_enable_step, s_enable_final,
    s_conciliate, s_flush, s_flush_acc, s_reset_cnt1, s_reset_cnt2,
    s_sel_read_fifo, s_enable_cnt2, s_reset_cnt1_n, s_reset_cnt2_n : std_logic;

component ram_N_S2P_op1 is
    port(
        clka   : in  std_logic;
        wea    : in  std_logic_vector(0 DOWNTO 0);
        addra  : in  std_logic_vector(N_LOG_RAM_RANGE);
        dina   : in  std_logic_vector(OP1_WIDTH);
        clkb   : in  std_logic;
        addrb  : in  std_logic_vector(N_LOG_RAM_RANGE);
        doutb  : out std_logic_vector(OP1_WIDTH)
    );
end component;

component ram_N_S2P_op2 is
    port(
        clka   : in  std_logic;
        wea    : in  std_logic_vector(0 DOWNTO 0);
        addra  : in  std_logic_vector(N_LOG_RAM_RANGE);
        dina   : in  std_logic_vector(OP2_WIDTH);
        clkb   : in  std_logic;
        addrb  : in  std_logic_vector(N_LOG_RAM_RANGE);
        doutb  : out std_logic_vector(OP2_WIDTH)
    );
end component;

component ram_NN_S2P_op2 is
    port(
        clka   : in  std_logic;
        wea    : in  std_logic_vector(0 DOWNTO 0);
        addra  : in  std_logic_vector(NN_LOG_RAM_RANGE);
        dina   : in  std_logic_vector(OP2_WIDTH);
        clkb   : in  std_logic;
        addrb  : in  std_logic_vector(NN_LOG_RAM_RANGE);
        doutb  : out std_logic_vector(OP2_WIDTH)
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

component counter_N_ram is
    port ( 
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        enable   : in  std_logic;
        max_val  : in  std_logic_vector(N_LOG_RAM_RANGE);
        count    : out std_logic_vector(N_LOG_RAM_RANGE)
    );
end component;

component counter_NN_ram is
    port ( 
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        enable   : in  std_logic;
        max_val  : in  std_logic_vector(NN_LOG_RAM_RANGE);
        count    : out std_logic_vector(NN_LOG_RAM_RANGE)
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
        ctrl_cnt1       : in  std_logic_vector(N_LOG_RANGE);
        ctrl_cnt2       : in  std_logic_vector(N_LOG_RANGE);
        flush           : out std_logic;
        flush_acc       : out std_logic;
        sel_read_fifo   : out std_logic;
        conciliate      : out std_logic;
        shift_alpha_in  : out std_logic;
        shift_alpha_out : out std_logic;
        shift_acc       : out std_logic;
        read_op         : out std_logic;
        read_tp         : out std_logic;
        reset_cnt1      : out std_logic;
        reset_cnt2      : out std_logic;
        enable_cnt2     : out std_logic;
        enable_macc     : out std_logic;
        enable_mul      : out std_logic;
        enable_shift1   : out std_logic;
        enable_shift2   : out std_logic;
        enable_acc      : out std_logic
    );
end component;

component forward_init is
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

component forward_step is
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
    s_pi_we(0) <= pi_we;
    s_b_we(0) <= b_we;
    s_tp_we(0) <= tp_we;
    s_enable_init <= data_ready and s_enable_mul;
    s_enable_step <= data_ready and (s_enable_macc or s_enable_mul
        or s_enable_shift1 or s_enable_shift2 or s_conciliate);
    s_enable_final <= data_ready and s_enable_acc;
    s_enable_shift <= s_enable_shift1 or s_enable_shift2;

    s_mux8_op1 <= s_enable_mul & (s_enable_shift1 or s_conciliate)
                  & (s_enable_shift2 or s_conciliate);
    s_mux2_op2 <= s_enable_mul;

    s_max_n_val <= std_logic_vector(to_unsigned(N_CNT, N_LOG_RAM_CNT));

    pi_w_addr: counter_N_ram port map (
        clk      => clk,
        reset_n  => reset_n,
        enable   => pi_we,
        max_val  => s_max_n_val,
        count    => s_pi_w_addr
    );

    op_r_addr: counter_N_ram port map (
        clk      => clk,
        reset_n  => reset_n,
        enable   => s_read_op,
        max_val  => s_max_n_val,
        count    => s_op_r_addr
    );

    ram_pi: ram_N_S2P_op1 port map (
        clka  => clk,
        wea   => s_pi_we,
        addra => s_pi_w_addr,
        dina  => pi_in,
        clkb  => clk,
        addrb => s_op_r_addr,
        doutb => s_pi
    );

    b_w_addr: counter_N_ram port map (
        clk      => clk,
        reset_n  => reset_n,
        enable   => b_we,
        max_val  => s_max_n_val,
        count    => s_b_w_addr
    );

    ram_b: ram_N_S2P_op2 port map (
        clka  => clk,
        wea   => s_b_we,
        addra => s_b_w_addr,
        dina  => b_in,
        clkb  => clk,
        addrb => s_op_r_addr,
        doutb => s_b
    );

    s_max_nn_val <= std_logic_vector(to_unsigned(NN_CNT, NN_LOG_RAM_CNT));

    tp_w_addr: counter_NN_ram port map (
        clk      => clk,
        reset_n  => reset_n,
        enable   => tp_we,
        max_val  => s_max_nn_val,
        count    => s_tp_w_addr
    );

    tp_r_addr: counter_NN_ram port map (
        clk      => clk,
        reset_n  => reset_n,
        enable   => s_read_tp,
        max_val  => s_max_nn_val,
        count    => s_tp_r_addr
    );

    ram_tp: ram_NN_S2P_op2 port map (
        clka  => clk,
        wea   => s_tp_we,
        addra => s_tp_w_addr,
        dina  => tp_in,
        clkb  => clk,
        addrb => s_tp_r_addr,
        doutb => s_tp
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

    s_reset_cnt1_n <= not(s_reset_cnt1) and reset_n;

    c_cnt1: counter_N port map (
        clk      => clk,
        reset_n  => s_reset_cnt1_n,
        enable   => '1',
        count    => s_ctrl_cnt1
    );

    s_reset_cnt2_n <= not(s_reset_cnt2) and reset_n;

    c_cnt2: counter_N port map (
        clk      => clk,
        reset_n  => s_reset_cnt2_n,
        enable   => s_enable_cnt2,
        count    => s_ctrl_cnt2
    );

    ctrl: forward_ctrl port map (
        clk             => clk,
        reset_n         => reset_n,
        enable          => data_ready,
        ctrl_cnt1       => s_ctrl_cnt1,
        ctrl_cnt2       => s_ctrl_cnt2,
        flush           => s_flush,
        flush_acc       => s_flush_acc,
        sel_read_fifo   => s_sel_read_fifo,
        conciliate      => s_conciliate,
        shift_alpha_in  => s_shift_alpha_in,
        shift_alpha_out => s_shift_alpha_out,
        shift_acc       => s_shift_acc,
        read_op         => s_read_op,
        read_tp         => s_read_tp,
        reset_cnt1      => s_reset_cnt1,
        reset_cnt2      => s_reset_cnt2,
        enable_cnt2     => s_enable_cnt2,
        enable_macc     => s_enable_macc,
        enable_mul      => s_enable_mul,
        enable_shift1   => s_enable_shift1,
        enable_shift2   => s_enable_shift2,
        enable_acc      => s_enable_acc
    );

    s_add_lzc(0) <= ((SCALE_CNT-OP2_LOG_CNT-1 downto 0 => '0') & s_lzc(0));

    u1: for k in L_RANGE generate
        if0: if k = 0 generate
            init: forward_init port map (
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
            stepk: forward_step port map (
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
