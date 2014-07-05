--------------------------------------------------------------------------------
-- Leading Zero Counter of Operand 2.                                         --
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
signal s_lzc, s_lzc0, s_lzc0_reg, s_lzc1, s_lzc1_reg, s_lzc_new, s_lzc_last, s_lzc_reg1,
    s_init_reg1 : std_logic_vector(OP2_LOG_WIDTH);
signal s_sel_lzc, s_load_d, s_load_out_d, s_load_out_dd, s_load_reg1,
    s_load_reg2, s_first_done, s_first_done_d : std_logic := '0';

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
    lzc0: process(data_in)
        variable leading_zeros0 : integer;
    begin
        leading_zeros0 := 0;
        L1: loop
            if data_in(OP2_CNT-leading_zeros0-1) = '1' then
                s_first_done <= '1';
            else
                s_first_done <= '0';
            end if;
            exit L1 when leading_zeros0 = OP2_CNT_12;
            exit L1 when data_in(OP2_CNT-leading_zeros0-1) = '1';
            leading_zeros0 := leading_zeros0+1;
        end loop;
        s_lzc0 <= std_logic_vector(to_unsigned(leading_zeros0, OP2_LOG_CNT));
    end process;

    reg01: reg_op2_log port map (
        clk      => clk,
        reset_n  => reset_n,
        load     => load,
        data_in  => s_lzc0,
        data_out => s_lzc0_reg
    );

    lzc1: process(data_in)
        variable leading_zeros1 : integer;
    begin
        leading_zeros1 := 0;
        L2: loop
            exit L2 when leading_zeros1 = OP2_CNT_22;
            exit L2 when data_in(OP2_CNT_22-leading_zeros1-1) = '1';
            leading_zeros1 := leading_zeros1+1;
        end loop;
        s_lzc1 <= std_logic_vector(to_unsigned(leading_zeros1, OP2_LOG_CNT));
    end process;

    reg02: reg_op2_log port map (
        clk      => clk,
        reset_n  => reset_n,
        load     => load,
        data_in  => s_lzc1,
        data_out => s_lzc1_reg
    );

    with s_first_done_d select
        s_lzc <= s_lzc0_reg              when '1',
                 s_lzc0_reg + s_lzc1_reg when others;
--    with s_first_done select
--        s_lzc <= s_lzc0          when '1',
--                 s_lzc0 + s_lzc1 when others;

    reg0: reg_op2_log port map (
        clk      => clk,
        reset_n  => reset_n,
        load     => s_load_d,
        --load     => load,
        data_in  => s_lzc,
        data_out => s_lzc_new
    );

    process(clk)
    begin
        if(clk = '1' and clk'event) then
            s_first_done_d <= s_first_done;
            s_load_d <= load;
            s_load_out_d <= load_out;
            s_load_out_dd <= s_load_out_d;
        end if;
    end process;

    s_load_reg1 <= s_sel_lzc or s_load_out_dd;
    --s_load_reg1 <= s_sel_lzc or s_load_out_d;
    --s_init_reg1 <= std_logic_vector(to_unsigned(OP2_CNT, OP2_LOG_CNT));
    s_init_reg1 <= (others => '0');
    with s_load_out_dd select
    --with s_load_out_d select
        s_lzc_reg1 <= s_lzc_new   when '0',
                      s_init_reg1 when others;

    reg1: reg_op2_log port map (
        clk      => clk,
        reset_n  => reset_n,
        load     => s_load_reg1,
        data_in  => s_lzc_reg1,
        data_out => s_lzc_last
    );

    s_load_reg2 <= s_load_out_d;
    --s_load_reg2 <= load_out;
    reg2: reg_op2_log port map (
        clk      => clk,
        reset_n  => reset_n,
        load     => s_load_reg2,
        data_in  => s_lzc_last,
        data_out => data_out
    );

    sel_lzc: process(s_lzc_new, s_lzc_last)
    begin
        if (s_lzc_new < s_lzc_last)
            or ((s_lzc_new > (OP2_LOG_WIDTH => '0'))
            and s_lzc_last = (OP2_LOG_WIDTH => '0')) then
                --and (s_lzc_new < OP2_CNT)) then
            s_sel_lzc <= '1';
        else
            s_sel_lzc <= '0';
        end if;
    end process;
end arch;
