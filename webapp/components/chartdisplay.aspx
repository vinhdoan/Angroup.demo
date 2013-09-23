<%@ Page Language="C#" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="dotnetCHARTING" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    /// <summary>
    /// Overrides the OnLoad event to bind data
    /// to the dropdown list, and to refresh
    /// data in the chart.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            BindData();
        }
    }


    /// <summary>
    /// Sets the axis type.
    /// </summary>
    /// <param name="axis"></param>
    /// <param name="axisType"></param>
    protected void SetAxisType(Axis axis, int? axisType)
    {
        if (axisType == DashboardAxisType.Normal)
            axis.Scale = Scale.Normal;
        else if (axisType == DashboardAxisType.Stacked)
            axis.Scale = Scale.Stacked;
        else if (axisType == DashboardAxisType.FullStacked)
            axis.Scale = Scale.FullStacked;
        else if (axisType == DashboardAxisType.DateTime)
        {
            axis.Scale = Scale.Time;
            axis.TimeScaleLabels.Mode = TimeScaleLabelMode.Dynamic;
            axis.TimeScaleLabels.DayFormatString = "dd-MMM-yyyy";
        }
    }


    /// <summary>
    /// Sets the chart type.
    /// </summary>
    /// <param name="chart"></param>
    /// <param name="dashboard"></param>
    protected void InitializeChart(Chart chart, string dashboardType, string xAxisLabelText, string yAxisLabelText, bool use3D)
    {
        // We have to give our chart image a specific filename,
        // because an apparenty bug in the charting control can
        // sometimes cause two charts on the same screen to mistakenly
        // points to the same file (!).
        //
        // Explicitly specifying the file name seems to get rid 
        // of that problem.
        //
        chart.CleanupPeriod = 60;
        chart.TempDirectory = Page.Request.PhysicalApplicationPath + "temp\\charts";
        chart.FileName = "dc" + Guid.NewGuid().ToString().Replace("-", "");

        if (dashboardType == "Pie:Pies")
        {
            chart.Type = ChartType.Pies;
            chart.Use3D = false;
        }
        else if (dashboardType == "Pie:PiesNested")
        {
            chart.Type = ChartType.PiesNested;
            chart.Use3D = false;
        }
        else if (dashboardType == "Pie:Donuts")
        {
            chart.Type = ChartType.Donuts;
            chart.Use3D = false;
        }
        else if (dashboardType == "Gauge")
        {
            chart.Type = ChartType.Gauges;
            chart.Use3D = true;
            chart.ClipGauges = false;
        }
        else if (dashboardType == "Bubble")
            chart.Type = ChartType.Bubble;
        else if (dashboardType == "Scatter")
            chart.Type = ChartType.Scatter;
        else if (dashboardType == "Basic:Vertical")
        {
            chart.Type = ChartType.Combo;
            chart.Use3D = true;
        }
        else if (dashboardType == "Basic:Vertical:Stacked")
        {
            chart.Type = ChartType.Combo;
            chart.Use3D = true;
            chart.YAxis.Scale = Scale.Stacked;
        }
        else if (dashboardType == "Basic:Vertical:FullStacked")
        {
            chart.Type = ChartType.Combo;
            chart.Use3D = true;
            chart.YAxis.Scale = Scale.FullStacked;
        }
        else if (dashboardType == "Basic:Horizontal")
        {
            chart.Type = ChartType.Combo;
            chart.Type = ChartType.ComboHorizontal;
            chart.Use3D = true;
        }
        else if (dashboardType == "Basic:Horizontal:Stacked")
        {
            chart.Type = ChartType.Combo;
            chart.Type = ChartType.ComboHorizontal;
            chart.Use3D = true;
            chart.XAxis.Scale = Scale.Stacked;
        }
        else if (dashboardType == "Basic:Horizontal:FullStacked")
        {
            chart.Type = ChartType.Combo;
            chart.Type = ChartType.ComboHorizontal;
            chart.Use3D = true;
            chart.XAxis.Scale = Scale.FullStacked;
        }
        else if (dashboardType == "Radar:Spider")
        {
            chart.Type = ChartType.Radar;
            chart.XAxis.RadarMode = RadarMode.Spider;
        }
        else if (dashboardType == "Radar:Spider:Stacked")
        {
            chart.Type = ChartType.Radar;
            chart.XAxis.RadarMode = RadarMode.Spider;
            chart.XAxis.Scale = Scale.Stacked;
        }
        else if (dashboardType == "Radar:Spider:FullStacked")
        {
            chart.Type = ChartType.Radar;
            chart.XAxis.RadarMode = RadarMode.Spider;
            chart.XAxis.Scale = Scale.FullStacked;
        }
        else if (dashboardType == "Radar:Polar")
        {
            chart.Type = ChartType.Radar;
            chart.XAxis.RadarMode = RadarMode.Polar;
        }
        else if (dashboardType == "Radar:Polar:Stacked")
        {
            chart.Type = ChartType.Radar;
            chart.XAxis.RadarMode = RadarMode.Polar;
            chart.XAxis.Scale = Scale.Stacked;
        }
        else if (dashboardType == "Radar:Polar:FullStacked")
        {
            chart.Type = ChartType.Radar;
            chart.XAxis.RadarMode = RadarMode.Polar;
            chart.XAxis.Scale = Scale.FullStacked;
        }

        // Set the x/y-axis labels.
        //
        if (dashboardType.StartsWith("Basic") ||
            dashboardType.StartsWith("Scatter") ||
            dashboardType.StartsWith("Bubble"))
        {
            if (dashboardType.Contains("Horizontal"))
            {
                chart.YAxis.Label.Text = xAxisLabelText;
                chart.XAxis.Label.Text = yAxisLabelText;
            }
            else
            {
                chart.XAxis.Label.Text = xAxisLabelText;
                chart.YAxis.Label.Text = yAxisLabelText;
            }
        }

        // Sets the series type
        //
        if (dashboardType.StartsWith("Basic") ||
            dashboardType.StartsWith("Radar") ||
            dashboardType.StartsWith("Scatter"))
        {
            chart.DefaultSeries.Type = SeriesType.Bar;
        }

        // Set other default parameters
        //
        chart.ShadingEffect = true;
        chart.ShadingEffectMode = ShadingEffectMode.Five;
        chart.DefaultSeries.Line.Width = 2;
        chart.DefaultSeries.DefaultElement.Transparency = 20;
        //if (dashboard.SeriesColumnName != "")
            chart.DefaultElement.Hotspot.ToolTip = "%Name, %SeriesName: %Value";
        //else
            //chart.DefaultElement.Hotspot.ToolTip = "%Name: %Value";
        chart.Palette = new Color[] { 
            Color.Blue, Color.Yellow, Color.Red, Color.Green, 
            Color.Olive,Color.Orange, Color.Orchid,Color.Purple,
            Color.SpringGreen, Color.SandyBrown, Color.Pink, Color.SkyBlue, 
            Color.SeaGreen, Color.Lime, Color.Crimson, Color.Aqua };
    }


    /// <summary>
    /// Sets the series' type.
    /// </summary>
    /// <param name="s"></param>
    /// <param name="dashboard"></param>
    protected void InitializeSeries(Series s, string dashboardType)
    {
        if (dashboardType.StartsWith("Gauge"))
        {
            s.YAxis = new Axis();
            s.YAxis.MinorInterval = 5;
            s.YAxis.Line.Width = 1;
            s.YAxis.DefaultMinorTick.Line.Width = 1;
        }
    }



    /// <summary>
    /// Tries to assign the target variable to a double. If it fails,
    /// throw an exception with the specified errorMessage.
    /// </summary>
    /// <param name="v"></param>
    /// <param name="errorMessage"></param>
    /// <returns></returns>
    protected double ConvertToDouble(object v, string exceptionMessage, string columnName)
    {
        try
        {
            if (v != DBNull.Value)
                return Convert.ToDouble(v);
            else
                return 0;
        }
        catch
        {
            throw new ArgumentException(String.Format(exceptionMessage, v, columnName));
        }
    }


    /// <summary>
    /// Tries to assign the target variable to a DateTime. If it fails,
    /// throw an exception with the specified errorMessage.
    /// </summary>
    /// <param name="v"></param>
    /// <param name="exceptionMessage"></param>
    /// <returns></returns>
    protected DateTime ConvertToDateTime(object v, string exceptionMessage, string columnName)
    {
        try
        {
            if (v != DBNull.Value)
                return Convert.ToDateTime(v);
            else
                return DateTime.MinValue;
        }
        catch
        {
            throw new ArgumentException(String.Format(exceptionMessage, v, columnName));
        }
    }


    /// <summary>
    /// Constructs the series based on data in the data table.
    /// </summary>
    /// <param name="chart"
    /// <param name="dt"></param>
    /// <param name="dashboardType"
    /// <param name="xAxisColumnName"></param>
    /// <param name="yAxisColumnName"></param>
    /// <param name="seriesColumnName"></param>
    protected void ConstructSeries(dotnetCHARTING.Chart chart, 
        DataTable dt, string dashboardType, 
        string xAxisColumnName, string yAxisColumnName, string seriesColumnName)
    {
            // Find out the distinct names of all series
            // in the data source.
            //
            Hashtable hseriesNames = new Hashtable();
            List<string> seriesNames = new List<string>();
            if (seriesColumnName != "")
            {
                foreach (DataRow dr in dt.Rows)
                {
                    string seriesName = dr[seriesColumnName].ToString();
                    if (hseriesNames[seriesName] == null)
                    {
                        hseriesNames[seriesName] = 1;
                        seriesNames.Add(seriesName);
                    }
                }
            }
            else
                // Add a dummy series name here so that the loop below
                // to construct the series' data points will execute 
                // at least once.
                //
                seriesNames.Add("");

            // Construct all the series' data points and
            // pass them into the chart control.
            //
            foreach (string seriesName in seriesNames)
            {
                Series s = new Series();
                int elementCount = 0;
                foreach (DataRow dr in dt.Rows)
                {
                    if (seriesColumnName == "" ||
                        dr[seriesColumnName].ToString() == seriesName)
                    {
                        Element e = new Element();

                        if (dt.Columns[xAxisColumnName].DataType == typeof(DateTime))
                            e.XDateTime = ConvertToDateTime(dr[xAxisColumnName], Resources.Errors.Dashboard_CannotConvertToDateTime, xAxisColumnName);
                        else
                        {
                            if (dashboardType == "Scatter")
                                e.XValue = ConvertToDouble(dr[xAxisColumnName], Resources.Errors.Dashboard_CannotConvertToDouble, xAxisColumnName);
                            e.Name = dr[xAxisColumnName].ToString();
                        }

                        if (dt.Columns[yAxisColumnName].DataType == typeof(DateTime))
                            e.YDateTime = ConvertToDateTime(dr[yAxisColumnName], Resources.Errors.Dashboard_CannotConvertToDateTime, yAxisColumnName);
                        else
                            e.YValue = ConvertToDouble(dr[yAxisColumnName], Resources.Errors.Dashboard_CannotConvertToDouble, yAxisColumnName);

                        if (dashboardType == "Gauge")
                            e.Color = chart.Palette[elementCount % chart.Palette.Length];

                        s.Elements.Add(e);
                        elementCount++;
                    }
                }
                s.Name = seriesName;

                InitializeSeries(s, dashboardType);
                chart.SeriesCollection.Add(s);
                chart.Visible = true;
            }
    }


    /// <summary>
    /// Queries the database and binds the data to the dashboard.
    /// </summary>
    protected void BindData()
    {
        try
        {
            chart.GetType().GetField("d", BindingFlags.NonPublic | BindingFlags.Static).SetValue(null, true);

            // Gets the data set saved into the diskcache by the
            // spreadsheet report component. 
            //
            DataSet ds = DiskCache.GetDataSet("DragDropReportChart");
            DataTable dt = ds.Tables[1];
            string dashboardType = ds.Tables[0].Rows[0]["DashboardType"].ToString();
            string xAxisLabelText = ds.Tables[0].Rows[0]["XAxisLabelText"].ToString();
            string yAxisLabelText = ds.Tables[0].Rows[0]["YAxisLabelText"].ToString();
            string xAxisColumnName = "XAxis";
            string yAxisColumnName = "YAxis";
            string seriesColumnName = dt.Columns.Contains("ZAxis") ? "ZAxis" : "";

            // Initialize the chart
            //
            chart.LegendBox.Position = LegendBoxPosition.BottomMiddle;
            InitializeChart(chart, dashboardType, xAxisLabelText, yAxisLabelText, true);
            ConstructSeries(chart, dt, dashboardType, xAxisColumnName, yAxisColumnName, seriesColumnName);

            /*
            // Find out the distinct names of all series
            // in the data source.
            //
            Hashtable hseriesNames = new Hashtable();
            List<string> seriesNames = new List<string>();
            if (dashboard.SeriesColumnName != "")
            {
                foreach (DataRow dr in dt.Rows)
                {
                    string seriesName = dr[dashboard.SeriesColumnName].ToString();
                    if (hseriesNames[seriesName] == null)
                    {
                        hseriesNames[seriesName] = 1;
                        seriesNames.Add(seriesName);
                    }
$                }
            }
            else
                // Add a dummy series name here so that the loop below
                // to construct the series' data points will execute 
                // at least once.
                //
                seriesNames.Add("");

            // Initialize the chart
            //
            chart.LegendBox.Position = LegendBoxPosition.BottomMiddle;
            InitializeChart(chart, dashboard);

            // Construct all the series' data points and
            // pass them into the chart control.
            //
            foreach (string seriesName in seriesNames)
            {
                Series s = new Series();
                int elementCount = 0;
                foreach (DataRow dr in dt.Rows)
                {
                    if (dashboard.SeriesColumnName == "" ||
                        dr[dashboard.SeriesColumnName].ToString() == seriesName)
                    {
                        Element e = new Element();

                        if (dashboard.XAxisType == DashboardAxisType.DateTime)
                            e.XDateTime = ConvertToDateTime(dr[dashboard.XAxisColumnName], Resources.Errors.Dashboard_CannotConvertToDateTime, dashboard.XAxisColumnName);
                        else
                        {
                            if (dashboard.DashboardType == DashboardType.Scatter)
                                e.XValue = ConvertToDouble(dr[dashboard.XAxisColumnName], Resources.Errors.Dashboard_CannotConvertToDouble, dashboard.XAxisColumnName);
                            e.Name = dr[dashboard.XAxisColumnName].ToString();
                        }

                        if (dashboard.YAxisType == DashboardAxisType.DateTime)
                            e.YDateTime = ConvertToDateTime(dr[dashboard.YAxisColumnName], Resources.Errors.Dashboard_CannotConvertToDateTime, dashboard.YAxisColumnName);
                        else
                            e.YValue = ConvertToDouble(dr[dashboard.YAxisColumnName], Resources.Errors.Dashboard_CannotConvertToDouble, dashboard.YAxisColumnName);

                        if (dashboard.DashboardType == DashboardType.Gauge)
                            e.Color = chart.Palette[elementCount % chart.Palette.Length];

                        s.Elements.Add(e);
                        elementCount++;
                    }
                }
                s.Name = seriesName;

                InitializeSeries(s, dashboard);
                chart.SeriesCollection.Add(s);
                chart.Visible = true;
            }
             * */
        }
        catch (Exception ex)
        {
            chart.Visible = false;
        }
    }


    protected override void Render(HtmlTextWriter writer)
    {
        StringWriter sw = new StringWriter();
        HtmlTextWriter hw = new HtmlTextWriter(sw);
        base.Render(hw);

        writer.Write(
            sw.ToString().Replace(Page.Request.PhysicalApplicationPath.Replace("\\", "/").Replace(" ", "%20").ToLower(), "../")
            );
    }



</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <dotnetCHARTING:Chart runat="server" ID="chart" PaletteName="four"
                ShadingEffectMode="One" Width="400px" Height="400px">
            </dotnetCHARTING:Chart>
        </div>
    </form>
</body>
</html>
