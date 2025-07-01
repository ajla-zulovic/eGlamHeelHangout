using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using eGlamHeelHangout.Service;

namespace eGlamHeelHangout.Service.Database
{
    public partial class _200199Context : DbContext
    {
        public _200199Context()
        {
        }

        public _200199Context(DbContextOptions<_200199Context> options)
            : base(options)
        {
        }
      public virtual DbSet<Category> Categories { get; set; } = null!;
      public virtual DbSet<Discount> Discounts { get; set; } = null!;
      public virtual DbSet<Favorite> Favorites { get; set; } = null!;
      public virtual DbSet<Giveaway> Giveaways { get; set; } = null!;
      public virtual DbSet<GiveawayParticipant> GiveawayParticipants { get; set; } = null!;
      public virtual DbSet<Notification> Notifications { get; set; } = null!;
      public virtual DbSet<Order> Orders { get; set; } = null!;
      public virtual DbSet<OrderItem> OrderItems { get; set; } = null!;
      public virtual DbSet<Product> Products { get; set; } = null!;
      public virtual DbSet<Review> Reviews { get; set; } = null!;
      public virtual DbSet<Role> Roles { get; set; } = null!;
      public virtual DbSet<User> Users { get; set; } = null!;
      public virtual DbSet<UsersRole> UsersRoles { get; set; } = null!;
      public virtual DbSet<ProductSize> ProductSizes { get; set; } = null!;
     public virtual DbSet<WinnerNotificationEntity> WinnerNotifications { get; set; }


        //protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        //{
        //  if (!optionsBuilder.IsConfigured)
        //  {
        //    optionsBuilder.UseSqlServer( "Server=localhost;Database=200199;User=sa;Password=QWEasd123!;TrustServerCertificate=True");

        //    //optionsBuilder.UseSqlServer("Server=localhost;Database=200199;Trusted_Connection=True;TrustServerCertificate=True;");

        //  }
        //}

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
      modelBuilder.Entity<User>(entity =>
      {
        entity.HasKey(e => e.UserId);
        entity.Property(e => e.UserId).HasColumnName("UserID");
        entity.Property(e => e.FirstName).HasMaxLength(50);
        entity.Property(e => e.LastName).HasMaxLength(50);
        entity.Property(e => e.Username).HasMaxLength(50);
        entity.Property(e => e.Email).HasMaxLength(100);
        entity.Property(e => e.PasswordHash).HasMaxLength(255);
        entity.Property(e => e.PasswordSalt).HasMaxLength(255);
        entity.Property(e => e.PhoneNumber).HasMaxLength(20);
        entity.Property(e => e.Address).HasMaxLength(255).IsRequired(false);
        entity.Property(e => e.ProfileImage).HasMaxLength(255).IsRequired(false);
        entity.Property(e => e.DateCreated).HasColumnType("datetime").IsRequired(false);
        entity.HasIndex(e => e.Username).IsUnique();
      });

      modelBuilder.Entity<Role>(entity =>
      {
        entity.HasKey(e => e.RoleId);
        entity.Property(e => e.RoleId).HasColumnName("RoleID");
        entity.Property(e => e.RoleName).HasMaxLength(20);
      });

      modelBuilder.Entity<Category>(entity =>
      {
        entity.HasIndex(e => e.CategoryName)
            .IsUnique();

        entity.Property(e => e.CategoryId).HasColumnName("CategoryID");
        entity.Property(e => e.CategoryName).HasMaxLength(100);
      });

      modelBuilder.Entity<Discount>(entity =>
      {
        entity.Property(e => e.DiscountId).HasColumnName("DiscountID");
        entity.Property(e => e.DiscountPercentage).HasColumnType("decimal(5, 2)");
        entity.Property(e => e.EndDate).HasColumnType("datetime");
        entity.Property(e => e.ProductId).HasColumnName("ProductID");
        entity.Property(e => e.StartDate).HasColumnType("datetime");

        entity.HasOne(d => d.Product)
            .WithMany(p => p.Discounts)
            .HasForeignKey(d => d.ProductId)
            .HasConstraintName("FK_Discounts_Products");
      });

      modelBuilder.Entity<Favorite>(entity =>
      {
        entity.Property(e => e.FavoriteId).HasColumnName("FavoriteID");
        entity.Property(e => e.DateAdded)
            .HasColumnType("datetime")
            .HasDefaultValueSql("(getdate())");
        entity.Property(e => e.ProductId).HasColumnName("ProductID");
        entity.Property(e => e.UserId).HasColumnName("UserID");

        entity.HasOne(d => d.Product)
            .WithMany(p => p.Favorites)
            .HasForeignKey(d => d.ProductId)
            .HasConstraintName("FK_Favorites_Products");

        entity.HasOne(d => d.User)
            .WithMany(p => p.Favorites)
            .HasForeignKey(d => d.UserId)
            .HasConstraintName("FK_Favorites_Users");
      });

      modelBuilder.Entity<Giveaway>(entity =>
      {
          entity.Property(e => e.GiveawayId).HasColumnName("GiveawayID");
          entity.Property(e => e.EndDate).HasColumnType("datetime");

          entity.Property(e => e.Title).HasMaxLength(100);
          entity.Property(e => e.Color).HasMaxLength(50);
          entity.Property(e => e.HeelHeight).HasPrecision(18, 2);


      });

