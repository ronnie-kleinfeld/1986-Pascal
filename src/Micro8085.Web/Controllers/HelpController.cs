using Micro8085.Core.Monitor;
using Microsoft.AspNetCore.Mvc;

namespace Micro8085.Web.Controllers;

/// <summary>F1 commands, F3 errors, and the original 8085 instruction card (MICRO.CMD).</summary>
public class HelpController(IWebHostEnvironment environment) : Controller
{
    public IActionResult Commands() => View();

    public IActionResult Errors() => View(MonitorErrors.All);

    public IActionResult Instructions() =>
        View((object)System.IO.File.ReadAllText(Path.Combine(environment.ContentRootPath, "Content", "instruction-card.txt")));
}
