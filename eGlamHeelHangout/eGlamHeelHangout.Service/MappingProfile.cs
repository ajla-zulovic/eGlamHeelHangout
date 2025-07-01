using AutoMapper;
using eGlamHeelHangout.Service.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AutoMapper;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Model;
namespace eGlamHeelHangout.Service
{
  public class MappingProfile:Profile
  {

    public MappingProfile()
        {

            // USERS
            CreateMap<UsersInsertRequest, User>()
                .ForMember(dest => dest.UserId, opt => opt.Ignore())
                .ForMember(dest => dest.PasswordHash, opt => opt.Ignore())
                .ForMember(dest => dest.PasswordSalt, opt => opt.Ignore())
                .ForMember(dest => dest.DateCreated, opt => opt.Ignore())
                .ForMember(dest => dest.UsersRoles, opt => opt.Ignore())
                .ForMember(dest => dest.Favorites, opt => opt.Ignore())
                .ForMember(dest => dest.GiveawayParticipants, opt => opt.Ignore())
                .ForMember(dest => dest.Notifications, opt => opt.Ignore())
                .ForMember(dest => dest.Orders, opt => opt.Ignore())
                .ForMember(dest => dest.Reviews, opt => opt.Ignore());

            //NOTIFICATION
            CreateMap<Notification, NotificationDTO>()
            .ForMember(dest => dest.ProductName,
                opt => opt.MapFrom(src => src.Product != null ? src.Product.Name : string.Empty))
            .ForMember(dest => dest.GiveawayTitle,
                opt => opt.MapFrom(src => src.Giveaway != null ? src.Giveaway.Title : string.Empty));



            CreateMap<UserUpdateRequest, User>()
                .ForMember(dest => dest.UserId, opt => opt.Ignore())
                .ForMember(dest => dest.Username, opt => opt.Ignore())
                .ForMember(dest => dest.PasswordHash, opt => opt.Ignore())
                .ForMember(dest => dest.PasswordSalt, opt => opt.Ignore())
                .ForMember(dest => dest.DateCreated, opt => opt.Ignore())
                .ForMember(dest => dest.UsersRoles, opt => opt.Ignore())
                .ForMember(dest => dest.Favorites, opt => opt.Ignore())
                .ForMember(dest => dest.GiveawayParticipants, opt => opt.Ignore())
                .ForMember(dest => dest.Notifications, opt => opt.Ignore())
                .ForMember(dest => dest.Orders, opt => opt.Ignore())
                .ForMember(dest => dest.Reviews, opt => opt.Ignore());

            CreateMap<User, Users>();

            // PRODUCTS
            CreateMap<ProductsInsertRequest, Product>()
                .ForMember(dest => dest.ProductId, opt => opt.Ignore())
                .ForMember(dest => dest.DateAdded, opt => opt.Ignore())
                .ForMember(dest => dest.StateMachine, opt => opt.Ignore())
                .ForMember(dest => dest.Category, opt => opt.Ignore())
                .ForMember(dest => dest.Discounts, opt => opt.Ignore())
                .ForMember(dest => dest.ProductSizes, opt => opt.Ignore())
                .ForMember(dest => dest.Favorites, opt => opt.Ignore())
                .ForMember(dest => dest.OrderItems, opt => opt.Ignore())
                .ForMember(dest => dest.Reviews, opt => opt.Ignore());

            CreateMap<ProductsUpdateRequest, Product>()
                .ForMember(dest => dest.ProductId, opt => opt.Ignore())
                .ForMember(dest => dest.CategoryId, opt => opt.Ignore())
                .ForMember(dest => dest.Color, opt => opt.Ignore())
                .ForMember(dest => dest.Material, opt => opt.Ignore())
                .ForMember(dest => dest.HeelHeight, opt => opt.Ignore())
                .ForMember(dest => dest.DateAdded, opt => opt.Ignore())
                .ForMember(dest => dest.StateMachine, opt => opt.Ignore())
                .ForMember(dest => dest.Category, opt => opt.Ignore())
                .ForMember(dest => dest.Discounts, opt => opt.Ignore())
                .ForMember(dest => dest.ProductSizes, opt => opt.Ignore())
                .ForMember(dest => dest.Favorites, opt => opt.Ignore())
                .ForMember(dest => dest.OrderItems, opt => opt.Ignore())
                .ForMember(dest => dest.Reviews, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));

