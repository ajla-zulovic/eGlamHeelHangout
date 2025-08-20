using AutoMapper;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Model;
using eGlamHeelHangout.Service.Database;
using eGlamHeelHangout.Service.ProductStateMachine;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EasyNetQ;
using eGlamHeelHangout.Service.SignalR;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Configuration;

namespace eGlamHeelHangout.Service
{
    public class GiveawayService:BaseCRUDService<Model.Giveaways,Database.Giveaway,Model.SearchObjects.GiveawaySearchObject,Model.Requests.GiveawayInsertRequest,object>,IGiveawayService
    {
        public BaseState _baseState { get; set; }
        private readonly IConfiguration _config;
        private readonly IHubContext<GiveawayHub> _hubContext;
        public GiveawayService(_200199Context context, IMapper mapper, BaseState baseState, IHubContext<GiveawayHub> hubContext, IConfiguration config) : base(context, mapper)
        {
            _baseState = baseState;
            _hubContext = hubContext;
            _config = config;
        }

        public async Task<List<Giveaways>> GetActive()
        {
            var list = await _context.Giveaways
                .Where(g => g.EndDate > DateTime.Now && !g.IsClosed)
                .ToListAsync();

            return _mapper.Map<List<Giveaways>>(list);
        }

        public async Task<GiveawayParticipants> AddParticipant(string username, GiveawayParticipantInsertRequest request)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == username);
            if (user == null)
                throw new Exception("User not found");

        
            var existingEntry = await _context.GiveawayParticipants
                .FirstOrDefaultAsync(p => p.GiveawayId == request.GiveawayId && p.UserId == user.UserId);

            if (existingEntry != null)
                throw new Exception("User has already participated in this giveaway.");

            
            if (request.Size < 36 || request.Size > 46)
                throw new Exception("Size must be between 36 and 46.");

            
            var entity = new GiveawayParticipant
            {
                GiveawayId = request.GiveawayId,
                Size = request.Size,
                UserId = user.UserId,
                Address = request.Address,
                City = request.City,
                PostalCode = request.PostalCode,
                IsWinner = false
            };

