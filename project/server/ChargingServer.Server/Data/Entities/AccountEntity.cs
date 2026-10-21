namespace ChargingServer.Server.Data.Entities;

public enum AccountRole
{
    User = 1,
    Admin
}

public class AccountEntity
{
    public Guid Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public bool Consent { get; set; }
    public bool IsBlocked { get; set; }
    public AccountRole Role { get; set; } = AccountRole.User;
    public string BindToken { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<StationEntity> Stations { get; set; } = [];
    public ICollection<ChargingSessionEntity> Sessions { get; set; } = [];
}
