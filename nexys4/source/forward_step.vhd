--------------------------------------------------------------------------------
-- Main Step of the Basic Forward Algorithm                                   --
--                                                                            --
-- Master's Thesis Project 2014                                               --
-- Università della Svizzera Italiana                                         --
-- Master of Science in Informatics, Embedded System Design                   --
--                                                                            --
-- 05.07.2014, Simon Maurer                                                   --
--------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity forward_step is
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
end forward_step;

architecture forward_step_arch of forward_step is
signal s_feed_back : std_logic_vector(MACC_WIDTH);
signal s_mul : std_logic_vector(MUL_WIDTH);
signal s_fifo_out, s_fifo0_out, s_fifo1_out, s_fifo0_in, s_fifo1_in,
    s_op1 : std_logic_vector(OP1_WIDTH);
signal s_op2, s_lzc_fact : std_logic_vector(OP2_WIDTH);
signal s_mux4_op1 : std_logic_vector(1 downto 0);
signal sel_read_fifo_n, s_fifo0_we, s_fifo1_we, s_fifo0_re, s_fifo1_re,
    s_reset_macc, s_fifo0_rst, s_fifo1_rst, s_load_lzc : std_logic;

component macc is
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        flush_acc : in  std_logic;
        shift_acc : in  std_logic;
        enable    : in  std_logic;
        op1       : in  std_logic_vector(OP1_WIDTH);
        op2       : in  std_logic_vector(OP2_WIDTH);
        mul       : out std_logic_vector(MUL_WIDTH);
        macc      : out std_logic_vector(MACC_WIDTH)
    );
end component;

component lzc_op2 is
    port(
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        load     : in  std_logic;
        load_out : in  std_logic;
        data_in  : in  std_logic_vector(OP2_WIDTH);
        data_out : out std_logic_vector(OP2_LOG_WIDTH)
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

    with sel_op1 select
        s_op1 <= s_fifo_out                       when "000",  -- next alpha
                 s_feed_back(MACC_MOST_WIDTH)     when "001",  -- higher part to shift
   --              (OP1_CNT-OP2_CNT-1 downto 0 => '0')
   --                 & s_feed_back(MACC_LOW_WIDTH) when "010",  -- lower part to shift
                 s_feed_back(MACC_LOW_WIDTH)      when "010",  -- lower part to shift
                 s_feed_back(MACC_LEAST_WIDTH)    when "100",  -- shiftet val to mul
                 (others => '0')                  when others; -- conciliate

    s_lzc_fact <= std_logic_vector(to_unsigned(2**to_integer(unsigned(lzc_in)), OP2_CNT));

    with sel_op2 select
        s_op2 <= op2_in     when '0',
                 s_lzc_fact when others;

    with sel_read_fifo select
        s_fifo0_in <= s_fifo0_out when '0',
                      alpha_in    when others;

    with sel_read_fifo_n select
        s_fifo1_in <= s_fifo1_out when '0',
                      alpha_in    when others;

    with sel_read_fifo select
        s_fifo_out <= s_fifo0_out when '0',
                      s_fifo1_out when others;

    s_reset_macc <= reset_n and not(flush_macc);

    macc_u: macc port map (
        clk       => clk,
        reset_n   => s_reset_macc,
        shift_acc => shift_acc,
        flush_acc => flush_acc,
        enable    => enable,
        op1       => s_op1,
        op2       => s_op2,
        mul       => s_mul,
        macc      => s_feed_back
    );

    en_lzc: process(s_mul, shift_alpha_out)
    begin
        if s_mul = (MUL_WIDTH => '0') then
            s_load_lzc <= '0';
        else
            s_load_lzc <= shift_alpha_out;
        end if;
    end process;

    lzc: lzc_op2 port map (
        clk      => clk,
        reset_n  => reset_n,
        load     => s_load_lzc,
        load_out => flush_fifo,
        data_in  => s_mul(MUL_LZC_WIDTH),
        data_out => lzc_out
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
