## ============================================================
## Nexys Video (xc7a200tsbg484-1) Constraints File
## Design : Lookahead Clock Gating + Gray Code 64x8 ROM
## ============================================================

## ============================================================
## CLOCK - 100MHz (Pin R4)
## ============================================================
set_property PACKAGE_PIN R4 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk [get_ports clk]

## ============================================================
## RESET (Pin G4)
## ============================================================
set_property PACKAGE_PIN G4 [get_ports rst]
set_property IOSTANDARD LVCMOS15 [get_ports rst]
set_false_path -from [get_ports rst]

## ============================================================
## ENABLE - SW0 (Pin E22) ? en gets E22
## ============================================================
set_property PACKAGE_PIN E22 [get_ports en]
set_property IOSTANDARD LVCMOS12 [get_ports en]
set_false_path -from [get_ports en]

## ============================================================
## ADDRESS INPUT - addr[5:0]
## SW1=F21, SW2=G21, SW3=G22, SW4=H17, SW5=J16, SW6=K13
## ============================================================
set_property PACKAGE_PIN F21 [get_ports {addr[0]}]
set_property IOSTANDARD LVCMOS12 [get_ports {addr[0]}]

set_property PACKAGE_PIN G21 [get_ports {addr[1]}]
set_property IOSTANDARD LVCMOS12 [get_ports {addr[1]}]

set_property PACKAGE_PIN G22 [get_ports {addr[2]}]
set_property IOSTANDARD LVCMOS12 [get_ports {addr[2]}]

set_property PACKAGE_PIN H17 [get_ports {addr[3]}]
set_property IOSTANDARD LVCMOS12 [get_ports {addr[3]}]

set_property PACKAGE_PIN J16 [get_ports {addr[4]}]
set_property IOSTANDARD LVCMOS12 [get_ports {addr[4]}]

set_property PACKAGE_PIN K13 [get_ports {addr[5]}]
set_property IOSTANDARD LVCMOS12 [get_ports {addr[5]}]

set_false_path -from [get_ports {addr[*]}]

## ============================================================
## DATA OUTPUT - LEDs LD0 to LD7
## ============================================================
set_property PACKAGE_PIN T14 [get_ports {data[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {data[0]}]

set_property PACKAGE_PIN T15 [get_ports {data[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {data[1]}]

set_property PACKAGE_PIN T16 [get_ports {data[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {data[2]}]

set_property PACKAGE_PIN U16 [get_ports {data[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {data[3]}]

set_property PACKAGE_PIN V15 [get_ports {data[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {data[4]}]

set_property PACKAGE_PIN W16 [get_ports {data[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {data[5]}]

set_property PACKAGE_PIN W15 [get_ports {data[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {data[6]}]

set_property PACKAGE_PIN Y13 [get_ports {data[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {data[7]}]

set_false_path -to [get_ports {data[*]}]

## ============================================================
## GATED CLOCK OUTPUT - LED LD8
## ============================================================
set_property PACKAGE_PIN AA13 [get_ports gated_clk]
set_property IOSTANDARD LVCMOS25 [get_ports gated_clk]
set_false_path -to [get_ports gated_clk]

## ============================================================
## CONFIG VOLTAGE - Fix CFGBVS DRC Warning
## ============================================================
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
```

---

## ? Pin Assignment Summary

| Port | Pin | Standard | Note |
|---|---|---|---|
| `clk` | R4 | LVCMOS33 | 100MHz clock |
| `rst` | G4 | LVCMOS15 | Reset button |
| `en` | E22 | LVCMOS12 | SW0 |
| `addr[0]` | F21 | LVCMOS12 | SW1 ? Fixed |
| `addr[1]` | G21 | LVCMOS12 | SW2 |
| `addr[2]` | G22 | LVCMOS12 | SW3 |
| `addr[3]` | H17 | LVCMOS12 | SW4 |
| `addr[4]` | J16 | LVCMOS12 | SW5 |
| `addr[5]` | K13 | LVCMOS12 | SW6 |
| `data[0-7]` | T14-Y13 | LVCMOS25 | LEDs |
| `gated_clk` | AA13 | LVCMOS25 | LED8 |

---

## ?? Steps
```
Step 1: Replace entire .xdc with above
Step 2: Save (Ctrl+S)
Step 3: Reset Runs ? impl_1
Step 4: Run Implementation
Step 5: Report DRC ? 0 errors ?
Step 6: Report Power ?