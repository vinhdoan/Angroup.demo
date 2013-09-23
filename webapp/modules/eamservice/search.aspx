<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.ServiceProcess" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    
    /// <summary>
    /// Display existing EAM windows service.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panelMain_Load(object sender, EventArgs e)
    {
        BindServices(ServiceView.ViewWindowsService());
    }

    /// <summary>
    /// Bind services to the WindowsServices gridview.
    /// </summary>
    /// <param name="services"></param>
    private void BindServices(DataTable services)
    {
        this.WindowsService.DataSource = services;
        this.WindowsService.DataBind();
    }

    /// <summary>
    /// Check if logon user is System administrator.
    /// </summary>
    public static ImpersonateUser AuthorizedUser = null;
    private bool CheckAccessRight(ImpersonateUser user)
    {
        bool check = false;
        if (ServiceView.IsAuthorizedUser(AuthorizedUser) == false)
            labelMessage.Text = Resources.Errors.EAMservice_LogonFailure;
        else
            check = true;
        return check;
    }

    /// <summary>
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void WindowsService_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        ServiceView view = new ServiceView();
        TimeSpan timeout = new TimeSpan(0, 0, 30); //30 seconds
        int index = Convert.ToInt32(e.CommandArgument);
        GridViewRow row = WindowsService.Rows[index];
        string serviceName = row.Cells[0].Text;

        if (AuthorizedUser != null)
        {
            if (e.CommandName == "Start")
            {
                try
                {
                    view.StartService(serviceName, timeout, AuthorizedUser);
                }
                catch { }
            }
            if (e.CommandName == "Stop")
            {
                try
                {
                    view.StopService(serviceName, timeout, AuthorizedUser);
                }
                catch { }
            }
            AuthorizedUser = null;
            BindServices(ServiceView.ViewWindowsService());
        }
    }

    /// <summary>
    /// Check if user has been logon as priviledge user.
    /// if YES: show Start/Stop button.
    /// if NO: hide Start/Stop button
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void WindowsService_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[2].Visible = AuthorizedUser == null ? false : true;
            e.Row.Cells[3].Visible = AuthorizedUser == null ? false : true;
            e.Row.Cells[1].ForeColor = e.Row.Cells[1].Text == Resources.Strings.EAMservice_Running ? System.Drawing.Color.Blue : System.Drawing.Color.Green;         
        }
        if (e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[2].Visible = AuthorizedUser == null ? false : true;
            e.Row.Cells[3].Visible = AuthorizedUser == null ? false : true;
        }
    }

    
    /// <summary>
    /// To start/stop Anacle.EAM services, user needs to log on as priviledge user such as system administrator
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void LogOn_Click(object sender, EventArgs e)
    {
        // logon type = 2: Interactive. This parameter causes LogonUser to create a primary token
        // that allows creating processes while impersonating.
        int logonType = 2;
        AuthorizedUser = new ImpersonateUser();
        AuthorizedUser.username = this.UserName.Text;
        AuthorizedUser.password = this.Password.Text;
        AuthorizedUser.domain = this.Domain.Text;
        AuthorizedUser.logontype = logonType;

        if (CheckAccessRight(AuthorizedUser))
            BindServices(ServiceView.ViewWindowsService());
        else
            AuthorizedUser = null;
        this.UserName.Text = "";
        this.Domain.Text = "";
    }

    /// <summary>
    /// Retrieve current statuses of Anacle.EAM services and bind them to grid view.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Refresh_Click(object sender, EventArgs e)
    {
        try
        {
            BindServices(ServiceView.ViewWindowsService());
        }
        catch (Exception ex)
        {
            this.labelMessage.Text = Resources.Errors.EAMservice_ViewError + ex.Message;
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
    <ui:UIObjectPanel runat="server" ID="panelMain" OnLoad="panelMain_Load" 
        BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <asp:Panel ID="panelMessage" runat="server" 
            meta:resourcekey="panelMessageResource1">
            <div style="width: 100%">
                <asp:Label ID="labelMessage" runat="server" EnableViewState="False" ForeColor="Red"
                    Font-Bold="False" meta:resourcekey="labelMessageResource1" />
            </div>
        </asp:Panel>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" 
                meta:resourcekey="tabSearchResource1">
                <ui:UITabView runat="server" ID="uitabview2" Caption="Services" CssClass="div-form"
                    meta:resourcekey="uitabview1Resource2" 
                    BorderStyle="NotSet">
                    <table>
                        <tr>
                            <td>
                                <asp:Label ID="Label1" runat="server" Text="Log on to Start/Stop Services" Font-Bold="True"
                                    ForeColor="Blue" meta:resourcekey="Label1Resource1"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <ui:UIFieldTextBox ID="UserName" runat="server" Caption="User Name" Width="200px"
                                    CaptionWidth="80px" InternalControlWidth="95%" 
                                    meta:resourcekey="UserNameResource1" />
                            </td>
                            <td>
                                <ui:UIFieldTextBox ID="Password" runat="server" Caption="Password" Width="200px"
                                    TextMode="Password" CaptionWidth="80px" InternalControlWidth="95%" 
                                    meta:resourcekey="PasswordResource1" />
                            </td>
                            <td>
                                <ui:UIFieldTextBox ID="Domain" runat="server" Caption="Domain" Width="200px" 
                                    CaptionWidth="80px" InternalControlWidth="95%" 
                                    meta:resourcekey="DomainResource1" />
                            </td>
                            <td>
                                <asp:Button CommandName="Logon" Text="Log on" runat="server" ID="LogOn" 
                                    OnClick="LogOn_Click" meta:resourcekey="LogOnResource1" />
                            </td>
                        </tr>
                    </table>
                    <ui:UISeparator ID="UISeparator1" runat="server" Caption="Anacle Services" 
                        meta:resourcekey="UISeparator1Resource1" />
                    <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:GridView ID="WindowsService" runat="server" AutoGenerateColumns="False" OnRowCommand="WindowsService_RowCommand"
                                OnRowDataBound="WindowsService_RowDataBound" 
                                meta:resourcekey="WindowsServiceResource1">
                                <Columns>
                                    <asp:BoundField HeaderText="Service Display Name" 
                                        DataField="Service Display Name" meta:resourcekey="BoundFieldResource1" >
                                        <ItemStyle Width="300px" />
                                    </asp:BoundField>
                                    <asp:BoundField HeaderText="Status" DataField="Service Status" 
                                        meta:resourcekey="BoundFieldResource2" >
                                        <ItemStyle Width="100px" />
                                    </asp:BoundField>
                                    <asp:ButtonField ButtonType="Image" ImageUrl="~/images/stop.jpg" CommandName="Stop"
                                        Text="Stop service" HeaderText="Action" 
                                        meta:resourcekey="ButtonFieldResource1" />
                                    <asp:ButtonField ButtonType="Image" ImageUrl="~/images/play.jpg" CommandName="Start"
                                        Text="Start service" HeaderText="Action" 
                                        meta:resourcekey="ButtonFieldResource2" />
                                </Columns>
                            </asp:GridView>
                            <asp:Button ID="Refresh" runat="server" OnClick="Refresh_Click" Text="Refresh" 
                                meta:resourcekey="RefreshResource1" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
