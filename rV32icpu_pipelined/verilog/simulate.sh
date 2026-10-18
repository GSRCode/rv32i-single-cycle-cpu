#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python3 make_program.py
iverilog -g2012 -Wall -s cpu_tb -o cpu_test.vvp cpu.v IFetch.v IDecode.v BubbleControl.v ID_EX.v HazardDetectionUnit.v ForwardingUnit.v Execute.v EX_MEM.v StoreForwardingUnit.v Memory.v MEM_WB.v cpu_tb.v
vvp cpu_test.vvp | tee simulation.log
grep -q 'PASS: FULL PIPELINE REGRESSION' simulation.log
