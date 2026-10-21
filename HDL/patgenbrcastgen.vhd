-- Standalone experimental broadcast generator; not in the active Vivado source set.
-- The frame is a fixed five-word pattern rather than a complete IPv4 packet.
-- The final SEND_PAYLOAD increment exceeds frame_index range 0 to 4.
-- Resolve that boundary and review AXI backpressure before enabling this example.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eth10g_broadcast_tx is
    port (
        tx_clk                           : in    std_logic;
        tx_reset                         : in    std_logic;
        Send_pack                        : in    std_logic;

        -- AXI-Stream TX interface to 10G MAC
        tx_axis_tdata                    : out   std_logic_vector(63 downto 0);
        tx_axis_tkeep                    : out   std_logic_vector(7 downto 0);
        tx_axis_tvalid                   : out   std_logic;
        tx_axis_tlast                    : out   std_logic;
        tx_axis_tready                   : in    std_logic
    );
end entity;

architecture rtl of eth10g_broadcast_tx is

    type state_type is (IDLE, SEND_HDR, SEND_PAYLOAD, DONE);
    signal state                               : state_type := IDLE;

    -- Frame content
    type frame_array is array(0 to 4) of std_logic_vector(63 downto 0);
    constant broadcast_frame                     : frame_array := (
        -- Broadcast MAC: FF:FF:FF:FF:FF:FF
        -- Src MAC: DE:AD:BE:EF:00:01
        -- Ethertype: 0x0800 (IPv4)
        x"FFFFFFFFFFFFDEAD", -- Dest MAC + part of Src MAC
        x"BEEF000108000000", -- Rest of Src MAC + EtherType + Payload
        x"ABCDEF1234567890",
        x"1122334455667788",
        x"0000000000000000"  -- Padding or additional payload
    );

    signal frame_index                         : integer range 0 to 4 := 0;

begin

    process(tx_clk)
    begin
        if rising_edge(tx_clk) then
            if tx_reset = '1' then
                state <= IDLE;
                tx_axis_tvalid <= '0';
                tx_axis_tlast  <= '0';
                frame_index    <= 0;
            else
                case state is
                    when IDLE =>
                        if tx_axis_tready = '1' and Send_pack='1' then
                            frame_index <= 0;
                            state <= SEND_HDR;
                        end if;

                    when SEND_HDR =>
                        if tx_axis_tready = '1' then
                            tx_axis_tdata  <= broadcast_frame(frame_index);
                            tx_axis_tkeep  <= x"FF";
                            tx_axis_tvalid <= '1';
                            tx_axis_tlast  <= '0';
                            frame_index <= frame_index + 1;
                            state <= SEND_PAYLOAD;
                        end if;

                    when SEND_PAYLOAD =>
                        if tx_axis_tready = '1' then
                            tx_axis_tdata  <= broadcast_frame(frame_index);
                            tx_axis_tkeep  <= x"FF";
                            tx_axis_tvalid <= '1';
                            if frame_index = 4 then
                                tx_axis_tlast <= '1';
                                state <= DONE;
                            else
                                tx_axis_tlast <= '0';
                            end if;
                            frame_index <= frame_index + 1;
                        end if;

                    when DONE =>
                        tx_axis_tvalid <= '0';
                        tx_axis_tlast  <= '0';
                        state <= IDLE;

                    when others =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;

end architecture;
