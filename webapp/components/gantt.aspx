<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" %>
<%@ Register Assembly="schedulecalendar" Namespace="schedulecalendar.rw" TagPrefix="cc1" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI.HtmlControls" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    
    private string fieldPercentageComplete = null;
    private string fieldTitle = null;
    private string fieldStartDate = null;
    private string fieldEndDate = null;

    protected void Page_Load(object sender, EventArgs e)
    {
        fieldTitle = Security.Decrypt(Request["T"]);
        fieldPercentageComplete = Security.Decrypt(Request["C"]);
        fieldStartDate = Security.Decrypt(Request["S"]);
        fieldEndDate = Security.Decrypt(Request["E"]);

        if (!IsPostBack)
        {

            BindMonthList();
            BindChart();
        }
    }


    protected void BindMonthList()
    {
        DataTable dt = (DataTable)Session["GANTT"];
        DateTime minTime = DateTime.MaxValue;
        DateTime maxTime = DateTime.MinValue;

        foreach (DataRow dr in dt.Rows)
        {
            if (dr[fieldStartDate] != DBNull.Value)
            {
                DateTime d = (DateTime)dr[fieldStartDate];
                if (d < minTime) minTime = d;
                if (d > maxTime) maxTime = d;
            }

            if (dr[fieldEndDate] != DBNull.Value)
            {
                DateTime d = (DateTime)dr[fieldEndDate];
                if (d < minTime) minTime = d;
                if (d > maxTime) maxTime = d;
            }
        }

        dropMonth.Items.Clear();
        for (DateTime d = new DateTime(minTime.Year, minTime.Month, 1); d <= maxTime; d = d.AddMonths(1))
            dropMonth.Items.Add(new ListItem(d.ToString("MMM-yyyy"), d.ToString()));
    }


    protected void BindChart()
    {
        DataTable dt = (DataTable)Session["GANTT"];
        if (dt == null)
            return;

        DataTable dt2 = dt.Copy();
        dt2.Columns.Add("__start__", typeof(DateTime));
        dt2.Columns.Add("__end__", typeof(DateTime));

        if (radioType.SelectedIndex == 0 && dropMonth.Items.Count > 0)
        {
            int counter = 0;
            DateTime minDate = Convert.ToDateTime(dropMonth.SelectedValue);
            DateTime maxDate = Convert.ToDateTime(dropMonth.SelectedValue).AddMonths(2).AddDays(-1);
            foreach (DataRow dr in dt2.Rows)
            {
                if (dr[fieldTitle] == DBNull.Value)
                    dr[fieldTitle] = " ";

                if (Request["GROUP"] == "0")
                    dr[fieldTitle] += "<span style='display:none'>" + (counter++).ToString("0000000000") + "</span>";

                dr["__start__"] = dr[fieldStartDate];
                dr["__end__"] = dr[fieldEndDate];

                if (dr["__start__"] != DBNull.Value)
                {
                    dr["__start__"] = ((DateTime)dr["__start__"]).Date;
                    if (((DateTime)dr["__start__"]) < minDate)
                        dr["__start__"] = minDate;
                    if (((DateTime)dr["__start__"]) > maxDate)
                        dr["__start__"] = maxDate;
                }

                if (dr["__end__"] != DBNull.Value)
                {
                    dr["__end__"] = ((DateTime)dr["__end__"]).Date;
                    if (((DateTime)dr["__end__"]) < minDate)
                        dr["__end__"] = minDate;
                    if (((DateTime)dr["__end__"]) > maxDate)
                        dr["__end__"] = maxDate;

                    dr["__end__"] = ((DateTime)dr["__end__"]).AddSeconds(1);
                }

                if (dr["__start__"] != DBNull.Value && dr["__end__"] != DBNull.Value)
                {
                    if (((DateTime)dr["__start__"]) == ((DateTime)dr["__end__"]))
                        dr["__end__"] = ((DateTime)dr["__start__"]).AddSeconds(1);
                }
            }

            DataRow newRow = dt2.NewRow();
            newRow["__start__"] = minDate;
            newRow["__end__"] = maxDate.AddDays(1).AddSeconds(-1);
            newRow[fieldStartDate] = minDate;
            newRow[fieldEndDate] = maxDate.AddDays(1).AddSeconds(-1);
            newRow[fieldTitle] = "";
            dt2.Rows.Add(newRow);
        }
        else
        {
            foreach (DataRow dr in dt2.Rows)
            {
                if (dr[fieldTitle] == DBNull.Value)
                    dr[fieldTitle] = " ";
            }
        }
                
        ScheduleGeneral1.DataRangeStartField = "__start__";
        ScheduleGeneral1.DataRangeEndField = "__end__";
        ScheduleGeneral1.TitleField = fieldTitle;

        firstItem = true;
        
        
        ScheduleGeneral1.DataSource = dt2;
        ScheduleGeneral1.DataBind();
    }

    protected string encodeString(string s)
    {
        return s.Replace("\"", "\"\"");
    }

    protected string formTable(DataRowView drv)
    {
        StringBuilder sb = new StringBuilder();
        DataTable dt = drv.DataView.Table;

        foreach (DataColumn dc in dt.Columns)
        {
            if (dc.ColumnName == "__start__" || dc.ColumnName == "__end__")
                continue;
            
            sb.Append("<tr><td>");
            sb.Append(Resources.Strings.ResourceManager.GetString(dc.ColumnName, System.Threading.Thread.CurrentThread.CurrentUICulture));     // translate it from strings.resxs
            sb.Append("</td><td>");
            if( dc.ColumnName!="Gantt_Status" )
                sb.Append(encodeString(drv[dc.ColumnName].ToString()));
            else
                sb.Append(Resources.Objects.ResourceManager.GetString(drv[dc.ColumnName].ToString(), System.Threading.Thread.CurrentThread.CurrentUICulture));     // translate it from strings.resxs
            sb.Append("</td></tr>");
        }
        return sb.ToString();
    }

    bool firstItem = true;

    protected void ScheduleGeneral1_ItemDataBound(object sender, ScheduleItemEventArgs e)
    {
        if (e.Item.ItemType == ScheduleItemType.Item ||
            e.Item.ItemType == ScheduleItemType.AlternatingItem)
        {
            HtmlTable divComplete = e.Item.FindControl("divComplete") as HtmlTable;
            HtmlGenericControl divBar = e.Item.FindControl("divBar") as HtmlGenericControl;
            DataRowView drv = e.Item.DataItem as DataRowView;

            if (drv[fieldTitle].ToString()=="")
            {
                divBar.Visible = false;
                firstItem = false;
            }

            if (fieldPercentageComplete != null && divComplete!=null)
            {
                try
                {
                    int complete = Convert.ToInt32(drv[fieldPercentageComplete].ToString());
                    if (complete < 0) complete = 0;
                    if (complete > 100) complete = 100;

                    if (complete > 0)
                        divComplete.Style["width"] = complete.ToString() + "%";
                    else
                        divComplete.Style["display"] = "none";
                }
                catch
                {
                    divComplete.Style["display"] = "none";
                }
            }

            if (divBar != null)
            {
                divBar.Attributes["title"] = "header=[" + encodeString(drv[fieldTitle].ToString()) +
                    "] body=[<table cellpadding='0' cellspacing='0' border='0' width='250px'> " +
                    formTable(drv) +
                    "</table>] cssbody=[gantt-tooltip-body] cssheader=[gantt-tooltip-header]";

                if( drv.Row.Table.Columns.Contains("Gantt_Status") )
                    divBar.Attributes["class"] = "gantt-"+encodeString(drv["Gantt_Status"].ToString());
            }
        }
    }

    protected void dropMonth_ControlChange(object sender, EventArgs e)
    {
        BindChart();
    }

    protected void radioType_ControlChange(object sender, EventArgs e)
    {
        BindChart();
    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        panelMonth.Visible = radioType.SelectedIndex == 0;
    }

    protected void buttonPrev_Click(object sender, EventArgs e)
    {
        if (dropMonth.SelectedIndex > 0)
            dropMonth.SelectedIndex--;
        BindChart();
    }

    protected void buttonNext_Click(object sender, EventArgs e)
    {
        if (dropMonth.SelectedIndex < dropMonth.Items.Count-1)
            dropMonth.SelectedIndex++;
        BindChart();
    }

    
    // 2010.05.14
    // Kim Foong
    // Added the selected index changed event.
    /// <summary>
    /// Occurs when the dropdown list is updated.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropMonth_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindChart();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
