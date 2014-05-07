package param_pkg is
    -- Accumulator
    subtype MUL_OP1_WIDTH is integer range 3 downto 0;
    subtype MUL_OP2_WIDTH is integer range 3 downto 0;
    subtype MUL_RES_WIDTH is integer range 7 downto 0;
    subtype ACC_RES_WIDTH is integer range 7 downto 0;
    -- Variables
    subtype B_WIDTH is integer range 7 downto 0;
    subtype PI_WIDTH is integer range 7 downto 0;
    subtype TP_WIDTH is integer range 7 downto 0;
    subtype ALPHA_WIDTH is integer range 7 downto 0;
    subtype COEFF_WIDTH is integer range 7 downto 0;
    subtype LPS_WIDTH is integer range 7 downto 0;
end param_pkg;
