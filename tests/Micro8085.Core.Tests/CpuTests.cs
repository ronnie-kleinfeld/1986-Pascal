using Micro8085.Core.Cpu;

namespace Micro8085.Core.Tests;

public class CpuTests
{
    private readonly TrainerIo _io = new();
    private readonly Cpu8085 _cpu;

    public CpuTests() => _cpu = new Cpu8085(_io);

    private void Load(params byte[] program) => program.CopyTo(_cpu.Memory, Cpu8085.InitialProgramCounter);

    private void Run(int steps)
    {
        for (var i = 0; i < steps; i++)
            Assert.Equal(StepKind.Ok, _cpu.Step().Kind);
    }

    [Fact]
    public void Reset_matches_the_original_power_on_state()
    {
        Assert.Equal(0x38FE, _cpu.SP);
        Assert.Equal(0x2000, _cpu.PC);
    }

    [Fact]
    public void Add_sets_carry_zero_parity_and_aux_carry()
    {
        Load(0x3E, 0xFF, 0xC6, 0x01); // MVI A,FF ; ADI 01
        Run(2);
        Assert.Equal(0, _cpu.A);
        Assert.True(_cpu.Carry);
        Assert.True(_cpu.Zero);
        Assert.True(_cpu.Parity);
        Assert.True(_cpu.AuxCarry);
        Assert.False(_cpu.Sign);
    }

    [Fact]
    public void Sub_borrow_sets_carry_and_sign()
    {
        Load(0x3E, 0x01, 0xD6, 0x02); // MVI A,01 ; SUI 02
        Run(2);
        Assert.Equal(0xFF, _cpu.A);
        Assert.True(_cpu.Carry);
        Assert.True(_cpu.Sign);
    }

    [Fact]
    public void Compare_leaves_accumulator_unchanged()
    {
        Load(0x3E, 0x05, 0xFE, 0x05); // MVI A,05 ; CPI 05
        Run(2);
        Assert.Equal(5, _cpu.A);
        Assert.True(_cpu.Zero);
        Assert.False(_cpu.Carry);
    }

    [Fact]
    public void Increment_does_not_touch_carry()
    {
        Load(0x37, 0x06, 0xFF, 0x04); // STC ; MVI B,FF ; INR B
        Run(3);
        Assert.Equal(0, _cpu.B);
        Assert.True(_cpu.Zero);
        Assert.True(_cpu.Carry);
    }

    [Fact]
    public void Daa_adjusts_bcd_addition()
    {
        Load(0x3E, 0x38, 0xC6, 0x45, 0x27); // 38 + 45 = 83 (BCD)
        Run(3);
        Assert.Equal(0x83, _cpu.A);
        Assert.False(_cpu.Carry);
    }

    [Fact]
    public void Dad_sets_carry_on_overflow()
    {
        Load(0x21, 0x00, 0x80, 0x29); // LXI H,8000 ; DAD H
        Run(2);
        Assert.Equal(0, _cpu.HL);
        Assert.True(_cpu.Carry);
    }

    [Fact]
    public void Push_and_pop_round_trip_through_the_stack()
    {
        Load(0x01, 0x34, 0x12, 0xC5, 0xD1); // LXI B,1234 ; PUSH B ; POP D
        Run(3);
        Assert.Equal(0x1234, _cpu.DE);
        Assert.Equal(Cpu8085.InitialStackPointer, _cpu.SP);
        Assert.Equal(0x12, _cpu.Memory[0x38FD]);
        Assert.Equal(0x34, _cpu.Memory[0x38FC]);
    }

    [Fact]
    public void Push_psw_stores_accumulator_and_flags()
    {
        Load(0x3E, 0x80, 0xB7, 0xF5, 0xC1); // MVI A,80 ; ORA A ; PUSH PSW ; POP B
        Run(4);
        Assert.Equal(0x80, _cpu.B);
        Assert.Equal(0x82, _cpu.C); // S set, bit 1 always set
    }

