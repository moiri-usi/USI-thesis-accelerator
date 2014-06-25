library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity flash_tb is
    port(
        clk          : in    std_logic;
        reset_n      : in    std_logic;
        read_reg     : in    std_logic;
        reg_type     : in    std_logic_vector(2 downto 0);
        reg_data     : out   std_logic_vector(7 downto 0)
    );
end flash_tb;

architecture tb of flash_tb is
signal s_cs, s_clk : std_logic;
signal s_db : std_logic_vector(3 downto 0);

component flash is
    port(
        clk          : in    std_logic;
        reset_n      : in    std_logic;
        read_reg     : in    std_logic;
        reg_type     : in    std_logic_vector(2 downto 0);
        o_reg_type   : out   std_logic_vector(2 downto 0);
        o_reset      : out   std_logic;
        o_read_reg   : out   std_logic;
        reg_data     : out   std_logic_vector(7 downto 0);
    --    QspiSCK      : out   std_logic;
        QspiDB       : inout std_logic_vector(3 downto 0);
        QspiCSn      : out   std_logic
    );
end component;

component s25fl128s is
    PORT (
        -- Data Inputs/Outputs
        SI                : INOUT std_ulogic := 'U'; -- serial data input/IO0
        SO                : INOUT std_ulogic := 'U'; -- serial data output/IO1
        -- Controls
        SCK               : IN    std_ulogic := 'U'; -- serial clock input
        CSNeg             : IN    std_ulogic := 'U'; -- chip select input
        RSTNeg            : IN    std_ulogic := 'U'; -- hardware reset pin
        WPNeg             : INOUT std_ulogic := 'U'; -- write protect input/IO2
        HOLDNeg           : INOUT std_ulogic := 'U'  -- hold input/IO3
    );
end component;
begin
    ctrl: flash port map(
        clk          => clk,
        reset_n      => reset_n,
        read_reg     => read_reg,
        reg_type     => reg_type,
        o_reg_type   => open,
        o_reset      => open,
        o_read_reg   => open,
        reg_data     => reg_data,
        QspiDB       => s_db,
        QspiCSn      => s_cs
    );

    s_clk <= clk and s_cs;
    prom: s25fl128s port map(
        SI           => s_db(0),
        SO           => s_db(1),
        SCK          => s_clk,
        CSNeg        => s_cs,
        RSTNeg       => reset_n,
        --WPNeg        => s_db(2),
        WPNeg        => open,
        --HOLDNeg      => s_db(3)
        HOLDNeg      => open
    );

end tb;
