library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity forward_ctrl is
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
        enable_macc     : out std_logic;
        enable_mul      : out std_logic;
        enable_shift    : out std_logic;
        enable_acc      : out std_logic
    );
end forward_ctrl;

architecture sm of forward_ctrl is
    type state is (st_init, st_select, st_macc, st_conciliate, st_shift,
        st_mul, st_store, st_flush);
    signal current_state, next_state : state;
    signal cnt1, cnt2 : integer;
    signal reset_cnt1, reset_cnt2, switch_fifo : boolean;
    signal s_sel_read_fifo : std_logic;
begin
    process(reset_n, current_state, cnt1, cnt2)
    begin
        flush           <= '0';
        conciliate      <= '0';
        shift_alpha_in  <= '0';
        shift_alpha_out <= '0';
        read_op         <= '0';
        read_tp         <= '0';
        enable_macc     <= '0';
        enable_mul      <= '0';
        enable_shift    <= '0';
        enable_acc      <= '0';
        next_state  <= st_init;
        reset_cnt1  <= FALSE;
        reset_cnt2  <= FALSE;
        switch_fifo <= FALSE;
        case current_state is
        when st_init => 
            next_state <= st_init;
            if reset_n = '1' then
                next_state <= st_select;
            end if;

        when st_select =>
            next_state <= st_macc;
            enable_acc  <= '1';
            reset_cnt1  <= TRUE;
            reset_cnt2  <= TRUE;
            switch_fifo <= TRUE;

        when st_macc =>
            next_state <= st_macc;
            if cnt1 = N_CNT-1 then
                next_state <= st_conciliate;
                reset_cnt1 <= TRUE;
            end if;
            shift_alpha_in <= '1';
            read_tp        <= '1';
            enable_macc    <= '1';

        when st_conciliate =>
            next_state <= st_conciliate;
            if cnt1 = 1 then
                next_state <= st_shift;
                reset_cnt1 <= TRUE;
            --elsif cnt1 = 3 then
            --    reset_cnt1 <= TRUE;
            --    next_state <= st_mul;
            end if;
            enable_macc    <= '1';
            --conciliate  <= '1';

        when st_shift =>
            next_state <= st_shift;
            if cnt1 = 1 then
                reset_cnt1 <= TRUE;
                next_state <= st_mul;
            end if;
            enable_shift <= '1';

        when st_mul =>
            next_state <= st_mul;
            if cnt1 = 1 then
                next_state <= st_store;
            end if;
            enable_mul <= '1';

        when st_store =>
            next_state <= st_flush;
            shift_alpha_out <= '1';
            read_op         <= '1';

        when st_flush =>
            next_state <= st_macc;
            if cnt2 = N_CNT then
                next_state <= st_select;
            end if;
            reset_cnt1 <= TRUE;
            flush      <= '1';

        end case;
    end process;

    process(clk, reset_n, reset_cnt1, reset_cnt2, s_sel_read_fifo)
    begin
        sel_read_fifo <= s_sel_read_fifo;
        if reset_n = '0' then
            current_state <= st_init;
            s_sel_read_fifo <= '0';
            cnt1 <= 0;
            cnt2 <= 0;
        else
            if enable = '1' and rising_edge(clk) then
                current_state <= next_state;
                cnt1 <= cnt1 + 1;
                if next_state = st_flush then
                    cnt2 <= cnt2 + 1;
                end if;
                if reset_cnt1 = TRUE then
                    cnt1 <= 0;
                end if;
                if reset_cnt2 = TRUE then
                    cnt2 <= 0;
                end if;
                if switch_fifo = TRUE then
                    s_sel_read_fifo <= not(s_sel_read_fifo);
                end if;
            end if;
        end if;
    end process;
end sm;
