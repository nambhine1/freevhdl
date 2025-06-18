library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wrapper_olo_axi_lite_slave is
    generic (
        AxiAddrWidth_g    : positive := 10;  -- 1024 bytes = 10 bits
        AxiDataWidth_g    : positive := 32;  -- 32 bits = 4 bytes
        ReadTimeoutClks_g : positive := 100
    );
    port (
        Clk               : in  std_logic;
        Rst               : in  std_logic;

        -- AXI-Lite Interface
        S_AxiLite_ArAddr  : in  std_logic_vector(AxiAddrWidth_g - 1 downto 0);
        S_AxiLite_ArValid : in  std_logic;
        S_AxiLite_ArReady : out std_logic;

        S_AxiLite_AwAddr  : in  std_logic_vector(AxiAddrWidth_g - 1 downto 0);
        S_AxiLite_AwValid : in  std_logic;
        S_AxiLite_AwReady : out std_logic;

        S_AxiLite_WData   : in  std_logic_vector(AxiDataWidth_g - 1 downto 0);
        S_AxiLite_WStrb   : in  std_logic_vector((AxiDataWidth_g / 8) - 1 downto 0);
        S_AxiLite_WValid  : in  std_logic;
        S_AxiLite_WReady  : out std_logic;

        S_AxiLite_BResp   : out std_logic_vector(1 downto 0);
        S_AxiLite_BValid  : out std_logic;
        S_AxiLite_BReady  : in  std_logic;

        S_AxiLite_RData   : out std_logic_vector(AxiDataWidth_g - 1 downto 0);
        S_AxiLite_RResp   : out std_logic_vector(1 downto 0);
        S_AxiLite_RValid  : out std_logic;
        S_AxiLite_RReady  : in  std_logic
    );
end entity;

architecture rtl of wrapper_olo_axi_lite_slave is

    constant BytesPerWord_c : integer := AxiDataWidth_g / 8;
    constant AddrShift_c    : integer := 2;  -- 2^2 = 4 bytes = 32 bits per word

    -- Number of 32-bit words in memory
    constant WordCount_c : integer := 2 ** (AxiAddrWidth_g - AddrShift_c);

    type Ram_t is array (0 to WordCount_c - 1) of std_logic_vector(AxiDataWidth_g - 1 downto 0);
    signal Ram : Ram_t := (others => (others => '0'));

    -- Register interface
    signal Rb_Addr    : std_logic_vector(AxiAddrWidth_g - 1 downto 0) := (others => '0');
    signal Rb_Wr      : std_logic  := '0';
    signal Rb_ByteEna : std_logic_vector((AxiDataWidth_g / 8) - 1 downto 0) := (others => '1');
    signal Rb_WrData  : std_logic_vector(AxiDataWidth_g - 1 downto 0) := (others => '0');
    signal Rb_Rd      : std_logic  := '0';
    signal Rb_RdData  : std_logic_vector(AxiDataWidth_g - 1 downto 0) := (others => '0');
    signal Rb_RdValid : std_logic := '0';

begin

    -- Instantiate AXI-Lite slave
    U_Slave : entity work.olo_axi_lite_slave
        generic map (
            AxiAddrWidth_g    => AxiAddrWidth_g,
            AxiDataWidth_g    => AxiDataWidth_g,
            ReadTimeoutClks_g => ReadTimeoutClks_g
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

    -- BRAM access process
    p_bram : process (Clk)
        variable WordAddr : integer;
    begin
        if rising_edge(Clk) then
            -- Address conversion (manual shift by 2 = divide by 4)
            WordAddr := to_integer(unsigned(Rb_Addr(AxiAddrWidth_g - 1 downto AddrShift_c)));

            -- Write
            if Rb_Wr = '1' then
                for i in 0 to BytesPerWord_c - 1 loop
                    if Rb_ByteEna(i) = '1' then
                        Ram(WordAddr)(8*i+7 downto 8*i) <= Rb_WrData(8*i+7 downto 8*i);
                    end if;
                end loop;
            end if;

            -- Read
            if Rb_Rd = '1' then
                Rb_RdData  <= Ram(WordAddr);
                Rb_RdValid <= '1';
            else
                Rb_RdValid <= '0';
            end if;
        end if;
    end process;

end architecture;
