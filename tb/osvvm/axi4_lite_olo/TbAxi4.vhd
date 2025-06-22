library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
  context osvvm.OsvvmContext ;

library osvvm_Axi4 ;
  context osvvm_Axi4.Axi4LiteContext ;

entity TbAxi4 is
end entity TbAxi4 ;
architecture TestHarness of TbAxi4 is
  constant AXI_ADDR_WIDTH : integer := 8 ;
  constant AXI_DATA_WIDTH : integer := 32 ;
  constant AXI_STRB_WIDTH : integer := AXI_DATA_WIDTH/8 ;

  constant tperiod_Clk : time := 10 ns ;
  constant tpd         : time := 2 ns ;

  signal Clk         : std_logic ;
  signal nReset      : std_logic ;

  signal ManagerRec  : AddressBusRecType(
          Address(AXI_ADDR_WIDTH-1 downto 0),
          DataToModel(AXI_DATA_WIDTH-1 downto 0),
          DataFromModel(AXI_DATA_WIDTH-1 downto 0)
        ) ;

--  -- AXI Manager Functional Interface
  signal   AxiBus : Axi4LiteRecType(
    WriteAddress( Addr (AXI_ADDR_WIDTH-1 downto 0) ),
    WriteData   ( Data (AXI_DATA_WIDTH-1 downto 0),   Strb(AXI_STRB_WIDTH-1 downto 0) ),
    ReadAddress ( Addr (AXI_ADDR_WIDTH-1 downto 0) ),
    ReadData    ( Data (AXI_DATA_WIDTH-1 downto 0) )
  ) ;


  component TestCtrl is
    port (
      -- Global Signal Interface
      Clk                 : In    std_logic ;
      nReset              : In    std_logic ;

      -- Transaction Interfaces
      ManagerRec          : inout AddressBusRecType 
    ) ;
  end component TestCtrl ;


begin

  -- create Clock
  Osvvm.ClockResetPkg.CreateClock (
    Clk        => Clk,
    Period     => Tperiod_Clk
  )  ;

  -- create nReset
  Osvvm.ClockResetPkg.CreateReset (
    Reset       => nReset,
    ResetActive => '0',
    Clk         => Clk,
    Period      => 7 * tperiod_Clk,
    tpd         => tpd
  ) ;


  Manager_1 : Axi4LiteManager
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- AXI Manager Functional Interface
    AxiBus      => AxiBus,

    -- Testbench Transaction Interface
    TransRec    => ManagerRec
  ) ;



  TestCtrl_1 : TestCtrl
  port map (
    -- Globals
    Clk            => Clk,
    nReset         => nReset,

    -- Testbench Transaction Interfaces
    ManagerRec     => ManagerRec
  ) ;
  
  DUT : entity work.olo_axi_lite_slave_wrapper
    generic map (
        AxiAddrWidth_g     => AXI_ADDR_WIDTH,
        AxiDataWidth_g     => AXI_DATA_WIDTH,
        ReadTimeoutClks_g  => 100  -- You can override if needed
    )
    port map (
        -- Clock and Reset
        Clk               => Clk,
        Rst               => not nReset,  -- Active-high reset

        -- Read Address Channel
        S_AxiLite_ArAddr  => AxiBus.ReadAddress.Addr,
        S_AxiLite_ArValid => AxiBus.ReadAddress.Valid,
        S_AxiLite_ArReady => AxiBus.ReadAddress.Ready,

        -- Write Address Channel
        S_AxiLite_AwAddr  => AxiBus.WriteAddress.Addr,
        S_AxiLite_AwValid => AxiBus.WriteAddress.Valid,
        S_AxiLite_AwReady => AxiBus.WriteAddress.Ready,

        -- Write Data Channel
        S_AxiLite_WData   => AxiBus.WriteData.Data,
        S_AxiLite_WStrb   => AxiBus.WriteData.Strb,
        S_AxiLite_WValid  => AxiBus.WriteData.Valid,
        S_AxiLite_WReady  => AxiBus.WriteData.Ready,

        -- Write Response Channel
        S_AxiLite_BResp   => AxiBus.WriteResponse.Resp,
        S_AxiLite_BValid  => AxiBus.WriteResponse.Valid,
        S_AxiLite_BReady  => AxiBus.WriteResponse.Ready,

        -- Read Data Channel
        S_AxiLite_RData   => AxiBus.ReadData.Data,
        S_AxiLite_RResp   => AxiBus.ReadData.Resp,
        S_AxiLite_RValid  => AxiBus.ReadData.Valid,
        S_AxiLite_RReady  => AxiBus.ReadData.Ready
    );


end architecture TestHarness ;