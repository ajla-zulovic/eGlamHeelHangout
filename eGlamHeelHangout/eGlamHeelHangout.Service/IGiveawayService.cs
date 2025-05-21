using eGlamHeelHangout.Model.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service
{
    public interface IGiveawayService:ICRUDService<Model.Giveaways,Model.SearchObjects.GiveawaySearchObject,Model.Requests.GiveawayInsertRequest,object>
    {
        Task<List<Model.Giveaways>> GetActive();
        Task<Model.GiveawayParticipants> AddParticipant(string username, GiveawayParticipantInsertRequest request);
        Task<Model.GiveawayParticipants?> PickWinner(int giveawayId);
        Task<bool> Delete(int id);


    }
}
