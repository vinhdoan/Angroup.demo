<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OLocation location = panel.SessionObject as OLocation;

        if (Request["TREEOBJID"] != null && TablesLogic.tLocation[Security.DecryptGuid(Request["TREEOBJID"])] != null)
            location.ParentID = Security.DecryptGuid(Request["TREEOBJID"]);

        ParentID.PopulateTree();
        ParentID.Enabled = location.IsNew || location.ParentID != null;
        IsPhysicalLocation.Enabled = location.IsNew;

        if (!location.IsNew)
        {
            aa.Value = location.CoordinateLeft;
            bb.Value = location.CoordinateRight;
            iframe1.Attributes["src"] = "../../map/MapPosition.aspx?l=" + location.CoordinateLeft + "&t=" + location.CoordinateRight;
        }

        buttonCreatePoints.Visible = AppSession.User.AllowCreate("OPoint");
        UIGridViewReading.Columns[0].Visible = AppSession.User.AllowEditAll("OPoint");
        UIGridViewEvent.Columns[0].Visible = AppSession.User.AllowEditAll("OOPCAEEvent");
        Equipment.Columns[0].Visible = AppSession.User.AllowEditAll("OEquipment");
        Equipment.Columns[1].Visible = AppSession.User.AllowViewAll("OEquipment");
        LocationTypeID.PopulateTree();
        if (ParentID.SelectedValue != null && ParentID.SelectedValue != "")
        {
            OLocation loc = TablesLogic.tLocation.Load(new Guid(ParentID.SelectedValue));
            ddlDefaultLOASignatory.Bind(OUser.GetUsersByRoleAndAboveLocation(loc, "PURCHASEADMIN"));
            //ddlDefaultLOASignatory.Bind(OUser.GetUsersByRole("PURCHASEADMIN"));
        }
        else
            ddlDefaultLOASignatory.Bind(OUser.GetUsersByRole("PURCHASEADMIN"));
        ddl_BuildingOwner.Bind(TablesLogic.tCapitalandCompany.LoadAll(), "ObjectNameAndAddress", "ObjectID");
        ddl_BuildingTrust.Bind(TablesLogic.tCapitalandCompany.LoadAll(), "ObjectNameAndAddress", "ObjectID");
        ddl_BuildingManagement.Bind(TablesLogic.tCapitalandCompany.LoadAll(), "ObjectNameAndAddress", "ObjectID");

        if (!IsPostBack)
        {
            PriceAtOwnership.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
        }

        objectBase.ObjectName.Enabled = (location.FromAmos == 0);
        panel.ObjectPanel.BindObjectToControls(location);

    }

    /// <summary>
    /// Validates and saves the location object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OLocation location = panel.SessionObject as OLocation;
            panel.ObjectPanel.BindControlsToObject(location);

            #region sli: map
            try
            {
                if (Convert.ToInt16(aa.Value) >= 0)
                {
                    location.CoordinateLeft = aa.Value;
                }
            }
            catch
            {
                location.CoordinateLeft = "";
            }

            try
            {
                if (Convert.ToInt16(bb.Value) >= 0)
                {
                    location.CoordinateRight = bb.Value;
                }
            }
            catch
            {
                location.CoordinateRight = "";
            }
            #endregion

            // Validate
            //
            if (location.IsDuplicateName())
                objectBase.ObjectName.ErrorMessage = Resources.Errors.General_NameDuplicate;
            if (location.IsCyclicalReference())
                ParentID.ErrorMessage = Resources.Errors.Code_CyclicalReference;
            //Rachel Bug fix. Check location parent not null first
            if (location.Parent != null && location.Parent.IsPhysicalLocation == 1 && location.IsPhysicalLocation == 0)
                ParentID.ErrorMessage = Resources.Errors.Location_ParentIDInvalid;

            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            location.Save();
            c.Commit();
        }
    }

    /// <summary>
    /// Constructs the location tree view.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater ParentID_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(panel.SessionObject.ParentID, true, true,
            Security.Decrypt(Request["TYPE"]), false, false);
    }

    /// <summary>
    /// Constructs the location type tree view.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater LocationTypeID_AcquireTreePopulater(object sender)
    {
        OLocation location = panel.SessionObject as OLocation;
        return new LocationTypePopulater(location.LocationTypeID, true, true);

    }

    /// <summary>
    /// Occurs when user clicks on the radio button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void IsPhysicalLocation_SelectedIndexChanged(object sender, EventArgs e)
    {
        // kf begin: bug fix
        /*
        OLocation location = (OLocation) panel.CurrentObject; 
        
        if (location.Parent != null && location.Parent.IsPhysicalLocation == 1)
        {
            IsPhysicalLocation.SelectedIndex = 1;
            IsPhysicalLocation.Enabled = false;
        }
         */
        // kf end

        //Rachel 13 April 2007. Customized object. 
        //once the location is not a physical, call the Update customized to delete attribute fields     
        if (Convert.ToInt32(this.IsPhysicalLocation.SelectedValue) == 0)
        {
            panel.UpdateCustomizedAttributeFields(null);
            this.LocationTypeID.SelectedValue = "";
        }
        else if (this.LocationTypeID.SelectedValue != "")
            panel.UpdateCustomizedAttributeFields(new Guid(LocationTypeID.SelectedValue.ToString()));
        //end Rachel
    }

    /// <summary>
    /// Updates the customized attribute fields when user clicks on the location type tree view.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void LocationTypeID_SelectedNodeChanged(object sender, EventArgs e)
    {
        if (this.LocationTypeID.SelectedValue == "")
            panel.UpdateCustomizedAttributeFields(null);
        else
            panel.UpdateCustomizedAttributeFields(new Guid(this.LocationTypeID.SelectedValue));
    }

    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        // kf begin: bug fix
        OLocation location = panel.SessionObject as OLocation;
        panel.ObjectPanel.BindControlsToObject(location);

        if (location.IsNew)
        {
            if (location.Parent != null && location.Parent.IsPhysicalLocation == 1)
            {
                location.IsPhysicalLocation = 1;
                IsPhysicalLocation.SelectedValue = "1";
                IsPhysicalLocation.Enabled = false;
            }
            else
                IsPhysicalLocation.Enabled = true;
        }
        // kf end
        tabPoints.Visible = !location.IsNew;
        tabEvents.Visible = !(UIGridViewEvent.Rows.Count == 0);
        panelLocation1.Visible = IsPhysicalLocation.SelectedIndex == 1;
        panelBuilding.Visible = location.LocationType != null && location.LocationType.ObjectName == OApplicationSetting.Current.LocationTypeNameForBuildingActual;
        txtEmailForSAPFMSBudget.Visible = location.LocationType != null && location.LocationType.ObjectName == OApplicationSetting.Current.LocationTypeNameForBuildingActual;

        AmosAssetID.Enabled = (location.LocationTypeID == OApplicationSetting.Current.AssetLocationTypeID);

        textDepartmentCode.Visible = location.IsPhysicalLocation == 0;//Nguyen Quoc Phuong 19-Nov-2012
        //cbSyncCRV.Visible = location.IsPhysicalLocation == 0;//Nguyen Quoc Phuong 21-Nov-2012
        textSystemCode.Visible = location.IsPhysicalLocation == 0;//Nguyen Quoc Phuong 10-Dec-2012
    }


    protected void buttonRefresh_Click(object sender, EventArgs e)
    {
        OLocation loc = panel.SessionObject as OLocation;
        panel.ObjectPanel.BindObjectToControls(loc);
    }

    protected void buttonRefreshEvent_Click(object sender, EventArgs e)
    {
        OLocation loc = panel.SessionObject as OLocation;
        panel.ObjectPanel.BindObjectToControls(loc);
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
        OLocation loc = panel.SessionObject as OLocation;

        tabPoints.BindControlsToObject(loc);
        if (loc.LocationType == null)
        {
            panel.Message = Resources.Errors.Location_LocationTypeNotSelected;
            return;
        }

        DataList<OLocationTypePoint> ltp = loc.LocationType.LocationTypePoints;
        if (ltp.Count == 0)
            panel.Message = Resources.Errors.Location_UnableToCreatePointsNoPoints;
        else
            loc.CreatePoints();
        tabPoints.BindObjectToControls(loc);
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
                    e.Row.Cells[1].Controls[0].Visible = false;
                }
            }
        }
    }


    protected void UIGridViewReading_PreRender(object sender, EventArgs e)
    {

    }

    protected void Page_Load(object sender, EventArgs e)
    {
        string controlName = Request.Params.Get("__EVENTTARGET");
        string arguement = Request.Params.Get("__EVENTARGUMENT");

        if (controlName == "ParentID" && arguement.Contains("SEARCH"))
        {
            string[] arg = arguement.Split('_');

            if (arg != null && arg.Length == 2)
                ParentID.SelectedValue = Security.Decrypt(arg[1]);
        }

    }


    /// <summary>
    /// Opens the equipment edit page.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void Equipment_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "EditObject")
        {
            Window.OpenEditObjectPage(this.Page, "OEquipment", dataKeys[0].ToString(), "");
        }
    }


    /// <summary>
    /// Opens the location for editing.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonEditLocationType_Click(object sender, EventArgs e)
    {
        if (LocationTypeID.SelectedValue != "")
            Window.OpenEditObjectPage(this, "OLocationType", LocationTypeID.SelectedValue, "");
    }


    /// <summary>
    /// Opens the location for viewing.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonViewLocationType_Click(object sender, EventArgs e)
    {
        if (LocationTypeID.SelectedValue != "")
            Window.OpenViewObjectPage(this, "OLocationType", LocationTypeID.SelectedValue, "");
    }


    protected void ParentID_SelectedNodeChanged(object sender, EventArgs e)
    {
        OLocation loc = TablesLogic.tLocation.Load(new Guid(ParentID.SelectedValue));
        ddlDefaultLOASignatory.Bind(OUser.GetUsersByRoleAndAboveLocation(loc, "PURCHASEADMIN"));
        //ddlDefaultLOASignatory.Bind(OUser.GetUsersByRole("PURCHASEADMIN"));
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Location" BaseTable="tLocation" OnPopulateForm="panel_PopulateForm"
            OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip ID="tabObject" runat="server" BorderStyle="NotSet" meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="uitabview1" runat="server" BorderStyle="NotSet" Caption="Details"
                    meta:resourcekey="uitabview1Resource1">
                    <web:base ID="objectBase" runat="server" meta:resourceKey="objectBaseResource1" ObjectNameTooltip="The location name as displayed on screen."
                        ObjectNumberVisible="false" />
                    <table border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <td>
                                <ui:UIFieldTreeList ID="ParentID" runat="server" Caption="Belongs Under" meta:resourcekey="ParentIDResource1"
                                    OnAcquireTreePopulater="ParentID_AcquireTreePopulater" PropertyName="ParentID"
                                    ShowCheckBoxes="None" ToolTip="The location or group under which this item belongs."
                                    TreeValueMode="SelectedNode" ValidateRequiredField="True" OnSelectedNodeChanged="ParentID_SelectedNodeChanged">
                                </ui:UIFieldTreeList>
                            </td>
                            <td valign="middle" width="40px">
                                <web:map ID="buttonMap" runat="server" TargetControlID="ParentID" />
                            </td>
                        </tr>
                    </table>
                    <ui:UIFieldTextBox ID="textRunningNumberCode" runat="server" Caption="Running Number Code"
                        InternalControlWidth="95%" meta:resourcekey="textRunningNumberCodeResource1"
                        PropertyName="RunningNumberCode">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldTextBox ID="textDepartmentCode" runat="server" Caption="Department Code"
                        InternalControlWidth="95%" PropertyName="DepartmentCode">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldTextBox ID="textSystemCode" runat="server" Caption="System Code" InternalControlWidth="95%" Hint="Input wrongly will cause system to perform unexpectedly."
                        PropertyName="SystemCode" ToolTip="Input wrongly will cause system to perform unexpectedly.">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldCheckBox ID="cbSyncCRV" runat="server" Caption="Sync CRV?" Enabled="false"
                        Visible="false" InternalControlWidth="95%" PropertyName="SyncCRV">
                    </ui:UIFieldCheckBox>
                    <ui:UIFieldRadioList ID="IsPhysicalLocation" runat="server" Caption="Folder/Physical"
                        meta:resourcekey="IsPhysicalLocationResource1" OnSelectedIndexChanged="IsPhysicalLocation_SelectedIndexChanged"
                        PropertyName="IsPhysicalLocation" TextAlign="Right" ToolTip="Indicates if this item is a folder or a physical location."
                        ValidateRequiredField="True">
                        <Items>
                            <asp:ListItem meta:resourceKey="ListItemResource1" Text="Folder &nbsp;" Value="0"></asp:ListItem>
                            <asp:ListItem meta:resourceKey="ListItemResource2" Text="Physical Location" Value="1"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIPanel ID="panelLocation1" runat="server" BorderStyle="NotSet" meta:resourcekey="panelLocation1Resource1"
                        Width="100%">
                        <ui:UIFieldTreeList ID="LocationTypeID" runat="server" Caption="Location Type" meta:resourcekey="LocationTypeIDResource1"
                            OnAcquireTreePopulater="LocationTypeID_AcquireTreePopulater" OnSelectedNodeChanged="LocationTypeID_SelectedNodeChanged"
                            PropertyName="LocationTypeID" ShowCheckBoxes="None" ToolTip="The type of this location."
                            TreeValueMode="SelectedNode" ValidateRequiredField="True">
                            <ContextMenuButtons>
                                <ui:UIButton ID="buttonEditLocationType" runat="server" AlwaysEnabled="True" CausesValidation="False"
                                    ConfirmText="Please remember to save this Location before editing the Location Type.\n\nAre you sure you want to continue?"
                                    ImageUrl="~/images/edit.gif" meta:resourcekey="buttonEditLocationTypeResource1"
                                    OnClick="buttonEditLocationType_Click" Text="Edit Location Type" />
                                <ui:UIButton ID="buttonViewLocationType" runat="server" AlwaysEnabled="True" CausesValidation="False"
                                    ConfirmText="Please remember to save this Location before viewing the Location Type.\n\nAre you sure you want to continue?"
                                    ImageUrl="~/images/view.gif" meta:resourcekey="buttonViewLocationTypeResource1"
                                    OnClick="buttonViewLocationType_Click" Text="View Location Type" />
                            </ContextMenuButtons>
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTextBox ID="AddressCountry" runat="server" Caption="Country" InternalControlWidth="95%"
                            MaxLength="255" meta:resourcekey="AddressCountryResource1" PropertyName="AddressCountry">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox ID="AddressState" runat="server" Caption="State" InternalControlWidth="95%"
                            MaxLength="255" meta:resourcekey="AddressStateResource1" PropertyName="AddressState">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox ID="AddressCity" runat="server" Caption="City" InternalControlWidth="95%"
                            MaxLength="255" meta:resourcekey="AddressCityResource1" PropertyName="AddressCity">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox ID="Address" runat="server" Caption="Address" InternalControlWidth="95%"
                            MaxLength="255" meta:resourcekey="AddressResource1" PropertyName="Address">
                        </ui:UIFieldTextBox>
                        <ui:UISeparator ID="sep1" runat="server" meta:resourcekey="sep1Resource1" />
                        <ui:UIFieldDateTime ID="DateOfOwnership" runat="server" Caption="Date of Ownership"
                            ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" meta:resourcekey="DateOfOwnershipResource1"
                            PropertyName="DateOfOwnership" ShowDateControls="True" ToolTip="The date from which this location was acquired.">
                        </ui:UIFieldDateTime>
                        <ui:UIFieldTextBox ID="PriceAtOwnership" runat="server" Caption="Price at Ownership"
                            InternalControlWidth="95%" meta:resourcekey="PriceAtOwnershipResource1" PropertyName="PriceAtOwnership"
                            Span="Half" ToolTip="The price of the location when acquired." ValidateDataTypeCheck="True"
                            ValidateRangeField="True" ValidationDataType="Currency" ValidationRangeMax="99999999999999"
                            ValidationRangeMin="0" ValidationRangeType="Currency">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox ID="LifeSpan" runat="server" Caption="Life Span (years)" InternalControlWidth="95%"
                            meta:resourcekey="LifeSpanResource1" PropertyName="LifeSpan" Span="Half" ToolTip="The life span of this location in years."
                            ValidateDataTypeCheck="True" ValidateRangeField="True" ValidationDataType="Integer"
                            ValidationRangeMin="0" ValidationRangeType="Integer">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox ID="GrossFloorArea" runat="server" Caption="Gross Floor Area"
                            InternalControlWidth="95%" meta:resourcekey="GrossFloorAreaResource1" PropertyName="GrossFloorArea"
                            Span="Half" ValidateDataTypeCheck="True" ValidateRangeField="True" ValidationDataType="Currency"
                            ValidationRangeMax="99999999999999" ValidationRangeMin="0" ValidationRangeType="Currency">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox ID="NetLettableArea" runat="server" Caption="Net Lettable Area"
                            InternalControlWidth="95%" meta:resourcekey="NetLettableAreaResource1" PropertyName="NetLettableArea"
                            Span="Half" ValidateDataTypeCheck="True" ValidateRangeField="True" ValidationDataType="Currency"
                            ValidationRangeMax="99999999999999" ValidationRangeMin="0" ValidationRangeType="Currency">
                        </ui:UIFieldTextBox>
                        <br />
                        <br />
                        <br />
                        <ui:UIPanel runat="server" ID="panelBuilding" BorderStyle="NotSet" meta:resourcekey="panelBuildingResource1">
                            <ui:UIFieldDropDownList ID="ddl_BuildingOwner" runat="server" Caption="Building Owner"
                                meta:resourcekey="ddl_BuildingOwnerResource1" PropertyName="BuildingOwnerID"
                                ValidateRequiredField="True">
                            </ui:UIFieldDropDownList>
                            <table cellpadding='0' cellspacing='0' border='0' style="width: 100%">
                                <tr>
                                    <td style="width: 150px">
                                    </td>
                                    <td>
                                        <asp:Label runat="server" ID="hintBuildingOwner" meta:resourcekey="hintBuildingOwnerResource1">This is the company that appears in the Deliver To section of a purchase order.</asp:Label>
                                        <br />
                                        <br />
                                    </td>
                                </tr>
                            </table>
                            <ui:UIFieldDropDownList ID="ddl_BuildingTrust" runat="server" Caption="Building Trust"
                                meta:resourcekey="ddl_BuildingTrustResource1" PropertyName="BuildingTrustID"
                                ValidateRequiredField="True">
                            </ui:UIFieldDropDownList>
                            <table cellpadding='0' cellspacing='0' border='0' style="width: 100%">
                                <tr>
                                    <td style="width: 150px">
                                    </td>
                                    <td>
                                        <asp:Label runat="server" ID="hintBuildingTrust" meta:resourcekey="hintBuildingTrustResource1">This is the company that appears in the Bill To section of a purchase order.</asp:Label>
                                        <br />
                                        <br />
                                    </td>
                                </tr>
                            </table>
                            <ui:UIFieldDropDownList ID="ddl_BuildingManagement" runat="server" Caption="Building Management"
                                meta:resourcekey="ddl_BuildingManagementResource1" PropertyName="BuildingManagementID"
                                ValidateRequiredField="True">
                            </ui:UIFieldDropDownList>
                            <table cellpadding='0' cellspacing='0' border='0' style="width: 100%">
                                <tr>
                                    <td style="width: 150px">
                                    </td>
                                    <td>
                                        <asp:Label runat="server" ID="hintBuildingManagement" meta:resourcekey="hintBuildingManagementResource1">This is the company that appears at the top of your purchase order.<br /><br /></asp:Label>
                                    </td>
                                </tr>
                            </table>
                            <ui:UIFieldDropDownList runat="server" ID="ddlDefaultLOASignatory" Caption="Default LOA Signatory"
                                PropertyName="DefaultLOASignatoryID" meta:resourcekey="ddlDefaultLOASignatoryResource1">
                            </ui:UIFieldDropDownList>
                        </ui:UIPanel>
                        <br />
                        <br />
                        <ui:UIFieldTextBox ID="txtEmailForSAPFMSBudget" runat="server" Caption="Email For SAP &lt;&gt; FMS Budget"
                            InternalControlWidth="95%" meta:resourcekey="txtEmailForSAPFMSBudgetResource1"
                            PropertyName="EmailForSAPFMSBudget">
                        </ui:UIFieldTextBox>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView ID="tabviewAmos" runat="server" BorderStyle="NotSet" Caption="Amos"
                    meta:resourcekey="tabviewAmosResource1">
                    <ui:UISeparator ID="AmosSeparator" runat="server" Caption="Amos" meta:resourcekey="AmosSeparatorResource1" />
                    <ui:UIFieldCheckBox ID="cbFromAmos" runat="server" Caption="From Amos" Enabled="False"
                        meta:resourcekey="cbFromAmosResource1" PropertyName="FromAmos" TextAlign="Right">
                    </ui:UIFieldCheckBox>
                    <ui:UIFieldTextBox ID="AmosAssetID" runat="server" Caption="Amos Asset ID" InternalControlWidth="95%"
                        meta:resourcekey="AmosAssetIDResource1" PropertyName="AmosAssetID" Span="Half">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldLabel ID="AmosSuiteID" runat="server" Caption="Amos Suite ID" Enabled="False"
                        InternalControlWidth="95%" meta:resourcekey="AmosSuiteIDResource1" PropertyName="AmosSuiteID"
                        Span="Half" DataFormatString="">
                    </ui:UIFieldLabel>
                    <ui:UIFieldLabel ID="AmosLevelID" runat="server" Caption="Amos Level ID" Enabled="False"
                        InternalControlWidth="95%" meta:resourcekey="AmosLevelIDResource1" PropertyName="AmosLevelID"
                        Span="Half" DataFormatString="">
                    </ui:UIFieldLabel>
                    <ui:UIFieldLabel ID="AmosAssetTypeID" runat="server" Caption="Amos Asset Type ID"
                        Enabled="False" InternalControlWidth="95%" meta:resourcekey="AmosAssetTypeIDResource1"
                        PropertyName="AmosAssetTypeID" Span="Half" DataFormatString="">
                    </ui:UIFieldLabel>
                    <ui:UIFieldLabel ID="IsActive" runat="server" Caption="Is Active" Enabled="False"
                        InternalControlWidth="95%" meta:resourcekey="IsActiveResource1" PropertyName="IsActiveText"
                        Span="Half" DataFormatString="">
                    </ui:UIFieldLabel>
                    <ui:UIFieldLabel ID="LeaseableFrom" runat="server" Caption="Leaseable From" DataFormatString="{0:dd-MMM-yyyy}"
                        Enabled="False" InternalControlWidth="95%" meta:resourcekey="LeaseableFromResource1"
                        PropertyName="LeaseableFrom" Span="Half">
                    </ui:UIFieldLabel>
                    <ui:UIFieldLabel ID="LeaseableTo" runat="server" Caption="Leaseable To" DataFormatString="{0:dd-MMM-yyyy}"
                        Enabled="False" InternalControlWidth="95%" meta:resourcekey="LeaseableToResource1"
                        PropertyName="LeaseableTo" Span="Half">
                    </ui:UIFieldLabel>
                    <ui:UIFieldLabel ID="LeaseableArea" runat="server" Caption="Leaseable Area" DataFormatString="{0:#,##0.00}"
                        Enabled="False" InternalControlWidth="95%" meta:resourcekey="LeaseableAreaResource1"
                        PropertyName="LeaseableArea" Span="Half">
                    </ui:UIFieldLabel>
                    <ui:UIFieldLabel ID="updatedOn" runat="server" Caption="Updated On" DataFormatString="{0:dd-MMM-yyyy}"
                        Enabled="False" InternalControlWidth="95%" meta:resourcekey="updatedOnResource1"
                        PropertyName="updatedOn" Span="Half">
                    </ui:UIFieldLabel>
                    <ui:UIFieldTextBox runat="server" Caption="AMOS InstanceID" ID="AMOSInstanceID" PropertyName="AMOSInstanceID"
                        Enabled="false">
                    </ui:UIFieldTextBox>
                </ui:UITabView>
                <ui:UITabView ID="tabviewTenantLease" runat="server" BorderStyle="NotSet" Caption="Leases"
                    meta:resourcekey="tabviewTenantLeaseResource1">
                    <ui:UIGridView ID="Uigridview1" runat="server" BindObjectsToRows="True" Caption="Leases"
                        CheckBoxColumnVisible="False" DataKeyNames="ObjectID" GridLines="Both" meta:resourcekey="UIGridViewResource1"
                        PropertyName="TenantLeases" RowErrorColor="" SortExpression="LeaseStartDate Desc"
                        Style="clear: both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:UIGridViewBoundColumn DataField="Tenant.ObjectName" HeaderText="Tenant" meta:resourcekey="UIGridViewBoundColumnResource1"
                                PropertyName="Tenant.ObjectName" ResourceAssemblyName="" SortExpression="Tenant.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="LeaseStartDate" DataFormatString="{0:dd-MMM-yyyy}"
                                HeaderText="Lease Start Date" meta:resourcekey="UIGridViewBoundColumnResource2"
                                PropertyName="LeaseStartDate" ResourceAssemblyName="" SortExpression="LeaseStartDate">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="LeaseEndDate" DataFormatString="{0:dd-MMM-yyyy}"
                                HeaderText="Lease End Date" meta:resourcekey="UIGridViewBoundColumnResource3"
                                PropertyName="LeaseEndDate" ResourceAssemblyName="" SortExpression="LeaseEndDate">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="Status" HeaderText="Lease Status" meta:resourcekey="UIGridViewBoundColumnResource4"
                                PropertyName="Status" ResourceAssemblyName="" SortExpression="Status">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="AmosLeaseID" HeaderText="Amos Lease ID" meta:resourcekey="UIGridViewBoundColumnResource5"
                                PropertyName="AmosLeaseID" ResourceAssemblyName="" SortExpression="AmosLeaseID">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="updatedOn" DataFormatString="{0:dd-MMM-yyyy}"
                                HeaderText="Updated On" meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="updatedOn"
                                ResourceAssemblyName="" SortExpression="updatedOn">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView ID="uitabview3" runat="server" BorderStyle="NotSet" Caption="Equipment"
                    meta:resourcekey="uitabview3Resource1">
                    <ui:UIGridView ID="Equipment" runat="server" Caption="Equipment" CheckBoxColumnVisible="False"
                        DataKeyNames="ObjectID" GridLines="Both" keyname="ObjectID" meta:resourcekey="EquipmentResource1"
                        OnAction="Equipment_Action" PropertyName="Equipment" RowErrorColor="" Style="clear: both;"
                        Width="100%" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" CommandName="EditObject"
                                ConfirmText="Please remember to save this Location before editing the Equipment.\n\nAre you sure you want to continue?"
                                ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn AlwaysEnabled="True" ButtonType="Image" CommandName="ViewObject"
                                ConfirmText="Please remember to save this Location before viewing the Equipment.\n\nAre you sure you want to continue?"
                                ImageUrl="~/images/view.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Equipment Name" meta:resourcekey="UIGridViewColumnResource1"
                                PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="EquipmentType.ObjectName" HeaderText="Equipment Type"
                                meta:resourcekey="UIGridViewColumnResource2" PropertyName="EquipmentType.ObjectName"
                                ResourceAssemblyName="" SortExpression="EquipmentType.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="SerialNumber" HeaderText="Serial Number" meta:resourcekey="UIGridViewColumnResource3"
                                PropertyName="SerialNumber" ResourceAssemblyName="" SortExpression="SerialNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="ModelNumber" HeaderText="Model Number" meta:resourcekey="UIGridViewColumnResource4"
                                PropertyName="ModelNumber" ResourceAssemblyName="" SortExpression="ModelNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView ID="tabPoints" runat="server" BorderStyle="NotSet" Caption="Points"
                    meta:resourcekey="tabPointsResource1">
                    <ui:UIButton ID="buttonRefresh" runat="server" ImageUrl="~/images/refresh.gif" meta:resourcekey="buttonRefreshResource1"
                        OnClick="buttonRefresh_Click" Text="Refresh" />
                    <ui:UIButton ID="buttonCreatePoints" runat="server" ConfirmText="Are you sure you want to create points for the selected location type? Existing points will not be removed or overwritten."
                        ImageUrl="~/images/add.png" meta:resourcekey="buttonCreatePointsResource1" OnClick="buttonCreatePoints_Click"
                        Text="Create Points for this Location Type" />
                    <br />
                    <br />
                    <ui:UIGridView ID="UIGridViewReading" runat="server" Caption="Points" CheckBoxColumnVisible="False"
                        DataKeyNames="ObjectID" GridLines="Both" keyname="ObjectID" meta:resourcekey="ReadingResource1"
                        OnAction="UIGridViewReading_Action" OnPreRender="UIGridViewReading_PreRender"
                        OnRowDataBound="UIGridViewReading_RowDataBound" PropertyName="Point" RowErrorColor=""
                        Style="clear: both;" Width="100%" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ConfirmText="Please remember to save this Location before editing the Point.\n\nAre you sure you want to continue?"
                                ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource3">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Point Name" meta:resourcekey="UIGridViewReadColumnResource1"
                                PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="Description" HeaderText="Description" meta:resourcekey="UIGridViewReadColumnResource1"
                                PropertyName="Description" ResourceAssemblyName="" SortExpression="Description">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="UnitOfMeasure.ObjectName" HeaderText="Parameter"
                                meta:resourcekey="UIGridViewReadColumnResource1" PropertyName="UnitOfMeasure.ObjectName"
                                ResourceAssemblyName="" SortExpression="UnitOfMeasure.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="LatestReading.Reading" HeaderText="Last Reading"
                                meta:resourcekey="UIGridViewReadColumnResource1" PropertyName="LatestReading.Reading"
                                ResourceAssemblyName="" SortExpression="LatestReading.Reading">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="LatestReading.DateOfReading" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}"
                                HeaderText="Last Reading Date/Time" meta:resourcekey="UIGridViewReadColumnResource1"
                                PropertyName="LatestReading.DateOfReading" ResourceAssemblyName="" SortExpression="LatestReading.DateOfReading">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView ID="tabEvents" runat="server" BorderStyle="NotSet" Caption="Events"
                    meta:resourcekey="tabEventsResource1">
                    <ui:UIButton ID="buttonRefreshEvent" runat="server" ImageUrl="~/images/refresh.gif"
                        meta:resourcekey="buttonRefreshEventResource1" OnClick="buttonRefreshEvent_Click"
                        Text="Refresh" />
                    <br />
                    <br />
                    <ui:UIGridView ID="UIGridViewEvent" runat="server" Caption="Events" CheckBoxColumnVisible="False"
                        DataKeyNames="ObjectID" GridLines="Both" keyname="ObjectID" meta:resourcekey="EventResource1"
                        OnAction="UIGridViewEvent_Action" PropertyName="OPCAEEvents" RowErrorColor=""
                        Style="clear: both;" Width="100%" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ConfirmText="Please remember to save this Location before editing the OPC AE Event.\n\nAre you sure you want to continue?"
                                ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource4">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Source" meta:resourcekey="UIGridViewEventColumnResource1"
                                PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="LatestEvent.ConditionName" HeaderText="Condition Name"
                                meta:resourcekey="UIGridViewEventColumnResource1" PropertyName="LatestEvent.ConditionName"
                                ResourceAssemblyName="" SortExpression="LatestEvent.ConditionName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="LatestEvent.SubConditionName" HeaderText="Sub Condition Name"
                                meta:resourcekey="UIGridViewEventColumnResource1" PropertyName="LatestEvent.SubConditionName"
                                ResourceAssemblyName="" SortExpression="LatestEvent.SubConditionName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="LatestEvent.Severity" HeaderText="Severity"
                                meta:resourcekey="UIGridViewEventColumnResource1" PropertyName="LatestEvent.Severity"
                                ResourceAssemblyName="" SortExpression="LatestEvent.Severity">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn DataField="LatestEvent.DateOfEvent" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}"
                                HeaderText="Time" meta:resourcekey="UIGridViewEventColumnResource1" PropertyName="LatestEvent.DateOfEvent"
                                ResourceAssemblyName="" SortExpression="LatestEvent.DateOfEvent">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView ID="attributeTabView" runat="server" BorderStyle="NotSet" Caption="Attribute"
                    meta:resourcekey="attributeTabViewResource1">
                </ui:UITabView>
                <ui:UITabView ID="tabMap" runat="server" BorderStyle="NotSet" Caption="Map" meta:resourcekey="tabMapResource1"
                    Visible="False">
                    <ui:UIFieldTextBox ID="CoordinateLeft" runat="server" border="0" Caption="Left Position"
                        cellpadding="2" cellspacing="0" Enabled="False" Height="20px" InternalControlWidth="95%"
                        MaxLength="4" meta:resourcekey="CoordinateLeftResource1" PropertyName="CoordinateLeft"
                        Span="Half" Style="float: left; table-layout: fixed;" Visible="False">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldTextBox ID="CoordinateRight" runat="server" border="0" Caption="Top Position"
                        cellpadding="2" cellspacing="0" Enabled="False" Height="20px" InternalControlWidth="95%"
                        MaxLength="4" meta:resourcekey="CoordinateRightResource1" PropertyName="CoordinateRight"
                        Span="Half" Style="float: left; table-layout: fixed;" Visible="False">
                    </ui:UIFieldTextBox>
                    <iframe id="iframe1" runat="server" frameborder="0" height="500" scrolling="no" src="../../map/MapPosition.aspx"
                        width="970px"></iframe>
                    <input id="aa" runat="server" type="hidden" value="9"></input>
                    </input> </input> </input>
                    <input id="bb" runat="server" type="hidden" value="9"></input>
                    </input> </input> </input>
                    <cc1:UIHint ID="hintMoveMarker" runat="server" meta:resourceKey="hintMoveMarkerResource1">Move the marker to position it on the map.
                    </cc1:UIHint>
                    </input> </input> </input>
                </ui:UITabView>
                <ui:UITabView ID="uitabview4" runat="server" BorderStyle="NotSet" Caption="Memo"
                    meta:resourcekey="uitabview4Resource1">
                    <web:memo ID="Memo1" runat="server" />
                </ui:UITabView>
                <ui:UITabView ID="uitabview2" runat="server" BorderStyle="NotSet" Caption="Attachments"
                    meta:resourcekey="uitabview2Resource1">
                    <web:attachments ID="attachments" runat="server" />
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
