using AutoMapper;
using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Model.SearchObjects;
using eGlamHeelHangout.Service.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Conventions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Markup;

namespace eGlamHeelHangout.Service
{
  public class UserService:BaseCRUDService<Model.Users,Database.User,UserSearchObjects,UsersInsertRequest,UserUpdateRequest>, IUserService
  {
    _200199Context _context;
    public IMapper _mapper { get; set; }
    public UserService(_200199Context context,IMapper mapper):base (context,mapper)
    {
      _context = context;
      _mapper = mapper;
    }

   
    public static string GenerateSalt()
    {
      RNGCryptoServiceProvider provider = new RNGCryptoServiceProvider();
      var byteArray = new byte[16];
      provider.GetBytes(byteArray);

      return Convert.ToBase64String(byteArray);
    }

    public static string GenerateHash(string salt, string password)
    {
            //byte[] src = Convert.FromBase64String(salt);
            //byte[] bytes = Encoding.Unicode.GetBytes(password);
            //byte[] dst = new byte[src.Length + bytes.Length];

            //System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
            //System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

            //HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
            //byte[] inArray = algorithm.ComputeHash(dst);
            //return Convert.ToBase64String(inArray);
            var saltBytes = Convert.FromBase64String(salt);
            using var hmac = new HMACSHA512(saltBytes);
            var passwordBytes = Encoding.UTF8.GetBytes(password);
            var hash = hmac.ComputeHash(passwordBytes);
            return Convert.ToBase64String(hash);
        }

 

    public override async Task BeforeInsert(User entity, UsersInsertRequest insert)
    {
      entity.PasswordSalt = GenerateSalt();
      entity.PasswordHash = GenerateHash(entity.PasswordSalt, insert.Password);
    }

    public override IQueryable<User> AddInclude(IQueryable<User> query, UserSearchObjects? search = null)
    {
      if (search?.IsRolseIncluded == true)
      {
        query = query.Include("UsersRoles.Role");
      }
      return base.AddInclude(query, search);
    }

    public async Task<Model.Users> Login(string username, string password)
    {
      var entity = await _context.Users.Include("UsersRoles.Role").FirstOrDefaultAsync(x => x.Username == username);

      if (entity == null) // ako nemamo pronađenog korisnika s odgovarajucim username-om onda vrati null, ne postoji, ovaj uslov je obavezan jer bi nam u suprotnom pala aplikacija 
      {
        return null;
      }

      var hash = GenerateHash(entity.PasswordSalt, password);

      if (hash != entity.PasswordHash) //ako hash s kojim se prijavljujemo ne odgovara onom u nasoj bazi, onda : 
      {
        return null; //korisnik ne postoji, vracamo null
      }

      return _mapper.Map<Model.Users>(entity); // u suprotno vracamo korisnika kojeg mapiramo u nas model Users
    }

    public async Task<Model.Users> GetCurrentUser(string username)
    {
            var user = await _context.Users
                .Include(u => u.UsersRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Username == username);

            return _mapper.Map<Model.Users>(user);
    }
        public override async Task<Users> Insert(UsersInsertRequest insert)
        {
            if (_context.Users.Any(u => u.Username == insert.Username))
                throw new Exception("Username already exists.");

   
            var result = await base.Insert(insert);
            await _context.SaveChangesAsync(); 

            
            var userRole = await _context.Roles.FirstOrDefaultAsync(r => r.RoleName == "User");
            if (userRole == null)
                throw new Exception("Role 'User' not found.");

            Console.WriteLine($"Dodajem rolu {userRole.RoleId} korisniku {result.UserId}");

            var newUserRole = new UsersRole
            {
                UserId = result.UserId,
                RoleId = userRole.RoleId,
                DateChange = DateTime.Now
            };

            _context.UsersRoles.Add(newUserRole);

          
            try
            {
                await _context.SaveChangesAsync(); 
            }
            catch (Exception ex)
            {
                Console.WriteLine("ERROR while saving UsersRole: " + ex.InnerException?.Message ?? ex.Message);
                throw;
            }
            return result;

        }

        public int GetCurrentUserId(string username)
        {
            var user = _context.Users.FirstOrDefault(u => u.Username == username);
            return user?.UserId ?? 0;
        }

