library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
  context osvvm.OsvvmContext ;

library osvvm_Axi4 ;
  context osvvm_Axi4.Axi4LiteContext ;
  context osvvm_AXI4.AxiStreamContext ;

entity TbAxi4 is
end entity TbAxi4 ;
architecture TestHarness of TbAxi4 is
  constant AXI_ADDR_WIDTH : integer := 32 ;
  constant AXI_DATA_WIDTH : integer := 32 ;
  constant AXI_STRB_WIDTH : integer := AXI_DATA_WIDTH/8 ;

  constant tperiod_Clk : time := 10 ns ;
  constant tpd         : time := 2 ns ;

  signal Clk         : std_logic ;
  signal nReset      : std_logic ;
  
  
  constant AXI_BYTE_WIDTH   : integer := AXI_DATA_WIDTH/8 ; 
  constant TID_MAX_WIDTH    : integer := 8 ;
  constant TDEST_MAX_WIDTH  : integer := 4 ;
  constant TUSER_MAX_WIDTH  : integer := 5 ;

  constant INIT_ID     : std_logic_vector(TID_MAX_WIDTH-1 downto 0)   := (others => '0') ; 
  constant INIT_DEST   : std_logic_vector(TDEST_MAX_WIDTH-1 downto 0) := (others => '0') ; 
  constant INIT_USER   : std_logic_vector(TUSER_MAX_WIDTH-1 downto 0) := (others => '0') ; 
  
  signal TxTValid, RxTValid    : std_logic ;
  signal TxTReady, RxTReady    : std_logic ; 
  signal TxTID   , RxTID       : std_logic_vector(TID_MAX_WIDTH-1 downto 0) ; 
  signal TxTDest , RxTDest     : std_logic_vector(TDEST_MAX_WIDTH-1 downto 0) ; 
  signal TxTUser , RxTUser     : std_logic_vector(TUSER_MAX_WIDTH-1 downto 0) ; 
  signal TxTData , RxTData     : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ; 
  signal TxTStrb , RxTStrb     : std_logic_vector(AXI_BYTE_WIDTH-1 downto 0) ; 
  signal TxTKeep , RxTKeep     : std_logic_vector(AXI_BYTE_WIDTH-1 downto 0) ; 
  signal TxTLast , RxTLast     : std_logic ; 
  
  constant AXI_PARAM_WIDTH : integer := TID_MAX_WIDTH + TDEST_MAX_WIDTH + TUSER_MAX_WIDTH + 1 ;

  signal StreamTxRec, StreamRxRec : StreamRecType(
      DataToModel   (AXI_DATA_WIDTH-1  downto 0),
      DataFromModel (AXI_DATA_WIDTH-1  downto 0),
      ParamToModel  (AXI_PARAM_WIDTH-1 downto 0),
      ParamFromModel(AXI_PARAM_WIDTH-1 downto 0)
    ) ;  

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
    Clk            : In    std_logic ;
    nReset         : In    std_logic ;

    -- Transaction Interfaces
    ManagerRec     : inout AddressBusRecType;
	-- Transaction Interfaces
    StreamTxRec        : InOut StreamRecType ;
    StreamRxRec        : InOut StreamRecType 
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
  
  
  Transmitter_1 : AxiStreamTransmitter 
    generic map (
      INIT_ID        => INIT_ID  , 
      INIT_DEST      => INIT_DEST, 
      INIT_USER      => INIT_USER, 
      INIT_LAST      => 0,

      tperiod_Clk    => tperiod_Clk,

      tpd_Clk_TValid => tpd, 
      tpd_Clk_TID    => tpd, 
      tpd_Clk_TDest  => tpd, 
      tpd_Clk_TUser  => tpd, 
      tpd_Clk_TData  => tpd, 
      tpd_Clk_TStrb  => tpd, 
      tpd_Clk_TKeep  => tpd, 
      tpd_Clk_TLast  => tpd 
    ) 
    port map (
      -- Globals
      Clk       => Clk,
      nReset    => nReset,
      
      -- AXI Stream Interface
      -- From TB Transmitter to DUT Receiver
      TValid    => RxTValid,
      TReady    => RxTReady,
      TID       => RxTID   ,
      TDest     => RxTDest ,
      TUser     => RxTUser ,
      TData     => RxTData ,
      TStrb     => RxTStrb ,
      TKeep     => RxTKeep ,
      TLast     => RxTLast ,

      -- Testbench Transaction Interface
      TransRec  => StreamTxRec
    ) ;
  
  Receiver_1 : AxiStreamReceiver
    generic map (
      tperiod_Clk    => tperiod_Clk,
      INIT_ID        => INIT_ID  , 
      INIT_DEST      => INIT_DEST, 
      INIT_USER      => INIT_USER, 
      INIT_LAST      => 0,

      tpd_Clk_TReady => tpd  
    ) 
    port map (
      -- Globals
      Clk       => Clk,
      nReset    => nReset,
      
      -- AXI Stream Interface
      -- From TB Receiver to DUT Transmitter
      TValid    => TxTValid,
      TReady    => TxTReady,
      TID       => TxTID   ,
      TDest     => TxTDest ,
      TUser     => TxTUser ,
      TData     => TxTData ,
      TStrb     => TxTStrb ,
      TKeep     => TxTKeep ,
      TLast     => TxTLast ,

      -- Testbench Transaction Interface
      TransRec  => StreamRxRec
    ) ;



  TestCtrl_1 : TestCtrl
  port map (
    -- Globals
    Clk            => Clk,
    nReset         => nReset,

    -- Testbench Transaction Interfaces
    ManagerRec     => ManagerRec,
	
	StreamTxRec   => StreamTxRec,
	StreamRxRec   => StreamRxRec
	
	
  ) ;
  
