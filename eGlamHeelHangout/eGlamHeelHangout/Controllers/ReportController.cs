using eGlamHeelHangout.Model;
using eGlamHeelHangout.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eGlamHeelHangout.Controllers
{

    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "Admin")]
    public class ReportController : ControllerBase
    {
        private readonly IReportService _reportService;

        public ReportController(IReportService reportService)
        {
            _reportService = reportService;
        }

        [HttpGet("monthly-revenue")]

        public async Task<ActionResult<List<MonthlyRevenueReport>>> GetMonthlyRevenue()
        {
            var result = await _reportService.GetMonthlyRevenueReport();
            return Ok(result);
        }
        [HttpGet("monthly-revenue/pdf")]
        public async Task<IActionResult> GetMonthlyRevenuePdf()
        {
            var data = await _reportService.GetMonthlyRevenueReport();
            var pdfBytes = _reportService.GenerateMonthlyRevenuePdf(data);

            return File(pdfBytes, "application/pdf", "MonthlyRevenueReport.pdf");
        }
        [HttpGet("order-count-by-age-group")]
        public async Task<IActionResult> GetOrderCountByAgeGroup()
        {
            var result = await _reportService.GetOrderCountByAgeGroup();
            return Ok(result);
        }


        [HttpPost("export/pdf")]
        public async Task<IActionResult> ExportReportToPdf([FromBody] ReportExportOptions options)
        {
            var monthlyData = options.IncludeMonthlyRevenue
                ? await _reportService.GetMonthlyRevenueReport()
                : new List<MonthlyRevenueReport>();

            var ageData = options.IncludeAgeGroupStats
                ? await _reportService.GetOrderCountByAgeGroup()
                : new List<AgeGroupReport>();

            
            var pdf = await _reportService.GeneratePdfReport(monthlyData, ageData, options);

            return File(pdf, "application/pdf", "report.pdf");
        }


    }
}
