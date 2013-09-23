<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Collections.Generic" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    protected void pagePanel1_Click(object sender, string commandName)
    {
        if (commandName == "CloseWin")
        {
            Session["UserList"] = null;
            Window.Close();
        }
        if (commandName == "AssignTechnician")
        {

            pagePanel1.Message = "";
            gridTechnician.ErrorMessage = "";
            
            List<OWork> workList = Session["WorkList"] as List<OWork>;
            List<OUser> userList = Session["UserList"] as List<OUser>;

            if (userList.Count == 0)
            {
                gridTechnician.ErrorMessage = "Please select at least one technician.";
                pagePanel1.Message = "Please select at least one technician.";
            }
            else
            {
                foreach (OWork work in workList)
                {
                    if (work.CurrentActivity.ObjectName == "PendingAssignment" ||
                        work.CurrentActivity.ObjectName == "PendingExecution" ||
                            work.CurrentActivity.ObjectName == "PendingMaterial" ||
                            work.CurrentActivity.ObjectName == "PendingContractor")
                    {
                        using (Connection c = new Connection())
                        {
                            bool duplicate = false;

                            if (AssignType.SelectedValue == "0")
                            {
                                foreach (OWorkCost workCost in work.WorkCost)
                                {
                                    if (workCost.CostType == WorkCostType.Technician)
                                        workCost.Deactivate();
                                }
                            }

                            foreach (OUser tech in userList)
                            {
                                foreach (OWorkCost workCost in work.WorkCost)
                                {
                                    if (workCost.CostType == WorkCostType.Technician)
                                    {
                                        if (workCost.Technician != null)
                                        {
                                            if (tech.ObjectID == workCost.Technician.ObjectID)
                                                duplicate = true;
                                        }
                                    }
                                }
                                if (!duplicate)
                                    work.AddWorkCost(tech);
                            }

                            if (work.CurrentActivity.ObjectName == "PendingAssignment")
                                work.SaveAndTransit("SubmitForExecution");
                            else
                                work.Save();
                            c.Commit();
                        }
                    }
                }
                Window.Opener.ClickUIButton("buttonItemsAdded");
                Window.Close();
            }
        }
    }

    protected void pagePanel1_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            Session["UserList"] = null;
            ddl_TechnicianID.Bind(OUser.GetUsersByPositions(OPosition.GetPositionsByRoleCode("WORKTECHNICIAN")), "ObjectName", "ObjectID");
            List<OWork> workList = Session["WorkList"] as List<OWork>;
            gridWork.Bind(workList);
        }
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        gridWork.PageSize = 1000;
        gridWork.ErrorMessage = "";
        pagePanel1.Message = gridWork.ErrorMessage;
        }

    protected void gridWork_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        //if (e.Row.RowType == DataControlRowType.DataRow)
        //{
        //    if (e.Row.Cells[6].Text.ToString().Replace("&nbsp;", "") == "" || e.Row.Cells[7].Text.ToString().Replace("&nbsp;", "")=="")
        //    {
        //        e.Row.CssClass = "task-urgentitem";
        //        e.Row.BackColor = System.Drawing.Color.Pink;
        //        gridWork.ErrorMessage = "Some of the flat/model type not found. These records will not be uploaded to the system.";
        //        pagePanel1.Message = gridWork.ErrorMessage;
        //    }

        //}
    }
    protected void ddl_TechnicianID_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddl_TechnicianID.SelectedValue != null && ddl_TechnicianID.SelectedValue!= "")
        {
            OUser user = TablesLogic.tUser.Load(new Guid(ddl_TechnicianID.SelectedValue.ToString()));
            if (user != null)
            {
                List<OUser> userList;
                
                if (Session["UserList"] != null)
                    userList = Session["UserList"] as List<OUser>;
                else
                    userList = new List<OUser>();

                bool duplicate = false;
                int count = userList.Count();
                for (int i = 0; i < count; i++)
                {
                    if (userList[i].ObjectID == user.ObjectID)
                    {
                        duplicate = true;
                        break;
                    }
                }
                if (!duplicate)
                    userList.Add(user);
                Session["UserList"] = userList;
                gridTechnician.Bind(userList);
            }
        }
        ddl_TechnicianID.SelectedValue = null;
    }

    protected void gridTechnician_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "RemoveTechnician")
        {

            OUser user = TablesLogic.tUser.Load(new Guid(dataKeys[0].ToString()));
            List<OUser> userList;
            if (Session["UserList"] != null)
                userList = Session["UserList"] as List<OUser>;
            else
                userList = new List<OUser>();
            
            int count = userList.Count();
            for (int i = 0; i < count; i++)
            {
                if (userList[i].ObjectID == user.ObjectID)
                {
                    userList.RemoveAt(i);
                    break;
                }
            }
            Session["UserList"] = userList;
            gridTechnician.Bind(userList);
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <web:pagepanel id="pagePanel1" runat="server" Caption="Assign Technician"　
             Button1_Caption="Assign Technician" Button1_CommandName="AssignTechnician" Button1_ImageUrl="~/images/Symbol-Check-big.gif"
             Button2_Caption="Close Window" Button2_CommandName="CloseWin" Button2_ImageUrl="~/images/Symbol-Check-big.gif"
             OnClick="pagePanel1_Click" OnLoad="pagePanel1_Load" meta:resourcekey="pagePanelResource1" />
        <div class="div-main">
            <ui:UITabStrip runat="server" id="tabObject" meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="uitabview1" caption="Details" CssClass="div-form" meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                    <br/><br/>
                    <ui:UIFieldRadioList ID="AssignType" runat="server" Caption="Method of Assignment"
                            Width="99%" ValidateRequiredField="True" RepeatColumns="0" meta:resourcekey="AssignTypeResource1" TextAlign="Right">
                            <Items>
                                <asp:listitem value="0" meta:resourcekey="ListItemResource1" Text="Technician list will be cleared and populate with the technicians selected."></asp:listitem>
                                <asp:listitem value="1" meta:resourcekey="ListItemResource2" Text="Technicians selected will be add on to the existing technician list. "></asp:listitem>
                            </Items>
                        </ui:UIFieldRadioList>
                    <ui:UIFieldSearchableDropDownList runat="server" ID="ddl_TechnicianID" Caption="Technician" OnSelectedIndexChanged="ddl_TechnicianID_SelectedIndexChanged" meta:resourcekey="ddl_TechnicianIDResource1">
                        </ui:UIFieldSearchableDropDownList>
                        <ui:UIGridView runat="server" ID="gridTechnician" Caption="Technician" SortExpression="ObjectName"
                            DataKeyNames="ObjectID" GridLines="Both" RowErrorColor=""
                            Style="clear: both;" OnAction="gridTechnician_Action" meta:resourcekey="gridTechnicianResource1" ImageRowErrorUrl="">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveTechnician"
                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource1" >
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn DataField="ObjectName" 
                                    HeaderText="Name"
                                    PropertyName="ObjectName"
                                    ResourceAssemblyName="" SortExpression="ObjectName" meta:resourcekey="UIGridViewBoundColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="panelTechnician"
                        BorderStyle="NotSet" meta:resourcekey="panelTechnicianResource1" >
                        <web:subpanel runat="server" ID="subpanelTechnician" GridViewID="gridTechnician" />
                    </ui:UIObjectPanel>
                    <ui:UIGridView runat="server" ID="gridWork" KeyName="BO" Width="100%" CheckBoxColumnVisible="False" OnRowDataBound="gridWork_RowDataBound" DataKeyNames="ObjectID" GridLines="Both" meta:resourcekey="gridWorkResource1" RowErrorColor="" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <cc1:UIGridViewBoundColumn DataField="ObjectNumber" HeaderText="Work Number" meta:resourceKey="UIGridViewColumnResource4" PropertyName="ObjectNumber" ResourceAssemblyName="" SortExpression="ObjectNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Case.ObjectNumber" HeaderText="Case Number" meta:resourceKey="UIGridViewBoundColumnResource1" PropertyName="Case.ObjectNumber" ResourceAssemblyName="" SortExpression="Case.ObjectNumber">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="WorkDescription" HeaderText="Work Description" meta:resourceKey="UIGridViewColumnResource5" PropertyName="WorkDescription" ResourceAssemblyName="" SortExpression="WorkDescription">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="TypeOfWork.ObjectName" HeaderText="Type of Work" meta:resourceKey="UIGridViewColumnResource6" PropertyName="TypeOfWork.ObjectName" ResourceAssemblyName="" SortExpression="TypeOfWork.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="TypeOfService.ObjectName" HeaderText="Type of Service" meta:resourceKey="UIGridViewColumnResource7" PropertyName="TypeOfService.ObjectName" ResourceAssemblyName="" SortExpression="TypeOfService.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="CurrentActivity.ObjectName" HeaderText="Status" meta:resourceKey="UIGridViewColumnResource8" PropertyName="CurrentActivity.ObjectName" ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" SortExpression="CurrentActivity.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </form>
</body>
</html>