DUT : entity work.axi_lite_ram_wrapper
    generic map (
        C_S00_AXI_DATA_WIDTH => AXI_DATA_WIDTH,
        C_S00_AXI_ADDR_WIDTH => AXI_ADDR_WIDTH
    )
    port map (
        -- AXI Clock and Reset
        s00_axi_aclk    => Clk,
        s00_axi_aresetn => nReset,

        -- AXI Write Address Channel
        s00_axi_awaddr  => AxiBus.WriteAddress.Addr,
        s00_axi_awprot  => (others => '0'),  -- You can customize this if needed
        s00_axi_awvalid => AxiBus.WriteAddress.Valid,
        s00_axi_awready => AxiBus.WriteAddress.Ready,

        -- AXI Write Data Channel
        s00_axi_wdata   => AxiBus.WriteData.Data,
        s00_axi_wstrb   => AxiBus.WriteData.Strb,
        s00_axi_wvalid  => AxiBus.WriteData.Valid,
        s00_axi_wready  => AxiBus.WriteData.Ready,

        -- AXI Write Response Channel
        s00_axi_bresp   => AxiBus.WriteResponse.Resp,
        s00_axi_bvalid  => AxiBus.WriteResponse.Valid,
        s00_axi_bready  => AxiBus.WriteResponse.Ready,

        -- AXI Read Address Channel
        s00_axi_araddr  => AxiBus.ReadAddress.Addr,
        s00_axi_arprot  => (others => '0'),  -- You can customize this if needed
        s00_axi_arvalid => AxiBus.ReadAddress.Valid,
        s00_axi_arready => AxiBus.ReadAddress.Ready,

        -- AXI Read Data Channel
        s00_axi_rdata   => AxiBus.ReadData.Data,
        s00_axi_rresp   => AxiBus.ReadData.Resp,
        s00_axi_rvalid  => AxiBus.ReadData.Valid,
        s00_axi_rready  => AxiBus.ReadData.Ready,
		
		-- stream from master
		s_valid  =>  RxTValid,
		s_ready  =>  RxTReady,
		s_data   =>  RxTData,
		
		-- stream to slave   
		m_valid   =>  TxTValid,
		m_ready   =>  TxTReady,
		m_data    =>  TxTData
    );

	
  
  

end architecture TestHarness ;