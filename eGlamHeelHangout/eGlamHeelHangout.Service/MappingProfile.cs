using AutoMapper;
using eGlamHeelHangout.Service.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AutoMapper;
using eGlamHeelHangout.Model.Requests;
namespace eGlamHeelHangout.Service
{
  public class MappingProfile:Profile
  {

    public MappingProfile()
    {
      CreateMap<Model.Requests.UsersInsertRequest, Database.User>();
      CreateMap<Model.Requests.UserUpdateRequest, Database.User>();
      CreateMap<Model.Requests.ProductsInsertRequest, Database.Product>();
      CreateMap<Model.Requests.ProductsUpdateRequest, Database.Product>().ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
      CreateMap<Database.Category, Model.Categories>();
      CreateMap<Database.Product, Model.Products>();
      CreateMap<Database.User, Model.Users>();
      CreateMap<Database.UsersRole, Model.UsersRoles>();
      CreateMap<Database.Role, Model.Roles>();
    }
  }
 
}