            CreateMap<Product, Products>()
                .ForMember(dest => dest.CreatedAt, opt => opt.Ignore())
                .ForMember(dest => dest.UpdatedAt, opt => opt.Ignore())
                .ForMember(dest => dest.IsActive, opt => opt.Ignore())
                .ForMember(dest => dest.Sizes, opt => opt.Ignore())
                .ForMember(dest => dest.IsFavorite, opt => opt.Ignore());

            // CATEGORY
            CreateMap<Category, Categories>();

            // ROLES
            CreateMap<Role, Roles>();
            CreateMap<UsersRole, UsersRoles>();

            // GIVEAWAYS
            CreateMap<Giveaway, Giveaways>().ForMember(dest => dest.WinnerName, opt => opt.Ignore())
                .ForMember(dest => dest.GiveawayProductImage, opt =>
                 opt.MapFrom(src => Convert.ToBase64String(src.GiveawayProductImage))); ; 
            CreateMap<GiveawayParticipant, GiveawayParticipants>();
            CreateMap<GiveawayInsertRequest, Giveaway>()
                .ForMember(dest => dest.GiveawayId, opt => opt.Ignore())
                .ForMember(dest => dest.IsClosed, opt => opt.Ignore())
                .ForMember(dest => dest.GiveawayParticipants, opt => opt.Ignore())
                .ForMember(dest => dest.GiveawayProductImage, opt => opt.Ignore());


            // REVIEWS
            CreateMap<ReviewInsertRequest, Review>()
                .ForMember(dest => dest.ReviewId, opt => opt.Ignore())
                .ForMember(dest => dest.UserId, opt => opt.Ignore())
                .ForMember(dest => dest.Comment, opt => opt.Ignore())
                .ForMember(dest => dest.ReviewDate, opt => opt.Ignore())
                .ForMember(dest => dest.Product, opt => opt.Ignore())
                .ForMember(dest => dest.User, opt => opt.Ignore());

            // PRODUCT SIZES
            CreateMap<ProductSize, ProductSizes>();

            //ORDER I ORDERITEM
            CreateMap<OrderInsertRequest, Order>()
    .ForMember(dest => dest.OrderId, opt => opt.Ignore())
    .ForMember(dest => dest.User, opt => opt.Ignore())
    .ForMember(dest => dest.OrderItems, opt => opt.Ignore());

            CreateMap<OrderItemInsertRequest, OrderItem>()
    .ForMember(dest => dest.OrderItemId, opt => opt.Ignore())
    .ForMember(dest => dest.OrderId, opt => opt.Ignore()) 
    .ForMember(dest => dest.ProductSize, opt => opt.Ignore())
    .ForMember(dest => dest.Order, opt => opt.Ignore())
    .ForMember(dest => dest.Product, opt => opt.Ignore());

            CreateMap<OrderItem, OrderItemDTO>()
                .ForMember(dest => dest.ProductName,
           opt => opt.MapFrom(src => src.Product != null ? src.Product.Name : null))

                .ForMember(dest => dest.Size, opt => opt.MapFrom(src => src.ProductSize.Size))
                .ForMember(dest => dest.ProductSizeId, opt => opt.MapFrom(src => src.ProductSizeId));

            CreateMap<Order, OrderDTO>()
                .ForMember(dest => dest.Username, opt => opt.MapFrom(src => src.User != null ? src.User.Username : string.Empty))
                .ForMember(dest => dest.Items, opt => opt.MapFrom(src => src.OrderItems));




        }
    }
 
}
