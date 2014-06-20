library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity forward_init_s is
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
end forward_init_s;

architecture forward_init_arch of forward_init_s is
signal s_mul : std_logic_vector(MUL_WIDTH);
signal s_reset, s_store_scale_small, s_load_reg1, s_sel_lzc : std_logic;
signal s_lzc_out, s_reg_lzc_new, s_init_reg1, s_reg1_in,
    s_reg_lzc_last : std_logic_vector(OP2_LOG_WIDTH);

component mul_s is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        enable  : in  std_logic;
        op1     : in  std_logic_vector(OP1_WIDTH);
        op2     : in  std_logic_vector(OP2_WIDTH);
        mul     : out std_logic_vector(MUL_WIDTH)
    );
end component;

component lzc_op2 is
    port(
        data_in  : in  std_logic_vector(OP2_WIDTH);
        data_out : out std_logic_vector(OP2_LOG_WIDTH)
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

component sel_lzc_op2 is
    port (
        data_in : in  std_logic_vector(OP2_LOG_WIDTH);
        ref_in  : in  std_logic_vector(OP2_LOG_WIDTH);
        sel_new : out std_logic
    );
end component;

begin
    s_reset <= reset_n and not(flush);

    mul: mul_s port map (
        clk     => clk,
        reset_n => s_reset,
        enable  => enable,
        op1     => PI_in,
        op2     => B_in,
        mul     => s_mul
    );

    lzc: lzc_op2 port map (
        data_in  => s_mul(MUL_LZC_WIDTH),
        data_out => s_lzc_out
    );

    reg0: reg_op2_log port map (
        clk      => clk,
        reset_n  => reset_n,
        load     => store_scale_new,
        data_in  => s_lzc_out,
        data_out => s_reg_lzc_new
    );

    process(clk)
    begin
        if(clk = '1' and clk'event) then
            s_store_scale_small <= store_scale_ok;
        end if;
    end process;

    s_load_reg1 <= s_sel_lzc or s_store_scale_small;
    s_init_reg1 <= std_logic_vector(to_unsigned(OP2_CNT, OP2_LOG_CNT));
    with s_store_scale_small select
        s_reg1_in <= s_reg_lzc_new when '0',
                     s_init_reg1   when others;

    reg1: reg_op2_log port map (
        clk      => clk,
        reset_n  => reset_n,
        load     => s_load_reg1,
        data_in  => s_reg1_in,
        data_out => s_reg_lzc_last
    );

    reg2: reg_op2_log port map (
        clk      => clk,
        reset_n  => reset_n,
        load     => store_scale_ok,
        data_in  => s_reg_lzc_last,
        data_out => lzc_out
    );

    sel_lzc: sel_lzc_op2 port map (
        data_in => s_reg_lzc_new,
        ref_in  => s_reg_lzc_last,
        sel_new => s_sel_lzc
    );

    alpha_out <= s_mul(MUL_MOST_WIDTH);

end forward_init_arch;
