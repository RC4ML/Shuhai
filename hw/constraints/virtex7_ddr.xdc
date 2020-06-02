# CPU_RESET
#set_property PACKAGE_PIN L30     [get_ports sys_reset]
#set_property IOSTANDARD LVCMOS18 [get_ports sys_reset]
#set_false_path -from [get_pins inst_clk_wiz_0/locked] # Reset false path
#set_property PACKAGE_PIN BJ43 [get_ports ddr0_sys_100M_p]
#set_property PACKAGE_PIN BJ44 [get_ports ddr0_sys_100M_n]
#set_property IOSTANDARD  DIFF_SSTL12 [get_ports ddr0_sys_100M_p]
#set_property IOSTANDARD  DIFF_SSTL12 [get_ports ddr0_sys_100M_n]


#set_property PACKAGE_PIN BH6 [get_ports ddr1_sys_100M_p]
#set_property PACKAGE_PIN BJ6 [get_ports ddr1_sys_100M_n]
#set_property IOSTANDARD  DIFF_SSTL12 [get_ports ddr1_sys_100M_p]
#set_property IOSTANDARD  DIFF_SSTL12 [get_ports ddr1_sys_100M_n]

#set_property PACKAGE_PIN G31 [get_ports sys_100M_p]
#set_property PACKAGE_PIN F31 [get_ports sys_100M_n]
#set_property IOSTANDARD  DIFF_SSTL12 [get_ports sys_100M_p]
#set_property IOSTANDARD  DIFF_SSTL12 [get_ports sys_100M_n]

#DDR3###########################################################################
#clock
#set_property PACKAGE_PIN [get_ports {clk_ref_p}]
#set_property PACKAGE_PIN [get_ports {clk_ref_n}]

set_property PACKAGE_PIN AH15 [get_ports c0_sys_clk_p]
set_property PACKAGE_PIN AJ15 [get_ports c0_sys_clk_n]
set_property PACKAGE_PIN G30 [get_ports c1_sys_clk_p]
set_property PACKAGE_PIN G31 [get_ports c1_sys_clk_n]


