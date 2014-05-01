library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity acc_N is
	-- N = 3
	port(	
		in11:in std_logic_vector(3 downto 0);
		in12:in std_logic_vector(3 downto 0);
		in21:in std_logic_vector(3 downto 0);
		in22:in std_logic_vector(3 downto 0);
		in31:in std_logic_vector(3 downto 0);
		in32:in std_logic_vector(3 downto 0);
		res: out std_logic_vector(7 downto 0)
	);
end acc_N;

architecture acc_N_arch of acc_N is
signal acc1_s: std_logic_vector(7 downto 0);
signal acc2_s: std_logic_vector(7 downto 0);
begin
	for i in 0 to 2 loop

	end loop;
    acc1_s <= in11 * in12;
    acc2_s <= in21 * in22;
    res <= acc1_s + acc2_s;
end acc_N_arch;
