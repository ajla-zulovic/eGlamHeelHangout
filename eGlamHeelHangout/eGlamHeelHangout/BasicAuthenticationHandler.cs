using eGlamHeelHangout.Service;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text;
using System.Text.Encodings.Web;

namespace eGlamHeelHangout
{
  public class BasicAuthenticationHandler : AuthenticationHandler<AuthenticationSchemeOptions>
  {
    IUserService _userService;
    public BasicAuthenticationHandler(IUserService userService,IOptionsMonitor<AuthenticationSchemeOptions> options, ILoggerFactory logger, UrlEncoder encoder, ISystemClock clock) : base(options, logger, encoder, clock)
    {
      _userService = userService; 
    }

    protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
    {
      if (!Request.Headers.ContainsKey("Authorization"))
      {
        return AuthenticateResult.Fail("Missing header");
      }

      var authHeader = AuthenticationHeaderValue.Parse(Request.Headers["Authorization"]);
      var credentialBytes = Convert.FromBase64String(authHeader.Parameter);
      var credentials = Encoding.UTF8.GetString(credentialBytes).Split(':');
      var username = credentials[0];
      var password = credentials[1];
      var user = await _userService.Login(username, password);
      if (user == null)
      {
        return AuthenticateResult.Fail("Incorecct username or password!");
      }
      else {
        //ako je korisnik uspjesno autentificiran nakon login metode, onda radimo sljedece:
        // claimovi -> tvrdnje / lista osobina o korisniku 
        var claims = new List<Claim>() {
          //new Claim(ClaimTypes.Name,user.FirstName),
          new Claim(ClaimTypes.Name, user.Username), 
          new Claim(ClaimTypes.NameIdentifier, user.UserId.ToString()),
         new Claim("id", user.UserId.ToString()) //privremeno
        };

        // ovo za ulogu koristimo da bismo mogli kasnije nad controllerima određivati koja uloga ima pristupe određenim metodama npr insert proizvoda ne moze raditi nikako krisnik nego admin 
        foreach (var role in user.UsersRoles)
        {
          claims.Add(new Claim(ClaimTypes.Role, role.Role.RoleName));
        }

        var identity = new ClaimsIdentity(claims,Scheme.Name);
        var principle = new ClaimsPrincipal(identity);
        var ticket = new AuthenticationTicket(principle, Scheme.Name);
        return AuthenticateResult.Success(ticket);


      }
    }
  }
}
