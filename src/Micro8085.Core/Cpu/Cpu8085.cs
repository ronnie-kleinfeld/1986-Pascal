namespace Micro8085.Core.Cpu;

public enum StepKind
{
    Ok,
    Halted,
    /// <summary>A HOLD instruction asked for a pause of <see cref="StepResult.Value"/> milliseconds.</summary>
    Delay,
    /// <summary>An IN instruction is waiting for the user; <see cref="StepResult.Value"/> is the port.</summary>
    InputRequired,
    InvalidOpcode,
}

public readonly record struct StepResult(StepKind Kind, int Value = 0)
{
    public static readonly StepResult Ok = new(StepKind.Ok);
}

/// <summary>
/// Intel 8085 interpreter. Replaces the CAOF procedure of MICRO-C.PAS with a flag-accurate
/// implementation (sign, zero, auxiliary carry, parity, carry) and a real stack.
/// </summary>
public sealed class Cpu8085
{
    public const ushort InitialStackPointer = 0x38FE;
    public const ushort InitialProgramCounter = 0x2000;

    private readonly IIoBus _io;

    public Cpu8085(IIoBus io)
    {
        _io = io;
        Reset();
    }

    public byte[] Memory { get; } = new byte[0x10000];

    public byte A { get; set; }
    public byte B { get; set; }
    public byte C { get; set; }
    public byte D { get; set; }
    public byte E { get; set; }
    public byte H { get; set; }
    public byte L { get; set; }
    public ushort SP { get; set; }
    public ushort PC { get; set; }

    public bool Sign { get; set; }
    public bool Zero { get; set; }
    public bool AuxCarry { get; set; }
    public bool Parity { get; set; }
    public bool Carry { get; set; }
    public bool InterruptsEnabled { get; private set; }

    /// <summary>
    /// Reproduces the 1988 simulator's rotates, which had RLC/RAL and RRC/RAR swapped (as does the
    /// printed card). Sample programs such as STEPS were written against that behaviour.
    /// </summary>
    public bool OriginalRotates { get; set; }

    public ushort BC { get => (ushort)(B << 8 | C); set { B = (byte)(value >> 8); C = (byte)value; } }
    public ushort DE { get => (ushort)(D << 8 | E); set { D = (byte)(value >> 8); E = (byte)value; } }
    public ushort HL { get => (ushort)(H << 8 | L); set { H = (byte)(value >> 8); L = (byte)value; } }

    /// <summary>Flag byte in 8085 order: S Z 0 AC 0 P 1 CY.</summary>
    public byte Flags
    {
        get => (byte)((Sign ? 0x80 : 0) | (Zero ? 0x40 : 0) | (AuxCarry ? 0x10 : 0) | (Parity ? 0x04 : 0) | 0x02 | (Carry ? 0x01 : 0));
        set
        {
            Sign = (value & 0x80) != 0;
            Zero = (value & 0x40) != 0;
            AuxCarry = (value & 0x10) != 0;
            Parity = (value & 0x04) != 0;
            Carry = (value & 0x01) != 0;
        }
    }

    public ushort PSW { get => (ushort)(A << 8 | Flags); set { A = (byte)(value >> 8); Flags = (byte)value; } }

    public byte M { get => Memory[HL]; set => Memory[HL] = value; }

    /// <summary>Clears registers and flags (the original IPUS procedure).</summary>
    public void Reset()
    {
        A = B = C = D = E = H = L = 0;
        Flags = 0;
        SP = InitialStackPointer;
        PC = InitialProgramCounter;
        InterruptsEnabled = false;
    }

    public void ClearMemory() => Array.Clear(Memory);

