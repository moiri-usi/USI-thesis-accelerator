library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package param_pkg is
    -- Signal Widths
    constant OP1_CNT : integer := 25;
    subtype  OP1_WIDTH is integer range OP1_CNT-1 downto 0;
    constant OP2_CNT : integer := 18;
    subtype  OP2_WIDTH is integer range OP2_CNT-1 downto 0;
    constant MUL_CNT : integer := 43;
    subtype  MUL_WIDTH is integer range MUL_CNT-1 downto 0;
    subtype  MUL_MOST_WIDTH is integer range MUL_CNT-1 downto MUL_CNT-OP1_CNT;
    subtype  MUL_LEAST_WIDTH is integer range MUL_CNT-OP1_CNT-1 downto 0;
    constant MACC_CNT : integer := 48;
    subtype  MACC_WIDTH is integer range MACC_CNT-1 downto 0;
    subtype  MACC_MOST_WIDTH is integer range MACC_CNT-1 downto MACC_CNT-OP1_CNT;
    subtype  MACC_LEAST_WIDTH is integer range MACC_CNT-OP1_CNT-1 downto 0;
    -- Constants
    constant N_CNT : integer := 2;
    subtype  N_RANGE is integer range 0 to N_CNT-1;
    constant L_CNT : integer := 3;
    subtype  L_RANGE is integer range 0 to L_CNT-1;
    -- Array types
    type ARRAY_A   is array (natural range <>) of std_logic_vector(OP1_WIDTH);
    type ARRAY_TP  is array (natural range <>) of std_logic_vector(OP2_WIDTH);
    type ARRAY_OP1 is array (natural range <>) of std_logic_vector(OP1_WIDTH);
end param_pkg;
