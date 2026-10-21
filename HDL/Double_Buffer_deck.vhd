-- Legacy 8-bit-write / 32-bit-read FIFO wrapper; not in the active source set.
-- Only channel 1 is instantiated. The former ping-pong path is inactive.
-- Wr_last is sampled in the read clock domain without a synchronizer here.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use  work.Reg_pack_comint.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity Double_Buffer_deck is
    Port (
        reset                            : in    STD_LOGIC;

        Wr_clk                           : in    STD_LOGIC;
        Wr_en                            : in    STD_LOGIC;
        Wr_last                          : in    STD_LOGIC;
        Wr_Data                          : in    STD_LOGIC_VECTOR(7 downto 0);
        Wr_Ready                         : out   STD_LOGIC;

        Rd_clk                           : in    STD_LOGIC;
        Rd_en                            : in    STD_LOGIC;
        RD_Data                          : out   STD_LOGIC_VECTOR(31 downto 0);
        Rd_ready                         : out   STD_LOGIC
           );
end Double_Buffer_deck;

architecture Behavioral of Double_Buffer_deck is

type State_num is (Idle,st1_B1,st1_B2);

COMPONENT fifo_generator_4DB
  PORT (
        rst                              : IN    STD_LOGIC;
        wr_clk                           : IN    STD_LOGIC;
        rd_clk                           : IN    STD_LOGIC;
        din                              : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
        wr_en                            : IN    STD_LOGIC;
        rd_en                            : IN    STD_LOGIC;
        dout                             : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
        full                             : OUT   STD_LOGIC;
        almost_full                      : OUT   STD_LOGIC;
        empty                            : OUT   STD_LOGIC;
        almost_empty                     : OUT   STD_LOGIC;
        rd_data_count                    : OUT   STD_LOGIC_VECTOR(12 DOWNTO 0);
        wr_data_count                    : OUT   STD_LOGIC_VECTOR(14 DOWNTO 0);
        wr_rst_busy                      : OUT   STD_LOGIC;
        rd_rst_busy                      : OUT   STD_LOGIC
  );
END COMPONENT;

    signal state, next_state                   : State_num;

    signal rd_data_count_ch1,rd_data_count_ch2 : std_logic_vector(12 downto 0);
    signal wr_data_count_ch1,wr_data_count_ch2 : std_logic_vector(14 downto 0);

    signal dout_ch1,dout_ch2                   : std_logic_vector(31 downto 0);
    signal empty_ch1,empty_ch2                 : std_logic;
    signal full_ch1,full_ch2                   : std_logic;
    signal almost_full_ch1,almost_full_ch2     : std_logic;
    signal almost_empty_ch1,almost_empty_ch2   : std_logic;
    signal rd_en_ch1,rd_en_ch2                 : std_logic;
    signal wr_en_ch1,wr_en_ch2                 : std_logic;
    signal Write_Ready,Read_Ready              : std_logic;
    signal first_stage    ,Wr_last_latch       : std_logic;

    signal TRIG0                               : std_logic_vector(15 downto 0);
    signal TRIG1                               : std_logic_vector(15 downto 0);
    signal TRIG2                               : std_logic_vector(15 downto 0);
    signal TRIG3                               : std_logic_vector(15 downto 0);
    signal TRIG4                               : std_logic_vector(15 downto 0);
    signal TRIG5                               : std_logic_vector(15 downto 0);
    signal TRIG6                               : std_logic_vector(15 downto 0);
    signal TRIG7                               : std_logic_vector(31 downto 0);
    signal TRIG8                               : std_logic_vector(31 downto 0);
    signal CONTROL0                            : std_logic_vector(35 downto 0);
    signal State_NO                            : std_logic_vector(1 downto 0);
    signal dout                                : std_logic_vector(7 downto 0);
    signal Wr_Data_ch2,Wr_Data_ch1             : std_logic_vector(7 downto 0);

begin

        Wr_Ready <= Write_Ready;
        Rd_Ready <= Read_Ready;

-- The active implementation contains one width-converting FIFO.
DATA_IN_FIFO_ch1 :fifo_generator_4DB
 PORT MAP (
        rst                              => reset,
        wr_clk                           => Wr_clk,
        rd_clk                           => Rd_clk,
        din                              => wr_data,
        wr_en                            => wr_en_ch1,
        rd_en                            => rd_en_ch1,
        dout                             => dout_ch1,
        full                             => full_ch1,
        almost_full                      => almost_full_ch1,
        almost_empty                     => almost_empty_ch1,
        empty                            => empty_ch1,
        rd_data_count                    => rd_data_count_ch1,
        wr_data_count                    => wr_data_count_ch1
 );

-- Register channel-1 write controls in the user write clock domain.
process(wr_clk,reset)
begin
   if reset = '1' then
       Wr_en_ch1 <= '0';
       Wr_en_ch2 <= '0';
       State_NO <= "00";
       Wr_Data_ch2 <= (others => '0');
       Wr_Data_ch1 <= (others => '0');
   elsif wr_clk'event and wr_clk ='1' then
            State_NO <= "10";
            Wr_en_ch1 <= Wr_en;
            Wr_en_ch2 <= '0';
            Wr_Data_ch2 <= (others => '0');
            Wr_Data_ch1 <= Wr_Data;
   end if;
end process;

process(wr_clk,reset,Wr_last_latch)
begin
   if reset = '1' then
        Write_Ready <= '0';
   elsif wr_clk'event and wr_clk ='1' then
            if almost_full_ch1 = '1' then
                Write_Ready <= '0';
            else
                Write_Ready <= '1';
            end if;
   end if;
end process;

-- Read readiness follows the channel-1 threshold and the legacy Wr_last input.
process(rd_clk,reset)
begin
   if reset = '1' then
        Read_Ready <= '0';
   elsif rd_clk'event and rd_clk ='1' then
           if almost_empty_ch1 = '1' then
                Read_Ready <= '0';
            elsif Wr_last ='1' then
                Read_Ready <= '1';
            end if;
   end if;
end process;

process(rd_clk,reset)
begin
   if reset = '1' then
        RD_Data <= (others =>'0');
        rd_en_ch2 <= '0';
        rd_en_ch1 <= '0';
   elsif rd_clk'event and rd_clk ='1' then
            RD_Data <= dout_ch1;
            rd_en_ch1 <= rd_en;
   end if;
end process;

end Behavioral;
