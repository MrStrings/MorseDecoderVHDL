library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity memoria is
	generic(
		altura: integer := 9;
		comprimento: integer := 5;
		init_file: string := "char.mif"
	);
	port(
		WrEn, clk: in std_logic; 
		data: in std_logic_vector(comprimento - 1 downto 0);
		adr: in  integer range 0 to 2**altura-1;
		Q: out std_logic_vector(comprimento - 1 downto 0)
	);
end memoria;

architecture arc of memoria is
	type mem_type is array (0 to 2**altura - 1) of std_logic_vector(comprimento - 1 downto 0);
	signal mem: mem_type;
	attribute ram_init_file: string;
	attribute ram_init_file of mem: signal is init_file;
begin
	Q <= mem(adr);
	process(clk) begin
		if clk'event and clk = '1' then
			if WrEn = '1' then
				mem(adr) <= data;
			end if;
		end if;
	end process;
end arc;