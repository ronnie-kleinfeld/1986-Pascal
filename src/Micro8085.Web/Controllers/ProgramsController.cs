using Micro8085.Core.Assembly;
using Micro8085.Core.Monitor;
using Micro8085.Core.Storage;
using Micro8085.Web.Infrastructure;
using Micro8085.Web.Models;
using Microsoft.AspNetCore.Mvc;

namespace Micro8085.Web.Controllers;

/// <summary>F9 - the input/output menu: load, save, dir, erase.</summary>
public class ProgramsController(ProgramCatalog catalog, MonitorSessionStore sessions, OriginalPrograms originals) : Controller
{
    private const string RangeMessage = "Address must be hex h0100-h7FFF.";

    public IActionResult Index() => View(catalog.List());

    [HttpGet]
    public IActionResult Load(string? id) =>
        View(new LoadProgramViewModel { Name = id ?? "", Programs = catalog.List() });

    [HttpPost]
    public IActionResult Load(LoadProgramViewModel model)
    {
        model.Programs = catalog.List();
        var entry = ModelState.IsValid ? catalog.Find(model.Name) : null;
        if (ModelState.IsValid && entry is null)
            ModelState.AddModelError(nameof(model.Name), "File not found.");

        var start = entry?.StartAddress ?? 0;
        if (entry is not null && !string.IsNullOrWhiteSpace(model.From) && !TryParseAddress(model.From, out start))
            ModelState.AddModelError(nameof(model.From), RangeMessage);
        if (entry is not null && ModelState.IsValid && start + entry.Length - 1 > MonitorSession.MaxAddress)
            ModelState.AddModelError(nameof(model.From), $"{entry.Length} bytes do not fit below h7FFF from h{Hex.Word(start)}.");
        if (!ModelState.IsValid)
            return View(model);

        var bytes = catalog.Read(entry!);
        var session = sessions.Get(HttpContext);
        lock (session.SyncRoot)
        {
            session.Break();
            session.LoadMemory(start, bytes);
            session.Cpu.PC = (ushort)start;
            session.Note($"Loaded {entry!.Name}", $"{Hex.Word(start)}-{Hex.Word(start + bytes.Length - 1)}");

            // Unmodified 1988 programs expect the original's swapped rotates; anything else gets a real 8085.
            var original = originals.IsOriginal(entry.Name, bytes);
            if (session.Cpu.OriginalRotates != original)
            {
                session.Cpu.OriginalRotates = original;
                session.Note(original ? "1988 rotates on" : "1988 rotates off", "F5 to change");
            }
        }
        return RedirectToAction("Index", "Home");
    }

    [HttpGet]
    public IActionResult Save(string? id)
    {
        var existing = id is null ? null : catalog.Find(id);
        return View(new SaveProgramViewModel
        {
            Name = existing?.Name ?? id ?? "",
            Start = existing is null ? "2000" : Hex.Word(existing.StartAddress),
            End = existing is null ? "" : Hex.Word(existing.StartAddress + existing.Length - 1),
        });
    }

    [HttpPost]
    public IActionResult Save(SaveProgramViewModel model)
    {
        if (!TryParseAddress(model.Start, out var start))
            ModelState.AddModelError(nameof(model.Start), RangeMessage);
        if (!TryParseAddress(model.End, out var end))
            ModelState.AddModelError(nameof(model.End), RangeMessage);
        else if (end < start)
            ModelState.AddModelError(nameof(model.End), "The range must end after it starts.");
        if (!ModelState.IsValid)
            return View(model);

        var session = sessions.Get(HttpContext);
        byte[] bytes;
        lock (session.SyncRoot)
            bytes = session.ReadMemory(start, end - start + 1);
        var entry = catalog.Save(model.Name, start, bytes);
        TempData["Message"] = $"Saved {entry.Name} (h{Hex.Word(start)}-h{Hex.Word(end)}, {bytes.Length} bytes).";
        return RedirectToAction(nameof(Index));
    }

    [HttpGet]
    public IActionResult Erase(string id)
    {
        var entry = catalog.Find(id);
        return entry is null ? NotFound() : View(entry);
    }

    [HttpPost, ActionName(nameof(Erase))]
    public IActionResult EraseConfirmed(string id)
    {
        if (!catalog.Erase(id))
            return NotFound();
        TempData["Message"] = $"Erased {ProgramCatalog.NormalizeName(id)}.";
        return RedirectToAction(nameof(Index));
    }

    private static bool TryParseAddress(string? text, out int address) =>
        Hex.TryParse(text?.Trim() ?? "", 4, out address) && MonitorSession.IsUserAddress(address);
}
