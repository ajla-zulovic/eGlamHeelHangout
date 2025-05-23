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

namespace eGlamHeelHangout.Service
{
    public class GiveawayService:BaseCRUDService<Model.Giveaways,Database.Giveaway,Model.SearchObjects.GiveawaySearchObject,Model.Requests.GiveawayInsertRequest,object>,IGiveawayService
    {
        public BaseState _baseState { get; set; }
        public GiveawayService(_200199Context context, IMapper mapper, BaseState baseState) : base(context, mapper)
        {
            _baseState = baseState;
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

            var entity = new GiveawayParticipant
            {
                GiveawayId = request.GiveawayId,
                Size = request.Size,
                UserId = user.UserId
            };

            _context.GiveawayParticipants.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<GiveawayParticipants>(entity);
        }

        public async Task<GiveawayParticipants?> PickWinner(int giveawayId)
        {
            var entries = await _context.GiveawayParticipants
                .Where(e => e.GiveawayId == giveawayId)
                .ToListAsync();

            if (!entries.Any()) return null;

            var winner = entries[new Random().Next(entries.Count)];
            winner.IsWinner = true;

            await _context.SaveChangesAsync();

            return _mapper.Map<GiveawayParticipants>(winner);
        }


        //overridana metoda inserta zbog slanja notif :
        public override async Task<Model.Giveaways> Insert(GiveawayInsertRequest insert)
        {
            var entity = _mapper.Map<Database.Giveaway>(insert);
            _context.Giveaways.Add(entity);
            await _context.SaveChangesAsync();
            using (var bus = RabbitHutch.CreateBus("host=rabbitmq;username=admin;password=admin123"))
            {
                await bus.PubSub.PublishAsync(new GiveawayNotificationDTO
                {
                    GiveawayID = entity.GiveawayId,
                    Title = entity.Title
                });

                return _mapper.Map<Model.Giveaways>(entity);
            }
        }


    }
}
