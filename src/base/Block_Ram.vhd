----------------------------------------------------------------------------------
-- Description:
--   This module implements a synchronous block RAM with configurable depth and 
--   data width. The address width is computed using a clog2 function.
--
--   The RAM supports two operational modes defined by the generic RAM_MODE:
--     - "RBW" (Read Before Write): 
--         The output reflects the old data at the address when write and read 
--         occur in the same clock cycle.
--     - "WBR" (Write Before Read): 
--         The new data is written first, and then immediately read back in the 
--         same cycle.
--
--   Features:
--     • Generic parameters: RAM_DEPTH, DATA_WIDTH, RAM_MODE
--     • CLOG2-based address width calculation
--     • Synchronous read/write with clock
--     • Asynchronous reset of output register
--     • Assertion checks for valid RAM_MODE configuration
--
-- Notes:
--   • Compatible with VHDL-2008 (for use of clog2 in port/generic expressions)
--   • Suitable for synthesis with tools like Xilinx Vivado
--   • Intended for behavioral simulation and FPGA implementation
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.math_utils.all;

entity Block_Ram is
  generic (
    RAM_DEPTH  : integer := 32;
    DATA_WIDTH : integer := 32;
    RAM_MODE : string := "WBR" -- Write Before Read/ Read Before Write
  );
  port (
    clk  : in  std_logic;
    rst  : in  std_logic;
    
    -- memory interface
    we   : in  std_logic;
    addr : in  std_logic_vector (clog2(RAM_DEPTH) - 1 downto 0);
    din  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    dout : out std_logic_vector(DATA_WIDTH - 1 downto 0)
  );
end entity;

architecture Behavioral of Block_Ram is
    signal dout_reg : std_logic_vector (DATA_WIDTH -1 downto 0) := (others => '0');
    type ram_type is array (0 to RAM_DEPTH - 1) of std_logic_vector (DATA_WIDTH -1 downto 0);
    signal ram_mem : ram_type := (others => (others => '0'));
    begin
        dout <= dout_reg;
        
        assert (RAM_MODE = "RBW" or RAM_MODE = "WBR")
          report "CONFIGURATION OF RAM_MODE IS WRONG"
          severity failure;

        ram_op : process (clk)
          begin
            if rising_edge (clk) then
                if rst = '1' then
                    dout_reg <= (others => '0');
                else
                    if (RAM_MODE = "RBW") then
                        -- read before write 
                        dout_reg <= ram_mem(to_integer(unsigned(addr)));
                        if (we = '1') then
                            ram_mem (to_integer(unsigned(addr))) <= din;
                        end if;   
                    else
                        -- write before read 
                         if (we = '1') then
                            ram_mem (to_integer(unsigned(addr))) <= din;
                         end if;
                         dout_reg <= ram_mem(to_integer(unsigned(addr)));          
                    end if;
                end if;
            end if;
          end process;
end architecture;
