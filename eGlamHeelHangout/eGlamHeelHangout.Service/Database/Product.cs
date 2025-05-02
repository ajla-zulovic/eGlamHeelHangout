using System;
using System.Collections.Generic;

namespace eGlamHeelHangout.Service.Database
{
    public partial class Product
    {
        public Product()
        {
            Discounts = new HashSet<Discount>();
            Favorites = new HashSet<Favorite>();
            Giveaways = new HashSet<Giveaway>();
            OrderItems = new HashSet<OrderItem>();
            Reviews = new HashSet<Review>();
            ProductSizes = new HashSet<ProductSize>();
    }

        public int ProductId { get; set; }
        public string Name { get; set; } = null!;
        public int CategoryId { get; set; }
        public string Color { get; set; } = null!;
        public string Material { get; set; } = null!;
        public decimal HeelHeight { get; set; }
        public decimal Price { get; set; }
        public string? ImageUrl { get; set; }
        public string? Description { get; set; }
        public DateTime? DateAdded { get; set; }
        public string? StateMachine { get; set; }

        public virtual Category Category { get; set; } = null!;
        public virtual ICollection<Discount> Discounts { get; set; }
       public virtual ICollection<ProductSize> ProductSizes { get; set; }
         public virtual ICollection<Favorite> Favorites { get; set; }
        public virtual ICollection<Giveaway> Giveaways { get; set; }
        public virtual ICollection<OrderItem> OrderItems { get; set; }
        public virtual ICollection<Review> Reviews { get; set; }
    }
}
