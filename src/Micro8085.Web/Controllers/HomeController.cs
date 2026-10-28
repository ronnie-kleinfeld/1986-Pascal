using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Micro8085.Web.Infrastructure;
using Micro8085.Web.Models;

namespace Micro8085.Web.Controllers;

public class HomeController(MonitorSessionStore sessions) : Controller
{
    public IActionResult Index()
    {
        var session = sessions.Get(HttpContext);
        lock (session.SyncRoot)
            return View(new HomeViewModel(session.Log.ToList(), session.State));
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
