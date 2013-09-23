<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" %>

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
    /// <summary>
    /// Gets or sets the selected node's value in the At-A-Glance
    /// treeview or the selected date in the Calendar.
    /// </summary>
    protected string SelectedItem
    {
        get { return ViewState["SelectedItem"].ToString(); }
        set { ViewState["SelectedItem"] = value; }
    }


    //-------------------------------------------------------------------
    // event
    //-------------------------------------------------------------------
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            ((UIGridViewBoundColumn)gridTasks.Columns[7]).DataFormatString = "<img src='" + ResolveUrl("~/images/") + "priority{0}.gif' border='0' />";

            SelectedItem = "";
            PopulateCalendar();
            PopulateTime();
            PopulateAnnouncements();

            if (gridAnnouncements.Rows.Count == 0)
                SelectedItem = "%/%";
            PopulateAtAGlance();
            PopulateQuickCreate();
            if (gridAnnouncements.Rows.Count == 0)
                PopulateInbox("");

            System.Globalization.CultureInfo ci = System.Threading.Thread.CurrentThread.CurrentUICulture;
            if (ci.TextInfo.IsRightToLeft)
            {
                linkToday.Style["float"] = "right";
                linkMonthView.Style["float"] = "right";
                linkDashboard.Style["float"] = "right";
            }
            linkClose.Attributes["onclick"] = "document.getElementById('" + tableMessage.ClientID + "').style.visibility = 'hidden'";
        }

        labelMessage.Text = "";
    }


    /// <summary>
    /// Populates the time.
    /// </summary>
    protected void PopulateTime()
    {
        labelDateTime.Text = DateTime.Now.ToString("dd-MMM-yyyy hh:mm tt");
    }


    /// <summary>
    /// Populates the calendar.
    /// </summary>
    protected void PopulateCalendar()
    {
        DateTime calendarDate = calendarTasks.VisibleDate;
        DateTime today = DateTime.Today;
        if (calendarDate == DateTime.MinValue)
            calendarDate = new DateTime(today.Year, today.Month, 1);
        if (calendarDate.DayOfWeek == DayOfWeek.Sunday)
            calendarDate = calendarDate.AddDays(-7);
        else if (calendarDate.DayOfWeek == DayOfWeek.Monday)
            calendarDate = calendarDate.AddDays(-1);
        else if (calendarDate.DayOfWeek == DayOfWeek.Tuesday)
            calendarDate = calendarDate.AddDays(-2);
        else if (calendarDate.DayOfWeek == DayOfWeek.Wednesday)
            calendarDate = calendarDate.AddDays(-3);
        else if (calendarDate.DayOfWeek == DayOfWeek.Thursday)
            calendarDate = calendarDate.AddDays(-4);
        else if (calendarDate.DayOfWeek == DayOfWeek.Friday)
            calendarDate = calendarDate.AddDays(-5);
        else if (calendarDate.DayOfWeek == DayOfWeek.Saturday)
            calendarDate = calendarDate.AddDays(-6);

        ViewState["CalendarTaskCount"] = OActivity.GetCalendarTaskCount(AppSession.User, calendarDate);
    }


    /// <summary>
    /// Populate the announcements.
    /// </summary>
    protected void PopulateAnnouncements()
    {
        DataTable dt = OAnnouncement.GetAnnouncementsTable(AppSession.User, DateTime.Now);
        ViewState["AnnouncementCount"] = dt.Rows.Count;
        gridAnnouncements.DataSource = dt;
        gridAnnouncements.DataBind();
    }


    /// <summary>
    /// Populate all tasks views on the home page by populating
    /// the following controls:
    /// 1. At-a-glance tree
    /// 2. Inbox
    /// 3. Calendar.
    /// </summary>
    protected void PopulateTasks()
    {
        PopulateAtAGlance();
        PopulateInbox("");

    }


    /// <summary>
    /// Selects appropriate node.
    /// </summary>
    /// <param name="node"></param>
    protected void SelectNode(TreeNode node)
    {
        if (node.Value == SelectedItem)
        {
            node.Selected = true;
            TreeNode currentNode = node;
            while (currentNode != null)
            {
                currentNode.Expanded = true;
                currentNode = currentNode.Parent;
            }
            return;
        }

        foreach (TreeNode childNode in node.ChildNodes)
            SelectNode(childNode);
    }


    /// <summary>
    /// Populates the at-a-glance part. This requires that
    /// we retrieve all the tasks assigned to the current user
    /// grouped by their object types and their statuses.
    /// </summary>
    protected void PopulateAtAGlance()
    {
        treeGlance.Nodes.Clear();

        DataTable dt = OActivity.GetOutstandingTasksGroupedByObjectTypeAndStatus(AppSession.User, DateTime.Now);

        // Compute the total number of outstanding items
        //
        int taskCount = 0;
        foreach (DataRow dr in dt.Rows)
            taskCount += (int)dr["Count"];

        // Create the root level Announcements node.
        //
        TreeNode announcementNode = new TreeNode("&nbsp;<b>" + Resources.Strings.Home_Announcements + " (" + ViewState["AnnouncementCount"] + ")&nbsp;</b>", "", "~/images/information.png");
        announcementNode.Expanded = true;
        announcementNode.Value = "";
        treeGlance.Nodes.Add(announcementNode);

        // Create the root level Inbox node
        //
        TreeNode inboxNode = new TreeNode("&nbsp;<b>" + Resources.Strings.Home_Inbox + " (" + taskCount + ")&nbsp;</b>", "%/%", "~/images/email.png");
        inboxNode.Expanded = true;
        inboxNode.Value = "%/%";
        treeGlance.Nodes.Add(inboxNode);

        // Create the object type nodes.
        // 
        Hashtable typeCount = new Hashtable();
        Hashtable h = new Hashtable();
        foreach (DataRow dr in dt.Rows)
        {
            // Add the object type
            //
            TreeNode typeNode = null;
            if (h[dr["ObjectTypeName"]] == null)
            {
                string typeName = Resources.Objects.ResourceManager.GetString(dr["ObjectTypeName"].ToString());
                typeNode = new TreeNode("<b>&nbsp;" + (typeName == null ? dr["ObjectTypeName"].ToString() : typeName) + "&nbsp;</b>", "", "~/images/otype.png");
                typeNode.Expanded = false;
                typeNode.Value = dr["ObjectTypeName"].ToString() + "/%";
                inboxNode.ChildNodes.Add(typeNode);

                h[dr["ObjectTypeName"]] = typeNode;
            }
            else
                typeNode = h[dr["ObjectTypeName"]] as TreeNode;

            // Compute the total count of outstanding tasks per
            // object type.
            //
            int count = 0;
            if (typeCount[dr["ObjectTypeName"]] != null)
                count = (int)typeCount[dr["ObjectTypeName"]];
            count += (int)dr["Count"];
            typeCount[dr["ObjectTypeName"]] = count;

            // Add the object status underneath the type
            //
            string statusName = Resources.WorkflowStates.ResourceManager.GetString(dr["ObjectName"].ToString());
            TreeNode statusNode = new TreeNode("&nbsp;" + (statusName == null ? dr["ObjectName"].ToString() : statusName) +
                " (" + dr["Count"] + ")&nbsp;");
            statusNode.Value = dr["ObjectTypeName"].ToString() + "/" + dr["ObjectName"].ToString();
            statusNode.Expanded = true;
            typeNode.ChildNodes.Add(statusNode);
        }

        // Append the count to the type name
        //
        foreach (object objectTypeName in h.Keys)
        {
            TreeNode typeNode = h[objectTypeName] as TreeNode;
            typeNode.Text += " (" + typeCount[objectTypeName] + ")";
        }

        // Selects the appropriate node.
        //
        foreach (TreeNode node in treeGlance.Nodes)
            SelectNode(node);
    }


    /// <summary>
    /// Creates the quick-create tree.
    /// </summary>
    protected void PopulateQuickCreate()
    {
        StringBuilder sb = new StringBuilder();
        ArrayList categoryNames = new ArrayList();

        DataTable createableFunctions = OFunction.GetFunctionsCreateableByUser(AppSession.User);

        Hashtable h = new Hashtable();
        foreach (DataRow dr in createableFunctions.Rows)
        {
            // add the category names
            //
            if (h[dr["CategoryName"]] == null)
            {
                string categoryName = Resources.Objects.ResourceManager.GetString(dr["CategoryName"].ToString());
                if (categoryName == null)
                    categoryName = dr["CategoryName"].ToString();

                sb.Append("<img align='absmiddle' src='" + ResolveUrl(ConfigurationManager.AppSettings["ImageUrl_TaskFolder"]) + "'> <b>" + categoryName + "</b><br/>");
                h[dr["CategoryName"]] = 1;
            }

            // add the objects
            //
            string url = ResolveUrl(dr["EditUrl"].ToString()) +
                "?ID=" + HttpUtility.UrlEncode(Security.Encrypt("NEW:")) +
                "&TYPE=" + HttpUtility.UrlEncode(Security.Encrypt(dr["ObjectTypeName"].ToString()));

            string functionName = Resources.Objects.ResourceManager.GetString(dr["FunctionName"].ToString());
            if (functionName == null)
                functionName = dr["FunctionName"].ToString();

            sb.Append(
                "<div style='padding-top:2px; padding-bottom:2px'>&nbsp; &nbsp; &nbsp; " +
                "<a href='#' onclick='javascript:window.open(\"" + url + "\", \"AnacleEAM_Window\")'>" + functionName + "</a></div>");
        }

        labelQuickCreate.Text = sb.ToString();
    }

    //-------------------------------------------------------------------
    // event
    //-------------------------------------------------------------------
    protected void PopulateInbox(string searchFilter)
    {
        if (SelectedItem != "" &&
            !SelectedItem.StartsWith("DATE:"))
        {
            // Here we determine which node is selected in the
            // at-a-glance tree. From that we can determine which
            // is the selected object type/status selected.
            // 
            string[] values = SelectedItem.Split('/');

            // Then, we filter the inbox accordingly.
            //
            gridTasks.DataSource = OActivity.GetOutstandingActivitiesForInbox(
                AppSession.User, new DateTime(DateTime.Today.Year, DateTime.Today.Month, DateTime.Today.Day, 23, 59, 59),
                values[0], values[1], "%" + searchFilter + "%");
            gridTasks.DataBind();
        }
    }


    //-------------------------------------------------------------------
    // event
    //-------------------------------------------------------------------
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        Page.ClientScript.RegisterClientScriptBlock(typeof(string), "Refresh",
            "<scr" + "ipt type='text/javascript'>\n" +
            "   function Refresh() { \n" +
            "      " + Page.ClientScript.GetPostBackEventReference(buttonRefresh.LinkButton, "") +
            "   } \n" +
            "</scr" + "ipt>\n");

        panelAnnouncements.Visible = (SelectedItem == "");
        panelTasks.Visible = (SelectedItem != "");
        panelMessage.Visible = labelMessage.Text != "";
    }


    //-------------------------------------------------------------------
    // event
    //-------------------------------------------------------------------
    protected void gridTasks_Action(object sender, string commandName, System.Collections.Generic.List<object> objectIds)
    {
        if (commandName == "EditObject")
        {
            foreach (object id in objectIds)
            {
                if (id is Guid)
                {
                    // pop-up the edit page for this object type
                    //
                    OActivity activity = TablesLogic.tActivity[(Guid)id];
                    Window.OpenEditObjectPage(Page, activity.ObjectTypeName, activity.AttachedObjectID.ToString(), "");
                }
            }
        }

    }


    //-------------------------------------------------------------------
    // event
    //-------------------------------------------------------------------
    protected void gridTasks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (((DataRowView)e.Row.DataItem)["ScheduledEndDateTime"] != DBNull.Value &&
                (DateTime)((DataRowView)e.Row.DataItem)["ScheduledEndDateTime"] < DateTime.Now)
            {
                // Show/hide clock image
                System.Web.UI.WebControls.Image imageClock = e.Row.FindControl("imageClock") as System.Web.UI.WebControls.Image;
                imageClock.Visible = true;
            }
        }

        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[9].Visible = false;
        }
    }


    //-------------------------------------------------------------------
    // event
    //-------------------------------------------------------------------
    protected void buttonRefresh_Click(object sender, EventArgs e)
    {
        SelectedItem = "%/%";
        PopulateTasks();
    }


    /// <summary>
    /// Filters the inbox by the object type/status selected.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeGlance_SelectedNodeChanged(object sender, EventArgs e)
    {
        string value = "/";
        if (treeGlance.SelectedNode != null)
            value = treeGlance.SelectedNode.Value;
        SelectedItem = value;

        if (value != "")
            PopulateTasks();
        else
            PopulateAnnouncements();

        calendarTasks.SelectedDates.Clear();

        textSearch.Text = "";
        PopulateCalendar();
    }



    int dayCount = 0;

    /// <summary>
    /// Renders the calendar.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void calendarTasks_DayRender(object sender, DayRenderEventArgs e)
    {
        DataTable dt = ViewState["CalendarTaskCount"] as DataTable;

        if ((int)dt.Rows[dayCount][0] > 0)
        {
            e.Cell.ForeColor = Color.AntiqueWhite;
            e.Cell.Font.Bold = true;
            e.Day.IsSelectable = true;
        }
        else
        {
            e.Day.IsSelectable = false;
        }

        dayCount++;
    }

    /// <summary>
    /// Occurs when the user selects a date or date range on the calendar.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void calendarTasks_SelectionChanged(object sender, EventArgs e)
    {
        if (calendarTasks.SelectedDates.Count > 0)
        {
            SelectedItem = "DATE:" + calendarTasks.SelectedDate.ToString("yyyy-MM-dd");
            gridTasks.DataSource = OActivity.GetOutstandingTasksAtDate(AppSession.User, calendarTasks.SelectedDate, "%");
            gridTasks.DataBind();
        }
        else
        {
            gridTasks.DataSource = null;
            gridTasks.DataBind();
        }

        if (treeGlance.SelectedNode != null)
            treeGlance.SelectedNode.Selected = false;

        textSearch.Text = "";
        PopulateCalendar();
    }


    /// <summary>
    /// Occurs when the user clicks on the search button to perform
    /// a search for tasks.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonSearch_Click(object sender, EventArgs e)
    {
        if (SelectedItem == "")
            SelectedItem = "%/%";

        if (SelectedItem.Contains("/"))
        {
            // Search for tasks based on the select node in the tree.
            //
            PopulateInbox(textSearch.Text);
        }
        else
        {
            // Search for tasks based on the selected day in the calendar.
            //
            gridTasks.DataSource = OActivity.GetOutstandingTasksAtDate(AppSession.User,
                calendarTasks.SelectedDate,
                "%" + textSearch.Text + "%");
            gridTasks.DataBind();
        }
    }


    /// <summary>
    /// Occurs when the user changes the month.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void calendarTasks_VisibleMonthChanged(object sender, MonthChangedEventArgs e)
    {
        PopulateCalendar();
    }


    protected override void Render(HtmlTextWriter writer)
    {
        System.IO.StringWriter sw = new System.IO.StringWriter();
        HtmlTextWriter hw = new HtmlTextWriter(sw);
        base.Render(hw);

        writer.Write(sw.ToString().Replace("color:AntiqueWhite", "                  "));
    }


    /// <summary>
    /// Perform mass action on selected objects.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonMassAction_Click(object sender, EventArgs e)
    {
        if (!panelMassAction.IsValid)
            return;
        
        // Validate to ensure that at least one checkbox selected.
        //
        int numberOfSelectedItems = 0;
        foreach (GridViewRow row in gridTasks.Rows)
            if ((row.Cells[0].Controls[0] as CheckBox).Checked)
                numberOfSelectedItems++;
        if (numberOfSelectedItems == 0)
        {
            labelMessage.Text = Resources.Errors.Task_CannotPerformMassActionNoTasksSelected;
            return;
        }
        
        
        // Load up all the relevant objects, and 
        // trigger the workflow event. 
        // 
        StringBuilder errorTasks = new StringBuilder();
        int count = 0;
        foreach (GridViewRow row in gridTasks.Rows)
        {
            if ((row.Cells[0].Controls[0] as CheckBox).Checked)
            {
                string objectTypeName = row.Cells[9].Text;
                try
                {
                    Type type = typeof(TablesLogic).Assembly.GetType("LogicLayer." + objectTypeName);
                    if (type != null)
                    {
                        using (Connection c = new Connection())
                        {
                            OActivity activity = TablesLogic.tActivity[(Guid)gridTasks.DataKeys[row.RowIndex][0]];
                            LogicLayerPersistentObject obj = PersistentObject.LoadObject(type, activity.AttachedObjectID.Value) as LogicLayerPersistentObject;
                            if (obj.CurrentActivity.ObjectName == "PendingApproval")
                            {
                                //obj.CurrentActivity.TriggeringEventName = dropMassAction.SelectedValue;
                                //obj.CurrentActivity.TaskCurrentComments = textComments.Text;
                                obj.Save();
                                //obj.TriggerWorkflowEvent(dropMassAction.SelectedValue);
                                obj.Save();
                                c.Commit();
                            }
                            else
                            {
                                throw new Exception();
                            }
                        }
                        count++;
                    }
                }
                catch (Exception ex)
                {
                    // the task type and task number.
                    //
                    errorTasks.Append(row.Cells[3].Text + " " + row.Cells[4].Text + "; ");
                }
            }
        }

        string message = "";
        if (count > 0)
            //message += String.Format(Resources.Messages.Task_ActionSuccessful, dropMassAction.SelectedItem.Text, count);
        if (errorTasks.Length > 0)
            //message += String.Format(Resources.Errors.Task_ActionUnsuccessful, dropMassAction.SelectedItem.Text, errorTasks.ToString());

        PopulateTasks();
        
        labelMessage.Text = message;
        //dropMassAction.SelectedIndex = 0;
        //textComments.Text = "";
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <link href="App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIPanel runat="server" ID="panel" BorderStyle="NotSet" 
        meta:resourcekey="panelResource1" BeginningHtml="" EndingHtml="">
        <div class="div-main">
            <table class="tabstrip" width="100%" border="0" cellpadding="0" cellspacing="0">
                <tr>
                    <td>
                        <ul style='direction: rtl'>
                            <li class="selected" style="display: inline;"><a runat="server" id="linkToday">
                                <asp:Label runat="server" ID="labelToday" 
                                  Text="Inbox"></asp:Label></a> </li>
                            <li style="display: inline;"><a runat="server" id="linkMonthView" href="homemonthview.aspx">
                                <asp:Label runat="server" ID="labelMonthView" 
                                    meta:resourcekey="labelMonthViewResource1" Text="Month View"></asp:Label></a> </li>
                            <li style="display: inline;"><a runat="server" id="linkDashboard" href="homedashboard.aspx">
                                <asp:Label runat="server" ID="labelDashboard" 
                                    meta:resourcekey="labelDashboardResource1" Text="Dashboard"></asp:Label></a> </li>
                        </ul>
                    </td>
                </tr>
            </table>
            <div class="div-form">
                <table width="100%">
                    <tr valign="top">
                        <td style='width: 200px'>
                            <ui:UISeparator runat="server" ID="sep1" Caption="At A Glance" meta:resourcekey="sep1Resource1" />
                            <asp:TreeView runat="server" ID="treeGlance" OnSelectedNodeChanged="treeGlance_SelectedNodeChanged" meta:resourcekey="treeGlanceResource1">
                            </asp:TreeView>
                            <ui:UISeparator runat="server" ID="sep2" Caption="Calendar" meta:resourcekey="sep2Resource1" />
                            <asp:Calendar runat="server" ID="calendarTasks" SkinID="SmallCalendar" OnDayRender="calendarTasks_DayRender" OnSelectionChanged="calendarTasks_SelectionChanged" OnVisibleMonthChanged="calendarTasks_VisibleMonthChanged" meta:resourcekey="calendarTasksResource2"></asp:Calendar>
                        </td>
                        <td style="width: 5px">
                        </td>
                        <td>
                            <asp:Panel runat="server" ID="panelBar" CssClass="home-buttons" meta:resourcekey="panelBarResource1">
                                <table cellpadding='0' cellspacing='0' border='0' style="width: 100%">
                                    <tr>
                                        <td style="white-space: nowrap">
                                            <asp:Panel runat="server" ID="panelNew" meta:resourcekey="panelNewResource1">
                                                <asp:Image runat="server" ID="imageNew" ImageUrl="~/images/plus.ico" ImageAlign="AbsMiddle" meta:resourcekey="imageNewResource1" />
                                                <asp:label runat="server" ID="labelNew" Text="Create New" meta:resourcekey="labelNewResource1"></asp:label>
                                                <asp:Image runat="server" ID="imageSubmenu" ImageUrl='~/images/submenu.gif' ImageAlign="AbsMiddle" meta:resourcekey="imageSubmenuResource1" />
                                                &nbsp; &nbsp;</asp:Panel>
                                        </td>
                                        <td style="white-space: nowrap">
                                            <ui:UIButton runat="server" ID="buttonRefresh" Text='Refresh Inbox' ImageUrl="~/images/symbol-refresh-big.gif" OnClick="buttonRefresh_Click" meta:resourcekey="buttonRefreshResource1"></ui:UIButton>
                                            &nbsp; &nbsp;
                                        </td>
                                        <td style="white-space: nowrap">
                                            <asp:TextBox runat="server" ID="textSearch" Width="150px" meta:resourcekey="textSearchResource1"></asp:TextBox>
                                            <ui:UIButton runat="server" ID="buttonSearch" ImageUrl="~/images/find.gif" Text="Search Tasks" OnClick="buttonSearch_Click" meta:resourcekey="buttonSearchResource1"></ui:UIButton>
                                        </td>
                                        <td align="right" style="width: 90%">
                                            <asp:Label runat="server" ID="labelDateTime" Font-Bold="True" meta:resourcekey="labelDateTimeResource1"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                                <asp:Panel runat="server" ID="panelNewObjects" Style="display: none; padding: 4px; max-height: 400px; overflow: auto" Width="200px" CssClass="menu-dropdown" meta:resourcekey="panelNewObjectsResource1">
                                    <asp:Label runat="server" ID="labelQuickCreate" meta:resourcekey="labelQuickCreateResource1"></asp:Label>
                                </asp:Panel>
                                <asp:PopupControlExtender ID="PopupControlExtender1" runat="server" PopupControlID="panelNewObjects" TargetControlID="panelNew" Position="Bottom" DynamicServicePath="" Enabled="True" ExtenderControlID="">
                                </asp:PopupControlExtender>
                            </asp:Panel>
                            <br />
                            <ui:UIPanel runat="server" ID="panelAnnouncements" BeginningHtml="" BorderStyle="NotSet" EndingHtml="" meta:resourcekey="panelAnnouncementsResource1">
                                <ui:UIGridView runat="server" ID="gridAnnouncements" 
                                    SortExpression="CreatedDateTime desc" Caption="Announcements" 
                                    DataKeyNames="ObjectID" GridLines="Both" 
                                    meta:resourcekey="gridAnnouncementsResource1" RowErrorColor="" 
                                    style="clear: both;" CheckBoxColumnVisible="False">
                                    <PagerSettings Mode="NumericFirstLast" />
                                    <Columns>
                                        <cc1:UIGridViewBoundColumn DataField="CreatedDateTime" DataFormatString="{0:dd-MMM-yyyy HH:mm}" HeaderText="Date/Time" meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="CreatedDateTime" ResourceAssemblyName="" SortExpression="CreatedDateTime">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewBoundColumn>
                                        <cc1:UIGridViewBoundColumn DataField="CreatedUser" HeaderText="From" meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="CreatedUser" ResourceAssemblyName="" SortExpression="CreatedUser">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewBoundColumn>
                                        <cc1:UIGridViewBoundColumn DataField="Announcement" HeaderText="Announcement" meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="Announcement" ResourceAssemblyName="" SortExpression="Announcement">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewBoundColumn>
                                    </Columns>
                                </ui:UIGridView>
                            </ui:UIPanel>
                            <ui:UIPanel runat="server" ID="panelTasks" BeginningHtml="" BorderStyle="NotSet" EndingHtml="" meta:resourcekey="panelTasksResource1">
                                <ui:uiobjectpanel runat="server" id="panelMassAction" BeginningHtml="" 
                                    BorderStyle="NotSet" EndingHtml="" meta:resourcekey="panelMassActionResource2">
                                    <%--<table cellpadding='0' cellspacing='0' border='0' >
                                     <tr>
                                            <td>
                                                <ui:uifielddropdownlist runat="server" id="dropMassAction" Caption="Action" 
                                                    FieldLayout="Flow" InternalControlWidth="100px" ValidateRequiredField="True" >
                                                    <Items>
                                                        <asp:ListItem meta:resourcekey="ListItemResource1"></asp:ListItem>
                                                        <asp:ListItem Value="Approve" meta:resourcekey="ListItemResource2">Approve</asp:ListItem>
                                                        <asp:ListItem Value="Reject" meta:resourcekey="ListItemResource3">Reject</asp:ListItem>
                                                        <asp:ListItem Value="Cancel" meta:resourcekey="ListItemResource4">Cancel</asp:ListItem>
                                                    </Items>
                                                </ui:uifielddropdownlist>
                                               &nbsp;
                                               &nbsp;
                                                <ui:uifieldtextbox runat="server" id="textComments" Caption="Comments" 
                                                    FieldLayout="Flow" InternalControlWidth="300px" 
                                                    meta:resourcekey="textCommentsResource1" >
                                                </ui:uifieldtextbox>
                                               &nbsp;
                                               &nbsp;
                                                <ui:uibutton runat="server" ID="buttonMassAction" 
                                                    OnClick="buttonMassAction_Click" ImageUrl="~/images/tick.gif" Text="Confirm" 
                                                    ConfirmText="Are you wish to wish to act on the selected items?" 
                                                    meta:resourcekey="buttonMassActionResource1" />
                                            </td>
                                        </tr>
                                    </table>--%>
                                    
                                </ui:uiobjectpanel>
                                <ui:UIGridView runat="server" ID="gridTasks" 
                                    SortExpression="ScheduledStartDateTime desc" Caption="Tasks" 
                                    OnAction="gridTasks_Action" OnRowDataBound="gridTasks_RowDataBound" 
                                    KeyName="ObjectID" meta:resourcekey="gridTasksResource1" 
                                    MouseOutColor="#FFFF80" DataKeyNames="ObjectID" GridLines="Both" 
                                    RowErrorColor="" style="clear: both;">
                                    <PagerSettings Mode="NextPreviousFirstLast" FirstPageText="First" LastPageText="Last" Position="TopAndBottom" />
                                    <Columns>
                                        <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject" meta:resourcekey="UIGridViewColumnResource1" ButtonType="Image">
                                            <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewButtonColumn>
                                        <ui:UIGridViewTemplateColumn meta:resourcekey="UIGridViewColumnResource2">
                                            <ItemTemplate>
                                                <asp:Image runat="server" ID="imageClock" Visible="False" ImageUrl="~/images/alert.gif" meta:resourcekey="imageClockResource1"></asp:Image>
                                            </ItemTemplate>
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewTemplateColumn>
                                        <ui:UIGridViewBoundColumn PropertyName="ObjectTypeName" HeaderText="Task Type" ResourceName="Resources.Objects" meta:resourcekey="UIGridViewColumnResource3" DataField="ObjectTypeName" ResourceAssemblyName="" SortExpression="ObjectTypeName">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn PropertyName="TaskNumber" HeaderText="Task Number" meta:resourcekey="UIGridViewColumnResource4" DataField="TaskNumber" ResourceAssemblyName="" SortExpression="TaskNumber">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn PropertyName="TaskName" HeaderText="Task Name" meta:resourcekey="UIGridViewColumnResource5" DataField="TaskName" ResourceAssemblyName="" SortExpression="TaskName">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn PropertyName="TaskAmount" HeaderText="Amount" DataFormatString="{0:c}" DataField="TaskAmount" meta:resourcekey="UIGridViewBoundColumnResource4" ResourceAssemblyName="" SortExpression="TaskAmount">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn PropertyName="Status" HeaderText="Status" meta:resourcekey="UIGridViewColumnResource8" ResourceName="Resources.WorkflowStates" DataField="Status" ResourceAssemblyName="" SortExpression="Status">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn DataFormatString="&lt;img src='images/priority{0}.gif' border='0' /&gt;" HtmlEncode="False" PropertyName="Priority" HeaderText="Priority" meta:resourcekey="UIGridViewColumnResource9" DataField="Priority" ResourceAssemblyName="" SortExpression="Priority">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewBoundColumn>
                                        <ui:UIGridViewBoundColumn PropertyName="ObjectTypeName" 
                                            DataField="ObjectTypeName" meta:resourcekey="UIGridViewBoundColumnResource6" 
                                            ResourceAssemblyName="" SortExpression="ObjectTypeName">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </ui:UIGridViewBoundColumn>
                                    </Columns>
                                </ui:UIGridView>
                            </ui:UIPanel>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </ui:UIPanel>
    <ui:UIPanel runat="server" ID="panelMessage" HorizontalAlign="Center" 
        BeginningHtml="" BorderStyle="NotSet" EndingHtml="" 
        meta:resourcekey="panelMessageResource2">
        <div runat="server" id="tableMessage" class="object-message" style="top: -50px; width: 100%; position: absolute;">
            <table style="width: 100%" cellpadding="5">
                <tr>
                    <td>
                        <table border="0" cellspacing="0" cellpadding="0" width="100%">
                            <tr valign="top">
                                <td align="left">
                                    <asp:Label runat='server' ID='labelMessage' meta:resourcekey="labelMessageResource1"></asp:Label>
                                </td>
                                <td align="right">
                                    <asp:HyperLink runat="server" ID="linkClose" Text="Hide" 
                                        NavigateUrl="javascript:void(0)" meta:resourcekey="linkCloseResource2"></asp:HyperLink>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
        <asp:AnimationExtender ID="AnimationExtender1" runat="server" 
            TargetControlID="tableMessage" Enabled="True">
            <Animations>
                <OnLoad>
                    <Parallel duration="0.3">
                        <FadeIn fps="10"></FadeIn>
                        <Move vertical="50" fps="10"></Move>
                    </Parallel>
                </OnLoad></Animations>
        </asp:AnimationExtender>
        <asp:AlwaysVisibleControlExtender runat="server" ID="acv1" 
            TargetControlID="tableMessage" Enabled="True">
        </asp:AlwaysVisibleControlExtender>
    </ui:UIPanel>
    </form>
</body>
</html>