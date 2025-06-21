using eGlamHeelHangout.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service
{
    public interface IReportService
    {
        Task<List<MonthlyRevenueReport>> GetMonthlyRevenueReport();
        byte[] GenerateMonthlyRevenuePdf(List<MonthlyRevenueReport> data);
        Task<List<AgeGroupReport>> GetOrderCountByAgeGroup();
        Task<byte[]> GeneratePdfReport(List<MonthlyRevenueReport> monthlyData, List<AgeGroupReport> ageData, ReportExportOptions options);


    }
}

