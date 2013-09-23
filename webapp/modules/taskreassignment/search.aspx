<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
    }

    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        string strPos = "";
        string strUser = "";
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //Guid objectId = (Guid)gridResults.DataKeys[e.Row.RowIndex][0];
            //OActivity act = TablesLogic.tActivity.Load(objectId);
            //foreach (OPosition position in act.Positions)
            //    strPos = strPos == "" ? strPos + position.ObjectName : strPos + ", " + position.ObjectName;
            //foreach (OUser user in act.Users)
            //    strUser = strUser == "" ? strUser + user.ObjectName : strUser + ", " + user.ObjectName;
            //e.Row.Cells[8].Text = strPos;
            //e.Row.Cells[7].Text = strUser;
        }
    }


    //---------------------------------------------------------------
    // event
    //---------------------------------------------------------------
    protected void btnReassign_Clicked(object sender, EventArgs e)
    {
        Session["TASK"] = gridResults.GetSelectedKeys();
        Window.Open(Page.Request.ApplicationPath + "/" + "modules/taskreassignment/reassign.aspx?");
    }


    protected void dropTaskType_ControlChange(object sender, EventArgs e)
    {
        DataTable dt = TablesLogic.tActivity
                        .SelectDistinct(TablesLogic.tActivity.ObjectName.As("Status"),
                        TablesLogic.tActivity.ObjectName)
                        .Where(
                        (dropTaskType.SelectedItem.Text == "" ? Query.True :
                        TablesLogic.tActivity.ObjectTypeName == dropTaskType.SelectedValue) &
                        TablesLogic.tActivity.IsDeleted == 0);
        listStatus.Bind(dt, "Status", "ObjectName");
    }


    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        dropTaskType.Bind(OActivity.GetTaskTypeTable(), "TaskType", "ObjectTypeName");
        foreach (ListItem item in dropTaskType.Items)
        {
            string translatedText = Resources.Objects.ResourceManager.GetString(item.Text);
            if (translatedText != null && translatedText != "")
                item.Text = translatedText;
        }

        ((UIGridViewBoundColumn)gridResults.Columns[3]).DataFormatString =
            OApplicationSetting.Current.BaseCurrency.CurrencySymbol + "{0:n}";
        
        listStatus.Bind(OActivity.GetStatuses(""), "ObjectName", "ObjectName");
        listPriority.Bind(OActivity.GetPriority(), "Priority", "Priority");
        listPosition.Bind(OPosition.GetAllPositions(), "ObjectName", "ObjectID");
    }

    protected void gridTasks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header)
        {
            (e.Row.Cells[0].Controls[0] as CheckBox).Checked = true;
        }
    }

    protected void buttonSearch_Click(object sender, EventArgs e)
    {
        List<OUser> list = TablesLogic.tUser.LoadList
            (TablesLogic.tUser.ObjectName.Like("%" + textSearch.Text + "%") &
            TablesLogic.tUser.isTenant == 0);
        listUsers.Bind(list);
    }



    protected void gridResults_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "ReAssign")
        {
            popupAddContact.Show();
            objectPanelReassign.Visible = true;

            listUsers.Bind(OUser.GetAllNonTenantUsers());
            listPositions.Bind(OPosition.GetAllPositions(), "ObjectName", "ObjectID");
            listSecretaryPositions.Bind(OPosition.GetAllPositions(), "ObjectName", "ObjectID");
            
            DataTable dt = CreateDatatable();
            List<OActivity> activitylist = OActivity.GetTasks(gridResults.GetSelectedKeys());
            
            gridTasks.DataSource = activitylist;
            gridTasks.DataBind();
        }
    }

    protected DataTable CreateDatatable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("Task Number");
        dt.Columns.Add("Description");
        dt.Columns.Add("Task Type");
        dt.Columns.Add("Status");
        dt.Columns.Add("Priority", typeof(int));
        dt.Columns.Add("Users");
        dt.Columns.Add("Positions");
        dt.Columns.Add("TaskAmount", typeof(decimal));
        dt.Columns.Add("ObjectID", typeof(Guid));
        return dt;
    }

    protected void buttonCancel_Click(object sender, EventArgs e)
    {
        popupAddContact.Hide();
        objectPanelReassign.Visible = false;
    }

    protected void buttonConfirm_Click(object sender, EventArgs e)
    {
        bool isSaved;
        List<object> Ids = gridTasks.GetSelectedKeys();
        if (Ids.Count == 0)
        {
            gridTasks.ErrorMessage = Resources.Messages.General_NoTaskSelected;
            if (!objectPanelReassign.IsValid)
            {
                panel.Message = objectPanelReassign.CheckErrorMessages();
                return;
            }              
            
        }
        else
        {
            if (!objectPanelReassign.IsValid)
            {
                panel.Message = objectPanelReassign.CheckErrorMessages();
                return;
            }
            List<OUser> listOfUsers = new List<OUser>();
            foreach (ListItem item in (IEnumerable)listUsers.Items)
            {
                if (item.Selected == true)
                {
                    OUser user = TablesLogic.tUser.Load(new Guid(item.Value));
                    listOfUsers.Add(user);
                }
            }

            List<OPosition> listOfPositions = new List<OPosition>();
            foreach (ListItem item in (IEnumerable)listPositions.Items)
            {
                if (item.Selected == true)
                {
                    OPosition pos = TablesLogic.tPosition.Load(new Guid(item.Value));
                    listOfPositions.Add(pos);
                }
            }

            List<OPosition> listOfSecretaries = new List<OPosition>();
            foreach (ListItem item in (IEnumerable)listSecretaryPositions.Items)
            {
                if (item.Selected == true)
                {
                    OPosition pos = TablesLogic.tPosition.Load(new Guid(item.Value));
                    listOfSecretaries.Add(pos);
                }
            }

            foreach (object obj in Ids)
            {
                if (listOfPositions.Count > 0 || listOfUsers.Count > 0)
                {
                    OActivity act = TablesLogic.tActivity.Load(new Guid(obj.ToString()));
                    isSaved = OActivity.SaveTaskReassignment(act,
                        listOfUsers, listOfPositions, listOfSecretaries);
                    if (isSaved)
                        this.panel.Message = Resources.Messages.General_ItemSaved;
                }
                else
                {
                    this.panel.Message = Resources.Messages.General_NoItemSelected;
                }
            }


            DataTable dt = CreateDatatable();
            List<Object> objectlist = (List<Object>)Session["TASK"];
            List<OActivity> activitylist = OActivity.GetTasks(gridResults.GetSelectedKeys());

            gridTasks.DataSource = activitylist;
            gridTasks.DataBind();
            //List<OActivity> activitylist = OActivity.GetTasks(objectlist);
            //gridTasks_DataBind(dt, activitylist);
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
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Re-assign Tasks" GridViewID="gridResults" EditButtonVisible="false"
                BaseTable="tActivity" OnSearch="panel_Search" meta:resourcekey="panelResource1"
                SearchType="ObjectQuery" OnPopulateForm="panel_PopulateForm"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" 
                    meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <table style="width:100%">
                            <tr>
                                <td width="50%">
                                    <ui:UIFieldTextBox ID="textTaskNumber" runat="server" PropertyName="TaskNumber" 
                                        Caption="Task Number" MaxLength="255" InternalControlWidth="95%" 
                                        meta:resourcekey="textTaskNumberResource1" />
                                </td>
                                <td width="50%">
                                    <ui:UIFieldTextBox ID="textDescription" runat="server" PropertyName="Description"
                                        Caption="Description" InternalControlWidth="95%" 
                                        meta:resourcekey="textDescriptionResource1" />
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2" width="100%">
                                    <ui:UIFieldListBox ID="listPriority" runat="server" PropertyName="Priority" 
                                        Caption="Priority" meta:resourcekey="listPriorityResource1"></ui:UIFieldListBox>
                                    <ui:UIFieldDropDownList ID="dropTaskType" runat="server" PropertyName="ObjectTypeName"
                                        Caption="Task Type" OnSelectedIndexChanged="dropTaskType_ControlChange"
                                        SearchType="Like" meta:resourcekey="dropTaskTypeResource1">
                                    </ui:UIFieldDropDownList>
                                
                                    <ui:UIFieldListBox ID="listStatus" runat="server" PropertyName="ObjectName" 
                                        Caption="Status" meta:resourcekey="listStatusResource1"></ui:UIFieldListBox>
                                    <ui:UIFieldTextBox ID="textUser" runat="server" PropertyName="Users.ObjectName" 
                                        Caption="Assigned to Users" InternalControlWidth="95%" 
                                        meta:resourcekey="textUserResource1"></ui:UIFieldTextBox>
                                    <ui:UIFieldListBox ID="listPosition" runat="server" PropertyName="Positions.ObjectID"
                                        Caption="Assigned to Positions" meta:resourcekey="listPositionResource1"></ui:UIFieldListBox>
                                </td>
                            </tr>
                        </table>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                        <%--<ui:UIButton ID="buttonReassign" runat="server" Text="re-assign Tasks" ImageUrl="~/images/add.gif"
                            OnClick="btnReassign_Clicked" meta:resourcekey="buttonReassignResource1" />--%>
                        <ui:UIGridView ID="gridResults" runat="server" BorderColor="Black" KeyName="ObjectID"
                            meta:resourcekey="gridResultsResource1" Width="100%" 
                            OnRowDataBound="gridResults_RowDataBound" DataKeyNames="ObjectID" 
                            GridLines="Both" ImageRowErrorUrl="" RowErrorColor="" style="clear:both;" OnAction="gridResults_Action">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="true" CommandText="Re-Assgin" ImageUrl="~/images/add.gif" CommandName="ReAssign" CausesValidation="false" />
                            </Commands>
                            <Columns>
                                <cc1:UIGridViewBoundColumn DataField="ObjectTypeName" HeaderText="Task Type" 
                                    meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="ObjectTypeName" 
                                    ResourceAssemblyName="" ResourceName="Resources.Objects" 
                                    SortExpression="ObjectTypeName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TaskNumber" HeaderText="Task Number" 
                                    meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="TaskNumber" 
                                    ResourceAssemblyName="" SortExpression="TaskNumber">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Description" HeaderText="Description" 
                                    meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="Description" 
                                    ResourceAssemblyName="" SortExpression="Description">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TaskAmount" HeaderText="Amount" 
                                    meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="TaskAmount" 
                                    ResourceAssemblyName="" SortExpression="TaskAmount">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Status" 
                                    meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="ObjectName" 
                                    ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" 
                                    SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Priority" HeaderText="Priority" 
                                    meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="Priority" 
                                    ResourceAssemblyName="" SortExpression="Priority">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="AssignedUserText" HeaderText="Assigned Users" 
                                    meta:resourcekey="UIGridViewBoundColumnResource7" PropertyName="AssignedUserText" 
                                    ResourceAssemblyName="" SortExpression="AssignedUserText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="AssignedUserPositionsWithUserNamesText" 
                                    HeaderText="Assigned Positions" 
                                    meta:resourcekey="UIGridViewBoundColumnResource8" PropertyName="AssignedUserPositionsWithUserNamesText" 
                                    ResourceAssemblyName="" SortExpression="AssignedUserPositionsWithUserNamesText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <asp:LinkButton runat="server" ID="buttonAddContactHidden" />
                        <asp:ModalPopupExtender runat='server' ID="popupAddContact" PopupControlID="objectPanelReassign"
                            BackgroundCssClass="modalBackground" TargetControlID="buttonAddContactHidden">
                        </asp:ModalPopupExtender>
                        <ui:UIObjectPanel runat="server" ID="objectPanelReassign" Width="800px" BackColor="White" CssClass="dialog" >
                        <div style="padding: 8px 8px 8px 8px; height: 500px; overflow: scroll">
                            <ui:UIGridView ID="gridTasks" runat="server" Caption="Task Assignment" 
                                BindObjectsToRows="True" OnRowDataBound="gridTasks_RowDataBound" 
                                DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" 
                                meta:resourcekey="gridTasksResource1" RowErrorColor="" style="clear:both;">
                                <PagerSettings Mode="NumericFirstLast" />
                                <Columns>
                                    <cc1:UIGridViewBoundColumn DataField="ObjectTypeName" HeaderText="Task Type" 
                                        meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="ObjectTypeName" 
                                        ResourceAssemblyName="" ResourceName="Resources.Objects" 
                                        SortExpression="ObjectTypeName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="TaskNumber" HeaderText="Task Number" 
                                        meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="TaskNumber" 
                                        ResourceAssemblyName="" SortExpression="TaskNumber">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="Description" HeaderText="Description" 
                                        meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="Description" 
                                        ResourceAssemblyName="" SortExpression="Description">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="TaskAmount" HeaderText="Amount" 
                                        meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="TaskAmount" 
                                        ResourceAssemblyName="" SortExpression="TaskAmount">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Status" 
                                        meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="ObjectName" 
                                        ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" 
                                        SortExpression="ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="Priority" HeaderText="Priority" 
                                        meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="Priority" 
                                        ResourceAssemblyName="" SortExpression="Priority">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="AssignedUserText" 
                                        HeaderText="Currently Assigned Users" 
                                        meta:resourcekey="UIGridViewBoundColumnResource7" PropertyName="AssignedUserText" 
                                        ResourceAssemblyName="" SortExpression="">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="AssignedUserPositionsWithUserNamesText" 
                                        HeaderText="Currently Assigned Positions" 
                                        meta:resourcekey="UIGridViewBoundColumnResource8" PropertyName="AssignedUserPositionsWithUserNamesText" 
                                        ResourceAssemblyName="" SortExpression="">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                </Columns>
                            </ui:UIGridView>
                            <ui:uiseparator runat="server" id="sep1" Caption="New Assignments" 
                                    meta:resourcekey="sep1Resource1" />
                            <table border="0" width="100%">
                            <tr>
                                <td width="50%"><ui:UIFieldTextBox ID="textSearch" runat="server" Caption="Search" 
                                        InternalControlWidth="95%" meta:resourcekey="textSearchResource1" /></td>
                                <td width="50%"></td>
                            </tr>
                            <tr>
                                <td>
                                    <table style='width:100%'><tr><td style='width:120px'>
                                    </td>
                                    <td>
                                    <ui:UIButton ID="buttonSearch" runat="server" Text="Filter Users" 
                                            OnClick="buttonSearch_Click" ImageUrl="~/images/view.gif" 
                                            meta:resourcekey="buttonSearchResource1" />
                                    </td>
                                    </tr></table>
                                    
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <ui:UIFieldListBox ID="listUsers" runat="server" Caption="Users" CaptionPosition="Top"
                                        meta:resourcekey="listUsersResource1" ></ui:UIFieldListBox>
                                </td>
                                <td>
                                    <ui:UIFieldListBox ID="listPositions" runat="server" Caption="Positions" CaptionPosition="Top"
                                        meta:resourcekey="listPositionsResource1" ></ui:UIFieldListBox>
                                </td>
                                
                            </tr>
                            <tr>
                                <td>
                                    <ui:UIFieldListBox ID="listSecretaryPositions" runat="server" Caption="Secretary" CaptionPosition="Top">
                                    </ui:UIFieldListBox>
                                </td>
                            </tr>
                            </table>
                            </div>
                            <table cellpadding='2' cellspacing='0' border='0' style="border-top: solid 1px gray;
                                width: 100%">
                                <tr>
                                    <td class="dialog-buttons">
                                        <ui:UIButton runat='server' ID="buttonConfirm" Text="Add" ImageUrl="~/images/add.gif" Font-Bold="true"
                                            CausesValidation="true"  OnClick="buttonConfirm_Click" />
                                        <ui:UIButton runat='server' ID="buttonCancel" Text="Cancel" ImageUrl="~/images/delete.gif" Font-Bold="true"
                                            CausesValidation='false' OnClick="buttonCancel_Click" />
                                    </td>
                                </tr>
                            </table>
                        
                        </ui:UIObjectPanel>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
