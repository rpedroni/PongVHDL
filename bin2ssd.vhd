--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--
entity bin2ssd is
	port(
		bin: in std_logic_vector(3 downto 0);
		hide: in std_logic;
		ssd: out std_logic_vector(6 downto 0)
	);
end entity;
--
architecture arch of bin2ssd is
	signal int: integer range 0 to 15;
begin
	
	-- int for easier 
	int <= conv_integer(bin);
	
	--SSD driver:
	ssd <= 	"1111111" when hide = '1' else
				"0000001" when int =  0 else
				"1001111" when int =  1 else
				"0010010" when int =  2 else 		
				"0000110" when int =  3 else
				"1001100" when int =  4 else
				"0100100" when int =  5 else
				"0100000" when int =  6 else
				"0001111" when int =  7 else	
				"0000000" when int =  8 else	
				"0000100" when int =  9 else	
				"0001000" when int =  10 else
				"1100000" when int =  11 else
				"0110001" when int =  12 else
				"1000010" when int =  13 else
				"0110000" when int =  14 else
				"0111000";
				
end architecture;