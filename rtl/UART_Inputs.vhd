library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_Inputs is
  generic (
    g_CLKS_PER_BIT   : integer := 434;
    g_AES_KEY_LENGTH : integer := 128  
  );
  port (
    CLOCK_50      : in  std_logic;
    i_Reset       : in  std_logic; 
    i_RX_Serial   : in  std_logic;
    o_TX_Serial   : out std_logic;
    loading_ready : out std_logic;
    plaintext     : out std_logic_vector(127 downto 0);
    key           : out std_logic_vector(g_AES_KEY_LENGTH-1 downto 0)
  );
end UART_Inputs;

architecture Behavioral of UART_Inputs is
  signal r_RX_DV      : std_logic;
  signal r_RX_Byte    : std_logic_vector(7 downto 0);
  signal r_TX_DV      : std_logic := '0';
  signal r_TX_Byte    : std_logic_vector(7 downto 0);
  signal r_TX_Done    : std_logic;
  signal r_TX_Active  : std_logic;
  type t_prompt_array is array(natural range <>) of std_logic_vector(7 downto 0);
  constant PROMPT_PT : t_prompt_array := (
		  x"0A", x"0D",  
		 x"47", x"69", x"76", x"65", x"20", x"6D", x"65", x"20",
		 x"79", x"6F", x"75", x"72", x"20", x"70", x"6C", x"61",
		 x"69", x"6E", x"74", x"65", x"78", x"74", x"3A", x"20"
		);
  constant PROMPT_KEY : t_prompt_array := (
		 x"0A", x"0D", x"0A", x"0D",  
		 x"47", x"69", x"76", x"65", x"20", x"6D", x"65", x"20",
		 x"79", x"6F", x"75", x"72", x"20", x"70", x"72", x"69",
		 x"76", x"61", x"74", x"65", x"20", x"6B", x"65", x"79",
		 x"3A", x"20"
	);
  type t_state is (IDLE, SEND_PT_MSG, GET_PT, SEND_KEY_MSG, GET_KEY, DONE);  
  signal r_state       : t_state := IDLE;
  signal r_pt_buf      : std_logic_vector(127 downto 0) := (others => '0');
  signal r_key_buf     : std_logic_vector(255 downto 0) := (others => '0');
  constant key_bytes     : integer := g_AES_KEY_LENGTH/8;
  signal byte_counter   : integer range 0 to 30 := 0;
  signal r_byte_count_plaintext  : integer range 0 to 16 := 0;
  signal r_byte_count_key        : integer range 0 to g_AES_KEY_LENGTH/8 := 0;
  signal sending        : std_logic := '0';
  signal start_send_prev : std_logic := '0';
  signal start_send_edge : std_logic := '0';
  signal start_send : std_logic := '0';
  signal ready_loading : std_logic := '0';
