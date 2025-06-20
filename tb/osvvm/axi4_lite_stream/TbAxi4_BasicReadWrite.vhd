architecture BasicReadWrite of TestCtrl is
  use    osvvm.ScoreboardPkg_slv.all;
  signal TestDone : integer_barrier := 1 ;
  signal Req_1, Req_2 : AlertLogIDType;
  signal SB : ScoreboardIDType;
  signal send_inv_image : std_logic := '0';

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
    Req_2 <= GetReqID("PR-0002", PassedGoal => 1, ParentID => REQUIREMENT_ALERTLOG_ID);
    -- Wait for Design Reset
    wait until nReset = '1';
	SB <= NEWID ("Score_Board"); 
    ClearAlerts;
    LOG("Start of Transactions");

    -- Wait for test to finish
    WaitForBarrier(TestDone, 5 ms);
    AlertIf(now >= 35 ms, "Test finished due to timeout");
    AlertIf(GetAffirmCount < 500, "Test is not Self-Checking");
	
	AffirmIf(Req_1, GetAlertCount = 0, GetTestName & "REQUIREMENT Req_1 FAILED!!!!!") ;
    AffirmIf(Req_2, GetAlertCount = 0, GetTestName & "REQUIREMENT Req_2 FAILED!!!!!") ;
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
	
	send_inv_image <= '1';
	valu := std_logic_vector(to_unsigned(0, AXI_ADDR_WIDTH));
    data_send := std_logic_vector(to_unsigned(1, AXI_DATA_WIDTH));
    Write(ManagerRec, valu*4, data_send);
	
	

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
	    variable TxData  : std_logic_vector(AXI_DATA_WIDTH - 1 downto 0);
		variable Inv_data : std_logic_vector(AXI_DATA_WIDTH - 1 downto 0);
		variable pixel_val : unsigned(7 downto 0);
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
		
		wait until send_inv_image = '1';
		
		WaitForClock(StreamTxRec, 25);
	    TxData := (others => '0');  -- Start from 0
	
		for J in 0 to 500 loop
			-- Process each 8-bit lane of the 32-bit data word
			for i in 0 to 3 loop
				pixel_val := unsigned(TxData((i+1)*8 - 1 downto i*8));
				Inv_data((i+1)*8 - 1 downto i*8) := std_logic_vector(to_unsigned(255 - to_integer(pixel_val), 8));
			end loop;
	
			Push(SB, Inv_data);       -- Expected inverted data
			Send(StreamTxRec, TxData); -- Send original data
	
			-- Optional: increment TxData (to simulate incrementing pixel pattern)
			TxData := std_logic_vector(unsigned(TxData) + 1);
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
	
    for J in 0 to 500 loop
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

