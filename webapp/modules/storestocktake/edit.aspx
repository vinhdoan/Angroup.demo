<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Reference Control="BinItems.ascx" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        OStoreStockTake StoreStockTake = (OStoreStockTake)panel.SessionObject;
        if (objectBase.CurrentObjectState != "Draft" && objectBase.CurrentObjectState != "Start")
        {
            StoreID.Enabled = false;
            StoreBinList.Enabled = false;
        }
        
        this.tabViewAdjustmentItems.Visible = objectBase.CurrentObjectState == "Close" || objectBase.CurrentObjectState == "PendingAdjustment";
        if (objectBase.CurrentObjectState == "Close" || objectBase.CurrentObjectState == "PendingAdjustment")
        {
            gridAdjustmentItems.Bind(StoreStockTake.GetStoreStockTakeItemsNeedingAdjustment());
        }

        if (StoreStockTake.CurrentActivity != null)
        {
            gridCatalogue.Visible = StoreStockTake.CurrentActivity.ObjectName == "InProgress" || StoreStockTake.CurrentActivity.ObjectName == "Close";
        }
        
        labelAdjustmentNumber.Visible = StoreStockTake.StoreAdjustID != null;
        
        if(StoreStockTake.StoreAdjustID!=null)
            objectBase.WorkflowActionRadioList.Items.Remove(objectBase.WorkflowActionRadioList.Items.FindByValue("ReturnToInProgress"));
    }
    
    public List<OStoreStockTakeBinItem> GetItems()
    {
        List<OStoreStockTakeBinItem> list = new List<OStoreStockTakeBinItem>();
        foreach (GridViewRow row in gridCatalogue.Grid.Rows)
        {
            if (row.RowType == DataControlRowType.DataRow)
            {
                OStoreStockTakeBinItem item = TablesLogic.tStoreStockTakeBinItem.Create();
                item.StoreBinItemID = new Guid(((HiddenField)row.Cells[7].FindControl("hidObjectID")).Value);
                item.ObservedQuantity = Convert.ToDecimal(((TextBox)row.Cells[7].FindControl("txtActualqty")).Text);
                list.Add(item);
            }
        }
        return list;
    }

    protected void BindData(Guid storeID)
    {
        StoreBinList.Bind(TablesLogic.tStoreBin[TablesLogic.tStoreBin.StoreID == storeID], "ObjectName", "ObjectID");
    }



    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        if (Request["AdjustCreated"] == "1" & !IsPostBack)
        {
            tabObject.SelectedIndex = 1;
            panel.Message = "Stocktake adjusted.";
        }

        OStoreStockTake StoreStockTake = (OStoreStockTake)panel.SessionObject;
        panel.ObjectPanel.BindObjectToControls(StoreStockTake);

        StoreID.Bind(OStore.FindAccessibleStores(AppSession.User, Security.Decrypt(Request["TYPE"]), StoreStockTake.StoreID), true);
        StoreBinList.Bind(TablesLogic.tStoreBin[TablesLogic.tStoreBin.StoreID == StoreStockTake.StoreID], "ObjectName", "ObjectID");

        if (StoreStockTake.StoreAdjustID != null)
        {
            buttonEditStoreAdjustment.Visible = AppSession.User.AllowEditAll("OStoreAdjust") || OActivity.CheckAssignment(AppSession.User, StoreStockTake.StoreAdjustID);
            buttonViewStoreAdjustment.Visible = AppSession.User.AllowViewAll("OStoreAdjust");
        }

        panel.ObjectPanel.BindObjectToControls(StoreStockTake);
    }


    protected void gridCatalogue_RowDataBound(Object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (objectBase.CurrentObjectState == "Close")
            {
                UIFieldTextBox text = (UIFieldTextBox)e.Row.Cells[6].FindControl("ObservedQuantity");
                
                if(text != null)
                    text.Enabled = false;
            }             
        }
    }
    protected void printStoreStockTakeform_Click(object sender, EventArgs e)
    {
        try
        {
            if (panel.CurrentObject.IsNew)
            {
                panel.Message = Resources.Errors.General_CannotPrintNewObject;
                return;
            }

            OStoreStockTake StoreStockTake = (OStoreStockTake)panel.SessionObject;
            panel.FocusWindow = false;
            panel.ObjectPanel.BindControlsToObject(StoreStockTake);

            DiskCache .Add("ReportTable", StoreStockTake.GetStockTakeFormData());

            Window.Open(Page.Request.ApplicationPath +
                "/modules/reportviewer/reportviewer.aspx?OutputType=EXCEL&ReportDataSetName=" +
                HttpUtility.UrlEncode(Security.Encrypt("StoreStockTake")) + "&ReportVirtualPath=" + HttpUtility.UrlEncode(Security.Encrypt("~/modules/storestocktake/stocktake.rdl")), "StoreStockTake_Window");

            Window.Opener.Refresh();
            
        }
        catch (System.Data.Odbc.OdbcException ex)
        {
            panel.Message = Resources.Errors.General_OdbcException;
        }
        catch (Exception ex)
        {
            panel.Message = ex.Message;
        }
    }

    protected void btnCreateStoreAdjustment_Click(object sender, EventArgs e)
    {
        OStoreStockTake StoreStockTake = (OStoreStockTake)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(StoreStockTake);

        List<OStoreStockTakeBinItem> adjustItems = StoreStockTake.GetStoreStockTakeItemsNeedingAdjustment();
        if (adjustItems.Count <= 0)
        {
            panel.Message = gridAdjustmentItems.ErrorMessage = Resources.Errors.StockTake_NoItemsToAdjust;
            return;
        }

        OStoreAdjust adjust = StoreStockTake.CreateStoreAdjustment();

        if (AppSession.User.AllowEditAll("OStoreAdjust") || OActivity.CheckAssignment(AppSession.User, adjust.ObjectID))
            Window.OpenEditObjectPage(this, "OStoreAdjust", adjust.ObjectID.ToString(), "AdjustCreated=1");
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        OStoreStockTake StoreStockTake = (OStoreStockTake)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(StoreStockTake);

        btnCreateStoreAdjustment.Visible = StoreStockTake.StoreAdjustID == null;
        btnCreateStoreAdjustment.Enabled = (objectBase.CurrentObjectState != "Close");
        labelAdjustmentNumber.Visible = StoreStockTake.StoreAdjustID != null;
    }

    protected void gridCatalogue_PreRender(object sender, EventArgs e)
    {
        foreach (GridViewRow row in gridCatalogue.Grid.Rows)
        {
            UIFieldTextBox tbObservedQuantity = row.FindControl("ObservedQuantity") as UIFieldTextBox;

            if (tbObservedQuantity != null)
            {
                if (tbObservedQuantity.Text !="")
                    tbObservedQuantity.Text = Convert.ToDecimal(tbObservedQuantity.Text).ToString("#,##0");
            }
        }
    }

    protected void StoreID_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (StoreID.Control.SelectedValue != "")
            StoreBinList.Bind(TablesLogic.tStoreBin[TablesLogic.tStoreBin.StoreID == new Guid(StoreID.Control.SelectedValue)]);
    }

    protected void StoreBinList_ControlChange(object sender, EventArgs e)
    {
        gridCatalogue.Visible = false;
        panel.Message = "";
    }

    
    /// <summary>
    /// Validates and saves the object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OStoreStockTake storeStockTake = (OStoreStockTake)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(storeStockTake);

            // Validate
            //
            if (objectBase.SelectedAction == "Start")
            {
                string lockedStoreBins = storeStockTake.ValidateStoreBinsNotLocked();
                if (lockedStoreBins != "")
                    StoreBinList.ErrorMessage = String.Format(Resources.Errors.StockTake_StoreBinsLocked, lockedStoreBins);
            }

            if (!panel.ObjectPanel.IsValid)
                return;

            storeStockTake.Save();
            c.Commit();
        }
    }

    
    /// <summary>
    /// Occurs when the user clicks on the edit adjustment button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonEditStoreAdjustment_Click(object sender, EventArgs e)
    {
        OStoreStockTake storeStockTake = (OStoreStockTake)panel.SessionObject;

        if (AppSession.User.AllowEditAll("OStoreAdjust") || OActivity.CheckAssignment(AppSession.User, storeStockTake.StoreAdjustID))
            Window.OpenEditObjectPage(this, "OStoreAdjust", storeStockTake.StoreAdjustID.ToString(), "");
        else
            panel.Message = Resources.Errors.General_CannotEditWorkBecauseNotAssignedToYou;
    }


    /// <summary>
    /// Occurs when the user clicks on the view adjustment button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonViewStoreAdjustment_Click(object sender, EventArgs e)
    {
        OStoreStockTake storeStockTake = (OStoreStockTake)panel.SessionObject;
        
        Window.OpenViewObjectPage(this, "OStoreAdjust", storeStockTake.StoreAdjustID.ToString(), "");
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Store Take" BaseTable="tStoreStockTake" 
            ObjectPanelID="tabObject" meta:resourcekey="panelResource1" OnPopulateForm="panel_PopulateForm"
             AutomaticBindingAndSaving="true" OnValidateAndSave="panel_ValidateAndSave"></web:object>
        <div class="div-main">
            <table width="100%" bgcolor ="#cccccc">
                <tr>
                    <td align="right">
                        <ui:uibutton id="printStoreStockTakeform" runat="server" 
                            imageurl="../../images/printer.gif" 
                            meta:resourcekey="printStoreStockTakeformResource1" 
                            onclick="printStoreStockTakeform_Click" text="Print Stock Take Form" />
                    </td>
                </tr>
            </table>
            <ui:uitabstrip id="tabObject" runat="server" borderstyle="NotSet" 
                meta:resourcekey="tabObjectResource1">
                <ui:uitabview id="uitabview1" runat="server" borderstyle="NotSet" 
                    caption="Details" cssclass="div-form" ismodifiedbyajax="False" 
                    meta:resourcekey="uitabview1Resource1">
                    <web:base ID="objectBase" runat="server" meta:resourceKey="objectBaseResource1" 
                        ObjectNameVisible="false" ObjectNumberCaption="Stock Take Number" 
                        ObjectNumberEnabled="false" ObjectNumberVisible="true" />
                    <ui:uifielddropdownlist id="StoreID" runat="server" ajaxpostback="False" 
                        border="0" caption="Store" cellpadding="2" cellspacing="0" height="20px" 
                        meta:resourcekey="StoreIDResource1" 
                        onselectedindexchanged="StoreID_SelectedIndexChanged" propertyname="StoreID" 
                        style="float: left; table-layout: fixed;" validaterequiredfield="True" 
                        width="99%">
                    </ui:uifielddropdownlist>
                    <ui:uifieldlistbox id="StoreBinList" runat="server" ajaxpostback="False" 
                        caption="Bin" meta:resourcekey="StoreBinListResource1" 
                        oncontrolchange="StoreBinList_ControlChange" propertyname="StoreBins" 
                        style="float:left;table-layout:fixed;" validaterequiredfield="True"></ui:uifieldlistbox>
                    <br />
                    <ui:uihint id="hintLockBins" runat="server" 
                        meta:resourcekey="hintLockBinsResource1" Text="
                    &amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;
                    ">
                    </ui:uihint>
                    <br />
                    <ui:uifieldlabel id="lblStoreTakeStartDate" runat="server" ajaxpostback="False" 
                        border="0" caption="Stock Take Start Date" cellpadding="2" cellspacing="0" 
                        dataformatstring="{0:dd-MMM-yyyy HH:mm:ss}" height="20px" 
                        ismodifiedbyajax="False" meta:resourcekey="lblStoreTakeStartDateResource1" 
                        propertyname="StoreStockTakeStartDateTime" span="Half" stringvalue="" 
                        style="float: left; table-layout: fixed;" width="99%">
                    </ui:uifieldlabel>
                    <ui:uifieldlabel id="lblStoreTakeEndDate" runat="server" ajaxpostback="False" 
                        border="0" caption="Stock Take End Date" cellpadding="2" cellspacing="0" 
                        dataformatstring="{0:dd-MMM-yyyy HH:mm:ss}" height="20px" 
                        ismodifiedbyajax="False" meta:resourcekey="lblStoreTakeEndDateResource1" 
                        propertyname="StoreStockTakeEndDateTime" span="Half" stringvalue="" style="float: left;
                        table-layout: fixed;" width="99%">
                    </ui:uifieldlabel>
                    <br />
                    <br />
                    <ui:uiseparator ID="Uiseparator1" runat="server" meta:resourcekey="UISeparatorResource1" />
                    <ui:uigridview id="gridCatalogue" runat="server" ajaxpostback="False" 
                        bindobjectstorows="True" caption="Store Catalog" checkboxcolumnvisible="False" 
                        datakeynames="ObjectID" gridlines="Both" 
                        ismodifiedbyajax="False" meta:resourcekey="gridCatalogueResource1" 
                        onprerender="gridCatalogue_PreRender" 
                        onrowdatabound="gridCatalogue_RowDataBound" pagingenabled="True" 
                        propertyname="StoreStockTakeBinItems" rowerrorcolor="" 
                        sortexpression="StoreBin.ObjectName, Catalogue.StockCode" style="clear:both;" 
                        width="100%" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:uigridviewboundcolumn datafield="StoreBin.ObjectName" headertext="Bin" 
                                meta:resourcekey="UIGridViewBoundColumnResource1" 
                                propertyname="StoreBin.ObjectName" resourceassemblyname="" 
                                sortexpression="StoreBin.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" Width="50px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Catalogue.StockCode" headertext="Stock Code" 
                                meta:resourcekey="UIGridViewBoundColumnResource3" 
                                propertyname="Catalogue.StockCode" resourceassemblyname="" 
                                sortexpression="Catalogue.StockCode">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" Width="100px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Catalogue.ObjectName" headertext="Catalog" 
                                propertyname="Catalogue.ObjectName" resourceassemblyname="" 
                                sortexpression="Catalogue.ObjectName" 
                                meta:resourcekey="UIGridViewBoundColumnResource10">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" Width="300px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Catalogue.UnitOfMeasure.ObjectName" 
                                headertext="Unit of Measure" 
                                propertyname="Catalogue.UnitOfMeasure.ObjectName" resourceassemblyname="" 
                                sortexpression="Catalogue.UnitOfMeasure.ObjectName" 
                                meta:resourcekey="UIGridViewBoundColumnResource11">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" Width="100px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="PhysicalQuantity" 
                                dataformatstring="{0:#,##0}" headertext="Physical Qty" 
                                meta:resourcekey="UIGridViewBoundColumnResource5" 
                                propertyname="PhysicalQuantity" resourceassemblyname="" 
                                sortexpression="PhysicalQuantity">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" Width="100px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewtemplatecolumn headertext="Observed Qty" 
                                meta:resourcekey="UIGridViewBoundColumnResource2">
                                <ItemTemplate>
                                    <ui:uifieldtextbox id="ObservedQuantity" runat="server" caption="Actual Qty" 
                                        internalcontrolwidth="80px" meta:resourcekey="ObservedQuantityResource1" 
                                        propertyname="ObservedQuantity" showcaption="False" 
                                        validatedatatypecheck="True" validaterangefield="True" 
                                        validaterequiredfield="True" validationdatatype="Currency" 
                                        validationrangemin="0" 
                                        validationrangetype="Currency">
                                    </ui:uifieldtextbox>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left"/>
                            </ui:uigridviewtemplatecolumn>
                        </Columns>
                    </ui:uigridview>
                </ui:uitabview>
                <ui:uitabview id="tabViewAdjustmentItems" runat="server" borderstyle="NotSet" 
                    caption="Adjustment" cssclass="div-form" 
                    meta:resourcekey="tabViewAdjustmentItemsResource1">
                    <ui:uifieldlabel id="labelAdjustmentNumber" runat="server" 
                        caption="Store Adjust Number" contextmenualwaysenabled="True" 
                        dataformatstring="" meta:resourcekey="labelAdjustmentNumberResource1" 
                        propertyname="StoreAdjust.ObjectNumber">
                        <contextmenubuttons>
                            <ui:uibutton id="buttonViewStoreAdjustment" runat="server" alwaysenabled="True" 
                                causesvalidation="False" imageurl="~/images/view.gif" 
                                meta:resourcekey="buttonViewStoreAdjustmentResource1" 
                                onclick="buttonViewStoreAdjustment_Click" text="View Adjustment" />
                            <ui:uibutton id="buttonEditStoreAdjustment" runat="server" alwaysenabled="True" 
                                causesvalidation="False" imageurl="~/images/edit.gif" 
                                meta:resourcekey="buttonEditStoreAdjustmentResource1" 
                                onclick="buttonEditStoreAdjustment_Click" text="Edit Adjustment" />
                        </contextmenubuttons>
                    </ui:uifieldlabel>
                    <ui:uibutton id="btnCreateStoreAdjustment" runat="server" 
                        confirmtext="Are you sure you want to create store adjust?" 
                        imageurl="../../images/add.gif" 
                        meta:resourcekey="btnCreateStoreAdjustmentResource1" 
                        onclick="btnCreateStoreAdjustment_Click" text="Create Store Adjustment" />
                    <ui:uigridview id="gridAdjustmentItems" runat="server" ajaxpostback="False" 
                        bindobjectstorows="True" caption="Adjustment Items" 
                        checkboxcolumnvisible="False" datakeynames="ObjectID" gridlines="Both" ismodifiedbyajax="False" 
                        meta:resourcekey="gridCatalogueResource1" 
                        onrowdatabound="gridCatalogue_RowDataBound" pagingenabled="True" 
                        rowerrorcolor="" sortexpression="StoreBin.ObjectName, Catalogue.StockCode" 
                        style="clear:both;" width="100%">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:uigridviewboundcolumn datafield="StoreBin.ObjectName" headertext="Bin" 
                                meta:resourcekey="UIGridViewBoundColumnResource6" 
                                propertyname="StoreBin.ObjectName" resourceassemblyname="" 
                                sortexpression="StoreBin.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Catalogue.StockCode" headertext="Stock Code" 
                                meta:resourcekey="UIGridViewBoundColumnResource4" 
                                propertyname="Catalogue.StockCode" resourceassemblyname="" 
                                sortexpression="Catalogue.StockCode">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Catalogue.ObjectName" headertext="Catalog" 
                                meta:resourcekey="UIGridViewBoundColumnResource7" 
                                propertyname="Catalogue.ObjectName" resourceassemblyname="" 
                                sortexpression="Catalogue.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Catalogue.UnitOfMeasure.ObjectName" 
                                headertext="Unit of Measure" meta:resourcekey="UIGridViewBoundColumnResource16" 
                                propertyname="Catalogue.UnitOfMeasure.ObjectName" resourceassemblyname="" 
                                sortexpression="Catalogue.UnitOfMeasure.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="PhysicalQuantity" 
                                dataformatstring="{0:#,##0}" headertext="Physical Qty" 
                                meta:resourcekey="UIGridViewBoundColumnResource8" 
                                propertyname="PhysicalQuantity" resourceassemblyname="" 
                                sortexpression="PhysicalQuantity">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="ObservedQuantity" 
                                dataformatstring="{0:#,##0}" headertext="Observed Qty" 
                                meta:resourcekey="UIGridViewBoundColumnResource9" 
                                propertyname="ObservedQuantity" resourceassemblyname="" 
                                sortexpression="ObservedQuantity">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                    </ui:uigridview>
                </ui:uitabview>
                <ui:uitabview id="tabMemo" runat="server" borderstyle="NotSet" caption="Memo" 
                    cssclass="div-form" meta:resourcekey="tabMemoResource1">
                    <web:memo ID="Memo1" runat="server" />
                </ui:uitabview>
                <ui:uitabview id="tabAttachments" runat="server" borderstyle="NotSet" 
                    caption="Attachments" cssclass="div-form" 
                    meta:resourcekey="uitabview2Resource1">
                    <web:attachments ID="attachments" runat="server" />
                </ui:uitabview>
            </ui:uitabstrip>
        </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
