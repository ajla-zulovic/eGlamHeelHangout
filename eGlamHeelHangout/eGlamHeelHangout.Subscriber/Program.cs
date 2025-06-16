using EasyNetQ;
using Microsoft.AspNetCore.SignalR.Client;
using eGlamHeelHangout.Model;

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
        Console.WriteLine($"The winner: {message.WinnerUsername} won: {message.GiveawayTitle}");
        await _hubConnection.InvokeAsync("ReceiveWinner", message);
    }

    static async Task HandleGiveawayMessage(GiveawayNotificationDTO message)
    {
        Console.WriteLine($"Received message from RabbitMQ: {message.Title}");

        await _hubConnection.InvokeAsync("ReceiveGiveaway", message);

        Console.WriteLine("Sent message to SignalR");

    }
}
