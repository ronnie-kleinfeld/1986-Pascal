using Micro8085.Core.Monitor;
using Micro8085.Web.Infrastructure;
using Microsoft.AspNetCore.Mvc;

namespace Micro8085.Web.Controllers;

/// <summary>JSON endpoints driven by the editor screen (wwwroot/js/micro.js).</summary>
[Route("monitor")]
public class MonitorController(MonitorSessionStore sessions) : Controller
{
    private const int MaxStepsPerRequest = 200_000;

    [HttpPost("execute")]
    public MonitorResponse Execute([FromBody] ExecuteRequest request) =>
        WithSession(s => s.Execute(request.Command ?? ""));

    [HttpPost("continue")]
    public MonitorResponse Continue([FromBody] ContinueRequest request) =>
        WithSession(s => s.Continue(Math.Clamp(request.Steps, 1, MaxStepsPerRequest)));

    [HttpPost("input")]
    public MonitorResponse Input([FromBody] InputRequest request) =>
        WithSession(s => s.ProvideInput((byte)Math.Clamp(request.Value, 0, 255)));

    [HttpPost("break")]
    public MonitorResponse Break() => WithSession(s => s.Break());

    private MonitorResponse WithSession(Func<MonitorSession, MonitorResponse> action)
    {
        var session = sessions.Get(HttpContext);
        lock (session.SyncRoot)
            return action(session);
    }

    public sealed record ExecuteRequest(string? Command);

    public sealed record ContinueRequest(int Steps);

    public sealed record InputRequest(int Value);
}
