#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
iverilog -g2012 -Wall -s cpu -o cpu_compile.vvp cpu.v IFetch.v IDecode.v BubbleControl.v ID_EX.v HazardDetectionUnit.v ForwardingUnit.v Execute.v EX_MEM.v StoreForwardingUnit.v Memory.v MEM_WB.v
echo "PASS: CPU RTL compiles"
