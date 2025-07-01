using AutoMapper;
using eGlamHeelHangout.Model;
using eGlamHeelHangout.Service.Database;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace eGlamHeelHangout.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize] 
    public class UserNotificationsController : ControllerBase
    {
        private readonly _200199Context _context;
        private readonly IMapper _mapper;

        public UserNotificationsController(_200199Context context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }


        [HttpGet("unread")]
        public async Task<IActionResult> GetUnread([FromQuery] string? type = null)
        {
            var username = User?.Identity?.Name;
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == username);
            if (user == null)
                return Unauthorized();

            var query = _context.Notifications
                .Include(n => n.Product)
                .Include(n => n.Giveaway)
                .Where(n => n.UserId == user.UserId && n.IsRead == false);

            if (!string.IsNullOrWhiteSpace(type))
                query = query.Where(n => n.NotificationType == type);

            var notifications = await query
                .OrderByDescending(n => n.DateSent)
                .ToListAsync();

            return Ok(_mapper.Map<List<NotificationDTO>>(notifications));
        }


        [HttpPut("mark-read/{id}")]
        public async Task<IActionResult> MarkAsRead(int id)
        {
            var username = User?.Identity?.Name;
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == username);
            if (user == null)
                return Unauthorized();

            var notif = await _context.Notifications
                .Where(n => n.NotificationId == id && n.UserId == user.UserId)
                .FirstOrDefaultAsync();

            if (notif == null)
                return NotFound();

            notif.IsRead = true;
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
