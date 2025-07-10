using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using server.Application.UseCases.Rooms.Create;
using server.Application.UseCases.Rooms.GetAll;
using server.Application.UseCases.Rooms.GetById;
using server.Communication.Requests;
using server.Communication.Responses;

namespace server.API.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class RoomsController : ControllerBase
    {
        [HttpGet]
        [Route("list")]
        [ProducesResponseType(typeof(List<ResponseRoomJson>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAll([FromServices] RoomGetAllUseCase roomGetAllUseCase)
        {
            var response = await roomGetAllUseCase.Execute();
            return Ok(response);
        }
        [HttpGet]
        [Route("{roomId:guid}/getById")]
        [ProducesResponseType(typeof(ResponseRoomJson), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetById([FromServices] RoomGetByIdUseCase roomGetByIdUseCase, [FromRoute]Guid roomId)
        {
            var response = await roomGetByIdUseCase.Execute(roomId);
            return Ok(response);
        }
        
        [HttpPost]
        [Route("create")]
        [ProducesResponseType(typeof(ResponseRoomJson), StatusCodes.Status201Created)]
        public async Task<IActionResult> Create([FromServices]RoomCreateUseCase roomCreateUseCase, [FromBody]RequestRoomCreateJson request)
        {
            var response = await roomCreateUseCase.Execute(request);
            return Created(string.Empty, response);
        }
        
    }
}
