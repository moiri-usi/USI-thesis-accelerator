library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity classification is
    port(
        clk          : in  std_logic;
        reset_n      : in  std_logic;
        ps1_in       : in  std_logic_vector(OP1_WIDTH);
        ps_scale1_in : in  std_logic_vector(SCALE_WIDTH);
        ps2_in       : in  std_logic_vector(OP1_WIDTH);
        ps_scale2_in : in  std_logic_vector(SCALE_WIDTH);
        theta        : in  std_logic_vector(55 downto 0);
        fail_predict : out std_logic
    );
end classification;

architecture class of classification is
    component div_op1 is
    port (
        aclk                   : in STD_LOGIC;
        s_axis_divisor_tvalid  : in STD_LOGIC;
        s_axis_dividend_tvalid : in STD_LOGIC;
        s_axis_divisor_tready  : out STD_LOGIC;
        s_axis_dividend_tready : out STD_LOGIC;
        m_axis_dout_tvalid     : out STD_LOGIC;
        s_axis_divisor_tdata   : in STD_LOGIC_VECTOR(31 downto 0);
        s_axis_dividend_tdata  : in STD_LOGIC_VECTOR(31 downto 0);
        m_axis_dout_tdata      : out STD_LOGIC_VECTOR(55 downto 0)
    );
    end component;
begin

end class;