</head>
<body>
    <form id="form1" runat="server">
        <div style="padding: 8px 8px 8px 8px">
            <div class='div-form'>
            <asp:Panel runat="server" ID="panel1" Width="100%">
                <ui:UIFieldRadioList runat="server" ID="radioType" Caption="View by" RepeatDirection="Vertical" Visible="false">
                    <Items>
                        <asp:listitem value="0" selected="true">View by month</asp:listitem>
                        <asp:listitem value="1">View entire chart</asp:listitem>
                    </Items>
                </ui:UIFieldRadioList>
                <asp:Panel runat="server" ID="panelMonth" Width="100%">
                    <ui:UIFieldDropDownList ID="dropMonth" runat="server" Caption="Month" OnSelectedIndexChanged="dropMonth_SelectedIndexChanged">
                    </ui:UIFieldDropDownList>
                    <asp:Label ID="Label1" runat="server" Width="120px"></asp:Label>
                    <ui:UIButton ID="buttonPrev" runat="server" ImageUrl="~/images/resultset_previous.gif" Text="Previous Month" OnClick="buttonPrev_Click" />
                    <ui:UIButton ID="buttonNext" runat="server" ImageUrl="~/images/resultset_next.gif"  Text="Next Month" OnClick="buttonNext_Click"/>
                </asp:Panel>
            </asp:Panel>
            <hr style="width:100%; height:1px" />
            <cc1:ScheduleGeneral ID="ScheduleGeneral1" runat="server" EnableViewState="false"
                TitleField="T1" DataRangeStartField="Start"  EnableTheming="true" HeaderGroupType="Month" 
                DataRangeEndField="End" FullTimeScale="true"  IncludeEndValue="false" TimeScaleInterval="10080" EndOfTimeScale="00:00:00" StartOfTimeScale="23:00:00"  BorderStyle="Solid" BorderColor="silver" GridLines="both" BorderWidth="1px" Layout="Horizontal" 
                DateHeaderDataFormatString="{0:MMM-yyyy}" SeparateDateHeader="true"  RangeDataFormatString="{0:dd}" 
                CellPadding="1" CellSpacing="0" EnableEmptySlotClick="false" ShowValueMarks="false" OnItemDataBound="ScheduleGeneral1_ItemDataBound" >
                <ItemTemplate>
                    <div runat='server' style="width:100%;" title='test' id="divBar">
                        <table cellpadding="0" cellspacing="0" border="0" width="100%" height="12px"><tr><td valign="middle">
                            <table runat="server" id="divComplete" class="gantt-complete" runat="server"><tr><td></td></tr></table>
                        </td></tr></table>
                    </div>
                </ItemTemplate>
            </cc1:ScheduleGeneral>
            </div>
        </div>
        <script src='../scripts/boxover.js' type='text/javascript'></script>
    </form>
</body>
</html>
