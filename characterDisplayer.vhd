library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity characterDisplayer is
  generic (
	CHAR_ALTURA: integer := 7;
	CHAR_COMPRIMENTO: integer := 5;
	TEMPO : integer := 2700000);
	
  port (
    clk27M, reset_button, triggerUpdate     : in  std_logic;
    letterCode 				  : in std_logic_vector(5 downto 0);  
    red, green, blue          : out std_logic_vector(3 downto 0);
    hsync, vsync              : out std_logic);
end characterDisplayer;

architecture comportamento of characterDisplayer is

	component memoria is
		generic(
			altura: integer := 9;
			comprimento: integer := 5;
			init_file: string := "charE.mif"
		);
		port(
			WrEn, clk: in std_logic; 
			data: in std_logic_vector(comprimento - 1 downto 0);
			adr: in  integer range 0 to 2**altura-1;
			Q: out std_logic_vector(comprimento - 1 downto 0)
		);
	end component;
	
	component ContadorModN is
		generic
		(Module : natural := 2);
		PORT ( toLoad : IN INTEGER RANGE 0 TO Module-1 ;
			   Clock, Resetn, Load, Enable : IN STD_LOGIC ;
			   Counter : BUFFER INTEGER RANGE 0 TO Module-1;
			   carry_out :BUFFER STD_LOGIC) ;
	end component;
	  
	-- variaveis contador
	signal counter : integer range 0 TO TEMPO-1;
	signal contou, counter_en, counter_reset : std_logic;

  signal write_enable : std_logic;

  -- Interface com a mem�ria de v�deo do controlador
  signal addr : integer range 0 to 12287;       -- endereco mem. vga
  signal pixel : std_logic_vector(2 downto 0);  -- valor de cor do pixel
  signal pixel_bit : std_logic;                 -- um bit do vetor acima

  -- Sinais dos contadores de linhas e colunas utilizados para percorrer
  -- as posi��es da mem�ria de v�deo (pixels) no momento de construir um quadro.
  signal line : integer range 0 to CHAR_ALTURA;  
  signal col : integer range 0 to CHAR_COMPRIMENTO;

  -- flag que indica o fim da escrita
  signal fim_escrita : std_logic;

  -- conversao do codigo binario da letra pra inteiro
  signal char_code : integer range 0 to 36;
  
  -- auxiliar para instanciacao de memoria
  signal Q_aux : std_logic_vector(4 downto 0);
  
  -- CONTADOR DE LETRAS IMPRESSAS
  signal cont_letras_hor : integer range 0 to 17;
  signal cont_letras_ver : integer range 0 to 95;
  -- declaracao da maquina de estados
  type fsm is (ESPERA, ESCRITA, E_FIM_ESCRITA, CONTA);
  signal estado : fsm := ESPERA;
  
  -- apagar
  signal flagApagar : std_logic;
  signal codigo_branco : std_logic_vector(5 downto 0) := "100101"; 

begin

  -----------------------------------------------------------------------------
     -- Instancia da tela, 128x96
  -----------------------------------------------------------------------------
  vga_controller: entity work.vgacon port map (
    clk27M       => clk27M,
    rstn         => '1',
    red          => red,
    green        => green,
    blue         => blue,
    hsync        => hsync,
    vsync        => vsync,
    write_clk    => clk27M,
    write_enable => write_enable,
    write_addr   => addr,
    data_in      => pixel);

  ------------------------------------------------------------------------------
     -- Maquina de estados.
  ------------------------------------------------------------------------------
  
  maquina_estados:
  process(clk27M) begin
	if clk27M'event and clk27M = '1' then
		case estado is
			when ESPERA =>
				counter_en <= '0';
				write_enable <= '0';
				if reset_button = '1' then
					flagApagar <= '1';
					cont_letras_hor <= cont_letras_hor - 1;
					estado <= ESCRITA;
				elsif (triggerUpdate) = '1' then
					estado <= ESCRITA;
				else
					estado <= ESPERA;
				end if;
			when ESCRITA =>
				counter_en <= '0';
				write_enable <= '1';
				if fim_escrita = '1' then
					estado <= E_FIM_ESCRITA;
				else
					estado <= ESCRITA;
				end if;
			when E_FIM_ESCRITA =>
				write_enable <= '0';
				counter_en <= '0';
				if flagApagar /= '1' then
					if cont_letras_hor = 17 then
						cont_letras_hor <= 0;
						cont_letras_ver <= cont_letras_ver + 9;
					else
						cont_letras_hor <= cont_letras_hor + 1;
					end if;
				else
					flagApagar <= '0';
				end if;
				estado <= CONTA;
			when CONTA =>
				counter_reset <= '0';
				counter_en <= '1';
				if contou = '1' then
					estado <= ESPERA;
					counter_reset <= '1';
				else
					estado <= CONTA;
				end if;
		end case;
    end if;
  end process;
  
  -----------------------------------------------------------------------------
     -- Percorre pixels da tela
  -----------------------------------------------------------------------------
  
  -- purpose: Este processo conta o n�mero da coluna atual, quando habilitado pelo sinal "col_enable".
  conta_coluna: process (clk27M)
  begin  
    if write_enable = '0' then               
      col <= 0;
    elsif clk27M'event and clk27M = '1' then  
       if col = CHAR_COMPRIMENTO then               
         col <= 0;
       else
         col <= col + 1;  
       end if;
	end if;
  end process conta_coluna;
    
  -- purpose: Este processo conta o n�mero da linha atual, quando habilitado pelo sinal "line_enable".
  conta_linha: process (clk27M)
  begin  
    if write_enable = '0' then                 
      line <= 0;
    elsif clk27M'event and clk27M = '1' then
      -- o contador de linha s� incrementa quando o contador de colunas
      -- chegou ao fim (valor 127)
      if col = CHAR_COMPRIMENTO then
        if line = CHAR_ALTURA - 1 then
          line <= 0;
        else
          line <= line + 1;  
        end if;        
      end if;
    end if;
  end process conta_linha;
  
  fim_escrita <= '1' when (line = CHAR_ALTURA - 1) and (col = CHAR_COMPRIMENTO) else '0'; 
  
  -- O endere�o de mem�ria pode ser constru�do com essa f�rmula simples,
  -- a partir da linha e coluna atual
  addr  <=  cont_letras_ver * 128 + cont_letras_hor * 7  + col + (128 * line);
  
  
  ------------------------------------------------------------------------------------------------------------
  ---------------------------------- Codificacao das letras --------------------------------------------------
  ------------------------------------------------------------------------------------------------------------
  
	char_code <= to_integer(unsigned(letterCode)) when flagApagar = '0' else to_integer(unsigned(codigo_branco));

	mifAcess: 
	memoria port map (
		WrEn => '0',
		clk => clk27M,
		data => (others => '0'),
		adr => line + 7*char_code,
		Q => Q_aux
	);  
  
	pixel_bit <= Q_aux(CHAR_COMPRIMENTO-1 - col) when CHAR_COMPRIMENTO-1-col > -1 else '0';
	pixel <= (others => pixel_bit);
	
	-------------------------------  CONTADOR  -----------------------
	
	contador:
	ContadorModN generic map (Module => TEMPO)
				 port map (toLoad => counter, Clock => clk27M, Resetn => counter_reset, Load => '0', Enable => counter_en, Counter => counter, carry_out => contou);
  
end comportamento;