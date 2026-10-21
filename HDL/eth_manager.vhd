-- Top-level integration for the 64-bit 10G Ethernet datapath.
-- Connects the MAC wrapper, TX stream FIFO, and command/register bridge.
-- The Vivado top entity is eth_manager; see README.md for integration limits.

library ieee;
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all ;
use ieee.std_logic_unsigned.all ;
use ieee.std_logic_misc.all ;
library unisim;
use unisim.vcomponents.all;
use work.Reg_pack_comint.ALL;

entity eth_manager is
    port (
        -- Active-high system reset; Soft_Reset also reaches the TX command path.
        sys_rst                          : in    std_logic;
        Soft_Reset                       : in    std_logic;
        -- Differential 156.25 MHz transceiver reference clock from the board.
        mgt_clk_n                        : in    std_logic;
        mgt_clk_p                        : in    std_logic;

        LED1                             : out   std_logic;
        sfp_txn                          : out   std_logic;
        sfp_txp                          : out   std_logic;

        sfp_rxn                          : in    std_logic;
        sfp_rxp                          : in    std_logic;
        -- Legacy configuration interface; the former AXI-Lite controller is inactive.
        control_data                     : in    std_logic_vector(7 downto 0);
        control_valid                    : in    std_logic;
        control_ready                    : out   std_logic;
        trx_axis_tvalid                  : out   std_logic;
        start_config                     : in    std_logic;

        clk_100MHz                       : in    std_logic;
        C156_25M_tx_Clk                  : out   std_logic;
        C156_25M_rx_Clk                  : out   std_logic;
        -- User payload write interface in wr_clk; stop writes when wr_ready is low.
        wr_ready                         : inout std_logic;
        wr_clk                           : in    std_logic;
        wr_en                            : in    std_logic;
        wr_last                          : in    std_logic;
        wr_data                          : in    std_logic_vector(Bus_width-1 downto 0);
        -- Received payload is read as bytes in rd_clk; data_len reports frame length.
        rd_ready                         : out   std_logic;
        rd_clk                           : in    std_logic;
        rd_en                            : in    std_logic;
        rd_data                          : inout std_logic_vector(7 downto 0);
        rd_data_count                    : out   std_logic_vector(11 downto 0);
        data_len                         : out   std_logic_vector(15 downto 0) ;
        -- Command code and byte length are queued together in CMD_clk.
        CMD_CODE                         : in    std_logic_vector(15 downto 0);
        CMD_length                       : in    std_logic_vector(15 downto 0);
        CMD_clk                          : in    std_logic;
        CMD_en                           : in    std_logic;
        -- Received terminal writes and externally supplied terminal reply data.
        TRMOUT_clk                       : out   std_logic;
        TRMOUT_EN                        : out   std_logic;
        TRMOUT_Addr                      : out   std_logic_vector(7 downto 0);
        TRMOUT_Data                      : out   std_logic_vector(63 downto 0);

        TRMIN_clk                        : in    std_logic;
        TRMIN_EN                         : in    std_logic;
        TRMIN_Addr                       : in    std_logic_vector(7 downto 0);
        TRMIN_Data                       : in    std_logic_vector(63 downto 0);
        -- 128 command/status registers, each 64 bits wide (Reg_pack_comint).
        command_updates                  : out   std_logic_vector(NOofreg-1  downto 0);
        command_registers                : out   std_logic_reg_array(NOofreg-1 downto 0);
        status_registers                 : in    std_logic_reg_array(NOofreg-1 downto 0);
        read_only_regs                   : in    std_logic_vector(NOofreg-1 downto 0);

        mtrlb_pktchk_error               : out   std_logic;
        mtrlb_activity_flash             : out   std_logic

    );
end eth_manager;

