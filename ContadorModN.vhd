LIBRARY ieee ;
USE ieee.std_logic_1164.all ;



ENTITY ContadorModN IS
	generic 
	(Module : natural := 2);

	
	PORT ( toLoad : IN INTEGER RANGE 0 TO Module-1 ;
		   Clock, Resetn, Load, Enable : IN STD_LOGIC ;
		   Counter : BUFFER INTEGER RANGE 0 TO Module-1;
		   carry_out :BUFFER STD_LOGIC) ;
END ContadorModN ;
	



	
ARCHITECTURE Behavior OF ContadorModN IS
BEGIN
	PROCESS ( Clock, Resetn )
	BEGIN
		if Enable = '1' then
			IF Resetn = '1' THEN
				Counter <= 0 ;
				carry_out <= '0';
			ELSIF (Clock'EVENT AND Clock = '1') THEN
				IF Load = '1' THEN
					Counter <= toLoad ;
				ELSIF Counter = Module - 1 THEN
					Counter <= 0;
					carry_out <= '1';
				ELSE
					Counter <= Counter + 1 ;
				END IF;
			END IF;
		end if;
	END PROCESS;
END Behavior;
