library IEEE;
use IEEE.std_logic_1164.all;

entity Reg is																																		
		port(
			D_IN		: in std_logic_vector(127 downto 0);
			CLK, RST : in std_logic;
			D_OUT		: out std_logic_vector(127 downto 0));
end Reg;

architecture RTL of Reg is
signal F: std_logic_vector(127 downto 0);
begin
p0: process(RST, CLK)
begin
	if(RST = '1') then F<=(127 downto 0 => '0');
	elsif(CLK'event and CLK = '1') then
		 F <=D_IN;
	end if;
end process;
D_OUT <= F;
end RTL;