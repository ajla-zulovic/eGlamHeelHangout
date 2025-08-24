using Microsoft.AspNetCore.Mvc;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Service;
using Microsoft.AspNetCore.Authorization;

[ApiController]
[Route("[controller]")]
public class DiscountController : ControllerBase
{
    private readonly IDiscountService _discountService;

    public DiscountController(IDiscountService discountService)
    {
        _discountService = discountService;
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Insert([FromBody] DiscountInsertRequest request)
    {
        try
        {
            await _discountService.AddDiscountAsync(request);
            return Ok("Discount added successfully.");
        }
        catch (Exception ex)
        {
            return BadRequest($"[Discount ERROR] {ex.Message}\n{ex.StackTrace}");
        }

    }

    [HttpGet("by-product/{productId}")]
    [Authorize]
    public async Task<IActionResult> GetByProduct(int productId)
    {
        var discount = await _discountService.GetByProductAsync(productId);
        if (discount == null)
            return NotFound();

        return Ok(discount);
    }

    [HttpDelete("{productId}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Remove(int productId)
    {
        await _discountService.RemoveDiscountAsync(productId);
        return Ok("Discount removed.");
    }
    [HttpGet("active")]
    [Authorize]
    public async Task<IActionResult> GetAllActiveDiscounts()
    {
        var result = await _discountService.GetDiscountedProductsAsync();
        return Ok(result);
    }


}
