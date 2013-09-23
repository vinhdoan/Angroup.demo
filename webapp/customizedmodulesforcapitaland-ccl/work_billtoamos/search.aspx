<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

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
        dateOfWork.DateTime = new DateTime(DateTime.Today.Year, DateTime.Today.Month,1).AddMonths(-1);
        dateOfWork.DateTimeTo = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1, 23, 59, 59).AddDays(-1);
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
        DataTable dtWorkOrder = new DataTable();
        ExpressionCondition WorkCondition = Query.True;

        DataTable dtWorkJustification = new DataTable();
        ExpressionCondition WorkJustificationCondition = Query.True;
        
        e.CustomCondition = Query.True;
        e.CustomCondition = e.CustomCondition & TablesLogic.tWork.CurrentActivity.CurrentStateName == "Close" &
                                                TablesLogic.tWork.IsChargedToCaller == 1;
        if (treeEquipment.SelectedValue != "")
        {
            OEquipment oEquipment = TablesLogic.tEquipment[new Guid(treeEquipment.SelectedValue)];
            if (oEquipment != null)
            {
                e.CustomCondition = e.CustomCondition & TablesLogic.tWork.Equipment.HierarchyPath.Like(oEquipment.HierarchyPath + "%");
                WorkCondition = WorkCondition & TablesLogic.tWork.Equipment.HierarchyPath.Like(oEquipment.HierarchyPath + "%");
                WorkJustificationCondition = WorkJustificationCondition & TablesLogic.tRequestForQuotation.Equipment.HierarchyPath.Like(oEquipment.HierarchyPath + "%");
            }

        }
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
            {
                e.CustomCondition = e.CustomCondition & (TablesLogic.tWork.Location.HierarchyPath.Like(location.HierarchyPath + "%") | TablesLogic.tReading.Point.Equipment.Location.HierarchyPath.Like(location.HierarchyPath + "%"));
                WorkCondition = WorkCondition & (TablesLogic.tWork.Location.HierarchyPath.Like(location.HierarchyPath + "%") | TablesLogic.tWork.Equipment.Location.HierarchyPath.Like(location.HierarchyPath + "%"));
                WorkJustificationCondition = WorkJustificationCondition & (TablesLogic.tRequestForQuotation.Location.HierarchyPath.Like(location.HierarchyPath + "%") | TablesLogic.tRequestForQuotation.Equipment.Location.HierarchyPath.Like(location.HierarchyPath + "%"));
            }
        }
        if (treeLocation.SelectedValue == "" && treeEquipment.SelectedValue == "")
        {
            ExpressionCondition locCondition = Query.False;
            ExpressionCondition eqptCondition = TablesLogic.tWork.EquipmentID == null;
            ExpressionCondition locCondition1 = Query.False;
            ExpressionCondition eqptCondition1 = TablesLogic.tRequestForQuotation.EquipmentID == null;
            foreach (OPosition position in AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"])))
            {
                foreach (OLocation location in position.LocationAccess)
                {
                    locCondition = locCondition | TablesLogic.tWork.Location.HierarchyPath.Like(location.HierarchyPath + "%") | TablesLogic.tWork.Equipment.Location.HierarchyPath.Like(location.HierarchyPath + "%");
                    locCondition1 = locCondition1 | TablesLogic.tRequestForQuotation.Location.HierarchyPath.Like(location.HierarchyPath + "%") | TablesLogic.tRequestForQuotation.Equipment.Location.HierarchyPath.Like(location.HierarchyPath + "%");
                }
                foreach (OEquipment equipment in position.EquipmentAccess)
                {
                    eqptCondition = eqptCondition | TablesLogic.tWork.Equipment.HierarchyPath.Like(equipment.HierarchyPath + "%");
                    eqptCondition1 = eqptCondition1 | TablesLogic.tRequestForQuotation.Equipment.HierarchyPath.Like(equipment.HierarchyPath + "%");
                }
            }
            e.CustomCondition = locCondition & eqptCondition;
            WorkCondition = locCondition & eqptCondition;
            WorkJustificationCondition = locCondition1 & eqptCondition1;
        }

        e.CustomCondition = e.CustomCondition
            // Removed this condition so that those readings for Singtel Base Station will appear.
            //& TablesLogic.tReading.Point.Location.AmosAssetID != null 
            & (TablesLogic.tWork.TenantLease.Tenant.AmosOrgID != null
            & TablesLogic.tWork.TenantContact.AmosContactID != null & TablesLogic.tWork.TenantContact.AmosBillAddressID != null
            & TablesLogic.tWork.BillToAMOSStatus != 6);
        
    }


    protected void gridResults_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "BillSelected")
        {
            if (IsDataValid())
            {
                if (dataKeys.Count > 0)
                {
                    List<OWork> wordList = TablesLogic.tWork.LoadList(TablesLogic.tWork.ObjectID.In(dataKeys),
                        TablesLogic.tWork.TenantLeaseID.Asc,
                        TablesLogic.tWork.TenantLease.TenantID.Asc,
                        TablesLogic.tWork.TenantContactID.Asc);

                    String prevKey = "";
                    int? batchID = OBill.GenerateNextBatchID();
                    int? batchNo = OBill.GenerateNextBatchNumber();

                    int countPostedReadings = 0;
                    using(Connection c= new Connection())
                    {
                        for (int i = 0; i < wordList.Count; i++)
                        {
                            OWork work = wordList[i];

                            if (work.BillToAMOSStatus == 0 || work.BillToAMOSStatus == 3 || work.BillToAMOSStatus == 5)
                            {
                                String currentKey = "";


                                if (work.TenantLeaseID != null)
                                {
                                    currentKey = currentKey + work.TenantLeaseID;
                                    if (work.TenantLease.TenantID != null)
                                        currentKey = currentKey + work.TenantLease.TenantID;
                                }
                                if (work.TenantContactID != null)
                                    currentKey = currentKey + work.TenantContactID;

                                if (prevKey == currentKey)
                                {
                                    OBill.AddBillItem(wordList[i - 1].LastestBillID, wordList[i]);
                                }
                                else
                                {
                                    OBill.CreateBill(work, batchID, batchNo);
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
                    List<OWork> workList = TablesLogic.tWork.LoadList(TablesLogic.tWork.ObjectID.In(dataKeys),
                        TablesLogic.tWork.TenantLeaseID.Asc,
                        TablesLogic.tWork.TenantLease.TenantID.Asc,
                        TablesLogic.tWork.TenantContactID.Asc);
                    int countCancelledReadings = 0;
                    using (Connection c = new Connection())
                    {
                        for (int i = 0; i < workList.Count; i++)
                        {
                            OWork work = workList[i];

                            if (work.BillToAMOSStatus == 0 || work.BillToAMOSStatus == 3 || work.BillToAMOSStatus == 5)
                            {
                                work.BillToAMOSStatus = 6;
                                work.Save();
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
            OWork work = TablesLogic.tWork.Load(new Guid(gridResults.DataKeys[dr.RowIndex][0].ToString()));

            if (work.TenantLease == null && work.TenantLease.Tenant == null)
                isValid = false;
            //else if (work.TenantLease.Tenant != null)
            //{
            //    if (work.TenantLease.AmosOrgID == null)
            //        isValid = false;
            //}
            else if (work.TenantLease != null)
            {
                if (work.TenantLease.Tenant == null)
                    isValid = false;
                else if (work.TenantLease.Tenant.AmosOrgID == null)
                    isValid = false;
            }
            
            if (work.TenantContact == null)
                isValid = false;
            else if (work.TenantContact.AmosOrgID==null)
                isValid = false;
            else if (work.TenantContact.AmosBillAddressID==null)
                isValid = false;
            
            if (work.Location == null)
                isValid = false;

            OLocation currentLocation = work.Location;
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
        //if (e.Row.RowType == DataControlRowType.DataRow)
        //{
        //    if (gridResults.DataKeys[e.Row.RowIndex][0] != DBNull.Value)
        //    {
        //        OReading reading = TablesLogic.tReading.Load(new Guid(gridResults.DataKeys[e.Row.RowIndex][0].ToString()));
        //        if (reading != null)
        //        {
        //            if (reading.Point != null)
        //            {
        //                if (reading.Point.TenantLease != null)
        //                {
        //                    if (reading.Point.TenantLease.LeaseStatus != "N")
        //                    {
        //                        e.Row.BackColor = System.Drawing.Color.LightPink;
        //                        count++;
        //                    }
        //                }
        //            }
        //        }
        //    }
        //}
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
            EditButtonVisible="false" BaseTable="tWork" OnSearch="panel_Search" SearchType="ObjectQuery"
            SearchTextBoxHint="Work Order Number, Description" 
            AutoSearchOnLoad="true" MaximumNumberOfResults="30" 
            SearchTextBoxPropertyNames="ObjectName,Role.RoleName" AdvancedSearchPanelID="panelAdvanced"
            OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1"></web:search>
        <div class="div-form">
                <ui:uifielddatetime runat="server" id="dateOfWork" Caption="Date of Work"
                    PropertyName="ActualStartDateTime" ShowTimeControls="True" SearchType="Range" 
                    ShowDateControls="True">
                </ui:uifielddatetime>
            <%--<ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" 
                meta:resourcekey="tabSearchResource1">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                    BorderStyle="NotSet" meta:resourcekey="uitabview3Resource1">--%>
                <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
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
                </ui:UIPanel>
                </ui:UITabView>
                <%--<ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                    BorderStyle="NotSet" meta:resourcekey="uitabview4Resource1">--%>
                    <ui:UIHint runat="server" ID="Hint" Visible="False" meta:resourcekey="HintResource3">
                    </ui:UIHint>
                    <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" OnAction="gridResults_Action"
                        SortExpression="ActualStartDateTime DESC" DataKeyNames="ObjectID"
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
                            <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="WO / WJ Number" 
                                PropertyName="ObjectNumber" ResourceAssemblyName="" 
                                SortExpression="ObjectNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Location.Path" 
                                HeaderText="Location" 
                                PropertyName="Location.Path" ResourceAssemblyName="" 
                                SortExpression="Location.Path">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <%--<cc1:UIGridViewBoundColumn DataField="Tenant.ObjectName" HeaderText="Tenant" 
                                PropertyName="Tenant.ObjectName" 
                                ResourceAssemblyName="" SortExpression="Tenant.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>--%>
                            <cc1:UIGridViewBoundColumn DataField="TaskAmount" 
                                HeaderText="Bill Amount"
                                PropertyName="TaskAmount" ResourceAssemblyName="" 
                                SortExpression="TaskAmount" DataFormatString="{0:#,##0.00}">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="TenantLease.LeaseStartDate" 
                                HeaderText="Lease Start Date" 
                                PropertyName="TenantLease.LeaseStartDate" ResourceAssemblyName="" 
                                SortExpression="TenantLease.LeaseStartDate" DataFormatString="{0:dd-MMM-yyyy}">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="TenantLease.LeaseEndDate" 
                                HeaderText="Lease End Date" 
                                PropertyName="TenantLease.LeaseEndDate" ResourceAssemblyName="" 
                                SortExpression="TenantLease.LeaseEndDate" DataFormatString="{0:dd-MMM-yyyy}">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="TenantLease.Status" 
                                HeaderText="Lease Status" 
                                PropertyName="TenantLease.Status" ResourceAssemblyName="" 
                                SortExpression="TenantLease.Status" meta:resourcekey="UIGridViewBoundColumnResource36">
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
                <%--</ui:UITabView>
            </ui:UITabStrip>--%>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>

