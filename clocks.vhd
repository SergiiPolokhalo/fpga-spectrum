-- ZX Spectrum for Altera DE1
--
-- Copyright (c) 2009-2010 Mike Stirling
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- * Redistributions of source code must retain the above copyright notice,
--   this list of conditions and the following disclaimer.
--
-- * Redistributions in synthesized form must reproduce the above copyright
--   notice, this list of conditions and the following disclaimer in the
--   documentation and/or other materials provided with the distribution.
--
-- * Neither the name of the author nor the names of other contributors may
--   be used to endorse or promote products derived from this software without
--   specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clocks is
port (
	-- 28 MHz master clock
	CLK				:	in std_logic;
	-- Master reset
	nRESET			:	in std_logic;
	
	-- 3.5 MHz clock enable (1 in 8)
	CLKEN_CPU		:	out std_logic;
	-- 14 MHz clock enable (out of phase with CPU)
	CLKEN_VID		:	out std_logic;
	-- 427.5 kHz clock enable for I2C
	CLKEN_I2C		:	out	std_logic;
	
	-- Set to slow the CPU
	SLOW			:	in	std_logic
	);
end clocks;

-- Clock enables for uncontended VRAM access
-- 0    1    2    3    4    5    6    7
-- CPU  VID       VID       VID       VID

architecture clocks_arch of clocks is
signal counter	:	std_logic_vector(19 downto 0);
begin
	CLKEN_CPU <= not (counter(0) or counter(1) or counter(2)) and counter(3) and
		counter(4) and counter(5) and counter(6) and counter(7) and counter(8) and
		counter(9) and counter(10) and counter(11) and counter(12) and counter(13) and
		counter(14) and counter(15) and counter(16) and counter(17) and counter(18) and
		counter(19) when SLOW = '1' else
		-- 000
		not (counter(0) or counter(1) or counter(2));
		
	-- 00X
	CLKEN_VID <= counter(0);
	
	-- 111111 (/64)
	CLKEN_I2C <= counter(0) and counter(1) and counter(2) and counter(3) and counter(4) and
		counter(5);

	process(nRESET,CLK)
	begin
		if nRESET = '0' then
			counter <= (others => '0');
		elsif falling_edge(CLK) then
			counter <= counter + '1';
		end if;
	end process;
end clocks_arch;

