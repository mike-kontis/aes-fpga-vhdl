library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity SubBytes is
    port (
        state_in  : in  std_logic_vector(127 downto 0);
        state_out : out std_logic_vector(127 downto 0)
    );
end SubBytes;

architecture behavioral of SubBytes is
begin
	  gen: for i in 0 to 15 generate
			sbox_inst: entity work.sbox
				 port map(
					  byte_in  => state_in((i+1)*8-1 downto i*8),
					  byte_out => state_out((i+1)*8-1 downto i*8)
				 );
	  end generate gen;
end behavioral;