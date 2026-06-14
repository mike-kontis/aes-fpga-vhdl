library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InvMixColumns is
    port(
        state_in  : in  std_logic_vector(127 downto 0);
        state_out : out std_logic_vector(127 downto 0)
    );
end InvMixColumns;

architecture Behavioral of InvMixColumns is
    function Xtimes(b: std_logic_vector(7 downto 0)) return std_logic_vector is
    begin
        if b(7) = '1' then
            return (b(6 downto 0) & '0') xor x"1B";  
        else
            return (b(6 downto 0) & '0'); 
        end if;
    end function;

    function GF_Mul(b: std_logic_vector(7 downto 0); factor: std_logic_vector(7 downto 0)) return std_logic_vector is
    begin
        case factor is
            when x"01" => return b;
            when x"02" => return Xtimes(b);
            when x"03" => return Xtimes(b) xor b;
            when x"09" => return Xtimes(Xtimes(Xtimes(b))) xor b;
            when x"0B" => return Xtimes(Xtimes(Xtimes(b))) xor Xtimes(b) xor b;
            when x"0D" => return Xtimes(Xtimes(Xtimes(b))) xor Xtimes(Xtimes(b)) xor b;
            when x"0E" => return Xtimes(Xtimes(Xtimes(b))) xor Xtimes(Xtimes(b)) xor Xtimes(b);
            when others => return "00000000"; 
        end case;
    end function;

    subtype column_t is std_logic_vector(31 downto 0);
	 type column_array_t is array (0 to 3) of column_t;
	 signal columns_in  : column_array_t;
	 signal columns_out : column_array_t;

begin
    columns_in(0) <= state_in(127 downto 96);
    columns_in(1) <= state_in(95 downto 64);
    columns_in(2) <= state_in(63 downto 32);
    columns_in(3) <= state_in(31 downto 0);
    process(columns_in)
    begin
        columns_out(0)(31 downto 24) <= GF_Mul(columns_in(0)(31 downto 24), x"0E") xor GF_Mul(columns_in(0)(23 downto 16), x"0B") xor GF_Mul(columns_in(0)(15 downto 8), x"0D") xor GF_Mul(columns_in(0)(7 downto 0), x"09");
		  columns_out(0)(23 downto 16) <= GF_Mul(columns_in(0)(31 downto 24), x"09") xor GF_Mul(columns_in(0)(23 downto 16), x"0E") xor GF_Mul(columns_in(0)(15 downto 8), x"0B") xor GF_Mul(columns_in(0)(7 downto 0), x"0D");
		  columns_out(0)(15 downto 8)  <= GF_Mul(columns_in(0)(31 downto 24), x"0D") xor GF_Mul(columns_in(0)(23 downto 16), x"09") xor GF_Mul(columns_in(0)(15 downto 8), x"0E") xor GF_Mul(columns_in(0)(7 downto 0), x"0B");
		  columns_out(0)(7 downto 0)   <= GF_Mul(columns_in(0)(31 downto 24), x"0B") xor GF_Mul(columns_in(0)(23 downto 16), x"0D") xor GF_Mul(columns_in(0)(15 downto 8), x"09") xor GF_Mul(columns_in(0)(7 downto 0), x"0E");
        columns_out(1)(31 downto 24) <= GF_Mul(columns_in(1)(31 downto 24), x"0E") xor GF_Mul(columns_in(1)(23 downto 16), x"0B") xor GF_Mul(columns_in(1)(15 downto 8), x"0D") xor GF_Mul(columns_in(1)(7 downto 0), x"09");
		  columns_out(1)(23 downto 16) <= GF_Mul(columns_in(1)(31 downto 24), x"09") xor GF_Mul(columns_in(1)(23 downto 16), x"0E") xor GF_Mul(columns_in(1)(15 downto 8), x"0B") xor GF_Mul(columns_in(1)(7 downto 0), x"0D");
		  columns_out(1)(15 downto 8)  <= GF_Mul(columns_in(1)(31 downto 24), x"0D") xor GF_Mul(columns_in(1)(23 downto 16), x"09") xor GF_Mul(columns_in(1)(15 downto 8), x"0E") xor GF_Mul(columns_in(1)(7 downto 0), x"0B");
		  columns_out(1)(7 downto 0)   <= GF_Mul(columns_in(1)(31 downto 24), x"0B") xor GF_Mul(columns_in(1)(23 downto 16), x"0D") xor GF_Mul(columns_in(1)(15 downto 8), x"09") xor GF_Mul(columns_in(1)(7 downto 0), x"0E");
        columns_out(2)(31 downto 24) <= GF_Mul(columns_in(2)(31 downto 24), x"0E") xor GF_Mul(columns_in(2)(23 downto 16), x"0B") xor GF_Mul(columns_in(2)(15 downto 8), x"0D") xor GF_Mul(columns_in(2)(7 downto 0), x"09");
		  columns_out(2)(23 downto 16) <= GF_Mul(columns_in(2)(31 downto 24), x"09") xor GF_Mul(columns_in(2)(23 downto 16), x"0E") xor GF_Mul(columns_in(2)(15 downto 8), x"0B") xor GF_Mul(columns_in(2)(7 downto 0), x"0D");
		  columns_out(2)(15 downto 8)  <= GF_Mul(columns_in(2)(31 downto 24), x"0D") xor GF_Mul(columns_in(2)(23 downto 16), x"09") xor GF_Mul(columns_in(2)(15 downto 8), x"0E") xor GF_Mul(columns_in(2)(7 downto 0), x"0B");
		  columns_out(2)(7 downto 0)   <= GF_Mul(columns_in(2)(31 downto 24), x"0B") xor GF_Mul(columns_in(2)(23 downto 16), x"0D") xor GF_Mul(columns_in(2)(15 downto 8), x"09") xor GF_Mul(columns_in(2)(7 downto 0), x"0E");
        columns_out(3)(31 downto 24) <= GF_Mul(columns_in(3)(31 downto 24), x"0E") xor GF_Mul(columns_in(3)(23 downto 16), x"0B") xor GF_Mul(columns_in(3)(15 downto 8), x"0D") xor GF_Mul(columns_in(3)(7 downto 0), x"09");
		  columns_out(3)(23 downto 16) <= GF_Mul(columns_in(3)(31 downto 24), x"09") xor GF_Mul(columns_in(3)(23 downto 16), x"0E") xor GF_Mul(columns_in(3)(15 downto 8), x"0B") xor GF_Mul(columns_in(3)(7 downto 0), x"0D");
		  columns_out(3)(15 downto 8)  <= GF_Mul(columns_in(3)(31 downto 24), x"0D") xor GF_Mul(columns_in(3)(23 downto 16), x"09") xor GF_Mul(columns_in(3)(15 downto 8), x"0E") xor GF_Mul(columns_in(3)(7 downto 0), x"0B");
		  columns_out(3)(7 downto 0)   <= GF_Mul(columns_in(3)(31 downto 24), x"0B") xor GF_Mul(columns_in(3)(23 downto 16), x"0D") xor GF_Mul(columns_in(3)(15 downto 8), x"09") xor GF_Mul(columns_in(3)(7 downto 0), x"0E");
    end process;
    state_out <= columns_out(0) & columns_out(1) & columns_out(2) & columns_out(3);
end Behavioral;
