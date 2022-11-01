----------------------------------------------------------------------------
-- group 06
-- eo20203
-- dm22509
-- nz20469
-- bi20475
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.misc.all;
library UNISIM;
use UNISIM.VComponents.all;
entity state_machine is
  port (
    clkm : in std_logic; -- Clock.
    rstn : in std_logic; -- Synchronous reset.
    dmao : in ahb_dma_out_type;
    dmai : out ahb_dma_in_type;
    HSIZE : in std_logic_vector (2 downto 0);
    HTRANS : in std_logic_vector (1 downto 0);
    HADDR : in std_logic_vector (31 downto 0);
    HWRITE : in std_logic;
    HWDATA : in std_logic_vector (31 downto 0);
    HREADY : out std_logic
    );
end;
architecture dataflow of state_machine is
  type state_type is (idle, start, instr_fetch);
  signal curState, nextState:state_type;
  begin
    dmai.size <= HSIZE;
    dmai.address <= HADDR;
    dmai.write <= HWRITE;
    dmai.wdata <= HWDATA;
    dmai.burst <= '0';
    dmai.busy <= '0';
    dmai.irq <= '0';
    state_reg: process(clkm, rstn)
      begin
	  if rstn = '0' then
	     curState <= idle;
		elsif rising_edge(clkm) then
			curState <= nextState;
		else
			curState <= curState;
		end if;
	  end process;
    
    state_trans: process(curState, HTRANS, dmao.ready)
    begin
      CASE curState is
      when idle =>
        if HTRANS = "10" then
          nextState <= start;
        else
          nextState <= idle;
        end if;
      when start =>
        nextState <= instr_fetch;
      when instr_fetch =>
        if dmao.ready = '1' then
          nextState <= idle;
        else
          nextState <= instr_fetch;
        end if;
      when OTHERS =>
        nextState <= idle;
      end case;
    end process;
    
    state_out: process(curState)
    begin
      CASE curState is
      when idle =>
        HREADY <= '1';
        dmai.start <= '0';
      when start =>
        HREADY <= '1';
        dmai.start <= '1';
      when instr_fetch =>
        HREADY <= '0';
        dmai.start <= '0';
      when OTHERS =>
      end case;
    end process;
end;

