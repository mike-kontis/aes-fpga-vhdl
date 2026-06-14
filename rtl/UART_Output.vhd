library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_Output is
    Port (
        CLOCK_50    : in  std_logic;
        start_send  : in  std_logic;
        message     : in  std_logic_vector(127 downto 0);
        o_TX_Serial : out std_logic
    );
end UART_Output;

architecture Behavioral of UART_Output is
    component UART_TX
        Port (
            CLOCK_50     : in  std_logic;
            i_Tx_DV     : in  std_logic;
            data_in   : in  std_logic_vector(7 downto 0);
            o_Tx_Active : out std_logic;
            o_Tx_Serial : out std_logic;
            o_Tx_Done   : out std_logic
        );
    end component;
    signal tx_byte        : std_logic_vector(7 downto 0);
    signal tx_dv          : std_logic := '0';
    signal tx_done        : std_logic;
    signal tx_active      : std_logic;
    signal byte_counter   : integer range 0 to 16 := 0;
    signal sending        : std_logic := '0';
    signal start_send_prev : std_logic := '0';
    signal start_send_edge : std_logic := '0';
begin
    uart_tx_inst : UART_TX
        port map (
            CLOCK_50     => CLOCK_50,
            i_Tx_DV     => tx_dv,
            data_in     => tx_byte,
            o_Tx_Active => tx_active,
            o_Tx_Serial => o_TX_Serial,
            o_Tx_Done   => tx_done
        );
    process (CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            start_send_edge <= '0';
            if start_send = '1' and start_send_prev = '0' then
                start_send_edge <= '1';
            end if;
            start_send_prev <= start_send;
            if start_send_edge = '1' and sending = '0' then
                byte_counter <= 0;
                sending <= '1';
            elsif sending = '1' then
                if tx_dv = '0' and tx_active = '0' and byte_counter < 16 then
                    tx_byte <= message(127 - byte_counter*8 downto 120 - byte_counter*8);
                    tx_dv <= '1';
                elsif tx_dv = '1' then
                    tx_dv <= '0'; 
                elsif tx_done = '1' then
                    byte_counter <= byte_counter + 1;
                    if byte_counter = 15 then
                        sending <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
