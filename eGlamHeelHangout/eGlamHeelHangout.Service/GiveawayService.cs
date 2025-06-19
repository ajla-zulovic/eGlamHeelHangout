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

namespace eGlamHeelHangout.Service
{
    public class GiveawayService:BaseCRUDService<Model.Giveaways,Database.Giveaway,Model.SearchObjects.GiveawaySearchObject,Model.Requests.GiveawayInsertRequest,object>,IGiveawayService
    {
        public BaseState _baseState { get; set; }
        private readonly IHubContext<GiveawayHub> _hubContext;
        public GiveawayService(_200199Context context, IMapper mapper, BaseState baseState, IHubContext<GiveawayHub> hubContext) : base(context, mapper)
        {
            _baseState = baseState;
            _hubContext = hubContext;
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

            var winner = entries[new Random().Next(entries.Count)];
            winner.IsWinner = true;

            var giveaway = await _context.Giveaways.FindAsync(giveawayId);
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
                try
                {
                    var base64 = insert.GiveawayProductImage;

                    
                    if (base64.Contains(","))
                        base64 = base64.Split(',')[1];

                    entity.GiveawayProductImage = Convert.FromBase64String(base64);
                }
                catch (Exception ex)
                {
                    throw new Exception("Invalid image format. Cannot decode base64 string.", ex);
                }
            }

            _context.Giveaways.Add(entity);
            await _context.SaveChangesAsync();

            try
            {
                using var bus = RabbitHutch.CreateBus("host=rabbitmq;username=admin;password=admin123");
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

                Console.WriteLine("Giveaway published to RabbitMQ");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"RabbitMQ error: {ex.Message}");
            }

            
            if (_hubContext != null)
            {
                await _hubContext.Clients.All.SendAsync("ReceiveGiveaway", new
                {
                    giveawayId = entity.GiveawayId,
                    title = entity.Title,
                    description = entity.Description,
                    heelHeight = entity.HeelHeight,
                    color = entity.Color,
                    giveawayProductImage = entity.GiveawayProductImage != null
                        ? Convert.ToBase64String(entity.GiveawayProductImage)
                        : null
                });
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

                var winner = dbGiveaway.GiveawayParticipants.FirstOrDefault(p => p.IsWinner);

                if (winner != null)
                {
                    var winnerUser = await _context.Users.FirstOrDefaultAsync(u => u.UserId == winner.UserId);
                    giveaway.WinnerName = winnerUser?.Username;
                }
            }

            return mappedList;
        }


        public async Task NotifyWinner(int giveawayId, int winnerUserId)
        {
            var giveaway = await _context.Giveaways.FindAsync(giveawayId);
            var winner = await _context.Users.FindAsync(winnerUserId);

            using (var bus = RabbitHutch.CreateBus("host=rabbitmq;username=admin;password=admin123"))
            {
                await bus.PubSub.PublishAsync(new WinnerNotification
                {
                    GiveawayId = giveawayId,
                    GiveawayTitle = giveaway.Title,
                    WinnerUserId = winnerUserId,
                    WinnerUsername = winner.Username,
                    NotificationDate = DateTime.Now
                },"winner.notification");
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
        }

        public async Task<WinnerNotificationEntity?> GetLastWinnerNotification()
        {
            return await _context.WinnerNotifications
                .OrderByDescending(n => n.NotificationDate)
                .FirstOrDefaultAsync();
        }
    }
}
