LIBRARY ieee  ; 
LIBRARY std  ; 
USE ieee.NUMERIC_STD.all  ; 
USE ieee.std_logic_1164.all  ; 
USE ieee.std_logic_textio.all  ; 
USE ieee.std_logic_unsigned.all  ; 
USE std.textio.all  ; 
ENTITY tb_cipher  IS 
  GENERIC (
    ROUND_COUNT  : INTEGER   := 10 ;  
    KEY_SIZE  : INTEGER   := 128 ); 
END ; 
 
ARCHITECTURE tb_cipher_arch OF tb_cipher IS
  SIGNAL ciphertext4   :  STD_LOGIC_VECTOR (31 downto 0)  ; 
  SIGNAL ciphertext1   :  STD_LOGIC_VECTOR (31 downto 0)  ; 
  SIGNAL rst   :  STD_LOGIC  ; 
  SIGNAL ciphertext2   :  STD_LOGIC_VECTOR (31 downto 0)  ; 
  SIGNAL done   :  STD_LOGIC  ; 
  SIGNAL clk   :  STD_LOGIC  ; 
  SIGNAL ciphertext3   :  STD_LOGIC_VECTOR (31 downto 0)  ; 
  SIGNAL start_enc   :  STD_LOGIC  ; 
  COMPONENT Cipher  
    GENERIC ( 
      ROUND_COUNT  : INTEGER ; 
      KEY_SIZE  : INTEGER  );  
    PORT ( 
      ciphertext4  : out STD_LOGIC_VECTOR (31 downto 0) ; 
      ciphertext1  : out STD_LOGIC_VECTOR (31 downto 0) ; 
      rst  : in STD_LOGIC ; 
      ciphertext2  : out STD_LOGIC_VECTOR (31 downto 0) ; 
      done  : out STD_LOGIC ; 
      clk  : in STD_LOGIC ; 
      ciphertext3  : out STD_LOGIC_VECTOR (31 downto 0) ; 
      start_enc  : in STD_LOGIC ); 
  END COMPONENT ; 
BEGIN
  DUT  : Cipher  
    GENERIC MAP ( 
      ROUND_COUNT  => ROUND_COUNT  ,
      KEY_SIZE  => KEY_SIZE   )
    PORT MAP ( 
      ciphertext4   => ciphertext4  ,
      ciphertext1   => ciphertext1  ,
      rst   => rst  ,
      ciphertext2   => ciphertext2  ,
      done   => done  ,
      clk   => clk  ,
      ciphertext3   => ciphertext3  ,
      start_enc   => start_enc   ) ; 



-- "Clock Pattern" : dutyCycle = 50
-- Start Time = 0 ns, End Time = 1 us, Period = 50 ns
  Process
	Begin
	 clk  <= '0'  ;
	wait for 25 ns ;
-- 25 ns, single loop till start period.
	for Z in 1 to 19
	loop
	    clk  <= '1'  ;
	   wait for 25 ns ;
	    clk  <= '0'  ;
	   wait for 25 ns ;
-- 975 ns, repeat pattern in loop.
	end  loop;
	 clk  <= '1'  ;
	wait for 25 ns ;
-- dumped values till 1 us
	wait;
 End Process;


-- "Constant Pattern"
-- Start Time = 25 ns, End Time = 1 us, Period = 0 ns
  Process
	Begin
	 rst  <= '1'  ;
	wait for 25 ns ;
	 rst  <= '0'  ;
	wait for 975 ns ;
-- dumped values till 1 us
	wait;
 End Process;


-- "Constant Pattern"
-- Start Time = 50 ns, End Time = 1 us, Period = 0 ns
  Process
	Begin
	 start_enc  <= '1'  ;
	wait for 50 ns ;
	 start_enc  <= '0'  ;
	wait for 950 ns ;
-- dumped values till 1 us
	wait;
 End Process;
END;
