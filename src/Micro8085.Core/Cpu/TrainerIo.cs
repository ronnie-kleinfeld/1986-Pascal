namespace Micro8085.Core.Cpu;

public interface IIoBus
{
    void Write(byte port, byte value);

    /// <summary>
    /// Reads a port into <paramref name="value"/>. Returns false when the read must wait for the user;
    /// ports with nothing attached leave <paramref name="value"/> unchanged, as the original did.
    /// </summary>
    bool TryRead(byte port, ref byte value);
}

/// <summary>
/// The trainer board drawn on the right of the original screen:
/// port 00 binary LEDs (out) and switches (in), ports 04/05 six-digit seven-segment display,
/// port FF a 20-character keyboard/terminal line.
/// </summary>
public sealed class TrainerIo : IIoBus
{
    public const byte LedPort = 0x00;
    public const byte SegmentPort = 0x04;
    public const byte DisplayControlPort = 0x05;
    public const byte KeyboardPort = 0xFF;
    public const int DigitCount = 6;
    public const int KeyboardWidth = 20;

    private byte? _pendingInput;

    public TrainerIo() => CleanPorts();

    /// <summary>Last value written to port 00; bit 7 is the leftmost LED.</summary>
    public byte Leds { get; private set; }

    /// <summary>Segment patterns per digit, active low: bit7 d, 6 c, 5 b, 4 a, 3 dp, 2 g, 1 f, 0 e.</summary>
    public byte[] Digits { get; } = new byte[DigitCount];

    /// <summary>Digit that the next OUT 04 writes to (0-5).</summary>
    public int DigitPosition { get; private set; }

    public bool AutoIncrement { get; private set; }

    public char[] KeyboardLine { get; } = new char[KeyboardWidth];

    public int KeyboardCursor { get; private set; }

    /// <summary>Port that an IN instruction is currently waiting on.</summary>
    public byte? WaitingPort { get; private set; }

    /// <summary>The "Clean ports" option of the operator menu.</summary>
    public void CleanPorts()
    {
        Leds = 0;
        Array.Fill(Digits, (byte)0xFF);
        DigitPosition = 0;
        AutoIncrement = true;
        Array.Fill(KeyboardLine, ' ');
        KeyboardCursor = 0;
        _pendingInput = null;
        WaitingPort = null;
    }

    /// <summary>Supplies the value the waiting IN instruction will read.</summary>
    public void ProvideInput(byte value)
    {
        _pendingInput = value;
        if (WaitingPort == KeyboardPort && value >= 32)
            Type((char)value);
    }

    public void CancelInput()
    {
        _pendingInput = null;
        WaitingPort = null;
    }

    public void Write(byte port, byte value)
    {
        switch (port)
        {
            case LedPort:
                Leds = value;
                break;
            case SegmentPort:
                Digits[DigitPosition] = value;
                if (AutoIncrement)
                    DigitPosition = (DigitPosition + 1) % DigitCount;
                break;
            case DisplayControlPort:
                // Control word 1000 I PPP: I = auto-increment, PPP = digit position.
                if (value >> 4 != 0x8)
                    break;
                AutoIncrement = (value & 0x08) != 0;
                DigitPosition = Math.Min(value & 0x07, DigitCount - 1);
                break;
            case KeyboardPort:
                if (value >= 32)
                    Type((char)value);
                break;
        }
    }

    public bool TryRead(byte port, ref byte value)
    {
        if (port is not (LedPort or KeyboardPort))
            return true;

        if (_pendingInput is null)
        {
            WaitingPort = port;
            return false;
        }

        // Control keys are ignored by IN FF, leaving A unchanged.
        if (port == LedPort || _pendingInput >= 32)
            value = _pendingInput.Value;
        _pendingInput = null;
        WaitingPort = null;
        return true;
    }

    private void Type(char c)
    {
        KeyboardLine[KeyboardCursor] = c;
        KeyboardCursor = (KeyboardCursor + 1) % KeyboardWidth;
    }
}
