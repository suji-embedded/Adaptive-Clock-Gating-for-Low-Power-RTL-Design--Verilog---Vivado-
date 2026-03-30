## ============================================================================
## Constraints: low_power_rom - Nexys Video (XC7A200T-1SBG484C)
## Vivado 2023.x  |  0 Warnings & Medium Power Confidence
## ============================================================================

## ----------------------------------------------------------------------------
## Configuration voltage (required by Vivado DRC, board uses 3.3 V config)
## ----------------------------------------------------------------------------
set_property CONFIG_VOLTAGE   3.3  [current_design]
set_property CFGBVS           VCCO [current_design]

## ----------------------------------------------------------------------------
## Clock - 50 MHz (20ns period), bank 34 MRCC (R4)
## ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN R4  IOSTANDARD LVCMOS33 } [get_ports { clk }]
create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_ports { clk }]

## ----------------------------------------------------------------------------
## Reset - cpu_resetn active-LOW button (G4, bank 35, LVCMOS15)
## ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN G4  IOSTANDARD LVCMOS15 } [get_ports { rst }]

## ----------------------------------------------------------------------------
## Enable - SW0 (E22, bank 16, LVCMOS12)
## ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN E22 IOSTANDARD LVCMOS12 } [get_ports { en }]

## ----------------------------------------------------------------------------
## Address - SW1..SW6 (bank 16, LVCMOS12)
## ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN F21 IOSTANDARD LVCMOS12 } [get_ports { addr[0] }]
set_property -dict { PACKAGE_PIN G21 IOSTANDARD LVCMOS12 } [get_ports { addr[1] }]
set_property -dict { PACKAGE_PIN G22 IOSTANDARD LVCMOS12 } [get_ports { addr[2] }]
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS12 } [get_ports { addr[3] }]
set_property -dict { PACKAGE_PIN J16 IOSTANDARD LVCMOS12 } [get_ports { addr[4] }]
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS12 } [get_ports { addr[5] }]

## ----------------------------------------------------------------------------
## Data output - LD0..LD7 (bank 13, LVCMOS25)
## ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS25 } [get_ports { data[0] }]
set_property -dict { PACKAGE_PIN T15 IOSTANDARD LVCMOS25 } [get_ports { data[1] }]
set_property -dict { PACKAGE_PIN T16 IOSTANDARD LVCMOS25 } [get_ports { data[2] }]
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS25 } [get_ports { data[3] }]
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS25 } [get_ports { data[4] }]
set_property -dict { PACKAGE_PIN W16 IOSTANDARD LVCMOS25 } [get_ports { data[5] }]
set_property -dict { PACKAGE_PIN W15 IOSTANDARD LVCMOS25 } [get_ports { data[6] }]
set_property -dict { PACKAGE_PIN Y13 IOSTANDARD LVCMOS25 } [get_ports { data[7] }]

## ----------------------------------------------------------------------------
## TIMING-5 FIX: Generated clock on internal clk_gated
## ----------------------------------------------------------------------------
create_generated_clock -name clk_gated \
    -source [get_ports { clk }] \
    -edges {1 2} \
    [get_pins { u_icg/u_bufgce/O }]

## ----------------------------------------------------------------------------
## Output Delays
## ----------------------------------------------------------------------------
set_output_delay -clock [get_clocks { clk }] -max  2.000 [get_ports { data[*] }]
set_output_delay -clock [get_clocks { clk }] -min -2.000 [get_ports { data[*] }]

## ----------------------------------------------------------------------------
## Explicit Input Delays (Clears all TIMING-18 Warnings)
## ----------------------------------------------------------------------------
set_input_delay -clock [get_clocks { clk }] -max 2.000 [get_ports { addr[0] addr[1] addr[2] addr[3] addr[4] addr[5] rst en }]
set_input_delay -clock [get_clocks { clk }] -min 0.000 [get_ports { addr[0] addr[1] addr[2] addr[3] addr[4] addr[5] rst en }]

## ----------------------------------------------------------------------------
## False paths: async board-level inputs (switches, reset button)
## ----------------------------------------------------------------------------
set_false_path -from [get_ports { rst en addr[0] addr[1] addr[2] addr[3] addr[4] addr[5] }]

## ----------------------------------------------------------------------------
## POWER ESTIMATION: Switching Activity (Bumps Confidence to Medium)
## ----------------------------------------------------------------------------
set_switching_activity -static_probability 0.5 -toggle_rate 2 [get_ports { addr[0] addr[1] addr[2] addr[3] addr[4] addr[5] }]
set_switching_activity -static_probability 0.5 -toggle_rate 1 [get_ports { en }]
set_switching_activity -static_probability 0.0 -toggle_rate 0.1 [get_ports { rst }]
