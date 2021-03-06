library ieee;
use ieee.std_logic_1164.all;

entity interpretador is
	generic
	(
		TAM_LETRA	: integer  := 5;
		TEMPO 		: integer  := 2700000 
	);
	port
	(
		-- Input ports
		clk_FPGA, clk, sinal, trigger	: in  std_logic;
		
		-- Output ports
		letra			: out std_logic_vector(5 downto 0);		
		ok 				: out std_logic
	);
end interpretador;

architecture arq of interpretador is

	component registrador
		generic 
		(N : natural := 5);
		port 
		(	ser_in, reset, clk	 : in std_logic;
			par_out				 : buffer std_logic_vector (N-1 downto 0));
	end component;
	
	component ContadorModN

		generic 
		(Module : natural := 2);

		
		PORT ( toLoad : IN INTEGER RANGE 0 TO Module-1 ;
			   Clock, Resetn, Load, Enable : IN STD_LOGIC ;
			   Counter : BUFFER INTEGER RANGE 0 TO Module-1;
			   carry_out :OUT STD_LOGIC) ;

	end component;
	
	-- saida dos registradores
	signal regSinal, regTam : std_logic_vector(TAM_LETRA-1 downto 0);
	-- codigo da letra formada
	signal saida : std_logic_vector(5 downto 0);
	
	-- variaveis do contador
	signal counter : integer range 0 to TEMPO-1;
	signal contou, counter_en : std_logic;
	type fsm is (NAO_CONTANDO, CONTANDO);
	signal estado : fsm := NAO_CONTANDO;
	
begin

	letra <= saida;
	ok <= counter_en;

	--------------- CONTADOR ------------------------------------

	contador:
	ContadorModN generic map (Module => TEMPO)
				 port map (toLoad => counter, Clock => clk_FPGA, Resetn => contou, Load => '0', Enable => counter_en, Counter => counter, carry_out => contou);

	process(trigger) begin
		case estado is
			when CONTANDO =>
				counter_en <= '1';
				if contou = '1' then
					estado <= NAO_CONTANDO;
				else
					estado <= CONTANDO;
				end if;
			when NAO_CONTANDO =>
				counter_en <= '0';
				if trigger = '1' then
					estado <= CONTANDO;
				else
					estado <= NAO_CONTANDO;
				end if;
		end case;
	end process;

	--------------- REGISTRADORES -------------------------------

	inst_regSinal: 
	registrador 
		generic map(
			N => TAM_LETRA
		)
		port map (
			ser_in => sinal,
			reset => contou,
			clk => not clk,
			par_out => regSinal
		);
		
	inst_regTam: 
	registrador 
		generic map(
			N => TAM_LETRA
		)
		port map (
			ser_in => '1',
			reset => contou,
			clk => not clk,
			par_out => regTam
		);
		
	process(regTam)
	begin
		case regTam is
			when "00001" =>
				case regSinal is
					when "00000" =>
						saida <= "000100"; -- E
					when "00001" =>
						saida <= "010011"; -- T
					when others =>
						saida <= (others => 'Z');
				end case;
			when "00011" =>
				case regSinal is
					when "00000" =>
						saida <= "001000"; -- I
					when "00001" =>
						saida <= "000000"; -- A
					when "00010" =>
						saida <= "001101"; -- N
					when "00011" =>
						saida <= "001100"; -- M
					when others =>
						saida <= (others => 'Z');
				end case;
			when "00111" =>
				case regSinal is
					when "00000" =>
						saida <= "010010"; -- S
					when "00001" =>
						saida <= "010100"; -- U
					when "00010" =>
						saida <= "010001"; -- R
					when "00011" =>
						saida <= "010110"; -- W
					when "00100" =>
						saida <= "000011"; -- D
					when "00101" =>
						saida <= "001010"; -- K
					when "00110" =>
						saida <= "000110"; -- G
					when "00111" =>
						saida <= "001110"; -- O
					when others =>
						saida <= (others => 'Z');
				end case;
			when "01111" =>
				case regSinal is
					when "01000" =>
						saida <= "000001"; -- B
					when "01010" =>
						saida <= "000010"; -- C
					when "00110" =>
						saida <= "001111"; -- P
					when "01101" =>
						saida <= "010000"; -- Q
					when "00010" =>
						saida <= "000101"; -- F
					when "00000" =>
						saida <= "000111"; -- H
					when "00001" =>
						saida <= "010101"; -- V
					when "00111" =>
						saida <= "001001"; -- J
					when "01001" =>
						saida <= "010111"; -- X
					when "00100" =>
						saida <= "001011"; -- L
					when "01011" =>
						saida <= "011000"; -- Y
					when "01100" =>
						saida <= "011001"; -- Z
					when "01111" =>
						saida <= "100101"; -- ESPACO
					when others =>
						saida <= "100100"; -- ERRO
				end case;
			when "11111" =>
				case regSinal is
					when "01111" =>
						saida <= "011010"; -- 1 
					when "00111" =>
						saida <= "011011"; -- 2 
					when "00011" =>
						saida <= "011100"; -- 3
					when "00001" =>
						saida <= "011101"; -- 4 
					when "00000" =>
						saida <= "011110"; -- 5
					when "10000" =>
						saida <= "011111"; -- 6
					when "11000" =>
						saida <= "100000"; -- 7
					when "11100" =>
						saida <= "100001"; -- 8
					when "11110" =>
						saida <= "100010"; -- 9
					when "11111" =>
						saida <= "100011"; -- 0
					when others =>
						saida <= "100100"; -- ERRO
				end case;
			when others =>
				saida <= (others => 'Z');
		end case;
	end process;
	
end arq;
