using System.Buffers.Binary;
using System.Text;
using System.Text.RegularExpressions;

namespace Micro8085.Core.Storage;

public sealed record CatalogEntry(string Name, int StartAddress, int Length);

/// <summary>
/// Saved programs, stored in the original on-disk formats so the 1986 files load unchanged:
/// MCRNAME.DAT is a Turbo Pascal "file of MAIN" (14-byte records: string[8] name, integer start,
/// integer range, boolean active) and NAME.DAT holds the raw program bytes.
/// </summary>
public sealed partial class ProgramCatalog(string directory)
{
    public const string CatalogFileName = "MCRNAME.DAT";
    private const int RecordSize = 14;
    private const int MaxNameLength = 8;

    private readonly Lock _lock = new();

    public string Directory { get; } = directory;

    public static bool IsValidName(string? name) => name is not null && NamePattern().IsMatch(name);

    public static string NormalizeName(string name) => name.Trim().ToUpperInvariant();

    public IReadOnlyList<CatalogEntry> List()
    {
        lock (_lock)
        {
            return ReadRecords()
                .Where(r => r.Active && File.Exists(DataPath(r.Name)))
                .GroupBy(r => r.Name)
                .Select(g => g.First())
                .Select(r => new CatalogEntry(r.Name, r.Start, (int)new FileInfo(DataPath(r.Name)).Length))
                .OrderBy(e => e.Name, StringComparer.Ordinal)
                .ToList();
        }
    }

    public CatalogEntry? Find(string name) =>
        List().FirstOrDefault(e => e.Name == NormalizeName(name));

    public byte[] Read(CatalogEntry entry)
    {
        lock (_lock)
            return File.ReadAllBytes(DataPath(entry.Name));
    }

    public CatalogEntry Save(string name, int startAddress, ReadOnlySpan<byte> bytes)
    {
        name = NormalizeName(name);
        if (!IsValidName(name))
            throw new ArgumentException($"'{name}' is not a valid program name.", nameof(name));

        lock (_lock)
        {
            System.IO.Directory.CreateDirectory(Directory);
            File.WriteAllBytes(DataPath(name), bytes.ToArray());

            var records = ReadRecords();
            var record = new Record(name, startAddress, bytes.Length, true);
            var index = records.FindIndex(r => r.Active && r.Name == name);
            if (index >= 0)
                records[index] = record;
            else
                records.Add(record);
            WriteRecords(records);
            return new CatalogEntry(name, startAddress, bytes.Length);
        }
    }

    /// <summary>Marks the catalog record inactive (as the original did) and removes the data file.</summary>
    public bool Erase(string name)
    {
        name = NormalizeName(name);
        lock (_lock)
        {
            var records = ReadRecords();
            var found = false;
            for (var i = 0; i < records.Count; i++)
            {
                if (records[i].Active && records[i].Name == name)
                {
                    records[i] = records[i] with { Active = false };
                    found = true;
                }
            }
            if (!found)
                return false;

            WriteRecords(records);
            if (IsValidName(name))
                File.Delete(DataPath(name));
            return true;
        }
    }

    private string DataPath(string name) => Path.Combine(Directory, name + ".DAT");

    private List<Record> ReadRecords()
    {
        var path = Path.Combine(Directory, CatalogFileName);
        if (!File.Exists(path))
            return [];

        var data = File.ReadAllBytes(path);
        var records = new List<Record>(data.Length / RecordSize);
        for (var offset = 0; offset + RecordSize <= data.Length; offset += RecordSize)
        {
            var span = data.AsSpan(offset, RecordSize);
            var length = Math.Min((int)span[0], MaxNameLength);
            var name = Encoding.ASCII.GetString(span.Slice(1, length));
            var start = (ushort)BinaryPrimitives.ReadInt16LittleEndian(span[9..]);
            var range = BinaryPrimitives.ReadInt16LittleEndian(span[11..]);
            var active = span[13] != 0 && IsValidName(name);
            records.Add(new Record(name, start, range, active));
        }
        return records;
    }

    private void WriteRecords(List<Record> records)
    {
        var data = new byte[records.Count * RecordSize];
        for (var i = 0; i < records.Count; i++)
        {
            var span = data.AsSpan(i * RecordSize, RecordSize);
            var record = records[i];
            var name = Encoding.ASCII.GetBytes(record.Name.Length > MaxNameLength ? record.Name[..MaxNameLength] : record.Name);
            span[0] = (byte)name.Length;
            name.CopyTo(span[1..]);
            BinaryPrimitives.WriteInt16LittleEndian(span[9..], (short)record.Start);
            BinaryPrimitives.WriteInt16LittleEndian(span[11..], (short)record.Range);
            span[13] = record.Active ? (byte)1 : (byte)0;
        }
        File.WriteAllBytes(Path.Combine(Directory, CatalogFileName), data);
    }

    // DOS 8.3 base names, which also keeps every data path inside the catalog directory.
    [GeneratedRegex("^[A-Z0-9#_-]{1,8}$")]
    private static partial Regex NamePattern();

    private sealed record Record(string Name, int Start, int Range, bool Active);
}
