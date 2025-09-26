using System.Security.Cryptography;

namespace YellowApp.Services;

public sealed class PodIdentityService
{
    private static readonly string[] Names =
    [
        "Avery",
        "Jordan",
        "Riley",
        "Morgan",
        "Taylor",
        "Dakota",
        "Harper",
        "Skyler",
        "Rowan",
        "Emerson",
        "Peyton",
        "Quinn",
        "Sawyer",
        "Finley",
        "Hayden",
        "Reese",
        "Casey",
        "Blake",
        "Elliott",
        "Parker"
    ];

    public string Name { get; }

    public PodIdentityService()
    {
        var index = RandomNumberGenerator.GetInt32(Names.Length);
        Name = Names[index];
    }
}
