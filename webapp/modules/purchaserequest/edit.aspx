<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

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
        OPurchaseRequest purchaseRequest = (OPurchaseRequest)panel.SessionObject;

        PurchaseRequestorID.Bind(OUser.GetUsersByRoleAndAboveLocation(
            purchaseRequest.PurchaseRequestor, purchaseRequest.Location, "PURCHASEREQUESTOR"));

        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();

        panel.ObjectPanel.BindObjectToControls(purchaseRequest);
    }

    /// <summary>
    /// Validates and saves the purchase request.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OPurchaseRequest purchaseRequest = panel.SessionObject as OPurchaseRequest;
            panel.ObjectPanel.BindControlsToObject(purchaseRequest);

            if (objectBase.SelectedAction == "Cancel")
            {
                // Validate to ensure that none of the selected
                // WJ items have been generated to RFQs/POs.
                //
                List<Guid> prItemIds = new List<Guid>();
                foreach (OPurchaseRequestItem pri in purchaseRequest.PurchaseRequestItems)
                    prItemIds.Add(pri.ObjectID.Value);
                string lineItems = OPurchaseRequest.ValidatePRLineItemsNotGeneratedToRFQOrPO(prItemIds);
                if (lineItems.Length != 0)
                    PurchaseRequestItems.ErrorMessage = Resources.Errors.PurchaseRequest_CannotBeCancelledItemsGeneratedToRFQOrPO;
            }

            if (!panel.ObjectPanel.IsValid)
                return;
            
            // Save
            //
            purchaseRequest.Save();
            c.Commit();
        }
    }

    /// <summary>
    /// Populates the purchase request item subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void PurchaseRequestItem_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OPurchaseRequest purchaseRequest = panel.SessionObject as OPurchaseRequest;
        OPurchaseRequestItem purchaseRequestItem = PurchaseRequestItem_SubPanel.SessionObject as OPurchaseRequestItem;

        UnitOfMeasureID.Bind(OCode.GetCodesByType("UnitOfMeasure", purchaseRequestItem.UnitOfMeasureID));
        CatalogueID.PopulateTree();
        FixedRateID.PopulateTree();

        ItemNumber.Items.Clear();
        for (int i = 1; i <= purchaseRequest.PurchaseRequestItems.Count + 1; i++)
            ItemNumber.Items.Add(new ListItem(i.ToString(), i.ToString()));

        if (purchaseRequestItem.IsNew && purchaseRequestItem.ItemNumber == null)
            purchaseRequestItem.ItemNumber = purchaseRequest.PurchaseRequestItems.Count + 1;

        PurchaseRequestItem_SubPanel.ObjectPanel.BindObjectToControls(purchaseRequestItem);
    }

    /// <summary>
    /// Validates and inserts the purchase request item into the 
    /// purchase request object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void PurchaseRequestItem_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OPurchaseRequestItem i = (OPurchaseRequestItem)PurchaseRequestItem_SubPanel.SessionObject;

        int itemNumber = i.ItemNumber.Value;
        PurchaseRequestItem_SubPanel.ObjectPanel.BindControlsToObject(i);

        // Update certain fields.
        //
        if (i.ItemType == PurchaseItemType.Material)
        {
            if (i.CatalogueID != null)
            {
                i.ItemDescription = i.Catalogue.ObjectName;
                i.UnitOfMeasureID = i.Catalogue.UnitOfMeasureID;
            }
        }
        else if (i.ItemType == PurchaseItemType.Service)
        {
            if (i.FixedRateID != null)
            {
                i.ItemDescription = i.FixedRate.ObjectName;
                i.UnitOfMeasureID = i.FixedRate.UnitOfMeasureID;
            }
        }
        else if (i.ItemType == PurchaseItemType.Others)
        {
            i.CatalogueID = null;
            i.FixedRateID = null;
        }

        // Add
        //        
        OPurchaseRequest p = (OPurchaseRequest)panel.SessionObject;
        p.PurchaseRequestItems.Add(i);
        p.ReorderItems(i);
        panelLineItems.BindObjectToControls(p);
    }

    //---------------------------------------------------------------    
    // event
    //---------------------------------------------------------------
    protected void PurchaseRequestItem_SubPanel_Deleted(object sender, EventArgs e)
    {
        OPurchaseRequest p = (OPurchaseRequest)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(p);
        p.ReorderItems(null);

        panel.ObjectPanel.BindObjectToControls(p);
    }

    /// <summary>
    /// Hides/shows or enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        OPurchaseRequest obj = (OPurchaseRequest)panel.SessionObject;
        objectBase.ObjectNumberVisible = !obj.IsNew;

        StoreID.Visible = obj.StoreID != null;
        CatalogueID.Visible = ItemType.SelectedValue == PurchaseItemType.Material.ToString();
        UnitOfMeasure.Visible = ItemType.SelectedValue == PurchaseItemType.Material.ToString();
        UnitOfMeasure2.Visible = ItemType.SelectedValue == PurchaseItemType.Service.ToString();
        FixedRateID.Visible = ItemType.SelectedValue == PurchaseItemType.Service.ToString();
        UnitOfMeasureID.Visible = ItemType.SelectedValue == PurchaseItemType.Others.ToString();
        ItemDescription.Visible = ItemType.SelectedValue == PurchaseItemType.Others.ToString();
        radioReceiptMode.Enabled = ItemType.SelectedValue != PurchaseItemType.Material.ToString();
        textQuantityRequired.Enabled = radioReceiptMode.SelectedValue != ReceiptModeType.Dollar.ToString() || ItemType.SelectedValue == PurchaseItemType.Material.ToString();
        

        Workflow_Setting();
    }


    /// <summary>
    /// Hides/shows or enables/disables elements based on the workflow.
    /// </summary>
    protected void Workflow_Setting()
    {
        tabDetails.Enabled = !objectBase.CurrentObjectState.Is("Closed", "Cancelled");
        panelDetails.Enabled = objectBase.CurrentObjectState.Is("Start", "Draft");
        panelLineItems.Enabled = objectBase.CurrentObjectState.Is("Start", "Draft");

        panelButtons.Visible = objectBase.CurrentObjectState.Is("Approved");
        panelAddMultipleItems.Visible = objectBase.CurrentObjectState.Is("Start", "Draft");
    }


    /// <summary>
    /// Occurs when the 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ItemType_SelectedIndexChanged(object sender, EventArgs e)
    {
        OPurchaseRequestItem purchaseRequestItem = PurchaseRequestItem_SubPanel.SessionObject as OPurchaseRequestItem;
        PurchaseRequestItem_SubPanel.ObjectPanel.BindControlsToObject(purchaseRequestItem);

        // If the item is a material item type, then
        // set the receipt mode to quantity, and 
        // disable the receipt mode radio button list.
        //
        if (purchaseRequestItem.ItemType == PurchaseItemType.Material)
            purchaseRequestItem.ReceiptMode = ReceiptModeType.Quantity;
        else if (purchaseRequestItem.ItemType == PurchaseItemType.Service)
        {
            purchaseRequestItem.ReceiptMode = ReceiptModeType.Dollar;
            purchaseRequestItem.QuantityRequired = 1.0M;
        }

        PurchaseRequestItem_SubPanel.ObjectPanel.BindObjectToControls(purchaseRequestItem);
    }


    /// <summary>
    /// Constructs and returns the catalog tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater CatalogueID_AcquireTreePopulater(object sender)
    {
        OPurchaseRequestItem purchaseRequestItem = PurchaseRequestItem_SubPanel.SessionObject as OPurchaseRequestItem;
        return new CatalogueTreePopulater(purchaseRequestItem.CatalogueID, true, true, true, true);
    }


    /// <summary>
    /// Occurs when the user selects a node in the treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CatalogueID_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPurchaseRequestItem i = (OPurchaseRequestItem)PurchaseRequestItem_SubPanel.SessionObject;
        PurchaseRequestItem_SubPanel.ObjectPanel.BindControlsToObject(i);
        PurchaseRequestItem_SubPanel.ObjectPanel.BindObjectToControls(i);
    }


    /// <summary>
    /// Constructs and returns a fixed rate tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater FixedRateID_AcquireTreePopulater(object sender)
    {
        OPurchaseRequestItem purchaseRequestItem = PurchaseRequestItem_SubPanel.SessionObject as OPurchaseRequestItem;
        return new FixedRateTreePopulater(purchaseRequestItem.FixedRateID, false, true);
    }


    /// <summary>
    /// Occurs when the user selects a node in the fixed rate treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void FixedRateID_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPurchaseRequestItem i = (OPurchaseRequestItem)PurchaseRequestItem_SubPanel.SessionObject;
        PurchaseRequestItem_SubPanel.ObjectPanel.BindControlsToObject(i);
        PurchaseRequestItem_SubPanel.ObjectPanel.BindObjectToControls(i);
    }


    /// <summary>
    /// Occurs when the user clicks on the Generate Request for Quotation button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonGenerateRFQ_Click(object sender, EventArgs e)
    {
        List<object> ids = PurchaseRequestItems.GetSelectedKeys();

        PurchaseRequestItems.ErrorMessage = "";
        panel.Message = "";
        if (ids.Count > 0)
        {
            // Validate to ensure that none of the selected
            // WJ items have been generated to RFQs/POs.
            //
            List<Guid> prItemIds = new List<Guid>();
            foreach (Guid id in ids)
                prItemIds.Add(id);
            string lineItems = OPurchaseRequest.ValidatePRLineItemsNotGeneratedToRFQOrPO(prItemIds);
            if (lineItems.Length != 0)
            {
                panel.Message = String.Format(Resources.Errors.PurchaseRequest_LineItemsAlreadyGeneratedIntoRFQOrPOs, lineItems);
                return;
            }
            
            List<OPurchaseRequestItem> items = new List<OPurchaseRequestItem>(); ;
            OPurchaseRequest pr = panel.SessionObject as OPurchaseRequest;
            panel.ObjectPanel.BindControlsToObject(pr);

            foreach (OPurchaseRequestItem pri in pr.PurchaseRequestItems)
            {
                if (ids.Contains(pri.ObjectID.Value))
                    items.Add(pri);
            }

            ORequestForQuotation rfq = ORequestForQuotation.CreateRFQFromPRLineItems(items);
            Window.OpenEditObjectPage(this, "ORequestForQuotation", rfq.ObjectID.Value.ToString(), "");
        }
        else
        {
            PurchaseRequestItems.ErrorMessage = Resources.Errors.PurchaseRequest_NoItemsSelected;
            panel.Message = Resources.Errors.PurchaseRequest_NoItemsSelected;
        }

    }


    /// <summary>
    /// Occurs when the user clicks on the Generate Purchase Order button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonGeneratePO_Click(object sender, EventArgs e)
    {
        List<object> ids = PurchaseRequestItems.GetSelectedKeys();

        PurchaseRequestItems.ErrorMessage = "";
        panel.Message = "";
        if (ids.Count > 0)
        {
            // Validate to ensure that none of the selected
            // WJ items have been generated to RFQs/POs.
            //
            List<Guid> prItemIds = new List<Guid>();
            foreach (Guid id in ids)
                prItemIds.Add(id);
            string lineItems = OPurchaseRequest.ValidatePRLineItemsNotGeneratedToRFQOrPO(prItemIds);
            if (lineItems.Length != 0)
            {
                panel.Message = String.Format(Resources.Errors.PurchaseRequest_LineItemsAlreadyGeneratedIntoRFQOrPOs, lineItems);
                return;
            }
            
            List<OPurchaseRequestItem> items = new List<OPurchaseRequestItem>(); ;
            OPurchaseRequest pr = panel.SessionObject as OPurchaseRequest;
            panel.ObjectPanel.BindControlsToObject(pr);

            foreach (OPurchaseRequestItem pri in pr.PurchaseRequestItems)
            {
                if (ids.Contains(pri.ObjectID.Value))
                    items.Add(pri);
            }

            OPurchaseOrder po = OPurchaseOrder.CreatePOFromPRLineItems(items);
            Window.OpenEditObjectPage(this, "OPurchaseOrder", po.ObjectID.Value.ToString(), "");
        }
        else
        {
            PurchaseRequestItems.ErrorMessage = Resources.Errors.PurchaseRequest_NoItemsSelected;
            panel.Message = Resources.Errors.PurchaseRequest_NoItemsSelected;
        }
    }



    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        OPurchaseRequest purchaseRequest = panel.SessionObject as OPurchaseRequest;
        return new LocationTreePopulater(purchaseRequest.LocationID, false, true, Security.Decrypt(Request["TYPE"]));
    }


    /// <summary>
    /// Updates the requestor dropdown list when the location changes,
    /// and clears the selected equipment ID.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeLocation_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPurchaseRequest purchaseRequest = panel.SessionObject as OPurchaseRequest;
        panel.ObjectPanel.BindControlsToObject(purchaseRequest);

        PurchaseRequestorID.Bind(OUser.GetUsersByRoleAndAboveLocation(
            purchaseRequest.Location, "PURCHASEREQUESTOR"));

        purchaseRequest.EquipmentID = null;
        panel.ObjectPanel.BindObjectToControls(purchaseRequest);
    }


    /// <summary>
    /// Constructs the equipment tree populator
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        OPurchaseRequest purchaseRequest = panel.SessionObject as OPurchaseRequest;
        return new EquipmentTreePopulater(purchaseRequest.EquipmentID, false, true, Security.Decrypt(Request["TYPE"]));
    }


    /// <summary>
    /// Updates the location to the location of the selected equipment.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeEquipment_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPurchaseRequest purchaseRequest = panel.SessionObject as OPurchaseRequest;
        panel.ObjectPanel.BindControlsToObject(purchaseRequest);

        if (purchaseRequest.Equipment != null)
        {
            purchaseRequest.LocationID = purchaseRequest.Equipment.LocationID;
            PurchaseRequestorID.Bind(OUser.GetUsersByRoleAndAboveLocation(
                purchaseRequest.Location, "PURCHASEREQUESTOR"));
            treeLocation.PopulateTree();
        }
        panel.ObjectPanel.BindObjectToControls(purchaseRequest);
    }


    /// <summary>
    /// Occurs when the user changes the receipt mode.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioReceiptMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (radioReceiptMode.SelectedValue == ReceiptModeType.Dollar.ToString())
        {
            textQuantityRequired.Text = "1.00";
        }
    }

    

    /// <summary>
    /// Occurs when the user selects the date required.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void DateRequired_DateTimeChanged(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Pops up a search page to add fixed rates.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddFixedRateItems_Click(object sender, EventArgs e)
    {
        Window.Open("addfixedrate.aspx");
        panel.FocusWindow = false;
    }

    /// <summary>
    /// Pops up a search page to add material items.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddMaterialItems_Click(object sender, EventArgs e)
    {
        Window.Open("addcatalog.aspx");
        panel.FocusWindow = false;
    }


    /// <summary>
    /// Occurs when the user adds selected items.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonItemsAdded_Click(object sender, EventArgs e)
    {
        OPurchaseRequest purchaseRequest = panel.SessionObject as OPurchaseRequest;

        panelLineItems.BindObjectToControls(purchaseRequest);
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
            <web:object runat="server" ID="panel" Caption="Purchase Request" BaseTable="tPurchaseRequest"
                OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave" >
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                    <ui:UITabView ID="tabDetails" runat="server"  Caption="Details"
                        meta:resourcekey="tabDetailsResource1">
                        <web:base ID="objectBase" runat="server" ObjectNumberVisible="false" ObjectNameVisible="false"
                            ObjectNumberEnabled="false" ObjectNumberValidateRequiredField="true" meta:resourcekey="objectBaseResource1">
                        </web:base>
                        <ui:UIPanel runat="server" ID="panelDetails" Width="100%" meta:resourcekey="panelDetailsResource1">
                            <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" PropertyName="LocationID" meta:resourcekey="treeLocationResource1"
                                OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" OnSelectedNodeChanged="treeLocation_SelectedNodeChanged"
                                ValidateRequiredField="true">
                            </ui:UIFieldTreeList>
                            <ui:UIFieldTreeList runat="server" ID="treeEquipment" meta:resourcekey="treeEquipmentResource1" Caption="Equipment" PropertyName="EquipmentID"
                                OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" OnSelectedNodeChanged="treeEquipment_SelectedNodeChanged">
                            </ui:UIFieldTreeList>
                            <ui:UIFieldTextBox ID="Description" runat="server" Caption="Description" PropertyName="Description"
                                MaxLength="255" ValidateRequiredField="True" meta:resourcekey="DescriptionResource1" />
                            <ui:UIFieldDateTime runat='server' ID="DateRequired" Caption="Date Required" ShowTimeControls="False"
                                PropertyName="DateRequired" ValidateRequiredField="True" ImageClearUrl="~/calendar/dateclr.gif"
                                ImageUrl="~/calendar/date.gif" meta:resourcekey="DateRequiredResource1" OnDateTimeChanged="DateRequired_DateTimeChanged" />
                            <ui:UIFieldDropDownList runat="server" ID="PurchaseRequestorID" Caption="Purchasing Requestor"
                                ValidateRequiredField="True" PropertyName="PurchaseRequestorID" meta:resourcekey="PurchaseRequestorIDResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList ID="StoreID" runat="server" Caption="Store" Span="Half" PropertyName="StoreID"
                                meta:resourcekey="StoreIDResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldTextBox ID="txtBackground" runat="server" Caption="Background" meta:resourcekey="txtBackgroundResource1" PropertyName="Background" TextMode="MultiLine" Rows="3"></ui:UIFieldTextBox>
                            <ui:UIFieldTextBox ID="txtScope" meta:resourcekey="txtScopeResource1" runat="server" Caption="Scope" PropertyName="Scope" TextMode="MultiLine" Rows="3"></ui:UIFieldTextBox>
                            <br />
                            <br />
                            <br />
                            <table cellpadding='0' cellspacing='0' style="width: 100%">
                                <tr>
                                    <td style="width: 50%">
                                        <ui:UIPanel ID="Panel1" runat="server" meta:resourcekey="Panel1Resource1">
                                            <asp:Label ID="Label1" runat="server" Font-Bold="True" Text="Ship To:" meta:resourcekey="Label1Resource1"></asp:Label><br />
                                            <ui:UIFieldTextBox ID="ShipToAddress" runat="server" Caption="Address" Rows="4" TextMode="MultiLine"
                                                PropertyName="ShipToAddress" meta:resourcekey="ShipToAddressResource1" />
                                            <ui:UIFieldTextBox ID="ShipToAttention" runat="server" Caption="Attention" PropertyName="ShipToAttention"
                                                meta:resourcekey="ShipToAttentionResource1" />
                                        </ui:UIPanel>
                                    </td>
                                    <td style="width: 50%">
                                        <ui:UIPanel ID="Panel2" runat="server" meta:resourcekey="Panel2Resource1">
                                            <asp:Label ID="Label2" runat="server" Font-Bold="True" Text="Bill To:" meta:resourcekey="Label2Resource1"></asp:Label><br />
                                            <ui:UIFieldTextBox ID="BillToAddress" runat="server" Caption="Address" Rows="4" TextMode="MultiLine"
                                                PropertyName="BillToAddress" meta:resourcekey="BillToAddressResource1" />
                                            <ui:UIFieldTextBox ID="BillToAttention" runat="server" Caption="Attention" PropertyName="BillToAttention"
                                                meta:resourcekey="BillToAttentionResource1" />
                                        </ui:UIPanel>
                                    </td>
                                </tr>
                            </table>
                            <br />
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Line Items" 
                        meta:resourcekey="uitabview4Resource1">
                        <ui:UIPanel runat="server" ID="panelButtons" meta:resourcekey="panelButtonsResource1">
                            <ui:UIButton runat="server" ID="buttonGenerateRFQ" Text="Generate RFQ from Selected Line Items"
                                ImageUrl="~/images/add.gif" OnClick="buttonGenerateRFQ_Click" ConfirmText="Are you sure you wish to generate a Request for Quotation from the selected line items?"
                                meta:resourcekey="buttonGenerateRFQResource1" />
                            <ui:UIButton runat="server" ID="buttonGeneratePO" Text="Generate PO from Selected Line Items"
                                ImageUrl="~/images/add.gif" OnClick="buttonGeneratePO_Click" ConfirmText="Are you sure you wish to generate a Purchase Order from the selected line items?"
                                meta:resourcekey="buttonGeneratePOResource1" />
                            <br />
                            <br />
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panelLineItems" meta:resourcekey="panelLineItemsResource1">
                            <ui:UIPanel runat="server" ID="panelAddMultipleItems" meta:resourcekey="panelAddMultipleItemsResource1">
                                <ui:UIButton runat="server" ID="buttonAddMaterialItems" meta:resourcekey="buttonAddMaterialItemsResource1" ImageUrl="~/images/add.gif" Text="Add Multiple Inventory Items" OnClick="buttonAddMaterialItems_Click" CausesValidation='false' />
                                <ui:UIButton runat="server" ID="buttonAddFixedRateItems" meta:resourcekey="buttonAddFixedRateItemsResource1" ImageUrl="~/images/add.gif" Text="Add Multiple Service Items" OnClick="buttonAddFixedRateItems_Click" CausesValidation='false' />
                                <ui:uibutton runat="server" id="buttonItemsAdded" meta:resourcekey="buttonItemsAddedResource1" CausesValidation="false" OnClick="buttonItemsAdded_Click"></ui:uibutton>
                                <br />
                                <br />
                            </ui:UIPanel>
                            <ui:UIGridView ID="PurchaseRequestItems" runat="server" Caption="Items" PropertyName="PurchaseRequestItems"
                                SortExpression="ItemNumber" KeyName="ObjectID" meta:resourcekey="PurchaseRequestItemsResource1"
                                Width="100%" AllowPaging="True" AllowSorting="True" PagingEnabled="True">
                                <Commands>
                                    <ui:UIGridViewCommand CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                        ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourcekey="UIGridViewCommandResource1">
                                    </ui:UIGridViewCommand>
                                    <ui:UIGridViewCommand CommandText="Add" ImageUrl="~/images/add.gif" CommandName="AddObject"
                                        meta:resourcekey="UIGridViewCommandResource2"></ui:UIGridViewCommand>
                                </Commands>
                                <Columns>
                                    <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                        CommandName="EditObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource1">
                                    </ui:UIGridViewButtonColumn>
                                    <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                        ConfirmText="Are you sure you wish to delete this item?" CommandName="DeleteObject"
                                        HeaderText="" meta:resourcekey="UIGridViewColumnResource2">
                                    </ui:UIGridViewButtonColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="SN" PropertyName="ItemNumber" >
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Ticket" PropertyName="Ticket">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="OpenTime" PropertyName="OpenTime" DataFormatString="{0:yyyy.MM.dd hh:mm}" >
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Type" PropertyName="TypeText">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Size" PropertyName="Size"
                                        DataFormatString="{0:#,##0.00##}" >
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Item" PropertyName="Item.ObjectName">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Price" PropertyName="OpenPrice"
                                        DataFormatString="{0:#,##0.00##}" >
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Price" PropertyName="OpenPrice"
                                        DataFormatString="{0:#,##0.00##}" >
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Price" PropertyName="OpenPrice"
                                        DataFormatString="{0:#,##0.00##}" >
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn Hea
                                    derText="Close Time" PropertyName="CloseTime" DataFormatString="{0:yyyy.MM.dd hh:mm}" >
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="ClosePrice" PropertyName="ClosePrice"
                                        DataFormatString="{0:#,##0.00##}" >
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Commission" PropertyName="Commission"
                                        DataFormatString="{0:#,##0.00##}" >
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewBoundColumn HeaderText="Profit" PropertyName="Profit"
                                        DataFormatString="{0:#,##0.00##}" >
                                    </ui:UIGridViewBoundColumn>
                                </Columns>
                            </ui:UIGridView>
                          <%--  <ui:UIObjectPanel ID="PurchaseRequestItem_Panel" runat="server" meta:resourcekey="PurchaseRequestItem_PanelResource1">
                                <web:subpanel runat="server" ID="PurchaseRequestItem_SubPanel" GridViewID="PurchaseRequestItems"
                                    OnDeleted="PurchaseRequestItem_SubPanel_Deleted"
                                    OnPopulateForm="PurchaseRequestItem_SubPanel_PopulateForm"
                                    MultiSelectColumnNames="ItemNumber,ItemType,CatalogueID,FixedRateID,QuantityRequired"
                                    OnValidateAndUpdate="PurchaseRequestItem_SubPanel_ValidateAndUpdate" />
                                <ui:UIFieldDropDownList ID="ItemNumber" runat="server" Caption="Item Number" PropertyName="ItemNumber"
                                    Span="Half" ValidateRequiredField="True" meta:resourcekey="ItemNumberResource1">
                                </ui:UIFieldDropDownList>
                                <ui:UIFieldRadioList ID="ItemType" runat="server" Caption="Item Type" PropertyName="ItemType"
                                    RepeatColumns="0" OnSelectedIndexChanged="ItemType_SelectedIndexChanged" ValidateRequiredField="True"
                                    meta:resourcekey="ItemTypeResource1">
                                    <Items>
                                        <asp:ListItem Value="0" meta:resourcekey="ListItemResource1" Text="Inventory">
                                        </asp:ListItem>
                                        <asp:ListItem Value="1" meta:resourcekey="ListItemResource2" Text="Service">
                                        </asp:ListItem>
                                        <asp:ListItem Value="2" meta:resourcekey="ListItemResource3">Others</asp:ListItem>
                                    </Items>
                                </ui:UIFieldRadioList>
                                <ui:UIFieldTreeList ID="CatalogueID" runat="server" Caption="Catalog" PropertyName="CatalogueID"
                                    OnAcquireTreePopulater="CatalogueID_AcquireTreePopulater" OnSelectedNodeChanged="CatalogueID_SelectedNodeChanged"
                                    ValidateRequiredField="True" meta:resourcekey="CatalogueIDResource1">
                                </ui:UIFieldTreeList>
                                <ui:UIFieldTreeList ID="FixedRateID" runat="server" Caption="Fixed Rate" PropertyName="FixedRateID"
                                    OnAcquireTreePopulater="FixedRateID_AcquireTreePopulater" OnSelectedNodeChanged="FixedRateID_SelectedNodeChanged"
                                    ValidateRequiredField="True" meta:resourcekey="FixedRateIDResource1">
                                </ui:UIFieldTreeList>
                                <ui:UIFieldLabel runat="server" ID="UnitOfMeasure" Caption="Unit of Measure" PropertyName="Catalogue.UnitOfMeasure.ObjectName"
                                    meta:resourcekey="UnitOfMeasureResource1" />
                                <ui:UIFieldLabel runat="server" ID="UnitOfMeasure2" Caption="Unit of Measure" PropertyName="FixedRate.UnitOfMeasure.ObjectName"
                                    meta:resourcekey="UnitOfMeasure2Resource1" />
                                <ui:UIFieldTextBox ID="ItemDescription" runat="server" Caption="Description" PropertyName="ItemDescription"
                                    MaxLength="255" ValidateRequiredField="True" meta:resourcekey="ItemDescriptionResource1" />
                                <ui:UIFieldDropDownList runat="server" ID="UnitOfMeasureID" Caption="Unit of Measure"
                                    PropertyName="UnitOfMeasureID" ValidateRequiredField="True" meta:resourcekey="UnitOfMeasureIDResource1" />
                                <ui:UIFieldRadioList runat="server" ID="radioReceiptMode" meta:resourcekey="radioReceiptModeResource1" PropertyName="ReceiptMode" Caption="Receipt Mode" OnSelectedIndexChanged="radioReceiptMode_SelectedIndexChanged">
                                    <Items>
                                        <asp:ListItem value="0" meta:resourcekey="ListItemResource4">Receive by Quantity</asp:ListItem>
                                        <asp:ListItem value="1" meta:resourcekey="ListItemResource5">Receive by Dollar Amount</asp:ListItem>
                                    </Items>
                                </ui:UIFieldRadioList>
                                <ui:UIFieldTextBox ID="textQuantityRequired" runat="server" Caption="Quantity Required"
                                    PropertyName="QuantityRequired" Span="Half" ValidateDataTypeCheck="True" ValidateRangeField="True"
                                    ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMax="99999999999999"
                                    ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="UIFieldTextBox1Resource1" />
                            </ui:UIObjectPanel>--%>
                        </ui:UIPanel>
                    </ui:UITabView>

                    <ui:UITabView runat="server" ID="uitabview1" Caption="Status History" meta:resourcekey="uitabview1Resource1">
                        <web:ActivityHistory runat="server" ID="ActivityHistory" />
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo"  meta:resourcekey="uitabview3Resource1">
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="uitabview2" runat="server"  Caption="Attachments"
                        meta:resourcekey="uitabview2Resource1">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>

