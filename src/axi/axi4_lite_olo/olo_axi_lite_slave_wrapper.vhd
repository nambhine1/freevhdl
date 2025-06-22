library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity olo_axi_lite_slave_wrapper is
    generic (
        AxiAddrWidth_g      : positive := 8;
        AxiDataWidth_g      : positive := 32;
        ReadTimeoutClks_g   : positive := 100
    );
    port (
        -- Clock and Reset
        Clk               : in  std_logic;
        Rst               : in  std_logic;

        -- AXI-Lite Interface
        -- AR channel
        S_AxiLite_ArAddr  : in  std_logic_vector(AxiAddrWidth_g - 1 downto 0);
        S_AxiLite_ArValid : in  std_logic;
        S_AxiLite_ArReady : out std_logic;

        -- AW channel
        S_AxiLite_AwAddr  : in  std_logic_vector(AxiAddrWidth_g - 1 downto 0);
        S_AxiLite_AwValid : in  std_logic;
        S_AxiLite_AwReady : out std_logic;

        -- W channel
        S_AxiLite_WData   : in  std_logic_vector(AxiDataWidth_g - 1 downto 0);
        S_AxiLite_WStrb   : in  std_logic_vector((AxiDataWidth_g / 8) - 1 downto 0);
        S_AxiLite_WValid  : in  std_logic;
        S_AxiLite_WReady  : out std_logic;

        -- B channel
        S_AxiLite_BResp   : out std_logic_vector(1 downto 0);
        S_AxiLite_BValid  : out std_logic;
        S_AxiLite_BReady  : in  std_logic;

        -- R channel
        S_AxiLite_RData   : out std_logic_vector(AxiDataWidth_g - 1 downto 0);
        S_AxiLite_RResp   : out std_logic_vector(1 downto 0);
        S_AxiLite_RValid  : out std_logic;
        S_AxiLite_RReady  : in  std_logic
    );
end entity;

architecture rtl of olo_axi_lite_slave_wrapper is

    -- Derived constant for memory depth
    constant MemDepth_c : integer := 2 ** AxiAddrWidth_g;

    -- Register Bus signals
    signal Rb_Addr    : std_logic_vector(AxiAddrWidth_g - 1 downto 0);
    signal Rb_Wr      : std_logic;
    signal Rb_ByteEna : std_logic_vector((AxiDataWidth_g / 8) - 1 downto 0);
    signal Rb_WrData  : std_logic_vector(AxiDataWidth_g - 1 downto 0);
    signal Rb_Rd      : std_logic;
    signal Rb_RdData  : std_logic_vector(AxiDataWidth_g - 1 downto 0);
    signal Rb_RdValid : std_logic;

    -- Memory declaration
    type mem_type is array (0 to MemDepth_c - 1) of std_logic_vector(AxiDataWidth_g - 1 downto 0);
    signal mem : mem_type := (others => (others => '0'));

begin

    -- AXI-Lite Slave Instantiation
    u_axi_lite_slave : entity work.olo_axi_lite_slave
        generic map (
            AxiAddrWidth_g     => AxiAddrWidth_g,
            AxiDataWidth_g     => AxiDataWidth_g,
            ReadTimeoutClks_g  => ReadTimeoutClks_g
        )
        port map (
            Clk               => Clk,
            Rst               => Rst,
            S_AxiLite_ArAddr  => S_AxiLite_ArAddr,
            S_AxiLite_ArValid => S_AxiLite_ArValid,
            S_AxiLite_ArReady => S_AxiLite_ArReady,
            S_AxiLite_AwAddr  => S_AxiLite_AwAddr,
            S_AxiLite_AwValid => S_AxiLite_AwValid,
            S_AxiLite_AwReady => S_AxiLite_AwReady,
            S_AxiLite_WData   => S_AxiLite_WData,
            S_AxiLite_WStrb   => S_AxiLite_WStrb,
            S_AxiLite_WValid  => S_AxiLite_WValid,
            S_AxiLite_WReady  => S_AxiLite_WReady,
            S_AxiLite_BResp   => S_AxiLite_BResp,
            S_AxiLite_BValid  => S_AxiLite_BValid,
            S_AxiLite_BReady  => S_AxiLite_BReady,
            S_AxiLite_RData   => S_AxiLite_RData,
            S_AxiLite_RResp   => S_AxiLite_RResp,
            S_AxiLite_RValid  => S_AxiLite_RValid,
            S_AxiLite_RReady  => S_AxiLite_RReady,
            Rb_Addr           => Rb_Addr,
            Rb_Wr             => Rb_Wr,
            Rb_ByteEna        => Rb_ByteEna,
            Rb_WrData         => Rb_WrData,
            Rb_Rd             => Rb_Rd,
            Rb_RdData         => Rb_RdData,
            Rb_RdValid        => Rb_RdValid
        );

    -- Register/memory read/write logic
    process (Clk)
        variable addr_v : integer;
    begin
        if rising_edge(Clk) then
            addr_v := to_integer(unsigned(Rb_Addr));

            -- Write operation
            if Rb_Wr = '1' then
                if addr_v < MemDepth_c then
                    mem(addr_v) <= Rb_WrData;
                end if;
            end if;

            -- Read operation
            if Rb_Rd = '1' then
                if addr_v < MemDepth_c then
                    Rb_RdData <= mem(addr_v);
                    Rb_RdValid <= '1';
                else
                    Rb_RdData <= (others => '0');
                    Rb_RdValid <= '0';
                end if;
            else
                Rb_RdValid <= '0';
            end if;
        end if;
    end process;

end architecture;
