using Micro8085.Core.Assembly;
using Micro8085.Core.Cpu;

namespace Micro8085.Core.Monitor;

public enum LineKind
{
    Normal,
    Info,
    Error,
}

/// <summary>One row of the editor pane; the original screen split every row into two 20-column halves.</summary>
public sealed record ConsoleLine(string Left, string Right = "", LineKind Kind = LineKind.Normal);

public enum RunStatus
{
    Idle,
    Running,
    Tracing,
    Delaying,
    WaitingForInput,
}

public sealed class MonitorResponse
{
    public List<ConsoleLine> Lines { get; } = [];
    public bool Cleared { get; set; }
    public MonitorError Error { get; set; }
    public string? ErrorMessage => Error == MonitorError.None ? null : MonitorErrors.Message(Error);

    /// <summary>Text to pre-fill the command line with (the original advanced to "A2003" etc.).</summary>
    public string Prompt { get; set; } = "";

    /// <summary>Command that continues a paged listing when the user presses space.</summary>
    public string? Continuation { get; set; }

    public string? PrintText { get; set; }
    public bool Beep { get; set; }
    public MachineState? State { get; set; }
}

/// <summary>
/// One user's simulator: CPU, trainer board, editor log and the run/trace state machine.
/// Running is cooperative: the host calls <see cref="Continue"/> repeatedly, so HOLD delays,
/// IN waits and trace steps can be handled by a browser without blocking a server thread.
/// </summary>
public sealed class MonitorSession
{
    public const int MinAddress = 0x0100;
    public const int MaxAddress = 0x7FFF;
    public const int ListingPageSize = 200;
    private const int MaxLogLines = 2000;
    private const string RegisterNames = "A B C D E H L M S Z P CY AC SP PC PSW BC DE HL";

    private readonly List<ConsoleLine> _log = [];

    public MonitorSession()
    {
        Cpu = new Cpu8085(Io);
    }

    public TrainerIo Io { get; } = new();
    public Cpu8085 Cpu { get; }
    public RunStatus Status { get; private set; } = RunStatus.Idle;
    public bool BeepEnabled { get; set; } = true;
    public IReadOnlyList<ConsoleLine> Log => _log;
    public object SyncRoot { get; } = new();

    public MachineState State => MachineState.From(this);

    public MonitorResponse Execute(string commandLine)
    {
        var response = NewResponse();
        if (Status != RunStatus.Idle)
            return Finish(response);

        var line = commandLine.Trim().ToUpperInvariant();
        if (line.Length == 0)
            return Finish(response);

        switch (line[0])
        {
            case 'C' when line is "C" or "CLS":
                _log.Clear();
                response.Cleared = true;
                break;
            case 'R': SetRegister(line, response); break;
            case 'A': Append(line, response); break;
            case 'O': Opcode(line, response); break;
            case 'S': Set(line, response); break;
            case 'L' or 'K' or 'P': List(line, response); break;
            case 'M': Move(line, response); break;
            case 'G' or 'T': StartRun(line, response); break;
            default: Fail(response, MonitorError.UnknownCommand, line); break;
        }
        return Finish(response);
    }

    /// <summary>Executes up to <paramref name="maxSteps"/> instructions (one while tracing).</summary>
    public MonitorResponse Continue(int maxSteps)
    {
        var response = NewResponse();
        if (Status is RunStatus.Idle or RunStatus.WaitingForInput)
            return Finish(response);

        var tracing = Status == RunStatus.Tracing;
        if (Status == RunStatus.Delaying)
            Status = RunStatus.Running;

        var steps = tracing ? 1 : Math.Max(1, maxSteps);
        for (var i = 0; i < steps; i++)
        {
            var result = Cpu.Step();
            switch (result.Kind)
            {
                case StepKind.Ok:
                    continue;
                case StepKind.Halted:
                    Stop(response, $"Halt at {Hex.Word(result.Value)}");
                    return Finish(response);
                case StepKind.InvalidOpcode:
                    Stop(response, $"{MonitorErrors.Message(MonitorError.UnknownOpcode)} at {Hex.Word(Cpu.PC)}", LineKind.Error);
                    response.Error = MonitorError.UnknownOpcode;
                    return Finish(response);
                case StepKind.Delay:
                    Status = tracing ? RunStatus.Tracing : RunStatus.Delaying;
                    DelayMs = tracing ? 0 : result.Value;
                    return Finish(response);
                case StepKind.InputRequired:
                    ResumeAfterInput = tracing ? RunStatus.Tracing : RunStatus.Running;
                    Status = RunStatus.WaitingForInput;
                    return Finish(response);
            }
        }
        return Finish(response);
    }

