-- Legacy MAC wrapper retained for reference; not in the Vivado source set.
-- This variant contains two declarations of xxv_ethernet_0.
-- Reconcile those declarations before adding this file to a design.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
library UNISIM;
use UNISIM.VComponents.all;
entity gtx_Comint is
    Port
        (
        reset                            : in    std_logic;
        refclk_p                         : in    std_logic;
        refclk_n                         : in    std_logic;
        clk_100MHz                       : in    std_logic;
        tx_clk_lan                       : out   std_logic;
        rx_clk_lan                       : out   std_logic;
        txp                              : out   std_logic;
        txn                              : out   std_logic;
        rxp                              : in    std_logic;
        rxn                              : in    std_logic;
        LOSS                             : in    std_logic;
        stat_tx_packet_small             : OUT   STD_LOGIC;
        stat_tx_packet_large             : OUT   STD_LOGIC;
        stat_tx_unicast                  : OUT   STD_LOGIC;
        stat_tx_multicast                : OUT   STD_LOGIC;
        stat_tx_broadcast                : OUT   STD_LOGIC;
        stat_tx_vlan                     : OUT   STD_LOGIC;
        stat_tx_frame_error              : OUT   STD_LOGIC;
        ctl_tx_test_pattern_en           : in    STD_LOGIC;
        Tx_axis_tready                   : out   std_logic;
        Tx_axis_aresetn                  : in    std_logic;
        Tx_axis_tdata                    : in    std_logic_vector(63 downto 0);
        Tx_axis_tvalid                   : in    std_logic;
        Tx_axis_tlast                    : in    std_logic;
        Tx_axis_tuser                    : in    std_logic_vector(0 downto 0);
        Tx_axis_tkeep                    : in    std_logic_vector(7 downto 0);
        Tx_ifg_delay                     : in    std_logic_vector(7 downto 0);
        Rx_axis_aresetn                  : in    std_logic;
        Rx_axis_tdata                    : out   std_logic_vector(63 downto 0);
        Rx_axis_tvalid                   : out   std_logic;
        Rx_axis_tuser                    : out   std_logic;
        Rx_axis_tlast                    : out   std_logic;
        Rx_axis_tkeep                    : out   std_logic_vector(7 downto 0)
        );
