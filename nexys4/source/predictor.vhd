library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.param_pkg.all;

entity predictor is
    port(
        clk          : in    std_logic;
        reset_n      : in    std_logic;
        event        : in    std_logic_vector(M_LOG_WIDTH);
        fail_predict : out   std_logic;
    -- ram
        RamCLK       : out   std_logic;
        RamADVn      : out   std_logic;
        RamCEn       : out   std_logic;
        RamCRE       : out   std_logic;
        RamOEn       : out   std_logic;
        RamWEn       : out   std_logic;
        RamLBn       : out   std_logic;
        RamUBn       : out   std_logic;
        RamWait      : in    std_logic;
        MemDB        : inout std_logic_vector(15 downto 0);
        MemAdr       : out   std_logic_vector(22 downto 0);
    -- flash
        QspiSCK      : out   std_logic;
        QspiDB       : inout std_logic_vector(3 downto 0);
        QspiCSn      : out   std_logic
    );
end predictor;

architecture predict of predictor is
signal s_data_ready, s_pi_we, s_pi_we0, s_pi_we1, s_tp_we, s_tp_we0, s_tp_we1,
    s_b_we, s_b_we0, s_b_we1, s_sel_ram, s_sel_flash : std_logic;
signal s_pi, s_ps0, s_ps1 : std_logic_vector(OP1_WIDTH);
signal s_b, s_tp : std_logic_vector(OP2_WIDTH);
signal s_ps_scale0, s_ps_scale1 : std_logic_vector(SCALE_WIDTH);

component ram_handler is
    port(
        RamCLK       : out   std_logic;
        RamADVn      : out   std_logic;
        RamCEn       : out   std_logic;
        RamCRE       : out   std_logic;
        RamOEn       : out   std_logic;
        RamWEn       : out   std_logic;
        RamLBn       : out   std_logic;
        RamUBn       : out   std_logic;
        RamWait      : in    std_logic;
        MemDB        : inout std_logic_vector(15 downto 0);
        MemAdr       : out   std_logic_vector(22 downto 0);
        sel_ram      : out   std_logic;
        b_sel        : in    std_logic_vector(M_LOG_WIDTH);
        b_out        : out   std_logic_vector(OP2_WIDTH);
        b_we         : out   std_logic
    );
end component;

component flash_handler is
    port(
        QspiSCK      : out   std_logic;
        QspiDB       : inout std_logic_vector(3 downto 0);
        QspiCSn      : out   std_logic;
        tp_out       : out   std_logic_vector(OP2_WIDTH);
        tp_we        : out   std_logic;
        pi_out       : out   std_logic_vector(OP1_WIDTH);
        pi_we        : out   std_logic;
        sel_flash    : out   std_logic;
        ready        : out   std_logic
    );
end component;

component forward_s is
    port(
        clk          : in  std_logic;
        reset_n      : in  std_logic;
        b_in         : in  std_logic_vector(OP2_WIDTH);
        b_we         : in  std_logic;
        tp_in        : in  std_logic_vector(OP2_WIDTH);
        tp_we        : in  std_logic;
        pi_in        : in  std_logic_vector(OP1_WIDTH);
        pi_we        : in  std_logic;
        data_ready   : in  std_logic;
        ps_scale_out : out std_logic_vector(SCALE_WIDTH);
        ps_out       : out std_logic_vector(OP1_WIDTH)
    );
end component;

component classification is
    port(
        ps1_in       : in  std_logic_vector(OP1_WIDTH);
        ps_scale1_in : in  std_logic_vector(SCALE_WIDTH);
        ps2_in       : in  std_logic_vector(OP1_WIDTH);
        ps_scale2_in : in  std_logic_vector(SCALE_WIDTH);
        fail_predict : out std_logic
    );
end component;

begin

    ram_h: ram_handler port map(
        RamCLK  => RamCLK,
        RamADVn => RamADVn,
        RamCEn  => RamCEn,
        RamCRE  => RamCRE,
        RamOEn  => RamOEn,
        RamWEn  => RamWEn,
        RamLBn  => RamLBn,
        RamUBn  => RamUBn,
        RamWait => RamWait,
        MemDB   => MemDB,
        MemAdr  => MemAdr,
        sel_ram => s_sel_ram,
        b_sel   => event,
        b_out   => s_b,
        b_we    => s_b_we
    );

    flash_h: flash_handler port map(
        QspiSCK   => QspiSCK,
        QspiDB    => QspiDB,
        QspiCSn   => QspiCSn,
        tp_out    => s_tp,
        tp_we     => s_tp_we,
        pi_out    => s_pi,
        pi_we     => s_pi_we,
        sel_flash => s_sel_flash,
        ready     => s_data_ready
    );

    s_b_we0 <= not(s_sel_ram) and s_b_we;
    s_b_we1 <= s_sel_ram and s_b_we;
    s_pi_we0 <= not(s_sel_flash) and s_pi_we;
    s_pi_we1 <= s_sel_flash and s_pi_we;
    s_tp_we0 <= not(s_sel_flash) and s_tp_we;
    s_tp_we1 <= s_sel_flash and s_tp_we;

    forward0: forward_s port map(
        clk          => clk,
        reset_n      => reset_n,
        b_in         => s_b,
        b_we         => s_b_we0,
        tp_in        => s_tp,
        tp_we        => s_tp_we0,
        pi_in        => s_pi,
        pi_we        => s_pi_we0,
        data_ready   => s_data_ready,
        ps_scale_out => s_ps_scale0,
        ps_out       => s_ps0
    );

    forward1: forward_s port map(
        clk          => clk,
        reset_n      => reset_n,
        b_in         => s_b,
        b_we         => s_b_we1,
        tp_in        => s_tp,
        tp_we        => s_tp_we1,
        pi_in        => s_pi,
        pi_we        => s_pi_we1,
        data_ready   => s_data_ready,
        ps_scale_out => s_ps_scale1,
        ps_out       => s_ps1
    );

    class: classification port map(
        ps1_in       => s_ps0,
        ps_scale1_in => s_ps_scale0,
        ps2_in       => s_ps1,
        ps_scale2_in => s_ps_scale1,
        fail_predict => fail_predict
    );

end predict;
