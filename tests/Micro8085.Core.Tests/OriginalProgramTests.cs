using Micro8085.Core.Monitor;
using Micro8085.Core.Storage;

namespace Micro8085.Core.Tests;

/// <summary>Runs against a copy of the 1986 files in MICRO/.</summary>
public sealed class OriginalProgramTests : IDisposable
{
    private readonly string _directory = Directory.CreateTempSubdirectory("micro8085-").FullName;
    private readonly ProgramCatalog _catalog;

    public OriginalProgramTests()
    {
        var original = Path.Combine(FindRepositoryRoot(), "MICRO");
        foreach (var file in Directory.GetFiles(original, "*.DAT"))
            File.Copy(file, Path.Combine(_directory, Path.GetFileName(file)));
        _catalog = new ProgramCatalog(_directory);
    }

    public void Dispose() => Directory.Delete(_directory, recursive: true);

    [Fact]
    public void Reads_the_original_catalog()
    {
        var names = _catalog.List().Select(e => e.Name).ToList();

        Assert.Contains("STEPS", names);
        Assert.Contains("ORT-88", names);
        Assert.DoesNotContain("ADD-2", names); // erased in 1988
        Assert.Equal(new CatalogEntry("STEPS", 0x2010, 20), _catalog.Find("steps"));
    }

    [Fact]
    public void Ort_88_spells_its_name_on_the_seven_segment_display()
    {
        var session = Load("ORT-88", 0x2000);

        session.Execute("G2000");
        var response = session.Continue(1000);

        Assert.Equal("Halt at 201C", response.Lines[^1].Left);
        // o r t - 8 8 in the board's active-low segment encoding
        Assert.Equal([0x3A, 0xFA, 0x78, 0xFB, 0x08, 0x08], session.Io.Digits.Select(d => (int)d));
    }

    [Fact]
    public void Steps_walks_the_leds_forever_with_1988_rotates()
    {
        var leds = RunSteps(originalRotates: true);

        Assert.True(leds.Distinct().Count() > 4);
        Assert.DoesNotContain((byte)0, leds);
    }

    [Fact]
    public void Steps_goes_dark_on_a_real_8085()
    {
        // ANI clears carry and RAL rotates through it, so the pattern shifts out after one pass.
        var leds = RunSteps(originalRotates: false);

        Assert.Equal(0, leds[^1]);
    }

    private List<byte> RunSteps(bool originalRotates)
    {
        var entry = _catalog.Find("STEPS")!;
        var session = Load(entry.Name, entry.StartAddress);
        session.Cpu.OriginalRotates = originalRotates;
        session.Execute($"G{entry.StartAddress:X4}");

        var leds = new List<byte>();
        for (var i = 0; i < 100; i++)
        {
            session.Continue(200);
            leds.Add(session.Io.Leds);
        }
        Assert.Equal(RunStatus.Running, session.Status);
        return leds;
    }

    [Fact]
    public void Save_and_erase_keep_the_original_record_format()
    {
        var saved = _catalog.Save("test-1", 0x3000, [0x3E, 0x01, 0x76]);
        var reopened = new ProgramCatalog(_directory);

        Assert.Equal(new CatalogEntry("TEST-1", 0x3000, 3), reopened.Find("TEST-1"));
        Assert.Equal(new byte[] { 0x3E, 0x01, 0x76 }, reopened.Read(saved));
        Assert.Equal(0, new FileInfo(Path.Combine(_directory, ProgramCatalog.CatalogFileName)).Length % 14);

        Assert.True(reopened.Erase("TEST-1"));
        Assert.Null(reopened.Find("TEST-1"));
    }

    [Theory]
    [InlineData("../EVIL")]
    [InlineData("TOOLONGNAME")]
    [InlineData("")]
    public void Rejects_unsafe_names(string name)
    {
        Assert.Throws<ArgumentException>(() => _catalog.Save(name, 0x2000, [0]));
    }

    private MonitorSession Load(string name, int address)
    {
        var entry = _catalog.Find(name)!;
        var session = new MonitorSession();
        session.LoadMemory(address, _catalog.Read(entry));
        return session;
    }

    private static string FindRepositoryRoot()
    {
        var directory = new DirectoryInfo(AppContext.BaseDirectory);
        while (directory is not null && !Directory.Exists(Path.Combine(directory.FullName, "MICRO")))
            directory = directory.Parent;
        return directory?.FullName ?? throw new DirectoryNotFoundException("MICRO folder not found.");
    }
}
