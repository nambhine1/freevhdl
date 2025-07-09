--
--  File Name:         TestHarness_fifo.vhd
--  Design Unit Name:  TestHarness_fifo
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Top level testbench for AxiStreamTransmitter and AxiStreamReceiver
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    07/2024   2024.07    Updated CreateClock
--    01/2023   2023.01    Added DUT (pass thru)
--    10/2020   2020.10    Updated name to be TestHarness_fifo.vhd in conjunction with Model Indepenedent Transactions
--    01/2020   2020.01    Updated license notice
--    05/2018   2018.05    Initial revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2018 - 2024 by SynthWorks Design Inc.  
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
--  limitations under the License.
--  
library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
    context osvvm.OsvvmContext ;
    
library osvvm_AXI4 ;
    context osvvm_AXI4.AxiStreamContext ;
    
entity TestHarness_fifo is
end entity TestHarness_fifo ; 
architecture TestHarness of TestHarness_fifo is

  constant tperiod_Clk : time := 10 ns ; 
  constant tpd         : time := 2 ns ; 

  signal Clk       : std_logic := '1' ;
  signal nReset    : std_logic ;
  
  constant AXI_DATA_WIDTH   : integer := 32 ;
  constant AXI_BYTE_WIDTH   : integer := AXI_DATA_WIDTH/8 ; 
  constant TID_MAX_WIDTH    : integer := 8 ;
  constant TDEST_MAX_WIDTH  : integer := 4 ;
  constant TUSER_MAX_WIDTH  : integer := 5 ;

  constant INIT_ID     : std_logic_vector(TID_MAX_WIDTH-1 downto 0)   := (others => '0') ; 
  constant INIT_DEST   : std_logic_vector(TDEST_MAX_WIDTH-1 downto 0) := (others => '0') ; 
  constant INIT_USER   : std_logic_vector(TUSER_MAX_WIDTH-1 downto 0) := (others => '0') ; 
  
  signal TxTValid, RxTValid_y    : std_logic ;
  signal TxTReady, RxTReady_y    : std_logic ; 
  signal TxTID   , RxTID_y       : std_logic_vector(TID_MAX_WIDTH-1 downto 0) ; 
  signal TxTDest , RxTDest_y     : std_logic_vector(TDEST_MAX_WIDTH-1 downto 0) ; 
  signal TxTUser , RxTUser_y     : std_logic_vector(TUSER_MAX_WIDTH-1 downto 0) ; 
  signal TxTData , RxTData_y     : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ; 
  signal TxTStrb , RxTStrb_y     : std_logic_vector(AXI_BYTE_WIDTH-1 downto 0) ; 
  signal TxTKeep , RxTKeep_y     : std_logic_vector(AXI_BYTE_WIDTH-1 downto 0) ; 
  signal TxTLast , RxTLast_y     : std_logic ; 
  
  signal  RxTValid_u    : std_logic ;
  signal  RxTReady_u    : std_logic ; 
  signal  RxTID_u       : std_logic_vector(TID_MAX_WIDTH-1 downto 0) ; 
  signal  RxTDest_u     : std_logic_vector(TDEST_MAX_WIDTH-1 downto 0) ; 
  signal  RxTUser_u     : std_logic_vector(TUSER_MAX_WIDTH-1 downto 0) ; 
  signal  RxTData_u     : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ; 
  signal  RxTStrb_u     : std_logic_vector(AXI_BYTE_WIDTH-1 downto 0) ; 
  signal  RxTKeep_u     : std_logic_vector(AXI_BYTE_WIDTH-1 downto 0) ; 
  signal  RxTLast_u     : std_logic ; 
  
  
  signal  RxTValid_v    : std_logic ;
  signal  RxTReady_v    : std_logic ; 
  signal  RxTID_v      : std_logic_vector(TID_MAX_WIDTH-1 downto 0) ; 
  signal  RxTDest_v     : std_logic_vector(TDEST_MAX_WIDTH-1 downto 0) ; 
  signal  RxTUser_v    : std_logic_vector(TUSER_MAX_WIDTH-1 downto 0) ; 
  signal  RxTData_v    : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ; 
  signal  RxTStrb_v     : std_logic_vector(AXI_BYTE_WIDTH-1 downto 0) ; 
  signal  RxTKeep_v    : std_logic_vector(AXI_BYTE_WIDTH-1 downto 0) ; 
  signal  RxTLast_v     : std_logic ; 
  
  
  constant AXI_PARAM_WIDTH : integer := TID_MAX_WIDTH + TDEST_MAX_WIDTH + TUSER_MAX_WIDTH + 1 ;

  signal StreamTxRec_y, StreamTxRec_u, StreamTxRec_v , StreamRxRec : StreamRecType(
      DataToModel   (AXI_DATA_WIDTH-1  downto 0),
      DataFromModel (AXI_DATA_WIDTH-1  downto 0),
      ParamToModel  (AXI_PARAM_WIDTH-1 downto 0),
      ParamFromModel(AXI_PARAM_WIDTH-1 downto 0)
    ) ;  
  

  component TestCtrl is
    generic ( 
      ID_LEN       : integer ;
      DEST_LEN     : integer ;
      USER_LEN     : integer 
    ) ;
    port (
      -- Global Signal Interface
      nReset          : In    std_logic ;

      -- Transaction Interfaces
      StreamTxRec_y     : inout StreamRecType ;
	  StreamTxRec_u     : inout StreamRecType ;
	  StreamTxRec_v     : inout StreamRecType ;
      StreamRxRec     : inout StreamRecType 
    ) ;
  end component TestCtrl ;

  
