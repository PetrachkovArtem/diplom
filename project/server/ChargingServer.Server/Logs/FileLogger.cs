namespace ChargingServer.Server.Logs;

public sealed class FileLogger(string path, LogLevel minLogLevel) : ILogger
{
    private readonly string _filePath = path;
    private readonly LogLevel _minLogLevel = minLogLevel;
    private readonly object _lock = new();

    public IDisposable? BeginScope<TState>(TState state) where TState : notnull => null;

    public bool IsEnabled(LogLevel logLevel) => logLevel >= _minLogLevel;

    public void Log<TState>(
        LogLevel logLevel,
        EventId eventId,
        TState state,
        Exception? exception,
        Func<TState, Exception?, string> formatter)
    {
        if (!IsEnabled(logLevel) || formatter == null)
        {
            return;
        }

        lock (_lock)
        {
            Directory.CreateDirectory(Path.GetDirectoryName(_filePath)!);

            if (exception != null)
            {
                var message = exception.Message;
                if (exception.InnerException != null)
                {
                    message += $"; {exception.InnerException.Message}";
                }

                File.AppendAllText(
                    _filePath,
                    $"[{DateTime.UtcNow:dd.MM.yyyy HH:mm:ss}] {logLevel} {state}: {message}{Environment.NewLine}{exception.StackTrace}{Environment.NewLine}");
            }
            else
            {
                File.AppendAllText(
                    _filePath,
                    $"[{DateTime.UtcNow:dd.MM.yyyy HH:mm:ss}] {logLevel} {state} {Environment.NewLine}");
            }
        }
    }
}
