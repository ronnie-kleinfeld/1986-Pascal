using Micro8085.Core.Monitor;

namespace Micro8085.Core.Tests;

public class MonitorSessionTests
{
    private readonly MonitorSession _session = new();

    [Fact]
    public void Append_assembles_and_advances_the_prompt()
    {
        var response = _session.Execute("A2000 MVI A,38");

        Assert.Equal(MonitorError.None, response.Error);
        Assert.Equal(new ConsoleLine("A2000:MVI  A,38", "O2000:3E,38"), Assert.Single(response.Lines));
        Assert.Equal("A2002 ", response.Prompt);
        Assert.Equal(0x3E, _session.Cpu.Memory[0x2000]);
    }

    [Fact]
    public void Append_error_keeps_the_line_for_editing()
    {
        var response = _session.Execute("A2000 MVI X,38");

        Assert.Equal(MonitorError.InvalidOperand, response.Error);
        Assert.Equal("3 Invalid mnemonics operand", response.ErrorMessage);
        Assert.Equal("A2000 MVI X,38", response.Prompt);
    }

    [Fact]
    public void Opcode_entry_shows_the_mnemonic()
    {
        var response = _session.Execute("O2000:C3,00,20");

        Assert.Equal(new ConsoleLine("O2000:C3,00,20", "A2000:JMP  2000"), Assert.Single(response.Lines));
        Assert.Equal("O2003 ", response.Prompt);
    }

    [Theory]
    [InlineData("O2000 C3,00", MonitorError.OpcodeSyntax)]
    [InlineData("O2000 CB", MonitorError.UnknownOpcode)]
    [InlineData("O2000 3", MonitorError.OpcodeSyntax)]
    [InlineData("A0050 NOP", MonitorError.OutOfRange)]
    [InlineData("A8000 NOP", MonitorError.OutOfRange)]
    [InlineData("X2000", MonitorError.UnknownCommand)]
    [InlineData("L2010-2000", MonitorError.ListType)]
    [InlineData("P2000-", MonitorError.ListType)]
    [InlineData("R:A=100", MonitorError.Syntax)]
    [InlineData("R:Q=1", MonitorError.Syntax)]
    [InlineData("R:CY=2", MonitorError.Syntax)]
    public void Reports_the_original_error_codes(string command, MonitorError error)
    {
        Assert.Equal(error, _session.Execute(command).Error);
    }

    [Fact]
    public void Set_writes_bytes()
    {
        var response = _session.Execute("S2000 48,54");

        Assert.Equal("S2002:", response.Prompt);
        Assert.Equal(new byte[] { 0x48, 0x54 }, _session.ReadMemory(0x2000, 2));
    }

    [Fact]
    public void List_and_k_list_show_both_columns()
    {
        _session.Execute("S2000 3E,38,76");

        var list = _session.Execute("L2000-2002");
        var opcodes = _session.Execute("K2000-2002");

        Assert.Equal(
            [new("A2000:MVI  A,38", "O2000:3E,38"), new("A2002:HLT", "O2002:76")],
            list.Lines);
        Assert.Equal(new ConsoleLine("O2000:3E,38", "A2000:MVI  A,38"), opcodes.Lines[0]);
    }

    [Fact]
    public void Long_listings_are_paged()
    {
        var response = _session.Execute("L2000-");

        Assert.Equal(MonitorSession.ListingPageSize + 1, response.Lines.Count);
        Assert.Equal("L20C8-7FFF", response.Continuation);
    }

    [Fact]
    public void Print_produces_a_listing()
    {
        _session.Execute("S2000 3E,38");

        var response = _session.Execute("P2000-2001");

        Assert.Equal("   2000:MVI  A,38             3E,38" + Environment.NewLine, response.PrintText);
    }

    [Fact]
    public void Move_copies_a_range()
    {
        _session.Execute("S2000 01,02,03");

        _session.Execute("M2000-2002 3000");

        Assert.Equal(new byte[] { 1, 2, 3 }, _session.ReadMemory(0x3000, 3));
    }

    [Fact]
    public void Register_command_sets_registers_pairs_and_flags()
    {
        _session.Execute("R:A=15");
        _session.Execute("R:HL=2100");
        _session.Execute("R:CY=1");

        Assert.Equal(0x15, _session.Cpu.A);
        Assert.Equal(0x2100, _session.Cpu.HL);
        Assert.True(_session.Cpu.Carry);
    }

    [Fact]
    public void Clear_screen_empties_the_log()
    {
        _session.Execute("A2000 NOP");

        var response = _session.Execute("CLS");

        Assert.True(response.Cleared);
        Assert.Empty(_session.Log);
    }

    [Fact]
    public void Go_runs_until_halt()
    {
        _session.Execute("S2000 3E,42,76");

        Assert.Equal(RunStatus.Running, _session.Execute("G2000").State!.Status);
        var response = _session.Continue(100);

        Assert.Equal(RunStatus.Idle, response.State!.Status);
        Assert.Equal("Halt at 2002", response.Lines[^1].Left);
        Assert.Equal(0x42, _session.Cpu.A);
    }

    [Fact]
    public void Trace_executes_one_instruction_per_continue()
    {
        _session.Execute("S2000 3E,42,06,01,76");
        _session.Execute("T2000");

        _session.Continue(100);

        Assert.Equal(0x2002, _session.Cpu.PC);
        Assert.Equal(RunStatus.Tracing, _session.Status);
    }

    [Fact]
    public void Break_stops_a_running_program()
    {
        _session.Execute("S2000 C3,00,20"); // JMP 2000
        _session.Execute("G2000");
        _session.Continue(50);

        var response = _session.Break();

        Assert.Equal("Break at 2000", response.Lines[^1].Left);
        Assert.Equal(RunStatus.Idle, _session.Status);
    }

    [Fact]
    public void Input_waits_and_resumes()
    {
        _session.Execute("S2000 DB,00,76"); // IN 00 ; HLT
        _session.Execute("G2000");

        Assert.Equal(RunStatus.WaitingForInput, _session.Continue(10).State!.Status);
        _session.ProvideInput(0x81);
        _session.Continue(10);

        Assert.Equal(0x81, _session.Cpu.A);
        Assert.Equal(RunStatus.Idle, _session.Status);
    }

    [Fact]
    public void Hold_pauses_the_run()
    {
        _session.Execute("S2000 08,00,7F,76"); // HOLD 7F00: bytes 00,7F
        _session.Execute("G2000");

        var response = _session.Continue(10);

        Assert.Equal(RunStatus.Delaying, response.State!.Status);
        Assert.Equal(Math.Abs(0x007F - 32767) / 2, response.State.DelayMs);
    }
}
