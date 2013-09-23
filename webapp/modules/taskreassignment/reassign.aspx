<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" %>
<%@ Register src="~/components/pagepanel.ascx" tagPrefix="web" tagName="search" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">

    protected void pagePanel1_Load(object sender, EventArgs e)
    {
        DataTable dt = CreateDatatable();
       
        if (Session["TASK"] != null)
        {
            if (!IsPostBack)
            {
                
                List<Object> objectlist = (List<Object>)Session["TASK"];
                List<OActivity> activitylist = OActivity.GetTasks(objectlist);

                listUsers.Bind(OUser.GetAllUsers(), "ObjectName", "ObjectID");
                listPositions.Bind(OPosition.GetAllPositions(), "ObjectName", "ObjectID");

                ((UIGridViewBoundColumn)gridTasks.Columns[3]).DataFormatString =
                    OApplicationSetting.Current.BaseCurrency.CurrencySymbol + "{0:n}";
                                
                gridTasks_DataBind(dt, activitylist);


            }                       
        }       
    }

    protected DataTable CreateDatatable()
    {
        DataTable  dt = new DataTable();
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

    protected void gridTasks_DataBind(DataTable dt,List<OActivity> activities)
    {
        foreach (OActivity activity in activities)
        {
            string strPos = "";
            string strUser = "";
            DataRow row = dt.NewRow();
            row["Task Number"] = activity.TaskNumber;
            row["Description"] = activity.Description;
            row["Task Type"] = activity.ObjectTypeName;
            row["Status"] = activity.ObjectName;
            row["Priority"] = activity.Priority;
            row["TaskAmount"] = activity.TaskAmount;
            row["ObjectID"] = activity.ObjectID;
            foreach (OPosition position in activity.Positions)
                strPos = strPos == "" ? strPos + position.ObjectName : strPos + ", " + position.ObjectName;
            foreach (OUser user in activity.Users)
                strUser = strUser == "" ? strUser + user.ObjectName : strUser + ", " + user.ObjectName;
    
            row["Users"] = strUser;
            row["Positions"] = strPos;
            
            dt.Rows.Add(row);
        }
        gridTasks.DataSource = dt;
        gridTasks.DataBind();       
    }    
    
 
    protected void pagePanel1_Click(object sender, string commandName)
    {
        bool isSaved = false;
        if (commandName == "Save")
        {
            List<object> Ids = gridTasks.GetSelectedKeys();
            if (Ids.Count == 0)
            {
                this.pagePanel1.Message = Resources.Messages.General_NoTaskSelected;   
                //this.pagePanel1.Message = "Please select at least one task before proceed";                
                return;
            }
            else
            {
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
                
                foreach (object obj in Ids)
                {
                    if (listOfPositions.Count > 0 || listOfUsers.Count > 0)
                    {
                        OActivity act = TablesLogic.tActivity.Load(new Guid(obj.ToString()));
                        isSaved = OActivity.SaveTaskReassignment(act,
                            listOfUsers, listOfPositions, null);
                        if (isSaved)
                            this.pagePanel1.Message = Resources.Messages.General_ItemSaved;
                    }
                    else
                    {
                        this.pagePanel1.Message = Resources.Messages.General_NoItemSelected;
                    }
                }


                DataTable dt = CreateDatatable();
                List<Object> objectlist = (List<Object>)Session["TASK"];
                List<OActivity> activitylist = OActivity.GetTasks(objectlist);
                gridTasks_DataBind(dt, activitylist);
            }
        }
    }


    protected void buttonSearch_Click(object sender, EventArgs e)
    {
        List<OUser> list = TablesLogic.tUser.LoadList(TablesLogic.tUser.ObjectName.Like("%" + textSearch.Text + "%"));
        listUsers.Bind(list);
    }

    
    protected void gridTasks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header)
        {
            (e.Row.Cells[0].Controls[0] as CheckBox).Checked = true;
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <web:pagepanel id="pagePanel1" runat="server" Caption="Task-reassign" meta:resourcekey="pagePanelResource1" Button1_Caption="Reassign" Button1_CommandName="Save" Button1_ConfirmText="Are you sure you wish to reassign the select tasks to the selected users/positions?\n\nAll existing assignments will be overwritten!" BUtton1_ImageUrl="~/images/check-big.png" OnLoad="pagePanel1_Load" OnClick="pagePanel1_Click" />
        <div class="div-main">
            <ui:UITabStrip runat="server" id="tabObject" Width="100%" 
                meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="uitabview1" caption="Details" Width="100%"  
                    meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                <table border="0" width="100%">
                <tr>
                <td>
                    <ui:UIGridView ID="gridTasks" runat="server" Caption="Task Assignment" 
                        BindObjectsToRows="True" OnRowDataBound="gridTasks_RowDataBound" 
                        DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" 
                        meta:resourcekey="gridTasksResource1" RowErrorColor="" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <cc1:UIGridViewBoundColumn DataField="Task Type" HeaderText="Task Type" 
                                meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="Task Type" 
                                ResourceAssemblyName="" ResourceName="Resources.Objects" 
                                SortExpression="Task Type">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Task Number" HeaderText="Task Number" 
                                meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="Task Number" 
                                ResourceAssemblyName="" SortExpression="Task Number">
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
                            <cc1:UIGridViewBoundColumn DataField="Status" HeaderText="Status" 
                                meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="Status" 
                                ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" 
                                SortExpression="Status">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Priority" HeaderText="Priority" 
                                meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="Priority" 
                                ResourceAssemblyName="" SortExpression="Priority">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Users" 
                                HeaderText="Currently Assigned Users" 
                                meta:resourcekey="UIGridViewBoundColumnResource7" PropertyName="Users" 
                                ResourceAssemblyName="" SortExpression="Users">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Positions" 
                                HeaderText="Currently Assigned Positions" 
                                meta:resourcekey="UIGridViewBoundColumnResource8" PropertyName="Positions" 
                                ResourceAssemblyName="" SortExpression="Positions">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    </td>
                </tr>
                </table>
                
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
                        <ui:UIFieldListBox ID="listUsers" runat="server" Caption="Users" 
                            meta:resourcekey="listUsersResource1" ></ui:UIFieldListBox>
                    </td>
                    <td>
                        <ui:UIFieldListBox ID="listPositions" runat="server" Caption="Positions" 
                            meta:resourcekey="listPositionsResource1" ></ui:UIFieldListBox>
                    </td>
                </tr>
                </table>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </form>
</body>
</html>

