using Microsoft.AspNetCore.Mvc.RazorPages;
using YellowApp.Services;

namespace YellowApp.Pages;

public class IndexModel : PageModel
{
    public string PodName { get; }

    public IndexModel(PodIdentityService identity)
    {
        PodName = identity.Name;
    }

    public void OnGet()
    {
    }
}
