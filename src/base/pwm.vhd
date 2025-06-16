library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pwm is
    generic (
        COUNTER_WIDTH : integer := 5  -- Number of PWM channels
    );
    Port (
        clk      : in std_logic; 
        rst      : in std_logic;
        pwm_out  : out std_logic_vector (COUNTER_WIDTH - 1 downto 0)
    );
end pwm;

architecture Behavioral of pwm is

    -- Max counter value for one full PWM cycle (e.g., 100 steps)
    constant MAX_COUNT : integer := 100;
    signal counter     : integer range 0 to MAX_COUNT := 0;

    -- Define fixed duty thresholds for each channel
    type duty_array is array (0 to 4) of integer;
    constant duty_thresholds : duty_array := (25, 50, 75, 100, 0); -- in %

    signal pwm_reg : std_logic_vector(4 downto 0); -- assuming fixed 5 channels

begin

    -- Counter process
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                counter <= 0;
            elsif counter = MAX_COUNT - 1 then
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    -- PWM output generation
    process(counter)
    begin
        for i in 0 to 4 loop
            if counter < duty_thresholds(i) then
                pwm_reg(i) <= '1';
            else
                pwm_reg(i) <= '0';
            end if;
        end loop;
    end process;

    -- Assign to output (truncate if COUNTER_WIDTH < 5)
    pwm_out <= pwm_reg(COUNTER_WIDTH - 1 downto 0);

end Behavioral;