end gtx_Comint;
architecture Behavioral of gtx_Comint is
COMPONENT xxv_ethernet_1
  PORT (
        gt_rxp_in_0                      : IN    STD_LOGIC;
        gt_rxn_in_0                      : IN    STD_LOGIC;
        gt_txp_out_0                     : OUT   STD_LOGIC;
        gt_txn_out_0                     : OUT   STD_LOGIC;
        rx_core_clk_0                    : IN    STD_LOGIC;
        txoutclksel_in_0                 : IN    STD_LOGIC_VECTOR(2 DOWNTO 0);
        rxoutclksel_in_0                 : IN    STD_LOGIC_VECTOR(2 DOWNTO 0);
        gtwiz_reset_tx_datapath_0        : IN    STD_LOGIC;
        gtwiz_reset_rx_datapath_0        : IN    STD_LOGIC;
        rxrecclkout_0                    : OUT   STD_LOGIC;
        sys_reset                        : IN    STD_LOGIC;
        dclk                             : IN    STD_LOGIC;
        tx_clk_out_0                     : OUT   STD_LOGIC;
        rx_clk_out_0                     : OUT   STD_LOGIC;
        gt_refclk_p                      : IN    STD_LOGIC;
        gt_refclk_n                      : IN    STD_LOGIC;
        gt_refclk_out                    : OUT   STD_LOGIC;
        gtpowergood_out_0                : OUT   STD_LOGIC;
        rx_reset_0                       : IN    STD_LOGIC;
        user_rx_reset_0                  : OUT   STD_LOGIC;
        rx_axis_tvalid_0                 : OUT   STD_LOGIC;
        rx_axis_tdata_0                  : OUT   STD_LOGIC_VECTOR(63 DOWNTO 0);
        rx_axis_tlast_0                  : OUT   STD_LOGIC;
        rx_axis_tkeep_0                  : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
        rx_axis_tuser_0                  : OUT   STD_LOGIC;
    -- Receive enabled, with preamble/SFD checks and FCS removal.
        ctl_rx_enable_0                  : IN    STD_LOGIC;
        ctl_rx_check_preamble_0          : IN    STD_LOGIC;
        ctl_rx_check_sfd_0               : IN    STD_LOGIC;
        ctl_rx_force_resync_0            : IN    STD_LOGIC;
        ctl_rx_delete_fcs_0              : IN    STD_LOGIC;
        ctl_rx_ignore_fcs_0              : IN    STD_LOGIC;
        ctl_rx_max_packet_len_0          : IN    STD_LOGIC_VECTOR(14 DOWNTO 0);
        ctl_rx_min_packet_len_0          : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
        ctl_rx_process_lfi_0             : IN    STD_LOGIC;
        ctl_rx_test_pattern_0            : IN    STD_LOGIC;
        ctl_rx_data_pattern_select_0     : IN    STD_LOGIC;
        ctl_rx_test_pattern_enable_0     : IN    STD_LOGIC;
        stat_rx_framing_err_0            : OUT   STD_LOGIC;
        stat_rx_framing_err_valid_0      : OUT   STD_LOGIC;
        stat_rx_local_fault_0            : OUT   STD_LOGIC;
        stat_rx_block_lock_0             : OUT   STD_LOGIC;
        stat_rx_valid_ctrl_code_0        : OUT   STD_LOGIC;
        stat_rx_status_0                 : OUT   STD_LOGIC;
        stat_rx_remote_fault_0           : OUT   STD_LOGIC;
        stat_rx_bad_fcs_0                : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
        stat_rx_stomped_fcs_0            : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
        stat_rx_truncated_0              : OUT   STD_LOGIC;
        stat_rx_internal_local_fault_0   : OUT   STD_LOGIC;
        stat_rx_received_local_fault_0   : OUT   STD_LOGIC;
        stat_rx_hi_ber_0                 : OUT   STD_LOGIC;
        stat_rx_got_signal_os_0          : OUT   STD_LOGIC;
        stat_rx_test_pattern_mismatch_0  : OUT   STD_LOGIC;
        stat_rx_total_bytes_0            : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
        stat_rx_total_packets_0          : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
        stat_rx_total_good_bytes_0       : OUT   STD_LOGIC_VECTOR(13 DOWNTO 0);
        stat_rx_total_good_packets_0     : OUT   STD_LOGIC;
        stat_rx_packet_bad_fcs_0         : OUT   STD_LOGIC;
        stat_rx_packet_64_bytes_0        : OUT   STD_LOGIC;
        stat_rx_packet_65_127_bytes_0    : OUT   STD_LOGIC;
        stat_rx_packet_128_255_bytes_0   : OUT   STD_LOGIC;
        stat_rx_packet_256_511_bytes_0   : OUT   STD_LOGIC;
        stat_rx_packet_512_1023_bytes_0  : OUT   STD_LOGIC;
        stat_rx_packet_1024_1518_bytes_0 : OUT   STD_LOGIC;
        stat_rx_packet_1519_1522_bytes_0 : OUT   STD_LOGIC;
        stat_rx_packet_1523_1548_bytes_0 : OUT   STD_LOGIC;
        stat_rx_packet_1549_2047_bytes_0 : OUT   STD_LOGIC;
        stat_rx_packet_2048_4095_bytes_0 : OUT   STD_LOGIC;
        stat_rx_packet_4096_8191_bytes_0 : OUT   STD_LOGIC;
        stat_rx_packet_8192_9215_bytes_0 : OUT   STD_LOGIC;
        stat_rx_packet_small_0           : OUT   STD_LOGIC;
        stat_rx_packet_large_0           : OUT   STD_LOGIC;
        stat_rx_unicast_0                : OUT   STD_LOGIC;
        stat_rx_multicast_0              : OUT   STD_LOGIC;
        stat_rx_broadcast_0              : OUT   STD_LOGIC;
        stat_rx_oversize_0               : OUT   STD_LOGIC;
        stat_rx_toolong_0                : OUT   STD_LOGIC;
        stat_rx_undersize_0              : OUT   STD_LOGIC;
        stat_rx_fragment_0               : OUT   STD_LOGIC;
        stat_rx_vlan_0                   : OUT   STD_LOGIC;
        stat_rx_inrangeerr_0             : OUT   STD_LOGIC;
        stat_rx_jabber_0                 : OUT   STD_LOGIC;
        stat_rx_bad_code_0               : OUT   STD_LOGIC;
        stat_rx_bad_sfd_0                : OUT   STD_LOGIC;
        stat_rx_bad_preamble_0           : OUT   STD_LOGIC;
        tx_reset_0                       : IN    STD_LOGIC;
        user_tx_reset_0                  : OUT   STD_LOGIC;
        tx_axis_tready_0                 : OUT   STD_LOGIC;
        tx_axis_tvalid_0                 : IN    STD_LOGIC;
        tx_axis_tdata_0                  : IN    STD_LOGIC_VECTOR(63 DOWNTO 0);
        tx_axis_tlast_0                  : IN    STD_LOGIC;
        tx_axis_tkeep_0                  : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
        tx_axis_tuser_0                  : IN    STD_LOGIC;
        tx_unfout_0                      : OUT   STD_LOGIC;
        stat_tx_local_fault_0            : OUT   STD_LOGIC;
        stat_tx_total_bytes_0            : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
        stat_tx_total_packets_0          : OUT   STD_LOGIC;
        stat_tx_total_good_bytes_0       : OUT   STD_LOGIC_VECTOR(13 DOWNTO 0);
        stat_tx_total_good_packets_0     : OUT   STD_LOGIC;
        stat_tx_bad_fcs_0                : OUT   STD_LOGIC;
        stat_tx_packet_64_bytes_0        : OUT   STD_LOGIC;
        stat_tx_packet_65_127_bytes_0    : OUT   STD_LOGIC;
        stat_tx_packet_128_255_bytes_0   : OUT   STD_LOGIC;
        stat_tx_packet_256_511_bytes_0   : OUT   STD_LOGIC;
        stat_tx_packet_512_1023_bytes_0  : OUT   STD_LOGIC;
        stat_tx_packet_1024_1518_bytes_0 : OUT   STD_LOGIC;
        stat_tx_packet_1519_1522_bytes_0 : OUT   STD_LOGIC;
        stat_tx_packet_1523_1548_bytes_0 : OUT   STD_LOGIC;
        stat_tx_packet_1549_2047_bytes_0 : OUT   STD_LOGIC;
        stat_tx_packet_2048_4095_bytes_0 : OUT   STD_LOGIC;
        stat_tx_packet_4096_8191_bytes_0 : OUT   STD_LOGIC;
        stat_tx_packet_8192_9215_bytes_0 : OUT   STD_LOGIC;
        stat_tx_packet_small_0           : OUT   STD_LOGIC;
        stat_tx_packet_large_0           : OUT   STD_LOGIC;
        stat_tx_unicast_0                : OUT   STD_LOGIC;
        stat_tx_multicast_0              : OUT   STD_LOGIC;
        stat_tx_broadcast_0              : OUT   STD_LOGIC;
        stat_tx_vlan_0                   : OUT   STD_LOGIC;
        stat_tx_frame_error_0            : OUT   STD_LOGIC;
    -- Transmit enabled with MAC FCS insertion; internal test patterns disabled.
        ctl_tx_enable_0                  : IN    STD_LOGIC;
        ctl_tx_send_rfi_0                : IN    STD_LOGIC;
        ctl_tx_send_lfi_0                : IN    STD_LOGIC;
        ctl_tx_send_idle_0               : IN    STD_LOGIC;
        ctl_tx_fcs_ins_enable_0          : IN    STD_LOGIC;
        ctl_tx_ignore_fcs_0              : IN    STD_LOGIC;
        ctl_tx_test_pattern_0            : IN    STD_LOGIC;
        ctl_tx_test_pattern_enable_0     : IN    STD_LOGIC;
        ctl_tx_test_pattern_select_0     : IN    STD_LOGIC;
        ctl_tx_data_pattern_select_0     : IN    STD_LOGIC;
        ctl_tx_test_pattern_seed_a_0     : IN    STD_LOGIC_VECTOR(57 DOWNTO 0);
        ctl_tx_test_pattern_seed_b_0     : IN    STD_LOGIC_VECTOR(57 DOWNTO 0);
        gt_loopback_in_0                 : IN    STD_LOGIC_VECTOR(2 DOWNTO 0);
        qpllreset_in_0                   : IN    STD_LOGIC
  );
