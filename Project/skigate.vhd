LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY skigate IS
    PORT (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        ski_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current player x position
        start : IN STD_LOGIC; -- initiates start of game
        red : OUT STD_LOGIC;
        green : OUT STD_LOGIC;
        blue : OUT STD_LOGIC
    );
END skigate;

ARCHITECTURE Behavioral OF skigate IS
    CONSTANT gate_w : INTEGER := 25; -- gate width in pixels
    CONSTANT gate_h : INTEGER := 3; -- gate height in pixels
    CONSTANT ski_w : INTEGER := 5; -- player width in pixels
    CONSTANT ski_h : INTEGER := 5; -- player height in pixels
    -- distance gate descends each frame
    CONSTANT gate_speed : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (6, 11);
    SIGNAL gate_on : STD_LOGIC; -- indicates whether gate is at current pixel position
    SIGNAL ski_on : STD_LOGIC; -- indicates whether player at over current pixel position
    SIGNAL game_on : STD_LOGIC := '0'; -- indicates whether gate is in motion

    -- current gate position - intitialized to top of screen
-- NEED TO randomize this x position
    SIGNAL gate_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
    SIGNAL gate_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(600, 11);

    -- player vertical position
-- CHANGE THIS TO TOP OF SCREEN
    CONSTANT ski_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(50, 11);
    -- current gate motion - initialized to (+ gate_speed) pixels/frame in both X and Y directions
    SIGNAL gate_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := gate_speed;
BEGIN
    red <= NOT ski_on; -- color setup for red ball and cyan bat on white background
    green <= NOT gate_on;
    blue <= NOT gate_on;
    -- process to draw gate
    -- set gate_on if current pixel address is covered by gate position
    gatedraw : PROCESS (gate_x, gate_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF pixel_row <= gate_y THEN -- vy = |ball_y - pixel_row|
            vy := gate_y - pixel_row;
        ELSE
            vy := pixel_row - gate_y;
        END IF;
    END PROCESS;
            
    -- process to draw player/skiier
    -- set ski_on if current pixel address is covered by player position
    skidraw : PROCESS (ski_x, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF ((pixel_col >= ski_x - ski_w) OR (ski_x <= ski_w)) AND
         pixel_col <= ski_x + ski_w AND
             pixel_row >= ski_y - ski_h AND
             pixel_row <= ski_y + ski_h THEN
                ski_on <= '1';
        ELSE
            ski_on <= '0';
        END IF;
    END PROCESS;
            
    -- process to move gate once every frame (i.e. once every vsync pulse)
    mgate : PROCESS
        VARIABLE temp : STD_LOGIC_VECTOR (11 DOWNTO 0);
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        IF start = '1' AND game_on = '0' THEN -- test for new game start
            game_on <= '1';
            gate_y_motion <= (NOT gate_speed) - 1; -- set vspeed to (- ball_speed) pixels
        ELSIF gate_y + gate_h >= 600 THEN -- if ball meets bottom wall
            gate_y_motion <= (NOT gate_speed) + 1; -- set vspeed to (- ball_speed) pixels
            game_on <= '0'; -- and make ball disappear
        END IF;
        -- if player is in between the gates, spawn new gate
      --  IF (gate_x + gate_w/2) >= (ski_x - ski_w) AND
        -- (gate_x - gate_w/2) <= (ski_x + ski_w) AND
         --    (gate_y + gate_w/2) >= (ski_y - ski_h) AND
         --    (gate_y - gate_w/2) <= (ski_y + ski_h) THEN
               --  SIGNAL gate_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
               --  SIGNAL gate_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(600, 11);
        END IF;
    END PROCESS;
END Behavioral;