    [Fact]
    public void Call_and_return()
    {
        Load(0xCD, 0x10, 0x20, 0x76);                 // CALL 2010 ; HLT
        new byte[] { 0x3E, 0x42, 0xC9 }.CopyTo(_cpu.Memory, 0x2010); // MVI A,42 ; RET
        Run(3);
        Assert.Equal(0x2003, _cpu.PC);
        Assert.Equal(0x42, _cpu.A);
        Assert.Equal(StepKind.Halted, _cpu.Step().Kind);
    }

    [Fact]
    public void Conditional_jump_falls_through_when_not_taken()
    {
        Load(0xAF, 0xC2, 0x00, 0x30); // XRA A ; JNZ 3000
        Run(2);
        Assert.Equal(0x2004, _cpu.PC);
    }

    [Fact]
    public void Restart_calls_the_vector()
    {
        Load(0xEF); // RST 5
        Run(1);
        Assert.Equal(0x0028, _cpu.PC);
        Assert.Equal(0x2001, _cpu.Memory[_cpu.SP] | _cpu.Memory[_cpu.SP + 1] << 8);
    }

    [Fact]
    public void Rotates_through_carry()
    {
        Load(0x3E, 0x81, 0x07, 0x1F); // MVI A,81 ; RLC ; RAR
        Run(2);
        Assert.Equal(0x03, _cpu.A);
        Assert.True(_cpu.Carry);
        Run(1);
        Assert.Equal(0x81, _cpu.A);
        Assert.True(_cpu.Carry);
    }

    [Theory]
    [InlineData(0x07, 0x81, false, 0x02, true)] // 1988 RLC rotated through carry
    [InlineData(0x17, 0x81, false, 0x03, true)] // 1988 RAL was circular, carry = old bit 0
    [InlineData(0x0F, 0x81, true, 0xC0, true)]  // 1988 RRC rotated through carry
    [InlineData(0x1F, 0x01, false, 0x80, false)] // 1988 RAR was circular, carry = old bit 7
    public void Original_rotates_reproduce_the_1988_simulator(byte op, byte a, bool carry, byte expectedA, bool expectedCarry)
    {
        _cpu.OriginalRotates = true;
        _cpu.A = a;
        _cpu.Carry = carry;
        Load(op);
        Run(1);
        Assert.Equal(expectedA, _cpu.A);
        Assert.Equal(expectedCarry, _cpu.Carry);
    }

    [Fact]
    public void Hold_requests_a_delay_using_the_original_formula()
    {
        Load(0x08, 0x7F, 0x00); // HOLD 007F -> |7F00 - 7FFF| / 2
        var result = _cpu.Step();
        Assert.Equal(StepKind.Delay, result.Kind);
        Assert.Equal((0x7FFF - 0x7F00) / 2, result.Value);
        Assert.Equal(0x2003, _cpu.PC);
    }

    [Fact]
    public void In_waits_for_the_user_then_reads_the_switches()
    {
        Load(0xDB, 0x00); // IN 00
        var result = _cpu.Step();
        Assert.Equal(StepKind.InputRequired, result.Kind);
        Assert.Equal(0x2000, _cpu.PC);

        _io.ProvideInput(0xA5);
        Run(1);
        Assert.Equal(0xA5, _cpu.A);
        Assert.Equal(0x2002, _cpu.PC);
    }

    [Fact]
    public void Undefined_opcode_is_reported()
    {
        Load(0xCB);
        Assert.Equal(StepKind.InvalidOpcode, _cpu.Step().Kind);
    }

    [Fact]
    public void Seven_segment_display_auto_increments()
    {
        Load(0x3E, 0x8A, 0xD3, 0x05, 0x3E, 0x0C, 0xD3, 0x04, 0xD3, 0x04); // position 2, auto-increment
        Run(5);
        Assert.Equal(0x0C, _io.Digits[2]);
        Assert.Equal(0x0C, _io.Digits[3]);
        Assert.Equal(4, _io.DigitPosition);
    }
}