END COMPONENT;
 -- Component interface must match the packaged xxv_ethernet_0 IP.
COMPONENT xxv_ethernet_0
  PORT (
        gt_rxp_in_0                      : IN    STD_LOGIC;
        gt_rxn_in_0                      : IN    STD_LOGIC;
        gt_txp_out_0                     : OUT   STD_LOGIC;
        gt_txn_out_0                     : OUT   STD_LOGIC;
        rx_core_clk_0                    : IN    STD_LOGIC;
        txoutclksel_in_0                 : IN    STD_LOGIC_VECTOR(2 DOWNTO 0);
        rxoutclksel_in_0                 : IN    STD_LOGIC_VECTOR(2 DOWNTO 0);
        gtwiz_reset_tx_datapath_0        : IN    STD_LOGIC;
        gtwiz_reset_rx_datapath_0        : IN    STD_LOGIC;
        rxrecclkout_0                    : OUT   STD_LOGIC;
        sys_reset                        : IN    STD_LOGIC;
        dclk                             : IN    STD_LOGIC;
        tx_clk_out_0                     : OUT   STD_LOGIC;
        rx_clk_out_0                     : OUT   STD_LOGIC;
        gt_refclk_p                      : IN    STD_LOGIC;
        gt_refclk_n                      : IN    STD_LOGIC;
        gt_refclk_out                    : OUT   STD_LOGIC;
        gtpowergood_out_0                : OUT   STD_LOGIC;
        rx_reset_0                       : IN    STD_LOGIC;
        user_rx_reset_0                  : OUT   STD_LOGIC;
        rx_axis_tvalid_0                 : OUT   STD_LOGIC;
        rx_axis_tdata_0                  : OUT   STD_LOGIC_VECTOR(63 DOWNTO 0);
        rx_axis_tlast_0                  : OUT   STD_LOGIC;
        rx_axis_tkeep_0                  : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
        rx_axis_tuser_0                  : OUT   STD_LOGIC;
        ctl_rx_enable_0                  : IN    STD_LOGIC;
        ctl_rx_check_preamble_0          : IN    STD_LOGIC;
        ctl_rx_check_sfd_0               : IN    STD_LOGIC;
        ctl_rx_force_resync_0            : IN    STD_LOGIC;
        ctl_rx_delete_fcs_0              : IN    STD_LOGIC;
        ctl_rx_ignore_fcs_0              : IN    STD_LOGIC;
        ctl_rx_max_packet_len_0          : IN    STD_LOGIC_VECTOR(14 DOWNTO 0);
        ctl_rx_min_packet_len_0          : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
        ctl_rx_process_lfi_0             : IN    STD_LOGIC;
        ctl_rx_test_pattern_0            : IN    STD_LOGIC;
        ctl_rx_data_pattern_select_0     : IN    STD_LOGIC;
        ctl_rx_test_pattern_enable_0     : IN    STD_LOGIC;
        stat_rx_framing_err_0            : OUT   STD_LOGIC;
        stat_rx_framing_err_valid_0      : OUT   STD_LOGIC;
        stat_rx_local_fault_0            : OUT   STD_LOGIC;
        stat_rx_block_lock_0             : OUT   STD_LOGIC;
        stat_rx_valid_ctrl_code_0        : OUT   STD_LOGIC;
        stat_rx_status_0                 : OUT   STD_LOGIC;
        stat_rx_remote_fault_0           : OUT   STD_LOGIC;
        stat_rx_bad_fcs_0                : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
        stat_rx_stomped_fcs_0            : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
        stat_rx_truncated_0              : OUT   STD_LOGIC;
        stat_rx_internal_local_fault_0   : OUT   STD_LOGIC;
        stat_rx_received_local_fault_0   : OUT   STD_LOGIC;
        stat_rx_hi_ber_0                 : OUT   STD_LOGIC;
        stat_rx_got_signal_os_0          : OUT   STD_LOGIC;
        stat_rx_test_pattern_mismatch_0  : OUT   STD_LOGIC;
        stat_rx_total_bytes_0            : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
        stat_rx_total_packets_0          : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
        stat_rx_total_good_bytes_0       : OUT   STD_LOGIC_VECTOR(13 DOWNTO 0);
        stat_rx_total_good_packets_0     : OUT   STD_LOGIC;
        stat_rx_packet_bad_fcs_0         : OUT   STD_LOGIC;
        stat_rx_packet_64_bytes_0        : OUT   STD_LOGIC;
        stat_rx_packet_65_127_bytes_0    : OUT   STD_LOGIC;
        stat_rx_packet_128_255_bytes_0   : OUT   STD_LOGIC;
        stat_rx_packet_256_511_bytes_0   : OUT   STD_LOGIC;
        stat_rx_packet_512_1023_bytes_0  : OUT   STD_LOGIC;
        stat_rx_packet_1024_1518_bytes_0 : OUT   STD_LOGIC;
        stat_rx_packet_1519_1522_bytes_0 : OUT   STD_LOGIC;
        stat_rx_packet_1523_1548_bytes_0 : OUT   STD_LOGIC;
        stat_rx_packet_1549_2047_bytes_0 : OUT   STD_LOGIC;
        stat_rx_packet_2048_4095_bytes_0 : OUT   STD_LOGIC;
        stat_rx_packet_4096_8191_bytes_0 : OUT   STD_LOGIC;
        stat_rx_packet_8192_9215_bytes_0 : OUT   STD_LOGIC;
        stat_rx_packet_small_0           : OUT   STD_LOGIC;
        stat_rx_packet_large_0           : OUT   STD_LOGIC;
        stat_rx_unicast_0                : OUT   STD_LOGIC;
        stat_rx_multicast_0              : OUT   STD_LOGIC;
        stat_rx_broadcast_0              : OUT   STD_LOGIC;
        stat_rx_oversize_0               : OUT   STD_LOGIC;
        stat_rx_toolong_0                : OUT   STD_LOGIC;
        stat_rx_undersize_0              : OUT   STD_LOGIC;
        stat_rx_fragment_0               : OUT   STD_LOGIC;
        stat_rx_vlan_0                   : OUT   STD_LOGIC;
        stat_rx_inrangeerr_0             : OUT   STD_LOGIC;
        stat_rx_jabber_0                 : OUT   STD_LOGIC;
        stat_rx_bad_code_0               : OUT   STD_LOGIC;
        stat_rx_bad_sfd_0                : OUT   STD_LOGIC;
        stat_rx_bad_preamble_0           : OUT   STD_LOGIC;
        tx_reset_0                       : IN    STD_LOGIC;
        user_tx_reset_0                  : OUT   STD_LOGIC;
        tx_axis_tready_0                 : OUT   STD_LOGIC;
        tx_axis_tvalid_0                 : IN    STD_LOGIC;
        tx_axis_tdata_0                  : IN    STD_LOGIC_VECTOR(63 DOWNTO 0);
        tx_axis_tlast_0                  : IN    STD_LOGIC;
        tx_axis_tkeep_0                  : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
        tx_axis_tuser_0                  : IN    STD_LOGIC;
        tx_unfout_0                      : OUT   STD_LOGIC;
        stat_tx_local_fault_0            : OUT   STD_LOGIC;
        stat_tx_total_bytes_0            : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
        stat_tx_total_packets_0          : OUT   STD_LOGIC;
        stat_tx_total_good_bytes_0       : OUT   STD_LOGIC_VECTOR(13 DOWNTO 0);
        stat_tx_total_good_packets_0     : OUT   STD_LOGIC;
        stat_tx_bad_fcs_0                : OUT   STD_LOGIC;
        stat_tx_packet_64_bytes_0        : OUT   STD_LOGIC;
        stat_tx_packet_65_127_bytes_0    : OUT   STD_LOGIC;
        stat_tx_packet_128_255_bytes_0   : OUT   STD_LOGIC;
        stat_tx_packet_256_511_bytes_0   : OUT   STD_LOGIC;
        stat_tx_packet_512_1023_bytes_0  : OUT   STD_LOGIC;
        stat_tx_packet_1024_1518_bytes_0 : OUT   STD_LOGIC;
        stat_tx_packet_1519_1522_bytes_0 : OUT   STD_LOGIC;
        stat_tx_packet_1523_1548_bytes_0 : OUT   STD_LOGIC;
        stat_tx_packet_1549_2047_bytes_0 : OUT   STD_LOGIC;
        stat_tx_packet_2048_4095_bytes_0 : OUT   STD_LOGIC;
        stat_tx_packet_4096_8191_bytes_0 : OUT   STD_LOGIC;
        stat_tx_packet_8192_9215_bytes_0 : OUT   STD_LOGIC;
        stat_tx_packet_small_0           : OUT   STD_LOGIC;
        stat_tx_packet_large_0           : OUT   STD_LOGIC;
        stat_tx_unicast_0                : OUT   STD_LOGIC;
        stat_tx_multicast_0              : OUT   STD_LOGIC;
        stat_tx_broadcast_0              : OUT   STD_LOGIC;
        stat_tx_vlan_0                   : OUT   STD_LOGIC;
        stat_tx_frame_error_0            : OUT   STD_LOGIC;
        ctl_tx_enable_0                  : IN    STD_LOGIC;
        ctl_tx_send_rfi_0                : IN    STD_LOGIC;
        ctl_tx_send_lfi_0                : IN    STD_LOGIC;
        ctl_tx_send_idle_0               : IN    STD_LOGIC;
        ctl_tx_fcs_ins_enable_0          : IN    STD_LOGIC;
        ctl_tx_ignore_fcs_0              : IN    STD_LOGIC;
        ctl_tx_test_pattern_0            : IN    STD_LOGIC;
        ctl_tx_test_pattern_enable_0     : IN    STD_LOGIC;
        ctl_tx_test_pattern_select_0     : IN    STD_LOGIC;
        ctl_tx_data_pattern_select_0     : IN    STD_LOGIC;
        ctl_tx_test_pattern_seed_a_0     : IN    STD_LOGIC_VECTOR(57 DOWNTO 0);
        ctl_tx_test_pattern_seed_b_0     : IN    STD_LOGIC_VECTOR(57 DOWNTO 0);
        gt_loopback_in_0                 : IN    STD_LOGIC_VECTOR(2 DOWNTO 0);
        qpllreset_in_0                   : IN    STD_LOGIC
  );