begin
  UART_RX_inst : entity work.UART_RX
    generic map (
      g_CLKS_PER_BIT => g_CLKS_PER_BIT
    )
    port map (
      CLOCK_50    => CLOCK_50,
      i_RX_Serial => i_RX_Serial,
      o_RX_DV     => r_RX_DV,
      o_RX_Byte   => r_RX_Byte
    );
    
  UART_TX_inst : entity work.UART_TX
    generic map (
      g_CLKS_PER_BIT => g_CLKS_PER_BIT
    )
    port map (
      CLOCK_50    => CLOCK_50,
      i_TX_DV     => r_TX_DV,
      data_in     => r_TX_Byte,
      o_TX_Active => r_TX_Active,
      o_TX_Serial => o_TX_Serial,
      o_TX_Done   => r_TX_Done
    );
  process(CLOCK_50)
  begin
    if rising_edge(CLOCK_50) then
      if i_Reset = '1' then
        r_state <= IDLE;
        r_pt_buf <= (others => '0');
        r_key_buf <= (others => '0');
        r_byte_count_plaintext <= 0;
        r_byte_count_key <= 0;
        byte_counter <= 0;
        sending <= '0';
        start_send <= '0';
        start_send_prev <= '0';
        start_send_edge <= '0';
        ready_loading <= '0';
        r_TX_DV <= '0';
        r_TX_Byte <= (others => '0');
      else
        r_TX_DV <= '0';
        ready_loading <= '0';
        case r_state is
          when IDLE =>
            start_send <= '1';
            r_state <= SEND_PT_MSG;
            
          when SEND_PT_MSG =>
            start_send_edge <= '0';
            if start_send = '1' and start_send_prev = '0' then
              start_send_edge <= '1';
            end if;
            start_send_prev <= start_send;
            
            if start_send_edge = '1' and sending = '0' then
              byte_counter <= 0;
              sending <= '1';
            elsif sending = '1' then
              if r_TX_DV = '0' and r_TX_Active = '0' and byte_counter < PROMPT_PT'length then
                r_TX_Byte <= PROMPT_PT(byte_counter);
                r_TX_DV <= '1';
              elsif r_TX_DV = '1' then
                r_TX_DV <= '0';  
              elsif r_TX_Done = '1' then
                byte_counter <= byte_counter + 1;
                if byte_counter = PROMPT_PT'length - 1 then
                  sending <= '0';
                  start_send <= '0';
                  start_send_prev <= '0';
                  start_send_edge <= '0';
                  r_state <= GET_PT;
                end if;
              end if;	 
            end if; 
          when GET_PT =>
            if r_RX_DV = '1' then
              r_TX_Byte <= r_RX_Byte;
              r_TX_DV <= '1';
            end if;
            if r_RX_DV = '1' and r_byte_count_plaintext < 16 then
              r_pt_buf(127 - r_byte_count_plaintext*8 downto 120 - r_byte_count_plaintext*8) <= r_RX_Byte;
              r_byte_count_plaintext <= r_byte_count_plaintext + 1;
              if r_byte_count_plaintext = 15 then
                start_send <= '1';
                r_state <= SEND_KEY_MSG;
              end if;
            end if;  
          when SEND_KEY_MSG =>
            start_send_edge <= '0';
            if start_send = '1' and start_send_prev = '0' then
              start_send_edge <= '1';
            end if;
            start_send_prev <= start_send;
            if start_send_edge = '1' and sending = '0' then
              byte_counter <= 0;
              sending <= '1';
            elsif sending = '1' then
              if r_TX_DV = '0' and r_TX_Active = '0' and byte_counter < PROMPT_KEY'length then
                r_TX_Byte <= PROMPT_KEY(byte_counter);
                r_TX_DV <= '1';
              elsif r_TX_DV = '1' then
                r_TX_DV <= '0';  
              elsif r_TX_Done = '1' then
                byte_counter <= byte_counter + 1;
                if byte_counter = PROMPT_KEY'length - 1 then
                  sending <= '0';
                  r_state <= GET_KEY;
                end if;
              end if;
            end if;  
          when GET_KEY =>
            if r_RX_DV = '1' then
              r_TX_Byte <= r_RX_Byte;
              r_TX_DV <= '1';
            end if;
            if r_RX_DV = '1' and r_byte_count_key < key_bytes then
              r_key_buf(255 - r_byte_count_key*8 downto 248 - r_byte_count_key*8) <= r_RX_Byte;
              r_byte_count_key <= r_byte_count_key + 1;
              if r_byte_count_key = key_bytes - 1 then
                r_state <= DONE;
              end if;
            end if; 
          when DONE =>
            ready_loading <= '1';
            if r_TX_DV = '1' then
              r_TX_DV <= '0';
            end if;    
        end case;
      end if;
    end if;
  end process;
  plaintext <= r_pt_buf;
  gen_key_slice: if g_AES_KEY_LENGTH = 128 generate
    key <= r_key_buf(255 downto 128);
  end generate;
  gen_key_slice_192: if g_AES_KEY_LENGTH = 192 generate
    key <= r_key_buf(255 downto 64);
  end generate;
  gen_key_slice_256: if g_AES_KEY_LENGTH = 256 generate
    key <= r_key_buf(255 downto 0);
  end generate;
  loading_ready <= ready_loading;
end Behavioral;
