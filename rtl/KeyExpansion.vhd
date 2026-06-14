library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity KeyExpansion is
    generic (
        KEY_SIZE    : integer := 128;  
        ROUND_COUNT : integer := 10  
    );
    port (
		  clk					 : in  std_logic;
        key      		  	 : in  std_logic_vector(KEY_SIZE - 1 downto 0); 
        round_key_value  : out std_logic_vector(127 downto 0) 			   
    );
end entity;

architecture arch of KeyExpansion is
    constant Nk: integer := KEY_SIZE/32;   															 
    type key_array is array(0 to ((4*ROUND_COUNT)+3)) of std_logic_vector(31 downto 0);
    type RCON_array is array (0 to 9) of std_logic_vector(31 downto 0);
	 type round_key_array is array (0 to ROUND_COUNT) of STD_LOGIC_VECTOR(127 downto 0); 
    signal expanded_key : key_array;
    signal temp        : std_logic_vector(31 downto 0);
    signal rotword_out : std_logic_vector(31 downto 0);
    signal subword_out : std_logic_vector(31 downto 0);
	 signal round_keys : round_key_array;
	 signal index : integer range 0 to ROUND_COUNT := 0;
    constant RCON : RCON_array := (
        x"01000000",  x"02000000",  x"04000000",  x"08000000",
        x"10000000",  x"20000000",  x"40000000",  x"80000000",
        x"1B000000",  x"36000000", others => (others => '0')
    );
    type sbox_array is array (0 to 255) of std_logic_vector(7 downto 0);
    constant sbox : sbox_array := (
    X"63", X"7C", X"77", X"7B", X"F2", X"6B", X"6F", X"C5", X"30", X"01", X"67", X"2B", X"FE", X"D7", X"AB", X"76",  
    x"ca", x"82", x"c9", x"7d", x"fa", x"59", x"47", x"f0", x"ad", x"d4", x"a2", x"af", x"9c", x"a4", x"72", x"c0",
    x"b7", x"fd", x"93", x"26", x"36", x"3f", x"f7", x"cc", x"34", x"a5", x"e5", x"f1", x"71", x"d8", x"31", x"15",
    x"04", x"c7", x"23", x"c3", x"18", x"96", x"05", x"9a", x"07", x"12", x"80", x"e2", x"eb", x"27", x"b2", x"75",
    x"09", x"83", x"2c", x"1a", x"1b", x"6e", x"5a", x"a0", x"52", x"3b", x"d6", x"b3", x"29", x"e3", x"2f", x"84",
    x"53", x"d1", x"00", x"ed", x"20", x"fc", x"b1", x"5b", x"6a", x"cb", x"be", x"39", x"4a", x"4c", x"58", x"cf",
    x"d0", x"ef", x"aa", x"fb", x"43", x"4d", x"33", x"85", x"45", x"f9", x"02", x"7f", x"50", x"3c", x"9f", x"a8",
    x"51", x"a3", x"40", x"8f", x"92", x"9d", x"38", x"f5", x"bc", x"b6", x"da", x"21", x"10", x"ff", x"f3", x"d2",
    x"cd", x"0c", x"13", x"ec", x"5f", x"97", x"44", x"17", x"c4", x"a7", x"7e", x"3d", x"64", x"5d", x"19", x"73",
    x"60", x"81", x"4f", x"dc", x"22", x"2a", x"90", x"88", x"46", x"ee", x"b8", x"14", x"de", x"5e", x"0b", x"db",
    x"e0", x"32", x"3a", x"0a", x"49", x"06", x"24", x"5c", x"c2", x"d3", x"ac", x"62", x"91", x"95", x"e4", x"79",
    x"e7", x"c8", x"37", x"6d", x"8d", x"d5", x"4e", x"a9", x"6c", x"56", x"f4", x"ea", x"65", x"7a", x"ae", x"08",
    x"ba", x"78", x"25", x"2e", x"1c", x"a6", x"b4", x"c6", x"e8", x"dd", x"74", x"1f", x"4b", x"bd", x"8b", x"8a",
    x"70", x"3e", x"b5", x"66", x"48", x"03", x"f6", x"0e", x"61", x"35", x"57", x"b9", x"86", x"c1", x"1d", x"9e",
    x"e1", x"f8", x"98", x"11", x"69", x"d9", x"8e", x"94", x"9b", x"1e", x"87", x"e9", x"ce", x"55", x"28", x"df",
    x"8c", x"a1", x"89", x"0d", x"bf", x"e6", x"42", x"68", x"41", x"99", x"2d", x"0f", x"b0", x"54", x"bb", x"16"
);

    function RotWord (word_in: std_logic_vector(31 downto 0)) return std_logic_vector is
        variable rotated_word : std_logic_vector(31 downto 0);
    begin
        rotated_word := word_in(23 downto 0) & word_in(31 downto 24);
        return rotated_word;
    end function;

    function SubWord (word_in: std_logic_vector(31 downto 0)) return std_logic_vector is
        variable substituted_word : std_logic_vector(31 downto 0);
    begin
        substituted_word(31 downto 24) := sbox(to_integer(unsigned(word_in(31 downto 24))));
        substituted_word(23 downto 16) := sbox(to_integer(unsigned(word_in(23 downto 16))));
        substituted_word(15 downto 8)  := sbox(to_integer(unsigned(word_in(15 downto 8))));
        substituted_word(7 downto 0)   := sbox(to_integer(unsigned(word_in(7 downto 0))));
        return substituted_word;
    end function;

begin
    process(key,expanded_key)
	 begin
    for i in 0 to Nk-1 loop
      expanded_key(i) <= key(((KEY_SIZE-1)-(32*i)) downto ((KEY_SIZE-32) - (32 * i)));
    end loop;
    for i in Nk to (4*ROUND_COUNT)+3 loop
      if i mod Nk = 0 then
        expanded_key(i) <= expanded_key(i - Nk) XOR SubWord(RotWord(expanded_key(i-1))) XOR Rcon((i / Nk) - 1);
		elsif Nk > 6 and i mod Nk = 4 then
		  expanded_key(i) <= SubWord(expanded_key(i-1)) XOR expanded_key(i - Nk);
      else
        expanded_key(i) <= expanded_key(i - Nk) XOR expanded_key(i - 1);
      end if;
    end loop;
    for i in 0 to ROUND_COUNT loop
      round_keys(i) <= expanded_key(i * 4) & expanded_key(i * 4 + 1) & expanded_key(i * 4 + 2) & expanded_key(i * 4 + 3);
    end loop;
  end process;
  
  process(clk)
  begin
	 if(rising_edge(clk)) then
		 round_key_value<= round_keys(index);
		 if index = ROUND_COUNT then
			 index <= 0;
		 else
			 index <= index + 1;
		 end if;
	 end if;
	end process;
end arch;