<%@ Control Language="C#" ClassName="webpartDashboard" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="Anacle.UIFramework" %>
<%@ Import Namespace="dotnetCHARTING" %>

<script runat="server">
    /// <summary>
    /// Gets or sets the dashboard ID of this dashboard
    /// control. This ID refers to the ObjectID of the
    /// ODashboard object in the database.
    /// </summary>
    [Personalizable(PersonalizationScope.User)]
    public Guid DashboardID
    {
        get
        {
            if (ViewState["DashboardID"] == null)
                return new Guid();
            else
                return (Guid)ViewState["DashboardID"];
        }
        set { ViewState["DashboardID"] = value; }
    }


    /// <summary>
    /// Translates the specified text from the dashboards.resx file.
    /// </summary>
    /// <param name="text"></param>
    /// <returns></returns>
    protected string TranslateDashboardItem(string text)
    {
        string translatedText = Resources.Dashboards.ResourceManager.GetString(text);
        if (translatedText == null || translatedText == "")
            return text;
        return translatedText;
    }


    private Hashtable parameters = new Hashtable();


    protected override void CreateChildControls()
    {
        base.CreateChildControls();

        // we must construct all the controls here
        //
        Guid dashboardId = DashboardID;
        ODashboard dashboard = TablesLogic.tDashboard.Load(dashboardId);

        if (dashboard == null)
        {
            return;
        }

        // Creates all the filter controls.
        //
        bool firstControl = true;
        Table t = new Table();
        t.Width = Unit.Percentage(100);
        t.CellPadding = 0;
        t.CellSpacing = 0;

        panelDashboardControls.Controls.Add(t);
        TableRow tr = null;

        foreach (ODashboardField field in dashboard.GetDashboardFieldsInOrder())
        {
            UIFieldBase control = null;
            if (field.ControlType == (int)EnumReportControlType.MonthYear)
            {
                control = new UIFieldDateTime();
                ((UIFieldDateTime)control).SelectMonthYear = true;
            }
            else if (field.ControlType == (int)EnumReportControlType.DropdownList)
                control = new UIFieldDropDownList();
            else if (field.ControlType == (int)EnumReportControlType.RadioButtonList)
                control = new UIFieldRadioList();
            else if (field.ControlType == (int)EnumReportControlType.DateTime)
            {
                control = new UIFieldDateTime();
                ((UIFieldDateTime)control).ShowTimeControls = true;
            }
            else if (field.ControlType == (int)EnumReportControlType.Date)
            {
                control = new UIFieldDateTime();
                ((UIFieldDateTime)control).ShowTimeControls = false;
            }
            if (control != null)
            {
                control.ID = field.ControlIdentifier;
                control.EnableViewState = true;

                // Create a new cell for the control
                // and insert the control into it.
                //
                tr = new TableRow();
                tr.VerticalAlign = VerticalAlign.Middle;
                t.Rows.Add(tr);

                System.Web.UI.WebControls.Label labelCaption = new System.Web.UI.WebControls.Label();
                TableCell td = new TableCell();
                td.VerticalAlign = VerticalAlign.Middle;
                tr.Cells.Add(td);
                tr.Cells[0].Controls.Add(control);

                control.ControlInfo = field.ControlIdentifier;

                control.Caption = TranslateDashboardItem(field.ControlCaption);
                if (control.Caption.Trim() == "")
                    control.ShowCaption = false;

                control.Span = Span.Full;

                // set up validation
                //
                if (field.DataType == 0)
                    control.ValidateDataTypeCheck = false;
                else
                    control.ValidateDataTypeCheck = true;

                // create the OdbcParameter for single value controls
                //
                global::Parameter p = global::Parameter.New(field.ControlIdentifier, DbType.String, 0, null, field.ControlCaption);
                if (field.DataType == 0)
                {
                    control.ValidationDataType = ValidationDataType.String;
                    p.DataType = DbType.String;//tessa
                    p.Size = 255;
                }
                else if (field.DataType == 1)
                {
                    control.ValidationDataType = ValidationDataType.Integer;
                    p.DataType = DbType.Int32;//tessa change from System.Data.Odbc.OdbcType.Int to DbType.Int32
                    p.Size = 4;
                }
                else if (field.DataType == 2)
                {
                    control.ValidationDataType = ValidationDataType.Currency;
                    p.DataType = DbType.Decimal; //tessa
                    p.Size = 8;
                }
                else if (field.DataType == 3)
                {
                    control.ValidationDataType = ValidationDataType.Double;
                    p.DataType = DbType.Double;//tessa
                    p.Size = 8;
                }
                else if (field.DataType == 4)
                {
                    control.ValidationDataType = ValidationDataType.Date;
                    p.DataType = DbType.DateTime;//Tessa
                    p.Size = 8;
                }
                else if (field.DataType == 5)
                {
                    control.ValidationDataType = ValidationDataType.String;
                    p.DataType = DbType.Guid;//tessa
                    p.Size = 8;
                }
                if (field.ControlType == 5)
                    p.IsSingleValue = false;
                else
                    p.IsSingleValue = true;
                parameters[field.ControlIdentifier] = p;

                // attach event to dropdown list for cascading drop down
                //
                if (field.ControlType == 2)
                    ((UIFieldDropDownList)control).SelectedIndexChanged += new EventHandler(listControl_SelectedIndexChanged);
                if (field.ControlType == 3)
                    ((UIFieldRadioList)control).SelectedIndexChanged += new EventHandler(listControl_SelectedIndexChanged);
                if (field.ControlType == 7)
                    ((UIFieldDateTime)control).Control.Change += new EventHandler(dateTime_ControlChange);
                if (field.ControlType == 7)
                    ((UIFieldDateTime)control).Control.ImageClearUrl = ResolveUrl("~/images/cross.gif");
            }
        }
    }
    
    /// <summary>
    /// Here we construct all controls
    /// </summary>
    /// <param name="e"></param>
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        
    }
    
    void dateTime_ControlChange(object sender, EventArgs e)
    {
        if (sender != null)
        {
            // find the report field corresponding to this control
            //
            Guid dashboardId = DashboardID;
            ODashboard dashboard = TablesLogic.tDashboard.Load(dashboardId);
            ODashboardField field = null;
            foreach (ODashboardField dashboardField in dashboard.DashboardFields)
                if (dashboardField.ControlIdentifier == ((Control)sender).ID)
                {
                    field = dashboardField;
                    break;
                }
            //CascadeChange(dashboard, field);
            BindDashboard();
            
        }
    }
    
    
    /// ------------------------------------------------------------------
    /// <summary>
    /// Event to handle the dropdown list change to cascade the change
    /// downwards to other dropdown lists.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    /// ------------------------------------------------------------------
    void listControl_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (sender != null)
        {
            // find the report field corresponding to this control
            //
            Guid dashboardId = DashboardID;
            ODashboard dashboard = TablesLogic.tDashboard.Load(dashboardId);
            ODashboardField field = null;
            foreach (ODashboardField dashboardField in dashboard.DashboardFields)
                if (dashboardField.ControlIdentifier == ((Control)sender).ID)
                {
                    field = dashboardField;
                    break;
                }
            CascadeChange(dashboard, field);

            BindDashboard();
        }
    }


    //--------------------------------------------------------------------
    /// <summary>
    /// Cascade changes down to the next level control.
    /// </summary>
    //--------------------------------------------------------------------
    protected void CascadeChange(ODashboard dashboard, object obj)
    {
        if (obj != null)
        {
            //Rachel. Allow one control to cascade multiple controls.            
            DataList<ODashboardField> cascadedFieldList = null;

            if (obj is ODashboardField)
                cascadedFieldList = ((ODashboardField)obj).CascadeControl;
            if (cascadedFieldList == null)
                return;

            foreach (ODashboardField cascadedField in cascadedFieldList)
            {
                Control c = this.FindControl(cascadedField.ControlIdentifier);
                if (c != null)
                {
                    if (cascadedField.ObjectID != ((PersistentObject)obj).ObjectID)
                    {
                        if (c is UIFieldDropDownList)
                            BindToList(c as UIFieldDropDownList, dashboard, cascadedField);
                        else if (c is UIFieldRadioList)
                            BindToList(c as UIFieldRadioList, dashboard, cascadedField);
                    }
                }
            }
        }
    }


    /// ------------------------------------------------------------------
    /// <summary>
    /// Bind to a dropdown list
    /// </summary>
    /// <param name="c"></param>
    /// <param name="dataSource"></param>
    /// <param name="textField"></param>
    /// <param name="valueField"></param>
    /// ------------------------------------------------------------------
    protected void BindToList(UIFieldDropDownList c, ODashboard dashboard, ODashboardField field)
    {
        global::Parameter[] paramList = ConstructParameters(dashboard).ToArray();
        try
        {
            bool insertBlank = (field.IsInsertBlank == 1);
            
            if (field.IsPopulatedByQuery == 1)
                c.Bind(
                    Analysis.DoQuery(field.ListQuery, ConstructParameters(dashboard).ToArray()), field.DataTextField, field.DataValueField, insertBlank);
                
            //Rachel. Allow to populate using C#
            else if (field.IsPopulatedByQuery == 2)
            {
                if (field.CSharpMethodName != null)
                {
                    DataTable dt = GetDataTableFromCMethod(field.CSharpMethodName, paramList);
                    if (dt != null)
                        c.Bind(dt, field.DataTextField, field.DataValueField, insertBlank);
                }
            }
            else
                c.Bind(field.ConstructTextValueTable(), "Text", "Value", insertBlank);
        }
        catch (Exception ex)
        {
            c.ErrorMessage = String.Format(Resources.Errors.Report_PopulateQueryError, ex.Message);
        }
    }


    /// ------------------------------------------------------------------
    /// <summary>
    /// Bind to a radio list
    /// </summary>
    /// <param name="c"></param>
    /// <param name="dataSource"></param>
    /// <param name="textField"></param>
    /// <param name="valueField"></param>
    /// ------------------------------------------------------------------
    protected void BindToList(UIFieldRadioList c, ODashboard dashboard, ODashboardField field)
    {
        global::Parameter[] paramList = ConstructParameters(dashboard).ToArray();
        try
        {
            if (field.IsPopulatedByQuery == 1)
                c.Bind(
                    Analysis.DoQuery(field.ListQuery, ConstructParameters(dashboard).ToArray()), field.DataTextField, field.DataValueField);
            //Rachel. Allow to populate using C#
            else if (field.IsPopulatedByQuery == 2)
            {
                if (field.CSharpMethodName != null)
                {
                    DataTable dt = GetDataTableFromCMethod(field.CSharpMethodName, paramList);
                    if (dt != null)
                        c.Bind(dt, field.DataTextField, field.DataValueField);
                }
            }
            else
                c.Bind(field.ConstructTextValueTable(), "Text", "Value");
        }
        catch (Exception ex)
        {
            c.ErrorMessage = String.Format(Resources.Errors.Report_PopulateQueryError, ex.Message);
        }
    }


    public DataTable GetDataTableFromCMethod(string MethodName, global::Parameter[] paramList)
    {
        using (Connection c = new Connection())
        {
            object result = Analysis.InvokeMethod(MethodName, paramList);
            if (result is DataSet)
            {
                return ((DataSet)result).Tables[0];
            }
            if (result is DataTable)
            {
                return (DataTable)result;
            }
            return null;
        }
    }
    
    
    /// ------------------------------------------------------------------
    /// <summary>
    /// Construct the parameters to be passed in to the SQL for doing
    /// query.
    /// </summary>
    /// <param name="report"></param>
    /// <returns></returns>
    /// ------------------------------------------------------------------
    protected List<global::Parameter> ConstructParameters(ODashboard dashboard)
    {
        List<global::Parameter> paramList = new List<global::Parameter>();

        foreach (ODashboardField field in dashboard.GetDashboardFieldsInOrder())
        {
            Control c = this.FindControl(field.ControlIdentifier);
            
            if (c is UIFieldBase && !(c is UIFieldTreeList))
            {
                UIFieldBase fieldBase = c as UIFieldBase;
                if (parameters[fieldBase.ControlInfo] != null)
                {
                    global::Parameter p = parameters[fieldBase.ControlInfo] as global::Parameter;
                    p.Value = ConvertToType(p.DataType, fieldBase.ControlValue);
                    paramList.Add(p);
                }
            }
        }

        paramList.Add(global::Parameter.New("UserID", System.Data.DbType.Guid, 16, AppSession.User.ObjectID.Value));
        paramList.Add(global::Parameter.New("DashboardID", System.Data.DbType.Guid, 16, dashboard.ObjectID.Value));
        return paramList;
    }

    /// ------------------------------------------------------------------
    /// <summary>
    /// Convert object from the string type to the specified type.
    /// </summary>
    /// <param name="type"></param>
    /// <param name="x"></param>
    /// <returns></returns>
    /// ------------------------------------------------------------------
    protected object ConvertToType(DbType type, object x)
    {
        try
        {
            if (type == DbType.String)
                return x.ToString();
            else if (type == DbType.Int32)
                return Convert.ToInt32(x.ToString());
            else if (type == DbType.Decimal)
                return Convert.ToDecimal(x.ToString());
            else if (type == DbType.Double)
                return Convert.ToDouble(x.ToString());
            else if (type == DbType.DateTime)
                return Convert.ToDateTime(x.ToString());
            else if (type == DbType.Guid)
                return new Guid(x.ToString());
        }
        catch
        {
            return DBNull.Value;
        }
        return DBNull.Value;
    }


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
            Refresh();
        }
    }


    /// <summary>
    /// Binds values in the dropdown list.
    /// </summary>
    protected void BindDropValue()
    {
        Guid dashboardId = DashboardID;
        ODashboard dashboard = TablesLogic.tDashboard.Load(dashboardId);
        
        // Populates all list controls.
        //
        foreach (ODashboardField field in dashboard.DashboardFields)
        {
            Control control = this.FindControl(field.ControlIdentifier);

            if (control != null)
            {
                if (field.ControlType == (int)EnumReportControlType.DropdownList)
                    BindToList(control as UIFieldDropDownList, dashboard, field);
                else if (field.ControlType == (int)EnumReportControlType.RadioButtonList)
                    BindToList(control as UIFieldRadioList, dashboard, field);
            }
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
    /// Creates the charting interface responsible
    /// for generating the chart.
    /// </summary>
    /// <param name="dashboard"></param>
    /// <returns></returns>
    protected ChartInterface CreateChart(ODashboard dashboard)
    {
        ChartInterface chartInterface = new ChartInterface(300, 300, "temp\\charts");

        chartInterface.AutoCalibrate = dashboard.IsAutoCalibrate == 1;
        chartInterface.SeriesByColumns = dashboard.SeriesByColumns == 1;
        chartInterface.DashboardPieType =
            dashboard.DashboardPieType == DashboardPieType.Pies ? "Pies" :
            dashboard.DashboardPieType == DashboardPieType.NestedPies ? "NestedPies" :
            dashboard.DashboardPieType == DashboardPieType.Donuts ? "Donuts" : "";
        chartInterface.DashboardSeriesType =
            dashboard.DashboardSeriesType == DashboardSeriesType.AreaLine ? "AreaLine" :
            dashboard.DashboardSeriesType == DashboardSeriesType.AreaSpline ? "AreaSpline" :
            dashboard.DashboardSeriesType == DashboardSeriesType.Bar ? "Bar" :
            dashboard.DashboardSeriesType == DashboardSeriesType.Cone ? "Cone" :
            dashboard.DashboardSeriesType == DashboardSeriesType.Cylinder ? "Cylinder" :
            dashboard.DashboardSeriesType == DashboardSeriesType.Line ? "Line" :
            dashboard.DashboardSeriesType == DashboardSeriesType.Pyramid ? "Pyramid" :
            dashboard.DashboardSeriesType == DashboardSeriesType.Spline ? "Spline" : "";
        chartInterface.DashboardType =
            dashboard.DashboardType == DashboardType.Basic ? "Basic" :
            dashboard.DashboardType == DashboardType.Bubble ? "Bubble" :
            dashboard.DashboardType == DashboardType.Gauge ? "Gauge" :
            dashboard.DashboardType == DashboardType.Grid ? "Grid" :
            dashboard.DashboardType == DashboardType.Pie ? "Pie" :
            dashboard.DashboardType == DashboardType.Polar ? "Polar" :
            dashboard.DashboardType == DashboardType.Radar ? "Radar" :
            dashboard.DashboardType == DashboardType.Scatter ? "Scatter" : "";
        chartInterface.SeriesColumnName = dashboard.SeriesColumnName;
        chartInterface.Show3D = dashboard.Dashboard3D == 1;
        chartInterface.ShowHorizontal = dashboard.DashboardShowHorizontal == 1;
        chartInterface.XAxisColumnName = dashboard.XAxisColumnName;
        chartInterface.XAxisLabelText = dashboard.XAxisLabelText;
        chartInterface.XAxisType =
            dashboard.XAxisType == DashboardAxisType.DateTime ? "DateTime" :
            dashboard.XAxisType == DashboardAxisType.FullStacked ? "FullStacked" :
            dashboard.XAxisType == DashboardAxisType.Normal ? "Normal" :
            dashboard.XAxisType == DashboardAxisType.Stacked ? "Stacked" : "";
        chartInterface.YAxisColumnName = dashboard.YAxisColumnName;
        chartInterface.YAxisLabelText = dashboard.YAxisLabelText;
        chartInterface.YAxisType =
            dashboard.YAxisType == DashboardAxisType.DateTime ? "DateTime" :
            dashboard.YAxisType == DashboardAxisType.FullStacked ? "FullStacked" :
            dashboard.YAxisType == DashboardAxisType.Normal ? "Normal" :
            dashboard.YAxisType == DashboardAxisType.Stacked ? "Stacked" : "";
        chartInterface.YAxisMaximum = dashboard.YAxisMaximum == null ? 0M : dashboard.YAxisMaximum.Value;
        chartInterface.YAxisMinimum = dashboard.YAxisMinimum == null ? 0M : dashboard.YAxisMinimum.Value;
        chartInterface.YAxisInterval = dashboard.YAxisInterval == null ? 0M : dashboard.YAxisInterval.Value;
        chartInterface.SizeColumnName = dashboard.SizeColumnName;

        return chartInterface;
    }


    /// <summary>
    /// Queries the database and binds the data to the dashboard.
    /// </summary>
    protected void BindDashboard()
    {
        try
        {
            ODashboard dashboard = TablesLogic.tDashboard.Load(DashboardID);
            if (dashboard != null)
            {
                // Runs the query against the database and gets
                // the result as a DataTable.
                //
                DataTable dt = null;
                List<global::Parameter> paramList = ConstructParameters(dashboard);
                if (dashboard.UseCSharpQuery == 0 || dashboard.UseCSharpQuery == null)
                {
                    dt = Analysis.DoQuery(dashboard.DashboardQuery, paramList.ToArray());
                }
                else
                {
                    object dataSource = Analysis.InvokeMethod(dashboard.CSharpMethodName, paramList.ToArray());
                    if (dataSource is DataTable)
                        dt = (DataTable)dataSource;
                    else if (dataSource is DataSet)
                        dt = ((DataSet)dataSource).Tables[0];
                }

                if (dashboard.DashboardType == DashboardType.Grid)
                {
                    // kf begin: bug fix
                    gridResults.DataSource = dt;
                    gridResults.DataBind();
                    gridResults.Visible = true;
                    literalChart.Visible = false;
                    panelMessage.Visible = false;
                }
                else
                {
                    ChartInterface chartInterface = CreateChart(dashboard);
                    chartInterface.DataSource = dt;
                    chartInterface.DataBind();
                    literalChart.Text = chartInterface.RenderOutput();

                    gridResults.Visible = false;
                    literalChart.Visible = true;
                    panelMessage.Visible = false;
                }
            }
        }
        catch (Exception ex)
        {
            gridResults.Visible = false;
            literalChart.Visible = false;
            panelMessage.Visible = true;
            labelMessage.Text = ex.Message;
        }
    }


    /// <summary>
    /// Refreshes the dashboard chart and the drop down list.
    /// </summary>
    public void Refresh()
    {
        try
        {
            BindDropValue();
            BindDashboard();
        }
        catch (Exception ex)
        {
            gridResults.Visible = false;
            panelMessage.Visible = true;
            labelMessage.Text = ex.Message;
        }

    }

    
    /// <summary>
    /// Refreshes the dashboard chart.
    /// </summary>
    public void RefreshChart()
    {
        try
        {
            BindDashboard();
        }
        catch (Exception ex)
        {
            gridResults.Visible = false;
            panelMessage.Visible = true;
            labelMessage.Text = ex.Message;
        }

    }

</script>

<ui:UIPanel runat="server" ID="panelDashboardMain">
    <ui:UIPanel runat="server" ID="panelDashboardControls">
    </ui:UIPanel>
    <asp:Panel runat="serveR" ID="panelDashboard" Width="300px" HorizontalAlign="center">
        <asp:Literal runat="server" ID="literalChart" Visible="false" />
        <asp:GridView runat="server" ID="gridResults" AutoGenerateColumns="true" Width="100%"
            Visible='false' EmptyDataText="No Data">
        </asp:GridView>
        <asp:Panel runat="server" ID="panelMessage">
            <asp:Label runat="server" ID="labelMessage"></asp:Label>
        </asp:Panel>
    </asp:Panel>
</ui:UIPanel>
