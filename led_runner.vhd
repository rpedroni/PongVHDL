--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--
entity led_runner is
	generic(
		FCLK: integer := 50_000_000;
		NUM_LEDS: integer := 10;
		MAX_LOOP_COUNT: integer := 20
	);
	port(
		-- ins
		speed: in std_logic_vector(3 downto 0); -- "speed" options
		autoSpeed: in std_logic; -- If speed should automatically increase
		enable, reset, clock: std_logic;
		resetPosition: in integer range 0 to NUM_LEDS - 1;
		resetDirection: in std_logic;
		-- outs
		leds: out std_logic_vector(0 to NUM_LEDS - 1);
		position: out integer range 0 to NUM_LEDS - 1
	);
end entity;
--
architecture arch of led_runner is
	signal currentPosition: integer range 0 to NUM_LEDS - 1 := resetPosition;
	signal currentDirection: std_logic := resetDirection;
	-- leds "speed" calculation
	signal speedCalc: integer range 0 to FCLK := 0;
	constant speedTop: integer := 2 ** speed'length;
	-- auto speed
	signal loopCount: integer range 0 to MAX_LOOP_COUNT;
begin

	-- Fixed signals / outputs
	position <= currentPosition;
	lg: for i in 0 to NUM_LEDS - 1 generate
		leds(i) <= '1' when i = currentPosition else '0';
	end generate;
	
	-- Speed calculation
	speedCalc <= 	((speedTop - conv_integer(speed)) * FCLK) / speedTop when autoSpeed = '0' else
						FCLK / (loopCount + 3);

	-- Start sequential
	process(all)
		variable timer: integer range 0 to FCLK := 0;
	begin
	
		-- Reset all values
		if reset = '1' then
			currentPosition <= resetPosition;
			currentDirection <= resetDirection;
			loopCount <= 0;
			timer := 0;
			
		elsif rising_edge(clock) and enable = '1' then
		
			-- Timer (check >= since speedCalc can change async)
			timer := timer + 1;
			if timer >= speedCalc then
				timer := 0;
				
				-- Do your stuff
				-- (Dec)(Inc)rement position and toggle direction
				if currentDirection = '0' and currentPosition < NUM_LEDS - 1 then
					currentPosition <= currentPosition + 1;
					currentDirection <= currentDirection;
					loopCount <= loopCount;
				elsif currentDirection = '0' and currentPosition = NUM_LEDS - 1 then
					currentPosition <= currentPosition - 1;
					currentDirection <= not currentDirection;
					
					if loopCount < MAX_LOOP_COUNT and autoSpeed = '1' then
						loopCount <= loopCount + 1;
					end if;

				elsif currentDirection = '1' and currentPosition > 0 then
					currentPosition <= currentPosition - 1;
					currentDirection <= currentDirection;
					loopCount <= loopCount;
				else
					currentPosition <= currentPosition + 1;
					currentDirection <= not currentDirection;
					
					if loopCount < MAX_LOOP_COUNT and autoSpeed = '1' then
						loopCount <= loopCount + 1;
					end if;
					
				end if;					
			end if;
		
		end if;
			
	
	end process;

end architecture;
--