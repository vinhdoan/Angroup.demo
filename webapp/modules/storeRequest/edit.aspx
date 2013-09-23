<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">
    
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OStoreRequest storeRequest = panel.SessionObject as OStoreRequest;
        objectBase.ObjectNumberVisible = !storeRequest.IsNew;

        StoreID.Bind(OStore.FindAccessibleStores(AppSession.User, Security.Decrypt(Request["TYPE"]), storeRequest.StoreID));
        UserID.Bind(OUser.GetAllUsers());

        panel.ObjectPanel.BindObjectToControls(storeRequest);
    }


    /// <summary>
    /// Saves the calendar to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OStoreRequest obj = (OStoreRequest)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(obj);

            String state = objectBase.CurrentObjectState;
            String action = objectBase.SelectedAction;

            // Validate
            //

            if (action == "SubmitForApproval")
            {
                if (!obj.ValidateSufficientItemsForRequest())
                {
                    string list = "";
                    foreach (OStoreRequestItem item in obj.StoreRequestItems)
                        if (!item.Valid)
                            list += (list == "" ? "" : Resources.Messages.General_CommaSeparator) + item.Catalogue.ObjectName + " (" + item.StoreBin.ObjectName + ")";

                    gridStoreRequestItems.ErrorMessage = String.Format(Resources.Errors.StoreRequest_InsufficientItems1, list);

                }
            }

            if (action.Is("Return"))
            {
                if (!obj.ValidateReturnAmount())
                {
                    string list = "";
                    foreach (OStoreRequestItem item in obj.StoreRequestItems)
                        if (!item.Valid)
                            list += (list == "" ? "" : Resources.Messages.General_CommaSeparator) + item.Catalogue.ObjectName + " (" + item.StoreBin.ObjectName + ")";

                    gridStoreRequestItems.ErrorMessage = String.Format(Resources.Errors.StoreRequest_InvalidReturn, list);
                }
            }

            if (action.Is("SubmitForCollection", "Return"))
            {
                // Validates to ensure that the none of the store bins
                // are locked before we try to check out or return.
                //
                string lockedBins = obj.ValidateBinsNotLocked();
                if (lockedBins != "")
                {
                    gridStoreRequestItems.ErrorMessage = String.Format(Resources.Errors.StoreRequest_BinLocked, lockedBins);
                    return;
                }
            }

            if (!panel.ObjectPanel.IsValid)
                return;

            obj.Save();
            c.Commit();
        }
    }

    /// <summary>
    /// Initializes the controls in the request item subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="obj"></param>
    protected void RequestItem_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OStoreRequest storeRequest = panel.SessionObject as OStoreRequest;
        OStoreRequestItem item = RequestItem_SubPanel.SessionObject as OStoreRequestItem;

        Request_CatalogueID.PopulateTree();

        Request_StoreBinID.Items.Clear();
        Request_ActualUnitOfMeasureID.Items.Clear();
        Return_ActualUnitOfMeasureID.Items.Clear();

        if (storeRequest.StoreID != null && item.CatalogueID != null)
        {
            Request_StoreBinID.Bind(
                OStore.FindBinsByCatalogue(storeRequest.StoreID, item.CatalogueID, true, item.StoreBinID),
                "ObjectName", "ObjectID", true);
            Request_ActualUnitOfMeasureID.Bind(
                OUnitConversion.GetConversions(item.Catalogue.UnitOfMeasureID, item.ActualUnitOfMeasureReservedID), "ObjectName", "ToUnitOfMeasureID", false);
            if (panelReturn.Visible)
                Return_ActualUnitOfMeasureID.Bind(
                    OUnitConversion.GetConversions(item.Catalogue.UnitOfMeasureID, item.ActualUnitOfMeasureReturnedID), "ObjectName", "ToUnitOfMeasureID", false);
        }

        RequestItem_SubPanel.ObjectPanel.BindObjectToControls(item);
    }


    /// <summary>
    /// Validates and inserts the store Request item
    /// into the store Request object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RequestItem_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OStoreRequest storeRequest = (OStoreRequest)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(storeRequest);

        OStoreRequestItem item = (OStoreRequestItem)RequestItem_SubPanel.SessionObject;
        RequestItem_SubPanel.ObjectPanel.BindControlsToObject(item);

        // Compute the estimated unit cost for the items.
        // when state is start and draft
        if (objectBase.CurrentObjectState.Is("Start", "Draft"))
        {
            item.ComputeBaseQuantityReserved();
            item.ComputeEstimatedUnitCost();
            if (!storeRequest.ValidateSufficientItemForRequest(item))
            {
                Request_ActualQuantity.ErrorMessage = String.Format(Resources.Errors.StoreRequest_InsufficientItems1, item.Catalogue.ObjectName);
            }
            if (storeRequest.HasDuplicateRequestItem(item))
            {
                Request_CatalogueID.ErrorMessage = String.Format(Resources.Errors.StoreRequest_DuplicateItemName, item.Catalogue.ObjectName);
                Request_StoreBinID.ErrorMessage = String.Format(Resources.Errors.StoreRequest_DuplicateItemName, item.Catalogue.ObjectName);

            }
        }

        if (objectBase.CurrentObjectState.Is("PendingReturn"))
        {
            item.ComputeBaseQuantityReturned();
            if (!storeRequest.ValidateReturnAmount(item))
            {
                Return_ActualQuantity.ErrorMessage = String.Format(Resources.Errors.StoreRequest_InvalidReturn, item.Catalogue.ObjectName);
            }
        }

        if (!RequestItem_SubPanel.ObjectPanel.IsValid)
            return;


        // Insert
        //
        storeRequest.StoreRequestItems.Add(item);
        panel.ObjectPanel.BindObjectToControls(storeRequest);
    }


    /// <summary>
    /// Constructs and returns the catalog tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater CatalogueID_AcquireTreePopulater(object sender)
    {
        OStoreRequestItem storeRequestItem = this.RequestItem_SubPanel.SessionObject as OStoreRequestItem;
        return new CatalogueTreePopulater(storeRequestItem.CatalogueID, true, true);
    }


    /// <summary>
    /// Hides/shows or enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        
 
        String state = objectBase.CurrentObjectState;
        String action = objectBase.SelectedAction;

        
        //Return_ActualQuantity.ValidateRequiredField = state.Is("PendingReturn","Returned") & action.Is("Return");
        //Return_ActualUnitOfMeasureID.ValidateRangeField = state.Is("PendingReturn", "Returned") & action.Is("Return"); 
        //tb.ValidateRequiredField = objectBase.CurrentObjectState.Is("PendingClosure", "Close") | objectBase.SelectedAction.Is("SubmitForClosure");
    
        OStoreRequest Request = (OStoreRequest)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(Request);

        buttonAddItems.Visible = Request.StoreID != null;
        gridStoreRequestItems.Visible = Request.StoreID != null;
        StoreID.Enabled = (Request.StoreRequestItems.Count == 0 && !RequestItem_Panel.Visible);
        panelDestinationUser.Visible = DestinationType.SelectedIndex == 1;        
        Request_ConversionText.Visible = (Request_ConversionText.Text != "");

        foreach (GridViewRow row in gridStoreRequestItems.Grid.Rows)
        {
            if (row.RowType == DataControlRowType.DataRow)
            {
                UIFieldLabel labelValid = (UIFieldLabel)row.FindControl("labelValid");
                Image imageError = (Image)row.FindControl("imageError");

                if (labelValid != null && imageError != null)
                    imageError.Visible = labelValid.Text.ToString() == "false";
            }
        }

        panelDetails.Enabled = state.Is("Start", "Draft", "PendingReturn");
        panelReturn.Visible = state.Is("PendingReturn", "Returned");
        Request_ActualQuantity.Enabled = state.Is("Start", "Draft");
        Request_ActualUnitOfMeasureID.Enabled = state.Is("Start", "Draft");
        Request_CatalogueID.Enabled = state.Is("Start", "Draft");
        Request_StoreBinID.Enabled = state.Is("Start", "Draft");
        DestinationType.Enabled = state.Is("Start", "Draft");
        UserID.Enabled = state.Is("Start", "Draft");
        buttonAddItems.Enabled = state.Is("Start", "Draft");
        Return_ActualQuantity.Enabled = state.Is("PendingReturn");
        Return_ActualUnitOfMeasureID.Enabled = state.Is("PendingReturn");
        //Return_ActualQuantity.ValidateRequiredField = state.Is("PendingReturn") & action.Is("Return");

        bool columnsVisible = objectBase.CurrentObjectState.Is("PendingReturn", "Returned") && !RequestItem_Panel.Visible;
        foreach (GridViewRow row in gridStoreRequestItems.Rows)
        {
            row.Cells[8].Visible = columnsVisible;
            row.Cells[9].Visible = columnsVisible;
        }
      
        tabDetails.Enabled = objectBase.CurrentObjectState != "Cancelled";
    }


    /// <summary>
    /// Occurs when the user selects a different value from
    /// the destination type dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void DestinationType_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Occurs when the user selects a different store from 
    /// the dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void StoreID_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Occurs when the user selects a different node in the
    /// catalog treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Request_CatalogueID_SelectedNodeChanged(object sender, EventArgs e)
    {
        // Bind to object.
        //
        OStoreRequest Request = (OStoreRequest)this.panel.SessionObject;

        OStoreRequestItem item = (OStoreRequestItem)this.RequestItem_SubPanel.SessionObject;
        RequestItem_SubPanel.ObjectPanel.BindControlsToObject(item);

        // Update dropdown lists.
        //
        Request_StoreBinID.Items.Clear();
        Request_ActualUnitOfMeasureID.Items.Clear();
        Return_ActualUnitOfMeasureID.Items.Clear();

        if (Request.StoreID != null && item.CatalogueID != null)
        {
            Request_StoreBinID.Bind(
                OStore.FindBinsByCatalogue(Request.StoreID, item.CatalogueID, true, null),
                "ObjectName", "ObjectID", true);
            Request_ActualUnitOfMeasureID.Bind(
                OUnitConversion.GetConversions(item.Catalogue.UnitOfMeasureID, null), "ObjectName", "ToUnitOfMeasureID", false);
            if (panelReturn.Visible)
                Return_ActualUnitOfMeasureID.Bind(
                OUnitConversion.GetConversions(item.Catalogue.UnitOfMeasureID, null), "ObjectName", "ToUnitOfMeasureID", false);
        }


        RequestItem_SubPanel.ObjectPanel.BindObjectToControls(item);
    }


    /// <summary>
    /// Occurs when the user selects a different 
    /// Request unit of measure.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Request_ActualUnitOfMeasureID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OStoreRequestItem item = (OStoreRequestItem)this.RequestItem_SubPanel.SessionObject;
        RequestItem_SubPanel.ObjectPanel.BindControlsToObject(item);
        RequestItem_SubPanel.ObjectPanel.BindObjectToControls(item);
    }


    /// <summary>
    /// Occurs when the user clicks on the "Add Consumables/Non-Consumables" button.
    /// Pops up the additems.aspx page.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddItems_Click(object sender, EventArgs e)
    {
        OStoreRequest storeRequest = panel.SessionObject as OStoreRequest;
        panel.ObjectPanel.BindControlsToObject(storeRequest);
        panel.FocusWindow = false;
        Window.Open("additems.aspx", "AnacleEAM_Popup");
    }


    /// <summary>
    /// Occurs when the user confirms the items to add in the pop-up page.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonItemsAdded_Click(object sender, EventArgs e)
    {
        OStoreRequest storeRequest = panel.SessionObject as OStoreRequest;
        panel.ObjectPanel.BindControlsToObject(storeRequest);
        panel.ObjectPanel.BindObjectToControls(storeRequest);
    }



    protected void gridStoreRequestItems_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        foreach (UIGridViewCommand i in gridStoreRequestItems.Commands)
            i.Button.Enabled = objectBase.CurrentObjectState.Is("Start", "Draft");
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[2].Controls[0].Visible = objectBase.CurrentObjectState.Is("Start", "Draft");

            UIFieldTextBox textActualQuantityReturned = e.Row.FindControl("textActualQuantityReturned") as UIFieldTextBox;
            UIFieldDropDownList dropActualUnitOfMeasureReturned = e.Row.FindControl("dropActualUnitOfMeasureReturned") as UIFieldDropDownList;

            dropActualUnitOfMeasureReturned.Bind(OCode.GetCodesByType("UnitOfMeasure", null));
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain">
        <web:object runat="server" ID="panel" Caption="Store Request" BaseTable="tStoreRequest" OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject">
                <ui:UITabView ID="tabDetails" runat="server" Caption="Details">
                    <web:base ID="objectBase" runat="server" ObjectNameCaption="Store Request" ObjectNumberVisible="false" ObjectNameVisible="false" ObjectNumberEnabled="false"></web:base>
                    <ui:UIPanel runat="server" ID="panelDetails">
                        <ui:UIFieldDropDownList runat="server" ID="StoreID" PropertyName="StoreID" Caption="Store" OnSelectedIndexChanged="StoreID_SelectedIndexChanged" meta:resourcekey="StoreIDResource1" ValidateRequiredField="true" />
                        <ui:UIFieldTextBox runat="server" ID="Remarks" PropertyName="Remarks" Caption="Remarks" ToolTip="Remarks for the request." meta:resourcekey="DescriptionResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldRadioList runat="server" ID="DestinationType" ValidateRequiredField="True" RepeatColumns="0" PropertyName="DestinationType" Caption="Request To" OnSelectedIndexChanged="DestinationType_SelectedIndexChanged" meta:resourcekey="DestinationTypeResource1">
                            <Items>
                                <asp:listitem value="0" selected="True" meta:resourcekey="ListItemResource1">None</asp:listitem>
                                <asp:listitem value="1" meta:resourcekey="ListItemResource2">User</asp:listitem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="panelDestinationUser" meta:resourcekey="panelDestinationUserResource1">
                            <ui:UIFieldDropDownList runat="server" ID="UserID" PropertyName="UserID" Caption="User" ValidateRequiredField="True" meta:resourcekey="UserIDResource1">
                            </ui:UIFieldDropDownList>
                        </ui:UIPanel>
                        <br />
                        <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1"></ui:UISeparator>
                        <ui:UIButton runat="server" ID="buttonAddItems" Text="Add Consumables/Non-Consumables" ImageUrl="~/images/add.gif" CausesValidation="false" OnClick="buttonAddItems_Click" />
                        <ui:UIButton runat="server" ID="buttonItemsAdded" CausesValidation="false" OnClick="buttonItemsAdded_Click" />
                        <br />
                        <br />
                        <ui:UIGridView runat="server" ID="gridStoreRequestItems" PropertyName="StoreRequestItems" Caption="Request Items" BindObjectsToRows="True" KeyName="ObjectID" meta:resourcekey="gridStoreRequestItemsResource1" Width="100%" ValidateRequiredField="true" ShowFooter="true" PageSize="1000" OnRowDataBound="gridStoreRequestItems_RowDataBound">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" AlwaysEnabled="true" CommandName="EditObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource1" />
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="RemoveObject" ConfirmText="Are you sure you wish to delete this item?" HeaderText="" meta:resourcekey="UIGridViewColumnResource2" />
                                <ui:UIGridViewBoundColumn PropertyName="Catalogue.ObjectName" HeaderText="Catalog" meta:resourcekey="UIGridViewColumnResource3">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Catalogue.StockCode" HeaderText="Stock Code">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="StoreBin.ObjectName" HeaderText="Bin" meta:resourcekey="UIGridViewColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ActualQuantityReserved" HeaderText="Reserved Quantity" meta:resourcekey="UIGridViewColumnResource6">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ActualUnitOfMeasureReserved.ObjectName" HeaderText="Reserved Unit" meta:resourcekey="UIGridViewColumnResource7">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn HeaderText="Returned Quantity*">
                                    <ItemTemplate>
                                        <ui:uifieldtextbox runat="server" id="textActualQuantityReturned" FieldLayout="Flow" PropertyName="ActualQuantityReturned" Caption="Returned Quantity" ShowCaption="false" InternalControlWidth="50px" ValidaterequiredField="true">
                                        </ui:uifieldtextbox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderText="Returned Unit*">
                                    <ItemTemplate>
                                        <ui:uifielddropdownlist runat="server" id="dropActualUnitOfMeasureReturned" FieldLayout="Flow" PropertyName="ActualUnitOfMeasureReturnedID" Caption="Returned Unit" ShowCaption="false" InternalControlWidth="100px" ValidaterequiredField="true">
                                        </ui:uifielddropdownlist>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewBoundColumn PropertyName="BaseQuantityUsed" HeaderText="Base Quantity Used">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Catalogue.UnitOfMeasure.ObjectName" HeaderText="Base Unit">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="EstimatedUnitCost" DataFormatString="{0:c}" HeaderText="Unit Cost (Estimated)">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ActualUnitCost" DataFormatString="{0:c}" HeaderText="Unit Cost (Actual)">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="SubTotal" DataFormatString="{0:c}" HeaderText="Sub Total (Estimated)" FooterAggregate="Sum">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="SubTotalActual" DataFormatString="{0:c}" HeaderText="Sub Total (Actual)" FooterAggregate="Sum">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandName="DeleteObject" ImageUrl="~/images/delete.gif" CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?" meta:resourcekey="UIGridViewCommandResource1" />
                                <ui:UIGridViewCommand CommandName="AddObject" ImageUrl="~/images/add.gif" CommandText="Add" meta:resourcekey="UIGridViewCommandResource2" />
                            </Commands>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="RequestItem_Panel" meta:resourcekey="RequestItem_PanelResource1">
                            <web:subpanel runat="server" ID="RequestItem_SubPanel" GridViewID="gridStoreRequestItems" MultiSelectColumnNames="CatalogueID,StoreBinID,ActualQuantityReserved,ActualUnitOfMeasureReservedID" OnPopulateForm="RequestItem_SubPanel_PopulateForm" OnValidateAndUpdate="RequestItem_SubPanel_ValidateAndUpdate" />
                            <ui:UIFieldTreeList runat="server" ID="Request_CatalogueID" PropertyName="CatalogueID" Caption="Catalog Item" ValidateRequiredField="True" OnAcquireTreePopulater="CatalogueID_AcquireTreePopulater" ToolTip="Catalog item to Request" OnSelectedNodeChanged="Request_CatalogueID_SelectedNodeChanged" meta:resourcekey="Request_CatalogueIDResource1" />
                            <ui:UIFieldDropDownList runat="server" ID="Request_StoreBinID" PropertyName="StoreBinID" ValidateRequiredField="True" Caption="Bin (Avail Qty)" Span="Full" ToolTip="The bin where this item is checked out from." meta:resourcekey="Request_StoreBinIDResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldLabel runat="server" ID="Request_BaseUnitOfMeasure" PropertyName="Catalogue.UnitOfMeasure.ObjectName" Caption="Base Unit" meta:resourcekey="Request_BaseUnitOfMeasureResource1" />
                            <table cellpadding='0' cellspacing='0' border='0'>
                                <tr>
                                    <td style="width: 50%">
                                        <ui:UIPanel runat="server" ID="panelRequest">
                                            <ui:UIFieldTextBox runat="server" ID="Request_ActualQuantity" PropertyName="ActualQuantityReserved" ValidateRangeField="true" ValidationRangeType='Currency' ValidationRangeMin="0" ValidationRangeMinInclusive="false" ValidateRequiredField="True" ValidationDataType="Double" Caption="Request Quantity" ToolTip="Request quantity." meta:resourcekey="Request_ActualQuantityResource1" />
                                            <ui:UIFieldDropDownList runat="server" ID="Request_ActualUnitOfMeasureID" PropertyName="ActualUnitOfMeasureReservedID" ValidateRequiredField="True" Caption="Request Unit" OnSelectedIndexChanged="Request_ActualUnitOfMeasureID_SelectedIndexChanged" meta:resourcekey="Request_ActualUnitOfMeasureIDResource1">
                                            </ui:UIFieldDropDownList>
                                        </ui:UIPanel>
                                    </td>
                                    <td style="width: 50%">
                                        <ui:UIPanel runat="server" Style="float: left" ID="panelReturn">
                                            <ui:UIFieldTextBox runat="server" ID="Return_ActualQuantity" PropertyName="ActualQuantityReturned" ValidateRangeField="true" ValidationRangeType='Currency' ValidationRangeMin="0" ValidationRangeMinInclusive="true" ValidateRequiredField="true" ValidationDataType="Double" Caption="Returned Quantity" ToolTip="Returned quantity." meta:resourcekey="Request_ActualQuantityResource1" />
                                            <ui:UIFieldDropDownList runat="server" ID="Return_ActualUnitOfMeasureID" PropertyName="ActualUnitOfMeasureReturnedID" ValidateRequiredField="true" Caption="Return Unit" OnSelectedIndexChanged="Request_ActualUnitOfMeasureID_SelectedIndexChanged" meta:resourcekey="Request_ActualUnitOfMeasureIDResource1">
                                            </ui:UIFieldDropDownList>
                                        </ui:UIPanel>
                                    </td>
                                </tr>
                            </table>
                            <br />
                            <ui:UIFieldLabel runat="server" ID="Request_ConversionText" PropertyName="ConversionTextReserve" Caption="Conversion Example" meta:resourcekey="Request_ConversionTextResource1" />
                        </ui:UIObjectPanel>
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                        <br />
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview1" Caption="Status History">
                    <web:ActivityHistory runat="server" ID="ActivityHistory" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo">
                    <web:memo runat="server" ID="memo1"></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabAttachments" Caption="Attachments">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
