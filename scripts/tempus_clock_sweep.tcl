set LIB /cadence/FOUNDRY/digital/45nm/NangateOpenCellLibrary_v1.00_20080225/liberty
file mkdir ../sta_report
read_lib $LIB/FreePDK45_lib_v1.0_typical.lib
read_verilog ../syn_report/simple_mac_netlist_iter1.v
set_top_module simple_mac
read_sdc ../syn_report/simple_mac_pd_iter1.sdc

foreach p {5.0 5.5 6.0 6.5 7.0 7.5 8.0} {
    puts "==== period = $p ns ===="
    create_clock -name clk -period $p [get_ports clk]
    report_timing -late -nworst 1 -path_type end
    report_analysis_summary
}