architecture wrapper of eth_manager is

    constant mtrlb_en_cs_offload                 : std_logic_vector(1 downto 0)  := "00"  ;
    constant mtrlb_config_dest_addr              : std_logic_vector(47 downto 0)  := x"DA0102030405"   ;
    constant mtrlb_config_src_addr               : std_logic_vector(47 downto 0)  := x"5A0102030405"   ;
    constant mtrlb_config_vlan_id                : std_logic_vector(11 downto 0)  := x"000"            ;
    constant mtrlb_config_vlan_priority          : std_logic_vector(2 downto 0)  :=  "000"            ;
    constant mtrlb_config_ip_dest_addr           : std_logic_vector(31 downto 0)  := x"DA060708"       ;
    constant mtrlb_config_ip_src_addr            : std_logic_vector(31 downto 0)  := x"5A060708"       ;
    constant mtrlb_config_tcp_dest_port          : std_logic_vector(15 downto 0)  := x"DA09"           ;
    constant mtrlb_config_tcp_src_port           : std_logic_vector(15 downto 0)  := x"5A09"           ;
    constant mtrlb_config_udp_dest_port          : std_logic_vector(15 downto 0)  := x"DA0A"           ;
    constant mtrlb_config_udp_src_port           : std_logic_vector(15 downto 0)  := x"5A0A"           ;
    constant mtrlb_config_min_size               : std_logic_vector(15 downto 0)  := x"0040"           ;
    constant mtrlb_config_max_size               : std_logic_vector(15 downto 0)  := x"4000"           ;
    constant mtrlb_da_sa_swap_en                 : std_logic  := '0'               ;
    COMPONENT Gtx_fifo_generator
      PORT (
        wr_rst_busy                      : OUT   STD_LOGIC;
        rd_rst_busy                      : OUT   STD_LOGIC;
        s_aclk                           : IN    STD_LOGIC;
        s_aresetn                        : IN    STD_LOGIC;
        s_axis_tvalid                    : IN    STD_LOGIC;
        s_axis_tready                    : OUT   STD_LOGIC;
        s_axis_tdata                     : IN    STD_LOGIC_VECTOR(63 DOWNTO 0);
        s_axis_tkeep                     : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
        s_axis_tlast                     : IN    STD_LOGIC;
        m_axis_tvalid                    : OUT   STD_LOGIC;
        m_axis_tready                    : IN    STD_LOGIC;
        m_axis_tdata                     : OUT   STD_LOGIC_VECTOR(63 DOWNTO 0);
        m_axis_tkeep                     : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
        m_axis_tlast                     : OUT   STD_LOGIC
      );
    END COMPONENT;
    signal clkgen_gtx_clk                      : std_logic;

    signal pause_req_s_sync_gtx_clk            : std_logic;
    signal mac_speed_sync_gtx_clk              : std_logic_vector(1 downto 0);

    signal update_speed_sync_gtx_clk           : std_logic;
    signal config_board_sync_gtx_clk           : std_logic;

    signal gen_tx_data_sync_gtx_clk            : std_logic;
    signal chk_tx_data_sync_gtx_clk            : std_logic;

    signal Proc_Clk_300M_bufg                  : std_logic;
    signal Proc_Clk_50M_bufg                   : std_logic;
    signal clk_20M_bufg                        : std_logic;
    signal gtx_clk_bufg                        : std_logic;
    signal refclk_bufg                         : std_logic;
    signal s_axi_aclk                          : std_logic;

    signal rx_mac_aclk                         : std_logic;
    signal tx_mac_aclk                         : std_logic;
    signal phy_resetn_int                      : std_logic;
    signal vector_resetn                       : std_logic;
    signal chk_resetn                          : std_logic;

    signal gtx_resetn                          : std_logic;

    signal rx_reset                            : std_logic;
    signal tx_reset                            : std_logic;

    signal dcm_locked                          : std_logic;
    signal glbl_rst_int                        : std_logic;
    signal phy_reset_count                     : unsigned(5 downto 0) := (others => '0');
    signal glbl_rst_intn                       : std_logic;

    signal rx_fifo_clock                       : std_logic;
    signal rx_fifo_resetn                      : std_logic;

    signal rx_axis_tdata                       : std_logic_vector(63 downto 0);
    signal rx_axis_tvalid                      : std_logic;
    signal rx_axis_tlast                       : std_logic;
    signal rx_axis_tready                      : std_logic;
    signal Rx_axis_tkeep                       : std_logic_vector(7 downto 0);

    signal tx_fifo_clock                       : std_logic;
    signal tx_fifo_resetn                      : std_logic;
    signal tx_axis_tdata                       : std_logic_vector(63 downto 0);
    signal tx_axis_tvalid                      : std_logic;
    signal tx_axis_tlast                       : std_logic;
    signal tx_axis_tready                      : std_logic;
    signal enable_address_swap                 : std_logic := '1';

    signal axi_lite_resetn                     : std_logic;
    signal s_axi_araddr                        : std_logic_vector(17 downto 0);
    signal s_axi_arready                       : std_logic;
    signal s_axi_arvalid                       : std_logic;
    signal s_axi_awaddr                        : std_logic_vector(17 downto 0);
    signal s_axi_awready                       : std_logic;
    signal s_axi_awvalid                       : std_logic;
    signal s_axi_bready                        : std_logic;
    signal s_axi_bresp                         : std_logic_vector(1 downto 0);
    signal s_axi_bvalid                        : std_logic;
    signal s_axi_rdata                         : std_logic_vector(31 downto 0);
    signal s_axi_rready                        : std_logic;
    signal s_axi_rresp                         : std_logic_vector(1 downto 0);
    signal s_axi_rvalid                        : std_logic;
    signal s_axi_wdata                         : std_logic_vector(31 downto 0);
    signal s_axi_wready                        : std_logic;
    signal s_axi_wvalid                        : std_logic;
    signal sys_out_rst                         : std_logic;

    signal m_axis_tkeep                        : std_logic_vector(7 downto 0);
    signal m_axis_tdata                        : std_logic_vector(63 downto 0);
    signal m_axis_tlast                        : std_logic;
    signal m_axis_tready                       : std_logic;
    signal m_axis_tvalid                       : std_logic;
    signal m_axis_tuser                        : std_logic;

    signal tx_axis_tkeep                       : std_logic_vector(7 downto 0);
    signal tx_axis_mac_tdata                   : std_logic_vector(63 downto 0);
    signal tx_axis_mac_tlast                   : std_logic;
    signal tx_axis_mac_tready                  : std_logic;
    signal tx_axis_mac_tuser                   : std_logic;
    signal tx_axis_mac_tvalid                  : std_logic;
    signal rx_axis_mac_tdata                   : std_logic_vector(7 downto 0);
    signal rx_axis_mac_tlast                   : std_logic;
    signal rx_axis_mac_tuser                   : std_logic;
    signal rx_axis_mac_tvalid                  : std_logic;

    signal ref_clk_50_bufg                     : std_logic;
    signal axi_lite_clk                        : std_logic;
    signal soft_rst                            : std_logic;
    signal axis_rstn                           : std_logic;
    signal rx_clk_lan,tx_clk_lan               : std_logic;

    signal signal_detect                       : std_logic := '1';
    signal status_vector                       : std_logic_vector(15 downto 0);
    signal loopback_master_slaven, slvlb_en_l2_addr_swap, mtrlb_en_packet_gen, mtrlb_en_packet_chk, mtrlb_en_pkt_drop_chk, mtrlb_reset_error : std_logic;
    signal pat_chk_ctrl, ex_des_cl, ex_des_blink_on_tx : std_logic ;
    signal mtrlb_line_speed                    : std_logic_vector(1 downto 0);
    signal mtrlb_select_packet_type            : std_logic_vector(4 downto 0);

    signal stat_tx_packet_small                : STD_LOGIC;
    signal stat_tx_packet_large                : STD_LOGIC;
    signal stat_tx_unicast                     : STD_LOGIC;
    signal stat_tx_multicast                   : STD_LOGIC;
    signal stat_tx_broadcast                   : STD_LOGIC;
    signal stat_tx_vlan                        : STD_LOGIC;
    signal stat_tx_frame_error                 : STD_LOGIC;
    signal ctl_tx_test_pattern_en              : STD_LOGIC;
    signal patgen_rstn                         : STD_LOGIC;
    signal sRx_axis_tdata                      : STD_LOGIC_VECTOR(63 DOWNTO 0);
   attribute DowngradeIPIdentifiedWarnings: string;
   attribute DowngradeIPIdentifiedWarnings of wrapper : architecture is "yes";

