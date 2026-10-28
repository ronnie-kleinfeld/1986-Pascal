using Micro8085.Web.Infrastructure;
using Micro8085.Web.Models;
using Microsoft.AspNetCore.Mvc;

namespace Micro8085.Web.Controllers;

/// <summary>F5 - the operator menu: beep, clean ports, clear registers.</summary>
public class OperateController(MonitorSessionStore sessions) : Controller
{
    [HttpGet]
    public IActionResult Index()
    {
        var session = sessions.Get(HttpContext);
        return View(new OperateViewModel { Beep = session.BeepEnabled, OriginalRotates = session.Cpu.OriginalRotates });
    }

    [HttpPost]
    public IActionResult Index(OperateViewModel model)
    {
        var session = sessions.Get(HttpContext);
        lock (session.SyncRoot)
        {
            session.BeepEnabled = model.Beep;
            session.Cpu.OriginalRotates = model.OriginalRotates;
            if (model.CleanPorts)
                session.Io.CleanPorts();
            if (model.ClearRegisters)
                session.ClearRegisters();
        }
        return RedirectToAction("Index", "Home");
    }
}
