using EasyNetQ;
using Microsoft.AspNetCore.SignalR.Client;
using eGlamHeelHangout.Model;
using System.Net.Http.Json;
using Microsoft.Extensions.Configuration;


public class Program
{
    private static HubConnection _hubConnection;
    private static string? apiBaseUrl;

    public static async Task Main(string[] args)
    {

        var config = new Microsoft.Extensions.Configuration.ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
            .Build();

        
        apiBaseUrl = config["ApiBaseUrl"]; 

        var rabbitHost = config["RabbitMQ:HostName"];
        var rabbitPort = config["RabbitMQ:Port"];
        var rabbitUser = config["RabbitMQ:UserName"];
        var rabbitPass = config["RabbitMQ:Password"];

        var rabbitConnection = $"host={rabbitHost};port={rabbitPort};username={rabbitUser};password={rabbitPass}";


        Console.WriteLine("Giveaway Notification Listener aktivan...");

        _hubConnection = new HubConnectionBuilder()
           .WithUrl("http://eglamheelhangout-api:7277/giveawayHub")
            .WithAutomaticReconnect()
            .Build();

        await _hubConnection.StartAsync();
        Console.WriteLine("SignalR connection successfully established.");

        using (var bus = RabbitHutch.CreateBus(rabbitConnection))
        {
            await bus.PubSub.SubscribeAsync<WinnerNotification>(
                "winner_notifications",
                async message => await HandleWinnerNotification(message),
                cfg => cfg.WithTopic("winner.*"));

            await bus.PubSub.SubscribeAsync<GiveawayNotificationDTO>(
                "giveaway_subscriber",
                async message => await HandleGiveawayMessage(message),
                cfg => cfg.WithTopic("giveaway.*"));
            await bus.PubSub.SubscribeAsync<ProductNotificationDTO>(
                "product_subscriber",
                async message => await HandleProductMessage(message),
                cfg => cfg.WithTopic("product.*"));
            Console.WriteLine("Subscribed to ProductNotificationDTO with topic product.*");
            await bus.PubSub.SubscribeAsync<DiscountNotification>(
            "discount_subscriber",
            async message => await HandleDiscountMessage(message),
            cfg => cfg.WithTopic("discount.*"));



            Console.WriteLine("Waiting for messages... Press Enter.");
            //Console.ReadLine();
            await Task.Delay(Timeout.Infinite);
        }
    }

    static async Task HandleWinnerNotification(WinnerNotification message)
    {
        Console.WriteLine($"Winner from RabbitMQ: {message.WinnerUsername}");

        using var client = new HttpClient();
        var response = await client.PostAsJsonAsync($"{apiBaseUrl}/notifications/winner", message);
        Console.WriteLine($"Winner notify status: {response.StatusCode}");
    }

    static async Task HandleGiveawayMessage(GiveawayNotificationDTO message)
    {
        Console.WriteLine($"Received giveaway from RabbitMQ: {message.Title}");

        using var client = new HttpClient();
        var response = await client.PostAsJsonAsync($"{apiBaseUrl}/notifications/giveaway", message);

        // Console.WriteLine($"Notification API status: {response.StatusCode}");
        Console.WriteLine(await response.Content.ReadAsStringAsync());

    }
    static async Task HandleProductMessage(ProductNotificationDTO message)
    {
        Console.WriteLine($"Received new product from RabbitMQ: {message.Name}");

        using var client = new HttpClient();
        var response = await client.PostAsJsonAsync($"{apiBaseUrl}/notifications/product", message);

        Console.WriteLine($"Product notify status: {response.StatusCode}");
    }
    static async Task HandleDiscountMessage(DiscountNotification message)
    {
        Console.WriteLine($"Received discount for product: {message.ProductName}");

        using var client = new HttpClient();
        var response = await client.PostAsJsonAsync($"{apiBaseUrl}/notifications/discount", message);

        Console.WriteLine($"Discount notify status: {response.StatusCode}");
    }


}
