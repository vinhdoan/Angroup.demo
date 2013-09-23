<%@ Control Language="C#" ClassName="BinItems" %>

<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.ComponentModel" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<script runat="server">
    public void Bind(DataTable dt)
    {
        //this.gridBinItem.DataSource = dt;
        //this.gridBinItem.DataBind();
        this.grid.DataSource = dt;
        this.grid.DataBind();
        caption.Text = dt.TableName;
        //gridBinItem.Caption = dt.TableName;
    }

    public List<OStoreStockTakeBinItem> GetItems()
    {
        List<OStoreStockTakeBinItem> list = new List<OStoreStockTakeBinItem>();
        foreach (GridViewRow row in grid.Rows)
        {
            if (row.RowType == DataControlRowType.DataRow)
            {
                OStoreStockTakeBinItem item = TablesLogic.tStoreStockTakeBinItem.Create();
                item.StoreBinItemID = new Guid(row.Cells[7].ToString());
                item.ObservedQuantity = Convert.ToDecimal(((TextBox)row.Cells[6].FindControl("txtActualqty")).Text);
                list.Add(item);
            }
        }
        return list;
    }

    //public Object DataSource
    //{
    //    set
    //    {
    //        this.gridBinItem.DataSource = value;
    //    }
    //}

    public String Caption
    {
        get
        {
            return caption.Text;
        }
    }

    public string Mode
    {
        set
        {
            switch (value)
            {
                case "EDIT":
                case "NEW":
                    {
                        foreach (GridViewRow row in grid.Rows)
                        {
                            if (row.RowType == DataControlRowType.DataRow)
                            {
                                ((TextBox)row.Cells[6].FindControl("txtActualqty")).Enabled = true;
                            }
                        }
                    }
                    break;
                default:
                    break;
            }
        }
    }

    protected void grid_RowDataBound(Object sender, GridViewRowEventArgs e)
    {
        
    }
</script>

<ui:UISeparator runat="server" ID="separator" 
    meta:resourcekey="separatorResource1" />       
<div><asp:Literal runat="server" ID="caption" meta:resourcekey="captionResource1"></asp:Literal></div>
<asp:GridView runat="server" ID="grid" AutoGenerateColumns="False" 
    OnRowDataBound="grid_RowDataBound" Width="80%" meta:resourcekey="gridResource1">
  <Columns>
      <asp:ButtonField ButtonType="Image" ImageUrl="~/images/table.gif" 
          CommandName="ViewTransactions" meta:resourcekey="ButtonFieldResource1"/>
      <asp:BoundField DataField="Catalogue" HeaderText = "Catalogue" 
          meta:resourcekey="BoundFieldResource5" />
      <asp:BoundField DataField="IsCatalogueItem" HeaderText = "Item Type" 
          meta:resourcekey="BoundFieldResource6" />
      <asp:BoundField DataField="UnitOfMeasure" HeaderText = "UnitOfMeasure" 
          meta:resourcekey="BoundFieldResource7" />
      <asp:BoundField DataField="AviableQty" HeaderText = "AviableQty" 
          meta:resourcekey="BoundFieldResource8" />
      <asp:TemplateField HeaderText="Actualqty" 
          meta:resourcekey="TemplateFieldResource2">
          <ItemTemplate>
            <asp:TextBox ID="txtActualqty" runat="server" Enabled="False" 
                  meta:resourcekey="txtActualqtyResource1"></asp:TextBox>
          </ItemTemplate>
      </asp:TemplateField>
  </Columns>
</asp:GridView>
