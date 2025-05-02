using eGlamHeelHangout.Model;
using eGlamHeelHangout.Service.Database;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using System.Net;

namespace eGlamHeelHangout.Filters
{
  public class ErrorFilter:ExceptionFilterAttribute
  {
    public override void OnException(ExceptionContext context)
    {
      if (context.Exception is UserException) //dakle ako je u pitanju greska koju je prouzrokovao korisnik
      {
        context.ModelState.AddModelError("userError", context.Exception.Message); //prikazat cemo originalni error
        context.HttpContext.Response.StatusCode = (int)HttpStatusCode.BadRequest; 
      }
      else
      {
        context.ModelState.AddModelError("ERROR", "Server side error"); // u suprotnom je side server exception
        context.HttpContext.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
      }
      var list = context.ModelState.Where(x => x.Value.Errors.Count() > 0).ToDictionary(x => x.Key, y => y.Value.Errors.Select(z => z.ErrorMessage));
      context.Result = new JsonResult(new { errors=list});
    }
  }
}
