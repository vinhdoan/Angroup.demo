<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource2" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<link rel="stylesheet" type="text/css" href="tooltip.css" />

<script runat="server">

    Hashtable workCount = new Hashtable();
    Hashtable workInfo = new Hashtable();
    DataList<OCalendarHoliday> holidays;
    System.Drawing.Color HolidayColor = System.Drawing.Color.Red;
    System.Drawing.Color WorkColor = System.Drawing.Color.FromName("#66CCFF");
    List<WorkDummy> worklist = null;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            OScheduledWork sw = Session["::SessionObject::"] as OScheduledWork;
            try
            {
                worklist = sw.PretendCreateWorks();
            }
            catch (Exception ex)
            {
                Window.WriteJavascript("alert('Please Select Items and Recurrence Mode First');window.close();");
                return;
            }
            if (worklist.Count == 0)
            {
                Window.WriteJavascript("alert('Please Select Items and Recurrence Mode First');window.close();");
                return;
            }
            DateTime firstDate = DateTime.MaxValue;
            DateTime lastDate = DateTime.MinValue;
            foreach (WorkDummy work in worklist)
            {
                if (work.ScheduledStartDateTime < firstDate)
                    firstDate = work.ScheduledStartDateTime;
                if (work.ScheduledEndDateTime > lastDate)
                    lastDate = work.ScheduledEndDateTime;
            }

            // populate the year dropdownlist
            //
            for (int i = firstDate.Year; i <= lastDate.Year; i++)
                dropYear.Items.Add(new ListItem(i.ToString(), i.ToString()));

            populateCalendar(firstDate.Year);

        }
        HolidayLegend.BackColor = HolidayColor;
        WorkLegend.BackColor = WorkColor;
    }

    private void populateCalendar(int currentYear)
    {
        OScheduledWork sw = Session["::SessionObject::"] as OScheduledWork;
        tbCalendar.Rows.Clear();

        // 2011.04.12
        // Kim Foong
        // Included the sw.Calendar != null as a condition.
        //if (holidays == null)
        if (holidays == null && sw.Calendar != null)
            holidays = sw.Calendar.HolidayDates;


        if (worklist == null)
        {
            try
            {
                worklist = sw.PretendCreateWorks();
            }
            catch (Exception ex)
            {
                Window.WriteJavascript("alert('Please Select Items and Recurrence Mode First');window.close();");
                return;
            }
        }

        List<Calendar> calList = new List<Calendar>();
        DateTime datetemp = new DateTime(currentYear, 1, 1);
        int rows = 4;
        //double monthCount = (lastDate.Year - firstDate.Year) * 12 + lastDate.Month - firstDate.Month+1;         
        double monthCount = 12;
        double cols = Math.Ceiling(monthCount / rows);
        int count = 0;
        for (int j = 0; j < cols; j++)
        {
            TableRow trTemp = new TableRow();
            for (int i = 0; i < rows; i++)
            {
                TableCell tcTemp = new TableCell();
                Calendar calTemp = new Calendar();
                calTemp.VisibleDate = datetemp;
                calTemp.SkinID = "smallCalendar";
                calTemp.ShowNextPrevMonth = false;
                calTemp.SelectionMode = System.Web.UI.WebControls.CalendarSelectionMode.None;
                calTemp.SelectedDayStyle.BackColor = WorkColor;
                calTemp.SelectedDayStyle.BorderColor = System.Drawing.Color.FromName("#FF3300");
                calTemp.SelectedDayStyle.BorderStyle = System.Web.UI.WebControls.BorderStyle.Solid;
                calTemp.SelectedDayStyle.BorderWidth = System.Web.UI.WebControls.Unit.Pixel(1);
                calTemp.DayRender += calTest_DayRender;

                datetemp = datetemp.AddMonths(1);
                tcTemp.Controls.Add(calTemp);
                trTemp.Cells.Add(tcTemp);
                calList.Add(calTemp);
                count++;
                if (count >= monthCount)
                    break;
            }
            tbCalendar.Rows.Add(trTemp);
        }

        foreach (WorkDummy work in worklist)
        {
            // monthDiffStart: the difference between current work's month and the first month, used as index of calendar list
            //int monthDiffStart = (work.ScheduledStartDateTime.Year - firstDate.Year) * 12 + work.ScheduledStartDateTime.Month - firstDate.Month;
            if (work.ScheduledStartDateTime.Year > currentYear ||
                work.ScheduledEndDateTime.Year < currentYear)
                continue;

            if (work.ScheduledStartDateTime.Year == currentYear)
                calList[work.ScheduledStartDateTime.Month - 1].SelectedDates.Add(work.ScheduledStartDateTime);

            DateTime temp = work.ScheduledStartDateTime;
            while (true)
            {
                if (temp.Year == currentYear)
                    calList[temp.Month - 1].SelectedDates.Add(temp);
                string key = temp.ToString("dd-MM-yyyy");

                if (workCount[key] == null || (int)workCount[key] < 15)
                {
                    if (workCount[key] == null)
                        workCount[key] = 1;
                    else
                        workCount[key] = (int)workCount[key] + 1;
                    workInfo[key] += formatTooltip(work);

                    if ((int)workCount[key] == 15)
                        workInfo[key] += "<tr><td colspan='5'>... ... ... ...</td></tr>";
                }

                if (temp.Year == work.ScheduledEndDateTime.Year &&
                    temp.Month == work.ScheduledEndDateTime.Month &&
                    temp.Day == work.ScheduledEndDateTime.Day)
                    break;
                temp = temp.AddDays(1);
            }
        }

        if (sw.Calendar != null)
            foreach (OCalendarHoliday i in sw.Calendar.HolidayDates)
            {
                if (i.HolidayDate.Value.Year == currentYear)
                    calList[i.HolidayDate.Value.Month - 1].SelectedDates.Add(i.HolidayDate.Value);
            }
    }


    protected string formatTooltip(WorkDummy work)
    {
        string temp = "<tr><td>" + (work.LocationPath) + "&nbsp</td>" +
            "<td>" + (work.EquipmentPath) + "&nbsp</td>" +
            "<td>" + work.Checklist + "&nbsp</td>" +
            "<td>" + work.ScheduledStartDateTime.ToString("dd-MMM HH:mm") + "</td>" +
            "<td>" + work.ScheduledEndDateTime.ToString("dd-MMM HH:mm") + "</td></tr>";
        return temp;
    }

    protected void calTest_DayRender(object sender, DayRenderEventArgs e)
    {
        if (e.Day.IsSelected)
        {
            if (holidays != null)
            {
                foreach (OCalendarHoliday i in holidays)
                {
                    if (e.Day.Date == i.HolidayDate.Value)
                    {
                        e.Cell.BackColor = HolidayColor;
                        e.Cell.BorderColor = System.Drawing.Color.Black;
                        e.Cell.Attributes["title"] = "header=[Holiday] body=[" + i.ObjectName + "] cssbody=[workpreview-holiday-tooltip-body] cssheader=[workpreview-holiday-tooltip-header]";
                        return;
                    }
                }
            }
            if (workInfo[e.Day.Date.ToString("dd-MM-yyyy")] != null)
            {
                e.Cell.Attributes["title"] = "header=[Schedule] body=[" +
                     "<table cellpadding='1px' cellspacing='0' border='solid' > " +
                     "<tr><td>Location</td><td>Equipment</td><td>Check List</td><td>Schedule Start</td><td>Schedule End</td></tr>" +
                     workInfo[e.Day.Date.ToString("dd-MM-yyyy")].ToString() +
                     "</table>] cssbody=[workpreview-tooltip-body] cssheader=[workpreview-tooltip-header]";
            }
        }

    }

    protected void dropYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        populateCalendar(Convert.ToInt32(dropYear.SelectedValue));
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
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:pagepanel runat="server" ID="pagePanelMain" Caption="Scheduled Works Preview"
            Button1_Caption="" Button1_ImageUrl="" Button1_CommandName="" Button2_Caption=""
            Button2_ImageUrl="" Button2_CommandName="" Button3_Caption="" Button3_ImageUrl=""
            Button3_CommandName="" Button4_Caption="" Button4_ImageUrl="" Button4_CommandName="" meta:resourcekey="pagePanelMainResource1" />
        <div class="div-main">
            <br/>
            <table>
                <tr><td align='center'>
                <asp:DropDownList runat="server" ID="dropYear" OnSelectedIndexChanged="dropYear_SelectedIndexChanged" AutoPostBack="true">
                </asp:DropDownList>
            <br/>
            <asp:Table ID="tbCalendar" runat="server" CellSpacing="3" meta:resourcekey="tbCalendarResource1">
            </asp:Table>
            <br />
            <ui:UISeparator runat="server" ID="Legend" Caption="Legend" meta:resourcekey="LegendResource2" />
                </td></tr>
            </table>
        </div>
        <asp:Table runat="server" meta:resourcekey="TableResource1">
            <asp:TableRow runat="server" meta:resourcekey="TableRowResource1">
                <asp:TableCell runat="server" ID="HolidayLegend" Width="50px" meta:resourcekey="HolidayLegendResource2"
                    Text="&amp;nbsp"></asp:TableCell>
                <asp:TableCell runat="server" Width="100px" meta:resourcekey="TableCellResource4"
                    Text="Holiday"></asp:TableCell>
                <asp:TableCell runat="server" Width="50px" meta:resourcekey="TableCellResource5"
                    Text="&amp;nbsp"></asp:TableCell>
                <asp:TableCell runat="server" ID="WorkLegend" Width="50px" meta:resourcekey="WorkLegendResource2"
                    Text="&amp;nbsp"></asp:TableCell>
                <asp:TableCell runat="server" Width="150px" meta:resourcekey="TableCellResource6"
                    Text="Scheduled Work Date"></asp:TableCell>
            </asp:TableRow>
        </asp:Table>
    </ui:UIObjectPanel>

    <script src='../../scripts/boxover.js' type='text/javascript'></script>

    </form>
</body>
</html>
