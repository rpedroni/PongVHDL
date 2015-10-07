--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
--
entity led_pong is
	generic(
		NUM_LEDS: integer := 10;
		WIN_SCORE: integer := 5; -- max 9
		FCLK: integer := 50_000_000
	);
	port(
		-- ins
		buttonLeftPlayer, buttonRightPlayer: in std_logic;
		speedSwitches: in std_logic_vector(3 downto 0);
		autoSpeed: in std_logic;
		clock, reset: in std_logic;
		-- outs
		leds: out std_logic_vector(0 to NUM_LEDS - 1);
		scoreLeftPlayerSSD, scoreRightPlayerSSD: out std_logic_vector(6 downto 0)
	);
end entity;
--
architecture arch of led_pong is
	signal buttonLeftPlayerDebounced, buttonRightPlayerDebounced: std_logic;
	
	-- Get ball position and reset positions
	signal resetBall: std_logic;
	signal resetPosition: integer range 0 to NUM_LEDS - 1 := 0;
	signal resetDirection: std_logic;
	signal currentPosition: integer range resetPosition'range;
	signal enableBall: std_logic := '0';
	
	-- Scores
	signal scoreLeft, scoreRight: integer range 0 to WIN_SCORE;
	signal isGameOver: std_logic;
	signal hideLeftScore, hideRightScore: std_logic;
		
	-- Game logic states
	type state is (ServeLeft, ServeRight, MovingLeft, MovingRight,
	BallOnLeft, BallOnRight, LoseLeft, LoseRight);
	signal presState, nextState: state;
	-- Game logic "inner outputs"
	signal leftLose, rightLose: std_logic := '0';

	constant BTN_PRESSED: std_logic := '1';
begin

	-- debounce buttons
	dbleft: entity work.debouncer generic map (DEBOUNCE_TIME => FCLK / 10)
	port map(button => not buttonLeftPlayer, clock => clock, buttonDebouncedPulse => buttonLeftPlayerDebounced);
	dbright: entity work.debouncer generic map (DEBOUNCE_TIME => FCLK / 10)
	port map(button => not buttonRightPlayer, clock => clock, buttonDebouncedPulse => buttonRightPlayerDebounced);

	-- Connect signals to LED RUNNER (used to display ball/led moviment)
	ledrunner: entity work.led_runner generic map (FCLK => FCLK, NUM_LEDS => NUM_LEDS)
	port map(
		-- ins
		speed =>	speedSwitches,
		autoSpeed => autoSpeed,
		enable => enableBall,-- and not gameOver,
		reset => resetBall,
		resetPosition => resetPosition,
		resetDirection => resetDirection,
		clock => clock,
		-- outs
		leds => leds,
		position => currentPosition
	);
	
	-- Wire scoreboards
	sbleft: entity work.bin2ssd port map(conv_std_logic_vector(scoreLeft, 4), hideLeftScore, scoreLeftPlayerSSD);
	sbright: entity work.bin2ssd port map(conv_std_logic_vector(scoreRight, 4), hideRightScore, scoreRightPlayerSSD);
	
	-- Game logic FSM
	process(clock, reset)
	begin
		if reset = '1' or isGameOver = '1' then
			presState <= ServeLeft;
		elsif rising_edge(clock) then
			presState <= nextState;
		end if;
	end process;
	-- State logic
	process(all)
	begin
		case presState is
			
			when ServeLeft =>
				leftLose <= '0';
				rightLose <= '0';
				resetBall <= '1'; resetPosition <= 0; resetDirection <= '0';
				enableBall <= '0';
				
				if buttonLeftPlayerDebounced = BTN_PRESSED then
					nextState <= MovingRight;
				else
					nextState <= ServeLeft;
				end if;
				
			when ServeRight =>
				leftLose <= '0';
				rightLose <= '0';
				resetBall <= '1'; resetPosition <= NUM_LEDS - 1; resetDirection <= '1';
				enableBall <= '0';
				
				if buttonRightPlayerDebounced = BTN_PRESSED then
					nextState <= MovingLeft;
				else
					nextState <= ServeRight;
				end if;
			
			when MovingLeft =>
				leftLose <= '0';
				rightLose <= '0';
				resetBall <= '0'; resetPosition <= 0; resetDirection <= '0';
				enableBall <= '1';
				
				if buttonLeftPlayerDebounced = BTN_PRESSED then
					nextState <= LoseLeft;
				elsif buttonRightPlayerDebounced = BTN_PRESSED then
					nextState <= LoseRight;
				elsif currentPosition = 0 then
					nextState <= BallOnLeft;
				else
					nextState <= MovingLeft;
				end if;
				
			when MovingRight =>
				leftLose <= '0';
				rightLose <= '0';
				resetBall <= '0'; resetPosition <= 0; resetDirection <= '0';
				enableBall <= '1';
				
				if buttonLeftPlayerDebounced = BTN_PRESSED then
					nextState <= LoseLeft;
				elsif buttonRightPlayerDebounced = BTN_PRESSED then
					nextState <= LoseRight;
				elsif currentPosition = NUM_LEDS - 1 then
					nextState <= BallOnRight;
				else
					nextState <= MovingRight;
				end if;
				
			when BallOnLeft =>
				leftLose <= '0';
				rightLose <= '0';
				resetBall <= '0'; resetPosition <= 0; resetDirection <= '0';
				enableBall <= '1';
				
				if buttonLeftPlayerDebounced = BTN_PRESSED then
					nextState <= MovingRight;
				elsif buttonRightPlayerDebounced = BTN_PRESSED then
					nextState <= LoseRight;
				elsif currentPosition = 1 then
					nextState <= LoseLeft;
				else
					nextState <= BallOnLeft;
				end if;
				
			when BallOnRight =>
				leftLose <= '0';
				rightLose <= '0';
				resetBall <= '0'; resetPosition <= 0; resetDirection <= '0';
				enableBall <= '1';
				
				if buttonLeftPlayerDebounced = BTN_PRESSED then
					nextState <= LoseLeft;
				elsif buttonRightPlayerDebounced = BTN_PRESSED then
					nextState <= MovingLeft;
				elsif currentPosition = NUM_LEDS - 2 then
					nextState <= LoseRight;
				else
					nextState <= BallOnRight;
				end if;

			when LoseLeft =>
				leftLose <= '1';
				rightLose <= '0';
				resetBall <= '1'; resetPosition <= 0; resetDirection <= '0';
				enableBall <= '0';				
				nextState <= ServeLeft;			
				
			when LoseRight =>
				leftLose <= '0';
				rightLose <= '1';
				resetBall <= '1'; resetPosition <= NUM_LEDS - 1; resetDirection <= '1';
				enableBall <= '0';	
				nextState <= ServeRight;
				
		end case;
	end process;
	
	-- Process user losing signals
	process(clock, reset, leftLose, rightLose)
	begin
		if reset = '1' then
			scoreLeft <= 0;
			scoreRight <= 0;
			isGameOver <= '0';
			hideLeftScore <= '0';
			hideRightScore <= '0';
		elsif rising_edge(clock) then
			if leftLose = '1' then
				scoreRight <= scoreRight + 1;
				if scoreRight = WIN_SCORE - 1 then
					hideLeftScore <= '1';
					isGameOver <= '1';
				end if;
			elsif rightLose = '1' then
				scoreLeft <= scoreLeft + 1;
				if scoreLeft = WIN_SCORE - 1 then
					hideRightScore <= '1';
					isGameOver <= '1';
				end if;
			end if;
		end if;
	end process;

end architecture;
--