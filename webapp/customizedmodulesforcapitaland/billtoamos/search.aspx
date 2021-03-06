﻿<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.OleDb" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();
        dateDateOfReading.DateTime = new DateTime(DateTime.Today.Year, DateTime.Today.Month,1).AddMonths(-1);
        dateDateOfReading.DateTimeTo = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1,23,59,59).AddDays(-1);
        gridResults.Commands[0].Visible = (OApplicationSetting.Current.PostingStartDay <= DateTime.Today.Day && OApplicationSetting.Current.PostingEndDay >= DateTime.Today.Day);
    }


    /// <summary>
    /// Constructs the equipment tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        return new EquipmentTreePopulater(null, true, true, Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, true, true, 
            Security.Decrypt(Request["TYPE"]),false,false);
    }


    /// <summary>
    /// Searches the panel.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition = Query.True;
        if (treeEquipment.SelectedValue != "")
        {
            OEquipment oEquipment = TablesLogic.tEquipment[new Guid(treeEquipment.SelectedValue)];
            if (oEquipment != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tReading.Point.Equipment.HierarchyPath.Like(oEquipment.HierarchyPath + "%");

        }
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                e.CustomCondition = e.CustomCondition & (TablesLogic.tReading.Point.Location.HierarchyPath.Like(location.HierarchyPath + "%") | TablesLogic.tReading.Point.Equipment.Location.HierarchyPath.Like(location.HierarchyPath + "%"));
        }
        if (treeLocation.SelectedValue == "" && treeEquipment.SelectedValue == "")
        {
            ExpressionCondition locCondition = Query.False;
            ExpressionCondition eqptCondition = TablesLogic.tReading.Point.EquipmentID == null;
            foreach (OPosition position in AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"])))
            {
                foreach (OLocation location in position.LocationAccess)
                    locCondition = locCondition | TablesLogic.tReading.Point.Location.HierarchyPath.Like(location.HierarchyPath + "%") | TablesLogic.tReading.Point.Equipment.Location.HierarchyPath.Like(location.HierarchyPath + "%");
                foreach (OEquipment equipment in position.EquipmentAccess)
                    eqptCondition = eqptCondition | TablesLogic.tReading.Point.Equipment.HierarchyPath.Like(equipment.HierarchyPath + "%");
            }
            e.CustomCondition = locCondition & eqptCondition;
        }

        e.CustomCondition = e.CustomCondition
            // Removed this condition so that those readings for Singtel Base Station will appear.
            //& TablesLogic.tReading.Point.Location.AmosAssetID != null 
            & ((TablesLogic.tReading.Point.Tenant.AmosOrgID != null | TablesLogic.tReading.Point.TenantLease.Tenant.AmosOrgID != null)
            & TablesLogic.tReading.Point.TenantContact.AmosContactID != null & TablesLogic.tReading.Point.TenantContact.AmosBillAddressID != null
            & TablesLogic.tReading.BillToAMOSStatus != 6);
    }


    protected void gridResults_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "BillSelected")
        {
            if (IsDataValid())
            {
                if (dataKeys.Count > 0)
                {
                    List<OReading> readingList = TablesLogic.tReading.LoadList(TablesLogic.tReading.ObjectID.In(dataKeys),
                        TablesLogic.tReading.Point.TenantID.Asc,
                        TablesLogic.tReading.Point.TenantLeaseID.Asc,
                        TablesLogic.tReading.Point.TenantLease.TenantID.Asc,
                        TablesLogic.tReading.Point.TenantContactID.Asc);

                    String prevKey = "";
                    int? batchID = OBill.GenerateNextBatchID();
                    int? batchNo = OBill.GenerateNextBatchNumber();

                    int countPostedReadings = 0;
                    using(Connection c= new Connection())
                    {
                        for (int i = 0; i < readingList.Count; i++)
                        {
                            OReading reading = readingList[i];

                            if (reading.BillToAMOSStatus == 0 || reading.BillToAMOSStatus == 3 || reading.BillToAMOSStatus == 5)
                            {
                                String currentKey = "";

                                if (reading.Point.TenantID != null)
                                    currentKey = currentKey + reading.Point.TenantID;
                                if (reading.Point.TenantLeaseID != null)
                                {
                                    currentKey = currentKey + reading.Point.TenantLeaseID;
                                    if (reading.Point.TenantLease.TenantID != null)
                                        currentKey = currentKey + reading.Point.TenantLease.TenantID;
                                }
                                if (reading.Point.TenantContactID != null)
                                    currentKey = currentKey + reading.Point.TenantContactID;

                                if (prevKey == currentKey)
                                {
                                    OBill.AddBillItem(readingList[i - 1].LastestBillID, readingList[i]);
                                }
                                else
                                {
                                    OBill.CreateBill(reading, batchID, batchNo);
                                }
                                prevKey = currentKey;
                                countPostedReadings++;
                            }
                        }
                        c.Commit();
                    }
                    panel.PerformSearch();
                    panel.Message = string.Format(Resources.Messages.BillToAmos_MarkedForPostingSuccessfully, countPostedReadings);
                }
            }
            else
            {
                panel.Message = Resources.Errors.BillToAmos_DataValidateNotSuccessful;
            }
        }
        else if (commandName == "CancelPosting")
        {
            if (IsDataValid())
            {
                if (dataKeys.Count > 0)
                {
                    List<OReading> readingList = TablesLogic.tReading.LoadList(TablesLogic.tReading.ObjectID.In(dataKeys),
                        TablesLogic.tReading.Point.TenantID.Asc,
                        TablesLogic.tReading.Point.TenantLeaseID.Asc,
                        TablesLogic.tReading.Point.TenantLease.TenantID.Asc,
                        TablesLogic.tReading.Point.TenantContactID.Asc);
                    int countCancelledReadings = 0;
                    using (Connection c = new Connection())
                    {
                        for (int i = 0; i < readingList.Count; i++)
                        {
                            OReading reading = readingList[i];

                            if (reading.BillToAMOSStatus == 0 || reading.BillToAMOSStatus == 3 || reading.BillToAMOSStatus == 5)
                            {
                                reading.BillToAMOSStatus = 6;
                                reading.Save();
                                countCancelledReadings += 1;
                            }
                        }
                        c.Commit();
                    }
                    this.panel.PerformSearch();
                    panel.Message = string.Format(Resources.Messages.BillToAmos_CancelledSuccessfully, countCancelledReadings);
                }
            }
        }
    }

    public bool IsDataValid()
    {
        bool isValid = true;

        foreach (GridViewRow dr in gridResults.Rows)
        {
            OReading reading = TablesLogic.tReading.Load(new Guid(gridResults.DataKeys[dr.RowIndex][0].ToString()));

            if (reading.Point.Tenant == null && reading.Point.TenantLease == null)
                isValid = false;
            else if (reading.Point.Tenant != null)
            {
                if (reading.Point.Tenant.AmosOrgID == null)
                    isValid = false;
            }
            else if (reading.Point.TenantLease != null)
            {
                if (reading.Point.TenantLease.Tenant == null)
                    isValid = false;
                else if (reading.Point.TenantLease.Tenant.AmosOrgID == null)
                    isValid = false;
            }
            
            if (reading.Point.TenantContact == null)
                isValid = false;
            else if (reading.Point.TenantContact.AmosOrgID==null)
                isValid = false;
            else if (reading.Point.TenantContact.AmosBillAddressID==null)
                isValid = false;
            
            if (reading.Point.Location == null)
                isValid = false;

            OLocation currentLocation = reading.Point.Location;
            while (currentLocation != null)
            {
                if (currentLocation.AmosAssetID != null)
                    break;
                currentLocation = currentLocation.Parent;
            }
            if (currentLocation == null || currentLocation.AmosAssetID == null)
                isValid = false;
            
            if(!isValid)
                dr.BackColor = System.Drawing.Color.LightCoral;
        }
        return isValid;
    }
    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        int count = 0;
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (gridResults.DataKeys[e.Row.RowIndex][0] != DBNull.Value)
            {
                OReading reading = TablesLogic.tReading.Load(new Guid(gridResults.DataKeys[e.Row.RowIndex][0].ToString()));
                if (reading != null)
                {
                    if (reading.Point != null)
                    {
                        if (reading.Point.TenantLease != null)
                        {
                            if (reading.Point.TenantLease.LeaseStatus != "N")
                            {
                                e.Row.BackColor = System.Drawing.Color.LightPink;
                                count++;
                            }
                        }
                    }
                }
            }
        }
        if (count > 0)
        {
            Hint.Visible = true;
            Hint.Text = String.Format(Resources.Messages.Reading_Hint, count);
        }
            
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form2" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
        meta:resourcekey="panelMainResource1">
        <web:search runat="server" ID="panel" Caption="Bill To AMOS" GridViewID="gridResults"
            EditButtonVisible="false" BaseTable="tReading" OnSearch="panel_Search" SearchType="ObjectQuery"
            OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1"></web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" 
                meta:resourcekey="tabSearchResource1">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                    BorderStyle="NotSet" meta:resourcekey="uitabview3Resource1">
                    <ui:UIFieldRadioList runat='server' ID="radioIsApplicableForLocation" PropertyName="Point.IsApplicableForLocation"
                        Caption="Location/Equipment" 
                        meta:resourcekey="radioIsApplicableForLocationResource1" TextAlign="Right">
                        <Items>
                            <asp:ListItem Text="Any" Selected="True" meta:resourcekey="ListItemResource1"></asp:ListItem>
                            <asp:ListItem Value="1" Text="Location" meta:resourcekey="ListItemResource2"></asp:ListItem>
                            <asp:ListItem Value="0" Text="Equipment" meta:resourcekey="ListItemResource3"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:uifieldtreelist runat="server" id="treeLocation" Caption="Location" 
                        OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" 
                        meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" 
                        TreeValueMode="SelectedNode">
                    </ui:uifieldtreelist>
                    <ui:uifieldtreelist runat="server" id="treeEquipment" Caption="Equipment" 
                        OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" 
                        meta:resourcekey="treeEquipmentResource1" ShowCheckBoxes="None" 
                        TreeValueMode="SelectedNode">
                    </ui:uifieldtreelist>
                    <ui:uifielddatetime runat="server" id="dateDateOfReading" Caption="Date of Reading"
                        PropertyName="DateOfReading" ShowTimeControls="True" SearchType="Range" 
                        meta:resourcekey="dateDateOfReadingResource1" ShowDateControls="True">
                    </ui:uifielddatetime>
                    <ui:UIFieldListBox runat="server" ID="listBillToAMOSStatus" Caption="Billing Status" PropertyName="BillToAMOSStatus">
                        <Items>
                            <asp:ListItem Value="0" Text="Not Posted to AMOS"></asp:ListItem>
                            <asp:ListItem Value="1" Text="Ready for Posting"></asp:ListItem>
                            <asp:ListItem Value="2" Text="Posted to AMOS"></asp:ListItem>
                            <asp:ListItem Value="3" Text="Rejected by AMOS"></asp:ListItem>
                            <asp:ListItem Value="4" Text="Accepted by AMOS"></asp:ListItem>
                            <asp:ListItem Value="5" Text="Unable to Post Due to Error"></asp:ListItem>
                        </Items>
                    </ui:UIFieldListBox>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                    BorderStyle="NotSet" meta:resourcekey="uitabview4Resource1">
                    <ui:UIHint runat="server" ID="Hint" Visible="False" meta:resourcekey="HintResource3">
                    </ui:UIHint>
                    <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" OnAction="gridResults_Action"
                        SortExpression="DateOfReading DESC" DataKeyNames="ObjectID"
                        GridLines="Both" PageSize="1000" 
                        RowErrorColor="" style="clear:both;" OnRowDataBound="gridResults_RowDataBound" meta:resourcekey="gridResultsResource4">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand
                                CommandName="BillSelected" CommandText="Bill Selected to AMOS" ConfirmText="Are you sure you want to post the selected readings to AMOS for billing?"
                                ImageUrl="~/images/accept.png" />
                            <cc1:UIGridViewCommand 
                                CommandName="CancelPosting" CommandText="Cancel Billing to AMOS"
                                ConfirmText="Are you sure you want to cancel this posting? This CANNOT BE UNDONE!"
                                ImageUrl="~/images/cross.gif" />
                        </commands>
                        <Columns>
                            <cc1:UIGridViewBoundColumn DataField="Point.ObjectName" HeaderText="Point" 
                                meta:resourcekey="UIGridViewBoundColumnResource2" 
                                PropertyName="Point.ObjectName" ResourceAssemblyName="" 
                                SortExpression="Point.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Point.LocationOrEquipmentPath" 
                                HeaderText="Location/Equipment" 
                                meta:resourcekey="UIGridViewBoundColumnResource3" 
                                PropertyName="Point.LocationOrEquipmentPath" ResourceAssemblyName="" 
                                SortExpression="Point.LocationOrEquipmentPath">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Reading" HeaderText="Reading" 
                                meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="Reading" 
                                ResourceAssemblyName="" SortExpression="Reading">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="DateOfReading" 
                                HeaderText="Date Of Reading" meta:resourcekey="UIGridViewBoundColumnResource6" 
                                PropertyName="DateOfReading" ResourceAssemblyName="" 
                                SortExpression="DateOfReading" DataFormatString="{0:dd-MMM-yyyy}">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Consumption" 
                                HeaderText="Consumption"
                                PropertyName="Consumption" ResourceAssemblyName="" 
                                SortExpression="Consumption" DataFormatString="{0:#,##0.00}" meta:resourcekey="UIGridViewBoundColumnResource28">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Tariff" 
                                HeaderText="Tariff"
                                PropertyName="Tariff" ResourceAssemblyName="" 
                                SortExpression="Tariff" DataFormatString="{0:#,##0.0000}" meta:resourcekey="UIGridViewBoundColumnResource29">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Factor" 
                                HeaderText="Factor"
                                PropertyName="Factor" ResourceAssemblyName="" 
                                SortExpression="Factor" DataFormatString="{0:#,##0.00}" meta:resourcekey="UIGridViewBoundColumnResource30">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Discount" 
                                HeaderText="Discount(%)"
                                PropertyName="Discount" ResourceAssemblyName="" 
                                SortExpression="Discount" DataFormatString="{0:#,##0.00}" meta:resourcekey="UIGridViewBoundColumnResource31">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="BillAmount" 
                                HeaderText="Bill Amount"
                                PropertyName="BillAmount" ResourceAssemblyName="" 
                                SortExpression="BillAmount" DataFormatString="{0:#,##0.00}" meta:resourcekey="UIGridViewBoundColumnResource32">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Point.TenantName" 
                                HeaderText="Tenant Name" 
                                PropertyName="Point.TenantName" ResourceAssemblyName="" 
                                SortExpression="Point.TenantName" meta:resourcekey="UIGridViewBoundColumnResource33">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Point.TenantLease.LeaseStartDate" 
                                HeaderText="Lease Start Date" 
                                PropertyName="Point.TenantLease.LeaseStartDate" ResourceAssemblyName="" 
                                SortExpression="Point.TenantLease.LeaseStartDate" DataFormatString="{0:dd-MMM-yyyy}" meta:resourcekey="UIGridViewBoundColumnResource34">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Point.TenantLease.LeaseEndDate" 
                                HeaderText="Lease End Date" 
                                PropertyName="Point.TenantLease.LeaseEndDate" ResourceAssemblyName="" 
                                SortExpression="Point.TenantLease.LeaseEndDate" DataFormatString="{0:dd-MMM-yyyy}" meta:resourcekey="UIGridViewBoundColumnResource35">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Point.TenantLease.Status" 
                                HeaderText="Lease Status" 
                                PropertyName="Point.TenantLease.Status" ResourceAssemblyName="" 
                                SortExpression="Point.TenantLease.Status" meta:resourcekey="UIGridViewBoundColumnResource36">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="BillToAMOSStatusText" 
                                HeaderText="Bill To AMOS Status" 
                                PropertyName="BillToAMOSStatusText" ResourceAssemblyName="" 
                                SortExpression="BillToAMOSStatusText" meta:resourcekey="UIGridViewBoundColumnResource37">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>

