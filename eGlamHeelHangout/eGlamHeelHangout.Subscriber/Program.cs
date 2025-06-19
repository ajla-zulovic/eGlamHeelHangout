using EasyNetQ;
using Microsoft.AspNetCore.SignalR.Client;
using eGlamHeelHangout.Model;
using System.Net.Http.Json;

public class Program
{
    private static HubConnection _hubConnection;

    public static async Task Main(string[] args)
    {
        Console.WriteLine("Giveaway Notification Listener aktivan...");

        _hubConnection = new HubConnectionBuilder()
           .WithUrl("http://eglamheelhangout-api:7277/giveawayHub")
            .WithAutomaticReconnect()
            .Build();

        await _hubConnection.StartAsync();
        Console.WriteLine("SignalR connection successfully established.");

        using (var bus = RabbitHutch.CreateBus("host=rabbitmq;username=admin;password=admin123"))
        {
            await bus.PubSub.SubscribeAsync<WinnerNotification>(
                "winner_notifications",
                async message => await HandleWinnerNotification(message),
                cfg => cfg.WithTopic("winner.*"));

            await bus.PubSub.SubscribeAsync<GiveawayNotificationDTO>(
                "giveaway_subscriber",
                async message => await HandleGiveawayMessage(message),
                cfg => cfg.WithTopic("giveaway.*"));

            Console.WriteLine("Waiting for messages... Press Enter.");
            Console.ReadLine();
        }
    }

    static async Task HandleWinnerNotification(WinnerNotification message)
    {
        Console.WriteLine($"Winner from RabbitMQ: {message.WinnerUsername}");

        using var client = new HttpClient();
        var response = await client.PostAsJsonAsync("http://eglamheelhangout-api:7277/notifications/winner", message);
        Console.WriteLine($"Winner notify status: {response.StatusCode}");
    }

    static async Task HandleGiveawayMessage(GiveawayNotificationDTO message)
    {
        Console.WriteLine($"Received giveaway from RabbitMQ: {message.Title}");

        using var client = new HttpClient();
        var response = await client.PostAsJsonAsync("http://eglamheelhangout-api:7277/notifications/giveaway", message);
        // Console.WriteLine($"Notification API status: {response.StatusCode}");
        Console.WriteLine(await response.Content.ReadAsStringAsync());

    }
}
