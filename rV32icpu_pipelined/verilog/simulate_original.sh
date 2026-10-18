#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python3 make_program.py
iverilog -g2012 -Wall -s cpu_tb -o cpu_test.vvp cpu.v cpu_tb.v
vvp cpu_test.vvp | tee simulation.log
if ! grep -q 'PASS: FULL PIPELINE REGRESSION' simulation.log; then exit 1; fi
