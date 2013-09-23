<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Workflow" %>
<%@ Import Namespace="System.Workflow.Runtime" %>
<%@ Import Namespace="System.Workflow.Activities" %>
<%@ Import Namespace="System.Workflow.ComponentModel" %>
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
        TypeOfWorkID.Bind(OCode.GetWorkTypes(AppSession.User, Security.Decrypt(Request["TYPE"]), null));
        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();

        listStatus.Bind(OActivity.GetStatuses(Security.Decrypt(Request["TYPE"])), "ObjectName", "ObjectName");
        foreach (ListItem item in listStatus.Items)
        {
            string translated = Resources.WorkflowStates.ResourceManager.GetString(item.Text);
            if (translated != null && translated != "")
                item.Text = translated;
        }
    }

    /// <summary>
    /// Performs search with custom conditions.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition = Query.True;
        if (treeEquipment.SelectedValue != "")
        {
            OEquipment oEquipment = TablesLogic.tEquipment[new Guid(treeEquipment.SelectedValue)];
            if (oEquipment != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tWork.Equipment.HierarchyPath.Like(oEquipment.HierarchyPath + "%");

        }
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tWork.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
        if (treeLocation.SelectedValue == "" && treeEquipment.SelectedValue == "")
        {
            ExpressionCondition locCondition = Query.False;
            ExpressionCondition eqptCondition = TablesLogic.tWork.EquipmentID == null;
            foreach (OPosition position in AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"])))
            {
                foreach (OLocation location in position.LocationAccess)
                    locCondition = locCondition | TablesLogic.tWork.Location.HierarchyPath.Like(location.HierarchyPath + "%");
                foreach (OEquipment equipment in position.EquipmentAccess)
                    eqptCondition = eqptCondition | TablesLogic.tWork.Equipment.HierarchyPath.Like(equipment.HierarchyPath + "%");
            }
            e.CustomCondition = locCondition & eqptCondition;
        }

        List<ColumnOrder> orderColumns = new List<ColumnOrder>();
        orderColumns.Add(TablesLogic.tWork.CreatedDateTime.Desc);

        e.CustomSortOrder = orderColumns;
    }


    /// <summary>
    /// Occurs when user clicks on the show chart button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonShowChart_Click(object sender, EventArgs e)
    {
        ExpressionCondition cond = panel.GetConditionAndCustomCondition();
        if (cond == null)
            return;

        Session["GANTT"] = OWork.GetWorksDataTable(cond);

        Window.Open("../../components/gantt.aspx?S=" +
            HttpUtility.UrlEncode(Security.Encrypt("Gantt_ScheduledStartDateTime")) +
            "&E=" + HttpUtility.UrlEncode(Security.Encrypt("Gantt_ScheduledEndDateTime")) +
            "&T=" + HttpUtility.UrlEncode(Security.Encrypt("Gantt_WorkNumber")) +
            "&C=" + HttpUtility.UrlEncode(Security.Encrypt("Gantt_PercentageComplete")) +
            "&GROUP=0", "AnacleEAM_Gantt");
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
        return new LocationEquipmentTreePopulaterForCapitaland(null, true, true, true, Security.Decrypt(Request["TYPE"]));
    }


    /// <summary>
    /// Occurs when user mades selection on the type of work drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void TypeOfWorkID_SelectedIndexChanged(object sender, EventArgs e)
    {
        TypeOfServiceID.Items.Clear();
        TypeOfProblemID.Items.Clear();
        CauseOfProblemID.Items.Clear();
        ResolutionID.Items.Clear();
        if (TypeOfWorkID.SelectedValue != "")
            TypeOfServiceID.Bind(OCode.GetTypeOfServices(AppSession.User, new Guid(TypeOfWorkID.SelectedValue), Security.Decrypt(Request["TYPE"]), null));
    }

    
    /// <summary>
    ///  Binds the type of problem.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void TypeOfServiceID_SelectedIndexChanged(object sender, EventArgs e)
    {
        TypeOfProblemID.Items.Clear();
        CauseOfProblemID.Items.Clear();
        ResolutionID.Items.Clear();
        if (TypeOfServiceID.SelectedValue != null)
            TypeOfProblemID.Bind(OCode.GetCodesByParentID(new Guid(TypeOfServiceID.SelectedValue), null), "ObjectName", "ObjectID", true);
    }


    /// <summary>
    /// Binds the cause of problem.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void TypeOfProblemID_SelectedIndexChanged(object sender, EventArgs e)
    {
        CauseOfProblemID.Items.Clear();
        ResolutionID.Items.Clear();
        if (TypeOfProblemID.SelectedValue != "")
            CauseOfProblemID.Bind(OCode.GetCodesByParentID(new Guid(TypeOfProblemID.SelectedValue), null), "ObjectName", "ObjectID", true);
    }


    /// <summary>
    /// Binds the resolution.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CauseOfProblemID_SelectedIndexChanged(object sender, EventArgs e)
    {
        ResolutionID.Items.Clear();
        if (CauseOfProblemID.SelectedValue != "")
            ResolutionID.Bind(OCode.GetCodesByParentID(new Guid(CauseOfProblemID.SelectedValue), null), "ObjectName", "ObjectID", true);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        string controlName = Request.Params.Get("__EVENTTARGET");
        string arguement = Request.Params.Get("__EVENTARGUMENT");

        if (controlName == "treeLocation" && arguement.Contains("SEARCH") )
        {
            string[] arg = arguement.Split('_');

            if (arg != null && arg.Length == 2)
                treeLocation.SelectedValue = Security.Decrypt(arg[1]);
        }
    }

    /// <summary>
    /// Exports the searched works into Microsoft Project.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonExportProject_Click(object sender, EventArgs e)
    {
        /*
        ExpressionCondition condition = panel.GetConditionAndCustomCondition();
        string filepath = "";
        string filepathWithExt = "";

        DataTable dt = TablesLogic.tWork.SelectDistinct(
            TablesLogic.tWork.ObjectNumber,
            TablesLogic.tWork.WorkDescription,
            TablesLogic.tWork.ScheduledStartDateTime,
            TablesLogic.tWork.ScheduledEndDateTime,
            TablesLogic.tWork.ActualStartDateTime,
            TablesLogic.tWork.ActualEndDateTime,
            TablesLogic.tWork.PercentageComplete,
            TablesLogic.tWork.CurrentActivity.ObjectName.As("Status"))
            .Where(condition)
            .OrderBy(TablesLogic.tWork.ObjectNumber.Asc);



        Microsoft.Office.Interop.MSProject.Application objAppProject = new Microsoft.Office.Interop.MSProject.Application(); ;
        try
        {
            Microsoft.Office.Interop.MSProject.Project objProject;

            objAppProject.FileNew(Type.Missing, Type.Missing, Type.Missing, Type.Missing);
            objProject = objAppProject.ActiveProject;

            foreach (DataRow dr in dt.Rows)
            {
                string workDescription = dr["WorkDescription"].ToString();
                string objectNumber = dr["ObjectNumber"].ToString();
                object scheduledStartDateTime = dr["ScheduledStartDateTime"];
                object scheduledEndDateTime = dr["ScheduledEndDateTime"];
                object actualStartDateTime = dr["ActualStartDateTime"];
                object actualEndDateTime = dr["ActualEndDateTime"];

                Microsoft.Office.Interop.MSProject.Task task = objProject.Tasks.Add(objectNumber + ": " + workDescription, Type.Missing);

                task.ActualStart = actualStartDateTime != DBNull.Value ? (DateTime)actualStartDateTime : scheduledStartDateTime != DBNull.Value ? (DateTime)scheduledStartDateTime : DateTime.Today;
                task.ActualFinish = actualEndDateTime != DBNull.Value ? (DateTime)actualEndDateTime : scheduledEndDateTime != DBNull.Value ? (DateTime)scheduledEndDateTime : DateTime.Today;

                task.BaselineStart = scheduledStartDateTime == DBNull.Value ? DateTime.Today : (DateTime)scheduledStartDateTime;
                task.BaselineFinish = scheduledEndDateTime == DBNull.Value ? DateTime.Today : (DateTime)scheduledEndDateTime;

                task.PercentComplete = dr["PercentageComplete"] == DBNull.Value ? 0 : (int)dr["PercentageComplete"];
            }

            filepath = DiskCache.GetFilePath("msproject");
            filepathWithExt = filepath + ".mpp";
            
            if (System.IO.File.Exists(filepath))
                System.IO.File.Delete(filepath);
            if (System.IO.File.Exists(filepathWithExt))
                System.IO.File.Delete(filepathWithExt);
                
            objProject.SaveAs(filepath, Microsoft.Office.Interop.MSProject.PjFileFormat.pjMPP,
                Type.Missing, Type.Missing, Type.Missing, Type.Missing, Type.Missing, Type.Missing, Type.Missing,
                "MSProject.mpp.9", Type.Missing, Type.Missing, Type.Missing, Type.Missing, Type.Missing);

        }
        finally
        {
            objAppProject.Quit(Microsoft.Office.Interop.MSProject.PjSaveType.pjSave);

            while (true)
            {
                try
                {
                    if (System.IO.File.Exists(filepathWithExt))
                    {
                        System.IO.File.Copy(filepathWithExt, filepath, true);
                        Window.DownloadFile(filepath, "project.mpp", "application/vnd.ms-project");
                        break;
                    }
                }
                catch
                {
                }
                System.Threading.Thread.Sleep(1000);
            }
        }
*/

    }

    protected void btnAssignTechnician_Click(object sender, EventArgs e)
    {
        panel.Message = "";
        List<object> idList = gridResults.GetSelectedKeys();
        if (idList.Count > 0)
        {
            List<Guid> ids = new List<Guid>();
            foreach (Guid id in idList)
                ids.Add(id);

            List<OWork> workList = TablesLogic.tWork.LoadList(TablesLogic.tWork.ObjectID.In(ids), null);
            Session["WorkList"] = workList;
            Window.Open("AssignTechnician.aspx");
        }
        else
            panel.Message = "Please select at least one work to assign technician.";
    }
    /// <summary>
    /// Occurs when the user adds selected items.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonItemsAdded_Click(object sender, EventArgs e)
    {
        panel.PerformSearch();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form2" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" 
            BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Work" GridViewID="gridResults" BaseTable="tWork"
                SearchTextBoxPropertyNames="ObjectNumber,WorkDescription" SearchTextBoxHint="Work Order Number, Description"
                AutoSearchOnLoad="true" AdvancedSearchPanelID="panelAdvanced"
                OnSearch="panel_Search" OnPopulateForm="panel_PopulateForm" EditButtonVisible="false"
                AssignedCheckboxVisible="true" meta:resourcekey="panelResource1"></web:search>
            <div class="div-form">
                <%--<ui:UITabStrip runat="server" ID="tabSearch" 
                    meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        meta:resourcekey="uitabview3Resource1" 
                        BorderStyle="NotSet">--%>
                        <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                            <ui:UIButton runat="server" ID="buttonItemsAdded" CausesValidation="False" 
                                    OnClick="buttonItemsAdded_Click" meta:resourcekey="buttonItemsAddedResource1"></ui:UIButton>
                            <%--<ui:UIFieldTextBox ID="ObjectNumber" runat="server" Caption="Work Number" PropertyName="ObjectNumber"
                                meta:resourcekey="ObjectNumberResource1" InternalControlWidth="95%" />--%>
                            <table cellpadding="0" cellspacing="0" border="0">
                                <tr nowrap>
                                    <td nowrap>
                                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" meta:resourcekey="LocationResource1"
                                            ToolTip="Use this to select the location that this work applies to." 
                                            OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" 
                                            ShowCheckBoxes="None" 
                                            TreeValueMode="SelectedNode" />
                                    </td>
                                    <td width="40px" valign="middle">
                                        <web:map runat="server" id="buttonMap" TargetControlID="treeLocation">
                                        </web:map>
                                    </td>
                                </tr>
                            </table>  
                            <ui:UIFieldTreeList ID="treeEquipment" runat="server" Caption="Equipment" meta:resourcekey="EquipmentResource1"
                                OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" 
                                ToolTip="Use this to select the equipment that this work applies to." 
                                ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                            </ui:UIFieldTreeList>
                            <br />
                            <ui:UISeparator ID="Separator1" runat="server" Caption="Problem" meta:resourcekey="Separator1Resource1" />
                            <ui:UIFieldDropDownList runat="server" ID="TypeOfWorkID" OnSelectedIndexChanged="TypeOfWorkID_SelectedIndexChanged"
                                PropertyName="TypeOfWorkID" Caption="Type of Work" meta:resourcekey="TypeOfWorkIDResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="TypeOfServiceID" PropertyName="TypeOfServiceID"
                                Caption="Type of Service" 
                                meta:resourcekey="TypeOfServiceIDResource1" OnSelectedIndexChanged="TypeOfServiceID_SelectedIndexChanged">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="TypeOfProblemID" PropertyName="TypeOfProblemID"
                                Caption="Type of Problem" 
                                meta:resourcekey="TypeOfProblemIDResource1" OnSelectedIndexChanged="TypeOfProblemID_SelectedIndexChanged">
                            </ui:UIFieldDropDownList>
                            <%--<ui:UIFieldTextBox ID="WorkDescription" runat="server" Caption="Work Description"
                                PropertyName="WorkDescription" MaxLength="255" 
                                meta:resourcekey="WorkDescriptionResource1" InternalControlWidth="95%" />--%>
                            <ui:UIFieldDateTime runat="server" ID="ScheduledStartDateTime" PropertyName="ScheduledStartDateTime"
                                Caption="Scheduled Start" ToolTip="The date/time in which the work is scheduled to start."
                                ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" 
                                meta:resourcekey="ScheduledStartDateTimeResource1" SearchType="Range" ShowDateControls="True"></ui:UIFieldDateTime>
                            <ui:UIFieldDateTime runat="server" ID="ScheduledEndDateTime" PropertyName="ScheduledEndDateTime"
                                Caption="Scheduled End" ToolTip="The date/time in which the work is scheduled to complete."
                                ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" 
                                meta:resourcekey="ScheduledEndDateTimeResource1" SearchType="Range" ShowDateControls="True"></ui:UIFieldDateTime>
                            <br />
                            <br />
                            <ui:UISeparator ID="Separator2" runat="server" Caption="Resolution" meta:resourcekey="Separator2Resource1" />
                            <ui:UIFieldDropDownList runat="server" ID="CauseOfProblemID" PropertyName="CauseOfProblemID"
                                Caption="Cause of Problem" 
                                meta:resourcekey="CauseOfProblemIDResource1" OnSelectedIndexChanged="CauseOfProblemID_SelectedIndexChanged">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="ResolutionID" PropertyName="ResolutionID"
                                Caption="Resolution" meta:resourcekey="ResolutionIDResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldTextBox ID="ResolutionDescription" runat="server" Caption="Resolution Description"
                                PropertyName="ResolutionDescription" ToolTip="Details on the resolution of the problem."
                                meta:resourcekey="ResolutionDescriptionResource1" 
                                InternalControlWidth="95%" />
                            <ui:UIFieldDateTime runat="server" ID="ActualStartDateTime" PropertyName="ActualStartDateTime"
                                Caption="Actual Start" ToolTip="The date/time in which the work actually started."
                                ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" 
                                meta:resourcekey="ActualStartDateTimeResource1" SearchType="Range" ShowDateControls="True"></ui:UIFieldDateTime>
                            <ui:UIFieldDateTime runat="server" ID="ActualEndDateTime" PropertyName="ActualEndDateTime"
                                Caption="Actual End" ToolTip="The date/time in which the work actually completed."
                                ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" 
                                meta:resourcekey="ActualEndDateTimeResource1" SearchType="Range" ShowDateControls="True"></ui:UIFieldDateTime>
                            <%--<br />
                            <br />
                            <ui:UISeparator ID="Separator4" runat="server" Caption="Contract/Vendor" meta:resourcekey="Separator4Resource1" />
                            <ui:UIFieldTextBox runat="server" ID="ContractName" PropertyName="Contract.ObjectName"
                                Caption="Contract Name" ToolTip="The name of the contract applied to the work."
                                meta:resourcekey="ContractNameResource1" InternalControlWidth="95%" />
                            <ui:UIFieldTextBox runat="server" ID="VendorName" PropertyName="Contract.Vendor.ObjectName"
                                Caption="Vendor Name" ToolTip="The vendor responsible for the work." 
                                meta:resourcekey="VendorNameResource1" InternalControlWidth="95%" />--%>
                            <ui:UISeparator ID="UISeparator2" runat="server" Caption="Status" 
                                meta:resourcekey="UISeparator2Resource1" />
                            <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName"
                                Caption="Status" Rows="4" meta:resourcekey="listStatusResource1"></ui:UIFieldListBox>
                        </ui:UIPanel>
                    <%--</ui:UITabView>--%>
                    
                    <%--<ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        meta:resourcekey="uitabview4Resource1" 
                        BorderStyle="NotSet">--%>
                        <ui:UIButton ID="buttonShowChart" runat="server" ImageUrl="~/images/view.gif" OnClick="buttonShowChart_Click"
                            Text="Show Gantt Chart" meta:resourcekey="buttonShowChartResource1" />
                        <ui:UIButton ID="buttonExportProject" runat="server" ImageUrl="~/images/view.gif" 
                            Text="Export to Microsoft Project" OnClick="buttonExportProject_Click" Visible="False" 
                            meta:resourcekey="buttonExportProjectResource1" />
                            <ui:UIButton runat="server" ID="btnAssignTechnician" Text="AssignTechnician"
                            ImageUrl="~/images/add.gif" OnClick="btnAssignTechnician_Click" meta:resourcekey="btnAssignTechnicianResource1" />
                        <br />
                        <br />
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" meta:resourcekey="gridResultsResource1"
                            Width="100%" SortExpression="CreatedDateTime DESC" DataKeyNames="ObjectID" 
                            GridLines="Both" RowErrorColor="" style="clear:both;" ImageRowErrorUrl="">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="DeleteObject" CommandText="Delete Selected" 
                                    ConfirmText="Are you sure you wish to delete the selected items?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                    ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" 
                                    ImageUrl="~/images/view.gif" meta:resourceKey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                    ConfirmText="Are you sure you wish to delete this item?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="Work Number" 
                                    meta:resourceKey="UIGridViewColumnResource4" PropertyName="ObjectNumber" 
                                    ResourceAssemblyName="" SortExpression="ObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Case.ObjectNumber" 
                                    HeaderText="Case Number" meta:resourcekey="UIGridViewBoundColumnResource1" 
                                    PropertyName="Case.ObjectNumber" ResourceAssemblyName="" 
                                    SortExpression="Case.ObjectNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="WorkDescription" 
                                    HeaderText="Work Description" meta:resourceKey="UIGridViewColumnResource5" 
                                    PropertyName="WorkDescription" ResourceAssemblyName="" 
                                    SortExpression="WorkDescription">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TypeOfWork.ObjectName" 
                                    HeaderText="Type of Work" meta:resourceKey="UIGridViewColumnResource6" 
                                    PropertyName="TypeOfWork.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="TypeOfWork.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TypeOfService.ObjectName" 
                                    HeaderText="Type of Service" meta:resourceKey="UIGridViewColumnResource7" 
                                    PropertyName="TypeOfService.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="TypeOfService.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" 
                                    HeaderText="Status" meta:resourceKey="UIGridViewColumnResource8" 
                                    PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" 
                                    ResourceName="Resources.WorkflowStates" 
                                    SortExpression="CurrentActivity.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CreatedDateTime" 
                                    HeaderText="Created Date Time"
                                    PropertyName="CreatedDateTime" ResourceAssemblyName="" 
                                    ResourceName="" 
                                    SortExpression="CreatedDateTime DESC">
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