    /// <summary>Milliseconds the host should wait before the next <see cref="Continue"/> while delaying.</summary>
    public int DelayMs { get; private set; }

    private RunStatus ResumeAfterInput { get; set; } = RunStatus.Running;

    public MonitorResponse ProvideInput(byte value)
    {
        var response = NewResponse();
        if (Status != RunStatus.WaitingForInput || Io.WaitingPort is not { } port)
            return Finish(response);

        Io.ProvideInput(value);
        AddLine(response, port == TrainerIo.KeyboardPort
            ? new ConsoleLine("Enter key in #FF:", value >= 32 ? ((char)value).ToString() : "", LineKind.Info)
            : new ConsoleLine("Enter number #00->", Hex.Byte(value), LineKind.Info));
        Status = ResumeAfterInput;
        return Finish(response);
    }

    public MonitorResponse Break()
    {
        var response = NewResponse();
        if (Status != RunStatus.Idle)
        {
            Io.CancelInput();
            Stop(response, $"Break at {Hex.Word(Cpu.PC)}");
        }
        return Finish(response);
    }

    /// <summary>The "Clear registers" option of the operator menu.</summary>
    public void ClearRegisters() => Cpu.Reset();

    public void LoadMemory(int start, ReadOnlySpan<byte> bytes) => bytes.CopyTo(Cpu.Memory.AsSpan(start));

    public byte[] ReadMemory(int start, int length) => Cpu.Memory.AsSpan(start, length).ToArray();

    public static bool IsUserAddress(int address) => address is >= MinAddress and <= MaxAddress;

    // A2000 MVI A,38
    private void Append(string line, MonitorResponse response)
    {
        if (!TryParseAddress(line, 1, out var address, out var rest, response))
            return;
        if (rest.Length == 0)
        {
            response.Prompt = $"A{Hex.Word(address)} ";
            return;
        }

        var result = Assembler.Assemble(rest);
        if (!result.Success)
        {
            Fail(response, result.Error, line);
            return;
        }

        LoadMemory(address, result.Bytes);
        var instruction = Disassembler.Disassemble(Cpu.Memory, (ushort)address);
        AddLine(response, new($"A{Hex.Word(address)}:{instruction.Mnemonic}", $"O{Hex.Word(address)}:{instruction.Opcodes}"));
        response.Prompt = $"A{Hex.Word(address + instruction.Length)} ";
    }

    // O2000 3E,38
    private void Opcode(string line, MonitorResponse response)
    {
        if (!TryParseAddress(line, 1, out var address, out var rest, response))
            return;
        if (rest.Length == 0)
        {
            response.Prompt = $"O{Hex.Word(address)} ";
            return;
        }
        if (!TryParseBytes(rest, out var bytes))
        {
            Fail(response, MonitorError.OpcodeSyntax, line);
            return;
        }

        var length = OpcodeTable.LengthOf(bytes[0]);
        if (length == 0)
        {
            Fail(response, MonitorError.UnknownOpcode, line);
            return;
        }
        if (length != bytes.Length)
        {
            Fail(response, MonitorError.OpcodeSyntax, line);
            return;
        }

        LoadMemory(address, bytes);
        var instruction = Disassembler.Disassemble(Cpu.Memory, (ushort)address);
        AddLine(response, new($"O{Hex.Word(address)}:{instruction.Opcodes}", $"A{Hex.Word(address)}:{instruction.Mnemonic}"));
        response.Prompt = $"O{Hex.Word(address + length)} ";
    }

