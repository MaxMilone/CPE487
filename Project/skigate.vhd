LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY skigate IS
    PORT (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        bat_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- player x position
        serve : IN STD_LOGIC; -- initiates serve
        red : OUT STD_LOGIC;
        green : OUT STD_LOGIC;
        blue : OUT STD_LOGIC
    );
END skigate;

ARCHITECTURE Behavioral OF skigate IS
	CONSTANT size  : INTEGER := 8;
	SIGNAL gate_on : STD_LOGIC; -- indicates whether the gate is over current pixel position
	-- current gate position - intitialized to center of screen
	SIGNAL gate_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
	SIGNAL gate_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
	-- current gate motion - initialized to +4 pixels/frame
	SIGNAL gate_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000100";
BEGIN
	red <= '1'; -- color setup for red gate on white background
	green <= NOT gate_on;
	blue  <= NOT gate_on;
	-- process to draw gate current pixel address is covered by gate position
	gdraw : PROCESS (gate_x, gate_y, pixel_row, pixel_col) IS
	BEGIN
		IF (pixel_col >= gate_x - size) AND
		 (pixel_col <= gate_x + size) AND
			 (pixel_row >= gate_y - size) AND
			 (pixel_row <= gate_y + size) THEN
				gate_on <= '1';
		ELSE
			gate_on <= '0';
		END IF;
		END PROCESS;
		-- process to move the gate once every frame (i.e. once every vsync pulse)
		mgate : PROCESS
		BEGIN
			WAIT UNTIL rising_edge(v_sync);
			-- allow for bounce off top or bottom of screen
			IF gate_y + size >= 600 THEN
				gate_y_motion <= "11111111100"; -- -4 pixels
			--ELSIF gate_y <= size THEN
				--gate_y_motion <= "00000000100"; -- +4 pixels
			END IF;
			gate_y <= gate_y + gate_y_motion; -- compute next gate position
		END PROCESS;
END Behavioral;
