using AutoMapper;
using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Service.Database;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service.ProductStateMachine
{
  public class BaseState
  {

    protected _200199Context _context;
    protected IMapper _mapper { get; set; }
    public IServiceProvider _serviceProvider { get; set; }
    public BaseState(_200199Context context, IMapper mapper,IServiceProvider serviceProvider)
    {
      _context = context;
      _mapper = mapper;
      _serviceProvider = serviceProvider;
    }
    //ovdje definisemo stanja koja moze imati nas proizvod

    public virtual Task<Model.Products> Insert(ProductsInsertRequest request)
    {
      throw new UserException("Not allowed !");
    }

    public virtual Task<Model.Products> Update(int id, ProductsUpdateRequest update) //id proizvoda koji ce biti updatan
    {
      throw new UserException("Not allowed !");
    }

    public virtual Task<Model.Products> Activate(int id) // id se salje za product koji je aktiviran
    {
      throw new UserException("Not allowed !");
    }

    public virtual Task<Model.Products> Hide(int id) //id se salje da znamo koji product sakrivamo 
    {
      throw new UserException("Not allowed !");  //omgoucit cemo da hide vrati stanje objekta u draft
    }

    public virtual Task<Model.Products> Delete(int id) //id se salje da znamo koji product brisemo
    {
      throw new UserException("Not allowed !");
    }

    public  BaseState CreateState(string stateName)
    {
      switch (stateName)
      {
        case "initial":
        case null:
          return _serviceProvider.GetService<InitialProductStage>();
          break;
        case "draft":
          return _serviceProvider.GetService<DraftProductState>();
          break;
        case "active":
          return _serviceProvider.GetService<ActiveProductState>();
          break;

        default:
          throw new UserException("Not allowed");
      }
    }

    public virtual async Task<List<string>> AllowedActions()
    {
      return new List<string>();
    }
  }

}