    // S2000 48,54,...
    private void Set(string line, MonitorResponse response)
    {
        if (!TryParseAddress(line, 1, out var address, out var rest, response))
            return;
        if (rest.Length == 0)
        {
            response.Prompt = $"S{Hex.Word(address)}:";
            return;
        }
        if (!TryParseBytes(rest, out var bytes) || address + bytes.Length - 1 > MaxAddress)
        {
            Fail(response, MonitorError.OpcodeSyntax, line);
            return;
        }

        LoadMemory(address, bytes);
        AddLine(response, new($"S{Hex.Word(address)}:{Convert.ToHexString(bytes)}"));
        response.Prompt = $"S{Hex.Word(address + bytes.Length)}:";
    }

    // L2000  L2000-  L2000-2010  (K = opcodes first, P = to the printer)
    private void List(string line, MonitorResponse response)
    {
        var kind = line[0];
        if (!TryParseAddress(line, 1, out var start, out var rest, response))
            return;

        int end;
        if (rest.Length == 0)
            end = start;
        else if (rest == "-")
        {
            if (kind == 'P')
            {
                Fail(response, MonitorError.ListType, line);
                return;
            }
            end = MaxAddress;
        }
        else if (rest[0] == '-' && TryParseAddress(rest, 1, out end, out var trailing, response) && trailing.Length == 0)
        {
            if (end < start)
            {
                Fail(response, MonitorError.ListType, line);
                return;
            }
        }
        else
        {
            if (response.Error == MonitorError.None)
                Fail(response, MonitorError.ListType, line);
            return;
        }

        if (kind == 'P')
        {
            var printout = new System.Text.StringBuilder();
            foreach (var instruction in Instructions(start, end))
                printout.AppendLine($"   {Hex.Word(instruction.Address)}:{instruction.Mnemonic,-22}{instruction.Opcodes}");
            response.PrintText = printout.ToString();
            AddLine(response, new($"P{Hex.Word(start)}-{Hex.Word(end)}", "sent to printer", LineKind.Info));
            return;
        }

        var count = 0;
        foreach (var instruction in Instructions(start, end))
        {
            if (count++ == ListingPageSize)
            {
                response.Continuation = $"{kind}{Hex.Word(instruction.Address)}-{Hex.Word(end)}";
                AddLine(response, new("Press space to continue, other to end.", "", LineKind.Info));
                return;
            }
            var mnemonic = $"A{Hex.Word(instruction.Address)}:{instruction.Mnemonic}";
            var opcodes = $"O{Hex.Word(instruction.Address)}:{instruction.Opcodes}";
            AddLine(response, kind == 'L' ? new(mnemonic, opcodes) : new(opcodes, mnemonic));
        }
    }

    private IEnumerable<DisassembledInstruction> Instructions(int start, int end)
    {
        for (var address = start; address <= end;)
        {
            var instruction = Disassembler.Disassemble(Cpu.Memory, (ushort)address);
            yield return instruction;
            address += instruction.Length;
        }
    }

    // M2000-2010 3000
    private void Move(string line, MonitorResponse response)
    {
        if (!TryParseAddress(line, 1, out var start, out var rest, response))
            return;
        if (rest.Length == 0 || rest[0] != '-')
        {
            Fail(response, MonitorError.ListType, line);
            return;
        }
        if (!TryParseAddress(rest, 1, out var end, out var target, response) ||
            !TryParseAddress(target, 0, out var destination, out var trailing, response))
            return;
        if (end < start || trailing.Length != 0)
        {
            Fail(response, MonitorError.ListType, line);
            return;
        }

        var length = end - start + 1;
        if (destination + length - 1 > MaxAddress)
        {
            Fail(response, MonitorError.OutOfRange, line);
            return;
        }

        Buffer.BlockCopy(Cpu.Memory, start, Cpu.Memory, destination, length);
        AddLine(response, new($"M{Hex.Word(start)}-{Hex.Word(end)} {Hex.Word(destination)}", $"{length} bytes moved"));
    }

