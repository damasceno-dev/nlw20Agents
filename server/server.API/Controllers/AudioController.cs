using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using server.Application.UseCases.Audio.Upload;
using server.Communication.Responses;

namespace server.API.Controllers
{
    [Route("[controller]/{roomId:guid}")]
    [ApiController]
    public class AudioController : ControllerBase
    {
        [HttpPost]
        [Route("upload")]
        [ProducesResponseType(typeof(ResponseAudioJson), StatusCodes.Status201Created)]
        [ProducesResponseType(typeof(ResponseErrorJson),StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ResponseErrorJson),StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UploadAudio(IFormFile audioFile, [FromServices] UploadAudioUseCase uploadAudioUseCase, [FromRoute] Guid roomId)
        {
            var response = await uploadAudioUseCase.Execute(audioFile, roomId);
            return Created(string.Empty, response);
        }
    }
}
