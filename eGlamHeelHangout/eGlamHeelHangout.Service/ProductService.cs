using AutoMapper;
using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Model.SearchObjects;
using eGlamHeelHangout.Service.Database;
using eGlamHeelHangout.Service.ProductStateMachine;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service
{
  public class ProductService:BaseCRUDService<Model.Products,Database.Product,Model.SearchObjects.ProductsSearchObjects,Model.Requests.ProductsInsertRequest,Model.Requests.ProductsUpdateRequest>, IProductService
  {
    public BaseState _baseState { get; set; }
    public ProductService(_200199Context context, IMapper mapper, BaseState baseState) : base(context,mapper)
    {
      _baseState = baseState;
    }


    public override Task<Model.Products> Insert(ProductsInsertRequest insert)
    {
      var state = _baseState.CreateState("initial");
      return state.Insert(insert);
    }

    public override async Task<Model.Products> Update(int id, ProductsUpdateRequest update)
    {
      var entity = await _context.Products.FindAsync(id);
      var state = _baseState.CreateState(entity.StateMachine);
      return await state.Update(id, update);

    }

    public async Task<Model.Products> Activate(int id)
    {
      var entity = await _context.Products.FindAsync(id);

      var state = _baseState.CreateState(entity.StateMachine);

      return await state.Activate(id);
    }

    public async Task<Model.Products> Hide(int id)
    {
      var entity = await _context.Products.FindAsync(id); //dohvatimo/nađemo trazeni proizvod u nasoj bazi, tabeli Products

      var state = _baseState.CreateState(entity.StateMachine); //dohvatimo stanje tog prozivoda 

      return await state.Hide(id);  //to stanje koje smo imali pozivamo nad njim Hide metodu te ga vracamo u draft
    }

    public async Task<List<string>> AllowedActions(int id) //dopustene akcije za određeni proizvod, povratni tip je lista stringova jer su radnje opisane popit active,hide, draft i sl
    {
      var entity = await _context.Products.FindAsync(id);
      var state = _baseState.CreateState(entity?.StateMachine??"initial");
      return await state.AllowedActions();
    }
  }
}

//AsQueryAble -> znaci da ce moci dodavati filtere
