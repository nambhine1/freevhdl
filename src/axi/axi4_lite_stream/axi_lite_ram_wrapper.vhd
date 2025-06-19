

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_lite_ram_wrapper is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 11
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line
		
		-- axi stream 
		s_valid : in std_logic;
		s_ready : out std_logic;
		s_data : in std_logic_vector (C_S00_AXI_DATA_WIDTH -1 downto 0);
		
		-- axi stream 
		m_valid : out std_logic;
		m_ready : in std_Logic;
		m_data : out std_logic_vector (C_S00_AXI_DATA_WIDTH -1 downto 0);
		
		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end axi_lite_ram_wrapper;

architecture arch_imp of axi_lite_ram_wrapper is
    signal select_mode_sig : std_logic;
begin

    -- Direct instantiation of the AXI Lite Slave using work.entity
    axi_lite_slave_inst : entity work.axi_lite_slave
        generic map (
            C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
            C_S_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH
        )
        port map (
            S_AXI_ACLK    => s00_axi_aclk,
            S_AXI_ARESETN => s00_axi_aresetn,
            S_AXI_AWADDR  => s00_axi_awaddr,
            S_AXI_AWPROT  => s00_axi_awprot,
            S_AXI_AWVALID => s00_axi_awvalid,
            S_AXI_AWREADY => s00_axi_awready,
            S_AXI_WDATA   => s00_axi_wdata,
            S_AXI_WSTRB   => s00_axi_wstrb,
            S_AXI_WVALID  => s00_axi_wvalid,
            S_AXI_WREADY  => s00_axi_wready,
            S_AXI_BRESP   => s00_axi_bresp,
            S_AXI_BVALID  => s00_axi_bvalid,
            S_AXI_BREADY  => s00_axi_bready,
            S_AXI_ARADDR  => s00_axi_araddr,
            S_AXI_ARPROT  => s00_axi_arprot,
            S_AXI_ARVALID => s00_axi_arvalid,
            S_AXI_ARREADY => s00_axi_arready,
            S_AXI_RDATA   => s00_axi_rdata,
            S_AXI_RRESP   => s00_axi_rresp,
            S_AXI_RVALID  => s00_axi_rvalid,
            S_AXI_RREADY  => s00_axi_rready,
            
            -- mode of axi stream
            select_mode_axis_stream => select_mode_sig
        );
        
       
        inst_image_inv  : entity work.image_inversion 
          generic map (
            DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
            BIT_PER_DATA => C_S00_AXI_DATA_WIDTH/4 
          )
          Port map  (
            clk => s00_axi_aclk,
            rst => s00_axi_aresetn,
            passthrough_sel => select_mode_sig,
            -- axi stream from master 
            s_valid => s_valid,
            s_ready => s_ready,
            s_data =>  s_data,
            
            -- axi stream to slave
            m_valid => m_valid,
            m_ready => m_ready,
            m_data => m_data
          );
end arch_imp;
