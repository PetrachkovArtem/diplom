namespace ChargingServer.Server.Logs;

public sealed class FileLoggerProvider : ILoggerProvider
{
    private readonly Dictionary<string, ILogger> _loggers = new();
    private readonly Dictionary<string, LogCategoryDesc> _categoryDescs;

    public FileLoggerProvider(string path, LogLevel minLogLevel)
    {
        _categoryDescs = new Dictionary<string, LogCategoryDesc>
        {
            ["Default"] = new LogCategoryDesc { Path = path, LogLevel = minLogLevel }
        };
    }

    public FileLoggerProvider(Dictionary<string, LogCategoryDesc> descs)
    {
        _categoryDescs = descs;
    }

    public ILogger CreateLogger(string categoryName)
    {
        if (string.IsNullOrEmpty(categoryName) || !_categoryDescs.ContainsKey(categoryName))
        {
            categoryName = "Default";
        }

        if (_loggers.TryGetValue(categoryName, out var existing))
        {
            return existing;
        }

        var desc = _categoryDescs[categoryName];
        var logger = new FileLogger(desc.Path, desc.LogLevel);
        _loggers[categoryName] = logger;
        return logger;
    }

    public void Dispose()
    {
    }
}
