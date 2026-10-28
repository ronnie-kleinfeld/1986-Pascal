namespace Micro8085.Web.Infrastructure;

/// <summary>Recognises the unmodified 1988 sample programs, which were written for the original's swapped rotates.</summary>
public sealed class OriginalPrograms(string seedDirectory)
{
    public bool IsOriginal(string name, ReadOnlySpan<byte> bytes)
    {
        var path = Path.Combine(seedDirectory, name + ".DAT");
        return File.Exists(path) && bytes.SequenceEqual(File.ReadAllBytes(path));
    }
}