      modelBuilder.Entity<GiveawayParticipant>(entity =>
      {
          entity.HasKey(e => e.ParticipantId);

          entity.Property(e => e.ParticipantId).HasColumnName("ParticipantID");
          entity.Property(e => e.GiveawayId).HasColumnName("GiveawayID");
          entity.Property(e => e.Size).HasMaxLength(10);
          entity.Property(e => e.UserId).HasColumnName("UserID");

          entity.HasOne(d => d.Giveaway)
              .WithMany(p => p.GiveawayParticipants)
              .HasForeignKey(d => d.GiveawayId)
              .HasConstraintName("FK_GiveawayParticipants_Giveaways");

          entity.HasOne(d => d.User)
              .WithMany(p => p.GiveawayParticipants)
              .HasForeignKey(d => d.UserId)
              .HasConstraintName("FK_GiveawayParticipants_Users");
      });

      modelBuilder.Entity<Notification>(entity =>
      {
        entity.Property(e => e.NotificationId).HasColumnName("NotificationID");
        entity.Property(e => e.DateSent)
            .HasColumnType("datetime")
            .HasDefaultValueSql("(getdate())");
        entity.Property(e => e.IsRead).HasDefaultValueSql("((0))");
        entity.Property(e => e.Message).HasMaxLength(255);
        entity.Property(e => e.NotificationType).HasMaxLength(50);
        entity.Property(e => e.UserId).HasColumnName("UserID");

        entity.HasOne(d => d.User)
            .WithMany(p => p.Notifications)
            .HasForeignKey(d => d.UserId)
            .HasConstraintName("FK_Notifications_Users");

        entity.HasOne(d => d.Giveaway)
            .WithMany() 
            .HasForeignKey(d => d.GiveawayId)
            .HasConstraintName("FK_Notifications_Giveaways");

        entity.HasOne(d => d.Product)
              .WithMany() 
              .HasForeignKey(d => d.ProductId)
              .HasConstraintName("FK_Notifications_Products");
      });

      modelBuilder.Entity<Order>(entity =>
      {
        entity.Property(e => e.OrderId).HasColumnName("OrderID");
        entity.Property(e => e.OrderDate)
            .HasColumnType("datetime")
            .HasDefaultValueSql("(getdate())");
        entity.Property(e => e.OrderStatus).HasMaxLength(50);
        entity.Property(e => e.PaymentMethod).HasMaxLength(50);
        entity.Property(e => e.TotalPrice).HasColumnType("decimal(10, 2)");
        entity.Property(e => e.UserId).HasColumnName("UserID");

        entity.HasOne(d => d.User)
            .WithMany(p => p.Orders)
            .HasForeignKey(d => d.UserId)
            .HasConstraintName("FK_Orders_Users");
      });

      modelBuilder.Entity<OrderItem>(entity =>
      {
        entity.Property(e => e.OrderItemId).HasColumnName("OrderItemID");
        entity.Property(e => e.OrderId).HasColumnName("OrderID");
        entity.Property(e => e.PricePerUnit).HasColumnType("decimal(10, 2)");
        entity.Property(e => e.ProductId).HasColumnName("ProductID");

        entity.HasOne(d => d.Order)
            .WithMany(p => p.OrderItems)
            .HasForeignKey(d => d.OrderId)
            .HasConstraintName("FK_OrderItems_Orders");

        entity.HasOne(d => d.Product)
            .WithMany(p => p.OrderItems)
            .HasForeignKey(d => d.ProductId)
            .HasConstraintName("FK_OrderItems_Products");
      });

      modelBuilder.Entity<Product>(entity =>
      {
        entity.HasKey(e => e.ProductId); 

        entity.Property(e => e.ProductId).HasColumnName("ProductID");
        entity.Property(e => e.CategoryId).HasColumnName("CategoryID");
        entity.Property(e => e.Color).HasMaxLength(50);
        entity.Property(e => e.DateAdded)
            .HasColumnType("datetime")
            .HasDefaultValueSql("(getdate())");
        entity.Property(e => e.HeelHeight).HasColumnType("decimal(5, 2)");
        entity.Property(e => e.Price)
         .HasPrecision(10, 2);
      });

      modelBuilder.Entity<UsersRole>(entity =>
      {
        entity.HasKey(e => new { e.UserId, e.RoleId });

        entity.Property(e => e.UserId).HasColumnName("UserID");
        entity.Property(e => e.RoleId).HasColumnName("RoleID");

        entity.HasOne(d => d.User)
            .WithMany(p => p.UsersRoles)
            .HasForeignKey(d => d.UserId)
            .HasConstraintName("FK_UsersRoles_Users");

        entity.HasOne(d => d.Role)
            .WithMany(p => p.UsersRoles)
            .HasForeignKey(d => d.RoleId)
            .HasConstraintName("FK_UsersRoles_Roles");
      });


      modelBuilder.Entity<ProductSize>(entity =>
            {
              entity.HasKey(e => e.ProductSizeId); 

              entity.Property(e => e.ProductSizeId)
                  .HasColumnName("ProductSizeID");

              entity.Property(e => e.ProductId)
                  .HasColumnName("ProductID");

              
              entity.Property(e => e.Size)
                  .HasMaxLength(10)
                  .IsRequired();

              entity.Property(e => e.StockQuantity)
                  .IsRequired()
                  .HasDefaultValue(0);

              
              entity.HasOne(d => d.Product)
                  .WithMany(p => p.ProductSizes)
                  .HasForeignKey(d => d.ProductId)
                  .OnDelete(DeleteBehavior.Cascade)
                  .HasConstraintName("FK_ProductSizes_Products");
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
