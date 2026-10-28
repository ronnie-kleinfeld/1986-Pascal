using Micro8085.Core.Cpu;
using Micro8085.Core.Monitor;

namespace Micro8085.Core.Assembly;

public readonly record struct AssemblyResult(byte[] Bytes, MonitorError Error)
{
    public bool Success => Error == MonitorError.None;
}

/// <summary>One-line assembler used by the A command (replaces the binary search in APPEND).</summary>
public static class Assembler
{
    private static readonly ILookup<string, OpcodeInfo> ByMnemonic =
        OpcodeTable.All.ToLookup(o => o.Mnemonic, StringComparer.OrdinalIgnoreCase);

    public static AssemblyResult Assemble(string text)
    {
        var trimmed = text.Trim().ToUpperInvariant();
        var space = trimmed.IndexOf(' ');
        var mnemonic = space < 0 ? trimmed : trimmed[..space];
        var operand = space < 0 ? "" : string.Concat(trimmed[space..].Where(c => !char.IsWhiteSpace(c)));

        if (!ByMnemonic.Contains(mnemonic))
            return new([], MonitorError.InvalidMnemonic);

        foreach (var info in ByMnemonic[mnemonic])
        {
            if (TryMatch(info, operand, out var bytes))
                return new(bytes, MonitorError.None);
        }
        return new([], MonitorError.InvalidOperand);
    }

    private static bool TryMatch(OpcodeInfo info, string operand, out byte[] bytes)
    {
        bytes = [];
        var template = info.Operand;
        var dollar = template.IndexOf('$');
        if (dollar < 0)
        {
            if (operand != template)
                return false;
            bytes = [info.Code];
            return true;
        }

        var prefix = template[..dollar];
        if (prefix == "#")
            prefix = operand.StartsWith('#') ? "#" : "";
        if (!operand.StartsWith(prefix, StringComparison.Ordinal))
            return false;

        var digits = template.Length - dollar;
        var value = operand.AsSpan(prefix.Length);
        if (value.EndsWith("H"))
            value = value[..^1];
        if (!Hex.TryParse(value, digits, out var number))
            return false;

        bytes = digits == 2
            ? [info.Code, (byte)number]
            : [info.Code, (byte)number, (byte)(number >> 8)];
        return true;
    }
}
