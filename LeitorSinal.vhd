LIBRARY ieee ;
USE ieee.std_logic_1164.all ;



ENTITY LeitorSinal IS
	
	GENERIC
	(DAH_TIME_MILISEC : natural := 500;
	 CLOCK_PERIOD_MILISEC : natural := 27000);
	
	
	PORT (
		   pushButton, clock: IN STD_LOGIC ;
		   reading: OUT STD_LOGIC;
		   codigo: BUFFER STD_LOGIC
		  );
END LeitorSinal ;
	



	
ARCHITECTURE Behavior OF LeitorSinal IS
	
	Component ContadorModN IS
		generic 
			 ( Module : natural := 2);
			
		PORT ( toLoad : IN INTEGER RANGE 0 TO Module-1 ;
			   Clock, Resetn, Load, Enable : IN STD_LOGIC ;
			   Counter : BUFFER INTEGER RANGE 0 TO Module-1;
			   carry_out :OUT STD_LOGIC) ;
	END Component ;

	signal counter 			: INTEGER RANGE 0 TO DAH_TIME_MILISEC*CLOCK_PERIOD_MILISEC-1;
	signal codigo_aux 		: STD_LOGIC;

	BEGIN

		-- Diz se esta lendo o sinal
		with PushButton select
		Reading <= '1' when '0',
				   '0' when others;
		
		-- Contador de 500 ms
		cont:
		ContadorModN generic map (Module => CLOCK_PERIOD_MILISEC * DAH_TIME_MILISEC) 
					 port map (toLoad => counter, Clock => clock, Resetn => pushButton, Load => '0', Enable => '1', Counter => counter, carry_out => codigo_aux);
		
		-- Registra o codigo de saida - dih ou dah. Eh ativado quando o contador em milisegundos da overflow e desativado quando inicializa a leitura do proximo sinal.
		process (clock)
		begin
			if (pushButton = '0') then
				codigo <= codigo_aux;
			end if;
		end process;
		
		
END Behavior;