    public StepResult Step()
    {
        var address = PC;
        var op = Memory[address];
        var info = OpcodeTable.Get(op);
        if (info is null)
            return new StepResult(StepKind.InvalidOpcode, op);

        var lo = Memory[(ushort)(address + 1)];
        var hi = Memory[(ushort)(address + 2)];
        var word = (ushort)(hi << 8 | lo);
        PC = (ushort)(address + info.Length);

        switch (op)
        {
            // MOV r,r' / HLT
            case 0x76:
                return new StepResult(StepKind.Halted, address);
            case >= 0x40 and <= 0x7F:
                SetReg(op >> 3 & 7, GetReg(op & 7));
                return StepResult.Ok;

            // ALU A,r
            case >= 0x80 and <= 0xBF:
                Alu(op >> 3 & 7, GetReg(op & 7));
                return StepResult.Ok;

            // ALU A,immediate
            case 0xC6 or 0xCE or 0xD6 or 0xDE or 0xE6 or 0xEE or 0xF6 or 0xFE:
                Alu(op >> 3 & 7, lo);
                return StepResult.Ok;

            // MVI r,data
            case 0x06 or 0x0E or 0x16 or 0x1E or 0x26 or 0x2E or 0x36 or 0x3E:
                SetReg(op >> 3 & 7, lo);
                return StepResult.Ok;

            // INR r / DCR r
            case 0x04 or 0x0C or 0x14 or 0x1C or 0x24 or 0x2C or 0x34 or 0x3C:
            {
                var r = op >> 3 & 7;
                var v = GetReg(r);
                var result = (byte)(v + 1);
                AuxCarry = (v & 0x0F) == 0x0F;
                SetZsp(result);
                SetReg(r, result);
                return StepResult.Ok;
            }
            case 0x05 or 0x0D or 0x15 or 0x1D or 0x25 or 0x2D or 0x35 or 0x3D:
            {
                var r = op >> 3 & 7;
                var v = GetReg(r);
                var result = (byte)(v - 1);
                AuxCarry = (v & 0x0F) != 0;
                SetZsp(result);
                SetReg(r, result);
                return StepResult.Ok;
            }

            // Register pairs
            case 0x01 or 0x11 or 0x21 or 0x31: SetPair(op >> 4 & 3, word); return StepResult.Ok;
            case 0x03 or 0x13 or 0x23 or 0x33: SetPair(op >> 4 & 3, (ushort)(GetPair(op >> 4 & 3) + 1)); return StepResult.Ok;
            case 0x0B or 0x1B or 0x2B or 0x3B: SetPair(op >> 4 & 3, (ushort)(GetPair(op >> 4 & 3) - 1)); return StepResult.Ok;
            case 0x09 or 0x19 or 0x29 or 0x39:
            {
                var sum = HL + GetPair(op >> 4 & 3);
                Carry = sum > 0xFFFF;
                HL = (ushort)sum;
                return StepResult.Ok;
            }

            // Loads and stores
            case 0x02: Memory[BC] = A; return StepResult.Ok;
            case 0x12: Memory[DE] = A; return StepResult.Ok;
            case 0x0A: A = Memory[BC]; return StepResult.Ok;
            case 0x1A: A = Memory[DE]; return StepResult.Ok;
            case 0x22: Memory[word] = L; Memory[(ushort)(word + 1)] = H; return StepResult.Ok;
            case 0x2A: L = Memory[word]; H = Memory[(ushort)(word + 1)]; return StepResult.Ok;
            case 0x32: Memory[word] = A; return StepResult.Ok;
            case 0x3A: A = Memory[word]; return StepResult.Ok;
            case 0xEB: (H, D) = (D, H); (L, E) = (E, L); return StepResult.Ok;
            case 0xE3:
            {
                var oldL = L;
                var oldH = H;
                L = Memory[SP];
                H = Memory[(ushort)(SP + 1)];
                Memory[SP] = oldL;
                Memory[(ushort)(SP + 1)] = oldH;
                return StepResult.Ok;
            }
            case 0xF9: SP = HL; return StepResult.Ok;
            case 0xE9: PC = HL; return StepResult.Ok;

            // Rotates and specials
            case 0x07 or 0x0F or 0x17 or 0x1F when OriginalRotates:
                RotateAs1988(op);
                return StepResult.Ok;
            case 0x07: Carry = (A & 0x80) != 0; A = (byte)(A << 1 | (Carry ? 1 : 0)); return StepResult.Ok;
            case 0x0F: Carry = (A & 0x01) != 0; A = (byte)(A >> 1 | (Carry ? 0x80 : 0)); return StepResult.Ok;
            case 0x17: { var c = Carry; Carry = (A & 0x80) != 0; A = (byte)(A << 1 | (c ? 1 : 0)); return StepResult.Ok; }
            case 0x1F: { var c = Carry; Carry = (A & 0x01) != 0; A = (byte)(A >> 1 | (c ? 0x80 : 0)); return StepResult.Ok; }
            case 0x27: Daa(); return StepResult.Ok;
            case 0x2F: A = (byte)~A; return StepResult.Ok;
            case 0x37: Carry = true; return StepResult.Ok;
            case 0x3F: Carry = !Carry; return StepResult.Ok;
            case 0x00 or 0x30: return StepResult.Ok;
            case 0x20: A = (byte)(InterruptsEnabled ? 0x08 : 0x00); return StepResult.Ok;
            case 0xF3: InterruptsEnabled = false; return StepResult.Ok;
            case 0xFB: InterruptsEnabled = true; return StepResult.Ok;

            // HOLD: the simulator's delay instruction, timing formula kept from the original.
            case 0x08:
                return new StepResult(StepKind.Delay, Math.Abs((lo << 8 | hi) - 32767) / 2);

            // Stack
            case 0xC5 or 0xD5 or 0xE5: Push(GetPair(op >> 4 & 3)); return StepResult.Ok;
            case 0xF5: Push(PSW); return StepResult.Ok;
            case 0xC1 or 0xD1 or 0xE1: SetPair(op >> 4 & 3, Pop()); return StepResult.Ok;
            case 0xF1: PSW = Pop(); return StepResult.Ok;

            // Jumps, calls, returns, restarts
            case 0xC3: PC = word; return StepResult.Ok;
            case 0xCD: Push(PC); PC = word; return StepResult.Ok;
            case 0xC9: PC = Pop(); return StepResult.Ok;
            case 0xC2 or 0xCA or 0xD2 or 0xDA or 0xE2 or 0xEA or 0xF2 or 0xFA:
                if (Condition(op >> 3 & 7)) PC = word;
                return StepResult.Ok;
            case 0xC4 or 0xCC or 0xD4 or 0xDC or 0xE4 or 0xEC or 0xF4 or 0xFC:
                if (Condition(op >> 3 & 7)) { Push(PC); PC = word; }
                return StepResult.Ok;
            case 0xC0 or 0xC8 or 0xD0 or 0xD8 or 0xE0 or 0xE8 or 0xF0 or 0xF8:
                if (Condition(op >> 3 & 7)) PC = Pop();
                return StepResult.Ok;
            case 0xC7 or 0xCF or 0xD7 or 0xDF or 0xE7 or 0xEF or 0xF7 or 0xFF:
                Push(PC);
                PC = (ushort)(op & 0x38);
                return StepResult.Ok;

            // I/O
            case 0xD3:
                _io.Write(lo, A);
                return StepResult.Ok;
            case 0xDB:
            {
                var a = A;
                if (!_io.TryRead(lo, ref a))
                {
                    PC = address; // re-executed once the user has supplied the value
                    return new StepResult(StepKind.InputRequired, lo);
                }
                A = a;
                return StepResult.Ok;
            }
        }

        throw new InvalidOperationException($"Opcode {op:X2} is in the table but not implemented.");
    }

