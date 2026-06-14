library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity AddRoundKey is
    Port (
        state_in    : in  std_logic_vector(127 downto 0); 
        state_in_from_round_key : in  std_logic_vector(127 downto 0); 
        state_out : out std_logic_vector(127 downto 0)  
    );
end AddRoundKey;

architecture behavioral of AddRoundKey is
begin 
     state_out <= state_in xor state_in_from_round_key;  
end behavioral;

