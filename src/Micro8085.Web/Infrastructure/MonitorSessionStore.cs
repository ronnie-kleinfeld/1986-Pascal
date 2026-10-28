using Micro8085.Core.Monitor;
using Microsoft.Extensions.Caching.Memory;

namespace Micro8085.Web.Infrastructure;

/// <summary>Keeps one simulator per browser, identified by a cookie, for as long as it is in use.</summary>
public sealed class MonitorSessionStore(IMemoryCache cache)
{
    private const string CookieName = "micro8085";
    private static readonly TimeSpan IdleTimeout = TimeSpan.FromHours(2);

    public MonitorSession Get(HttpContext context)
    {
        if (!context.Request.Cookies.TryGetValue(CookieName, out var id) || !Guid.TryParseExact(id, "N", out _))
        {
            id = Guid.NewGuid().ToString("N");
            context.Response.Cookies.Append(CookieName, id, new CookieOptions
            {
                HttpOnly = true,
                IsEssential = true,
                SameSite = SameSiteMode.Strict,
                Secure = context.Request.IsHttps,
            });
        }

        return cache.GetOrCreate($"{CookieName}:{id}", entry =>
        {
            entry.SlidingExpiration = IdleTimeout;
            return new MonitorSession();
        })!;
    }
}
