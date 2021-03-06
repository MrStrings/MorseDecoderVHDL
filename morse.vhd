library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity morse is
	generic(
		LIMITE_TAM_LETRA : integer := 5
	);
	port
	(
		-- Input ports
		clock_fpga, pushButton, apagar: in  std_logic;
		-- Output ports
		red, green, blue          : out std_logic_vector(3 downto 0);
		hsync, vsync              : out std_logic;
		letra					  : out std_logic_vector(5 downto 0);	
		letraPronta				  : buffer std_logic;
		trigger1, trigger2		  : out std_logic
	);
end morse;


architecture arq of morse is

	component LeitorSinal
		GENERIC
		(DAH_TIME_MILISEC : natural := 500;
		 CLOCK_PERIOD_MILISEC : natural := 27000);
		
		PORT (
			   pushButton, clock: IN STD_LOGIC ;
			   reading: OUT STD_LOGIC;
			   codigo: BUFFER STD_LOGIC
			  );
	end component;
	
	component interpretador
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
			letra		: out std_logic_vector(5 downto 0);	
			ok 			: out std_logic
		);
	end component;
	
	component controladorTamanho
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
	end component;
	
	component controladorTempo
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
	end component;
	
	component characterDisplayer is
	
		 generic (
			CHAR_ALTURA: integer := 7;
			CHAR_COMPRIMENTO: integer := 5;
			TEMPO : integer := 2700000);
			
		  port (
			clk27M, reset_button, triggerUpdate     : in  std_logic;
			letterCode 				  : in std_logic_vector(5 downto 0);  
			red, green, blue          : out std_logic_vector(3 downto 0);
			hsync, vsync              : out std_logic);
		
	end component;

	signal sinalLido, aviso, triggerF: std_logic;
	signal letra_aux 	: std_logic_vector(5 downto 0);
	signal letraPronta_aux  : std_logic;
	signal letraTam : std_logic_vector(2 downto 0);
	signal trigger_aux1, trigger_aux2 : std_logic := '0';

begin

	-- Retirar saida teste do controladorTempo

	triggerF <= trigger_aux2 or trigger_aux1;

	-- Instancia Leitor de Sinal
	inst_leitorSinal:
	LeitorSinal port map(pushButton => pushButton, clock => clock_fpga, reading => aviso, codigo => sinalLido);
	
	-- Instancia do interpretador
	inst_inter:
	interpretador port map(clk_FPGA => clock_fpga, clk => aviso, sinal => sinalLido, trigger => triggerF, letra => letra_aux, ok => letraPronta_aux);
	
	-- Instancia do contador do tempo da palavra
	inst_contTempo:
	controladorTempo port map(clk => clock_fpga, pushButton => pushButton, tamLetra => letraTam, trigger => trigger_aux1);
	
	-- Instancia do contador do tempo da palavra
	inst_contTam:
	controladorTamanho port map(reset => triggerF, clk => not aviso, trigger => trigger_aux2, tamLetra => letraTam);
	
	-- Exibe a letra na tela
	inst_displayer:
	characterDisplayer port map(clk27M => clock_fpga, reset_button => not apagar, triggerUpdate => letraPronta_aux, letterCode => letra_aux, red => red, green => green, blue => blue, hsync => hsync, vsync => vsync);

	letra <= letra_aux;
	letraPronta <= letraPronta_aux;
	trigger1 <= trigger_aux1;
	trigger2 <= trigger_aux2;
end arq;
