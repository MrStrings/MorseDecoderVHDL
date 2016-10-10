LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

entity controladorTempo is
	generic
	(
		LIMITE_CONTADOR	: integer  := 27000000;
		LIMITE_TAM_LETRA : integer := 5
	);
	port
	(
		-- Input ports
		clk, pushButton : in  std_logic;
		tamLetra : in std_logic_vector(2 downto 0);
		-- Output ports
		trigger	: out std_logic
	);
end controladorTempo;

architecture arq of controladorTempo is

	component ContadorModN

		generic 
		(Module : natural := 2);

		
		PORT ( toLoad : IN INTEGER RANGE 0 TO Module-1 ;
			   Clock, Resetn, Load, Enable : IN STD_LOGIC ;
			   Counter : BUFFER INTEGER RANGE 0 TO Module-1;
			   carry_out :OUT STD_LOGIC);

	end component;

	signal contador : integer range 0 to LIMITE_CONTADOR-1;
	signal cont_reset : std_logic;
	signal naoComecouEscrever : std_logic;

begin
	
	naoComecouEscrever <= '1' when tamLetra = "000" else '0';
	cont_reset <= (not pushButton) or naoComecouEscrever;

	inst_cont:
	ContadorModN generic map(Module => LIMITE_CONTADOR)
				 port map (toLoad => contador, Clock => clk, Resetn => cont_reset, Load => '0', Enable => '1', Counter => contador, carry_out => trigger);

end arq;

