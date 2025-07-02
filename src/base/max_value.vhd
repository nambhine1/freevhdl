library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity max_value is 
    generic (
        DATA_WIDTH_g       : positive := 32;
        NUMBER_IN_DATA_g   : positive := 32;
        SPLIT_DATA_NUM_g   : positive := 2;
        PIPELINE_MODE : string := "NOT_ACTIVE" -- , NOT_ACTIVE; ACTIVE
    );
    port (
        clk       : in std_logic; 
        rst       : in std_logic;
        data      : in std_logic_vector(NUMBER_IN_DATA_g * DATA_WIDTH_g -1 downto 0);
        max_data  : out std_logic_vector(DATA_WIDTH_g -1 downto 0)
    );
end max_value;

architecture Behavioral of max_value is

    constant split_data_c : positive := NUMBER_IN_DATA_g / SPLIT_DATA_NUM_g;

    -- Data types
    type split_data_array is array (0 to SPLIT_DATA_NUM_g -1) of std_logic_vector(split_data_c * DATA_WIDTH_g -1 downto 0);
    signal current_data_array : split_data_array;

    type out_max_array_t is array (0 to SPLIT_DATA_NUM_g -1) of std_logic_vector(DATA_WIDTH_g -1 downto 0);
    signal out_max_array : out_max_array_t;

    signal max_data_s : std_logic_vector(DATA_WIDTH_g -1 downto 0);

begin

    -- Optional: Assert config sanity
    assert (NUMBER_IN_DATA_g mod SPLIT_DATA_NUM_g = 0)
        report "NUMBER_IN_DATA_g must be divisible by SPLIT_DATA_NUM_g"
        severity failure;
    -- check mode of pipeline
    assert PIPELINE_MODE = "ACTIVE" or PIPELINE_MODE = "NOT_ACTIVE"
        report "PIPELINE MODE must be only active or not active"
        severity failure;
    -- check timing if not active pipeline used 
	assert PIPELINE_MODE = "NOT_ACTIVE" and NUMBER_IN_DATA_g < 5
		report "NOT ACTIVE PIPELINE; NUMBER OF INPUT SHALL LESS THAN 5"
		severity warning;
	       

   pipeline_mode_active : if PIPELINE_MODE = "ACTIVE" generate
    -- Split input data
    split_data_gen : for i in 0 to SPLIT_DATA_NUM_g -1 generate
        current_data_array(i) <= data(((i+1) * split_data_c * DATA_WIDTH_g -1) downto (i * split_data_c * DATA_WIDTH_g));
    end generate;
    -- Filter minimum per segment
    filter_min : for i in 0 to SPLIT_DATA_NUM_g -1 generate
        filter_min_proc : process(clk)
            variable temp : unsigned(DATA_WIDTH_g -1 downto 0);
            variable word : unsigned(DATA_WIDTH_g -1 downto 0);
        begin
            if rising_edge(clk) then
                if rst = '1' then
                    out_max_array(i) <= (others => '0');
                else
                    temp := unsigned(current_data_array(i)(DATA_WIDTH_g -1 downto 0));
                    for j in 1 to split_data_c - 1 loop
                        word := unsigned(current_data_array(i)((DATA_WIDTH_g*(j+1))-1 downto (DATA_WIDTH_g*j)));
                        if word >= temp then
                            temp := word;
                        end if;
                    end loop;
                    out_max_array(i) <= std_logic_vector(temp);
                end if;
            end if;
        end process;
    end generate;

    -- Global minimum from sub-mins
    min_array : process(clk)
        variable temp_min : unsigned(DATA_WIDTH_g -1 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                temp_min := (others => '0');
                max_data_s <= (others => '0');
            else
                temp_min := unsigned(out_max_array(0));
                for i in 1 to SPLIT_DATA_NUM_g -1 loop
                    if unsigned(out_max_array(i)) >= temp_min then
                        temp_min := unsigned(out_max_array(i));
                    end if;
                end loop;
                max_data_s <= std_logic_vector(temp_min);
            end if;
        end if;
    end process;
   end generate pipeline_mode_active;
   
   pipeline_mode_not_active : if PIPELINE_MODE = "NOT_ACTIVE" generate
      max_value_proc : process (clk) 
        variable temp : unsigned (DATA_WIDTH_g -1 downto 0);
        variable word : unsigned (DATA_WIDTH_g -1 downto 0);
        begin
            if rising_edge (clk) then
                if rst = '1' then
                    max_data_s <= (others => '0');
                    temp := (others => '0');
                    word := (others => '0');
                else
                    temp := unsigned(data(DATA_WIDTH_g -1 downto 0));
                    for i in 1 to NUMBER_IN_DATA_g -1 loop
                        word := unsigned (data( ((i +1)* DATA_WIDTH_g) -1 downto i* DATA_WIDTH_g ));
                        if (word >= temp) then
                            temp := word;
                        end if;
                    end loop;
                    
                    max_data_s <= std_logic_vector(temp);
                end if;
            end if;
        end process;
   end generate pipeline_mode_not_active;

    max_data <= max_data_s;

end Behavioral;
