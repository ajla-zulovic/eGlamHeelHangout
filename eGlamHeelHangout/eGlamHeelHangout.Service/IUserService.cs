using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service
{
  public interface IUserService : ICRUDService<Model.Users,Model.SearchObjects.UserSearchObjects,Model.Requests.UsersInsertRequest,Model.Requests.UserUpdateRequest>
  {
    public Task<Model.Users> Login(string username, string password); //ovo ce biti metoda za login korisnik gdje prosljeđujemo dva parametra, username i password 
    public Task<Model.Users> GetCurrentUser(string username);
    public int GetCurrentUserId(string username);
    Task ChangePassword(ChangePasswordRequest request);

    Task<bool> PromoteToAdmin(int userId);
    Task<bool> Delete(int id, int currentUserId);
     Task<bool> DemoteFromAdmin(int userId, int currentUserId);
    }
}
