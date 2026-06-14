LIBRARY ieee  ; 
LIBRARY std  ; 
USE ieee.NUMERIC_STD.all  ; 
USE ieee.std_logic_1164.all  ; 
USE ieee.std_logic_textio.all  ; 
USE ieee.std_logic_unsigned.all  ; 
USE std.textio.all  ; 
ENTITY tb_invcipher  IS 
  GENERIC (
    ROUND_COUNT  : INTEGER   := 10 ;  
    KEY_SIZE  : INTEGER   := 128 ); 
END ; 
 
ARCHITECTURE tb_invcipher_arch OF tb_invcipher IS
  SIGNAL plaintext3   :  STD_LOGIC_VECTOR (31 downto 0)  ; 
  SIGNAL plaintext4   :  STD_LOGIC_VECTOR (31 downto 0)  ; 
  SIGNAL start_dec   :  STD_LOGIC  ; 
  SIGNAL rst   :  STD_LOGIC  ; 
  SIGNAL plaintext1   :  STD_LOGIC_VECTOR (31 downto 0)  ; 
  SIGNAL done   :  STD_LOGIC  ; 
  SIGNAL clk   :  STD_LOGIC  ; 
  SIGNAL plaintext2   :  STD_LOGIC_VECTOR (31 downto 0)  ; 
  SIGNAL decrypt   :  STD_LOGIC  ; 
  COMPONENT InvCipher  
    GENERIC ( 
      ROUND_COUNT  : INTEGER ; 
      KEY_SIZE  : INTEGER  );  
    PORT ( 
      plaintext3  : out STD_LOGIC_VECTOR (31 downto 0) ; 
      plaintext4  : out STD_LOGIC_VECTOR (31 downto 0) ; 
      start_dec  : in STD_LOGIC ; 
      rst  : in STD_LOGIC ; 
      plaintext1  : out STD_LOGIC_VECTOR (31 downto 0) ; 
      done  : out STD_LOGIC ; 
      clk  : in STD_LOGIC ; 
      plaintext2  : out STD_LOGIC_VECTOR (31 downto 0) ; 
      decrypt  : in STD_LOGIC ); 
  END COMPONENT ; 
BEGIN
  DUT  : InvCipher  
    GENERIC MAP ( 
      ROUND_COUNT  => ROUND_COUNT  ,
      KEY_SIZE  => KEY_SIZE   )
    PORT MAP ( 
      plaintext3   => plaintext3  ,
      plaintext4   => plaintext4  ,
      start_dec   => start_dec  ,
      rst   => rst  ,
      plaintext1   => plaintext1  ,
      done   => done  ,
      clk   => clk  ,
      plaintext2   => plaintext2  ,
      decrypt   => decrypt   ) ; 



-- "Clock Pattern" : dutyCycle = 50
-- Start Time = 0 ns, End Time = 1 us, Period = 20 ns
  Process
	Begin
	 clk  <= '0'  ;
	wait for 10 ns ;
-- 10 ns, single loop till start period.
	for Z in 1 to 49
	loop
	    clk  <= '1'  ;
	   wait for 10 ns ;
	    clk  <= '0'  ;
	   wait for 10 ns ;
-- 990 ns, repeat pattern in loop.
	end  loop;
	 clk  <= '1'  ;
	wait for 10 ns ;
-- dumped values till 1 us
	wait;
 End Process;


-- "Constant Pattern"
-- Start Time = 10 ns, End Time = 1 us, Period = 0 ns
  Process
	Begin
	 rst  <= '1'  ;
	wait for 10 ns ;
	 rst  <= '0'  ;
	wait for 990 ns ;
-- dumped values till 1 us
	wait;
 End Process;


-- "Constant Pattern"
-- Start Time = 20 ns, End Time = 1 us, Period = 0 ns
  Process
	Begin
	 start_dec  <= '1'  ;
	wait for 20 ns ;
	 start_dec  <= '0'  ;
	wait for 980 ns ;
-- dumped values till 1 us
	wait;
 End Process;


-- "Constant Pattern"
-- Start Time = 10 ns, End Time = 1 us, Period = 0 ns
  Process
	Begin
	 decrypt  <= '0'  ;
	wait for 10 ns ;
	 decrypt  <= '1'  ;
	wait for 990 ns ;
-- dumped values till 1 us
	wait;
 End Process;
END;
