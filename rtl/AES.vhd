library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AES is
	generic (
        KEY_SIZE    : integer := 128;
        ROUND_COUNT : integer := 10
		  
    );
	 Port (
		  CLOCK_50      : in  std_logic;
		  rst      : in  std_logic;
		  start_enc: in  std_logic;
		  aes_enable : in std_logic;
		  plaintext  : in  std_logic_vector(127 downto 0);
		  key : in std_logic_vector(KEY_SIZE-1 downto 0);
		  encrypt_done,decrypt_done : out std_logic;
		  encrypt_decrypt : in std_logic;
		  sel_part    : in  std_logic_vector(1 downto 0);
		  HEX0_out, HEX1_out, HEX2_out, HEX3_out, HEX4_out, HEX5_out, HEX6_out, HEX7_out : out std_logic_vector(6 downto 0);
		  final_result : out std_logic_vector(127 downto 0)
	);
end AES;

architecture arch of AES is 
	signal internal_encrypt_done,internal_decrypt_done : std_logic;
   signal temp_result_encrypt,temp_result_decrypt : std_logic_vector(127 downto 0) :=(others => '0');
	signal temp_result : std_logic_vector(127 downto 0) :=(others => '0');
	signal result_encrypt : std_logic_vector(127 downto 0) :=(others => '0');
	signal clk_new : std_logic;
	signal hex_output : std_logic_vector(31 downto 0);

    function hex_decoder(hex_input : std_logic_vector(3 downto 0)) return std_logic_vector is
        variable segments : std_logic_vector(6 downto 0);
    begin
        case hex_input is
            when "0000" => segments := "1000000";  
            when "0001" => segments := "1111001"; 
            when "0010" => segments := "0100100"; 
            when "0011" => segments := "0110000"; 
            when "0100" => segments := "0011001"; 
            when "0101" => segments := "0010010"; 
            when "0110" => segments := "0000010";
            when "0111" => segments := "1111000"; 
            when "1000" => segments := "0000000"; 
            when "1001" => segments := "0011000"; 
            when "1010" => segments := "0001000"; 
            when "1011" => segments := "0000011"; 
            when "1100" => segments := "1000110"; 
            when "1101" => segments := "0100001"; 
            when "1110" => segments := "0000110"; 
            when others => segments := "0001110"; 
        end case;
        return segments;
    end function;
begin
   div_inst : entity work.div 
	port map (clk_old => CLOCK_50,enable=>aes_enable, clk_new => clk_new);
	cipher_inst : entity work.Cipher
	generic map(
		KEY_SIZE => KEY_SIZE,
		ROUND_COUNT => ROUND_COUNT
	)
	port map(
	clk 				=> clk_new,
	rst				=> rst,
	start_enc 		=> start_enc,
	plaintext 		=> plaintext,
	key 		 		=> key,
	done 		 		=> internal_encrypt_done,
	ciphertext1    => temp_result_encrypt(127 downto 96),
	ciphertext2		=>	temp_result_encrypt(95 downto 64),	
	ciphertext3	   => temp_result_encrypt(63 downto 32),
	ciphertext4    => temp_result_encrypt(31 downto 0)
	);
   process(clk_new,rst)
	begin
		if internal_encrypt_done = '1' then
			result_encrypt <= temp_result_encrypt;
		end if;
	end process;
	encrypt_done <= internal_encrypt_done;	
	
	invcipher_inst : entity work.InvCipher
	generic map(
		KEY_SIZE => KEY_SIZE,
		ROUND_COUNT => ROUND_COUNT
	)
	port map(
	clk    => clk_new,
	rst    => rst,
	start_dec => internal_encrypt_done,
	decrypt   => encrypt_decrypt,
	ciphertext => result_encrypt,
	key        => key,
	done       => decrypt_done,
	plaintext1 => temp_result_decrypt(127 downto 96),
	plaintext2 => temp_result_decrypt(95 downto 64),
	plaintext3 => temp_result_decrypt(63 downto 32),
	plaintext4 => temp_result_decrypt(31 downto 0)
	);
	
	with encrypt_decrypt select
			temp_result <= temp_result_encrypt when '0',
								 temp_result_decrypt when '1';
	final_result<=temp_result;

   with sel_part select
        hex_output <= temp_result(127 downto 96) when "00",
                      temp_result(95 downto 64) when "01",
                      temp_result(63 downto 32) when "10",
                      temp_result(31 downto 0) when others;
    HEX0_out <= hex_decoder(hex_output(3 downto 0));
    HEX1_out <= hex_decoder(hex_output(7 downto 4));
    HEX2_out <= hex_decoder(hex_output(11 downto 8));
    HEX3_out <= hex_decoder(hex_output(15 downto 12));
    HEX4_out <= hex_decoder(hex_output(19 downto 16));
    HEX5_out <= hex_decoder(hex_output(23 downto 20));
    HEX6_out <= hex_decoder(hex_output(27 downto 24));
    HEX7_out <= hex_decoder(hex_output(31 downto 28));
end arch;