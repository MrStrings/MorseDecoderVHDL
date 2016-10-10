library ieee;
use ieee.std_logic_1164.all;

entity registrador is

	generic 
	(N : natural := 5);

	port 
	(	ser_in, reset, clk	 : in std_logic;
		par_out				 		 : buffer std_logic_vector (N-1 downto 0));

end entity;

architecture Behavior of registrador is
	begin
		process(clk, reset)
		begin
			
			-- Reset
			if (reset = '1') then
				par_out <= (others => '0');
				
			elsif (clk'event and clk = '1') then		
				-- Left shift
				shiftLeft: for i in 1 to N-1 loop
					par_out(i) <= par_out(i-1) ;
				end loop;
				par_out(0) <= ser_in;
		
			end if;
			
		end process;		
end Behavior;
