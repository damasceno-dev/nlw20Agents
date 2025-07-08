using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using server.Application.UseCases.Rooms.GetAll;
using server.Communication.Responses;

namespace server.API.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class RoomsController : ControllerBase
    {
        [HttpGet]
        [Route("getAll")]
        [ProducesResponseType(typeof(List<ResponseRoomJson>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAll([FromServices] RoomGetAllUseCase roomGetAllUseCase)
        {
            var response = await roomGetAllUseCase.Execute();
            return Ok(response);
        }
    }
}
