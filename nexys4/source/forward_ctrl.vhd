library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity forward_ctrl is
    port(
        clk             : in  std_logic;
        reset_n         : in  std_logic;
        flush           : out std_logic;
        flush_Ps        : out std_logic;
        sel_op1         : out std_logic;
        sel_op1_zero    : out std_logic;
        sel_op2         : out std_logic;
        load_alpha_in   : out std_logic;
        load_out        : out std_logic;
        shift_alpha_in  : out std_logic;
        shift_alpha_out : out std_logic;
        enable_step     : out std_logic;
        enable_init     : out std_logic;
        enable_final    : out std_logic
    );
end forward_ctrl;

architecture sm of forward_ctrl is
    type state is (st_init, st_load, st_macc, st_conciliate, st_mul, st_store,
        st_flush);
    signal current_state, next_state : state;
    signal cnt1, cnt2 : std_logic_vector(N_LOG_RANGE);
    signal reset_cnt1, reset_cnt2 : boolean;
begin
    process(reset_n, current_state, cnt1, cnt2)
    begin
        flush           <= '0';
        flush_Ps        <= '0';
        sel_op1         <= '0';
        sel_op1_zero    <= '0';
        sel_op2         <= '0';
        load_alpha_in   <= '0';
        load_out        <= '0';
        shift_alpha_in  <= '0';
        shift_alpha_out <= '0';
        enable_step     <= '0';
        enable_init     <= '0';
        enable_final    <= '0';
        next_state <= st_init;
        reset_cnt1 <= FALSE;
        reset_cnt2 <= FALSE;
        case current_state is
        when st_init => 
            next_state <= st_init;
            if reset_n = '1' then
                next_state <= st_load;
            end if;
        when st_load =>
            next_state <= st_macc;
            flush_Ps       <= '1';
            load_alpha_in  <= '1';
            shift_alpha_in <= '1';
            reset_cnt1 <= TRUE;
            reset_cnt2 <= TRUE;
        when st_macc =>
            next_state <= st_macc;
            if cnt1 = N_CNT-1 then
                next_state <= st_conciliate;
                reset_cnt1 <= TRUE;
            end if;
            if cnt2 = 0 then
                enable_final <= '1';
            end if;
            shift_alpha_in <= '1';
            enable_step    <= '1';
        when st_conciliate =>
            next_state <= st_conciliate;
            if cnt1 = 1 then
                next_state <= st_mul;
                reset_cnt1 <= TRUE;
            end if;
            sel_op1_zero <= '1';
            enable_step    <= '1';
        when st_mul =>
            next_state <= st_mul;
            if cnt1 = 1 then
                next_state <= st_store;
            end if;
            sel_op1     <= '1';
            sel_op2     <= '1';
            enable_step <= '1';
            enable_init <= '1';
        when st_store =>
            next_state <= st_flush;
            if cnt2 = 0 then
                load_out    <= '1';
            end if;
            shift_alpha_out <= '1';
        when st_flush =>
            next_state <= st_macc;
            if cnt2 = N_CNT then
                next_state <= st_load;
            end if;
            reset_cnt1 <= TRUE;
            flush <= '1';
        end case;
    end process;

    process(clk, reset_n, reset_cnt1, reset_cnt2)
    begin
        if reset_n = '0' then
            current_state <= st_init;
            cnt1 <= (others => '0');
            cnt2 <= (others => '0');
        elsif rising_edge(clk) then
            current_state <= next_state;
            cnt1 <= cnt1 + 1;
            if next_state = st_flush then
                cnt2 <= cnt2 + 1;
            end if;
            if reset_cnt1 = TRUE then
                cnt1 <= (others => '0');
            end if;
            if reset_cnt2 = TRUE then
                cnt2 <= (others => '0');
            end if;
        end if;
    end process;
end sm;
