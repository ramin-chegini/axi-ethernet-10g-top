-- Shared protocol identifiers, register types, and buffer configuration.
-- Keep these widths consistent with the configured FIFO IP interfaces.

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.ALL;

package Reg_pack_comint is
    -- Count divisions by two until the bus width reaches eight bits.
    -- For the configured 64-bit bus this returns 3 (eight bytes per word).
    function Bus_width_integer( depth : natural) return integer ;

    -- High byte shared by data, register, and terminal command codes.
    constant HPR_ID                              : std_logic_vector(7 downto 0):= x"02";
    constant Version_string                      : std_logic_vector(63 downto 0) := x"5665722030353530";--Ver 5.5

    constant Dist_MAC_ADDR                       : bit_vector(47 downto 0) := X"ECA868F4A5B9" ;

    constant SRC_MAC_ADDR                        : bit_vector(47 downto 0) := X"5a0102030405";
    constant NOofreg                             : integer   := 128;
    constant reg_width                           : integer := 64;
    constant TOPreg_width                        : integer := 32;
    constant NOofBUF                             : integer   := 16;
    constant Bus_Width                           : integer   := 64;
    constant LAST_Data                           : std_logic_vector(15 downto 0) := conv_std_logic_vector((Bus_width/8), 16);
    constant trimpoint                           : integer := Bus_width_integer(Bus_Width);
    constant TransferSizeBuff0_cons              : std_logic_vector(15 downto 0) := X"1410";
    constant TransferSizeBuff1_cons              : std_logic_vector(15 downto 0) := X"0A10";--0C84
    constant TransferSizeBuff2_cons              : std_logic_vector(15 downto 0) := X"0A10";--0644
    constant TransferSizeBuff3_cons              : std_logic_vector(15 downto 0) := X"0200";
    constant TransferSizeBuff4_cons              : std_logic_vector(15 downto 0) := X"1000";
    constant TransferSizeBuff5_cons              : std_logic_vector(15 downto 0) := X"0200"; -- Number of Bytes
    constant TransferSizeBuff6_cons              : std_logic_vector(15 downto 0) := X"1000";
    constant TransferSizeBuff7_cons              : std_logic_vector(15 downto 0) := X"1000";
    constant TransferSizeBuff8_cons              : std_logic_vector(15 downto 0) := X"2000";
    constant TransferSizeBuff9_cons              : std_logic_vector(15 downto 0) := X"0A10";
    constant TransferSizeBuff10_cons             : std_logic_vector(15 downto 0) := X"0400";
    constant TransferSizeBuff11_cons             : std_logic_vector(15 downto 0) := X"0200";
    constant TransferSizeBuff12_cons             : std_logic_vector(15 downto 0) := X"0400"; -- Number of Bytes
    constant TransferSizeBuff13_cons             : std_logic_vector(15 downto 0) := X"1000";
    constant TransferSizeBuff14_cons             : std_logic_vector(15 downto 0) := X"0200";
    constant TransferSizeBuff15_cons             : std_logic_vector(15 downto 0) := X"0200";

    -- Buffer 15 occupies the most-significant field; buffer 0 occupies the least.
    constant ConstTransferSize                   : std_logic_vector((NOofBUF * 16)-1 downto 0) :=   TransferSizeBuff15_cons
                                                                                    & TransferSizeBuff14_cons
                                                                                    & TransferSizeBuff13_cons
                                                                                    & TransferSizeBuff12_cons
                                                                                    & TransferSizeBuff11_cons
                                                                                    & TransferSizeBuff10_cons
                                                                                    & TransferSizeBuff9_cons
                                                                                    & TransferSizeBuff8_cons
                                                                                    & TransferSizeBuff7_cons
                                                                                    & TransferSizeBuff6_cons
                                                                                    & TransferSizeBuff5_cons
                                                                                    & TransferSizeBuff4_cons
                                                                                    & TransferSizeBuff3_cons
                                                                                    & TransferSizeBuff2_cons
                                                                                    & TransferSizeBuff1_cons
                                                                                    & TransferSizeBuff0_cons ;
    constant BuffWidthByte0_cons                 : std_logic_vector(3 downto 0) := X"4";
    constant BuffWidthByte1_cons                 : std_logic_vector(3 downto 0) := X"4";
    constant BuffWidthByte2_cons                 : std_logic_vector(3 downto 0) := X"4";
    constant BuffWidthByte3_cons                 : std_logic_vector(3 downto 0) := X"4";
    constant BuffWidthByte4_cons                 : std_logic_vector(3 downto 0) := X"2";
    constant BuffWidthByte5_cons                 : std_logic_vector(3 downto 0) := X"4";
    constant BuffWidthByte6_cons                 : std_logic_vector(3 downto 0) := X"2";
    constant BuffWidthByte7_cons                 : std_logic_vector(3 downto 0) := X"2";
    constant BuffWidthByte8_cons                 : std_logic_vector(3 downto 0) := X"4";
    constant BuffWidthByte9_cons                 : std_logic_vector(3 downto 0) := X"4";
    constant BuffWidthByte10_cons                : std_logic_vector(3 downto 0) := X"2";
    constant BuffWidthByte11_cons                : std_logic_vector(3 downto 0) := X"1";
    constant BuffWidthByte12_cons                : std_logic_vector(3 downto 0) := X"4";
    constant BuffWidthByte13_cons                : std_logic_vector(3 downto 0) := X"2";
    constant BuffWidthByte14_cons                : std_logic_vector(3 downto 0) := X"2";
    constant BuffWidthByte15_cons                : std_logic_vector(3 downto 0) := X"1";
     -- Per-buffer byte widths use the same descending field order as transfer sizes.
    constant ConstBuffer_Width                   : std_logic_vector((NOofBUF * 4)-1 downto 0) :=   BuffWidthByte15_cons
                                                                                        & BuffWidthByte14_cons
                                                                                        & BuffWidthByte13_cons
                                                                                        & BuffWidthByte12_cons
                                                                                        & BuffWidthByte11_cons
                                                                                        & BuffWidthByte10_cons
                                                                                        & BuffWidthByte9_cons
                                                                                        & BuffWidthByte8_cons
                                                                                        & BuffWidthByte7_cons
                                                                                        & BuffWidthByte6_cons
                                                                                        & BuffWidthByte5_cons
                                                                                        & BuffWidthByte4_cons
                                                                                        & BuffWidthByte3_cons
                                                                                        & BuffWidthByte2_cons
                                                                                        & BuffWidthByte1_cons
                                                                                        & BuffWidthByte0_cons ;

    type std_logic_reg_array is array (natural range <>) of std_logic_vector(reg_width-1 downto 0);
    type std_logic_TOP_reg_array is array (natural range <>) of std_logic_vector(TOPreg_width-1 downto 0);
    type std_logic_array8 is array (natural range<>) of std_logic_vector(7 downto 0);

    type buffer_datain_array is array (natural range<>) of std_logic_vector(31 downto 0);
    type buffer_data_array is array (natural range<>) of std_logic_vector(Bus_Width-1 downto 0);
    type buffer_READ_count_array is array (natural range<>) of std_logic_vector(10 downto 0);
    type buffer_WRITE_count_array is array (natural range<>) of std_logic_vector(15 downto 0);

end Reg_pack_comint;

package body Reg_pack_comint is

function Bus_width_integer( depth : natural) return integer is
    variable temp    : integer := depth;
    variable ret_val : integer := 0;
begin
    while temp > 8 loop
        ret_val := ret_val + 1;
        temp    := temp / 2;
    end loop;
return ret_val;

end function;

end Reg_pack_comint;
