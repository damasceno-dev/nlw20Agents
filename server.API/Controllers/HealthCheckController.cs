using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace server.API.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class HealthCheckController : ControllerBase
    {
        [HttpGet]
        public ActionResult<string> Get()
        {
            return "Healthy";
        }
    }
}
