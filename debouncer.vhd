--
library ieee;
use ieee.std_logic_1164.all;
--
entity debouncer is
	generic(
		DEBOUNCE_TIME: integer := 5--50_000 -- .1 milisecond for 50MHz clock
 	);
	port(
		button, clock: in std_logic;
		buttonDebounced: out std_logic;
		buttonDebouncedPulse: out std_logic
	);
end entity;
--
architecture arch of debouncer is
	signal innerDebounced: std_logic := '0';
	signal buttonDidDrop: std_logic;
	signal innerDebouncedPulse: std_logic := '0';
begin

	buttonDebounced <= innerDebounced;
	buttonDebouncedPulse <= innerDebouncedPulse;
	
	process(clock, button)
		variable counter: integer range 0 to DEBOUNCE_TIME - 1 := 0;
	begin
	
		if rising_edge(clock) then
			if button /= innerDebounced then
				counter := counter + 1;
				if counter = DEBOUNCE_TIME - 1 then
					counter := 0;
					innerDebounced <= not innerDebounced;
				end if;
			else
				counter := 0;
			end if;
		end if;
	
	end process;
	
	process(clock)
		variable detectDown: std_logic := '0';
	begin
		if rising_edge(clock) then
			if innerDebounced = '1' and innerDebouncedPulse = '0' and detectDown = '0' then
				innerDebouncedPulse <= '1';
				detectDown := '1';
			elsif innerDebounced = '0' then
				detectDown := '0';
				innerDebouncedPulse <= '0';
			else
				detectDown := detectDown;
				innerDebouncedPulse <= '0';
			end if;
		end if;				
	end process;
	
end architecture;