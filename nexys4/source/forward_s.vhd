library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity forward_s is
    port ( 
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        B_in     : in  std_logic_vector(OP2_WIDTH);
        TP_in    : in  std_logic_vector(OP2_WIDTH);
        PI_in    : in  std_logic_vector(OP1_WIDTH);
        Ps       : out std_logic_vector(OP1_WIDTH)
    );
end forward_s;

architecture forward_arch of forward_s is
signal s_B, s_TP, s_op2, s_op2_reg : std_logic_vector (OP2_WIDTH);
signal s_PI, s_Ps : std_logic_vector (OP1_WIDTH);
signal s_alpha : ARRAY_OP1(L_RANGE);
signal s_sel_op1, s_sel_op1_zero, s_sel_op2, s_shift_alpha_in,
    s_shift_alpha_out, s_enable_step, s_enable_init, s_flush,
    s_enable_final, s_sel_read_fifo : std_logic;

component forward_ctrl is
    port(
        clk             : in  std_logic;
        reset_n         : in  std_logic;
        flush           : out std_logic;
        sel_read_fifo   : out std_logic;
        sel_op1         : out std_logic;
        sel_op1_zero    : out std_logic;
        sel_op2         : out std_logic;
        shift_alpha_in  : out std_logic;
        shift_alpha_out : out std_logic;
        enable_step     : out std_logic;
        enable_init     : out std_logic;
        enable_final    : out std_logic
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

component reg_op1 is
    port ( 
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        load     : in  std_logic;
        data_in  : in  std_logic_vector(OP1_WIDTH);
        data_out : out std_logic_vector(OP1_WIDTH)
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

component forward_init_s is
port (
    clk             : in  std_logic;
    reset_n         : in  std_logic;
    enable          : in  std_logic;
    flush           : in  std_logic;
    PI_in           : in  std_logic_vector(OP1_WIDTH);
    B_in            : in  std_logic_vector(OP2_WIDTH);
    alpha_out       : out std_logic_vector(OP1_WIDTH)
);
end component;

component forward_step_s is
port (
    clk             : in  std_logic;
    reset_n         : in  std_logic;
    sel_read_fifo   : in  std_logic;
    sel_op1         : in  std_logic;
    sel_op1_zero    : in  std_logic;
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
    Ps             : out std_logic_vector(OP1_WIDTH)
);
end component;

begin 
    s_PI <= PI_in;
    s_B <= B_in;
    s_TP <= TP_in;

    ctrl: forward_ctrl port map (
        clk             => clk,
        reset_n         => reset_n,
        flush           => s_flush,
        sel_read_fifo   => s_sel_read_fifo,
        sel_op1         => s_sel_op1,
        sel_op1_zero    => s_sel_op1_zero,
        sel_op2         => s_sel_op2,
        shift_alpha_in  => s_shift_alpha_in,
        shift_alpha_out => s_shift_alpha_out,
        enable_step     => s_enable_step,
        enable_init     => s_enable_init,
        enable_final    => s_enable_final
    );

    mux_op2: mux_2_op2 port map (
        sel             => s_sel_op2,
        data_in_1       => s_TP,
        data_in_2       => s_B,
        data_out        => s_op2
    );

    reg1: reg_op2 port map (
        clk             => clk,
        reset_n         => reset_n,
        load            => s_enable_step,
        data_in         => s_op2,
        data_out        => s_op2_reg
    );

    u1: for k in L_RANGE generate
        if0: if k = 0 generate
            init: forward_init_s port map (
                clk             => clk,
                reset_n         => reset_n,
                flush           => s_flush,
                PI_in           => s_PI,
                B_in            => s_B,
                enable          => s_enable_init,
                alpha_out       => s_alpha(k)
            );
        end generate if0;
        ifk: if k > 0 generate
            stepk: forward_step_s port map (
                clk             => clk,
                reset_n         => reset_n,
                sel_read_fifo   => s_sel_read_fifo,
                sel_op1         => s_sel_op1,
                sel_op1_zero    => s_sel_op1_zero,
                shift_alpha_in  => s_shift_alpha_in,
                shift_alpha_out => s_shift_alpha_out,
                enable          => s_enable_step,
                flush_macc      => s_flush,
                flush_fifo      => s_enable_final,
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
        enable          => s_enable_final,
        alpha_in        => s_alpha(L_CNT-1),
        Ps              => Ps
    );

end forward_arch;
