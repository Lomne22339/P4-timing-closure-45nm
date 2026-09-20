# Iteration 1: Genus High-Effort Re-synthesis

**Date:** Sep 19, 2026
**Method:** Cadence Genus 19.13 with all effort knobs at high (syn_generic, syn_map, syn_opt), tns_opto true, retime true
**Compared against:** baseline (Genus effort medium, P3b Nangate branch)

## Results (Cadence Tempus 20.10)

| Metric | Baseline | Iter1 | Delta |
|---|---|---|---|
| WNS | −1309 ps | −1309 ps | **0 ps** |
| TNS | −23,572 ps | −23,572 ps | **0 ps** |
| Violating paths | 40 | 40 | 0 |
| Critical path | coef_sel[1] → mult_result_reg[14]/SI | Same | Structurally unchanged |

## Genus internal STA disagreed with Tempus signoff

Genus final report: WNS −1189 ps (claims 120 ps improvement over baseline)
Tempus signoff: WNS −1309 ps (no improvement)
Delta: Tempus's stricter setup checking swallowed Genus's optimizations

## Conclusion

Genus effort knobs alone are insufficient to move signoff timing on a datapath dominated by an arithmetic structure the library cannot implement efficiently (Nangate FreePDK45 lacks dedicated adder cells).

**Retirement of levers:**
❌ Genus effort=high alone: no signoff impact
❌ Retiming (Genus): did not fire — multiplier is monolithic combinational logic with no register locations to redistribute

**Levers still available:**
Innovus placement-aware cell sizing (optDesign)
Clock relaxation (find max frequency at which design closes)
RTL surgery: pipeline the multiplier (adds latency, unblocks 200 MHz)
