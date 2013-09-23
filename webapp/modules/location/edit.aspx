<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.IO" %>
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

        if (!IsPostBack)
        {
            PriceAtOwnership.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
        }
        
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
        return new LocationTreePopulater(panel.SessionObject.ParentID, true, true,
            Security.Decrypt(Request["TYPE"]));
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
            <ui:uitabstrip id="tabObject" runat="server" borderstyle="NotSet" 
                meta:resourcekey="tabObjectResource1">
                <ui:uitabview id="uitabview1" runat="server" borderstyle="NotSet" 
                    caption="Details" meta:resourcekey="uitabview1Resource1">
                    <web:base ID="objectBase" runat="server" meta:resourceKey="objectBaseResource1" 
                        ObjectNameTooltip="The location name as displayed on screen." 
                        ObjectNumberVisible="false" />
                    <table border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <td nowrap>
                                <ui:uifieldtreelist id="ParentID" runat="server" caption="Belongs Under" 
                                    meta:resourcekey="ParentIDResource1" 
                                    onacquiretreepopulater="ParentID_AcquireTreePopulater" propertyname="ParentID" 
                                    showcheckboxes="None" 
                                    tooltip="The location or group under which this item belongs." 
                                    treevaluemode="SelectedNode" validaterequiredfield="True">
                                </ui:uifieldtreelist>
                            </td>
                            <td valign="middle" width="40px">
                                <web:map ID="buttonMap" runat="server" TargetControlID="ParentID" />
                            </td>
                        </tr>
                    </table>
                    <ui:uifieldtextbox id="textRunningNumberCode" runat="server" 
                        caption="Running Number Code" internalcontrolwidth="95%" 
                        meta:resourcekey="textRunningNumberCodeResource1" 
                        propertyname="RunningNumberCode">
                    </ui:uifieldtextbox>
                    <ui:uifieldradiolist id="IsPhysicalLocation" runat="server" 
                        caption="Folder/Physical" meta:resourcekey="IsPhysicalLocationResource1" 
                        onselectedindexchanged="IsPhysicalLocation_SelectedIndexChanged" 
                        propertyname="IsPhysicalLocation" textalign="Right" 
                        tooltip="Indicates if this item is a folder or a physical location." 
                        validaterequiredfield="True">
                        <Items>
                            <asp:ListItem meta:resourceKey="ListItemResource1" Value="0">Folder &nbsp;</asp:ListItem>
                            <asp:ListItem meta:resourceKey="ListItemResource2" Value="1">Physical Location</asp:ListItem>
                        </Items>
                    </ui:uifieldradiolist>
                    <ui:uipanel id="panelLocation1" runat="server" borderstyle="NotSet" 
                        meta:resourcekey="panelLocation1Resource1" width="100%">
                        <ui:uifieldtreelist id="LocationTypeID" runat="server" caption="Location Type" 
                            meta:resourcekey="LocationTypeIDResource1" 
                            onacquiretreepopulater="LocationTypeID_AcquireTreePopulater" 
                            onselectednodechanged="LocationTypeID_SelectedNodeChanged" 
                            propertyname="LocationTypeID" showcheckboxes="None" 
                            tooltip="The type of this location." treevaluemode="SelectedNode" 
                            validaterequiredfield="True">
                            <contextmenubuttons>
                                <ui:uibutton id="buttonEditLocationType" runat="server" alwaysenabled="True" 
                                    causesvalidation="False" 
                                    confirmtext="Please remember to save this Location before editing the Location Type.\n\nAre you sure you want to continue?" 
                                    imageurl="~/images/edit.gif" meta:resourcekey="buttonEditLocationTypeResource1" 
                                    onclick="buttonEditLocationType_Click" text="Edit Location Type" />
                                <ui:uibutton id="buttonViewLocationType" runat="server" alwaysenabled="True" 
                                    causesvalidation="False" 
                                    confirmtext="Please remember to save this Location before viewing the Location Type.\n\nAre you sure you want to continue?" 
                                    imageurl="~/images/view.gif" meta:resourcekey="buttonViewLocationTypeResource1" 
                                    onclick="buttonViewLocationType_Click" text="View Location Type" />
                            </contextmenubuttons>
                        </ui:uifieldtreelist>
                        <ui:uifieldtextbox id="AddressCountry" runat="server" caption="Country" 
                            internalcontrolwidth="95%" maxlength="255" 
                            meta:resourcekey="AddressCountryResource1" propertyname="AddressCountry">
                        </ui:uifieldtextbox>
                        <ui:uifieldtextbox id="AddressState" runat="server" caption="State" 
                            internalcontrolwidth="95%" maxlength="255" 
                            meta:resourcekey="AddressStateResource1" propertyname="AddressState">
                        </ui:uifieldtextbox>
                        <ui:uifieldtextbox id="AddressCity" runat="server" caption="City" 
                            internalcontrolwidth="95%" maxlength="255" 
                            meta:resourcekey="AddressCityResource1" propertyname="AddressCity">
                        </ui:uifieldtextbox>
                        <ui:uifieldtextbox id="Address" runat="server" caption="Address" 
                            internalcontrolwidth="95%" maxlength="255" meta:resourcekey="AddressResource1" 
                            propertyname="Address">
                        </ui:uifieldtextbox>
                        <ui:uiseparator id="sep1" runat="server" meta:resourcekey="sep1Resource1" />
                        <ui:uifielddatetime id="DateOfOwnership" runat="server" 
                            caption="Date of Ownership" imageclearurl="~/calendar/dateclr.gif" 
                            imageurl="~/calendar/date.gif" meta:resourcekey="DateOfOwnershipResource1" 
                            propertyname="DateOfOwnership" showdatecontrols="True" 
                            tooltip="The date from which this location was acquired.">
                        </ui:uifielddatetime>
                        <ui:uifieldtextbox id="PriceAtOwnership" runat="server" 
                            caption="Price at Ownership" internalcontrolwidth="95%" 
                            meta:resourcekey="PriceAtOwnershipResource1" propertyname="PriceAtOwnership" 
                            span="Half" tooltip="The price of the location when acquired." 
                            validatedatatypecheck="True" validaterangefield="True" 
                            validationdatatype="Currency" validationrangemax="99999999999999" 
                            validationrangemin="0" validationrangetype="Currency">
                        </ui:uifieldtextbox>
                        <ui:uifieldtextbox id="LifeSpan" runat="server" caption="Life Span (years)" 
                            internalcontrolwidth="95%" meta:resourcekey="LifeSpanResource1" 
                            propertyname="LifeSpan" span="Half" 
                            tooltip="The life span of this location in years." validatedatatypecheck="True" 
                            validaterangefield="True" validationdatatype="Integer" validationrangemin="0" 
                            validationrangetype="Integer">
                        </ui:uifieldtextbox>
                        <ui:uifieldtextbox id="GrossFloorArea" runat="server" caption="Gross Floor Area" 
                            internalcontrolwidth="95%" meta:resourcekey="GrossFloorAreaResource1" 
                            propertyname="GrossFloorArea" span="Half" validatedatatypecheck="True" 
                            validaterangefield="True" validationdatatype="Currency" 
                            validationrangemax="99999999999999" validationrangemin="0" 
                            validationrangetype="Currency">
                        </ui:uifieldtextbox>
                        <ui:uifieldtextbox id="NetLettableArea" runat="server" caption="Net Lettable Area" 
                            internalcontrolwidth="95%" meta:resourcekey="NetLettableAreaResource1" 
                            propertyname="NetLettableArea" span="Half" validatedatatypecheck="True" 
                            validaterangefield="True" validationdatatype="Currency" 
                            validationrangemax="99999999999999" validationrangemin="0" 
                            validationrangetype="Currency">
                        </ui:uifieldtextbox>
                    </ui:uipanel>
                </ui:uitabview>
                <ui:uitabview id="uitabview3" runat="server" borderstyle="NotSet" 
                    caption="Equipment" meta:resourcekey="uitabview3Resource1">
                    <ui:uigridview id="Equipment" runat="server" caption="Equipment" 
                        checkboxcolumnvisible="False" datakeynames="ObjectID" gridlines="Both" 
                        imagerowerrorurl="" keyname="ObjectID" meta:resourcekey="EquipmentResource1" 
                        onaction="Equipment_Action" propertyname="Equipment" rowerrorcolor="" 
                        style="clear:both;" width="100%">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:uigridviewbuttoncolumn alwaysenabled="True" buttontype="Image" 
                                commandname="EditObject" 
                                confirmtext="Please remember to save this Location before editing the Equipment.\n\nAre you sure you want to continue?" 
                                imageurl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewbuttoncolumn>
                            <ui:uigridviewbuttoncolumn alwaysenabled="True" buttontype="Image" 
                                commandname="ViewObject" 
                                confirmtext="Please remember to save this Location before viewing the Equipment.\n\nAre you sure you want to continue?" 
                                imageurl="~/images/view.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewbuttoncolumn>
                            <ui:uigridviewboundcolumn datafield="ObjectName" headertext="Equipment Name" 
                                meta:resourcekey="UIGridViewColumnResource1" propertyname="ObjectName" 
                                resourceassemblyname="" sortexpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="EquipmentType.ObjectName" 
                                headertext="Equipment Type" meta:resourcekey="UIGridViewColumnResource2" 
                                propertyname="EquipmentType.ObjectName" resourceassemblyname="" 
                                sortexpression="EquipmentType.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="SerialNumber" headertext="Serial Number" 
                                meta:resourcekey="UIGridViewColumnResource3" propertyname="SerialNumber" 
                                resourceassemblyname="" sortexpression="SerialNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="ModelNumber" headertext="Model Number" 
                                meta:resourcekey="UIGridViewColumnResource4" propertyname="ModelNumber" 
                                resourceassemblyname="" sortexpression="ModelNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                    </ui:uigridview>
                </ui:uitabview>
                <ui:uitabview id="tabPoints" runat="server" borderstyle="NotSet" caption="Points" 
                    meta:resourcekey="tabPointsResource1">
                    <ui:uibutton id="buttonRefresh" runat="server" imageurl="~/images/refresh.gif" 
                        meta:resourcekey="buttonRefreshResource1" onclick="buttonRefresh_Click" 
                        text="Refresh" />
                    <ui:uibutton id="buttonCreatePoints" runat="server" 
                        confirmtext="Are you sure you want to create points for the selected location type? Existing points will not be removed or overwritten." 
                        imageurl="~/images/add.png" meta:resourcekey="buttonCreatePointsResource1" 
                        onclick="buttonCreatePoints_Click" 
                        text="Create Points for this Location Type" />
                    <br />
                    <br />
                    <ui:uigridview id="UIGridViewReading" runat="server" caption="Points" 
                        checkboxcolumnvisible="False" datakeynames="ObjectID" gridlines="Both" 
                        imagerowerrorurl="" keyname="ObjectID" meta:resourcekey="ReadingResource1" 
                        onaction="UIGridViewReading_Action" onprerender="UIGridViewReading_PreRender" 
                        onrowdatabound="UIGridViewReading_RowDataBound" propertyname="Point" 
                        rowerrorcolor="" style="clear:both;" width="100%">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:uigridviewbuttoncolumn buttontype="Image" commandname="EditObject" 
                                confirmtext="Please remember to save this Location before editing the Point.\n\nAre you sure you want to continue?" 
                                imageurl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource3">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewbuttoncolumn>
                            <ui:uigridviewboundcolumn datafield="ObjectName" headertext="Point Name" 
                                meta:resourcekey="UIGridViewReadColumnResource1" propertyname="ObjectName" 
                                resourceassemblyname="" sortexpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="Description" headertext="Description" 
                                meta:resourcekey="UIGridViewReadColumnResource1" propertyname="Description" 
                                resourceassemblyname="" sortexpression="Description">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="UnitOfMeasure.ObjectName" 
                                headertext="Parameter" meta:resourcekey="UIGridViewReadColumnResource1" 
                                propertyname="UnitOfMeasure.ObjectName" resourceassemblyname="" 
                                sortexpression="UnitOfMeasure.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="LatestReading.Reading" 
                                headertext="Last Reading" meta:resourcekey="UIGridViewReadColumnResource1" 
                                propertyname="LatestReading.Reading" resourceassemblyname="" 
                                sortexpression="LatestReading.Reading">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="LatestReading.DateOfReading" 
                                dataformatstring="{0:dd-MMM-yyyy HH:mm:ss}" headertext="Last Reading Date/Time" 
                                meta:resourcekey="UIGridViewReadColumnResource1" 
                                propertyname="LatestReading.DateOfReading" resourceassemblyname="" 
                                sortexpression="LatestReading.DateOfReading">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                    </ui:uigridview>
                </ui:uitabview>
                <ui:uitabview id="tabEvents" runat="server" borderstyle="NotSet" caption="Events" 
                    meta:resourcekey="tabEventsResource1">
                    <ui:uibutton id="buttonRefreshEvent" runat="server" 
                        imageurl="~/images/refresh.gif" meta:resourcekey="buttonRefreshEventResource1" 
                        onclick="buttonRefreshEvent_Click" text="Refresh" />
                    <br />
                    <br />
                    <ui:uigridview id="UIGridViewEvent" runat="server" caption="Events" 
                        checkboxcolumnvisible="False" datakeynames="ObjectID" gridlines="Both" 
                        imagerowerrorurl="" keyname="ObjectID" meta:resourcekey="EventResource1" 
                        onaction="UIGridViewEvent_Action" propertyname="OPCAEEvents" rowerrorcolor="" 
                        style="clear:both;" width="100%">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <ui:uigridviewbuttoncolumn buttontype="Image" commandname="EditObject" 
                                confirmtext="Please remember to save this Location before editing the OPC AE Event.\n\nAre you sure you want to continue?" 
                                imageurl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource4">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewbuttoncolumn>
                            <ui:uigridviewboundcolumn datafield="ObjectName" headertext="Source" 
                                meta:resourcekey="UIGridViewEventColumnResource1" propertyname="ObjectName" 
                                resourceassemblyname="" sortexpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="LatestEvent.ConditionName" 
                                headertext="Condition Name" meta:resourcekey="UIGridViewEventColumnResource1" 
                                propertyname="LatestEvent.ConditionName" resourceassemblyname="" 
                                sortexpression="LatestEvent.ConditionName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="LatestEvent.SubConditionName" 
                                headertext="Sub Condition Name" 
                                meta:resourcekey="UIGridViewEventColumnResource1" 
                                propertyname="LatestEvent.SubConditionName" resourceassemblyname="" 
                                sortexpression="LatestEvent.SubConditionName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="LatestEvent.Severity" headertext="Severity" 
                                meta:resourcekey="UIGridViewEventColumnResource1" 
                                propertyname="LatestEvent.Severity" resourceassemblyname="" 
                                sortexpression="LatestEvent.Severity">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn datafield="LatestEvent.DateOfEvent" 
                                dataformatstring="{0:dd-MMM-yyyy HH:mm:ss}" headertext="Time" 
                                meta:resourcekey="UIGridViewEventColumnResource1" 
                                propertyname="LatestEvent.DateOfEvent" resourceassemblyname="" 
                                sortexpression="LatestEvent.DateOfEvent">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                    </ui:uigridview>
                </ui:uitabview>
                <!--Rachel 13 April 2007 Customized object-->
                <ui:uitabview id="attributeTabView" runat="server" borderstyle="NotSet" 
                    caption="Attribute" meta:resourcekey="attributeTabViewResource1">
                </ui:uitabview>
                <!--end-->
                <!--Sli 08 Oct 2009 Location Map-->
                <ui:uitabview id="tabMap" runat="server" borderstyle="NotSet" caption="Map" 
                    meta:resourcekey="tabMapResource1" visible="False">
                    <ui:uifieldtextbox id="CoordinateLeft" runat="server" border="0" 
                        caption="Left Position" cellpadding="2" cellspacing="0" enabled="False" 
                        height="20px" internalcontrolwidth="95%" maxlength="4" 
                        meta:resourcekey="CoordinateLeftResource1" propertyname="CoordinateLeft" 
                        span="Half" style="float: left; table-layout: fixed;" visible="False">
                    </ui:uifieldtextbox>
                    <ui:uifieldtextbox id="CoordinateRight" runat="server" border="0" 
                        caption="Top Position" cellpadding="2" cellspacing="0" enabled="False" 
                        height="20px" internalcontrolwidth="95%" maxlength="4" 
                        meta:resourcekey="CoordinateRightResource1" propertyname="CoordinateRight" 
                        span="Half" style="float: left; table-layout: fixed;" visible="False">
                    </ui:uifieldtextbox>
                    <iframe id="iframe1" runat="server" frameborder="0" height="500" scrolling="no" 
                        src="../../map/MapPosition.aspx" width="970px"></iframe>
                    <input id="aa" runat="server" type="hidden" value="9"></input>
                        <input id="bb" runat="server" type="hidden" value="9"></input>
                            <ui:uihint id="hintMoveMarker" runat="server" 
                                meta:resourcekey="hintMoveMarkerResource1">
                                <asp:Table runat="server" CellPadding="4" CellSpacing="0" Width="100%">
                                    <asp:TableRow runat="server">
                                        <asp:TableCell runat="server" VerticalAlign="Top" Width="16px"><asp:Image 
                                            runat="server" ImageUrl="~/images/information.gif" />
                                        </asp:TableCell>
                                        <asp:TableCell runat="server" VerticalAlign="Top"><asp:Label runat="server">Move 
                                        the marker to position it on the map.</asp:Label>
                                        </asp:TableCell>
                                    </asp:TableRow>
                                </asp:Table>
                            </ui:uihint>
                        </input>
                    </input>
                </ui:uitabview>
                <!--end-->
                <ui:uitabview id="uitabview4" runat="server" borderstyle="NotSet" caption="Memo" 
                    meta:resourcekey="uitabview4Resource1">
                    <web:memo ID="Memo1" runat="server" />
                </ui:uitabview>
                <ui:uitabview id="uitabview2" runat="server" borderstyle="NotSet" 
                    caption="Attachments" meta:resourcekey="uitabview2Resource1">
                    <web:attachments ID="attachments" runat="server" />
                </ui:uitabview>
            </ui:uitabstrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
