using Micro8085.Core.Storage;

namespace Micro8085.Web.Infrastructure;

public static class ProgramSeeder
{
    /// <summary>Copies the 1986 sample programs into an empty program directory.</summary>
    public static void SeedIfEmpty(string directory, string seedDirectory)
    {
        Directory.CreateDirectory(directory);
        if (File.Exists(Path.Combine(directory, ProgramCatalog.CatalogFileName)) || !Directory.Exists(seedDirectory))
            return;

        foreach (var file in Directory.GetFiles(seedDirectory, "*.DAT"))
            File.Copy(file, Path.Combine(directory, Path.GetFileName(file)), overwrite: false);
    }
}