begin

	-- Instance of interleave_yuv
	interleave_inst : entity work.interleave_yuv
	generic map (
		DATA_WIDTH_g => AXI_DATA_WIDTH  -- match your data width
	)
	port map (
		clk       => clk,
		rst       => not nReset,
		
		s_valid_y => RxTValid_y,
		s_ready_y => RxTReady_y,
		s_data_y  => RxTData_y,
		
		s_valid_u => RxTValid_u,
		s_ready_u => RxTReady_u,
		s_data_u  => RxTData_u,
		
		s_valid_v => RxTValid_v,
		s_ready_v => RxTReady_v,
		s_data_v  => RxTData_v,
		
		m_valid   => TxTValid,
		m_ready   => TxTReady,
		m_data    => TxTData
	);
	
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
      TValid    => RxTValid_y,
      TReady    => RxTReady_y,
      TID       => RxTID_y   ,
      TDest     => RxTDest_y ,
      TUser     => RxTUser_y ,
      TData     => RxTData_y ,
      TStrb     => RxTStrb_y ,
      TKeep     => RxTKeep_y ,
      TLast     => RxTLast_y ,

      -- Testbench Transaction Interface
      TransRec  => StreamTxRec_y
    ) ;
	
	
	Transmitter_2 : AxiStreamTransmitter 
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
      TValid    => RxTValid_u,
      TReady    => RxTReady_u,
      TID       => RxTID_u   ,
      TDest     => RxTDest_u ,
      TUser     => RxTUser_u ,
      TData     => RxTData_u ,
      TStrb     => RxTStrb_u ,
      TKeep     => RxTKeep_u ,
      TLast     => RxTLast_u ,

      -- Testbench Transaction Interface
      TransRec  => StreamTxRec_u
    ) ;
	
	Transmitter_3 : AxiStreamTransmitter 
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
      TValid    => RxTValid_v,
      TReady    => RxTReadv_v,
      TID       => RxTID_v   ,
      TDest     => RxTDest_v ,
      TUser     => RxTUser_v ,
      TData     => RxTData_v ,
      TStrb     => RxTStrb_v ,
      TKeep     => RxTKeep_v ,
      TLast     => RxTLast_v ,

      -- Testbench Transaction Interface
      TransRec  => StreamTxRec_v
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
  
  
  TestCtrl_5 : TestCtrl
  generic map ( 
    ID_LEN       => TxTID'length,
    DEST_LEN     => TxTDest'length,
    USER_LEN     => TxTUser'length
  ) 
  port map ( 
    -- Globals
    nReset       => nReset,
    
    -- Testbench Transaction Interfaces
    StreamTxRec_y  => StreamTxRec_y, 
	StreamTxRec_u  => StreamTxRec_u, 
	StreamTxRec_v  => StreamTxRec_v, 
    StreamRxRec  => StreamRxRec  
  ) ; 

end architecture TestHarness ;
