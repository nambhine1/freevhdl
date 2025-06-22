library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;
    use work.olo_base_pkg_math.all;
    use work.olo_base_pkg_attribute.all;
    use work.olo_base_pkg_string.all;

entity olo_private_ram_sdp_nobe is
    generic (
        Depth_g         : positive;
        Width_g         : positive;
        IsAsync_g       : boolean  := false;
        RdLatency_g     : positive := 1;
        RamStyle_g      : string   := "auto";
        RamBehavior_g   : string   := "RBW";
        InitString_g    : string   := "";
        InitFormat_g    : string   := "NONE";
        InitWidth_g     : positive;
        InitShift_g     : natural  := 0
    );
    port (
        Clk         : in    std_logic;
        Wr_Addr     : in    std_logic_vector(log2ceil(Depth_g) - 1 downto 0);
        Wr_Ena      : in    std_logic := '1';
        Wr_Data     : in    std_logic_vector(Width_g - 1 downto 0);
        Rd_Clk      : in    std_logic := '0';
        Rd_Addr     : in    std_logic_vector(log2ceil(Depth_g) - 1 downto 0);
        Rd_Ena      : in    std_logic := '1';
        Rd_Data     : out   std_logic_vector(Width_g - 1 downto 0)
    );
end entity;

architecture rtl of olo_private_ram_sdp_nobe is

    type Data_t is array (natural range <>) of std_logic_vector(Width_g - 1 downto 0);
    signal Mem_v : Data_t(Depth_g - 1 downto 0);

    signal RdPipe : Data_t(1 to RdLatency_g);

    attribute shreg_extract of RdPipe : signal is ShregExtract_SuppressExtraction_c;
    attribute ram_style of Mem_v    : signal is RamStyle_g;
    attribute ramstyle of Mem_v     : signal is RamStyle_g;
    attribute syn_ramstyle of Mem_v : signal is RamStyle_g;

    function getInitContent return Data_t is
        variable Data_v         : Data_t(Depth_g - 1 downto 0)               := (others => (others => '0'));
        constant InitElements_c : natural                                    := countOccurence(InitString_g, ',')+1;
        variable StartIdx_v     : natural                                    := InitString_g'left;
        variable EndIdx_v       : natural;
        variable FullInitVal_v  : std_logic_vector(InitWidth_g - 1 downto 0) := (others => '0');
    begin
        if InitFormat_g /= "NONE" then
            for i in 0 to InitElements_c - 1 loop
                EndIdx_v := StartIdx_v;
                loop
                    if InitString_g(EndIdx_v) = ',' then
                        EndIdx_v := EndIdx_v - 1;
                        exit;
                    end if;
                    if EndIdx_v = InitString_g'right then
                        exit;
                    end if;
                    EndIdx_v := EndIdx_v + 1;
                end loop;
                FullInitVal_v := hex2StdLogicVector(InitString_g(StartIdx_v to EndIdx_v), InitWidth_g, hasPrefix => true);
                Data_v(i)     := FullInitVal_v(InitShift_g + Width_g - 1 downto InitShift_g);
                StartIdx_v    := EndIdx_v + 2;
            end loop;
        end if;
        return Data_v;
    end function;

    -- Simulation-only initialization process
    -- pragma translate_off
    initialization : process
    begin
        Mem_v <= getInitContent;
        wait;
    end process;
    -- pragma translate_on

begin

    assert InitFormat_g = "NONE" or InitFormat_g = "HEX"
        report "olo_base_ram_sdp: InitFormat_g must be NONE or HEX. Got: " & InitFormat_g
        severity error;

    assert RamBehavior_g = "RBW" or RamBehavior_g = "WBR"
        report "olo_base_ram_sdp: RamBehavior_g must Be RBW or WBR. Got: " & RamBehavior_g
        severity error;

    g_sync : if not IsAsync_g generate
        p_ram : process (Clk) is
        begin
            if rising_edge(Clk) then
                if RamBehavior_g = "RBW" then
                    if Rd_Ena = '1' then
                        RdPipe(1) <= Mem_v(to_integer(unsigned(Rd_Addr)));
                    end if;
                end if;

                if Wr_Ena = '1' then
                    Mem_v(to_integer(unsigned(Wr_Addr))) <= Wr_Data;
                end if;

                if RamBehavior_g = "WBR" then
                    if Rd_Ena = '1' then
                        RdPipe(1) <= Mem_v(to_integer(unsigned(Rd_Addr)));
                    end if;
                end if;

                RdPipe(2 to RdLatency_g) <= RdPipe(1 to RdLatency_g - 1);
            end if;
        end process;
    end generate;

    g_async : if IsAsync_g generate
        p_write : process (Clk) is
        begin
            if rising_edge(Clk) then
                if Wr_Ena = '1' then
                    Mem_v(to_integer(unsigned(Wr_Addr))) <= Wr_Data;
                end if;
            end if;
        end process;

        p_read : process (Rd_Clk) is
        begin
            if rising_edge(Rd_Clk) then
                if Rd_Ena = '1' then
                    RdPipe(1) <= Mem_v(to_integer(unsigned(Rd_Addr)));
                end if;
                RdPipe(2 to RdLatency_g) <= RdPipe(1 to RdLatency_g - 1);
            end if;
        end process;
    end generate;

    Rd_Data <= RdPipe(RdLatency_g);

end architecture;
