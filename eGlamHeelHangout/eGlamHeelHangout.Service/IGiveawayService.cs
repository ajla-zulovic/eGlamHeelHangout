using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Service.Database;
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
        Task NotifyWinner(int giveawayId, int winnerUserId);
 
        Task<List<Model.Giveaways>> GetFiltered(bool? isActive);
        Task<bool> Delete(int id);
        Task<WinnerNotificationEntity?> GetLastWinnerNotification();
        Task<bool> DeleteIfAllowed(int id);
        Task<List<WinnerNotificationEntity>> GetWinnerNotificationsForUser(string username);
  
        Task<List<Giveaways>> GetFinishedWithWinner();




    }
}
