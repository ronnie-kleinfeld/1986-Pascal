namespace Micro8085.Core.Monitor;

/// <summary>The eight error codes of the original (ERR_ and ERT tables, shown with F3).</summary>
public enum MonitorError
{
    None = 0,
    ListType = 1,
    InvalidMnemonic = 2,
    InvalidOperand = 3,
    Syntax = 4,
    OutOfRange = 5,
    UnknownCommand = 6,
    OpcodeSyntax = 7,
    UnknownOpcode = 8,
}

public sealed record MonitorErrorInfo(MonitorError Code, string Title, string Description);

public static class MonitorErrors
{
    public static readonly IReadOnlyList<MonitorErrorInfo> All =
    [
        new(MonitorError.ListType, "List type mistake",
            "A request for a program list that does not have a char that separates the two line numbers, or whose end is before its start."),
        new(MonitorError.InvalidMnemonic, "Invalid mnemonics operation",
            "The mnemonic operation does not match the computer library, or the mnemonic does not operate like a command."),
        new(MonitorError.InvalidOperand, "Invalid mnemonics operand",
            "The mnemonic operand is not correct."),
        new(MonitorError.Syntax, "Syntax error",
            "The command could not be understood, or a value is out of range for its register."),
        new(MonitorError.OutOfRange, "Line out of range",
            "Line number is out of the computer range (h0100-h7FFF)."),
        new(MonitorError.UnknownCommand, "Unknown command",
            "The first letter in the line does not match the list of commands the computer has."),
        new(MonitorError.OpcodeSyntax, "Op code syntax error",
            "The op code is out of range. This error might also be because the op code does not have the right length."),
        new(MonitorError.UnknownOpcode, "Unknown op code",
            "The op code in the memory list does not operate like an op code."),
    ];

    public static MonitorErrorInfo Get(MonitorError code) => All[(int)code - 1];

    public static string Message(MonitorError code) => $"{(int)code} {Get(code).Title}";
}
