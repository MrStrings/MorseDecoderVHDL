LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
use ieee.numeric_std.all;

entity controladorTamanho is
	generic
	(
		LIMITE_TAM_LETRA	: integer  := 5
	);
	port
	(
		-- Input ports
		reset, clk	: in  std_logic;
		
		-- Output ports
		trigger	: out std_logic;
		tamLetra : out std_logic_vector(2 downto 0)
	);
end controladorTamanho;

architecture arq of controladorTamanho is

	component ContadorModN

		generic 
		(Module : natural := 2);

		
		PORT ( toLoad : IN INTEGER RANGE 0 TO Module-1 ;
			   Clock, Resetn, Load, Enable : IN STD_LOGIC ;
			   Counter : BUFFER INTEGER RANGE 0 TO Module-1;
			   carry_out :OUT STD_LOGIC) ;

	end component;
	
	signal contador : integer range 0 to LIMITE_TAM_LETRA-1;

begin

	tamLetra <= std_logic_vector(to_unsigned(contador, tamLetra'length));

	inst_cont:
	ContadorModN generic map(Module => LIMITE_TAM_LETRA)
				 port map (toLoad => contador, Clock => clk, Resetn => reset, Load => '0', Enable => '1', Counter => contador, carry_out => trigger);
				 
end arq;

