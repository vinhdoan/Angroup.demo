﻿<%@ Control Language="C#" ClassName="menu2" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.ComponentModel" %>
<%@ Import Namespace="Anacle.UIFramework" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">
    protected override void OnLoad( EventArgs e )
    {
        base.OnLoad( e );

        if (!IsPostBack)
        {
            if (OApplicationSetting.Current.HomePageUrl != null && OApplicationSetting.Current.HomePageUrl != "")
                mainMenu.Items[0].NavigateUrl = OApplicationSetting.Current.HomePageUrl;

            using (Connection c = new Connection())
            {
                // set the user name
                //
                labelName.Text = AppSession.User.ObjectName;

                // Insert the home / analysis menu items
                //
                mainMenu.Items[1].Selectable = false;

                // set up the link URL
                //
                OFunction userFunction = OFunction.GetFunctionByObjectType("OUser");

                linkEditProfile.NavigateUrl =
                    ResolveUrl(userFunction.EditUrl) +
                    (userFunction.EditUrl.Contains("?") ? "&" : "?") +
                    "ID=" + HttpUtility.UrlEncode(Security.Encrypt("EDIT:" + AppSession.User.ObjectID.ToString())) +
                    "&TYPE=" + HttpUtility.UrlEncode(Security.Encrypt("OUser")) +
                    "&MODE=" + HttpUtility.UrlEncode(Security.Encrypt("EDITPROFILE"));

                // load menu items from the objects.xml file
                //
                List<MenuItem> parentMenuSession = new List<MenuItem>();
                Dictionary<string, MenuItem> parentMenu = new Dictionary<string, MenuItem>();

                //foreach (OFunction function in OFunction.GetFunctionsAccessibleByUser(AppSession.User))
                foreach (DataRow dr in OFunction.GetMenusAccessibleByUser(AppSession.User).Rows)
                {
                    MenuItem parentMenuItem = null;
                    MenuItem subMenuItem = null;

                    // now we add this into the menu
                    //
                    if (parentMenu.ContainsKey(dr["CategoryName"].ToString()))
                    {
                        parentMenuItem = parentMenu[dr["CategoryName"].ToString()];
                    }
                    else
                    {
                        parentMenuItem = new MenuItem("<div>" + TranslateMenuItem(dr["CategoryName"].ToString()) + "</div>");
                        parentMenuItem.Selectable = false;
                        parentMenu[dr["CategoryName"].ToString()] = parentMenuItem;
                        mainMenu.Items.Add(parentMenuItem);

                        parentMenuSession.Add(parentMenuItem);
                    }

                    // we add a new sub menu if present
                    //
                    if (dr["SubCategoryName"].ToString() != "")
                    {
                        if (parentMenu.ContainsKey(dr["CategoryName"].ToString() + ":::" + dr["SubCategoryName"].ToString()))
                        {
                            subMenuItem = parentMenu[dr["CategoryName"].ToString() + ":::" + dr["SubCategoryName"].ToString()];
                        }
                        else
                        {
                            subMenuItem = new MenuItem(
                                "<div style=\"background-image:url('images/submenu.gif'); background-position: right center; background-repeat: no-repeat\" >" + TranslateMenuItem(dr["SubCategoryName"].ToString()) + "&nbsp; &nbsp; </div>", "", "", "");
                            subMenuItem.Selectable = false;
                            parentMenu[dr["CategoryName"].ToString() + ":::" + dr["SubCategoryName"].ToString()] = subMenuItem;
                            parentMenuItem.ChildItems.Add(subMenuItem);
                            parentMenuSession.Add(subMenuItem);
                        }
                    }

                    MenuItem childMenuItem = new MenuItem(
                        "<div>" + TranslateMenuItem(dr["FunctionName"].ToString()) + "</div>", "", "",
                        dr["MainUrl"].ToString() +
                        (dr["MainUrl"].ToString().Contains("?") ? "&" : "?") +
                        "TYPE=" +
                        HttpUtility.UrlEncode(Security.Encrypt(dr["ObjectTypeName"].ToString())), "frameBottom");

                    if (subMenuItem != null)
                        subMenuItem.ChildItems.Add(childMenuItem);
                    else
                        parentMenuItem.ChildItems.Add(childMenuItem);
                }



                // load the reports from the database.
                //
                DataTable reports = OReport.GetAllReportsByUserAndCategoryName(AppSession.User);

                // figure out which category names we should show
                //
                ArrayList categoryNames = new ArrayList();
                foreach (DataRow dr in reports.Rows)
                {
                    if (!categoryNames.Contains(dr["CategoryName"].ToString()))
                        categoryNames.Add(dr["CategoryName"].ToString());
                }
                categoryNames.Sort();

                foreach (string categoryName in categoryNames)
                {
                    MenuItem subMenu = new MenuItem(
                        "<div style=\"background-image:url('images/submenu.gif'); background-position: right center; background-repeat: no-repeat\">" + TranslateReportItem(categoryName) + "</div>");
                    subMenu.Selectable = false;
                    mainMenu.Items[1].ChildItems.Add(subMenu);

                    foreach (DataRow report in reports.Rows)
                    {
                        if (report["CategoryName"].ToString() == categoryName)
                        {
                            MenuItem reportMenu = new MenuItem(
                                "<div>" + TranslateReportItem(report["ReportName"].ToString()) + "</div>", "", "",
                                "../modules/reportviewer/search.aspx?ID=" +
                                HttpUtility.UrlEncode(Security.EncryptGuid((Guid)report["ObjectID"])),
                                "frameBottom");
                            subMenu.ChildItems.Add(reportMenu);
                        }
                    }
                }
            }
            
            // Construct the URL link to another instance.
            //
            string otherSystemLink = ConfigurationManager.AppSettings["OtherSystemLink"];
            string otherApplicablePositions = ConfigurationManager.AppSettings["OtherSystemApplicablePositions"];
            if (otherSystemLink != null && otherApplicablePositions != null)
            {
                string[] links = otherSystemLink.Split(',');
                string[] positions = otherApplicablePositions.Split(',');

                bool applicable = false;
                foreach(string position in positions)
                    foreach(OPosition p in AppSession.User.Positions)
                        if (p.ObjectName.Contains(position))
                        {
                            applicable = true;
                            break;
                        }

                if (applicable)
                {
                    labelLinkToAnotherSystem.Visible = true;
                    labelLinkToAnotherSystem.Text = "";
                    for (int i = 0; i < links.Length; i = i + 2)
                    {
                        if (i + 1 >= links.Length)
                            break;
                        if (links[i + 1] == "")
                            labelLinkToAnotherSystem.Text += links[i] + " &nbsp; ";
                        else
                            labelLinkToAnotherSystem.Text += "<a href='" + links[i + 1] + "'>" + links[i] + "</a> &nbsp; ";
                    }
                }
                else
                    labelLinkToAnotherSystem.Visible = false;
            }

        }

        if (Request.UserAgent != null && Request.UserAgent.IndexOf("AppleWebKit") > 0)
        {
            Request.Browser.Adapters.Clear();
        }
    }

    
    /// <summary>
    /// Translates the specified text from the objects.resx file.
    /// </summary>
    /// <param name="text"></param>
    /// <returns></returns>
    protected string TranslateMenuItem(string text)
    {
        string translatedText = Resources.Objects.ResourceManager.GetString(text);
        if (translatedText == null || translatedText == "")
            return text;
        return translatedText;
    }
    
    
    /// <summary>
    /// Translates the specified text from the reports.resx file.
    /// </summary>
    /// <param name="text"></param>
    /// <returns></returns>
    protected string TranslateReportItem(string text)
    {
        string translatedText = Resources.Reports.ResourceManager.GetString(text);
        if (translatedText == null || translatedText == "")
            return text;
        return translatedText;
    }


    protected void linkLogout_Click(object sender, EventArgs e)
    {
        if (Session["SessionId"] != null)
        {
            try
            {
                Security.Logoff((Guid)Session["SessionId"]);
            }
            catch
            {
                // Since the user is logging off from the system
                // we should worry about the log off method
                // throwing exceptions due to SQL failures.
                //
                // So we just ignore, and proceed to clear the
                // session and direct the user back to the
                // log in page.
            }
        }
        Session.Clear();

        // 2010.09.27
        // Kim Foong
        // If we are logging on with Windows, then when the user clicks on
        // the log out button, instead of redirecting him/her back to the
        // log in page (which will cause him/her to auto login again), 
        // we simply just close the window.
        //
        if (ConfigurationManager.AppSettings["AuthenticateWithWindowsLogon"].ToLower() == "true")
            Window.Close();
        else
            Response.Redirect("applogin.aspx");
    }


    protected override void Render(HtmlTextWriter writer)
    {
        StringWriter sw2 = new StringWriter();
        HtmlTextWriter hw2 = new HtmlTextWriter((TextWriter)sw2);
        base.Render(hw2);

        string renderedOutput = hw2.InnerWriter.ToString();

        // Do some sneaky replace to hide the <a href="#menu_mainMenu_SkipLink">
        // in the main menu. This is needed for the rendering in Firefox to
        // look correct.
        //
        writer.Write(renderedOutput.Replace("<a href=\"#menu_mainMenu_SkipLink\">", "<a href=\"#menu_mainMenu_SkipLink\" style='display:none'>"));
    }
