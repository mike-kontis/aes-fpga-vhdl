library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Cipher is
	generic ( 
		KEY_SIZE    : integer := 128;  
		ROUND_COUNT : integer := 10 
	);
	port(
		clk,rst,start_enc    : in  std_logic;
		plaintext  				: in  std_logic_vector(127 downto 0);
		key 						: in std_logic_vector(KEY_SIZE-1 downto 0);
		done 						: out std_logic;
		ciphertext1 			: out std_logic_vector(31 downto 0);
		ciphertext2				: out std_logic_vector(31 downto 0);
		ciphertext3				: out std_logic_vector(31 downto 0);
		ciphertext4				: out std_logic_vector(31 downto 0)
	);
end Cipher;

architecture arch of Cipher is 
	signal reg_encrypt_input : std_logic_vector(127 downto 0) := (others => '0');
	signal reg_encrypt_output : std_logic_vector(127 downto 0) := (others => '0');
	signal subbytes_input : std_logic_vector(127 downto 0) := (others => '0');
	signal subbytes_output : std_logic_vector(127 downto 0) := (others => '0');
	signal shiftrows_output : std_logic_vector(127 downto 0) := (others => '0');
	signal mixcol_output : std_logic_vector(127 downto 0) := (others => '0');
	signal feedback_encrypt : std_logic_vector(127 downto 0) := (others => '0');
	signal round_key_encrypt : std_logic_vector(127 downto 0) := (others => '0');
	signal sel_encrypt : std_logic;
	signal result_encrypt : std_logic_vector(127 downto 0) := (others => '0');
begin
	reg_encrypt_input <= plaintext when start_enc = '1' else feedback_encrypt;
	reg_encrypt_inst : entity work.Reg 
		port map(
			D_IN   => reg_encrypt_input,
			CLK => clk,
			RST => rst,
			D_OUT   => reg_encrypt_output
		);
		add_round_key_encrypt_inst : entity work.AddRoundKey
		port map(
			state_in => reg_encrypt_output,
			state_in_from_round_key => round_key_encrypt,
			state_out => subbytes_input
		);
		sub_byte_inst : entity work.SubBytes
		port map(
			state_in  => subbytes_input,
			state_out => subbytes_output	
		);
		shift_rows_inst : entity work.ShiftRows
		port map(
			state_in  => subbytes_output,
			state_out => shiftrows_output
		);
		mix_columns_inst : entity work.MixColumns
		port map(
			state_in  => shiftrows_output,
			state_out => mixcol_output
		);
		feedback_encrypt <= mixcol_output when sel_encrypt = '0' else shiftrows_output;
		result_encrypt <= subbytes_input;
		key_expansion_inst : entity work.KeyExpansion
		 generic map(
			KEY_SIZE => KEY_SIZE,
			ROUND_COUNT => ROUND_COUNT
		)
		port map(
			clk         => clk,
			key         => key,
			round_key_value   => round_key_encrypt
		);	
		round_controller_encrypt_inst : entity work.round_controller_encrypt 
		 generic map(
			ROUND_COUNT => ROUND_COUNT
		)
		port map(
			clk              => clk,
			reset            => rst,
			is_final_round   => sel_encrypt,
			done             => done
		);
		ciphertext1 <= result_encrypt(127 downto 96);
		ciphertext2 <= result_encrypt(95 downto 64);
		ciphertext3 <= result_encrypt(63 downto 32);
		ciphertext4 <= result_encrypt(31 downto 0);
end arch;