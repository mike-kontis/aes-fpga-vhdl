library ieee;
use ieee.std_logic_1164.all;

entity round_controller_decrypt is
    generic (
        ROUND_COUNT : integer := 10   
    );
    port (
        clk           : in  std_logic;  
        reset         : in  std_logic;  
		  decrypt       : in std_logic;
        is_first_round : out std_logic; 
		  is_final_round : out std_logic;
        done          : out std_logic   
    );
end entity;

architecture Behavioral of round_controller_decrypt is
    signal round : integer range 0 to ROUND_COUNT  := 0;  
begin
	 process(clk, reset)
	begin
		 if reset = '1' then
			  round <= 0;
			  is_first_round <= '0';
			  is_final_round <= '0';
			  done <= '0';
		 elsif rising_edge(clk) then
			if decrypt = '1' then
				  if round = 0 then
						is_first_round <= '1';
				  end if;
				  if round = ROUND_COUNT - 1 then
					 is_final_round <= '1';
					 done<= '1'; 
				  end if;
				  if round < ROUND_COUNT then
						round <= round + 1; 
				  end if;
			 end if;
		 end if;
	end process;
end Behavioral;


