--
--  File Name:         Tb_send_data.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Validates Stream Model Independent Transactions
--      Send, Get, Check with 2nd parameter, with ID, Dest, User
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    10/2020   2020.10    Initial revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2018 - 2020 by SynthWorks Design Inc.  
--  
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--  
--      https://www.apache.org/licenses/LICENSE-2.0
--  
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.TestCtrl
--  


architecture AxiSendGet2 of TestCtrl is
  use      osvvm.ScoreboardPkg_slv.all;
  signal   TestDone : integer_barrier := 1 ;
  signal   SB : ScoreboardIDType;

   
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  
  ControlProc : process
  begin
    SetTestName("Tb_send_data");
    TranscriptOpen;
    SetTranscriptMirror(TRUE);
    SetLogEnable(PASSED, FALSE);
    SetLogEnable(INFO, FALSE);
    

    -- Wait for testbench initialization 
    wait for 0 ns;
    wait until nReset = '1' ; 
	SB <= NEWID ("Score_Board"); 
    ClearAlerts;
    WaitForBarrier(TestDone, 10 ms);
    AlertIf(now >= 10 ms, "Test finished due to timeout");
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");

    wait for 1 us;
    EndOfTestReports(ReportAll => TRUE);
    TranscriptClose;
    std.env.finish;
    wait;
  end process ControlProc;
  
  
  ------------------------------------------------------------
  -- AxiTransmitterProc
  --   Generate transactions for AxiTransmitter
  ------------------------------------------------------------
	AxiTransmitterProc : process
    variable rand_data : std_logic_vector (DATA_WIDTH - 1 downto 0);
begin
    wait until nReset = '1';
    WaitForClock(StreamTxRec, 2);

    log("Send 1000 words with incrementing index values");

    for J in 0 to 8 loop  -- 18 words instead of 1000 (check this later if you want exactly 1000)
        -- Convert loop index J to std_logic_vector of DATA_WIDTH bits
        rand_data := std_logic_vector(to_unsigned(J, DATA_WIDTH));
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
	variable ExpData : std_logic_vector(DATA_WIDTH-1 downto 0);
	variable RcvData : std_logic_vector(DATA_WIDTH-1 downto 0);
	variable data_r : std_logic_vector (23 downto 0);
	begin
	WaitForClock(StreamRxRec, 2);
	
	log("Receive and check 1000 incrementing values");
	
	ExpData := (others => '0');
	for J in 0 to 2 loop
		Get(StreamRxRec, RcvData);
		data_r :=RcvData(23 downto 0);
		if (J = 0) then
			AffirmIfEqual(data_r, x"020100", "Data received and matched");
	    elsif (J = 1) then 
			AffirmIfEqual(data_r, x"050403", "Data received and matched");
		else 
			AffirmIfEqual(data_r, x"080706", "Data received and matched");
		end if;
	end loop;
	
	WaitForClock(StreamRxRec, 2);
	WaitForBarrier(TestDone);
	wait;
  end process AxiReceiverProc;


end AxiSendGet2 ;

Configuration Tb_send_data of TestHarness_fifo is
  for TestHarness
    for TestCtrl_5 : TestCtrl
      use entity work.TestCtrl(AxiSendGet2) ; 
    end for ; 
  end for ; 
end Tb_send_data ; 