    private byte GetReg(int r) => r switch
    {
        0 => B, 1 => C, 2 => D, 3 => E, 4 => H, 5 => L, 6 => M, _ => A,
    };

    private void SetReg(int r, byte value)
    {
        switch (r)
        {
            case 0: B = value; break;
            case 1: C = value; break;
            case 2: D = value; break;
            case 3: E = value; break;
            case 4: H = value; break;
            case 5: L = value; break;
            case 6: M = value; break;
            default: A = value; break;
        }
    }

    private ushort GetPair(int rp) => rp switch { 0 => BC, 1 => DE, 2 => HL, _ => SP };

    private void SetPair(int rp, ushort value)
    {
        switch (rp)
        {
            case 0: BC = value; break;
            case 1: DE = value; break;
            case 2: HL = value; break;
            default: SP = value; break;
        }
    }

    private bool Condition(int cc) => cc switch
    {
        0 => !Zero, 1 => Zero, 2 => !Carry, 3 => Carry, 4 => !Parity, 5 => Parity, 6 => !Sign, _ => Sign,
    };

    private void Push(ushort value)
    {
        SP--;
        Memory[SP] = (byte)(value >> 8);
        SP--;
        Memory[SP] = (byte)value;
    }

    private ushort Pop()
    {
        var lo = Memory[SP];
        SP++;
        var hi = Memory[SP];
        SP++;
        return (ushort)(hi << 8 | lo);
    }

