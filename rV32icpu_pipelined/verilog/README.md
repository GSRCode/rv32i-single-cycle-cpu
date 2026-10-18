# RV32I CPU — Logisim-aligned signal naming

Based on the previously passing 11-component modular CPU. This package is a **signal-name refactor**, not a new architecture. Module names match the Logisim screenshots.

## Named signal correspondence

- `clock`: rising-edge pipeline clock (previously `clk`)
- `reset`: synchronous reset
- `not_stall`: IFetch active-high fetch enable, driven by `~stall`
- `br_taken`: redirect request (BEQ taken, JAL or JALR); previously `redirect`
- `br_target`: redirect address; previously `target`
- `pc`: fetch program counter
- `instruction` in the Logisim IFetch drawing corresponds to the `if_insn` pipeline output in this version, but the boundary differs: Verilog IFetch includes IF/ID registers.

Not all ports can be confirmed from screenshots alone. Remaining internal signal names retain the proven RTL names; they should not be presented as exact Logisim matches. The two implementations are not yet verified cycle-for-cycle equivalent.

## Test

```bash
chmod +x simulate.sh compile.sh
./compile.sh
./simulate.sh
```

Expected existing test: `PASS: FULL PIPELINE REGRESSION` and `errors=0`. No simulator is available in the packaging environment; verify with Icarus Verilog in WSL.

The existing testbench is retained and updated to use `clock`, `br_taken` and `br_target`. The testbench still loads `dut.IFetch1.imem` and examines `dut.IDecode1.regs` and `dut.Memory1.dmem`.
