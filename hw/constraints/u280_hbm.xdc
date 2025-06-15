# CPU_RESET
#set_property PACKAGE_PIN L30     [get_ports sys_reset]
#set_property IOSTANDARD LVCMOS18 [get_ports sys_reset]
#set_false_path -from [get_pins inst_clk_wiz_0/locked] # Reset false path
set_property PACKAGE_PIN BJ43 [get_ports ddr0_sys_100M_p]
set_property PACKAGE_PIN BJ44 [get_ports ddr0_sys_100M_n]
set_property IOSTANDARD  DIFF_SSTL12 [get_ports ddr0_sys_100M_p]
set_property IOSTANDARD  DIFF_SSTL12 [get_ports ddr0_sys_100M_n]


#set_property PACKAGE_PIN BH6 [get_ports ddr1_sys_100M_p]
#set_property PACKAGE_PIN BJ6 [get_ports ddr1_sys_100M_n]
#set_property IOSTANDARD  DIFF_SSTL12 [get_ports ddr1_sys_100M_p]
#set_property IOSTANDARD  DIFF_SSTL12 [get_ports ddr1_sys_100M_n]

#set_property PACKAGE_PIN G31 [get_ports sys_100M_p]
#set_property PACKAGE_PIN F31 [get_ports sys_100M_n]
#set_property IOSTANDARD  DIFF_SSTL12 [get_ports sys_100M_p]
#set_property IOSTANDARD  DIFF_SSTL12 [get_ports sys_100M_n]

#############################################################################################################
create_clock -name ddr0_sys_clock -period 10 [get_ports ddr0_sys_100M_p]
#create_clock -name ddr1_sys_clock -period 10 [get_ports ddr1_sys_100M_p]
create_clock -name sys_clk -period 10 [get_ports sys_clk_p]
#
#############################################################################################################
set_false_path -from [get_ports sys_rst_n]
set_property PULLUP true [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS18 [get_ports sys_rst_n]
#
set_property PACKAGE_PIN BH26 [get_ports sys_rst_n]
#
set_property CONFIG_VOLTAGE 1.8 [current_design]
#
##############################################################################################################
#set_property PACKAGE_PIN AL14 [get_ports sys_clk_n]
#set_property PACKAGE_PIN AL15 [get_ports sys_clk_p]
set_property LOC [get_package_pins -of_objects [get_bels [get_sites -filter {NAME =~ *COMMON*} -of_objects [get_iobanks -of_objects [get_sites GTYE4_CHANNEL_X1Y7]]]/REFCLK0P]] [get_ports sys_clk_p]
set_property LOC [get_package_pins -of_objects [get_bels [get_sites -filter {NAME =~ *COMMON*} -of_objects [get_iobanks -of_objects [get_sites GTYE4_CHANNEL_X1Y7]]]/REFCLK0N]] [get_ports sys_clk_n]
##
#############################################################################################################

set_property PACKAGE_PIN D32 [get_ports d32_port]
set_property IOSTANDARD  LVCMOS18 [get_ports d32_port]

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
set_false_path -to [get_pins -hier *sync_reg[0]/D]
#
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets */APB_0_PCLK]


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

set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT1]] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT2]] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT3]] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT4]] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT5]] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT6]] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]

set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT1]]
set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT2]]
set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT3]]
set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT4]]
set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT5]]
set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT6]]

set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks {xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/xdma_0_pcie4c_ip_gt_i/inst/gen_gtwizard_gtye4_top.xdma_0_pcie4c_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[24].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]
set_false_path -from [get_clocks {xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/xdma_0_pcie4c_ip_gt_i/inst/gen_gtwizard_gtye4_top.xdma_0_pcie4c_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[24].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]

set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/xdma_0_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]]
set_false_path -from [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/xdma_0_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]] -to [get_clocks -of_objects [get_pins {xdma_0_i/inst/pcie4c_ip_i/inst/xdma_0_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/xdma_0_pcie4c_ip_gt_i/inst/gen_gtwizard_gtye4_top.xdma_0_pcie4c_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[27].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_false_path -from [get_clocks -of_objects [get_pins {xdma_0_i/inst/pcie4c_ip_i/inst/xdma_0_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/xdma_0_pcie4c_ip_gt_i/inst/gen_gtwizard_gtye4_top.xdma_0_pcie4c_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[27].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/xdma_0_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
set_false_path -from [get_clocks -of_objects [get_pins u_mmcm_0/CLKOUT0]] -to [get_clocks -of_objects [get_pins xdma_0_i/inst/pcie4c_ip_i/inst/xdma_0_pcie4c_ip_gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_userclk/O]]
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