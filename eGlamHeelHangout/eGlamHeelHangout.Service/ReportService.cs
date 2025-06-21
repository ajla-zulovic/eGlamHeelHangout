using eGlamHeelHangout.Model;
using eGlamHeelHangout.Service.Database;
using System;
using System.Globalization;
using Microsoft.EntityFrameworkCore;
using eGlamHeelHangout.Service;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;


public class ReportService : IReportService
{
    private readonly _200199Context _context;

    public ReportService(_200199Context context)
    {
        _context = context;
    }

    public async Task<List<MonthlyRevenueReport>> GetMonthlyRevenueReport()
    {
        var result = await _context.Orders
            .Where(o => o.OrderDate.HasValue && o.OrderStatus.ToLower() == "delivered")
            .GroupBy(o => o.OrderDate.Value.Month)

            .Select(g => new MonthlyRevenueReport
            {
                Month = CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(g.Key),
                TotalRevenue = g.Sum(x => x.TotalPrice)
            })
            .ToListAsync();

        return result;
    }

    public byte[] GenerateMonthlyRevenuePdf(List<MonthlyRevenueReport> data)
    {
        var document = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Margin(30);
                page.Header().Text("Monthly Revenue Report").SemiBold().FontSize(20).AlignCenter();
                page.Content().Table(table =>
                {
                    table.ColumnsDefinition(columns =>
                    {
                        columns.RelativeColumn();
                        columns.RelativeColumn();
                    });

                    table.Header(header =>
                    {
                        header.Cell().Text("Month").Bold();
                        header.Cell().Text("Total Revenue").Bold();
                    });

                    foreach (var item in data)
                    {
                        table.Cell().Text(item.Month);
                        table.Cell().Text($"{item.TotalRevenue:C}"); 
                    }
                });

                page.Footer().AlignCenter().Text(txt =>
                {
                    txt.Span("Generated on ");
                    txt.Span($"{DateTime.Now:yyyy-MM-dd HH:mm}");
                });
            });
        });

        return document.GeneratePdf();
    }


    public async Task<List<AgeGroupReport>> GetOrderCountByAgeGroup()
    {
        var data = await _context.Orders
            .Where(o => o.OrderStatus.ToLower() == "delivered")
            .Join(_context.Users, o => o.UserId, u => u.UserId, (order, user) => new
            {
                Age = user.DateOfBirth.HasValue
                    ? (int)((DateTime.Now - user.DateOfBirth.Value).TotalDays / 365.25)
                    : 0
            })
            .ToListAsync();

        var grouped = data
            .GroupBy(x =>
            {
                var age = x.Age;
                return age switch
                {
                    <= 17 => "Under 18",
                    <= 24 => "18–24",
                    <= 34 => "25–34",
                    <= 44 => "35–44",
                    <= 54 => "45–54",
                    <= 64 => "55–64",
                    _ => "65+"
                };
            })
            .Select(g => new AgeGroupReport
            {
                AgeGroup = g.Key,
                OrderCount = g.Count()
            })
            .ToList();

        return grouped;
    }

    public async Task<byte[]> GeneratePdfReport(List<MonthlyRevenueReport> monthlyData, List<AgeGroupReport> ageData, ReportExportOptions options)
    {
        var document = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(2, Unit.Centimetre);
                page.DefaultTextStyle(x => x.FontSize(14));

                page.Content().Column(column =>
                {
                    column.Spacing(20);

                    if (options.IncludeMonthlyRevenue)
                    {
                        column.Item().Text("Monthly Revenue Report").Bold().FontSize(18);
                        column.Item().Table(table =>
                        {
                            table.ColumnsDefinition(c =>
                            {
                                c.ConstantColumn(150);
                                c.RelativeColumn();
                            });

                            table.Header(header =>
                            {
                                header.Cell().Text("Month").Bold();
                                header.Cell().Text("Total Revenue").Bold();
                            });

                            foreach (var item in monthlyData)
                            {
                                table.Cell().Text(item.Month);
                                table.Cell().Text($"${item.TotalRevenue:F2}");
                            }
                        });
                    }

                    if (options.IncludeAgeGroupStats)
                    {
                        column.Item().Text("Orders by Age Group").Bold().FontSize(18);
                        column.Item().Table(table =>
                        {
                            table.ColumnsDefinition(c =>
                            {
                                c.ConstantColumn(150);
                                c.RelativeColumn();
                            });

                            table.Header(header =>
                            {
                                header.Cell().Text("Age Group").Bold();
                                header.Cell().Text("Order Count").Bold();
                            });

                            foreach (var item in ageData)
                            {
                                table.Cell().Text(item.AgeGroup);
                                table.Cell().Text(item.OrderCount.ToString());
                            }
                        });
                    }
                });
            });
        });

      
        return await Task.Run(() => document.GeneratePdf());
    }


}