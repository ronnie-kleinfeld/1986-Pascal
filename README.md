# 1986-Pascal

MICRO is an Intel 8085 trainer simulator written by Raanan Kleinfeld in Turbo Pascal for MS-DOS (Ver 2.00, 1988).
It combines a line editor and assembler, a register panel, and a simulated trainer board with LEDs, switches,
a six-digit seven-segment display and a keyboard line.

This repository keeps the original sources and has a port to **ASP.NET Core 10 MVC**.

```text
MICRO/                      the original, unchanged (MICRO-A/B/C.PAS, MICRO.COM, MICRO.CMD, *.DAT)
src/Micro8085.Core/         simulator: CPU, trainer board, assembler, monitor commands, program catalog
src/Micro8085.Web/          ASP.NET Core 10 MVC front end
tests/Micro8085.Core.Tests/ xUnit tests, including runs of the 1988 sample programs
```

## Run

```sh
dotnet run --project src/Micro8085.Web    # http://localhost:5198
dotnet test
```

On first start, the sample programs and `MCRNAME.DAT` are copied into `src/Micro8085.Web/App_Data/Programs`.
To use a different folder, set `Programs:Directory`.

## Using it

Type commands at the `>` prompt, as in the original editor:

| Command | Meaning |
| --- | --- |
| `A2000 MVI A,38` | assemble a line (the next address is offered afterwards) |
| `O2000 3E,38` | enter one instruction as op codes |
| `S2000 48,54,...` | set memory bytes |
| `L2000-2010`, `L2000-`, `L2000` | list in mnemonics (`K` = op codes first, `P` = print) |
| `M2000-2010 3000` | move a block |
| `R:A=15` | set a register, pair or flag (`A`-`L`, `M`, `SP`, `PC`, `PSW`, `BC`, `DE`, `HL`, `S`, `Z`, `P`, `CY`, `AC`) |
| `G2000` / `T2000` | run / trace (space pauses, `B` breaks) |
| `CLS` | clear the screen |

F1 shows the commands, F3 the error codes, F5 the operator menu, and F9 load/save/dir/erase.
The original printed 8085 reference card is linked from the footer.

Board ports: `OUT 00` LEDs, `IN 00` switches, `OUT 04` digit segments (active low, bits `d c b a dp g f e`),
`OUT 05` display control (`1000 I PPP`), `OUT FF` / `IN FF` keyboard line. `HOLD addr` (opcode 08) is the
simulator's own delay instruction.

## How the port maps to the Pascal

| Pascal | C# |
| --- | --- |
| `MEM_`, `OPR_`, `LEN` tables | `Cpu/OpcodeTable.cs` (generated from them) |
| `CAOF`, `RUN` | `Cpu/Cpu8085.cs`, `MonitorSession.Continue` |
| `OUT`/`IN` cases for ports 00, 04, 05, FF | `Cpu/TrainerIo.cs` |
| `APPEND`, `OPCODE`, `LIST`, `SIT`, `MOV`, `BEGS`, `ENTER` | `Monitor/MonitorSession.cs`, `Assembly/*` |
| `ERR_`, `ERT` | `Monitor/MonitorError.cs` |
| `SAVE`, `LOAD`, `DIR`, `ERASE` (`MCRNAME.DAT`) | `Storage/ProgramCatalog.cs`, same binary format |
| `MAIN_SCREEN`, `REGISTERS`, `EDITOR` | `Views/Home/Index.cshtml`, `wwwroot/js/micro.js` |
| `COMMAND`, `ERL`, `OPERATE`, `INUT` menus | `HelpController`, `OperateController`, `ProgramsController` |

Running is cooperative. The browser asks the server for a batch of instructions at the chosen speed,
which lets `HOLD` delays, `IN` waits and trace steps work without holding a server thread.

## Differences from the 1988 program

The CPU now behaves like a real 8085. The original had bugs that the port fixes:

- Sign is taken from bit 7, auxiliary carry is implemented, and `DAA` works (it was a no-op).
- `PUSH`/`POP`/`CALL`/`RET` share one stack layout (they disagreed before).
- `RST n` calls `n*8` (it was a no-op).
- Fixed instructions: `LHLD` read the wrong address, `SUB A` used the wrong operand, `ADC M` dropped A, and `DAD` carry was wrong.
- **Rotates:** the original swapped `RLC`/`RAL` and `RRC`/`RAR`, and its printed card has the same swap.
  The sample `STEPS` depends on this. Loading an unmodified 1988 sample switches *1988 rotates* on automatically,
  and loading any other program switches it off. You can override it in the F5 menu.
- An undefined opcode stops the run with error 8. Before, it was skipped.
- The `RST 3` length was 3 bytes in the table; it is now 1.
- Addresses outside h0100-h7FFF report error 5 (before: error 1).
- `PSW` is A:flags, Intel order. The original showed flags:A.
- `G` and `T` without an address start from PC.
- Listings pause every 200 lines instead of every screen.
- Load leaves the catalog unchanged (the original overwrote the saved start address) and sets PC to the load address.
- Erase also deletes the program's `.DAT` file.
- The reference card's `MVI L` opcode is corrected from 3E to 2E.
