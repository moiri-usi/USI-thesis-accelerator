library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity forward_ctrl is
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
end forward_ctrl;

architecture sm of forward_ctrl is
    type state is (st_init, st_select, st_macc, st_conciliate_macc1, st_conciliate_macc2, st_shift1,
        st_conciliate_shift1, st_conciliate_shift2, st_shift2, st_mul1, st_mul2, st_store, st_flush);
    signal current_state, next_state : state;
    signal switch_fifo : boolean;
    signal s_sel_read_fifo, s_reset_cnt1, s_reset_cnt2, s_enable_cnt2 : std_logic;
begin
    process(reset_n, current_state, ctrl_cnt1, ctrl_cnt2)
    begin
        flush           <= '0';
        flush_acc       <= '0';
        conciliate      <= '0';
        shift_alpha_in  <= '0';
        shift_alpha_out <= '0';
        shift_acc       <= '0';
        read_op         <= '0';
        read_tp         <= '0';
        s_enable_cnt2   <= '0';
        enable_macc     <= '0';
        enable_mul      <= '0';
        enable_shift1   <= '0';
        enable_shift2   <= '0';
        enable_acc      <= '0';
        next_state      <= st_init;
        s_reset_cnt1    <= '0';
        s_reset_cnt2    <= '0';
        switch_fifo     <= FALSE;
        case current_state is
        when st_init => 
            next_state <= st_init;
            if reset_n = '1' then
                next_state <= st_select;
                s_reset_cnt1  <= '1';
                s_reset_cnt2  <= '1';
            end if;

        when st_select =>
            next_state <= st_macc;
            enable_acc  <= '1';
            read_tp     <= '1';
            switch_fifo <= TRUE;

        when st_macc =>
            next_state <= st_macc;
            if ctrl_cnt1 = N_CNT-1 then
                next_state <= st_conciliate_macc1;
            elsif ctrl_cnt1 < N_CNT-1 then
                read_tp        <= '1';
            end if;
            shift_alpha_in <= '1';
            enable_macc    <= '1';

        when st_conciliate_macc1 =>
            next_state <= st_conciliate_macc2;
            conciliate  <= '1';

        when st_conciliate_macc2 =>
            next_state <= st_shift1;
            conciliate  <= '1';

        when st_shift1 =>
            next_state <= st_shift2;
            enable_shift1 <= '1';

        when st_shift2 =>
            next_state <= st_conciliate_shift1;
            enable_shift2 <= '1';
            flush_acc     <= '1';
            s_reset_cnt1  <= '1';

        when st_conciliate_shift1 =>
            next_state <= st_conciliate_shift2;
            enable_shift2 <= '1';
            conciliate  <= '1';

        when st_conciliate_shift2 =>
            shift_acc  <= '1';
            next_state <= st_mul1;
            conciliate  <= '1';

        when st_mul1 =>
            next_state <= st_mul2;
            enable_mul <= '1';

        when st_mul2 =>
            next_state <= st_store;
            enable_mul  <= '1';

        when st_store =>
            next_state <= st_flush;
            shift_alpha_out <= '1';
            read_op         <= '1';
            s_reset_cnt1    <= '1';
            s_enable_cnt2   <= '1';

        when st_flush =>
            next_state <= st_macc;
            if ctrl_cnt2 = N_CNT-1 then
                next_state <= st_select;
                s_reset_cnt1    <= '1';
            else
                read_tp <= '1';
            end if;
            flush <= '1';

        end case;
    end process;

    process(clk, reset_n, enable, s_sel_read_fifo)
    begin
        sel_read_fifo <= s_sel_read_fifo;
        if reset_n = '0' then
            current_state <= st_init;
            s_sel_read_fifo <= '0';
            reset_cnt1 <= '0';
            reset_cnt2 <= '0';
            enable_cnt2 <= '0';
        else
            if enable = '1' and rising_edge(clk) then
                reset_cnt1 <= s_reset_cnt1;
                reset_cnt2 <= s_reset_cnt2;
                enable_cnt2 <= s_enable_cnt2;
                current_state <= next_state;
                if switch_fifo = TRUE then
                    s_sel_read_fifo <= not(s_sel_read_fifo);
                end if;
            end if;
        end if;
    end process;
end sm;
