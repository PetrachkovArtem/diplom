namespace ChargingServer.Ocpp.Models;

public class SendMessage
{
    public required string Id { get; init; }
    public required string ActionType { get; init; }
    public string? DebugMessageData { get; set; }
    public TaskCompletionSource<string> Tcs { get; } = new(TaskCreationOptions.RunContinuationsAsynchronously);
}
