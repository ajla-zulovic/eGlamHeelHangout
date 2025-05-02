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
    Console.WriteLine("Hello World");

    using (var bus = RabbitHutch.CreateBus("host=rabbitmq;username=admin;password=admin123"))
    {
      await bus.PubSub.SubscribeAsync<Products>("test", HandleTextMessage);
      Console.WriteLine("Listening for messages. Hit <return> to quit.");
      Console.ReadLine();
    }
  }

  static void HandleTextMessage(Products entity)
  {
    Console.WriteLine($"Primljeno: {entity.ProductID}, {entity.Name}");
  }
}


//var factory = new ConnectionFactory { HostName = "localhost" };
//using var connection = await factory.CreateConnectionAsync();
//using var channel = await connection.CreateChannelAsync();

//await channel.QueueDeclareAsync(queue: "product_added", durable: false, exclusive: false, autoDelete: false,
//    arguments: null);


//Console.WriteLine(" [*] Waiting for message.");

//var consumer = new AsyncEventingBasicConsumer(channel);
//consumer.ReceivedAsync += (model, ea) =>
//{
//  var body = ea.Body.ToArray();
//  var message = Encoding.UTF8.GetString(body);
//  Console.WriteLine($" [x] Received {message}");
//  return Task.CompletedTask;
//};

//channel.BasicConsumeAsync(queue: "product_added", autoAck: true, consumer: consumer);
//Console.WriteLine("Press [enter] to exit.");
//Console.ReadLine();
