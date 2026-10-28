using Micro8085.Core.Cpu;

namespace Micro8085.Core.Assembly;

/// <param name="Mnemonic">e.g. "MVI  A,38", or "----" for an unassigned opcode.</param>
/// <param name="Opcodes">Bytes as stored in memory, e.g. "3E,38" or "C3,00,20".</param>
public readonly record struct DisassembledInstruction(ushort Address, string Mnemonic, string Opcodes, int Length);

public static class Disassembler
{
    public static DisassembledInstruction Disassemble(byte[] memory, ushort address)
    {
        var op = memory[address];
        var info = OpcodeTable.Get(op);
        if (info is null)
            return new(address, "----", "--", 1);

        var lo = memory[(ushort)(address + 1)];
        var hi = memory[(ushort)(address + 2)];
        var bytes = info.Length switch
        {
            1 => Hex.Byte(op),
            2 => $"{Hex.Byte(op)},{Hex.Byte(lo)}",
            _ => $"{Hex.Byte(op)},{Hex.Byte(lo)},{Hex.Byte(hi)}",
        };
        return new(address, Format(info, lo, hi), bytes, info.Length);
    }

    public static string Format(OpcodeInfo info, byte lo, byte hi)
    {
        var operand = info.Operand
            .Replace("$$$$", Hex.Byte(hi) + Hex.Byte(lo))
            .Replace("$$", Hex.Byte(lo));
        return $"{info.Mnemonic,-4} {operand}".TrimEnd();
    }
}

public static class Hex
{
    public static string Byte(byte value) => value.ToString("X2");

    public static string Word(int value) => ((ushort)value).ToString("X4");

    public static bool TryParse(ReadOnlySpan<char> text, int maxDigits, out int value)
    {
        value = 0;
        if (text.Length == 0 || text.Length > maxDigits)
            return false;
        foreach (var c in text)
        {
            var digit = c switch
            {
                >= '0' and <= '9' => c - '0',
                >= 'A' and <= 'F' => c - 'A' + 10,
                >= 'a' and <= 'f' => c - 'a' + 10,
                _ => -1,
            };
            if (digit < 0)
                return false;
            value = value << 4 | digit;
        }
        return true;
    }
}
