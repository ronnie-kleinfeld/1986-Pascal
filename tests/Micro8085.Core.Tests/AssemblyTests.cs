using Micro8085.Core.Assembly;
using Micro8085.Core.Cpu;
using Micro8085.Core.Monitor;

namespace Micro8085.Core.Tests;

public class AssemblyTests
{
    public static TheoryData<byte> AllOpcodes() => new(OpcodeTable.All.Select(o => o.Code));

    [Theory]
    [MemberData(nameof(AllOpcodes))]
    public void Every_opcode_round_trips_through_disassembler_and_assembler(byte opcode)
    {
        var memory = new byte[0x10000];
        memory[0x2000] = opcode;
        memory[0x2001] = 0x34;
        memory[0x2002] = 0x12;

        var instruction = Disassembler.Disassemble(memory, 0x2000);
        var result = Assembler.Assemble(instruction.Mnemonic);

        Assert.True(result.Success, $"{instruction.Mnemonic}: {result.Error}");
        Assert.Equal(memory.AsSpan(0x2000, instruction.Length).ToArray(), result.Bytes);
    }

    [Theory]
    [InlineData("MVI  A,38", "MVI  A,38", "3E,38")]
    [InlineData("jmp 2000", "JMP  2000", "C3,00,20")]
    [InlineData("OUT #FF", "OUT  #FF", "D3,FF")]
    [InlineData("OUT 04", "OUT  #04", "D3,04")]
    [InlineData("LXI SP,38FE", "LXI  SP,38FE", "31,FE,38")]
    [InlineData("MOV M, A", "MOV  M,A", "77")]
    [InlineData("RST 7", "RST  7", "FF")]
    public void Formats_like_the_original_listing(string source, string mnemonic, string opcodes)
    {
        var memory = new byte[0x10000];
        Assembler.Assemble(source).Bytes.CopyTo(memory, 0x2000);

        var instruction = Disassembler.Disassemble(memory, 0x2000);

        Assert.Equal(mnemonic, instruction.Mnemonic);
        Assert.Equal(opcodes, instruction.Opcodes);
    }

    [Theory]
    [InlineData("FOO A", MonitorError.InvalidMnemonic)]
    [InlineData("MVI Q,38", MonitorError.InvalidOperand)]
    [InlineData("MVI A,123", MonitorError.InvalidOperand)]
    [InlineData("JMP", MonitorError.InvalidOperand)]
    public void Rejects_bad_source(string source, MonitorError error)
    {
        Assert.Equal(error, Assembler.Assemble(source).Error);
    }

    [Fact]
    public void Undefined_opcodes_disassemble_as_dashes()
    {
        var memory = new byte[0x10000];
        memory[0x2000] = 0xCB;
        var instruction = Disassembler.Disassemble(memory, 0x2000);
        Assert.Equal("----", instruction.Mnemonic);
        Assert.Equal(1, instruction.Length);
    }
}
