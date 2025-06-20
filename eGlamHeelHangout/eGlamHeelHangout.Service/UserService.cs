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
      byte[] src = Convert.FromBase64String(salt);
      byte[] bytes = Encoding.Unicode.GetBytes(password);
      byte[] dst = new byte[src.Length + bytes.Length];

      System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
      System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

      HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
      byte[] inArray = algorithm.ComputeHash(dst);
      return Convert.ToBase64String(inArray);
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


    }
}