</script>

<div align='center'>
<table cellpadding="0" cellspacing="0" border="0" style="width:960px; height: 105px; background-image:url(images/headerbg_new.jpg); background-repeat:no-repeat; background-position: center top;" class="menu" runat="server" >
    <tr style='height: 80px'>
        <td></td>
    </tr>
    <tr style='height:: 25px; width: 250px' align="left" valign='top' >
        <td style='color: Black; padding: 10px 0px 0px 0px'>
            您好，
            <asp:Label ID="labelName" runat="server" Font-Names="Tahoma" Font-Size="8pt" meta:resourcekey="labelNameResource1"></asp:Label>
            &nbsp;
            <asp:Image ID="imageEditProfile" runat="server" ImageUrl="../images/user_edit.gif" ImageAlign="AbsMiddle" meta:resourcekey="imageEditProfileResource1" />
            &nbsp;
            <asp:HyperLink runat="server" id="linkEditProfile" Text="Edit Profile" Target="AnacleEAM_Window" meta:resourcekey="linkEditProfileResource1" ></asp:HyperLink>
            <asp:Image ID="imageLogout" runat="server" ImageUrl="../images/logout.gif" ImageAlign="AbsMiddle" meta:resourcekey="imageLogoutResource1" Visible="false" />
            <asp:label runat='server' ID='labelLinkToAnotherSystem' ForeColor="Yellow" Font-Size="10pt" Visible="false"></asp:label>
        </td>
        <td align="left" style='width:630px; height:20px; color: Blue' valign='top'>
            <asp:Menu ID="mainMenu" runat="server" Orientation="Horizontal" 
                meta:resourcekey="mainMenuResource1" CssSelectorClass="menu" 
                StaticEnableDefaultPopOutImage="False" DynamicEnableDefaultPopOutImage="False" >
                <StaticMenuItemStyle CssClass="menu-staticitem" ForeColor="DarkBlue" />
                <Items>
                    <asp:MenuItem Text="<div>Home</div>" NavigateUrl="~/home.aspx" 
                        Target="frameBottom" meta:resourcekey="MenuItemResource3"></asp:MenuItem>
                    <asp:MenuItem Text="<div>Analysis</div>" meta:resourcekey="MenuItemResource4"></asp:MenuItem>
                </Items>
                <DynamicMenuStyle CssClass="menu-dropdown" ForeColor="DarkBlue" />
                <DynamicMenuItemStyle CssClass="menu-dynamicitem" />
            </asp:Menu>
        </td>
        <td style='width: 80px' align="left" valign="center">
            <asp:LinkButton ID="linkLogout" runat="server" Text="Logout" OnClick="linkLogout_Click" meta:resourcekey="linkLogoutResource1"></asp:LinkButton>
        </td>
    </tr>
</table>
</div>