library ieee;
use ieee.std_logic_1164.all;

entity round_controller_encrypt is
    generic (
        ROUND_COUNT : integer := 10  
    );
    port (
        clk            : in  std_logic;  
        reset          : in  std_logic;  
        is_final_round : out std_logic; 
        done           : out std_logic  
    );
end entity;

architecture Behavioral of round_controller_encrypt is
    signal round : integer range 0 to ROUND_COUNT + 2 := 0; 
begin
    process(clk, reset)
        variable next_round : integer range 0 to ROUND_COUNT + 2;
    begin
        if reset = '1' then
            round <= 0;
            is_final_round <= '0';
            done <= '0';
        elsif rising_edge(clk) then
            if round < ROUND_COUNT + 2 then
                next_round := round + 1;
            else
                next_round := round; 
            end if;     
				if next_round = ROUND_COUNT then
                is_final_round <= '1';
                done <= '0';					
				end if;
            if next_round = ROUND_COUNT + 1 then
                is_final_round <= '0';
                done <= '1';
				end if;
            if next_round = ROUND_COUNT + 2 then
					 is_final_round <= '0';
                done <= '0';
            end if;
            round <= next_round;
        end if;
    end process;
end Behavioral;