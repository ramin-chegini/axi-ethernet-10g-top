-- Command and status register bank with pipelined readback.
-- read_only_regs selects the readback source; it does not block writes.
-- Register values and update strobes retain the original reset behavior.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use  work.Reg_pack_comint.ALL;

entity Config_Register_Comint is
    generic(
        Width : integer := 64;
        num_reg : integer := 128    );
    Port (
        clk                              : in    STD_LOGIC;
        Reset                            : in    STD_LOGIC;

        RegData_RD                       : Out   STD_LOGIC_VECTOR (Width-1 downto 0);
        RD_val                           : out   STD_LOGIC;

        RegData_WR                       : in    STD_LOGIC_VECTOR (Width-1 downto 0);
        RegAddr                          : in    STD_LOGIC_VECTOR (7 downto 0);
        read_only_regs                   : in    STD_LOGIC_VECTOR (num_reg-1 downto 0);
        command_registers                : out   std_logic_reg_array(num_reg-1 downto 0);
        status_registers                 : in    std_logic_reg_array(num_reg-1 downto 0);
        command_updates                  : out   std_logic_vector(num_reg-1 downto 0);
        RD                               : in    STD_LOGIC;
        WR                               : in    STD_LOGIC);
end Config_Register_Comint;

architecture Behavioral of Config_Register_Comint is

    constant RegAddrWidth                        : integer := 5;

    signal RegData_RD_int                      : std_logic_reg_array(num_reg-1 downto 0);
    signal REG_RD                              : std_logic_vector(num_reg-1 downto 0);
    signal REG_WR                              : std_logic_vector(num_reg-1 downto 0);
    signal REG_WR_d , REG_WR_d2                : std_logic_vector(num_reg-1 downto 0);
    signal REG_RD_d , REG_RD_d2                : std_logic_vector(num_reg-1 downto 0);
    signal RegCnt                              : std_logic_vector(31 downto 0);
    signal REG26_RD                            : std_logic;
    signal RD_val_B,RD_d1,RD_d2                : std_logic;

    signal command_registers_sig               : std_logic_reg_array(num_reg-1 downto 0);
    signal command_updates_sig                 : std_logic_vector(num_reg-1 downto 0);
    signal status_registers_sig                : std_logic_reg_array(num_reg-1 downto 0);

begin
    command_registers <= command_registers_sig;
    -- Decode each address into registered per-register read and write strobes.
    Gen1 :for i in 0 to num_reg-1 generate
        process (clk,reset)
        begin
            if reset='1' then
                REG_RD(i) <= '0';
                REG_WR(i) <= '0';
            elsif rising_edge(clk) then
                if (RD = '1'  and RegAddr = i) then
                    REG_RD(i) <= '1';
                else
                    REG_RD(i) <= '0';
                end if;
                if (WR = '1'  and RegAddr = i) then
                    REG_WR(i) <= '1';
                else
                    REG_WR(i) <= '0';
                end if;
            end if;
        end process;
    end generate;

    -- Snapshot command or external status data according to the readback mask.
    Gen2_1 :for i in 0 to num_reg-1 generate
        process (clk,REG_RD(i))
        begin
            if (reset = '1') then
                RegData_RD_int(i) <= (others => '0');
            elsif rising_edge(clk) then
                REG_RD_d(i) <= REG_RD(i) ;
                if (REG_RD(i)='1' and read_only_regs(i) = '0') then
                    RegData_RD_int(i) <= command_registers_sig(i);
                elsif (REG_RD(i)='1' and read_only_regs(i) = '1') then
                    RegData_RD_int(i) <= status_registers(i);
                end if;
            END IF;
        END PROCESS;
    end generate;

    -- Delay RD through the readback pipeline and select the addressed value.
    process (clk,reset)
    begin
        if reset='1' then
            RD_val <= '0';
            RD_d2 <= '0';
            RD_d1 <= '0';
            RegData_RD <= (others => '0');
        elsif rising_edge(clk) then
            RD_d1 <= RD;
            RD_d2 <= RD_d1;
            RD_val <= RD_d2;
            for i in 0 to num_reg-1 loop
                if (REG_RD_d(i)='1' ) then
                    RegData_RD <= RegData_RD_int(i);
                end if;
            end loop;
        end if;
    end process;

    -- Detect the falling edge of each write strobe and pipeline the update flag.
    Gen3 :for i in 0 to num_reg-1 generate
        process (clk,REG_WR(i))
        begin
            if rising_edge(clk) then
                REG_WR_d(i) <= REG_WR(i) ;
                if (REG_WR_d(i)='1' and REG_WR(i)='0') then
                    command_updates_sig(i) <= REG_WR_d(i);
                else
                    command_updates_sig(i) <= '0';
                end if;
                command_updates <= command_updates_sig;
            END IF;
        END PROCESS;
    end generate;

    -- Writes always update command storage, including status-selected addresses.
    process (clk,REG_WR)
    begin
        if rising_edge(clk) then
            for i in 0 to num_reg-1 loop
                if REG_WR(i) = '1' then
                    command_registers_sig(i) <= RegData_WR;
                end if;
            end loop;
        end if;
    end process;

end Behavioral;
