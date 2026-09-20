set LIB /cadence/FOUNDRY/digital/45nm/NangateOpenCellLibrary_v1.00_20080225/liberty
file mkdir ../sta_report
read_lib $LIB/FreePDK45_lib_v1.0_typical.lib
read_verilog ../syn_report/simple_mac_netlist_iter1.v
set_top_module simple_mac
read_sdc ../syn_report/simple_mac_pd_iter1.sdc
report_timing -late -nworst 10 -max_paths 20         > ../sta_report/iter1_setup_top20.rpt
report_timing -late -nworst 1  -path_type full_clock > ../sta_report/iter1_top1_detailed.rpt
report_analysis_summary                              > ../sta_report/iter1_summary.rpt
