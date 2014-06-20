library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

package param_pkg is
    -- Signal Widths
    constant OP1_CNT : integer := 25;
    subtype  OP1_WIDTH is integer range OP1_CNT-1 downto 0;
    constant OP1_LOG_CNT : integer := integer(ceil(log2(real(OP1_CNT))));
    subtype  OP1_LOG_WIDTH is integer range OP1_LOG_CNT-1 downto 0;
    constant OP2_CNT : integer := 18;
    subtype  OP2_WIDTH is integer range OP2_CNT-1 downto 0;
    constant OP2_LOG_CNT : integer := integer(ceil(log2(real(OP2_CNT))));
    subtype  OP2_LOG_WIDTH is integer range OP2_LOG_CNT-1 downto 0;
    constant MUL_CNT : integer := 43;
    subtype  MUL_WIDTH is integer range MUL_CNT-1 downto 0;
    subtype  MUL_MOST_WIDTH is integer range MUL_CNT-1 downto MUL_CNT-OP1_CNT;
    subtype  MUL_LZC_WIDTH is integer range MUL_CNT-1 downto MUL_CNT-OP2_CNT;
    subtype  MUL_LEAST_WIDTH is integer range OP1_CNT-1 downto 0;
    constant MACC_CNT : integer := 48;
    subtype  MACC_WIDTH is integer range MACC_CNT-1 downto 0;
    subtype  MACC_MOST_WIDTH is integer range MUL_CNT-1 downto MUL_CNT-OP1_CNT;
    subtype  MACC_LEAST_WIDTH is integer range OP1_CNT-1 downto 0;
    subtype  MACC_LOW_WIDTH is integer range OP2_CNT-1 downto 0;
    -- Constants
    constant N_CNT : integer := 3;
    subtype  N_RANGE is integer range 0 to N_CNT-1;
    constant N_LOG_CNT : integer := integer(ceil(log2(real(N_CNT))));
    subtype  N_LOG_RANGE is integer range 0 to N_LOG_CNT-1;
    constant L_CNT : integer := 10;
    subtype  L_RANGE is integer range 0 to L_CNT-1;
    constant L_LOG_CNT : integer := integer(ceil(log2(real(L_CNT))));
    subtype  L_LOG_RANGE is integer range 0 to L_LOG_CNT-1;
    constant M_CNT : integer := 1000;
    subtype  M_RANGE is integer range 0 to M_CNT-1;
    constant M_LOG_CNT : integer := integer(ceil(log2(real(M_CNT))));
    subtype  M_LOG_RANGE is integer range 0 to M_LOG_CNT-1;
    subtype  M_LOG_WIDTH is integer range M_LOG_CNT-1 downto 0;
    constant SCALE_CNT : integer := integer(ceil(log2(real(M_LOG_CNT))))+integer(L_LOG_CNT);
    subtype  SCALE_WIDTH is integer range SCALE_CNT-1 downto 0;
    type ARRAY_SCALE is array (natural range <>) of std_logic_vector(SCALE_WIDTH);
    -- Array types
    type ARRAY_OP1 is array (natural range <>) of std_logic_vector(OP1_WIDTH);
    type ARRAY_OP1_LOG is array (natural range <>) of std_logic_vector(OP1_LOG_WIDTH);
    type MATRIX_OP1 is array (natural range <>) of ARRAY_OP1(N_RANGE);
    type ARRAY_OP2 is array (natural range <>) of std_logic_vector(OP2_WIDTH);
    type ARRAY_OP2_LOG is array (natural range <>) of std_logic_vector(OP2_LOG_WIDTH);
end param_pkg;
