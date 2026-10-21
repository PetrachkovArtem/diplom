using ChargingServer.Ocpp.Models;

namespace ChargingServer.Ocpp.Models.Messages;

public class AuthorizeRequest
{
    public IdTokenType IdToken { get; set; } = new();
}

public class AuthorizeResponse
{
    public IdTokenInfoType IdTokenInfo { get; set; } = new();
}
