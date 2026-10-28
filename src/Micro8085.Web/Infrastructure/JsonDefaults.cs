using System.Text.Json;
using System.Text.Json.Serialization;

namespace Micro8085.Web.Infrastructure;

public static class JsonDefaults
{
    public static readonly JsonSerializerOptions Options = Configure(new JsonSerializerOptions(JsonSerializerDefaults.Web));

    public static JsonSerializerOptions Configure(JsonSerializerOptions options)
    {
        options.Converters.Add(new JsonStringEnumConverter(JsonNamingPolicy.CamelCase));
        return options;
    }
}