#on & poke
set_property PACKAGE_PIN AA24 [get_ports {dram_on[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {dram_on[*]}]
set_property PACKAGE_PIN AB25 [get_ports {dram_on[1]}]
set_property PACKAGE_PIN AA31 [get_ports pok_dram]
set_property IOSTANDARD LVCMOS18 [get_ports pok_dram]


set_property PACKAGE_PIN AH10 [get_ports {c0_ddr3_dm[0]}]
set_property PACKAGE_PIN AF9 [get_ports {c0_ddr3_dm[1]}]
set_property PACKAGE_PIN AM13 [get_ports {c0_ddr3_dm[2]}]
set_property PACKAGE_PIN AL10 [get_ports {c0_ddr3_dm[3]}]
set_property PACKAGE_PIN AL20 [get_ports {c0_ddr3_dm[4]}]
set_property PACKAGE_PIN AJ24 [get_ports {c0_ddr3_dm[5]}]
set_property PACKAGE_PIN AD22 [get_ports {c0_ddr3_dm[6]}]
set_property PACKAGE_PIN AD15 [get_ports {c0_ddr3_dm[7]}]
set_property PACKAGE_PIN AM23 [get_ports {c0_ddr3_dm[8]}]

set_property VCCAUX_IO NORMAL [get_ports {c0_ddr3_dm[*]}]
set_property SLEW FAST [get_ports {c0_ddr3_dm[*]}]
set_property IOSTANDARD SSTL15 [get_ports {c0_ddr3_dm[*]}]


set_property PACKAGE_PIN B32 [get_ports {c1_ddr3_dm[0]}]
set_property PACKAGE_PIN A30 [get_ports {c1_ddr3_dm[1]}]
set_property PACKAGE_PIN E24 [get_ports {c1_ddr3_dm[2]}]
set_property PACKAGE_PIN B26 [get_ports {c1_ddr3_dm[3]}]
set_property PACKAGE_PIN U31 [get_ports {c1_ddr3_dm[4]}]
set_property PACKAGE_PIN R29 [get_ports {c1_ddr3_dm[5]}]
set_property PACKAGE_PIN K34 [get_ports {c1_ddr3_dm[6]}]
set_property PACKAGE_PIN N34 [get_ports {c1_ddr3_dm[7]}]
set_property PACKAGE_PIN P25 [get_ports {c1_ddr3_dm[8]}]

set_property VCCAUX_IO NORMAL [get_ports {c1_ddr3_dm[*]}]
set_property SLEW FAST [get_ports {c1_ddr3_dm[*]}]
set_property IOSTANDARD SSTL15 [get_ports {c1_ddr3_dm[*]}]


#############################################################################################################
#create_clock -name ddr0_sys_clock -period 10 [get_ports ddr0_sys_100M_p]
#create_clock -name ddr1_sys_clock -period 10 [get_ports ddr1_sys_100M_p]
#create_clock -name sys_clk -period 10 [get_ports sys_clk_p]
##############################################################################################################
set_property PACKAGE_PIN W27 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS18 [get_ports sys_rst_n]
set_property PULLUP true [get_ports sys_rst_n]
set_property PACKAGE_PIN F5 [get_ports sys_clk_n]


set_property LOC GTHE2_CHANNEL_X1Y35 [get_cells {dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gth_channel.gthe2_channel_i}]
#set_property LOC GTHE2_CHANNEL_X1Y35 [get_cells {dma_driver_inst/dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gth_channel.gthe2_channel_i}]
set_property PACKAGE_PIN B5 [get_ports {pci_exp_rxn[0]}]
set_property PACKAGE_PIN B6 [get_ports {pci_exp_rxp[0]}]
set_property PACKAGE_PIN A3 [get_ports {pci_exp_txn[0]}]
set_property PACKAGE_PIN A4 [get_ports {pci_exp_txp[0]}]
set_property LOC GTHE2_CHANNEL_X1Y34 [get_cells {dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[1].gt_wrapper_i/gth_channel.gthe2_channel_i}]
#set_property LOC GTHE2_CHANNEL_X1Y34 [get_cells {dma_driver_inst/dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[1].gt_wrapper_i/gth_channel.gthe2_channel_i}]
set_property PACKAGE_PIN D5 [get_ports {pci_exp_rxn[1]}]
set_property PACKAGE_PIN D6 [get_ports {pci_exp_rxp[1]}]
set_property PACKAGE_PIN B1 [get_ports {pci_exp_txn[1]}]
set_property PACKAGE_PIN B2 [get_ports {pci_exp_txp[1]}]
set_property LOC GTHE2_CHANNEL_X1Y33 [get_cells {dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[2].gt_wrapper_i/gth_channel.gthe2_channel_i}]
#set_property LOC GTHE2_CHANNEL_X1Y33 [get_cells {dma_driver_inst/dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[2].gt_wrapper_i/gth_channel.gthe2_channel_i}]
set_property PACKAGE_PIN E3 [get_ports {pci_exp_rxn[2]}]
set_property PACKAGE_PIN E4 [get_ports {pci_exp_rxp[2]}]
set_property PACKAGE_PIN C3 [get_ports {pci_exp_txn[2]}]
set_property PACKAGE_PIN C4 [get_ports {pci_exp_txp[2]}]
set_property LOC GTHE2_CHANNEL_X1Y32 [get_cells {dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[3].gt_wrapper_i/gth_channel.gthe2_channel_i}]
#set_property LOC GTHE2_CHANNEL_X1Y32 [get_cells {dma_driver_inst/dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[3].gt_wrapper_i/gth_channel.gthe2_channel_i}]
set_property PACKAGE_PIN G3 [get_ports {pci_exp_rxn[3]}]
set_property PACKAGE_PIN G4 [get_ports {pci_exp_rxp[3]}]
set_property PACKAGE_PIN D1 [get_ports {pci_exp_txn[3]}]
set_property PACKAGE_PIN D2 [get_ports {pci_exp_txp[3]}]
set_property LOC GTHE2_CHANNEL_X1Y31 [get_cells {dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[4].gt_wrapper_i/gth_channel.gthe2_channel_i}]
#set_property LOC GTHE2_CHANNEL_X1Y31 [get_cells {dma_driver_inst/dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[4].gt_wrapper_i/gth_channel.gthe2_channel_i}]
set_property PACKAGE_PIN J3 [get_ports {pci_exp_rxn[4]}]
set_property PACKAGE_PIN J4 [get_ports {pci_exp_rxp[4]}]
set_property PACKAGE_PIN F1 [get_ports {pci_exp_txn[4]}]
set_property PACKAGE_PIN F2 [get_ports {pci_exp_txp[4]}]
set_property LOC GTHE2_CHANNEL_X1Y30 [get_cells {dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[5].gt_wrapper_i/gth_channel.gthe2_channel_i}]
#set_property LOC GTHE2_CHANNEL_X1Y30 [get_cells {dma_driver_inst/dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[5].gt_wrapper_i/gth_channel.gthe2_channel_i}]
set_property PACKAGE_PIN K5 [get_ports {pci_exp_rxn[5]}]
set_property PACKAGE_PIN K6 [get_ports {pci_exp_rxp[5]}]
set_property PACKAGE_PIN H1 [get_ports {pci_exp_txn[5]}]
set_property PACKAGE_PIN H2 [get_ports {pci_exp_txp[5]}]
set_property LOC GTHE2_CHANNEL_X1Y29 [get_cells {dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[6].gt_wrapper_i/gth_channel.gthe2_channel_i}]
#set_property LOC GTHE2_CHANNEL_X1Y29 [get_cells {dma_driver_inst/dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[6].gt_wrapper_i/gth_channel.gthe2_channel_i}]
set_property PACKAGE_PIN L3 [get_ports {pci_exp_rxn[6]}]
set_property PACKAGE_PIN L4 [get_ports {pci_exp_rxp[6]}]
set_property PACKAGE_PIN K1 [get_ports {pci_exp_txn[6]}]
set_property PACKAGE_PIN K2 [get_ports {pci_exp_txp[6]}]
set_property LOC GTHE2_CHANNEL_X1Y28 [get_cells {dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[7].gt_wrapper_i/gth_channel.gthe2_channel_i}]
#set_property LOC GTHE2_CHANNEL_X1Y28 [get_cells {dma_driver_inst/dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_lane[7].gt_wrapper_i/gth_channel.gthe2_channel_i}]
set_property PACKAGE_PIN N3 [get_ports {pci_exp_rxn[7]}]
set_property PACKAGE_PIN N4 [get_ports {pci_exp_rxp[7]}]
set_property PACKAGE_PIN M1 [get_ports {pci_exp_txn[7]}]
set_property PACKAGE_PIN M2 [get_ports {pci_exp_txp[7]}]

#set_false_path -from [get_ports sys_rst_n]
#set_property PULLUP true [get_ports sys_rst_n]
#set_property IOSTANDARD LVCMOS18 [get_ports sys_rst_n]
#
#set_property PACKAGE_PIN BH26 [get_ports sys_rst_n]
#
set_property CONFIG_VOLTAGE 1.8 [current_design]
#
##############################################################################################################
#set_property PACKAGE_PIN AL14 [get_ports sys_clk_n]
#set_property PACKAGE_PIN AL15 [get_ports sys_clk_p]
#set_property LOC [get_package_pins -of_objects [get_bels [get_sites -filter {NAME =~ *COMMON*} -of_objects [get_iobanks -of_objects [get_sites GTYE4_CHANNEL_X1Y7]]]/REFCLK0P]] [get_ports sys_clk_p]
#set_property LOC [get_package_pins -of_objects [get_bels [get_sites -filter {NAME =~ *COMMON*} -of_objects [get_iobanks -of_objects [get_sites GTYE4_CHANNEL_X1Y7]]]/REFCLK0N]] [get_ports sys_clk_n]


##
#############################################################################################################
#############################################################################################################
#
#
# BITFILE/BITSTREAM compress options
#
#set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
#set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1 [current_design]
#set_property CONFIG_MODE BPI16 [current_design]
#set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
#set_property BITSTREAM.CONFIG.UNUSEDPIN Pulldown [current_design]
#
#
#set_false_path -to [get_pins -hier *sync_reg[0]/D]
#
#set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
#connect_debug_port dbg_hub/clk [get_nets */APB_0_PCLK]


# Bitstream Configuration
# ------------------------------------------------------------------------
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.CONFIG.CONFIGFALLBACK Enable [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 85.0 [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN disable [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR Yes [current_design]
# ------------------------------------------------------------------------

set_false_path -from [get_clocks -of_objects [get_pins dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT3]] -to [get_clocks -of_objects [get_pins u_mig_7series_0/u_mig_7series_0_mig/c0_u_ddr3_infrastructure/gen_mmcm.mmcm_i/CLKFBOUT]]
set_false_path -from [get_clocks -of_objects [get_pins u_mig_7series_0/u_mig_7series_0_mig/c1_u_ddr3_infrastructure/gen_mmcm.mmcm_i/CLKFBOUT]] -to [get_clocks -of_objects [get_pins dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT3]]
set_false_path -from [get_clocks -of_objects [get_pins dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT3]] -to [get_clocks -of_objects [get_pins u_mig_7series_0/u_mig_7series_0_mig/c1_u_ddr3_infrastructure/gen_mmcm.mmcm_i/CLKFBOUT]]
set_false_path -from [get_clocks -of_objects [get_pins u_mig_7series_0/u_mig_7series_0_mig/c0_u_ddr3_infrastructure/gen_mmcm.mmcm_i/CLKFBOUT]] -to [get_clocks -of_objects [get_pins dma_inst/inst/pcie3_ip_i/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT3]]


#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT1]] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT2]] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT3]] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT4]] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT5]] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT6]] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]

#set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT1]]
#set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT2]]
#set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT3]]
#set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT4]]
#set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT5]]
#set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT6]]

#set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks {xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/xdma_0_pcie4c_ip_gt_i/inst/gen_gtwizard_gtye4_top.xdma_0_pcie4c_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[24].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]
#set_false_path -from [get_clocks {xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/xdma_0_pcie4c_ip_gt_i/inst/gen_gtwizard_gtye4_top.xdma_0_pcie4c_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[24].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]


#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT1]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT2]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT3]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT4]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT5]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT6]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]] -to [get_clocks -of_objects [get_pins u_mmcm_1/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]] -to [get_clocks -of_objects [get_pins u_mmcm_1/CLKOUT1]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]] -to [get_clocks -of_objects [get_pins u_mmcm_1/CLKOUT2]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]] -to [get_clocks -of_objects [get_pins u_mmcm_1/CLKOUT3]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]] -to [get_clocks -of_objects [get_pins u_mmcm_1/CLKOUT4]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]] -to [get_clocks -of_objects [get_pins u_mmcm_1/CLKOUT5]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]] -to [get_clocks -of_objects [get_pins u_mmcm_1/CLKOUT6]]

#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT1]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT2]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT3]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT4]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT5]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT6]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_1/CLKOUT1]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_1/CLKOUT2]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_1/CLKOUT3]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_1/CLKOUT4]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_1/CLKOUT5]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_1/CLKOUT6]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_1/CLKOUT0]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]]

#set_false_path -from [get_clocks -of_objects [get_pins u_ddr4_0/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins u_ddr4_1/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins u_ddr4_0/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
#set_false_path -from [get_clocks -of_objects [get_pins u_ddr4_1/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
#set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins u_ddr4_0/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins u_ddr4_1/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0]]
