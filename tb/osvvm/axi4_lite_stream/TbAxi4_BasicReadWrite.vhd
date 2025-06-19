architecture BasicReadWrite of TestCtrl is
  use    osvvm.ScoreboardPkg_slv.all;
  signal TestDone : integer_barrier := 1 ;
  signal Req_1 : AlertLogIDType;
  signal SB : ScoreboardIDType;

begin
  ------------------------------------------------------------
  -- ControlProc
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetTestName("TbAxi4_BasicReadWrite");
    TranscriptOpen;
    SetTranscriptMirror(TRUE);
    SetLogEnable(PASSED, FALSE);    -- Enable PASSED logs
    SetLogEnable(INFO, FALSE);      -- Enable INFO logs
	
	Req_1 <= GetReqID("PR-0001", PassedGoal => 1, ParentID => REQUIREMENT_ALERTLOG_ID);
 
    -- Wait for Design Reset
    wait until nReset = '1';
    ClearAlerts;
    LOG("Start of Transactions");

    -- Wait for test to finish
    WaitForBarrier(TestDone, 5 ms);
    AlertIf(now >= 35 ms, "Test finished due to timeout");
    AlertIf(GetAffirmCount < 500, "Test is not Self-Checking");
	
	AffirmIf(Req_1, GetAlertCount = 0, GetTestName & "REQUIREMENT Req_1 FAILED!!!!!") ;

    wait for 1 us;

    EndOfTestReports(ReportAll => TRUE);
    TranscriptClose;
    std.env.stop;
    wait;
  end process ControlProc;
  
  ------------------------------------------------------------
  -- ManagerProc
  ------------------------------------------------------------
  ManagerProc : process
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
    variable data_send : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
    variable expect_data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
    variable valu : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  begin
    -- Initialization
    wait until nReset = '1';
    WaitForClock(ManagerRec, 2);

    -- Write loop
    for int_value in 0 to 511 loop
      valu := std_logic_vector(to_unsigned(int_value, AXI_ADDR_WIDTH));
      data_send := std_logic_vector(to_unsigned(int_value, AXI_DATA_WIDTH));
      Write(ManagerRec, valu*4, data_send);
      wait for 10 ns; -- Wait for 10 ns between values
    end loop;

    -- Read loop
    for int_value in 0 to 511 loop
      valu := std_logic_vector(to_unsigned(int_value, AXI_ADDR_WIDTH));
      expect_data := std_logic_vector(to_unsigned(int_value, AXI_DATA_WIDTH));
      Read(ManagerRec, valu*4, Data);
      AffirmIfEqual(Data, expect_data, "Manager Read Data: ");
      wait for 10 ns; -- Wait for 10 ns between values
    end loop;

    WaitForClock(ManagerRec, 2);
    WaitForBarrier(TestDone);
    wait;
  end process ManagerProc;



  ------------------------------------------------------------
  -- AxiTransmitterProc
  --   Generate transactions for AxiTransmitter
  ------------------------------------------------------------
    AxiTransmitterProc : process
		variable rv : RandomPType;
		variable rand_data : std_logic_vector (AXI_DATA_WIDTH - 1 downto 0);
	begin
		wait until nReset = '1';
		WaitForClock(StreamTxRec, 2);
		
		rv.InitSeed("AxiTransmitterProc");  -- Use string literal or integer seed
	
		log("Send 1000 words with random values");
	
		for J in 0 to 999 loop  -- 1000 words
			rand_data := x"00000001";  -- match DATA_WIDTH
			Push(SB, rand_data);
			Send(StreamTxRec, rand_data);
		end loop;
	
		WaitForClock(StreamTxRec, 2);
		WaitForBarrier(TestDone);
		wait;
	end process AxiTransmitterProc;
	

  ------------------------------------------------------------
  -- AxiReceiverProc
  --   Generate transactions for AxiReceiver
  ------------------------------------------------------------
   AxiReceiverProc : process
	variable ExpData : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	variable RcvData : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	begin
	WaitForClock(StreamRxRec, 2);
	
	log("Receive and check 1000 incrementing values");
	
	ExpData := (others => '0');
	for J in 0 to 999 loop
		Get(StreamRxRec, RcvData);
		log("Data Received: " & to_hstring(RcvData), Level => DEBUG);
		Check(SB,RcvData);
	end loop;
	
	WaitForClock(StreamRxRec, 2);
	WaitForBarrier(TestDone);
	wait;
  end process AxiReceiverProc;
   
end BasicReadWrite;

Configuration TbAxi4_BasicReadWrite of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(BasicReadWrite) ; 
    end for ; 
  end for ; 
end TbAxi4_BasicReadWrite ; 

