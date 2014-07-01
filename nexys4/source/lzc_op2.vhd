library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity lzc_op2 is
    port (
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        load     : in  std_logic;
        load_out : in  std_logic;
        data_in  : in  std_logic_vector(OP2_WIDTH);
        data_out : out std_logic_vector(OP2_LOG_WIDTH)
    );
end lzc_op2;

architecture arch of lzc_op2 is
signal s_lzc, s_lzc_new, s_lzc_last, s_lzc_reg1,
    s_init_reg1 : std_logic_vector(OP2_LOG_WIDTH);
signal s_sel_lzc, s_load_out_d, s_load_reg1,
    s_load_reg2: std_logic := '0';

component reg_op2_log is
    port ( 
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        load     : in  std_logic;
        data_in  : in  std_logic_vector(OP2_LOG_WIDTH);
        data_out : out std_logic_vector(OP2_LOG_WIDTH)
    );
end component;

begin
    lzc: process(data_in)
        variable leading_zeros, shift_fact : integer;
    begin
        leading_zeros := 0;
        L1: loop
            exit L1 when leading_zeros = OP2_CNT;
            exit L1 when data_in(OP2_CNT-leading_zeros-1) = '1';
            leading_zeros := leading_zeros+1;
        end loop;
        s_lzc <= std_logic_vector(to_unsigned(leading_zeros, OP2_LOG_CNT));
    end process;

    reg0: reg_op2_log port map (
        clk      => clk,
        reset_n  => reset_n,
        load     => load,
        data_in  => s_lzc,
        data_out => s_lzc_new
    );

    process(clk)
    begin
        if(clk = '1' and clk'event) then
            s_load_out_d <= load_out;
        end if;
    end process;

    s_load_reg1 <= s_sel_lzc or s_load_out_d;
    s_init_reg1 <= std_logic_vector(to_unsigned(OP2_CNT, OP2_LOG_CNT));
    with s_load_out_d select
        s_lzc_reg1 <= s_lzc_new   when '0',
                      s_init_reg1 when others;

    reg1: reg_op2_log port map (
        clk      => clk,
        reset_n  => reset_n,
        load     => s_load_reg1,
        data_in  => s_lzc_reg1,
        data_out => s_lzc_last
    );

    s_load_reg2 <= load_out;
    reg2: reg_op2_log port map (
        clk      => clk,
        reset_n  => reset_n,
        load     => s_load_reg2,
        data_in  => s_lzc_last,
        data_out => data_out
    );

    sel_lzc: process(s_lzc_new, s_lzc_last)
    begin
        if (s_lzc_new < s_lzc_last) or ((s_lzc_new > (OP2_LOG_WIDTH => '0'))
            and s_lzc_last = (OP2_LOG_WIDTH => '0')) then
            s_sel_lzc <= '1';
        else
            s_sel_lzc <= '0';
        end if;
    end process;
end arch;
