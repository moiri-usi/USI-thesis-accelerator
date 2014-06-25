library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity flash is
    port(
        clk          : in    std_logic;
        reset_n      : in    std_logic;
        read_reg     : in    std_logic;
        reg_type     : in    std_logic_vector(2 downto 0);
        o_reg_type   : out   std_logic_vector(2 downto 0);
        o_reset      : out   std_logic;
        o_read_reg   : out   std_logic;
        reg_data     : out   std_logic_vector(7 downto 0);
        QspiSCK      : out   std_logic;
        QspiDB       : inout std_logic_vector(3 downto 0);
        QspiCSn      : out   std_logic
    );
end flash;

architecture ctrl of flash is
    type state is (st_settle, st_idle, st_inst, st_addr, st_dummy, st_rcv);
    type action is (a_inst, a_read);
    signal current_state, next_state : state;
    signal current_action : action;
    signal s_inst: std_logic_vector(7 downto 0);
    signal s_reg_data: std_logic_vector(7 downto 0);
    signal s_cs : std_logic;
    signal cnt : integer;
    signal reset_cnt, write_bus, read_bus : boolean;

    constant RDCR  : std_logic_vector(7 downto 0) := "00110101"; -- read ctrl reg
    constant RDSR1 : std_logic_vector(7 downto 0) := "00000101"; -- read stat1 reg
    constant RDSR2 : std_logic_vector(7 downto 0) := "00000111"; -- read stat2 reg
    constant WREN  : std_logic_vector(7 downto 0) := "00000110"; -- write enable
    constant RDID  : std_logic_vector(7 downto 0) := "10011111"; -- read manu info
begin
    o_reg_type <= reg_type;
    o_reset    <= not(reset_n);
    o_read_reg <= read_reg;
    with reg_type select
        s_inst <= RDCR  when "011",
                  RDSR1 when "000",
                  RDSR2 when "001",
                  RDID  when "010",
                  WREN  when "100",
                  RDSR1 when others;
    process(s_inst)
    begin
        case s_inst is
            when WREN   => current_action <= a_inst;
            when RDCR   => current_action <= a_read;
            when RDSR1  => current_action <= a_read;
            when RDSR2  => current_action <= a_read;
            when RDID   => current_action <= a_read;
            when others => current_action <= a_read;
        end case;
    end process;

    READ_CTRL_REG: process(read_reg, current_state, current_action, cnt)
    begin
        s_cs  <= '1';
        reset_cnt <= FALSE;
        write_bus <= FALSE;
        read_bus  <= FALSE;
        next_state  <= st_idle;
        case current_state is
        when st_settle =>
            next_state <= st_settle;
            if read_reg = '0' then
                next_state <= st_idle;
            end if;
        when st_idle => 
            if read_reg = '1' then
                next_state <= st_inst;
                reset_cnt  <= TRUE;
            end if;
        when st_inst => 
            s_cs       <= '0';
            next_state <= st_inst;
            write_bus  <= TRUE;
            if cnt = 7 then
                if current_action = a_read then
                    next_state <= st_rcv;
                elsif current_action = a_inst then
                    next_state <= st_settle;
                end if;
                reset_cnt  <= TRUE;
            end if;
        when st_addr =>
        when st_dummy =>
        when st_rcv => 
            next_state    <= st_rcv;
            s_cs          <= '0';
            read_bus <= TRUE;
            if cnt = 7 then
                next_state <= st_settle;
            end if;
        when others => next_state <= st_idle;
        end case;
    end process;

    process(clk, reset_n, reset_cnt, QspiDB)
    begin
        if reset_n = '0' then
            current_state <= st_idle;
            cnt <= 0;
            s_reg_data <= (others => '0');
            reg_data <= (others => '0');
            --QspiDB <= (others => 'Z');
        else
            if clk = '0' and clk'event then
                QspiCSn       <= s_cs;
                if write_bus = TRUE then
                    QspiDB(0)  <= s_inst(7-cnt);
                end if;
            elsif clk = '1' and clk'event then
                current_state <= next_state;
                cnt           <= cnt + 1;
                if read_bus = TRUE then
                    s_reg_data(7-cnt) <= QspiDB(1);
                    reg_data(7-cnt)   <= s_reg_data(7-cnt);
                end if;
                if reset_cnt = TRUE then
                    cnt <= 0;
                end if;
            end if;
        end if;
    end process;

end ctrl;
