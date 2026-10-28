using Micro8085.Core.Assembly;
using Micro8085.Core.Cpu;

namespace Micro8085.Core.Monitor;

/// <summary>Everything the register panel and trainer board show (the original REGISTERS procedure).</summary>
public sealed record MachineState(
    byte A, byte B, byte C, byte D, byte E, byte H, byte L,
    ushort SP, ushort PC, ushort PSW,
    bool Sign, bool Zero, bool AuxCarry, bool Parity, bool Carry,
    byte MemoryAtBC, byte MemoryAtDE, byte MemoryAtHL, byte MemoryAtPC,
    string NextInstruction,
    byte Leds, int[] Digits, int DigitPosition, string Keyboard,
    RunStatus Status, int DelayMs, byte? WaitingPort, bool BeepEnabled)
{
    public static MachineState From(MonitorSession session)
    {
        var cpu = session.Cpu;
        var io = session.Io;
        var memory = cpu.Memory;
        var next = Disassembler.Disassemble(memory, cpu.PC);
        return new(
            cpu.A, cpu.B, cpu.C, cpu.D, cpu.E, cpu.H, cpu.L,
            cpu.SP, cpu.PC, cpu.PSW,
            cpu.Sign, cpu.Zero, cpu.AuxCarry, cpu.Parity, cpu.Carry,
            memory[cpu.BC], memory[cpu.DE], memory[cpu.HL], memory[cpu.PC],
            $"{Hex.Word(cpu.PC)}:{next.Mnemonic}",
            io.Leds, Array.ConvertAll(io.Digits, d => (int)d), io.DigitPosition, new string(io.KeyboardLine),
            session.Status, session.DelayMs, io.WaitingPort, session.BeepEnabled);
    }
}
