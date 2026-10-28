using System.ComponentModel.DataAnnotations;
using Micro8085.Core.Monitor;
using Micro8085.Core.Storage;

namespace Micro8085.Web.Models;

public sealed record HomeViewModel(IReadOnlyList<ConsoleLine> Log, MachineState State);

public sealed class OperateViewModel
{
    public bool Beep { get; set; }
    public bool CleanPorts { get; set; }
    public bool ClearRegisters { get; set; }
    public bool OriginalRotates { get; set; }
}

public sealed class LoadProgramViewModel
{
    [Required(ErrorMessage = "Choose a file.")]
    [Display(Name = "File name")]
    public string Name { get; set; } = "";

    /// <summary>Hex address to load at; blank keeps the address the program was saved from.</summary>
    [Display(Name = "From")]
    public string? From { get; set; }

    public IReadOnlyList<CatalogEntry> Programs { get; set; } = [];
}

public sealed class SaveProgramViewModel
{
    [Required(ErrorMessage = "Enter a file name.")]
    [RegularExpression("^[A-Za-z0-9#_-]{1,8}$", ErrorMessage = "Up to 8 letters, digits, # _ or -.")]
    [Display(Name = "File name")]
    public string Name { get; set; } = "";

    [Required(ErrorMessage = "Enter the start address.")]
    public string Start { get; set; } = "";

    [Required(ErrorMessage = "Enter the end address.")]
    public string End { get; set; } = "";
}
