library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AES_with_UART is
	generic (
        KEY_SIZE    : integer := 192;
        ROUND_COUNT : integer := 12;
		  g_CLKS_PER_BIT : integer := 434
    );
	 Port (
		  i_RX_Serial : in  std_logic;
		  i_Reset : in std_logic;
		  ready_loading : out std_logic;
		  o_TX_Serial       : out std_logic;
		  o_TX_Serial_two       : out std_logic;
		  CLOCK_50      : in  std_logic;
		  rst      : in  std_logic;
		  start_enc: in  std_logic;
		  aes_enable : in std_logic;
		  encrypt_decrypt : in std_logic;
		  encrypt_done : out std_logic;
		  decrypt_done : out std_logic;
		  sel_part    : in  std_logic_vector(1 downto 0);
		  HEX0_out, HEX1_out, HEX2_out, HEX3_out, HEX4_out, HEX5_out, HEX6_out, HEX7_out : out std_logic_vector(6 downto 0);
		  final_result : out std_logic_vector(127 downto 0)
	);
end AES_with_UART;

architecture arch of AES_with_UART is 
	signal internal_encrypt_done,internal_decrypt_done : std_logic;
	signal plaintext_loaded,plaintext : std_logic_vector(127 downto 0);
	signal key_loaded : std_logic_vector(KEY_SIZE-1 downto 0);
	signal temp_result : std_logic_vector(127 downto 0) :=(others => '0');
	signal done : std_logic;
begin
	UART_Inputs_inst: entity work.UART_Inputs
	generic map(g_CLKS_PER_BIT => g_CLKS_PER_BIT,g_AES_KEY_LENGTH=>KEY_SIZE)
	port map(
		CLOCK_50        => CLOCK_50,
		i_Reset         => i_Reset,
	   i_RX_Serial     => i_RX_Serial,   
		o_TX_Serial     => o_TX_Serial,
	   loading_ready   => ready_loading,
	   plaintext       => plaintext_loaded,
		key             => key_loaded
	);
	plaintext <= plaintext_loaded when start_enc='1' else (others=>'0');
	AES_inst : entity work.AES
	generic map(
		KEY_SIZE => KEY_SIZE,
		ROUND_COUNT => ROUND_COUNT
	)
	port map(
		  CLOCK_50 => CLOCK_50,
		  rst      => rst,
		  start_enc=>start_enc,
		  aes_enable=>aes_enable,
		  plaintext => plaintext,
		  key =>key_loaded,
		  encrypt_done=>internal_encrypt_done,
		  decrypt_done=>internal_decrypt_done,
		  encrypt_decrypt=> encrypt_decrypt,
		  sel_part    =>sel_part,
		  HEX0_out=>HEX0_out, 
		  HEX1_out=>HEX1_out, 
		  HEX2_out=>HEX2_out, 
		  HEX3_out=>HEX3_out, 
		  HEX4_out=>HEX4_out, 
		  HEX5_out=>HEX5_out, 
		  HEX6_out=>HEX6_out, 
		  HEX7_out=>HEX7_out,
		  final_result =>temp_result
	);
	done <= internal_encrypt_done or internal_decrypt_done;
	UART_Output_inst: entity work.UART_Output
	port map (
        CLOCK_50     => CLOCK_50,
        start_send   => done,
		  message 		=> temp_result,
        o_TX_Serial  => o_TX_Serial_two
    );
	 final_result<=temp_result;
	 encrypt_done<=internal_encrypt_done;
	 decrypt_done<=internal_decrypt_done; 
end arch;