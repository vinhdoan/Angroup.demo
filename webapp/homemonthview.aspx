<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">

    public bool flag = false;

    // kf begin: removed to optimize home page loading
    //private List<OActivity> activitiesForTheMonth = null;
    private DataTable dtActivitiesForTheMonth;
    // kf end

    //-------------------------------------------------------------------
    // event
    //-------------------------------------------------------------------
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            DateTime now = DateTime.Now;
            dtActivitiesForTheMonth = OActivity.GetMonthActivities(AppSession.User, now.Year, now.Month);
            Session.Add("dtActivities", dtActivitiesForTheMonth);
            PopulateForm();

            System.Globalization.CultureInfo ci = System.Threading.Thread.CurrentThread.CurrentUICulture;
            if (ci.TextInfo.IsRightToLeft)
            {
                linkToday.Style["float"] = "right";
                linkMonthView.Style["float"] = "right";
                linkDashboard.Style["float"] = "right";
            }
        }
        else dtActivitiesForTheMonth = (DataTable)Session["dtActivities"];
    }

    //-------------------------------------------------------------------
    // event
    //-------------------------------------------------------------------
    protected void PopulateForm()
    {
    }

    
    //-------------------------------------------------------------------
    // event
    //-------------------------------------------------------------------
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
    }
    
    protected string encodeString(string s)
    {
        return s.Replace("\"", "\"\"");
    }

    protected void formRow(StringBuilder sb, string columnName, object val)
    {
        formRow(sb, columnName, val, null);
    }

    protected void formRow(StringBuilder sb, string columnName, object val, string dataFormatString)
    {
        sb.Append("<tr><td width='100px'>");
        sb.Append(Resources.Strings.ResourceManager.GetString(columnName));     // translate it from strings.resxs
        sb.Append("</td><td>");
        if (val != null && val != DBNull.Value)
        {
            if (dataFormatString == null)
                sb.Append(encodeString(val.ToString()));
            else
                sb.Append(encodeString(String.Format(dataFormatString, val)));
        }
        sb.Append("</td></tr>");
    }

    protected string getPriority(int? priority)
    {
        if (priority == null)
            return "";
        else
            return priority.ToString();
    }

    [Obsolete]
    protected string formTable(OActivity activity)
    {
        StringBuilder sb = new StringBuilder();
        formRow(sb, "Task_Status", Resources.Objects.ResourceManager.GetString(activity.ObjectName));
        formRow(sb, "Task_Priority", "<img src='" + ResolveUrl("~/images/") + "priority" + getPriority(activity.Priority) + ".gif' align='absmiddle'> ");
        formRow(sb, "Task_ScheduledStartDateTime", activity.ScheduledStartDateTime, "{0:dd-MMM-yyyy hh:mm tt}");
        formRow(sb, "Task_ScheduledEndDateTime", activity.ScheduledEndDateTime, "{0:dd-MMM-yyyy hh:mm tt}");

        return sb.ToString();
    }


    // kf begin: added to improve loading performance at home page    
    //-------------------------------------------------------------------
    /// <summary>
    /// Form the tool tip table from the activity DataRow.
    /// </summary>
    /// <param name="dr"></param>
    /// <returns></returns>
    //-------------------------------------------------------------------
    protected string formTableFromActivity(DataRow dr)
    {
        StringBuilder sb = new StringBuilder();
        formRow(sb, "Task_ObjectName", dr["TaskName"]);
        formRow(sb, "Task_Status", Resources.Objects.ResourceManager.GetString(dr["Status"].ToString()));
        formRow(sb, "Task_Priority", "<img src='" + ResolveUrl("~/images/") + "priority" + getPriority((int?)dr["Priority"]) + ".gif' align='absmiddle'> ");
        formRow(sb, "Task_ScheduledStartDateTime", dr["ScheduledStartDateTime"], "{0:dd-MMM-yyyy hh:mm tt}");
        formRow(sb, "Task_ScheduledEndDateTime", dr["ScheduledEndDateTime"], "{0:dd-MMM-yyyy hh:mm tt}");

        return sb.ToString();
    }
    // kf: end


    //-------------------------------------------------------------------
    // event
    //-------------------------------------------------------------------
    // kf begin: added to improve loading speed of home page
    Hashtable functionHash = null;
    
    protected void calendarTasks_DayRender2(object sender, DayRenderEventArgs e)
    {
        if (functionHash == null)
        {
            functionHash = new Hashtable();
            List<OFunction> functions = OFunction.GetAllFunctions();
            foreach (OFunction function in functions)
                functionHash[function.ObjectTypeName] = function;
        }
        
        if (flag == false)
        {
            foreach (DataRow dr in dtActivitiesForTheMonth.Rows)
            {
                if (((DateTime)dr["ScheduledStartDateTime"]).AddDays(-1) <= e.Day.Date &&
                    e.Day.Date <= ((DateTime)dr["ScheduledEndDateTime"]))
                {
                    string objectType = (string)dr["ObjectTypeName"];
                    
                    OFunction function = functionHash[objectType] as OFunction;

                    if (function != null)
                    {
                        // kf end
                        string p = 
                            ResolveUrl(function.EditUrl) +
                            "?ID=" + HttpUtility.UrlEncode(Security.Encrypt("EDIT:" + dr["AttachedObjectID"].ToString())) +
                            "&TYPE=" + HttpUtility.UrlEncode(Security.Encrypt(objectType));

                        LiteralControl c = new LiteralControl();
                        c.Text = "<br/><span style='cursor:hand' " +
                            "onclick=\"window.open( '" + p + "', 'AnacleEAM_Window' );\" " +
                            "class='" +
                            (((DateTime)dr["ScheduledEndDateTime"]) < DateTime.Now ? "task-urgentitem" : "") +
                            "' title=\"header=[" +
                            encodeString(dr["TaskNumber"].ToString()) +
                            "] body=[<table cellpadding='0' cellspacing='0' border='0' width='250px'>" +
                            formTableFromActivity(dr) +
                            "</table>] cssbody=[gantt-tooltip-body] cssheader=[gantt-tooltip-header]\">" +
                            "<img width='16px' height='16px' src='" + ResolveUrl("~/images/") + "priority" + getPriority((int?)dr["Priority"]) + ".gif' align='absmiddle'> " +
                            dr["TaskNumber"].ToString() + "</span></a>";
                        e.Cell.Controls.Add(c);
                        // kf begin: bug fix
                    }
                    // kf end
                }
            }
        }
    }
    // kf end;

    //-------------------------------------------------------------------
    // event
    //-------------------------------------------------------------------
    protected void calendarTasks_VisibleMonthChanged(object sender, MonthChangedEventArgs e)
    {
        DateTime now = calendarTasks.VisibleDate;
        dtActivitiesForTheMonth = OActivity.GetMonthActivities(AppSession.User, now.Year, now.Month);
        Session["dtActivities"] = dtActivitiesForTheMonth;
    }

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <link href="App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="div-main">
		    <table class="tabstrip" width="100%" border="0" cellpadding="0" cellspacing="0">
                <tr>
	                <td>
	                    <ul>
		                    <li style="display:inline;">
	                            <a runat="server" id="linkToday" href="home.aspx"><asp:Label runat="server" ID="labelToday" meta:resourcekey="labelTodayResource1" >Today</asp:Label></a>
	                        </li>
	                        <li class="selected" style="display:inline;">
	                            <a runat="server" id="linkMonthView" ><asp:Label runat="server" ID="labelMonthView" meta:resourcekey="labelMonthViewResource1">Month View</asp:Label></a>
	                        </li>
	                        <li style="display:inline;">
	                            <a runat="server" id="linkDashboard" href="homedashboard.aspx"><asp:Label runat="server" ID="labelDashboard" meta:resourcekey="labelDashboardResource1">Dashboard</asp:Label></a>
	                        </li>
	                    </ul>
	                </td>
                </tr>
            </table>
            <div class="div-form">
                <table width="100%">
                    <tr>
                        <td>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Calendar runat="server" ID="calendarTasks" Font-Names="Tahoma" Font-Size="8pt" SkinID="BigCalendar"
                                ShowGridLines="True" Width="100%" SelectionMode="None" OnDayRender="calendarTasks_DayRender2"
                                meta:resourcekey="calendarTasksResource1" OnVisibleMonthChanged="calendarTasks_VisibleMonthChanged">
                            </asp:Calendar>
                        </td>
                    </tr>
                </table>
            </div>
            <br />
        </div>

        <script src='scripts/boxover.js' type='text/javascript'></script>

    </form>
</body>
</html>
