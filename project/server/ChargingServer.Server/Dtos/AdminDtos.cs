namespace ChargingServer.Server.Dtos;

public class AdminUserDto
{
    public Guid Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public bool IsBlocked { get; set; }
    public DateTime CreatedAt { get; set; }
    public string Role { get; set; } = string.Empty;
}

public class BlockUserRequest
{
    public bool IsBlocked { get; set; }
}
