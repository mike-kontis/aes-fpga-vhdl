library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity div is
	port (
		clk_old : in std_logic;
		enable  : in std_logic;
		clk_new : out std_logic
	);
end div;

architecture arch of div is 
	signal clk_temp : std_logic;
	signal temp     : integer range 0 to 49999999;
begin 
	process(clk_old,clk_temp)
	begin 
		if(rising_edge(clk_old)) then
		  if(enable ='1') then
				if(temp = 50000000/2 -1) then
					temp <= temp+1;
					clk_temp <= '1';
				elsif(temp = 50000000-1) then
					temp <= 0;
					clk_temp <= '0';
				else
					temp <= temp+1;
				end if;
				clk_new <= clk_temp;
			end if;
		end if;
	end process;
end arch;
