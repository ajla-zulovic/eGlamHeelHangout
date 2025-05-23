// See https://aka.ms/new-console-template for more information
using EasyNetQ;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using eGlamHeelHangout.Model;

public class Program
{
  public static async Task Main(string[] args)
  {
        //Console.WriteLine("Hello World");
        Console.WriteLine("Giveaway Listener aktivan...");

        using (var bus = RabbitHutch.CreateBus("host=rabbitmq;username=admin;password=admin123"))
    {
            //await bus.PubSub.SubscribeAsync<Products>("test", HandleTextMessage);
            //Console.WriteLine("Listening for messages. Hit <return> to quit.");
            //Console.ReadLine();
            await bus.PubSub.SubscribeAsync<GiveawayNotificationDTO>("giveaway_subscriber", HandleGiveawayMessage);
            Console.WriteLine("Ceka poruke... Pritisni Enter za kraj.");
            Console.ReadLine();
        }
  }

  static void HandleTextMessage(Products entity)
  {
    Console.WriteLine($"Primljeno: {entity.ProductID}, {entity.Name}");
  }
    static void HandleGiveawayMessage(GiveawayNotificationDTO message)
    {
        Console.WriteLine($"Novi giveaway: {message.Title} (ID: {message.GiveawayID})");
        //  dodati slanje emaila, slanje ka Flutteru itd.
    }

}