            _context.GiveawayParticipants.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<GiveawayParticipants>(entity);
        }

        public async Task<GiveawayParticipants?> PickWinner(int giveawayId)
        {
            var existingWinner = await _context.GiveawayParticipants
                .Where(e => e.GiveawayId == giveawayId && e.IsWinner)
                .FirstOrDefaultAsync();

            if (existingWinner != null)
                throw new Exception("Winner already picked for this giveaway.");

            var entries = await _context.GiveawayParticipants
                .Where(e => e.GiveawayId == giveawayId)
                .ToListAsync();

            if (!entries.Any())
                throw new Exception("There are no participants, not able to generate a winner.");

            var giveaway = await _context.Giveaways.FindAsync(giveawayId);

            if (giveaway.EndDate > DateTime.Now)
                throw new Exception("Giveaway is still active. You can pick a winner only after the giveaway ends.");

            var winner = entries[new Random().Next(entries.Count)];
            winner.IsWinner = true;
            giveaway.IsClosed = true;

            await _context.SaveChangesAsync();

            try
            {
                await NotifyWinner(giveawayId, winner.UserId);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to send winner notification: {ex.Message}");
            }

            return _mapper.Map<GiveawayParticipants>(winner);
        }
        //overridana metoda inserta zbog slanja notif :
        public override async Task<Model.Giveaways> Insert(GiveawayInsertRequest insert)
        {
            if (insert.EndDate <= DateTime.Now)
                throw new Exception("End date must be in the future.");

            var entity = _mapper.Map<Database.Giveaway>(insert);

            if (!string.IsNullOrWhiteSpace(insert.GiveawayProductImage))
            {
                var base64 = insert.GiveawayProductImage;
                if (base64.Contains(",")) base64 = base64.Split(',')[1];
                entity.GiveawayProductImage = Convert.FromBase64String(base64);
            }

            _context.Giveaways.Add(entity);
            await _context.SaveChangesAsync();

            var users = await _context.Users
            .Where(u => u.UsersRoles.Any(ur => ur.Role.RoleName == "User"))
            .ToListAsync();

            var notifications = new List<Notification>();

            foreach (var user in users)
            {
                var notif = new Notification
                {
                    UserId = user.UserId,
                    Message = $"New giveaway '{entity.Title}' has started! Join now!",
                    NotificationType = "NewGiveaway",
                    GiveawayId = entity.GiveawayId,
                    IsRead = false,
                    DateSent = DateTime.Now
                };
                notifications.Add(notif);
                _context.Notifications.Add(notif);
            }

            await _context.SaveChangesAsync();

            // RABBITMQ
            try
            {
                var rabbitHost = _config["RabbitMQ:HostName"];
                var rabbitPort = _config["RabbitMQ:Port"];
                var rabbitUser = _config["RabbitMQ:UserName"];
                var rabbitPass = _config["RabbitMQ:Password"];

                var rabbitConnection = $"host={rabbitHost};port={rabbitPort};username={rabbitUser};password={rabbitPass}";
                using var bus = RabbitHutch.CreateBus(rabbitConnection);
                await bus.PubSub.PublishAsync(new GiveawayNotificationDTO
                {
                    GiveawayId = entity.GiveawayId,
                    Title = entity.Title,
                    Color = entity.Color,
                    HeelHeight = entity.HeelHeight,
                    Description = entity.Description,
                    GiveawayProductImage = entity.GiveawayProductImage != null
                        ? Convert.ToBase64String(entity.GiveawayProductImage)
                        : null
                }, "giveaway.new");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"RabbitMQ error: {ex.Message}");
            }

            // SIGNALR
            foreach (var notif in notifications)
            {
                var user = users.FirstOrDefault(u => u.UserId == notif.UserId);
                if (user != null)
                {
                    await _hubContext.Clients.User(user.Username).SendAsync("ReceiveGiveaway", new
                    {
                        notificationId = notif.NotificationId,
                        giveawayId = entity.GiveawayId,
                        giveawayTitle = entity.Title,
                        message = notif.Message,
                        dateSent = notif.DateSent?.ToString("yyyy-MM-ddTHH:mm:ss")
                    });
                }
            }

            return _mapper.Map<Model.Giveaways>(entity);
        }

        public override async Task<PagedResult<Model.Giveaways>> Get(Model.SearchObjects.GiveawaySearchObject? search = null)
        {
            var query = _context.Giveaways
                .Include(g => g.GiveawayParticipants)
                .AsQueryable();

            var list = await query.ToListAsync();
            var mappedList = _mapper.Map<List<Model.Giveaways>>(list);

            foreach (var giveaway in mappedList)
            {
                var dbGiveaway = list.First(g => g.GiveawayId == giveaway.GiveawayId);

             
                var winner = dbGiveaway.GiveawayParticipants.FirstOrDefault(p => p.IsWinner);
                if (winner != null)
                {
                    var winnerUser = await _context.Users.FirstOrDefaultAsync(u => u.UserId == winner.UserId);
                    giveaway.WinnerName = winnerUser?.Username;
                }

                giveaway.ParticipantsCount = dbGiveaway.GiveawayParticipants.Count;
                var isFinished = dbGiveaway.EndDate <= DateTime.Now;
                var hasWinner = dbGiveaway.GiveawayParticipants.Any(p => p.IsWinner);

                giveaway.CanGenerateWinner = isFinished && !hasWinner && giveaway.ParticipantsCount > 0;
                giveaway.CanDelete = !isFinished || hasWinner || giveaway.ParticipantsCount == 0;
            }

            return new PagedResult<Model.Giveaways>
            {
                Count = mappedList.Count,
                Result = mappedList
            };
        }
        public async Task<List<Giveaways>> GetFiltered(bool? isActive)
        {
            var query = _context.Giveaways
                .Include(g => g.GiveawayParticipants)
                .AsQueryable();

            if (isActive.HasValue)
            {
                query = isActive.Value
                    ? query.Where(g => g.EndDate > DateTime.Now && !g.IsClosed)
                    : query.Where(g => g.EndDate <= DateTime.Now);
            }

            var list = await query.ToListAsync();
            var mappedList = _mapper.Map<List<Model.Giveaways>>(list);

            foreach (var giveaway in mappedList)
            {
                var dbGiveaway = list.First(g => g.GiveawayId == giveaway.GiveawayId);

                // WinnerName (postojeće)
                var winner = dbGiveaway.GiveawayParticipants.FirstOrDefault(p => p.IsWinner);
                if (winner != null)
                {
                    var winnerUser = await _context.Users.FirstOrDefaultAsync(u => u.UserId == winner.UserId);
                    giveaway.WinnerName = winnerUser?.Username;
                }

                // NOVO
                giveaway.ParticipantsCount = dbGiveaway.GiveawayParticipants.Count;
                var isFinished = dbGiveaway.EndDate <= DateTime.Now;
                var hasWinner = dbGiveaway.GiveawayParticipants.Any(p => p.IsWinner);

                giveaway.CanGenerateWinner = isFinished && !hasWinner && giveaway.ParticipantsCount > 0;
                giveaway.CanDelete = !isFinished || hasWinner || giveaway.ParticipantsCount == 0;
            }

            return mappedList;
        }


        public async Task NotifyWinner(int giveawayId, int winnerUserId)
        {
            var giveaway = await _context.Giveaways.FindAsync(giveawayId);
            var winner = await _context.Users.FindAsync(winnerUserId);

            try
            {
                var rabbitHost = _config["RabbitMQ:HostName"];
                var rabbitPort = _config["RabbitMQ:Port"];
                var rabbitUser = _config["RabbitMQ:UserName"];
                var rabbitPass = _config["RabbitMQ:Password"];

                var rabbitConnection = $"host={rabbitHost};port={rabbitPort};username={rabbitUser};password={rabbitPass}";
                using (var bus = RabbitHutch.CreateBus(rabbitConnection))
                {
                    await bus.PubSub.PublishAsync(new WinnerNotification
                    {
                        GiveawayId = giveawayId,
                        GiveawayTitle = giveaway.Title,
                        WinnerUserId = winnerUserId,
                        WinnerUsername = winner.Username,
                        NotificationDate = DateTime.Now
                    }, "winner.notification");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"RabbitMQ error: {ex.Message}");
            }

            _context.WinnerNotifications.Add(new WinnerNotificationEntity
            {
                GiveawayId = giveawayId,
                GiveawayTitle = giveaway.Title,
                WinnerUserId = winnerUserId,
                WinnerUsername = winner.Username,
                NotificationDate = DateTime.Now
            });

            await _context.SaveChangesAsync();

            if (_hubContext != null)
            {
                await _hubContext.Clients.All.SendAsync("ReceiveWinner", new
                {
                    winnerUsername = winner.Username,
                    giveawayTitle = giveaway.Title
                });
            }
        }


        public async Task<WinnerNotificationEntity?> GetLastWinnerNotification()
        {
            return await _context.WinnerNotifications
                .OrderByDescending(n => n.NotificationDate)
                .FirstOrDefaultAsync();
        }

   
        public async Task<bool> DeleteIfAllowed(int id)
        {
            var giveaway = await _context.Giveaways
                .Include(g => g.GiveawayParticipants)
                .FirstOrDefaultAsync(g => g.GiveawayId == id)
                ?? throw new Exception("Giveaway not found.");

            var isFinished = giveaway.EndDate <= DateTime.Now;
            var participantsCount = giveaway.GiveawayParticipants.Count;
            var hasWinner = giveaway.GiveawayParticipants.Any(p => p.IsWinner);

          
            var canDelete = !isFinished || hasWinner || participantsCount == 0;
            if (!canDelete)
                throw new Exception("Cannot delete: giveaway finished and has participants without a winner.");
            _context.Giveaways.Remove(giveaway);
            await _context.SaveChangesAsync();
            return true;
        }


        public async Task<List<WinnerNotificationEntity>> GetWinnerNotificationsForUser(string username)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == username);
            if (user == null)
                throw new Exception("User not found");

            return await _context.WinnerNotifications
                .Where(w => w.WinnerUserId == user.UserId)
                .OrderByDescending(w => w.NotificationDate)
                .ToListAsync();
        }

        public async Task<List<Giveaways>> GetFinishedWithWinner()
        {
            var query = _context.Giveaways
                .Include(g => g.GiveawayParticipants)
                .Where(g => g.EndDate <= DateTime.Now && g.IsClosed);

            var list = await query.ToListAsync();

            var mappedList = _mapper.Map<List<Model.Giveaways>>(list);

            foreach (var giveaway in mappedList)
            {
                var dbGiveaway = list.First(g => g.GiveawayId == giveaway.GiveawayId);
                var winner = dbGiveaway.GiveawayParticipants.FirstOrDefault(p => p.IsWinner);

                if (winner != null)
                {
                    var winnerUser = await _context.Users.FirstOrDefaultAsync(u => u.UserId == winner.UserId);
                    giveaway.WinnerName = winnerUser?.Username;
                }
            }

            return mappedList.Where(g => g.WinnerName != null).ToList();
        }

    }
}