        public async Task ChangePassword(ChangePasswordRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Username))
                throw new Exception("Username is required.");

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == request.Username);

            if (user == null)
                throw new Exception("User not found.");

            if (request.NewPassword != request.ConfirmNewPassword)
                throw new Exception("New password values don't match.");

            string hashOfNewWithOldSalt = GenerateHash(user.PasswordSalt, request.NewPassword);
            if (hashOfNewWithOldSalt == user.PasswordHash)
                throw new Exception("New password can't be the same as the old one.");

            string hashOfOldPassword = GenerateHash(user.PasswordSalt, request.CurrentPassword);
            if (hashOfOldPassword != user.PasswordHash)
                throw new Exception("Current password is incorrect.");

            user.PasswordSalt = GenerateSalt();
            user.PasswordHash = GenerateHash(user.PasswordSalt, request.NewPassword);

            await _context.SaveChangesAsync();
        }

        public override IQueryable<Database.User> AddFilter(IQueryable<Database.User> query, UserSearchObjects? search = null)
        {
            if (!string.IsNullOrWhiteSpace(search?.SearchText))
            {
                var searchText = search.SearchText.ToLower();

                query = query.Where(x =>
                    x.FirstName.ToLower().Contains(searchText) ||
                    x.LastName.ToLower().Contains(searchText) ||
                    x.Email.ToLower().Contains(searchText));
            }

            return base.AddFilter(query, search);
        }
        public override async Task<PagedResult<Model.Users>> Get(UserSearchObjects? search = null)
        {
            var result = await base.Get(search);

            var userIds = result.Result.Select(x => x.UserId).ToList();

            var dbUsers = await _context.Users
                .Include(u => u.UsersRoles)
                .ThenInclude(ur => ur.Role)
                .Where(u => userIds.Contains(u.UserId))
                .ToListAsync();

            foreach (var user in result.Result)
            {
                var dbUser = dbUsers.FirstOrDefault(u => u.UserId == user.UserId);

                if (dbUser != null)
                {
                    user.RoleName = string.Join(", ",
                        dbUser.UsersRoles.Select(ur => ur.Role.RoleName));
                }
            }

            return result;
        }

        public async Task<bool> PromoteToAdmin(int userId)
        {
            var adminRole = await _context.Roles.FirstOrDefaultAsync(r => r.RoleName == "Admin");
            if (adminRole == null)
                throw new Exception("Admin role not found.");

            var hasRole = await _context.UsersRoles.AnyAsync(x => x.UserId == userId && x.RoleId == adminRole.RoleId);
            if (hasRole)
                return false;

            _context.UsersRoles.Add(new UsersRole
            {
                UserId = userId,
                RoleId = adminRole.RoleId,
                DateChange = DateTime.Now
            });

            await _context.SaveChangesAsync();
            return true;
        }
        public async Task<bool> Delete(int id, int currentUserId)
        {
            if (id == currentUserId)
                throw new Exception("You cannot delete yourself.");

            return await base.Delete(id);
        }

        public async Task<bool> DemoteFromAdmin(int userId, int currentUserId)
        {
            if (userId == currentUserId)
                throw new Exception("You cannot demote yourself.");

            var adminRole = await _context.Roles.FirstOrDefaultAsync(r => r.RoleName == "Admin");
            if (adminRole == null)
                throw new Exception("Admin role not found.");

            var userRole = await _context.UsersRoles
                .FirstOrDefaultAsync(x => x.UserId == userId && x.RoleId == adminRole.RoleId);

            if (userRole == null)
                return false; 

            
            _context.UsersRoles.Remove(userRole);
            await _context.SaveChangesAsync();

            bool hasOtherRoles = await _context.UsersRoles.AnyAsync(x => x.UserId == userId);

            if (!hasOtherRoles)
            {
                var userDefaultRole = await _context.Roles.FirstOrDefaultAsync(r => r.RoleName == "User");
                if (userDefaultRole == null)
                    throw new Exception("Role 'User' not found.");

                _context.UsersRoles.Add(new UsersRole
                {
                    UserId = userId,
                    RoleId = userDefaultRole.RoleId,
                    DateChange = DateTime.Now
                });

                await _context.SaveChangesAsync();
            }

            return true;
        }


    }
}