    // R:A=15
    private void SetRegister(string line, MonitorResponse response)
    {
        var body = line[1..].TrimStart(':', ' ').Replace(" ", "");
        response.Prompt = "R:";
        var equals = body.IndexOf('=');
        if (equals <= 0)
        {
            Fail(response, MonitorError.Syntax, line);
            return;
        }

        var name = body[..equals];
        var text = body[(equals + 1)..];
        if (!RegisterNames.Split(' ').Contains(name) || !Hex.TryParse(text, 4, out var value))
        {
            Fail(response, MonitorError.Syntax, line);
            return;
        }

        var maximum = name switch
        {
            "S" or "Z" or "P" or "CY" or "AC" => 1,
            "SP" or "PC" or "PSW" or "BC" or "DE" or "HL" => 0xFFFF,
            _ => 0xFF,
        };
        if (value > maximum)
        {
            Fail(response, MonitorError.Syntax, line);
            return;
        }

        var cpu = Cpu;
        switch (name)
        {
            case "A": cpu.A = (byte)value; break;
            case "B": cpu.B = (byte)value; break;
            case "C": cpu.C = (byte)value; break;
            case "D": cpu.D = (byte)value; break;
            case "E": cpu.E = (byte)value; break;
            case "H": cpu.H = (byte)value; break;
            case "L": cpu.L = (byte)value; break;
            case "M": cpu.M = (byte)value; break;
            case "S": cpu.Sign = value == 1; break;
            case "Z": cpu.Zero = value == 1; break;
            case "P": cpu.Parity = value == 1; break;
            case "CY": cpu.Carry = value == 1; break;
            case "AC": cpu.AuxCarry = value == 1; break;
            case "SP": cpu.SP = (ushort)value; break;
            case "PC": cpu.PC = (ushort)value; break;
            case "PSW": cpu.PSW = (ushort)value; break;
            case "BC": cpu.BC = (ushort)value; break;
            case "DE": cpu.DE = (ushort)value; break;
            case "HL": cpu.HL = (ushort)value; break;
        }
        AddLine(response, new($"R:{name}={text}"));
    }

    // G2000 runs, T2000 traces; the address defaults to PC.
    private void StartRun(string line, MonitorResponse response)
    {
        int address = Cpu.PC;
        if (line.Length > 1 && !TryParseAddress(line, 1, out address, out _, response))
            return;

        Cpu.PC = (ushort)address;
        Status = line[0] == 'G' ? RunStatus.Running : RunStatus.Tracing;
        AddLine(response, new($"{line[0]}{Hex.Word(address)}", line[0] == 'G' ? "running" : "tracing", LineKind.Info));
    }

    private bool TryParseAddress(string text, int offset, out int address, out string rest, MonitorResponse response)
    {
        var span = text.AsSpan(offset).TrimStart(' ');
        var length = 0;
        while (length < span.Length && length < 4 && Uri.IsHexDigit(span[length]))
            length++;

        rest = span[length..].TrimStart(' ').TrimStart(':').Trim().ToString();
        if (!Hex.TryParse(span[..length], 4, out address) || !IsUserAddress(address))
        {
            Fail(response, MonitorError.OutOfRange, text);
            return false;
        }
        return true;
    }

    private static bool TryParseBytes(string text, out byte[] bytes)
    {
        var digits = string.Concat(text.Where(c => c is not (' ' or ',' or '-' or '*' or '#' or ':')));
        bytes = [];
        if (digits.Length == 0 || digits.Length % 2 != 0 || !digits.All(Uri.IsHexDigit))
            return false;
        bytes = Convert.FromHexString(digits);
        return true;
    }

    private void Fail(MonitorResponse response, MonitorError error, string line)
    {
        response.Error = error;
        response.Prompt = line;
        response.Beep = BeepEnabled;
    }

    private void Stop(MonitorResponse response, string message, LineKind kind = LineKind.Normal)
    {
        Status = RunStatus.Idle;
        DelayMs = 0;
        AddLine(response, new(message, "", kind));
        response.Beep = BeepEnabled;
    }

    /// <summary>Writes an informational row to the editor log (used by the I/O menu).</summary>
    public void Note(string left, string right = "") => AddLine(null, new(left, right, LineKind.Info));

    private void AddLine(MonitorResponse? response, ConsoleLine line)
    {
        response?.Lines.Add(line);
        _log.Add(line);
        if (_log.Count > MaxLogLines)
            _log.RemoveRange(0, _log.Count - MaxLogLines);
    }

    private static MonitorResponse NewResponse() => new();

    private MonitorResponse Finish(MonitorResponse response)
    {
        response.State = State;
        return response;
    }
}
