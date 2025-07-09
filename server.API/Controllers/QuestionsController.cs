using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using server.Application.UseCases.Question.Create;
using server.Application.UseCases.Question.GetFromRoom;
using server.Communication.Requests;
using server.Communication.Responses;

namespace server.API.Controllers
{
    [Route("[controller]/{roomId:guid}")]
    [ApiController]
    public class QuestionsController : ControllerBase
    {
        
        [HttpGet]
        [Route("list")]
        [ProducesResponseType(typeof(List<ResponseQuestionJson>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetRoomQuestions([FromServices] QuestionsGetFromRoomUseCase questionsGetFromRoomUseCase, [FromRoute] Guid roomId)
        {
            var response = await questionsGetFromRoomUseCase.Execute(roomId);
            return Ok(response);
        }
        
        [HttpPost]
        [Route("create")]
        [ProducesResponseType(typeof(List<ResponseQuestionJson>), StatusCodes.Status201Created)]
        public async Task<IActionResult> CreateRoomQuestions([FromServices] QuestionsCreateUseCase questionsCreateUseCase, [FromBody] RequestCreateQuestionJson request, [FromRoute] Guid roomId)
        {
            var response = await questionsCreateUseCase.Execute(roomId,request);
            return Created(string.Empty, response);
        }
    }
}
