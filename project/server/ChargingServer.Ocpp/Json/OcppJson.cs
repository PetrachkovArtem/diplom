using System.Text.Json;
using System.Text.Json.Serialization;

namespace ChargingServer.Ocpp.Json;

public static class OcppJson
{
    public static readonly JsonSerializerOptions Options = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
        PropertyNameCaseInsensitive = true,
        Converters =
        {
            new JsonStringEnumConverter(namingPolicy: null, allowIntegerValues: false)
        }
    };

    public static T? Deserialize<T>(string json) => JsonSerializer.Deserialize<T>(json, Options);
    public static T? Deserialize<T>(JsonElement element) => element.Deserialize<T>(Options);
}
