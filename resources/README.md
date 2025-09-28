# Color Demo Apps

A set of ultra-simple ASP.NET Core Razor Pages apps, each themed with a different color and packaged for easy containerization. Every app lives in its own folder with:

- An ASP.NET Core `net8.0` project
- A single Razor page (`Pages/Index.cshtml`) that paints the page with the target color
- A ready-to-use multi-stage `Dockerfile`
- `build-and-push.ps1` helper script for building and pushing to Docker Hub

## Projects

| Folder        | Description                                         | Special Behavior                           |
| ------------- | --------------------------------------------------- | ------------------------------------------ |
| `green-app/`  | Calming green theme with white text                 | —                                          |
| `blue-app/`   | Cool blue theme with white text                     | —                                          |
| `yellow-app/` | Bright yellow background with dark text             | —                                          |
| `purple-app/` | Gradient purple background for a more creative vibe | —                                          |
| `red-app/`    | Red warning theme                                   | Crashes intentionally 5 seconds after boot |

## Building and Pushing Images

### Individual Apps

Each folder contains an identical PowerShell helper script:

```powershell
# Run inside the application folder
cd blue-app
./build-and-push.ps1

# Or with a custom tag
./build-and-push.ps1 -Tag v1.2
```

### All Apps at Once

Use the master build script from the resources folder:

```powershell
# Build and push all color apps with default 'latest' tag
./build-all-apps.ps1

# Build and push all color apps with custom tag
./build-all-apps.ps1 -Tag v2.0
```

Make sure you invoke `docker login` beforehand so the push succeeds.

**Note**: All images are pushed to `domasmasiulis/<app-name>:tag` on Docker Hub.

## Running Locally

```powershell
# From inside an app folder
dotnet run

# Or using Docker
# (replace repo/tag with the values you built)
docker run --rm -p 8080:8080 yourdockerhubuser/green-app:v1
```

The ASP.NET Core apps listen on port 8080 inside the container (configured in the Dockerfile via `ASPNETCORE_URLS`).

## Notes

- The red app uses `Environment.FailFast` to terminate five seconds after start-up, simulating a failing service.
- All projects target .NET 8.0; update the `TargetFramework` property if you require a different runtime.
- Feel free to duplicate folders to create more color themes—only the HTML/CSS and namespace in `_ViewImports` need to change.
