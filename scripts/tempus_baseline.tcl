# Tempus baseline STA on Nangate FreePDK45 synthesized netlist
# Purpose: capture starting timing state for P4 timing-closure case study

set LIB /cadence/FOUNDRY/digital/45nm/NangateOpenCellLibrary_v1.00_20080225/liberty

file mkdir ../sta_report

read_lib $LIB/FreePDK45_lib_v1.0_typical.lib
read_verilog ../syn_report/simple_mac_netlist_nangate.v
set_top_module simple_mac
read_sdc ../constraints/simple_mac_nangate.sdc

set_global timing_defaultDelay 0

report_timing -late -nworst 10 -max_paths 20   > ../sta_report/baseline_setup_top20.rpt
report_timing -late -nworst 5  -path_type full_clock > ../sta_report/baseline_top5_detailed.rpt
report_analysis_coverage                        > ../sta_report/baseline_coverage.rpt
report_constraints -all_violators               > ../sta_report/baseline_violators.rpt

report_timing -late -path_group reg2reg -nworst 3   > ../sta_report/baseline_reg2reg.rpt
report_timing -late -path_group default -nworst 3   > ../sta_report/baseline_default.rpt
report_timing -late -path_group in2reg -nworst 3    > ../sta_report/baseline_in2reg.rpt
report_timing -late -path_group reg2out -nworst 3   > ../sta_report/baseline_reg2out.rpt
