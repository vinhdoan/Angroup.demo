<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/webpartDashboard.ascx" TagPrefix="web" TagName="webpartDashboard" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        webpartManager.DisplayMode = WebPartManager.DesignDisplayMode;
        if (Request["Print"] != null)
        {
            //for printing purpose
            this.MainTab.Visible = false;
            this.buttonAddDashboards.Visible = false;
            this.buttonPrintPreview.Text = Resources.Strings.Dashboard_Print;
            this.buttonPrintPreview.ImageUrl = "~/images/printer.gif";
            this.buttonBack.Visible = true;
            this.buttonHidden.Visible = false;
            this.panelAddDashboard.Visible = false;
        }
        else
        {
            this.buttonPrintPreview.Text = Resources.Strings.Dashboard_Preview;
            this.buttonPrintPreview.ImageUrl = "~/images/preview.gif";
            this.buttonBack.Visible = false;
        }

        if (!IsPostBack)
        {
            System.Globalization.CultureInfo ci = System.Threading.Thread.CurrentThread.CurrentUICulture;
            if (ci.TextInfo.IsRightToLeft)
            {
                linkToday.Style["float"] = "right";
                linkMonthView.Style["float"] = "right";
                linkDashboard.Style["float"] = "right";
            }
        }
    }


    protected void BindDashboardWebParts()
    {
        List<ODashboard> dashboards = ODashboard.GetDashboardByUserRoles(AppSession.User);
        checkboxlistDashboards.Bind(dashboards, "ObjectName", "ObjectID");

        foreach (ListItem item in checkboxlistDashboards.Items)
        {
            string text = item.Text;
            string translatedText = Resources.Dashboards.ResourceManager.GetString(text);
            if (translatedText != null && translatedText != "")
                item.Text = translatedText;
        }
    }


    //-------------------------------------------------------------------
    // event
    //-------------------------------------------------------------------
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
    }


    /// <summary>
    /// Pops up a dialog box to allow users to add selected dashboards.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddDashboards_Click(object sender, EventArgs e)
    {
        BindDashboardWebParts();

        modalAddDashboard.Show();
        panelAddDashboard.Visible = true;
        panelError.Visible = false;
        panelAddDashboard.ClearErrorMessages();
    }


    /// <summary>
    /// Adds the selected dashboards.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddSelectedDashboards_Click(object sender, EventArgs e)
    {
        if (!panelAddDashboard.IsValid)
        {
            modalAddDashboard.Show();
            panelAddDashboard.Visible = true;
            panelError.Visible = true;
            return;
        }

        modalAddDashboard.Hide();
        panelAddDashboard.Visible = false;

        WebPartZone zoneToAddDashboard = null;
        if (dropWebPartZones.SelectedIndex == 0)
            zoneToAddDashboard = webpartZone1;
        if (dropWebPartZones.SelectedIndex == 1)
            zoneToAddDashboard = webpartZone2;
        if (dropWebPartZones.SelectedIndex == 2)
            zoneToAddDashboard = webpartZone3;
        
        foreach (ListItem item in checkboxlistDashboards.Items)
        {
            if (item.Selected)
            {
                Guid dashboardId = new Guid(item.Value);
                ODashboard dashboard = TablesLogic.tDashboard.Load(dashboardId);

                if (zoneToAddDashboard != null && dashboard != null)
                {
                    webpartDashboard d = new webpartDashboard();
                    d.ID = "db" + dashboardId.ToString().Replace("-", "");
                    WebPart wp = webpartManager.AddWebPart(
                        webpartManager.CreateWebPart(d), zoneToAddDashboard, 0);

                    string title = dashboard.ObjectName;
                    string translatedText = Resources.Dashboards.ResourceManager.GetString(title);
                    if (translatedText != null && translatedText != "")
                        title = translatedText;

                    wp.Title = title;
                    ((webpartDashboard)wp.Controls[0]).DashboardID = dashboardId;
                    ((webpartDashboard)wp.Controls[0]).Refresh();
                }
            }
        }
    }


    /// <summary>
    /// Closes the add dashboards pop-up.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonCancelAddDashboards_Click(object sender, EventArgs e)
    {
        modalAddDashboard.Hide();
        panelAddDashboard.Visible = false;
    }

    /// <summary>
    /// In normal mode: button text = "Preview"
    /// In preview mode: button text = "Print"
    /// Occurs when user clicks on the Preview/Print button:
    /// -- when "Preview" button is clicked: navigates to same page but in preview mode which displays content for printing only (remove tabs, unused button)
    /// -- when "Print" button is clicked: the print dialog would be displayed.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonPrintPreview_Click(object sender, EventArgs e)
    {
        if (Request["Print"] == null)
            Window.Open("homedashboard.aspx?Print=1");
        else
            Window.WriteJavascript("window.print();");
    }

    /// <summary>
    /// Occurs when user clicks on the Back button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonBack_Click(object sender, EventArgs e)
    {
        if (Request["Print"] == null)
            Window.Open("homedashboard.aspx");
        Window.Close();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <link href="App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
    <link href="App_Themes/PrintStyle.css" rel="stylesheet" type="text/css" media="print" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIPanel runat="server" ID="panelMain" BeginningHtml="" BorderStyle="NotSet" EndingHtml=""
        meta:resourcekey="panelMainResource1">
        <div class="div-main">
            <ui:UIPanel runat="server" ID="panelDashboards" BeginningHtml="" BorderStyle="NotSet"
                EndingHtml="" meta:resourcekey="panelDashboardsResource1">
                <asp:WebPartManager runat="server" ID="webpartManager" DeleteWarning="Are you sure you want to hide this dashboard? (You can add it back again by clicking on the 'Add Dashboards' button later)" >
                </asp:WebPartManager>
                <asp:Panel runat="server" ID="MainTab" meta:resourcekey="MainTabResource1">
                    <table id="Table1" class="tabstrip" width="100%" runat="server" border="0" cellpadding="0" cellspacing="0">
                        <tr id="Tr1" runat="server">
                            <td id="Td1" runat="server">
                                <ul>
                                    <li style="display: inline;"><a runat="server" id="linkToday" href="home.aspx"><asp:Label runat="server" ID="labelToday" meta:resourcekey="labelTodayResource1" >Today</asp:Label></a> </li>
                                    <li style="display: inline;"><a runat="server" id="linkMonthView" href="homemonthview.aspx"><asp:Label runat="server" ID="labelMonthView" meta:resourcekey="labelMonthViewResource1" >Month View</asp:Label></a>
                                    </li>
                                    <li class="selected" style="display: inline;"><a runat="server" id="linkDashboard" href="#"><asp:Label runat="server" ID="labelDashboard" meta:resourcekey="labelDashboardResource1" >Dashboard</asp:Label></a>
                                    </li>
                                </ul>
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
                <div class="div-form" id="dvPrintContent">
                    <ui:UIButton runat="server" CssClass="divNoDisplay" ID="buttonAddDashboards" Text="Add Dashboards"
                        ImageUrl="~/images/add.gif" CausesValidation="False" OnClick="buttonAddDashboards_Click"
                        meta:resourcekey="buttonAddDashboardsResource1" />
                        <ui:UIButton runat="server" CssClass="divNoDisplay" ID="buttonBack" Text="Back" Visible="False" CausesValidation="False" OnClick="buttonBack_Click" 
                        meta:resourcekey="buttonBackResource1"/>
                    <ui:UIButton runat="server" CssClass="divNoDisplay" ID="buttonPrintPreview" Text="Preview"
                        ImageUrl="~/images/preview.gif" CausesValidation="False" OnClick="buttonPrintPreview_Click" 
                        meta:resourcekey="buttonPrintPreviewResource1"/>
                    <br />
                    <br />
                    <table cellpadding="0" cellspacing="0" border="0">
                        <tr valign="top">
                            <td class="webpart-zonecontainerleft">
                                <asp:WebPartZone runat="server" ID="webpartZone1" BorderStyle="None" WebPartVerbRenderMode="TitleBar" EmptyZoneText="Click 'Add Dashboards' to add a new dashboard to this zone, or drag a dashboard from another zone to this zone."
                                    Width="310px" HeaderText=" " meta:resourcekey="webpartZone1Resource1">
                                    <CloseVerb Visible="False" />
                                    <DeleteVerb Text="Hide" Description="Hide {0}" />
                                    <MinimizeVerb Visible="False" />
                                    <PartChromeStyle BorderColor="Silver" BorderStyle="Solid" BorderWidth="1px" />
                                    <PartTitleStyle BackColor="#EEEEEE" />
                                </asp:WebPartZone>
                            </td>
                            <td class="webpart-zonecontainer">
                                <asp:WebPartZone runat="server" ID="webpartZone2" BorderStyle="None" WebPartVerbRenderMode="TitleBar" EmptyZoneText="Click 'Add Dashboards' to add a new dashboard to this zone, or drag a dashboard from another zone to this zone."
                                    Width="310px" HeaderText=" " meta:resourcekey="webpartZone2Resource1">
                                    <CloseVerb Visible="False" />
                                    <DeleteVerb Text="Hide" Description="Hide {0}" />
                                    <MinimizeVerb Visible="False" />
                                    <PartChromeStyle BorderColor="Silver" BorderStyle="Solid" BorderWidth="1px" />
                                    <PartTitleStyle BackColor="#EEEEEE" />
                                </asp:WebPartZone>
                            </td>
                            <td class="webpart-zonecontainer">
                                <asp:WebPartZone runat="server" ID="webpartZone3" BorderStyle="None" WebPartVerbRenderMode="TitleBar" EmptyZoneText="Click 'Add Dashboards' to add a new dashboard to this zone, or drag a dashboard from another zone to this zone."
                                    Width="310px" HeaderText=" " meta:resourcekey="webpartZone3Resource1">
                                    <CloseVerb Visible="False" />
                                    <DeleteVerb Text="Hide" Description="Hide {0}" />
                                    <MinimizeVerb Visible="False" />
                                    <PartChromeStyle BorderColor="Silver" BorderStyle="Solid" BorderWidth="1px" />
                                    <PartTitleStyle BackColor="#EEEEEE" />
                                </asp:WebPartZone>
                            </td>
                        </tr>
                    </table>
                </div>
                <div id="divHidden">
                <asp:LinkButton runat="server" ID="buttonHidden" meta:resourcekey="buttonHiddenResource1" />
                <asp:ModalPopupExtender ID="modalAddDashboard" runat="server" TargetControlID="buttonHidden"
                    PopupControlID="panelAddDashboard" BackgroundCssClass="modalBackground" DynamicServicePath=""
                    Enabled="True">
                </asp:ModalPopupExtender>
                <ui:UIObjectPanel runat="server" ID="panelAddDashboard" CssClass="modalPopup" Width="400px"
                    BeginningHtml="" BorderStyle="NotSet" EndingHtml="" meta:resourcekey="panelAddDashboardResource1">
                    <ui:UISeparator runat="server" ID="sep1" Caption="Add Dashboards" meta:resourcekey="sep1Resource1" />
                    <br />
                    <asp:Panel runat="server" ID="panelError" meta:resourcekey="panelErrorResource1">
                        <asp:Label runat="server" ID="labelError" Text="Please select one or more dashboards from the list below.<br/>"
                            ForeColor="Red" Font-Bold="True" meta:resourcekey="labelErrorResource1"></asp:Label>
                        <br />
                    </asp:Panel>
                    <div style="height: 200px; overflow: scroll; border: solid 1px silver">
                        <ui:UIFieldCheckboxList runat="server" ID="checkboxlistDashboards" ShowCaption='False'
                            ValidateRequiredField="True" Caption="Dashboards" meta:resourcekey="checkboxlistDashboardsResource1"
                            TextAlign="Right">
                        </ui:UIFieldCheckboxList>
                    </div>
                    <br />
                    <br />
                    <asp:Label runat="server" ID="labelAddToZone" Text="Add the selected dashboards to: "
                        meta:resourcekey="labelAddToZoneResource1"></asp:Label>
                    <asp:DropDownList runat="server" ID="dropWebPartZones" meta:resourcekey="dropWebPartZonesResource1">
                        <asp:ListItem Text="Zone 1" meta:resourcekey="ListItemResource1"></asp:ListItem>
                        <asp:ListItem Text="Zone 2" meta:resourcekey="ListItemResource2"></asp:ListItem>
                        <asp:ListItem Text="Zone 3" meta:resourcekey="ListItemResource3"></asp:ListItem>
                    </asp:DropDownList>
                    <br />
                    <br />
                    <ui:UISeparator runat="server" ID="UISeparator1" meta:resourcekey="UISeparator1Resource1" />
                    <br />
                    <div align="center">
                        <ui:UIButton runat="server" ID="buttonAddSelectedDashboards" ImageUrl="~/images/tick.gif"
                            OnClick="buttonAddSelectedDashboards_Click" Text="Confirm" meta:resourcekey="buttonAddSelectedDashboardsResource1" />
                        <ui:UIButton runat="server" ID="buttonCancelAddDashboards" ImageUrl="~/images/delete.gif"
                            OnClick="buttonCancelAddDashboards_Click" Text="Cancel" CausesValidation="False"
                            meta:resourcekey="buttonCancelAddDashboardsResource1" />
                    </div>
                </ui:UIObjectPanel>
                </div>
            </ui:UIPanel>
        </div>
    </ui:UIPanel>
    <script src='scripts/boxover.js' type='text/javascript'></script>
    </form>
</body>
</html>
