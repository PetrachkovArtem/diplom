using System.Collections.Concurrent;

namespace ChargingServer.Server.Services;

public sealed class TimedOutStartRegistry
{
    private readonly ConcurrentDictionary<(string ChargePointId, int RemoteStartId), byte> _marks = new();

    public void Mark(string chargePointId, int remoteStartId) => _marks[(chargePointId, remoteStartId)] = 0;

    public bool IsMarked(string chargePointId, int? remoteStartId) => remoteStartId > 0 && _marks.ContainsKey((chargePointId, remoteStartId.Value));

    public void Forget(string chargePointId, int remoteStartId) => _marks.TryRemove((chargePointId, remoteStartId), out _);
}
