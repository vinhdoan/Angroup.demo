<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>

<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OEquipment Equipment = panel.SessionObject as OEquipment;

        if (Request["TREEOBJID"] != null && TablesLogic.tEquipment[Security.DecryptGuid(Request["TREEOBJID"])] != null)
            Equipment.ParentID = Security.DecryptGuid(Request["TREEOBJID"]);


        ParentID.Enabled = Equipment.IsNew || Equipment.ParentID != null;
        ParentID.PopulateTree();
        EquipmentTypeID.PopulateTree();
        LocationID.PopulateTree();
        dropStoreID.Bind(OStore.FindAccessibleStores(AppSession.User, "OEquipment", Equipment.StoreID));

        if (Equipment.Status == EquipmentStatusType.PendingWriteOff ||
            Equipment.Status == EquipmentStatusType.WrittenOff)
        {
            dropStatus.Enabled = false;
        }
        else
        {
            // Removes the last two items in the list
            // (the last two items should usually be the 
            // PendingWriteOff/WrittenOff statuses)
            //dropStatus.Items.RemoveAt(dropStatus.Items.Count - 1);
            //dropStatus.Items.RemoveAt(dropStatus.Items.Count - 1);
        }

        IsPhysicalEquipment.Enabled = Equipment.IsNew;
        buttonCreatePoints.Enabled = AppSession.User.AllowCreate("OPoint");
        UIGridViewReading.Columns[0].Visible = AppSession.User.AllowEditAll("OPoint");
        UIGridViewEvent.Columns[0].Visible = AppSession.User.AllowEditAll("OOPCAEEvent");
        buttonEditLocation.Visible = AppSession.User.AllowEditAll("OLocation");
        buttonViewLocation.Visible = AppSession.User.AllowViewAll("OLocation");
        buttonEditEquipmentType.Visible = AppSession.User.AllowEditAll("OEquipmentType");
        buttonViewEquipmentType.Visible = AppSession.User.AllowViewAll("OEquipmentType");
        
        // Checks to ensure if the Equipment is within a locked store bin, 
        // then disable the Location treeview and Store dropdownlist 
        // (to disallow the user from moving it).
        //
        OStoreBin storeBin = TablesLogic.tStoreBin.Load(
            TablesLogic.tStoreBin.StoreBinItems.ObjectID == Equipment.StoreBinItemID);
        if (storeBin != null && storeBin.IsLocked == 1)
        {
            panelLocation.Enabled = false;
            hintStoreBinLocked.Visible = true;
        }
        //binding reminder users
        ddlReminder1.Bind(OUser.GetUsersByRole("ASSETADMIN"));
        ddlReminder2.Bind(OUser.GetUsersByRole("ASSETADMIN"));
        ddlReminder3.Bind(OUser.GetUsersByRole("ASSETADMIN"));
        ddlReminder4.Bind(OUser.GetUsersByRole("ASSETADMIN"));

        //populate currency drop down
        dropCurrency.Bind(OCurrency.GetAllCurrencies());
        //populate every PO invoice number
        PurchaseOrderInvoiceNumbers.Text = Equipment.PurchaseOrderInvoiceNumbers();

        Designation.Visible = ConfigurationManager.AppSettings["CustomizedInstance"] == "IT";
        
        panel.ObjectPanel.BindObjectToControls(Equipment);
    }

    /// <summary>
    /// Validates and saves the equipment object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OEquipment Equipment = panel.SessionObject as OEquipment;
            panel.ObjectPanel.BindControlsToObject(Equipment);

            // Validate
            //
            if (Equipment.IsDuplicateName())
                objectBase.ObjectName.ErrorMessage = Resources.Errors.General_NameDuplicate;
            if (Equipment.IsCyclicalReference())
                ParentID.ErrorMessage = Resources.Errors.Code_CyclicalReference;
            if (Equipment.Parent != null && Equipment.Parent.IsPhysicalEquipment == 1 && Equipment.IsPhysicalEquipment == 0)
                ParentID.ErrorMessage = Resources.Errors.Equipment_ParentIDInvalid;
            if (!Equipment.ValidateEquipmentNotMovingToLockedBin())
            {
                LocationID.ErrorMessage = Resources.Errors.Equipment_MovingToLockedStoreBin;
                dropStoreID.ErrorMessage = Resources.Errors.Equipment_MovingToLockedStoreBin;
            }

            if (!panel.ObjectPanel.IsValid)
                return;
            if (!IsSharedOwnership.Checked)
                Equipment.OwnershipPercentage = null;
            // Save
            //
            Equipment.Save();
            c.Commit();
        }
    }

    /// <summary>
    /// Constructs and returns the equipment tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater ParentID_AcquireTreePopulater(object sender)
    {
        return new EquipmentTreePopulater(panel.SessionObject.ParentID, true, true, Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// Constructs and returns the equipment type tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater EquipmentTypeID_AcquireTreePopulater(object sender)
    {
        return new EquipmentTypeTreePopulater(((OEquipment)panel.SessionObject).EquipmentTypeID, true, true);
    }

    /// <summary>
    /// Constructs and returns the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater LocationID_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(((OEquipment)panel.SessionObject).LocationID, false, true,
            Security.Decrypt(Request["TYPE"]), false, false);
    }

    /// <summary>
    /// Occurs when user clicks the radio button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void IsPhysicalEquipment_SelectedIndexChanged(object sender, EventArgs e)
    {
        //once the equipment is not a physical, call the Update customized to delete attribute fields     
        if (Convert.ToInt32(this.IsPhysicalEquipment.SelectedValue) == 0)
        {
            panel.UpdateCustomizedAttributeFields(null);
            this.EquipmentTypeID.SelectedValue = "";
        }
        else if (this.EquipmentTypeID.SelectedValue != "")
            panel.UpdateCustomizedAttributeFields(new Guid(EquipmentTypeID.SelectedValue));
    }

    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        OEquipment Equipment = panel.SessionObject as OEquipment;
        tabPoints.Visible = !Equipment.IsNew;
        if (Equipment.IsNew)
        {
            if (Equipment.Parent != null && Equipment.Parent.IsPhysicalEquipment == 1)
            {
                Equipment.IsPhysicalEquipment = 1;
                IsPhysicalEquipment.SelectedValue = "1";
                IsPhysicalEquipment.Enabled = false;
            }
            else
                IsPhysicalEquipment.Enabled = true;
            
        }
                        
        InvoiceNumber.Visible = Equipment.PurchaseOrderID == null;
        PurchaseOrderInvoiceNumbers.Visible = Equipment.PurchaseOrderID != null;
        OwnershipPercentage.Visible = IsSharedOwnership.Checked;
        panelEquipment1.Visible = IsPhysicalEquipment.SelectedIndex == 1;
        if (UIGridViewEvent.Rows.Count == 0)
            tabEvents.Visible = false;
      
            textPurchaseOrderNumber.Enabled = Equipment.PurchaseOrderID == null;
            PriceAtCurrency.Enabled = Equipment.PurchaseOrderID == null;
            dropCurrency.Enabled = Equipment.PurchaseOrderID == null;
            textVendor.Enabled = Equipment.PurchaseOrderID == null;
     
        LocationID.Visible = radioIsInstore.SelectedValue == "0";
        dropStoreID.Visible = radioIsInstore.SelectedValue == "1";

        //11th March 2011, Joey
        //navigate to purchase order view when user clicks on the context menu option beside the purchase order number
        buttonViewPurchaseOrder.Visible =
            !textPurchaseOrderNumber.Enabled
            &&
            (
                AppSession.User.AllowViewAll("OPurchaseOrder")
                ||
                OActivity.CheckAssignment(AppSession.User, Equipment.PurchaseOrderID)
            );

        //11th March 2011, Joey
        //navigate to purchase order edit when user clicks on the context menu option beside the purchase order number        
        buttonEditPurchaseOrder.Visible =
            !textPurchaseOrderNumber.Enabled
            &&
            (
                AppSession.User.AllowEditAll("OPurchaseOrder")
                ||
                OActivity.CheckAssignment(AppSession.User, Equipment.PurchaseOrderID)
            );
        

    }

    /// <summary>
    /// Occurs when user clicks on the equipment type drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void EquipmentTypeID_SelectedNodeChanged(object sender, EventArgs e)
    {
        if (this.EquipmentTypeID.SelectedValue == "")
            panel.UpdateCustomizedAttributeFields(null);
        else
            panel.UpdateCustomizedAttributeFields(new Guid(this.EquipmentTypeID.SelectedValue));
    }


    protected void buttonRefresh_Click(object sender, EventArgs e)
    {
        OEquipment eqp = panel.SessionObject as OEquipment;
        panel.ObjectPanel.BindObjectToControls(eqp);        
    }

    protected void buttonRefreshEvent_Click(object sender, EventArgs e)
    {
        OEquipment eqp = panel.SessionObject as OEquipment;
        panel.ObjectPanel.BindObjectToControls(eqp);         
    }
    
    protected void UIGridViewReading_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "EditObject")
        {
             Window.OpenEditObjectPage(this.Page, "OPoint", dataKeys[0].ToString(), "");
        }
    }

    protected void UIGridViewEvent_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "EditObject")
        {
            Window.OpenEditObjectPage(this.Page, "OOPCAEEvent", dataKeys[0].ToString(), "");
        }
    }

    protected void buttonCreatePoints_Click(object sender, EventArgs e)
    {
        OEquipment eqp = panel.SessionObject as OEquipment;
        tabPoints.BindControlsToObject(eqp);
        if (eqp.EquipmentType == null)
        {
            panel.Message = Resources.Errors.Equipment_EquipmentTypeNotSelected;
            return;
        }
        
        DataList<OEquipmentTypePoint> etp = eqp.EquipmentType.EquipmentTypePoints;
        if (etp.Count == 0)
            panel.Message = Resources.Errors.Equipment_UnableToCreatePointsNoPoints;
        else
            eqp.CreatePoints();

        tabPoints.BindObjectToControls(eqp);
    }
 
 

    protected void UIGridViewReading_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        using (Connection c = new Connection())
        {
            if (e.Row.RowType.ToString() == "DataRow")
            {
                Guid id = new Guid(UIGridViewReading.DataKeys[e.Row.RowIndex].Value.ToString().Trim());
                OPoint pt = TablesLogic.tPoint.Load(id);
                if (pt == null)
                {   
                    e.Row.Cells[1].Controls[0].Visible=false;
                }
            }
        }        
    }


    protected void UIGridViewReading_PreRender(object sender, EventArgs e)
    {

    }

    
    /// <summary>
    /// Opens the location for editing.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonEditLocation_Click(object sender, EventArgs e)
    {
        if (LocationID.SelectedValue != "")
            Window.OpenEditObjectPage(this, "OLocation", LocationID.SelectedValue, "");
    }


    /// <summary>
    /// Opens the location for viewing.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonViewLocation_Click(object sender, EventArgs e)
    {
        if (LocationID.SelectedValue != "")
            Window.OpenViewObjectPage(this, "OLocation", LocationID.SelectedValue, "");
    }


    /// <summary>
    /// Opens the location for editing.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonEditEquipmentType_Click(object sender, EventArgs e)
    {
        if (EquipmentTypeID.SelectedValue != "")
            Window.OpenEditObjectPage(this, "OEquipmentType", EquipmentTypeID.SelectedValue, "");
    }

    //11th March 2011, Joey
    //navigate to purchase order view when user clicks on the context menu option beside the purchase order number
    protected void buttonViewPurchaseOrder_Click(object sender, EventArgs e)
    {
        if (textPurchaseOrderNumber.Text.Trim().Length > 0)
        {
            OEquipment equipment = panel.SessionObject as OEquipment;
            
            if (equipment.PurchaseOrderID != null)
                Window.OpenViewObjectPage(this, "OPurchaseOrder", equipment.PurchaseOrderID.ToString(), "");
        }            
    }

    //11th March 2011, Joey
    //navigate to purchase order edit when user clicks on the context menu option beside the purchase order number    
    protected void buttonEditPurchaseOrder_Click(object sender, EventArgs e)
    {
        if (textPurchaseOrderNumber.Text.Trim().Length > 0)
        {
            OEquipment equipment = panel.SessionObject as OEquipment;

            if (equipment.PurchaseOrderID != null)
                Window.OpenEditObjectPage(this, "OPurchaseOrder", equipment.PurchaseOrderID.ToString(), "");
        }            
    }     

    /// <summary>
    /// Opens the location for viewing.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonViewEquipmentType_Click(object sender, EventArgs e)
    {
        if (EquipmentTypeID.SelectedValue != "")
            Window.OpenViewObjectPage(this, "OEquipmentType", EquipmentTypeID.SelectedValue, "");
    }

    
    
    /// <summary>
    /// Occurs when the user selects the radio button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioIsInstore_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    protected void Reminder_SubPanel_PopulateForm(object sender, EventArgs e)
    {
       
        OEquipmentReminder reminder = Reminder_SubPanel.SessionObject as OEquipmentReminder;
        rdl_ReminderType.Bind(OCode.GetCodesByType("EquipmentReminderType",reminder.ReminderTypeID));
        Reminder_SubPanel.ObjectPanel.BindObjectToControls(reminder);
    }

    protected void Reminder_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OEquipment equipment = panel.SessionObject as OEquipment;
        OEquipmentReminder reminder = Reminder_SubPanel.SessionObject as OEquipmentReminder;
        Reminder_SubPanel.ObjectPanel.BindControlsToObject(reminder);
        equipment.EquipmentReminders.Add(reminder);
        Reminder_Panel.BindObjectToControls(equipment);
    }

    protected void IsSharedOwnership_CheckedChanged(object sender, EventArgs e)
    {

    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Equipment" BaseTable="tEquipment"
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Details" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" ObjectNameTooltip="The equipment name as displayed on screen."
                            meta:resourcekey="objectBaseResource1"></web:base>
                        <ui:uifieldtextbox runat="server" id="textRunningNumberCode" Caption="Running Number Code" PropertyName="RunningNumberCode" meta:resourcekey="textRunningNumberCodeResource1" InternalControlWidth="95%"></ui:uifieldtextbox>
                        <ui:UIFieldTreeList runat="server" ID="ParentID" PropertyName="ParentID" Caption="Belongs Under"
                            OnAcquireTreePopulater="ParentID_AcquireTreePopulater" ValidateRequiredField="True"
                            ToolTip="The equipment or the folder under which this equipment belongs." meta:resourcekey="ParentIDResource1"  ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                        <ui:UIFieldRadioList runat="server" ID="IsPhysicalEquipment" PropertyName="IsPhysicalEquipment"
                            Caption="Folder/Physical" OnSelectedIndexChanged="IsPhysicalEquipment_SelectedIndexChanged"
                            ValidateRequiredField="True" ToolTip="Indicates if this item is a folder or a physical equipment."
                            meta:resourcekey="IsPhysicalEquipmentResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource1" Text="Folder &#160;"></asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource2" Text="Physical Equipment"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="panelEquipment1" meta:resourcekey="panelEquipment1Resource1" BorderStyle="NotSet">
                            <ui:UIFieldTreeList runat="server" ID="EquipmentTypeID" PropertyName="EquipmentTypeID"
                                Caption="Equipment Type" OnAcquireTreePopulater="EquipmentTypeID_AcquireTreePopulater"
                                ValidateRequiredField="True" ToolTip="The type of this equipment." OnSelectedNodeChanged="EquipmentTypeID_SelectedNodeChanged"
                                meta:resourcekey="EquipmentTypeIDResource1"  ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                                <ContextMenuButtons>
                                    <ui:UIButton runat="server" id="buttonEditEquipmentType" Text="Edit Equipment Type" AlwaysEnabled="True" ImageUrl="~/images/edit.gif" ConfirmText="Please remember to save this Equipment before editing the Equipment Type.\n\nAre you sure you want to continue?" OnClick="buttonEditEquipmentType_Click" CausesValidation="False" meta:resourcekey="buttonEditEquipmentTypeResource1"  />
                                    <ui:UIButton runat="server" id="buttonViewEquipmentType" Text="View Equipment Type" AlwaysEnabled="True" ImageUrl="~/images/view.gif" ConfirmText="Please remember to save this Equipment before viewing the Equipment Type.\n\nAre you sure you want to continue?" OnClick="buttonViewEquipmentType_Click" CausesValidation="False" meta:resourcekey="buttonViewEquipmentTypeResource1"  />
                                </ContextMenuButtons>
                            </ui:UIFieldTreeList>
                            <ui:uipanel runat="server" id="panelLocation" BorderStyle="NotSet" meta:resourcekey="panelLocationResource1">
                                <ui:uifieldradiolist runat="server" id="radioIsInstore" PropertyName="IsInStore" caption="Store/Location" validaterequiredfield="True" OnSelectedIndexChanged="radioIsInstore_SelectedIndexChanged" meta:resourcekey="radioIsInstoreResource1" TextAlign="Right">   
                                    <Items>
                                        <asp:ListItem value="0" meta:resourcekey="ListItemResource3" 
                                            Text="This equipment is currently in a Location."></asp:ListItem>
                                        <asp:ListItem value="1" meta:resourcekey="ListItemResource4" 
                                            Text="This equipment is currently in a Store."></asp:ListItem>
                                    </Items>
                                </ui:uifieldradiolist>
                                <ui:UIFieldTreeList runat="server" ID="LocationID" PropertyName="LocationID" Caption="Location"
                                    OnAcquireTreePopulater="LocationID_AcquireTreePopulater" ValidateRequiredField="True"
                                    ToolTip="The location in which this equipment resides." meta:resourcekey="LocationIDResource1"  ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                                    <ContextMenuButtons>
                                        <ui:UIButton runat="server" id="buttonEditLocation" Text="Edit Location" AlwaysEnabled="True" ImageUrl="~/images/edit.gif" ConfirmText="Please remember to save this Equipment before editing the Location.\n\nAre you sure you want to continue?" OnClick="buttonEditLocation_Click" CausesValidation="False" meta:resourcekey="buttonEditLocationResource1"  />
                                        <ui:UIButton runat="server" id="buttonViewLocation" Text="View Location" AlwaysEnabled="True" ImageUrl="~/images/view.gif" ConfirmText="Please remember to save this Equipment before viewing the Location.\n\nAre you sure you want to continue?" OnClick="buttonViewLocation_Click" CausesValidation="False" meta:resourcekey="buttonViewLocationResource1"  />
                                    </ContextMenuButtons>
                                </ui:UIFieldTreeList>
                                <ui:uifielddropdownlist runat="server" id="dropStoreID" PropertyName="StoreID" Caption="Store" ValidaterequiredField="True" meta:resourcekey="dropStoreIDResource1">
                                </ui:uifielddropdownlist>
                                <ui:uihint runat="server" id="hintStoreBinLocked" Text="The location or the store bin is currently locked for stock-taking" Visible="False" meta:resourcekey="hintStoreBinLockedResource1"></ui:uihint>
                            </ui:uipanel>
                            <ui:UIFieldDropDownList ID="dropStatus" runat="server" Caption="Status" 
                                PropertyName="Status" meta:resourcekey="dropStatusResource1" >
                                <Items>
                                    <asp:ListItem Value="4" Text="Active" meta:resourcekey="ListItemResource5"></asp:ListItem>
                                    <asp:ListItem Value="5" Text="Damaged" meta:resourcekey="ListItemResource6"></asp:ListItem>
                                    <asp:ListItem Value="6" Text="In-Repair" meta:resourcekey="ListItemResource7"></asp:ListItem>
                                    <asp:ListItem Value="7" Text="Written Off" meta:resourcekey="ListItemResource9"></asp:ListItem>
                                </Items>
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldTextBox runat="server" ID="SerialNumber" PropertyName="SerialNumber" Span="Half"
                                Caption="Serial Number" ToolTip="The serial number of this equipment." meta:resourcekey="SerialNumberResource1" InternalControlWidth="95%" />
                            <ui:UIFieldTextBox runat="server" ID="ModelNumber" PropertyName="ModelNumber" Span="Half"
                                Caption="Model Number" ToolTip="The model number of this equipment." meta:resourcekey="ModelNumberResource1" InternalControlWidth="95%" />
                            <ui:UIFieldTextBox runat="server" ID="Barcode" PropertyName="Barcode" Span="Half"
                                Caption="Barcode" ToolTip="The barcode identifier of this equipment." meta:resourcekey="BarcodeResource1" InternalControlWidth="95%" />
                            <ui:UIFieldDateTime runat="server" ID="DateOfManufacture" PropertyName="DateOfManufacture"
                                Span="Half" Caption="Date of Manufacture" ToolTip="Date of manufacture of the equipment."
                                ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="" 
                                meta:resourcekey="DateOfManufactureResource1" ShowDateControls="True" />
                            <ui:uifieldtextbox runat="server" id="textMake" PropertyName="Make" 
                                Caption="Make" Span="Half" InternalControlWidth="95%" 
                                meta:resourcekey="textMakeResource1"></ui:uifieldtextbox>
                            <ui:uifieldtextbox runat="server" id="textSoftwareVersionNumber" 
                                PropertyName="SoftwareVersionNumber" Caption="Version Number" Span="Half" 
                                InternalControlWidth="95%" 
                                meta:resourcekey="textSoftwareVersionNumberResource1"></ui:uifieldtextbox>
                            <ui:UIFieldDropDownList runat="server" ID="Designation" PropertyName="Designation" Caption="Designation" Span="Half" meta:resourcekey="DesignationResource1">
                                <Items>
                                    <asp:ListItem Text="" Value=""></asp:ListItem>
                                    <asp:ListItem Text="Testing" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="Production" Value="1"></asp:ListItem>
                                </Items>
                            </ui:UIFieldDropDownList>
                            <ui:uifieldtextbox runat="server" id="textVendor" PropertyName="Vendor" 
                                Caption="Vendor" InternalControlWidth="95%" 
                                meta:resourcekey="textVendorResource1"></ui:uifieldtextbox>
                            <ui:uifieldtextbox runat="server" id="textDescription" 
                                PropertyName="Description" Caption="Description" textmode="MultiLine" Rows="5" 
                                InternalControlWidth="95%" meta:resourcekey="textDescriptionResource1"></ui:uifieldtextbox>
                            <ui:UISeparator runat="server" ID="sep1" Caption="Ownership"
                                meta:resourcekey="sep1Resource1"></ui:UISeparator>
                            <ui:UIFieldDateTime runat="server" ID="DateOfOwnership" PropertyName="DateOfOwnership"
                                Span="Half" Caption="Date of Ownership" ToolTip="Date the equipment was purchased."
                                ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="" 
                                meta:resourcekey="DateOfOwnershipResource1" ShowDateControls="True" />
                            <ui:UIFieldTextBox runat="server" ID="PriceAtOwnership" PropertyName="PriceAtOwnership" ValidateRequiredField="True"
                                Span="Half" Caption="Price at Ownership ($)" ToolTip="The price of the equipment when purchased." DataFormatString="{0:n}"
                                ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" 
                                ValidationRangeMin="0" ValidationRangeMax="99999999999999" ValidationRangeType="Currency"
                                meta:resourcekey="PriceAtOwnershipResource1" InternalControlWidth="95%" />
                            <ui:UIFieldDropDownList runat="server" ID="dropCurrency" PropertyName="CurrencyID" Span="Half"
                            Caption="Currency" meta:resourcekey="dropCurrencyResource1"></ui:UIFieldDropDownList>
                            <ui:UIFieldTextBox runat="server" ID="PriceAtCurrency" PropertyName="PriceAtCurrency" DataFormatString="{0:n}"
                             Caption="Price at Currency" meta:resourcekey="PriceAtCurrencyResource1" 
                                Span="Half" InternalControlWidth="95%"></ui:UIFieldTextBox>
                             <ui:UIFieldTextBox runat="server" ID="VolumeLicense" PropertyName="VolumeLicense"
                             Caption="No. of license(s)" meta:resourcekey="VolumeLicenseResource1" 
                                Span="Half" InternalControlWidth="95%"></ui:UIFieldTextBox>
                            <ui:UIFieldCheckBox runat="server" ID="IsSharedOwnership" 
                                PropertyName="IsSharedOwnership" meta:resourcekey="IsSharedOwnershipResource1" 
                                Caption="Shared Ownership?" 
                                Text="Yes, this Equipment is co-owned with another entity" 
                                OnCheckedChanged="IsSharedOwnership_CheckedChanged" TextAlign="Right">
                                </ui:UIFieldCheckBox>
                            <ui:UIFieldTextBox runat="server" ID="OwnershipPercentage" 
                                PropertyName="OwnershipPercentage" Caption="Ownership Percentage (%)" 
                                ValidateDataTypeCheck="True" Span="Half"
                              ValidationDataType="Currency" ValidateRangeField="True" 
                                ValidationRangeMin="0" InternalControlWidth="95%" 
                                meta:resourceKey="OwnershipPercentageResource1" >
                               </ui:UIFieldTextBox>
                            <ui:UISeparator runat="server" ID="UISeparator1" Caption="Warranty" meta:resourcekey="UISeparator1Resource1"
                                ></ui:UISeparator>
                            <ui:UIFieldTextBox runat="server" ID="Warranty" Caption="Warranty" 
                                meta:resourcekey="WarrantyResource1" PropertyName="Warranty" MaxLength="255" 
                                InternalControlWidth="95%">
                            </ui:UIFieldTextBox>
                            <table >
                            <tr>
                            <td><asp:Label ID="Label2" runat="server" Text="Warranty Period:" meta:resourcekey="WarrantyPeriodResource1" Width="120px"></asp:Label>
                            </td>
                            <td>
                            <ui:UIFieldTextBox runat="server" ID="txtWarrantyPeriod" Caption="Warranty Period"
                            PropertyName="WarrantyPeriod" ValidateDataTypeCheck="True" ValidationDataType="Integer"
                            Span="Half" InternalControlWidth="100px" FieldLayout="Flow" ShowCaption="False" 
                                    meta:resourceKey="txtWarrantyPeriodResource1" >
                        </ui:UIFieldTextBox>
                        <ui:UIFieldDropDownList runat="server" ID="ddlWarrantyUnit" Caption="Warranty Unit"
                            PropertyName="WarrantyUnit" Span="Half" InternalControlWidth="100px" 
                                    FieldLayout="Flow" ShowCaption="False" 
                                    meta:resourceKey="ddlWarrantyUnitResource1" >
                            <Items>
                                <asp:ListItem Value="0" meta:resourceKey="ListItemResource10" Text="day(s)"  ></asp:ListItem>
                                <asp:ListItem Value="1" meta:resourceKey="ListItemResource11" Text="week(s)"  ></asp:ListItem>
                                <asp:ListItem Value="2" meta:resourceKey="ListItemResource12" Text="month(s)"  ></asp:ListItem>
                                <asp:ListItem Value="3" meta:resourceKey="ListItemResource13" Text="year(s)"  ></asp:ListItem>
                            </Items>
                        </ui:UIFieldDropDownList>
                            </td>
                            </tr>
                            </table>
                            <ui:UIFieldTextBox runat="server" ID="LifeSpan" PropertyName="LifeSpan" Span="Half"
                                Caption="Life Span (years)" ToolTip="The estimated life span of the equipment in years."
                                ValidateDataTypeCheck="True" ValidationDataType="Integer" ValidateRangeField="True"
                                ValidationRangeMin="0" ValidationRangeType="Integer" meta:resourcekey="LifeSpanResource1" InternalControlWidth="95%" />
                            <ui:UIFieldDateTime runat="server" ID="WarrantyExpiryDate" PropertyName="WarrantyExpiryDate"
                                Span="Half" Caption="Warranty Expiry" ToolTip="The date on which the warranty of the equipment expires."
                                ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="" 
                                meta:resourcekey="WarrantyExpiryDateResource1" ShowDateControls="True" />
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:uitabview runat="server" id="tabOtherInformation" CAption="Other Info" 
                        BorderStyle="NotSet" meta:resourcekey="tabOtherInformationResource1">
                        <ui:uiseparator runat="server" id="sepSAP" 
                            Caption="SAP/Procurement Information" meta:resourcekey="sepSAPResource1" />
                        <ui:uifieldtextbox runat="server" id="textSAPIOCenter" 
                            PropertyName="SAPIOCenter" Caption="SAP IO Center" InternalControlWidth="95%" 
                            meta:resourcekey="textSAPIOCenterResource1"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat="server" id="textSAPFixedAssetCode" 
                            PropertyName="SAPFixedAssetCode" Caption="SAP FA Code" 
                            InternalControlWidth="95%" meta:resourcekey="textSAPFixedAssetCodeResource1"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat="server" id="textSAPFixedAssetSerial" 
                            PropertyName="SAPFixedAssetSerial" Caption="SAP FA Serial" 
                            InternalControlWidth="95%" meta:resourcekey="textSAPFixedAssetSerialResource1"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat="server" id="textPurchaseOrderNumber" 
                            PropertyName="PurchaseOrderNumber" Caption="PO Number" 
                            InternalControlWidth="95%" meta:resourcekey="textPurchaseOrderNumberResource1" ContextMenuAlwaysEnabled="true">
                            <ContextMenuButtons>
                                <ui:UIButton visible="false" runat="server" id="buttonViewPurchaseOrder" Text="View Purchase Order" AlwaysEnabled="True" ImageUrl="~/images/view.gif" ConfirmText="Please remember to save this Equipment before viewing the Purchase Order.\n\nAre you sure you want to continue?" OnClick="buttonViewPurchaseOrder_Click" meta:resourcekey="buttonViewPurchaseOrderResource1"/>
                                <ui:UIButton visible="false" runat="server" id="buttonEditPurchaseOrder" Text="Edit Purchase Order" AlwaysEnabled="True" ImageUrl="~/images/edit.gif" ConfirmText="Please remember to save this Equipment before editing the Purchase Order.\n\nAre you sure you want to continue?" OnClick="buttonEditPurchaseOrder_Click" meta:resourcekey="buttonEditPurchaseOrderResource1"/>
                            </ContextMenuButtons>
                        </ui:uifieldtextbox>
                        <ui:UIFieldTextBox runat="server" ID="InvoiceNumber" Caption="Invoice Number" 
                            PropertyName="InvoiceNumber" MaxLength="255" InternalControlWidth="95%" 
                            meta:resourceKey="InvoiceNumberResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldLabel runat="server" ID="PurchaseOrderInvoiceNumbers" 
                            Caption="Invoice Number" DataFormatString="" 
                            meta:resourceKey="PurchaseOrderInvoiceNumbersResource1" >
                        </ui:UIFieldLabel>
                        
                        <ui:uiseparator runat="server" id="Uiseparator3" Caption="Assignment" 
                            meta:resourcekey="Uiseparator3Resource1" />
                        <ui:uifieldtextbox runat="server" id="textOwnership" PropertyName="Ownership" 
                            Caption="Ownership" InternalControlWidth="95%" 
                            meta:resourcekey="textOwnershipResource1"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat="server" id="textDivision" PropertyName="Division" 
                            Caption="Division" InternalControlWidth="95%" 
                            meta:resourcekey="textDivisionResource1"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat="server" id="textDepartment" PropertyName="Department" 
                            Caption="Department" InternalControlWidth="95%" 
                            meta:resourcekey="textDepartmentResource1"></ui:uifieldtextbox>
                    </ui:uitabview>
                    <ui:UITabView ID="attributeTabView" runat="server" Caption="Attributes" meta:resourcekey="attributeTabViewResource1" BorderStyle="NotSet">
                    </ui:UITabView>
                    
                    <ui:UITabView runat="server" ID="tabPoints" Caption="Points" meta:resourcekey="tabPointsResource1" BorderStyle="NotSet"
                        >
                        <ui:UIButton runat="server" ID="buttonRefresh" Text="Refresh" ImageUrl="~/images/refresh.gif" OnClick="buttonRefresh_Click" meta:resourcekey="buttonRefreshResource1" />
                        <ui:UIButton runat="server" ID="buttonCreatePoints" Text="Create Points for this Equipment Type" ImageUrl="~/images/add.png" OnClick="buttonCreatePoints_Click"  meta:resourcekey="buttonCreatePointsResource1"
                         ConfirmText="Are you sure you want to create points for the selected equipment type? Existing points will not be removed or overwritten."/>
                        <br />
                        <br />
                      
                       <ui:UIGridView ID="UIGridViewReading" runat="server" Caption="Readings" PropertyName="Point" 
                            KeyName="ObjectID" meta:resourcekey="ReadingResource1" Width="100%" 
                            CheckBoxColumnVisible="False"  OnAction="UIGridViewReading_Action"  
                            OnRowDataBound="UIGridViewReading_RowDataBound" 
                            OnPreRender="UIGridViewReading_PreRender" DataKeyNames="ObjectID" 
                            GridLines="Both" RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ConfirmText="Please remember to save this Equipment before editing the Point.\n\nAre you sure you want to continue?" ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Point Name" meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Description" HeaderText="Description" meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="Description" ResourceAssemblyName="" SortExpression="Description">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UnitOfMeasure.ObjectName" HeaderText="Unit Of Measure" meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="UnitOfMeasure.ObjectName" ResourceAssemblyName="" SortExpression="UnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="LatestReading.Reading" HeaderText="Last Reading" meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="LatestReading.Reading" ResourceAssemblyName="" SortExpression="LatestReading.Reading">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="LatestReading.DateOfReading" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" HeaderText="Last Reading Date/Time" meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="LatestReading.DateOfReading" ResourceAssemblyName="" SortExpression="LatestReading.DateOfReading">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>                        
                    </ui:UITabView>
                    
                    <ui:UITabView runat="server" ID="tabEvents" Caption="Events" BorderStyle="NotSet" meta:resourcekey="tabEventsResource1" 
                        >
                        <ui:UIButton runat="server" ID="buttonRefreshEvent" Text="Refresh" ImageUrl="~/images/refresh.gif" OnClick="buttonRefreshEvent_Click" meta:resourcekey="buttonRefreshEventResource1" />
                        <br />
                        <br />
                      
                       <ui:UIGridView ID="UIGridViewEvent" runat="server" Caption="Events" PropertyName="OPCAEEvents"
                            KeyName="ObjectID" meta:resourcekey="EventResource1" Width="100%" 
                            CheckBoxColumnVisible="False"  OnAction="UIGridViewEvent_Action" 
                            DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" 
                            style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ConfirmText="Please remember to save this Equipment before editing the OPC AE Event.\n\nAre you sure you want to continue?" ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Source" meta:resourceKey="UIGridViewEventColumnResource1" PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="LatestEvent.ConditionName" HeaderText="Condition Name" meta:resourceKey="UIGridViewEventColumnResource1" PropertyName="LatestEvent.ConditionName" ResourceAssemblyName="" SortExpression="LatestEvent.ConditionName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="LatestEvent.SubConditionName" HeaderText="Sub Condition Name" meta:resourceKey="UIGridViewEventColumnResource1" PropertyName="LatestEvent.SubConditionName" ResourceAssemblyName="" SortExpression="LatestEvent.SubConditionName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="LatestEvent.Severity" HeaderText="Severity" meta:resourceKey="UIGridViewEventColumnResource1" PropertyName="LatestEvent.Severity" ResourceAssemblyName="" SortExpression="LatestEvent.Severity">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="LatestEvent.DateOfEvent" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" HeaderText="Time" meta:resourceKey="UIGridViewEventColumnResource1" PropertyName="LatestEvent.DateOfEvent" ResourceAssemblyName="" SortExpression="LatestEvent.DateOfEvent">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        
                    </ui:UITabView>
                    <ui:UITabView runat="server" Caption="Reminders" BorderStyle="NotSet" meta:resourcekey="UITabViewResource1">
                        <ui:UIFieldSearchableDropDownList ID="ddlReminder1" runat="server" 
                            Caption="Reminder User 1" PropertyName="ReminderUser1ID" 
                            meta:resourcekey="ddlReminder1Resource1" SearchInterval="300" 
                            MaximumNumberOfItems="500"></ui:UIFieldSearchableDropDownList>
                        <ui:UIFieldSearchableDropDownList ID="ddlReminder2" runat="server" 
                            Caption="Reminder User 2" PropertyName="ReminderUser2ID" 
                            meta:resourcekey="ddlReminder2Resource1" SearchInterval="300" 
                            MaximumNumberOfItems="500"></ui:UIFieldSearchableDropDownList>
                        <ui:UIFieldSearchableDropDownList ID="ddlReminder3" runat="server" 
                            Caption="Reminder User 3" PropertyName="ReminderUser3ID" 
                            meta:resourcekey="ddlReminder3Resource1" SearchInterval="300" 
                            MaximumNumberOfItems="500"></ui:UIFieldSearchableDropDownList>
                        <ui:UIFieldSearchableDropDownList ID="ddlReminder4" runat="server" 
                            Caption="Reminder User 4" PropertyName="ReminderUser4ID" 
                            meta:resourcekey="ddlReminder4Resource1" SearchInterval="300" 
                            MaximumNumberOfItems="500"></ui:UIFieldSearchableDropDownList>
                        <ui:UISeparator runat="server" ID="UISeparator2" Caption="Reminder Time" 
                            meta:resourcekey="UISeparator2Resource1" />
                        <ui:UIPanel runat="server" ID="panelEndReminder" Width="50%" 
                            BorderStyle="NotSet" meta:resourcekey="panelEndReminderResource1">
                            <ui:UIFieldLabel runat="server" ID="label1" CaptionWidth="300px" Caption="Reminder before Warranty Expiry Date (Days)" meta:resourcekey="label1Resource1" DataFormatString="" />
                            <ui:UIFieldTextBox runat="server" ID="EndReminderDays1" 
                                PropertyName="EndReminderDays1" Caption="First" ValidateDataTypeCheck="True" 
                                ValidationDataType="Integer" 
                                ToolTip="The number of days prior to the expiry date to send the reminder notification. You may specify up to four reminders." 
                                ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Integer" 
                                InternalControlWidth="95%" meta:resourcekey="EndReminderDays1Resource1" />
                            <ui:UIFieldTextBox runat="server" ID="EndReminderDays2" 
                                PropertyName="EndReminderDays2" Caption="Second" ValidateDataTypeCheck="True" 
                                ValidationDataType="Integer" 
                                ToolTip="The number of days prior to the expiry date to send the reminder notification. You may specify up to four reminders." 
                                ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Integer" 
                                InternalControlWidth="95%" meta:resourcekey="EndReminderDays2Resource1" />
                            <ui:UIFieldTextBox runat="server" ID="EndReminderDays3" 
                                PropertyName="EndReminderDays3" Caption="Third" ValidateDataTypeCheck="True" 
                                ValidationDataType="Integer" 
                                ToolTip="The number of days prior to the expiry date to send the reminder notification. You may specify up to four reminders." 
                                ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Integer" 
                                InternalControlWidth="95%" meta:resourcekey="EndReminderDays3Resource1" />
                            <ui:UIFieldTextBox runat="server" ID="EndReminderDays4" 
                                PropertyName="EndReminderDays4" Caption="Fourth" ValidateDataTypeCheck="True" 
                                ValidationDataType="Integer" 
                                ToolTip="The number of days prior to the expiry date to send the reminder notification. You may specify up to four reminders." 
                                ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Integer" 
                                InternalControlWidth="95%" meta:resourcekey="EndReminderDays4Resource1" />
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="Reminder_Panel" BorderStyle="NotSet" meta:resourcekey="Reminder_PanelResource1">
                        <ui:UIGridView runat="server" ID="gridReminder" PropertyName="EquipmentReminders" 
                                DataKeyNames="ObjectID" GridLines="Both" 
                                meta:resourcekey="gridReminderResource1" RowErrorColor="" style="clear:both;" 
                                Caption="Reminders" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <ui:uigridviewcommand alwaysenabled="False" causesvalidation="False" commandname="DeleteObject" commandtext="Delete" confirmtext="Are you sure you wish to delete the selected items?" imageurl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                                <ui:uigridviewcommand alwaysenabled="False" causesvalidation="False" commandname="AddObject" commandtext="Add" imageurl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource2" />
                            </commands>
                            <Columns>
                                <ui:uigridviewbuttoncolumn buttontype="Image" commandname="EditObject" imageurl="~/images/edit.gif" meta:resourcekey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewbuttoncolumn>
                                <ui:uigridviewbuttoncolumn buttontype="Image" commandname="DeleteObject" confirmtext="Are you sure you wish to delete this item?" imageurl="~/images/delete.gif" meta:resourcekey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewbuttoncolumn>
                                <ui:UIGridViewBoundColumn HeaderText="Reminder Type" PropertyName="ReminderType.ObjectName" DataField="ReminderType.ObjectName" meta:resourcekey="UIGridViewBoundColumnResource6" ResourceAssemblyName="" SortExpression="ReminderType.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Reminder Date" PropertyName="ReminderDate" DataFormatString="{0:dd-MMM-yyyy}" DataField="ReminderDate" meta:resourcekey="UIGridViewBoundColumnResource7" ResourceAssemblyName="" SortExpression="ReminderDate">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Reminder Description" PropertyName="ReminderDescription" DataField="ReminderDescription" meta:resourcekey="UIGridViewBoundColumnResource8" ResourceAssemblyName="" SortExpression="ReminderDescription">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="Reminders_ObjectPanel" BorderStyle="NotSet" meta:resourcekey="Reminders_ObjectPanelResource1" >
                            <web:subpanel runat="server" GridViewID="gridReminder" ID="Reminder_SubPanel" OnPopulateForm="Reminder_SubPanel_PopulateForm" OnValidateAndUpdate="Reminder_SubPanel_ValidateAndUpdate" />
                            <ui:UIFieldRadioList runat="server" ID="rdl_ReminderType" Caption="Reminder Type" PropertyName="ReminderTypeID" 
                            ValidateRequiredField="True" meta:resourcekey="rdl_ReminderTypeResource1" TextAlign="Right"></ui:UIFieldRadioList>
                            <ui:UIFieldDateTime runat="server" ID="ReminderDate" Caption="Reminder Date" 
                                PropertyName="ReminderDate" ValidateRequiredField="True" 
                                meta:resourcekey="ReminderDateResource1" ShowDateControls="True" ImageUrl=""></ui:UIFieldDateTime>
                            <ui:UIFieldTextBox runat="server" ID="txtReminderDescription" Caption="Reminder Description" PropertyName="ReminderDescription" MaxLength="255" InternalControlWidth="95%" meta:resourcekey="txtReminderDescriptionResource1"></ui:UIFieldTextBox>
                        </ui:UIObjectPanel>
                        </ui:UIPanel>
                    </ui:UITabView>
                    
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Memo"  meta:resourcekey="uitabview4Resource1" BorderStyle="NotSet">
                        <web:memo ID="Memo1" runat="server"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Attachments" 
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>

