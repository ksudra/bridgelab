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

entity cm0_wrapper is
  port(
    clkm : in std_logic;
    rstn : in std_logic;
    ahbmi : in ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;
    cm0_led : out std_logic
  );
end cm0_wrapper;

architecture structural of cm0_wrapper is
  signal HADDR : std_logic_vector (31 downto 0); -- AHB transaction address
  signal HSIZE : std_logic_vector (2 downto 0); -- AHB size: byte, half-word or word
  signal HTRANS : std_logic_vector (1 downto 0); -- AHB transfer: non-sequential only
  signal HWDATA : std_logic_vector (31 downto 0); -- AHB write-data
  signal HWRITE : std_logic; -- AHB write control
  signal HRDATA : std_logic_vector (31 downto 0); -- AHB read-data
  signal HREADY : std_logic;
  signal LED : std_logic;
  
  component AHB_bridge is
    port(
      -- Clock and Reset -----------------
      clkm : in std_logic;
      rstn : in std_logic;
      -- AHB Master records --------------
      ahbmi : in ahb_mst_in_type;
      ahbmo : out ahb_mst_out_type;
       -- ARM Cortex-M0 AHB-Lite signals -- 
      HADDR : in std_logic_vector (31 downto 0); -- AHB transaction address
      HSIZE : in std_logic_vector (2 downto 0); -- AHB size: byte, half-word or word
      HTRANS : in std_logic_vector (1 downto 0); -- AHB transfer: non-sequential only
      HWDATA : in std_logic_vector (31 downto 0); -- AHB write-data
      HWRITE : in std_logic; -- AHB write control
      HRDATA : out std_logic_vector (31 downto 0); -- AHB read-data
      HREADY : out std_logic -- AHB stall signal
    );
  end component;   
  
  component CORTEXM0DS is
    port(
      -- Clock and Reset -----------------
      HCLK : in std_logic;
      HRESETn : in std_logic;
       -- ARM Cortex-M0 AHB-Lite signals -- 
      HADDR : out std_logic_vector (31 downto 0); -- AHB transaction address
      HSIZE : out std_logic_vector (2 downto 0); -- AHB size: byte, half-word or word
      HTRANS : out std_logic_vector (1 downto 0); -- AHB transfer: non-sequential only
      HWDATA : out std_logic_vector (31 downto 0); -- AHB write-data
      HWRITE : out std_logic; -- AHB write control
      HRDATA : in std_logic_vector (31 downto 0); -- AHB read-data
      HREADY : in std_logic; -- AHB stall signal
      HRESP: in std_logic;
      NMI : in std_logic;
      IRQ : in std_logic_vector(15 downto 0);
      RXEV : in std_logic
    );
  end component; 

begin
  blink : process(clkm, HRDATA, LED)
  begin
    if falling_edge(clkm) then
      if HRDATA = "00000110000001100000011000000110" then
        LED <= '1';
      else
        LED <= '0';
      end if;
    end if;
  end process;
  cm0_led <= LED;
  
  inst_AHB_bridge : AHB_bridge
    port map(
      -- Clock and Reset -----------------
      clkm => clkm,
      rstn => rstn,
      -- AHB Master records --------------
      ahbmi => ahbmi,
      ahbmo => ahbmo,
       -- ARM Cortex-M0 AHB-Lite signals -- 
      HADDR => HADDR,
      HSIZE => HSIZE,
      HTRANS => HTRANS,
      HWDATA => HWDATA,
      HWRITE => HWRITE,
      HRDATA => HRDATA,
      HREADY => HREADY
    );
    
  inst_cortexm0 : CORTEXM0DS
    port map(
      HCLK => clkm,
      HRESETn => rstn,
      HADDR => HADDR,
      HSIZE => HSIZE,
      HTRANS => HTRANS,
      HWDATA => HWDATA,
      HWRITE => HWRITE,
      HRDATA => HRDATA,
      HREADY => HREADY,
      HRESP => '0',
      NMI => '0',
      IRQ => (OTHERS => '0'),
      RXEV => '0'
    );
end;
