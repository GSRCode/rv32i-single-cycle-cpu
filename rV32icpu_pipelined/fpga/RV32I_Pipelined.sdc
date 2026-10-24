//Copyright (C)2014-2026 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.11.03 Education 
//Created Time: 2026-10-19 17:28:26
create_clock -name board_clk -period 20 -waveform {0 10} [get_ports {clk}]