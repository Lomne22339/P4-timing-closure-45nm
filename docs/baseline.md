# P4 — Timing Closure Case Study: Baseline

**Design:** 8×8 Multiply-Accumulate unit (simple_mac) — FSM controller + 4-entry coefficient register file + 16-bit accumulator, mentor-supplied RTL, ~140 lines Verilog.

**Library:** Nangate FreePDK45 (FreePDK45_lib_v1.0_typical.lib, 113 cells)
**Synthesis tool:** Cadence Genus 19.13 (RTL → mapped netlist, effort medium)
**STA tool:** Cadence Tempus 20.10
**Analysis mode:** Pre-layout, ideal clock, no parasitics, default net delay 1000 ps
**Target clock:** 200 MHz (5.0 ns period)

Baseline captured Sat Sep 19, 2026 by running scripts/tempus_baseline.tcl on the P3b Nangate-branch synthesized netlist.

---

## Headline metrics

| Metric | Value |
|---|---|
| **WNS (worst negative slack)** | **−1309 ps** |
| **TNS (total negative slack)** | **−23,572 ps** |
| **Total violating paths** | **40** |
| Cells (Tempus view) | 106 (86 combinational + 20 sequential) |
| Cells (Genus report) | 528 (includes hierarchy) |
| Setup requirement | 1020 ps |
| Clock uncertainty | 200 ps |
| Hold violations | **0** — this is a setup-only problem |

---

## Path-group breakdown

| Group | WNS | TNS | # Violators |
|---|---|---|---|
| IN2REG | −1309 ps | −11,574 ps | 12 |
| REG2REG | −1215 ps | −11,998 ps | 28 |
| IN2OUT | 0 | 0 | 0 |
| REG2OUT | 0 | 0 | 0 |

**Observation:** the pain is split roughly evenly between IN2REG (input port → flop) and REG2REG (flop → flop). Both categories are dominated by the same combinational structure — the multiplier.

---

## Critical path anatomy (Path #1, WNS −1309 ps)

**Beginpoint:** coef_sel[1] (primary input port, input delay 1500 ps)
**Endpoint:** mult_result_reg[14]/SI (scan input of SDFFR_X2)
**Path length:** 31 combinational gates
**Path signature:**
  - 27× NAND2_X1 (minimum drive)
  - 4× INV_X1 / INV_X2 / INV_X4 / INV_X8
  - 1× AND2_X2, 1× BUF_X16, 1× OAI21_X1
**Physical region:** entirely inside mul_58_40/* — the 8×8 array multiplier module
**Slack budget breakdown:**
  - Required time: 3780 ps (5000 clock − 1020 setup − 200 uncertainty)
  - Arrival time: 5089 ps
  - **Gap: −1309 ps**

The pure combinational arrival time (5089 ps) already exceeds the clock period (5000 ps) by 89 ps before any setup timing is applied. Setup and uncertainty then add another 1220 ps of shortfall.

---

## Top-5 critical paths — all structurally similar

| # | Beginpoint | Endpoint | Slack |
|---|---|---|---|
| 1 | coef_sel[1] | mult_result_reg[14]/SI | −1309 ps |
| 2 | coef_sel[1] | mult_result_reg[13]/SI | −1302 ps |
| 3 | coef_sel[1] | mult_result_reg[14]/SI | −1301 ps |
| 4 | coef_sel[0] | mult_result_reg[14]/SI | −1299 ps |

Every top path is coef_sel[*] → multiplier → mult_result_reg[*upper bits*]. The upper result bits accumulate the longest carry chains from the 8×8 array multiplier. **This is one structural bottleneck, not forty independent bugs.**

---

## Why Nangate hurts here (context from P3b comparison)

Same RTL synthesized on Cadence GSCLIB045 achieved WNS +40 ps at the same 200 MHz. The delta comes from library composition:

Nangate FreePDK45 ships **no dedicated adder cells** (no ADDF*, no HA*)
The multiplier is therefore built from primitive NAND2/INV gates
GSCLIB045's ADDFHX* family collapses each 1-bit full-adder into 1 cell; Nangate uses 5–7 gates for the same function
Result: the multiplier's carry chain becomes 31 gates deep on Nangate vs ~20 on GSCLIB045

This is the "library selection dominates datapath performance" observation, quantified.

---

## Optimization levers available for P4

| Lever | Expected impact | Cost / risk |
|---|---|---|
| **Cell sizing / drive-strength tuning** | Recover 100–300 ps by upsizing critical-path cells | Low risk, needs Innovus or Genus incremental optimization |
| **Retiming** | Redistribute pipeline registers across combinational cloud | RTL semantics preserved; Genus supports if enabled |
| **Multi-Vt swap** | **Unavailable** — Nangate ships single Vt only | — |
| **Pipelining** | Insert a register stage inside th
| **Clock relaxation** | Set clock period to 6/7 ns until timing meets | Documents what freq the design actually runs at; not "closure" in the true sense |
| **Physical design** | Some paths recover during place & route as real delays replace 1000 ps default | Requires running Innovus |

---

## Success criterion for P4

**Primary goal:** achieve WNS ≥ 0 ps @ 200 MHz with a documented method
**Fallback goal:** if 200 MHz is infeasible on this library without RTL changes, document the maximum achievable frequency with unmodified RTL and record it as a library-limit finding
**Non-goal:** GDSII — that's what P3b already produced. P4 is a methodology and analysis project, not a re-run of the P&R flow

---

## Raw report artifacts

All reports in sta_report/:
baseline_setup_top20.rpt — top 20 setup violators with full path traces
baseline_top5_detailed.rpt — top 5 paths with full clock path
baseline_coverage.rpt — analysis coverage summary
baseline_violators.rpt — all violating constraints
baseline_default.rpt — default path group
baseline_reg2reg.rpt, baseline_in2reg.rpt, baseline_reg2out.rpt — empty (Tempus does not define these groups by default; will re-create in iteration 1 via group_path)

