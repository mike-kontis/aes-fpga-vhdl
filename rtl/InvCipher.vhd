library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity InvCipher is 
	generic ( 
		KEY_SIZE    : integer := 128; 
		ROUND_COUNT : integer := 10  
	);
	port (
	   clk,rst,start_dec,decrypt     : in  std_logic;
		ciphertext  : in  std_logic_vector(127 downto 0);
		key         : in std_logic_vector(KEY_SIZE-1 downto 0);
		done        : out std_logic;
		plaintext1   : out std_logic_vector(31 downto 0);
		plaintext2   : out std_logic_vector(31 downto 0);
		plaintext3   : out std_logic_vector(31 downto 0);
		plaintext4   : out std_logic_vector(31 downto 0)
	);
end entity;

architecture arch of InvCipher is 
	signal reg_decrypt_input : std_logic_vector(127 downto 0) := (others => '0');
	signal reg_decrypt_output : std_logic_vector(127 downto 0) := (others => '0');
	signal inv_subbytes_input : std_logic_vector(127 downto 0) := (others => '0');
	signal inv_shiftrows_input : std_logic_vector(127 downto 0) := (others => '0');
	signal inv_mixcol_input : std_logic_vector(127 downto 0) := (others => '0');
	signal inv_mixcol_output : std_logic_vector(127 downto 0) := (others => '0');
	signal feedback_decrypt : std_logic_vector(127 downto 0) := (others => '0');
	signal round_key_decrypt : std_logic_vector(127 downto 0) := (others => '0');
	signal sel_decrypt,sel_decrypt_two : std_logic;
	signal result_decrypt : std_logic_vector(127 downto 0) := (others => '0');
begin
	reg_decrypt_input <= ciphertext when start_dec = '1' else feedback_decrypt;
	reg_decrypt_inst : entity work.Reg 
		port map(
			D_IN   => reg_decrypt_input,
			CLK => clk,
			RST => rst,
			D_OUT   => reg_decrypt_output
		);
		add_round_key_decrypt_inst : entity work.AddRoundKey
		port map(
			state_in => reg_decrypt_output,
			state_in_from_round_key => round_key_decrypt,
			state_out => inv_mixcol_input
		);
		inv_mix_columns_inst : entity work.InvMixColumns
		port map(
			state_in  => inv_mixcol_input,
			state_out => inv_mixcol_output
		);
		inv_shiftrows_input <= inv_mixcol_input when sel_decrypt = '0' else inv_mixcol_output; 
		result_decrypt <= inv_shiftrows_input when sel_decrypt_two = '0' else inv_mixcol_input;
		inv_shift_rows_inst : entity work.InvShiftRows
		port map(
			state_in  => inv_shiftrows_input,
			state_out => inv_subbytes_input
		);
		inv_sub_byte_inst : entity work.InvSubBytes
		port map(
			state_in  => inv_subbytes_input,
			state_out => feedback_decrypt
			
		);
		key_expansioneic_inst : entity work.KeyExpansionEic
		 generic map(
			KEY_SIZE => KEY_SIZE,
			ROUND_COUNT => ROUND_COUNT
		)
		port map(
			clk         => clk,
			key         => key,
			round_key_value   => round_key_decrypt
		);
		round_controller_decrypt_inst : entity work.round_controller_decrypt 
		 generic map(
			ROUND_COUNT => ROUND_COUNT
		)
		port map(
			clk              => clk,
			reset            => start_dec,
			decrypt          => decrypt,
			is_first_round   => sel_decrypt,
			is_final_round   => sel_decrypt_two,
			done             => done
		);
		plaintext1 <= result_decrypt(127 downto 96);
		plaintext2 <= result_decrypt(95 downto 64);
		plaintext3 <= result_decrypt(63 downto 32);
		plaintext4 <= result_decrypt(31 downto 0);
end arch;