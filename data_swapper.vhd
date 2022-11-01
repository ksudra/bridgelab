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
entity data_swapper is
  port (
    reset : in std_logic;
    dmao_data : in std_logic_vector (31 downto 0);
    hrdata : out std_logic_vector (31 downto 0)
    );
end; 

architecture structural of data_swapper is
begin
  hrdata(7 downto 0) <= dmao_data(31 downto 24);
  hrdata(15 downto 8) <= dmao_data(23 downto 16);
  hrdata(23 downto 16) <= dmao_data(15 downto 8);
  hrdata(31 downto 24) <= dmao_data(7 downto 0); 
end;