END COMPONENT;
begin
ethernet_1 :xxv_ethernet_1
  PORT MAP (
        gt_rxp_in_0                      => rxp,
        gt_rxn_in_0                      => rxn,
        gt_txp_out_0                     => txp,
        gt_txn_out_0                     => txn,
        rx_core_clk_0                    => '0',
        txoutclksel_in_0                 => "101",
        rxoutclksel_in_0                 => "101",
        gtwiz_reset_tx_datapath_0        => '0',
        gtwiz_reset_rx_datapath_0        => '0',
        sys_reset                        => reset,
        dclk                             => clk_100MHz,
        tx_clk_out_0                     => tx_clk_lan,
        rx_clk_out_0                     => rx_clk_lan,
        gt_refclk_p                      => refclk_p,
        gt_refclk_n                      => refclk_n,
        gt_refclk_out                    => open,
        rx_reset_0                       => '0',
        rx_axis_tvalid_0                 => Rx_axis_tvalid,
        rx_axis_tdata_0                  => Rx_axis_tdata,
        rx_axis_tlast_0                  => Rx_axis_tlast,
        rx_axis_tkeep_0                  => Rx_axis_tkeep,
        rx_axis_tuser_0                  => Rx_axis_tuser,
        ctl_rx_enable_0                  => '1',
        ctl_rx_check_preamble_0          => '1',
        ctl_rx_check_sfd_0               => '1',
        ctl_rx_force_resync_0            => '0',
        ctl_rx_delete_fcs_0              => '1',
        ctl_rx_ignore_fcs_0              => '0',
        ctl_rx_max_packet_len_0          => (OTHERS => '0'),
        ctl_rx_min_packet_len_0          => (OTHERS => '0'),
        ctl_rx_process_lfi_0             => '0',
        ctl_rx_test_pattern_0            => '0',
        ctl_rx_data_pattern_select_0     => '0',
        ctl_rx_test_pattern_enable_0     => '0',
        tx_reset_0                       => not(Tx_axis_aresetn),
        tx_axis_tready_0                 => Tx_axis_tready,
        tx_axis_tvalid_0                 => Tx_axis_tvalid,
        tx_axis_tdata_0                  => Tx_axis_tdata,
        tx_axis_tlast_0                  => Tx_axis_tlast,
        tx_axis_tkeep_0                  => Tx_axis_tkeep,
        tx_axis_tuser_0                  => Tx_axis_tuser(0),
        ctl_tx_enable_0                  => '1',
        ctl_tx_send_rfi_0                => '0',
        ctl_tx_send_lfi_0                => '0',
        ctl_tx_send_idle_0               => '0',
        ctl_tx_fcs_ins_enable_0          => '1',
        ctl_tx_ignore_fcs_0              => '0',
        ctl_tx_test_pattern_0            => '0',
        ctl_tx_test_pattern_enable_0     => '0',
        ctl_tx_test_pattern_select_0     => '0',
        ctl_tx_data_pattern_select_0     => '0',
        ctl_tx_test_pattern_seed_a_0     => (OTHERS => '0'),
        ctl_tx_test_pattern_seed_b_0     => (OTHERS => '0'),
        gt_loopback_in_0                 => (OTHERS => '0'),
        qpllreset_in_0                   => '0',
        stat_tx_packet_small_0           => stat_tx_packet_small,
        stat_tx_packet_large_0           => stat_tx_packet_large,
        stat_tx_unicast_0                => stat_tx_unicast,
        stat_tx_multicast_0              => stat_tx_multicast,
        stat_tx_broadcast_0              => stat_tx_broadcast,
        stat_tx_vlan_0                   => stat_tx_vlan,
        stat_tx_frame_error_0            => stat_tx_frame_error
  );
end Behavioral;
