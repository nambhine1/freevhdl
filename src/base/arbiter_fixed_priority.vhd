library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity arbiter_fixed_priority is
  generic (
    REQUEST_WIDTH : integer := 3
  );
  Port (
        clk : in std_logic;
        rst : in std_logic; 
        request : in std_logic_vector (REQUEST_WIDTH -1 downto 0);
        grant : out std_logic_vector (REQUEST_WIDTH -1 downto 0);
        valid_grant : out std_logic
     );
end arbiter_fixed_priority;

architecture Behavioral of arbiter_fixed_priority is
    signal grant_reg : std_logic_vector (grant'range) := (others => '0');
    signal valid_grant_reg : std_logic := '0';
begin
    grant <= grant_reg;
    valid_grant <= valid_grant_reg;
    
    fixed_priority : process (clk)
        variable priority_given : std_logic := '0';
      begin
          if rising_edge (clk) then
              if rst = '1' then 
                grant_reg <= (others => '0');
                valid_grant_reg<= '0';
              else
                priority_given := '0';
                grant_reg <= (others => '0');
                for index  in 0 to request'high loop
                    if (request(index) = '1' and priority_given = '0') then
                        grant_reg(index) <= '1';
                        valid_grant_reg <= '1';
                        priority_given := '1';
                    end if;
                end loop;
              end if;
          end if;
          
      end process fixed_priority;

end Behavioral;