begin
C156_25M_tx_Clk <= tx_clk_lan;
C156_25M_rx_Clk <= rx_clk_lan;

trx_axis_tvalid <= m_axis_tvalid or rx_axis_tvalid;

-- MAC and transceiver wrapper: stream data and generated LAN clocks.
Inst_gtx :entity work.gtx
        Port map
        (
        reset                            => sys_rst,
        refclk_p                         => mgt_clk_p,
        refclk_n                         => mgt_clk_n,
        clk_100MHz                       => clk_100MHz,
        rx_clk_lan                       => rx_clk_lan,
        tx_clk_lan                       => tx_clk_lan,
        txp                              => sfp_txp,
        txn                              => sfp_txn,
        rxp                              => sfp_rxp,
        rxn                              => sfp_rxn,
        LOSS                             => '0',

        stat_tx_packet_small             => stat_tx_packet_small    ,
        stat_tx_packet_large             => stat_tx_packet_large    ,
        stat_tx_unicast                  => stat_tx_unicast         ,
        stat_tx_multicast                => stat_tx_multicast       ,
        stat_tx_broadcast                => stat_tx_broadcast       ,
        stat_tx_vlan                     => stat_tx_vlan            ,
        stat_tx_frame_error              => stat_tx_frame_error     ,
        ctl_tx_test_pattern_en           => ctl_tx_test_pattern_en  ,

        Tx_axis_tready                   => m_axis_tready,
        Tx_axis_aresetn                  => '1',
        Tx_axis_tdata                    => m_axis_tdata,
        Tx_axis_tvalid                   => m_axis_tvalid,
        Tx_axis_tlast                    => m_axis_tlast,
        Tx_axis_tuser                    => "0",
        Tx_axis_tkeep                    => m_axis_tkeep,
        Tx_ifg_delay                     => x"0F",

        Rx_axis_aresetn                  => axi_lite_resetn,
        Rx_axis_tdata                    => rx_axis_tdata,
        Rx_axis_tvalid                   => rx_axis_tvalid,
        Rx_axis_tuser                    => open,
        Rx_axis_tlast                    => rx_axis_tlast,
        Rx_axis_tkeep                    => Rx_axis_tkeep
        );

