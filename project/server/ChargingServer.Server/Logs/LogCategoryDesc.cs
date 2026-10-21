namespace ChargingServer.Server.Logs;

public sealed class LogCategoryDesc
{
    public required string Path { get; init; }
    public LogLevel LogLevel { get; init; }
}
