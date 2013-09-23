<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.IO" %>
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
            Security.Decrypt(Request["TYPE"]), false,false);
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
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
        meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Location" BaseTable="tLocation" OnPopulateForm="panel_PopulateForm"
            OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
        </web:object>
        <div class="div-main">
            <ui:uitabstrip id="tabObject" runat="server" borderstyle="NotSet" meta:resourcekey="tabObjectResource1">
                <ui:uitabview id="uitabview1" runat="server" borderstyle="NotSet" caption="Details" meta:resourcekey="uitabview1Resource1">
                    <web:base ID="objectBase" runat="server" meta:resourceKey="objectBaseResource1" ObjectNameTooltip="The location name as displayed on screen." ObjectNumberVisible="false" />
                    <table border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <td >
                                <ui:uifieldtreelist id="ParentID" runat="server" caption="Belongs Under" meta:resourcekey="ParentIDResource1" onacquiretreepopulater="ParentID_AcquireTreePopulater" propertyname="ParentID" showcheckboxes="None" tooltip="The location or group under which this item belongs." treevaluemode="SelectedNode" validaterequiredfield="True"  OnSelectedNodeChanged="ParentID_SelectedNodeChanged">
                                </ui:uifieldtreelist>
                            </td>
                            <td valign="middle" width="40px">
                                <web:map ID="buttonMap" runat="server" TargetControlID="ParentID" />
                            </td>
                        </tr>
                    </table>
                    <ui:uifieldtextbox id="textRunningNumberCode" runat="server" caption="Running Number Code" internalcontrolwidth="95%" meta:resourcekey="textRunningNumberCodeResource1" propertyname="RunningNumberCode">
                    </ui:uifieldtextbox>
                    <ui:uifieldradiolist id="IsPhysicalLocation" runat="server" caption="Folder/Physical" meta:resourcekey="IsPhysicalLocationResource1" onselectedindexchanged="IsPhysicalLocation_SelectedIndexChanged" propertyname="IsPhysicalLocation" textalign="Right" tooltip="Indicates if this item is a folder or a physical location." validaterequiredfield="True">
                        <Items>
                            <asp:ListItem meta:resourceKey="ListItemResource1" Text="Folder &nbsp;" Value="0"></asp:ListItem>
                            <asp:ListItem meta:resourceKey="ListItemResource2" Text="Physical Location" Value="1"></asp:ListItem>
                        </Items>
                    </ui:uifieldradiolist>
                    <ui:uipanel id="panelLocation1" runat="server" borderstyle="NotSet" meta:resourcekey="panelLocation1Resource1" width="100%">
                        <ui:uifieldtreelist id="LocationTypeID" runat="server" caption="Location Type" meta:resourcekey="LocationTypeIDResource1" onacquiretreepopulater="LocationTypeID_AcquireTreePopulater" onselectednodechanged="LocationTypeID_SelectedNodeChanged" propertyname="LocationTypeID" showcheckboxes="None" tooltip="The type of this location." treevaluemode="SelectedNode" validaterequiredfield="True">
                            <contextmenubuttons>
                                <ui:uibutton id="buttonEditLocationType" runat="server" alwaysenabled="True" causesvalidation="False" confirmtext="Please remember to save this Location before editing the Location Type.\n\nAre you sure you want to continue?" imageurl="~/images/edit.gif" meta:resourcekey="buttonEditLocationTypeResource1" onclick="buttonEditLocationType_Click" text="Edit Location Type" />
                                <ui:uibutton id="buttonViewLocationType" runat="server" alwaysenabled="True" causesvalidation="False" confirmtext="Please remember to save this Location before viewing the Location Type.\n\nAre you sure you want to continue?" imageurl="~/images/view.gif" meta:resourcekey="buttonViewLocationTypeResource1" onclick="buttonViewLocationType_Click" text="View Location Type" />
                            </contextmenubuttons>
                        </ui:uifieldtreelist>
                        <ui:uifieldtextbox id="AddressCountry" runat="server" caption="Country" internalcontrolwidth="95%" maxlength="255" meta:resourcekey="AddressCountryResource1" propertyname="AddressCountry">
                        </ui:uifieldtextbox>
                        <ui:uifieldtextbox id="AddressState" runat="server" caption="State" internalcontrolwidth="95%" maxlength="255" meta:resourcekey="AddressStateResource1" propertyname="AddressState">
                        </ui:uifieldtextbox>
                        <ui:uifieldtextbox id="AddressCity" runat="server" caption="City" internalcontrolwidth="95%" maxlength="255" meta:resourcekey="AddressCityResource1" propertyname="AddressCity">
                        </ui:uifieldtextbox>
                        <ui:uifieldtextbox id="Address" runat="server" caption="Address" internalcontrolwidth="95%" maxlength="255" meta:resourcekey="AddressResource1" propertyname="Address">
                        </ui:uifieldtextbox>
                        
                        <ui:UISeparator id="sep1" runat="server" meta:resourcekey="sep1Resource1" />
                        <ui:uifielddatetime id="DateOfOwnership" runat="server" caption="Date of Ownership" imageclearurl="~/calendar/dateclr.gif" imageurl="~/calendar/date.gif" meta:resourcekey="DateOfOwnershipResource1" propertyname="DateOfOwnership" showdatecontrols="True" tooltip="The date from which this location was acquired.">
                        </ui:uifielddatetime>
                        <ui:uifieldtextbox id="PriceAtOwnership" runat="server" caption="Price at Ownership" internalcontrolwidth="95%" meta:resourcekey="PriceAtOwnershipResource1" propertyname="PriceAtOwnership" span="Half" tooltip="The price of the location when acquired." validatedatatypecheck="True" validaterangefield="True" validationdatatype="Currency" validationrangemax="99999999999999" validationrangemin="0" validationrangetype="Currency">
                        </ui:uifieldtextbox>
                        <ui:uifieldtextbox id="LifeSpan" runat="server" caption="Life Span (years)" internalcontrolwidth="95%" meta:resourcekey="LifeSpanResource1" propertyname="LifeSpan" span="Half" tooltip="The life span of this location in years." validatedatatypecheck="True" validaterangefield="True" validationdatatype="Integer" validationrangemin="0" validationrangetype="Integer">
                        </ui:uifieldtextbox>
                        <ui:uifieldtextbox id="GrossFloorArea" runat="server" caption="Gross Floor Area" internalcontrolwidth="95%" meta:resourcekey="GrossFloorAreaResource1" propertyname="GrossFloorArea" span="Half" validatedatatypecheck="True" validaterangefield="True" validationdatatype="Currency" validationrangemax="99999999999999" validationrangemin="0" validationrangetype="Currency">
                        </ui:uifieldtextbox>
                        <ui:uifieldtextbox id="NetLettableArea" runat="server" caption="Net Lettable Area" internalcontrolwidth="95%" meta:resourcekey="NetLettableAreaResource1" propertyname="NetLettableArea" span="Half" validatedatatypecheck="True" validaterangefield="True" validationdatatype="Currency" validationrangemax="99999999999999" validationrangemin="0" validationrangetype="Currency">
                        </ui:uifieldtextbox>
                        <br />
                        <br />
                        <br />
                        <ui:UIPanel runat="server" ID="panelBuilding" BorderStyle="NotSet" 
                            meta:resourcekey="panelBuildingResource1">
                            <ui:uifielddropdownlist id="ddl_BuildingOwner" runat="server" caption="Building Owner" meta:resourcekey="ddl_BuildingOwnerResource1" propertyname="BuildingOwnerID" validaterequiredfield="True">
                            </ui:uifielddropdownlist>
                            <table cellpadding='0' cellspacing='0' border='0' style="width: 100%">
                                <tr>
                                    <td style="width: 150px"></td>
                                    <td>
                                        <asp:Label runat="server" ID="hintBuildingOwner" 
                                            meta:resourcekey="hintBuildingOwnerResource1">This is the company that appears in the Deliver To section of a purchase order.</asp:Label>
                                        <br /><br />
                                    </td>
                                </tr>
                            </table>
                            <ui:uifielddropdownlist id="ddl_BuildingTrust" runat="server" caption="Building Trust" meta:resourcekey="ddl_BuildingTrustResource1" propertyname="BuildingTrustID" validaterequiredfield="True">
                            </ui:uifielddropdownlist>
                            <table cellpadding='0' cellspacing='0' border='0' style="width: 100%">
                                <tr>
                                    <td style="width: 150px"></td>
                                    <td>
                                        <asp:Label runat="server" ID="hintBuildingTrust" 
                                            meta:resourcekey="hintBuildingTrustResource1">This is the company that appears in the Bill To section of a purchase order.</asp:Label>
                                        <br /><br />
                                    </td>
                                </tr>
                            </table>
                            <ui:uifielddropdownlist id="ddl_BuildingManagement" runat="server" caption="Building Management" meta:resourcekey="ddl_BuildingManagementResource1" propertyname="BuildingManagementID" validaterequiredfield="True">
                            </ui:uifielddropdownlist>
                            <table cellpadding='0' cellspacing='0' border='0' style="width: 100%">
                                <tr>
                                    <td style="width: 150px"></td>
                                    <td>
                                        <asp:Label runat="server" ID="hintBuildingManagement" 
                                            meta:resourcekey="hintBuildingManagementResource1">This is the company that appears at the top of your purchase order.<br /><br /></asp:Label>
                                        
                                    </td>
                                </tr>
                            </table>
                            <ui:UIFieldDropDownList runat="server" ID="ddlDefaultLOASignatory" 
                                Caption="Default LOA Signatory" PropertyName="DefaultLOASignatoryID" 
                                meta:resourcekey="ddlDefaultLOASignatoryResource1"></ui:UIFieldDropDownList>
                        </ui:UIPanel>
                        
                        <br />
                        <br />
                        <ui:uifieldtextbox id="txtEmailForSAPFMSBudget" runat="server" caption="Email For SAP &lt;&gt; FMS Budget" internalcontrolwidth="95%" meta:resourcekey="txtEmailForSAPFMSBudgetResource1" propertyname="EmailForSAPFMSBudget">
                        </ui:uifieldtextbox>
                    </ui:uipanel>
                </ui:uitabview>
                <ui:uitabview id="tabviewAmos" runat="server" borderstyle="NotSet" caption="Amos" meta:resourcekey="tabviewAmosResource1">
                    <ui:uiseparator id="AmosSeparator" runat="server" caption="Amos" meta:resourcekey="AmosSeparatorResource1" />
                    <ui:uifieldcheckbox id="cbFromAmos" runat="server" caption="From Amos" enabled="False" meta:resourcekey="cbFromAmosResource1" propertyname="FromAmos" textalign="Right">
                    </ui:uifieldcheckbox>
                    <ui:uifieldtextbox id="AmosAssetID" runat="server" caption="Amos Asset ID" internalcontrolwidth="95%" meta:resourcekey="AmosAssetIDResource1" propertyname="AmosAssetID" span="Half">
                    </ui:uifieldtextbox>
                    <ui:uifieldlabel id="AmosSuiteID" runat="server" caption="Amos Suite ID" 
                        enabled="False" internalcontrolwidth="95%" 
                        meta:resourcekey="AmosSuiteIDResource1" propertyname="AmosSuiteID" span="Half" 
                        DataFormatString="">
                    </ui:uifieldlabel>
                    <ui:uifieldlabel id="AmosLevelID" runat="server" caption="Amos Level ID" 
                        enabled="False" internalcontrolwidth="95%" 
                        meta:resourcekey="AmosLevelIDResource1" propertyname="AmosLevelID" span="Half" 
                        DataFormatString="">
                    </ui:uifieldlabel>
                    <ui:uifieldlabel id="AmosAssetTypeID" runat="server" 
                        caption="Amos Asset Type ID" enabled="False" internalcontrolwidth="95%" 
                        meta:resourcekey="AmosAssetTypeIDResource1" propertyname="AmosAssetTypeID" 
                        span="Half" DataFormatString="">
                    </ui:uifieldlabel>
                    <ui:uifieldlabel id="IsActive" runat="server" caption="Is Active" 
                        enabled="False" internalcontrolwidth="95%" meta:resourcekey="IsActiveResource1" 
                        propertyname="IsActiveText" span="Half" DataFormatString="">
                    </ui:uifieldlabel>
                    <ui:uifieldlabel id="LeaseableFrom" runat="server" caption="Leaseable From" dataformatstring="{0:dd-MMM-yyyy}" enabled="False" internalcontrolwidth="95%" meta:resourcekey="LeaseableFromResource1" propertyname="LeaseableFrom" span="Half">
                    </ui:uifieldlabel>
                    <ui:uifieldlabel id="LeaseableTo" runat="server" caption="Leaseable To" dataformatstring="{0:dd-MMM-yyyy}" enabled="False" internalcontrolwidth="95%" meta:resourcekey="LeaseableToResource1" propertyname="LeaseableTo" span="Half">
                    </ui:uifieldlabel>
                    <ui:uifieldlabel id="LeaseableArea" runat="server" caption="Leaseable Area" dataformatstring="{0:#,##0.00}" enabled="False" internalcontrolwidth="95%" meta:resourcekey="LeaseableAreaResource1" propertyname="LeaseableArea" span="Half">
                    </ui:uifieldlabel>
                    <ui:uifieldlabel id="updatedOn" runat="server" caption="Updated On" dataformatstring="{0:dd-MMM-yyyy}" enabled="False" internalcontrolwidth="95%" meta:resourcekey="updatedOnResource1" propertyname="updatedOn" span="Half">
                    </ui:uifieldlabel>
                </ui:uitabview>
                <ui:uitabview id="tabviewTenantLease" runat="server" borderstyle="NotSet" caption="Leases" meta:resourcekey="tabviewTenantLeaseResource1">
                    <ui:uigridview ID="Uigridview1" runat="server" bindobjectstorows="True" 
                        caption="Leases" checkboxcolumnvisible="False" datakeynames="ObjectID" 
                        gridlines="Both" meta:resourcekey="UIGridViewResource1" 
                        propertyname="TenantLease" rowerrorcolor="" 
                        sortexpression="LeaseStartDate Desc" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:uigridviewboundcolumn datafield="Tenant.ObjectName" headertext="Tenant" meta:resourcekey="UIGridViewBoundColumnResource1" propertyname="Tenant.ObjectName" resourceassemblyname="" sortexpression="Tenant.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="LeaseStartDate" dataformatstring="{0:dd-MMM-yyyy}" headertext="Lease Start Date" meta:resourcekey="UIGridViewBoundColumnResource2" propertyname="LeaseStartDate" resourceassemblyname="" sortexpression="LeaseStartDate">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="LeaseEndDate" dataformatstring="{0:dd-MMM-yyyy}" headertext="Lease End Date" meta:resourcekey="UIGridViewBoundColumnResource3" propertyname="LeaseEndDate" resourceassemblyname="" sortexpression="LeaseEndDate">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Status" headertext="Lease Status" meta:resourcekey="UIGridViewBoundColumnResource4" propertyname="Status" resourceassemblyname="" sortexpression="Status">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="AmosLeaseID" headertext="Amos Lease ID" meta:resourcekey="UIGridViewBoundColumnResource5" propertyname="AmosLeaseID" resourceassemblyname="" sortexpression="AmosLeaseID">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="updatedOn" dataformatstring="{0:dd-MMM-yyyy}" headertext="Updated On" meta:resourcekey="UIGridViewBoundColumnResource6" propertyname="updatedOn" resourceassemblyname="" sortexpression="updatedOn">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                    </ui:uigridview>
                </ui:uitabview>
                <ui:uitabview id="uitabview3" runat="server" borderstyle="NotSet" caption="Equipment" meta:resourcekey="uitabview3Resource1">
                    <ui:uigridview id="Equipment" runat="server" caption="Equipment" 
                        checkboxcolumnvisible="False" datakeynames="ObjectID" gridlines="Both" 
                        keyname="ObjectID" meta:resourcekey="EquipmentResource1" 
                        onaction="Equipment_Action" propertyname="Equipment" rowerrorcolor="" 
                        style="clear:both;" width="100%" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:uigridviewbuttoncolumn alwaysenabled="True" buttontype="Image" commandname="EditObject" confirmtext="Please remember to save this Location before editing the Equipment.\n\nAre you sure you want to continue?" imageurl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewbuttoncolumn>
                            <ui:uigridviewbuttoncolumn alwaysenabled="True" buttontype="Image" commandname="ViewObject" confirmtext="Please remember to save this Location before viewing the Equipment.\n\nAre you sure you want to continue?" imageurl="~/images/view.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewbuttoncolumn>
                            <ui:uigridviewboundcolumn datafield="ObjectName" headertext="Equipment Name" meta:resourcekey="UIGridViewColumnResource1" propertyname="ObjectName" resourceassemblyname="" sortexpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="EquipmentType.ObjectName" headertext="Equipment Type" meta:resourcekey="UIGridViewColumnResource2" propertyname="EquipmentType.ObjectName" resourceassemblyname="" sortexpression="EquipmentType.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="SerialNumber" headertext="Serial Number" meta:resourcekey="UIGridViewColumnResource3" propertyname="SerialNumber" resourceassemblyname="" sortexpression="SerialNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="ModelNumber" headertext="Model Number" meta:resourcekey="UIGridViewColumnResource4" propertyname="ModelNumber" resourceassemblyname="" sortexpression="ModelNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                    </ui:uigridview>
                </ui:uitabview>
                <ui:uitabview id="tabPoints" runat="server" borderstyle="NotSet" caption="Points" meta:resourcekey="tabPointsResource1">
                    <ui:uibutton id="buttonRefresh" runat="server" imageurl="~/images/refresh.gif" meta:resourcekey="buttonRefreshResource1" onclick="buttonRefresh_Click" text="Refresh" />
                    <ui:uibutton id="buttonCreatePoints" runat="server" confirmtext="Are you sure you want to create points for the selected location type? Existing points will not be removed or overwritten." imageurl="~/images/add.png" meta:resourcekey="buttonCreatePointsResource1" onclick="buttonCreatePoints_Click" text="Create Points for this Location Type" />
                    <br />
                    <br />
                    <ui:uigridview id="UIGridViewReading" runat="server" caption="Points" 
                        checkboxcolumnvisible="False" datakeynames="ObjectID" gridlines="Both" 
                        keyname="ObjectID" meta:resourcekey="ReadingResource1" 
                        onaction="UIGridViewReading_Action" onprerender="UIGridViewReading_PreRender" 
                        onrowdatabound="UIGridViewReading_RowDataBound" propertyname="Point" 
                        rowerrorcolor="" style="clear:both;" width="100%" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:uigridviewbuttoncolumn buttontype="Image" commandname="EditObject" confirmtext="Please remember to save this Location before editing the Point.\n\nAre you sure you want to continue?" imageurl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource3">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewbuttoncolumn>
                            <ui:uigridviewboundcolumn datafield="ObjectName" headertext="Point Name" meta:resourcekey="UIGridViewReadColumnResource1" propertyname="ObjectName" resourceassemblyname="" sortexpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Description" headertext="Description" meta:resourcekey="UIGridViewReadColumnResource1" propertyname="Description" resourceassemblyname="" sortexpression="Description">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="UnitOfMeasure.ObjectName" headertext="Parameter" meta:resourcekey="UIGridViewReadColumnResource1" propertyname="UnitOfMeasure.ObjectName" resourceassemblyname="" sortexpression="UnitOfMeasure.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="LatestReading.Reading" headertext="Last Reading" meta:resourcekey="UIGridViewReadColumnResource1" propertyname="LatestReading.Reading" resourceassemblyname="" sortexpression="LatestReading.Reading">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="LatestReading.DateOfReading" dataformatstring="{0:dd-MMM-yyyy HH:mm:ss}" headertext="Last Reading Date/Time" meta:resourcekey="UIGridViewReadColumnResource1" propertyname="LatestReading.DateOfReading" resourceassemblyname="" sortexpression="LatestReading.DateOfReading">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                    </ui:uigridview>
                </ui:uitabview>
                <ui:uitabview id="tabEvents" runat="server" borderstyle="NotSet" caption="Events" meta:resourcekey="tabEventsResource1">
                    <ui:uibutton id="buttonRefreshEvent" runat="server" imageurl="~/images/refresh.gif" meta:resourcekey="buttonRefreshEventResource1" onclick="buttonRefreshEvent_Click" text="Refresh" />
                    <br />
                    <br />
                    <ui:uigridview id="UIGridViewEvent" runat="server" caption="Events" 
                        checkboxcolumnvisible="False" datakeynames="ObjectID" gridlines="Both" 
                        keyname="ObjectID" meta:resourcekey="EventResource1" 
                        onaction="UIGridViewEvent_Action" propertyname="OPCAEEvents" rowerrorcolor="" 
                        style="clear:both;" width="100%" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:uigridviewbuttoncolumn buttontype="Image" commandname="EditObject" confirmtext="Please remember to save this Location before editing the OPC AE Event.\n\nAre you sure you want to continue?" imageurl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource4">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewbuttoncolumn>
                            <ui:uigridviewboundcolumn datafield="ObjectName" headertext="Source" meta:resourcekey="UIGridViewEventColumnResource1" propertyname="ObjectName" resourceassemblyname="" sortexpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="LatestEvent.ConditionName" headertext="Condition Name" meta:resourcekey="UIGridViewEventColumnResource1" propertyname="LatestEvent.ConditionName" resourceassemblyname="" sortexpression="LatestEvent.ConditionName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="LatestEvent.SubConditionName" headertext="Sub Condition Name" meta:resourcekey="UIGridViewEventColumnResource1" propertyname="LatestEvent.SubConditionName" resourceassemblyname="" sortexpression="LatestEvent.SubConditionName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="LatestEvent.Severity" headertext="Severity" meta:resourcekey="UIGridViewEventColumnResource1" propertyname="LatestEvent.Severity" resourceassemblyname="" sortexpression="LatestEvent.Severity">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="LatestEvent.DateOfEvent" dataformatstring="{0:dd-MMM-yyyy HH:mm:ss}" headertext="Time" meta:resourcekey="UIGridViewEventColumnResource1" propertyname="LatestEvent.DateOfEvent" resourceassemblyname="" sortexpression="LatestEvent.DateOfEvent">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                    </ui:uigridview>
                </ui:uitabview>
                <ui:uitabview id="attributeTabView" runat="server" borderstyle="NotSet" caption="Attribute" meta:resourcekey="attributeTabViewResource1">
                </ui:uitabview>
                <ui:uitabview id="tabMap" runat="server" borderstyle="NotSet" caption="Map" meta:resourcekey="tabMapResource1" visible="False">
                    <ui:uifieldtextbox id="CoordinateLeft" runat="server" border="0" caption="Left Position" cellpadding="2" cellspacing="0" enabled="False" height="20px" internalcontrolwidth="95%" maxlength="4" meta:resourcekey="CoordinateLeftResource1" propertyname="CoordinateLeft" span="Half" style="float: left; table-layout: fixed;" visible="False">
                    </ui:uifieldtextbox>
                    <ui:uifieldtextbox id="CoordinateRight" runat="server" border="0" caption="Top Position" cellpadding="2" cellspacing="0" enabled="False" height="20px" internalcontrolwidth="95%" maxlength="4" meta:resourcekey="CoordinateRightResource1" propertyname="CoordinateRight" span="Half" style="float: left; table-layout: fixed;" visible="False">
                    </ui:uifieldtextbox>
                    <iframe id="iframe1" runat="server" frameborder="0" height="500" scrolling="no" src="../../map/MapPosition.aspx" width="970px"></iframe>
                    <input id="aa" runat="server" type="hidden" value="9"></input>
</input>
</input>
</input>
                    <input id="bb" runat="server" type="hidden" value="9"></input>
</input>
</input>
</input>
                    <cc1:UIHint ID="hintMoveMarker" runat="server" 
                        meta:resourceKey="hintMoveMarkerResource1">Move the marker to position it on the map.
                    </cc1:UIHint>



                </input>
                </input>
                </input>
                </ui:uitabview>
                <ui:uitabview id="uitabview4" runat="server" borderstyle="NotSet" caption="Memo" meta:resourcekey="uitabview4Resource1">
                    <web:memo ID="Memo1" runat="server" />
                </ui:uitabview>
                <ui:uitabview id="uitabview2" runat="server" borderstyle="NotSet" caption="Attachments" meta:resourcekey="uitabview2Resource1">
                    <web:attachments ID="attachments" runat="server" />
                </ui:uitabview>
            </ui:uitabstrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
