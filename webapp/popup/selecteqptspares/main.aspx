<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" %>
<%@ Register src="~/components/menu.ascx" tagPrefix="web" tagName="menu" %>
<%@ Register src="~/components/objectsearchpanel.ascx" tagPrefix="web" tagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="pragma" content="no-cache" />


<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        if (!IsPostBack)
        {
            if (Session["Work"] != null)
            {
                OWork work = (OWork)Session["Work"];
                if (work.LocationID != null)
                    StoreID.Bind(OStore.FindAvailableStores(work));
            }
            else if (Session["ScheduledWork"] != null)
            {
                OScheduledWork work = (OScheduledWork)Session["ScheduledWork"];
                if (work.LocationID != null)
                    StoreID.Bind(OStore.FindAvailableStores(work));
            }
            BindEquipmentSpares();
        }
    }


    //---------------------------------------------------------------------
    /// <summary>
    /// Bind the equipment spares to the grid view.
    /// </summary>
    //---------------------------------------------------------------------
    Hashtable h = new Hashtable();
    protected void BindEquipmentSpares()
    {
        if (Request["ID"] != null)
        {
            OEquipment equipment = TablesLogic.tEquipment[Security.DecryptGuid(Request["ID"])];

            foreach (GridViewRow row in gridResults.Grid.Rows)
            {
                UIFieldTextBox QuantityToAdd = (UIFieldTextBox) row.FindControl("QuantityToAdd");
                //Rachel. Use row index instead of DataItemIndex as datakeys is generated for the currently in view grid page, not for the whole grid
                h[gridResults.Grid.DataKeys[row.RowIndex][0]] = QuantityToAdd.Text;
            }

            if (equipment != null && equipment.EquipmentType != null)
            {
                if (StoreBinID.SelectedIndex > 0)
                    gridResults.DataSource = equipment.EquipmentType.GetEquipmentTypeSparesAndQuantity(new Guid(StoreBinID.SelectedValue));
                else
                    gridResults.DataSource = equipment.EquipmentType.GetEquipmentTypeSparesAndQuantity(null);
                gridResults.DataBind();
            }
        }
    }


    //---------------------------------------------------------------------
    /// <summary>
    /// Event
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    //---------------------------------------------------------------------
    protected void StoreID_ControlChange(object sender, EventArgs e)
    {
        OStore store = TablesLogic.tStore[new Guid(StoreID.Items[StoreID.SelectedIndex].Value)];
        if (store != null)
        {
            StoreBinID.Bind(store.StoreBins);
        }
    }


    //---------------------------------------------------------------------
    /// <summary>
    /// Event
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    //---------------------------------------------------------------------
    protected void BinID_ControlChange(object sender, EventArgs e)
    {
        BindEquipmentSpares();
    }


    //---------------------------------------------------------------------
    /// <summary>
    /// Event
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    //---------------------------------------------------------------------
    protected void panel_Click(object sender, string commandName)
    {
        if (commandName == "AddSpares")
        {
            if (!formMain.IsValid)
            {
                panel.Message = formMain.CheckErrorMessages();
                return;
            }
            
            if (Session["Work"] != null)
            {
                OWork work = (OWork)Session["Work"];

                foreach (GridViewRow row in gridResults.Grid.Rows)
                {
                    UIFieldTextBox t = (UIFieldTextBox) row.FindControl("QuantityToAdd");
                    OWorkCost workCost = TablesLogic.tWorkCost.Create();
                    //Rachel. Use row index instead of DataItemIndex as datakeys is generated for the currently in view grid page, not for the whole grid
                    OCatalogue catalogue = TablesLogic.tCatalogue[(Guid)gridResults.DataKeys[row.RowIndex][0]];

                    workCost.StoreID = new Guid(StoreID.SelectedValue);
                    workCost.StoreBinID = new Guid(StoreBinID.SelectedValue);
                    workCost.CostType = WorkCostType.Material;
                    workCost.CostDescription = catalogue.ObjectName;
                    workCost.CatalogueID = catalogue.ObjectID;
                    workCost.UnitOfMeasureID = catalogue.UnitOfMeasureID;
                    if (Request["MODE"] != null)
                    {
                        if (Security.Decrypt(Request["MODE"]) == "0")
                        {
                            workCost.EstimatedCostFactor = 1.0M;
                            workCost.EstimatedQuantity = Convert.ToDecimal(t.Text);
                        }
                        else
                        {
                            workCost.ActualCostFactor = 1.0M;
                            workCost.ActualQuantity = Convert.ToDecimal(t.Text);
                        }
                    }

                    work.WorkCost.Add(workCost);
                }

                Session["Work"] = null;
                Window.Opener.Refresh();
                Window.Close();
            }
            else if (Session["ScheduledWork"] != null)
            {
                OScheduledWork work = (OScheduledWork)Session["ScheduledWork"];

                foreach (GridViewRow row in gridResults.Grid.Rows)
                {
                    UIFieldTextBox t = (UIFieldTextBox)row.FindControl("QuantityToAdd");
                    OScheduledWorkCost workCost = TablesLogic.tScheduledWorkCost.Create();
                    //Rachel. Use row index instead of DataItemIndex as datakeys is generated for the currently in view grid page, not for the whole grid
                    OCatalogue catalogue = TablesLogic.tCatalogue[(Guid)gridResults.DataKeys[row.RowIndex][0]];

                    workCost.StoreID = new Guid(StoreID.SelectedValue);
                    workCost.StoreBinID = new Guid(StoreBinID.SelectedValue);
                    workCost.CostType = WorkCostType.Material;
                    workCost.CostDescription = catalogue.ObjectName;
                    workCost.CatalogueID = catalogue.ObjectID;
                    workCost.UnitOfMeasureID = catalogue.UnitOfMeasureID;
                    workCost.EstimatedCostFactor = 1.0M;
                    workCost.EstimatedQuantity = Convert.ToDecimal(t.Text);

                    work.ScheduledWorkCost.Add(workCost);
                }

                Session["ScheduledWork"] = null;
                Window.Opener.Refresh();
                Window.Close();
            }
        }
    }


    //---------------------------------------------------------------------
    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    //---------------------------------------------------------------------
    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (!IsPostBack)
            {
                UIFieldTextBox t = (UIFieldTextBox)e.Row.FindControl("QuantityToAdd");

                t.Text = ((DataRowView)e.Row.DataItem)["SpareQuantity"].ToString();
            }
            else
            {
                UIFieldTextBox t = (UIFieldTextBox)e.Row.FindControl("QuantityToAdd");
                //Rachel. Use row index instead of DataItemIndex as datakeys is generated for the currently in view grid page, not for the whole grid
                if (h[gridResults.Grid.DataKeys[e.Row.RowIndex][0]] != null)
                    //Rachel. Use row index instead of DataItemIndex as datakeys is generated for the currently in view grid page, not for the whole grid
                    t.Text = h[gridResults.Grid.DataKeys[e.Row.RowIndex][0]].ToString();
            }
        }
    }
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="formMain">
        <web:pagepanel runat="server" ID="panel" Caption="Equipment Spares" OnClick="panel_Click" Button1_Caption="Add" Button1_ImageUrl="~/images/Symbol-Add-big.gif"  Button1_CommandName="AddSpares" />
        <div class="div-main">
            <ui:UITabStrip runat="server" id="tabSearch" >
                <ui:UITabView runat="server" ID="uitabview2" caption="Results"  >
                    <ui:UIFieldDropDownList runat="server" ID="StoreID" Caption="Store" OnSelectedIndexChanged="StoreID_ControlChange" ValidateRequiredField="true" ></ui:UIFieldDropDownList>
                    <ui:UIFieldDropDownList runat="server" ID="StoreBinID" Caption="Bin" OnSelectedIndexChanged="BinID_ControlChange" ValidateRequiredField="true" ></ui:UIFieldDropDownList>
                    <br />
                    <br />
                    <br />
                    <ui:UIGridView runat="server" ID="gridResults" CaptionWidth="120px" KeyName="ObjectID" Width="100%" CheckBoxColumnVisible="true" OnRowDataBound="gridResults_RowDataBound" Caption="Equipment Spares" >
                        <Columns>
                            <ui:UIGridViewBoundColumn  PropertyName="ObjectName" HeaderText="Catalog Name" />
                            <ui:UIGridViewBoundColumn  PropertyName="StockCode" HeaderText="Stock Code" />
                            <ui:UIGridViewBoundColumn  PropertyName="Manufacturer" HeaderText="Manufacturer" />
                            <ui:UIGridViewBoundColumn  PropertyName="Model" HeaderText="Model" />
                            <ui:UIGridViewBoundColumn  PropertyName="UnitOfMeasure" HeaderText="Unit of measure" />
                            <ui:UIGridViewBoundColumn  PropertyName="Qty" HeaderText="Avail. Balance" />
                            <ui:UIGridViewTemplateColumn  HeaderText="Quantity to Add" HeaderStyle-Width="120px">
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="QuantityToAdd" CaptionWidth="1px" Caption="Quantity To Add"  ValidateDataTypeCheck="true" ValidationDataType="Currency" ValidateRequiredField="true" />
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>