-- Buffer the outgoing stream in tx_clk_lan and propagate MAC backpressure.
mem  : Gtx_fifo_generator
  PORT MAP (
        wr_rst_busy                      => open,
        rd_rst_busy                      => open,
        s_aclk                           => tx_clk_lan,

        s_aresetn                        => not(sys_rst),

        s_axis_tkeep                     => tx_axis_tkeep,
        s_axis_tvalid                    => tx_axis_tvalid,
        s_axis_tready                    => tx_axis_tready,
        s_axis_tdata                     => tx_axis_tdata,
        s_axis_tlast                     => tx_axis_tlast,

        m_axis_tvalid                    => m_axis_tvalid,
        m_axis_tready                    => m_axis_tready,
        m_axis_tkeep                     => m_axis_tkeep,
        m_axis_tdata                     => m_axis_tdata,
        m_axis_tlast                     => m_axis_tlast
  );

    -- Retained byte-reversed RX view from the former server interface; currently unused.
    sRx_axis_tdata(63 downto 56) <= rx_axis_tdata( 7 downto  0);
    sRx_axis_tdata(55 downto 48) <= rx_axis_tdata(15 downto  8);
    sRx_axis_tdata(47 downto 40) <= rx_axis_tdata(23 downto 16);
    sRx_axis_tdata(39 downto 32) <= rx_axis_tdata(31 downto 24);
    sRx_axis_tdata(31 downto 24) <= rx_axis_tdata(39 downto 32);
    sRx_axis_tdata(23 downto 16) <= rx_axis_tdata(47 downto 40);
    sRx_axis_tdata(15 downto  8) <= rx_axis_tdata(55 downto 48);
    sRx_axis_tdata( 7 downto  0) <= rx_axis_tdata(63 downto 56);

   -- The active path disables MAC test-pattern control. Soft_Reset is handled in TX.
   ctl_tx_test_pattern_en <= '0';
   patgen_rstn <= ((not(sys_rst)));
 -- Bridge user data, command queues, register access, and the MAC streams.
 basic_pat_gen_inst : entity work.ethernet_mac_RGMII_basic_pat_gen
   port map (
        axi_tclk                         => tx_clk_lan,
        axi_rclk                         => rx_clk_lan,
        axi_tresetn                      => patgen_rstn,
        Soft_Reset                       => Soft_Reset,

        enable_pat_gen                   => gen_tx_data_sync_gtx_clk,
        enable_pat_chk                   => chk_tx_data_sync_gtx_clk,
        enable_address_swap              => enable_address_swap,
        speed                            => "11",
        wr_ready                         => wr_ready,
        wr_clk                           => wr_clk,
        wr_en                            => wr_en,
        wr_last                          => wr_last,
        wr_data                          => WR_data,

        rd_ready                         => rd_ready,
        rd_clk                           => rd_clk,
        rd_en                            => rd_en,
        rd_data                          => rd_data,
        rd_data_count                    => rd_data_count ,
        data_len                         => data_len ,

        CMD_CODE                         => CMD_CODE,
        CMD_length                       => CMD_length,
        CMD_clk                          => CMD_clk,
        CMD_en                           => CMD_en,

        TRMOUT_clk                       => TRMOUT_clk   ,
        TRMOUT_EN                        => TRMOUT_EN   ,
        TRMOUT_Addr                      => TRMOUT_Addr ,
        TRMOUT_Data                      => TRMOUT_Data ,

        TRMIN_clk                        => TRMIN_clk    ,
        TRMIN_EN                         => TRMIN_EN    ,
        TRMIN_Addr                       => TRMIN_Addr  ,
        TRMIN_Data                       => TRMIN_Data  ,

        command_updates                  => command_updates,
        command_registers                => command_registers,
        status_registers                 => status_registers,
        read_only_regs                   => read_only_regs,
        rx_axis_tdata                    => rx_axis_tdata ,
        rx_axis_tvalid                   => rx_axis_tvalid,
        rx_axis_tlast                    => rx_axis_tlast ,
        rx_axis_tuser                    => '0',
        rx_axis_tready                   => rx_axis_tready,

        tx_axis_tdata                    => tx_axis_tdata  ,
        tx_axis_tvalid                   => tx_axis_tvalid,
        tx_axis_tlast                    => tx_axis_tlast  ,
        tx_axis_tready                   => tx_axis_tready,
        tx_axis_tkeep                    => tx_axis_tkeep,

        stat_tx_packet_small             => stat_tx_packet_small    ,
        stat_tx_packet_large             => stat_tx_packet_large    ,
        stat_tx_unicast                  => stat_tx_unicast         ,
        stat_tx_multicast                => stat_tx_multicast       ,
        stat_tx_broadcast                => stat_tx_broadcast       ,
        stat_tx_vlan                     => stat_tx_vlan            ,
        stat_tx_frame_error              => stat_tx_frame_error     ,

        frame_error                      => mtrlb_pktchk_error,
        activity_flash                   => mtrlb_activity_flash
   );

end wrapper;