    private void Alu(int operation, byte value)
    {
        switch (operation)
        {
            case 0: Add(value, 0); break;                          // ADD / ADI
            case 1: Add(value, Carry ? 1 : 0); break;              // ADC / ACI
            case 2: A = Subtract(value, 0); break;                 // SUB / SUI
            case 3: A = Subtract(value, Carry ? 1 : 0); break;     // SBB / SBI
            case 4: AuxCarry = ((A | value) & 0x08) != 0; A &= value; Carry = false; SetZsp(A); break; // ANA / ANI
            case 5: A ^= value; Carry = AuxCarry = false; SetZsp(A); break; // XRA / XRI
            case 6: A |= value; Carry = AuxCarry = false; SetZsp(A); break; // ORA / ORI
            default: Subtract(value, 0); break;                    // CMP / CPI
        }
    }

    private void Add(byte value, int carryIn)
    {
        var sum = A + value + carryIn;
        AuxCarry = (A & 0x0F) + (value & 0x0F) + carryIn > 0x0F;
        Carry = sum > 0xFF;
        A = (byte)sum;
        SetZsp(A);
    }

    private byte Subtract(byte value, int borrowIn)
    {
        var difference = A - value - borrowIn;
        AuxCarry = (A & 0x0F) - (value & 0x0F) - borrowIn >= 0;
        Carry = difference < 0;
        var result = (byte)difference;
        SetZsp(result);
        return result;
    }

    // Transcribed from CAOF in MICRO-C.PAS, including its carry handling.
    private void RotateAs1988(byte op)
    {
        var bit0 = (A & 0x01) != 0;
        var bit7 = (A & 0x80) != 0;
        switch (op)
        {
            case 0x07: A = (byte)(A << 1 | (Carry ? 1 : 0)); Carry = bit7; break;    // rotates through carry
            case 0x17: A = (byte)(A << 1 | (bit7 ? 1 : 0)); Carry = bit0; break;     // circular
            case 0x0F: A = (byte)(A >> 1 | (Carry ? 0x80 : 0)); Carry = bit0; break; // rotates through carry
            default: A = (byte)(A >> 1 | (bit0 ? 0x80 : 0)); Carry = bit7; break;    // 1F, circular
        }
    }

    private void Daa()
    {
        var correction = 0;
        var carry = Carry;
        if ((A & 0x0F) > 9 || AuxCarry) correction |= 0x06;
        if (A > 0x99 || Carry)
        {
            correction |= 0x60;
            carry = true;
        }
        AuxCarry = (A & 0x0F) + (correction & 0x0F) > 0x0F;
        A = (byte)(A + correction);
        Carry = carry;
        SetZsp(A);
    }

    private void SetZsp(byte value)
    {
        Sign = (value & 0x80) != 0;
        Zero = value == 0;
        Parity = System.Numerics.BitOperations.PopCount(value) % 2 == 0;
    }
}
