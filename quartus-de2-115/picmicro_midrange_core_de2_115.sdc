## Generated SDC file "picmicro_midrange_core_de2_115.out.sdc"

## Copyright (C) 2017  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Intel and sold by Intel or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 17.0.0 Build 595 04/25/2017 SJ Lite Edition"

## DATE    "Mon Nov  4 21:26:17 2019"

##
## DEVICE  "EP4CE115F29C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 20.000 -waveform { 0.000 0.500 } [get_ports {clk}]
create_clock -name {clk_wdt} -period 20.000 -waveform { 0.000 0.500 } [get_ports {clk_wdt}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clk_wdt}] -rise_to [get_clocks {clk_wdt}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk_wdt}] -fall_to [get_clocks {clk_wdt}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk_wdt}] -rise_to [get_clocks {clk_wdt}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk_wdt}] -fall_to [get_clocks {clk_wdt}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {generic_register:option|q[3]}] -rise_to [get_clocks {generic_register:option|q[3]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {generic_register:option|q[3]}] -fall_to [get_clocks {generic_register:option|q[3]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {generic_register:option|q[3]}] -rise_to [get_clocks {clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {generic_register:option|q[3]}] -fall_to [get_clocks {clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {generic_register:option|q[3]}] -rise_to [get_clocks {generic_register:option|q[3]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {generic_register:option|q[3]}] -fall_to [get_clocks {generic_register:option|q[3]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {generic_register:option|q[3]}] -rise_to [get_clocks {clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {generic_register:option|q[3]}] -fall_to [get_clocks {clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {generic_register:option|q[3]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {generic_register:option|q[3]}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {generic_register:option|q[3]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {generic_register:option|q[3]}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

