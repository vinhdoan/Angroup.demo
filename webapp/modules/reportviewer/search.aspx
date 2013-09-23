<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource3"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Resources" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
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



    /// <summary>
    /// Occurs whenever the page is rendered.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        //if it is a static report, hide the panel too
        OReport report = TablesLogic.tReport[Security.DecryptGuid(Request["ID"])];
        if (report != null)
        {
            if (report.ReportType == 1)
            {
                this.checkUseTemplate.Visible = true;
                this.Sep1.Visible = true;
            }
            else
            {
                this.checkUseTemplate.Visible = false;
                this.Sep1.Visible = false;
            }
        }

    }
    private Hashtable parameters = new Hashtable();

    /// <summary>
    /// Translates the text in a report field.
    /// </summary>
    /// <param name="listItems"></param>
    /// <param name="?"></param>
    protected void TranslateListControlText(ListItemCollection listItems, OReportField field)
    {
        string resourceAssemblyName = field.ResourceAssemblyName;
        Assembly asm;
        if (resourceAssemblyName == null || resourceAssemblyName.Trim() == "")
            asm = Assembly.Load("App_GlobalResources");
        else
            asm = Assembly.Load(resourceAssemblyName);
        if (asm != null && field.ResourceName != null)
        {
            ResourceManager rm = new ResourceManager(field.ResourceName, asm);
            foreach (ListItem item in listItems)
            {
                string translatedText = "";
                try
                {
                    translatedText = rm.GetString(item.Text, System.Threading.Thread.CurrentThread.CurrentUICulture);
                }
                catch (Exception ex)
                {
                }
                if (translatedText != null && translatedText != "")
                    item.Text = translatedText;
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
    protected void BindToList(UIFieldDropDownList c, OReport report, OReportField field)
    {
        global::Parameter[] paramList = ConstructParameters(report).ToArray();
        try
        {
            bool insertBlank = (field.IsInsertBlank == (int)EnumApplicationGeneral.Yes);

            if (field.IsPopulatedByQuery == (int)EnumReportFieldPopulateWith.Query)
                c.Bind(
                    Analysis.DoQuery(field.ListQuery, ConstructParameters(report).ToArray()), field.DataTextField, field.DataValueField, insertBlank);
            //Rachel. Allow to populate using C#
            else if (field.IsPopulatedByQuery == (int)EnumReportFieldPopulateWith.CSharpMethod)
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
        TranslateListControlText(c.Items, field);
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
    protected void BindToList(UIFieldRadioList c, OReport report, OReportField field)
    {
        global::Parameter[] paramList = ConstructParameters(report).ToArray();
        try
        {
            if (field.IsPopulatedByQuery == 1)
                c.Bind(
                    Analysis.DoQuery(field.ListQuery, ConstructParameters(report).ToArray()), field.DataTextField, field.DataValueField);
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
        TranslateListControlText(c.Items, field);
    }


    /// ------------------------------------------------------------------
    /// <summary>
    /// Bind to a multi-select list box.
    /// </summary>
    /// <param name="c"></param>
    /// <param name="report"></param>
    /// <param name="field"></param>
    /// ------------------------------------------------------------------
    protected void BindToList(UIFieldListBox c, OReport report, OReportField field)
    {
        global::Parameter[] paramList = ConstructParameters(report).ToArray();
        try
        {
            if (field.IsPopulatedByQuery == (int)EnumReportFieldPopulateWith.Query)
                c.Bind(
                    Analysis.DoQuery(field.ListQuery, ConstructParameters(report).ToArray()), field.DataTextField, field.DataValueField);
            //Rachel. Allow to populate using C#
            else if (field.IsPopulatedByQuery == (int)EnumReportFieldPopulateWith.CSharpMethod)
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
            c.ErrorMessage = String.Format(Resources.Errors.Report_PopulateQueryError, ex.Message + ex.StackTrace);
        }
        TranslateListControlText(c.Items, field);
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

    /// ------------------------------------------------------------------
    /// <summary>
    /// Construct the parameters to be passed in to the SQL for doing
    /// query.
    /// </summary>
    /// <param name="report"></param>
    /// <returns></returns>
    /// ------------------------------------------------------------------
    protected List<global::Parameter> ConstructParameters(OReport report)
    {
        List<global::Parameter> paramList = new List<global::Parameter>();
        DateTime? startPeriod = null;
        DateTime? endPeriod = null;

        //Save parameter into the SEssion for the system to display selected parameter
        //Build an arraylist for the report parameter. Each record of the param include an array string, with 2 items, first item is the caption name of the filter, second item is the selected value
        ArrayList paramHash = new ArrayList();
        //Rachel. we base by the report list rather than search by control as we need to ensure the paramHash table shown in correct order     

        foreach (OReportField field in report.GetReportFieldsInOrder())
        {
            Control c = tabSearch.FindControl(field.ControlIdentifier);
            //do not set param based on report template drop or use template checkbox
            if (c.ID == "TemplateDetails_Template" || c.ID == "UseTemplate")
                continue;

            //if (c is UIFieldBase && !(c is UIFieldTreeUrl))
            if (c is UIFieldBase)
            {
                UIFieldBase fieldBase = c as UIFieldBase;
                if (parameters[fieldBase.ControlInfo] != null)
                {
                    global::Parameter p = parameters[fieldBase.ControlInfo] as global::Parameter;
                    if (!(fieldBase is UIFieldListBox))
                    {
                        p.Value = ConvertToType(p.DataType, fieldBase.ControlValue);
                        if (p.DataType == DbType.DateTime && fieldBase.ControlValue != null)
                        {
                            if (field.ControlType == (int)EnumReportControlType.DateTime)
                                p.Value = (object)Convert.ToDateTime(fieldBase.ControlValue.ToString()).ToString("dd-MMM-yyyy HH:mm");
                            if (field.ControlType == (int)EnumReportControlType.MonthYear)
                                p.Value = (object)Convert.ToDateTime(fieldBase.ControlValue.ToString()).ToString("MMMM-yyyy");
                            if (field.ControlType == (int)EnumReportControlType.Date)
                                p.Value = (object)Convert.ToDateTime(fieldBase.ControlValue.ToString()).ToString("dd-MMM-yyyy");
                        }
                        //else
                        //    p.Value = ConvertToType(p.DataType, fieldBase.ControlValue);

                        //save into the paramHash table to display the filtering criteria on Report page
                        if (fieldBase is UIFieldCheckBox)
                        {
                            if (((UIFieldCheckBox)fieldBase).Checked)
                                paramHash.Add(GetParamDisplay(p.ParameterDisplay, EnumApplicationGeneral.Yes.ToString()));
                            else
                                paramHash.Add(GetParamDisplay(p.ParameterDisplay, EnumApplicationGeneral.No.ToString()));
                        }
                        //drop down list, we will use the text of selected item
                        else if (fieldBase is UIFieldCheckboxList && ((UIFieldCheckboxList)fieldBase).SelectedItem != null && ((UIFieldCheckboxList)fieldBase).SelectedItem.Text != "")
                        {
                            paramHash.Add(GetParamDisplay(p.ParameterDisplay, ((UIFieldCheckboxList)fieldBase).SelectedItem.Text));

                        }
                        else if (fieldBase is UIFieldDropDownList && ((UIFieldDropDownList)fieldBase).SelectedItem != null && ((UIFieldDropDownList)fieldBase).SelectedItem.Text != "")
                        {
                            paramHash.Add(GetParamDisplay(p.ParameterDisplay, ((UIFieldDropDownList)fieldBase).SelectedItem.Text));
                        }
                        else if (fieldBase is UIFieldRadioList && ((UIFieldRadioList)fieldBase).SelectedItem != null && ((UIFieldRadioList)fieldBase).SelectedItem.Text != "")
                        {
                            paramHash.Add(GetParamDisplay(p.ParameterDisplay, ((UIFieldRadioList)fieldBase).SelectedItem.Text));
                        }

                        else if (fieldBase is UIFieldTreeList && ((UIFieldTreeList)fieldBase).SelectedValue.ToString() != "")
                            paramHash.Add(GetParamDisplay(p.ParameterDisplay, ((UIFieldTreeList)fieldBase).SelectedItemPath));
                        else if (p.Value != null && p.Value.ToString().Trim() != "")//for other case like datetime, text box
                            paramHash.Add(GetParamDisplay(p.ParameterDisplay, p.Value.ToString()));
                    }
                    else
                    {
                        List<object> list1 = (List<object>)fieldBase.ControlValue;
                        List<object> list2 = new List<object>();
                        //save into the paramHash table to display the filtering criteria on Report page
                        StringBuilder listValue = new StringBuilder();
                        if (list1 != null)
                        {
                            foreach (object o in list1)
                            {
                                list2.Add(ConvertToType(p.DataType, o));
                                //grab the selected text
                                listValue.Append(((UIFieldListBox)fieldBase).Items.FindByValue(o.ToString()).Text);
                                listValue.Append("; ");
                            }
                            paramHash.Add(GetParamDisplay(p.ParameterDisplay, listValue.ToString()));
                        }
                        p.List = list2;

                    }
                    paramList.Add(p);
                }
            }
        }

        if (report.ContextTree != 0 && tree != null)
        {
            Guid? id = null;
            if (tree.SelectedValue != "")
                id = new Guid(tree.SelectedValue);

            global::Parameter p = global::Parameter.New(
                tree.ControlInfo, DbType.Guid, 16, id, tree.ControlInfo);

            if (tree.SelectedNode != null)
                paramHash.Add(GetParamDisplay(p.ParameterDisplay, tree.SelectedItemPath));

            paramList.Add(p);
        }

        paramList.Add(global::Parameter.New("UserID", System.Data.DbType.Guid, 16, AppSession.User.ObjectID.Value));
        paramList.Add(global::Parameter.New("ReportID", System.Data.DbType.Guid, 16, report.ObjectID.Value));

        Session["ReportParametersDisplay"] = paramHash;

        return paramList;
    }

    protected string GetParamDisplay(string paramName, string paramValue)
    {
        return TranslateReportItem(paramName) + ": " + paramValue;
    }


    /// <summary>
    /// Cached copy of the report object that is initialized
    /// in the OnPreInit event. This is used by the 
    /// AcquireTreePopulater to construct the correct
    /// tree populater.
    /// </summary>
    OReport cachedReport = null;

    /// <summary>
    /// The tree list control.
    /// </summary>
    UIFieldTreeList tree;
    OReportField reportfield = null;

    /// ------------------------------------------------------------------
    /// <summary>
    /// Here we construct all controls
    /// </summary>
    /// <param name="e"></param>
    /// ------------------------------------------------------------------
    protected override void OnPreInit(EventArgs e)
    {
        base.OnPreInit(e);
        // we must construct all the controls here
        //
        Guid reportId = Security.DecryptGuid(Request["ID"]);
        OReport report = TablesLogic.tReport[reportId];
        cachedReport = report;

        if (report == null)
        {
            labelReportInvalid.Visible = true;
            panel.Visible = false;
            tabstripSearch.Visible = false;
            return;
        }

        panel.Caption = TranslateReportItem(report.ReportName);

        // Creates the treeview control.
        //
        if (report.ContextTree != 0)
        {
            tree = new UIFieldTreeList();
            tree.ID = "contextTreeView";
            tree.ControlInfo = "TreeviewID";
            tree.Caption = Resources.Strings.Report_SelectTree;
            tree.AcquireTreePopulater += new UITreeList.TreePopulaterEventHandler(tree_AcquireTreePopulater);
            tabSearch.Controls.Add(tree);
        }

        // Creates all the filter controls.
        //
        bool firstControl = true;
        Table t = new Table();
        t.Width = Unit.Percentage(100);
        t.CellPadding = 0;
        t.CellSpacing = 0;

        // Add a separator may solve incorrect layout problem in safari by KNX
        // UISeparator sep = new UISeparator();        
        // tabSearch.Controls.Add(sep);

        tabSearch.Controls.Add(t);
        TableRow tr = null;

        foreach (OReportField field in report.GetReportFieldsInOrder())
        {
            UIFieldBase control = null;

            if (field.ControlType == (int)EnumReportControlType.TexBox)
                control = new UIFieldTextBox();
            else if (field.ControlType == (int)EnumReportControlType.DateTime)
            {
                control = new UIFieldDateTime();

                // 2010.07.23
                // Kim Foong
                // Bug fix to show time controls, as the default for time
                // controls is 'false'.
                //
                ((UIFieldDateTime)control).ShowTimeControls = true;
            }
            else if (field.ControlType == (int)EnumReportControlType.MonthYear)
            {
                control = new UIFieldDateTime();
                ((UIFieldDateTime)control).SelectMonthYear = true;
            }
            else if (field.ControlType == (int)EnumReportControlType.Date)
            {
                control = new UIFieldDateTime();
                ((UIFieldDateTime)control).ShowTimeControls = false;
            }
            else if (field.ControlType == (int)EnumReportControlType.DropdownList)
            {
                control = new UIFieldDropDownList();
            }
            else if (field.ControlType == (int)EnumReportControlType.RadioButtonList)
            {
                control = new UIFieldRadioList();
            }
            else if (field.ControlType == (int)EnumReportControlType.MultiSelectList)
            {
                control = new UIFieldListBox();
                ((UIFieldListBox)control).Rows = 6;
            }
            else if (field.ControlType == (int)EnumReportControlType.ContextTree)
            {
                control = new UIFieldTreeList();
                ((UIFieldTreeList)control).Control.BorderStyle = BorderStyle.None;
                ((UIFieldTreeList)control).Control.BorderWidth = Unit.Pixel(field.ContextTree.Value);
                reportfield = field;
                ((UIFieldTreeList)control).AcquireTreePopulater += new UITreeList.TreePopulaterEventHandler(treeview_AcquireTreePopulater);
            }
            else if (field.ControlType == (int)EnumReportControlType.Checkbox)
            {
                control = new UIFieldCheckBox();
                
            }

            if (control != null)
            {
                control.ID = field.ControlIdentifier;
                control.EnableViewState = true;

                // Apply the hint to the control
                //
                control.Hint = field.ControlHint;

                // Create a new cell for the control
                // and insert the control into it.
                //
                if (firstControl || field.ControlSpan == 1)
                {
                    tr = new TableRow();
                    tr.VerticalAlign = VerticalAlign.Middle;
                    t.Rows.Add(tr);

                    TableCell td = new TableCell();
                    td.VerticalAlign = VerticalAlign.Middle;
                    tr.Cells.Add(td);
                    tr.Cells[0].Controls.Add(control);

                    // If the control is a full-span, then set
                    // the column span to 2.
                    //
                    if (field.ControlSpan == 1)
                    {
                        tr.Cells[0].ColumnSpan = 2;
                        firstControl = true;
                    }
                    else
                        firstControl = !firstControl;
                }
                else
                {
                    TableCell td = new TableCell();
                    td.VerticalAlign = VerticalAlign.Middle;
                    tr.Cells.Add(td);
                    tr.Cells[1].Controls.Add(control);
                    tr.Cells[0].Width = Unit.Percentage(50);
                    tr.Cells[1].Width = Unit.Percentage(50);
                    firstControl = !firstControl;
                }

                control.ControlInfo = field.ControlIdentifier;

                control.Caption = TranslateReportItem(field.ControlCaption);
                control.Span = Span.Full;

                // set up validation:
                // We do not validate if the data type is a string,
                // and if the control is a list box / tree view. 
                //
                if (field.DataType == (int)EnumReportDataType.String || 
                    field.ControlType == (int)EnumReportControlType.MultiSelectList || 
                    field.ControlType == (int)EnumReportControlType.ContextTree ||
                    field.ControlType == (int)EnumReportControlType.Checkbox)
                    control.ValidateDataTypeCheck = false;
                else
                    control.ValidateDataTypeCheck = true;

                // create the OdbcParameter for single value controls
                //
                global::Parameter p = global::Parameter.New(field.ControlIdentifier, DbType.String, 0, null, field.ControlCaption);
                if (field.DataType == (int)EnumReportDataType.String)
                {
                    control.ValidationDataType = ValidationDataType.String;
                    p.DataType = DbType.String;//tessa
                    p.Size = 255;
                }
                else if (field.DataType == (int)EnumReportDataType.Integer)
                {
                    control.ValidationDataType = ValidationDataType.Integer;
                    p.DataType = DbType.Int32;//tessa change from System.Data.Odbc.OdbcType.Int to DbType.Int32
                    p.Size = 4;
                }
                else if (field.DataType == (int)EnumReportDataType.Decimal)
                {
                    control.ValidationDataType = ValidationDataType.Currency;
                    p.DataType = DbType.Decimal; //tessa
                    p.Size = 8;
                }
                else if (field.DataType == (int)EnumReportDataType.Double)
                {
                    control.ValidationDataType = ValidationDataType.Double;
                    p.DataType = DbType.Double;//tessa
                    p.Size = 8;
                }
                else if (field.DataType == (int)EnumReportDataType.DateTime)
                {
                    control.ValidationDataType = ValidationDataType.Date;
                    p.DataType = DbType.DateTime;//Tessa
                    p.Size = 8;
                }
                else if (field.DataType == (int)EnumReportDataType.UniqueIdentifier)
                {
                    control.ValidationDataType = ValidationDataType.String;
                    p.DataType = DbType.Guid;//tessa
                    p.Size = 8;
                }
                if (field.ControlType == (int)EnumReportControlType.MultiSelectList)
                    p.IsSingleValue = false;
                else
                    p.IsSingleValue = true;
                parameters[field.ControlIdentifier] = p;

                // Set the required field validation.
                //
                control.ValidateRequiredField = (field.IsRequiredField == (int)EnumApplicationGeneral.Yes);

                // attach event to dropdown list for cascading drop down
                //
                if (field.CascadeControl.Count > 0)
                {
                    if (field.ControlType == (int)EnumReportControlType.DropdownList)
                        ((UIFieldDropDownList)control).SelectedIndexChanged += new EventHandler(listControl_SelectedIndexChanged);
                    if (field.ControlType == (int)EnumReportControlType.RadioButtonList)
                        ((UIFieldRadioList)control).SelectedIndexChanged += new EventHandler(listControl_SelectedIndexChanged);
                    if (field.ControlType == (int)EnumReportControlType.MultiSelectList)
                        ((UIFieldListBox)control).SelectedIndexChanged += new EventHandler(report_search_aspx_SelectedIndexChanged);
                }
            }
        }
    }


    /// <summary>
    /// Constructs the tree populater based on the context tree value.
    /// </summary>
    /// <returns></returns>
    TreePopulater ConstructTreePopulater(int contextTree)
    {
        List<string> roleCodes = null;
        if (contextTree == (int)EnumReportContextTree.Equipment || 
            contextTree == (int)EnumReportContextTree.Location || 
            contextTree == (int)EnumReportContextTree.LocationAndEquipment)
        {
            roleCodes = new List<string>();
            foreach (ORole role in cachedReport.Roles)
                roleCodes.Add(role.RoleCode);
        }

        if (contextTree == (int)EnumReportContextTree.Checklist)
            return new ChecklistTreePopulater(null, true, true);
        else if (contextTree == (int)EnumReportContextTree.Code)
            return new CodeTreePopulater(null);
        else if (contextTree == (int)EnumReportContextTree.CodeType)
            return new CodeTypeTreePopulater(null);
        else if (contextTree == (int)EnumReportContextTree.Equipment)
            return new EquipmentTreePopulater(null, true, true, roleCodes);
        else if (contextTree == (int)EnumReportContextTree.EquipmentType)
            return new EquipmentTypeTreePopulater(null, true);
        else if (contextTree == (int)EnumReportContextTree.Location)
            return new LocationTreePopulater(null, true, true, roleCodes);
        else if (contextTree == (int)EnumReportContextTree.LocationType)
            return new LocationTypePopulater(null, true);
        else if (contextTree == (int)EnumReportContextTree.LocationAndEquipment)
            return new LocationEquipmentTreePopulater(null, true, true, true, roleCodes);
        else if (contextTree == (int)EnumReportContextTree.ServiceCatalog)
            return new FixedRateTreePopulater(null, true, true);
        else if (contextTree == (int)EnumReportContextTree.Account)
            return new AccountTreePopulater(null);
        else if (contextTree == (int)EnumReportContextTree.InventoryCatalog)
            return new CatalogueTreePopulater(null, true, false, true, true);
        return null;
    }


    /// <summary>
    /// Constructs and returns the tree view populater, depending
    /// on the type of the context tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    TreePopulater tree_AcquireTreePopulater(object sender)
    {
        if (cachedReport.ContextTree != null)
        {
            int contextTree = cachedReport.ContextTree.Value;
            return ConstructTreePopulater(contextTree);
        }
        return null;

    }


    /// <summary>
    /// Constructs and returns the tree view populater, depending
    /// on the type of the context tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    TreePopulater treeview_AcquireTreePopulater(object sender)
    {
        UITreeList tree = sender as UITreeList;
        int contextTree = Convert.ToInt32(tree.BorderWidth.Value);

        return ConstructTreePopulater(contextTree);
    }

    /// ------------------------------------------------------------------
    /// <summary>
    /// Here we populate all dropdown/radiolist controls
    /// </summary>
    /// <param name="e"></param>
    /// ------------------------------------------------------------------
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        // set up the data text/value field for list controls
        //
        if (!IsPostBack)
        {
            Guid reportId = Security.DecryptGuid(Request["ID"]);
            OReport report = TablesLogic.tReport[reportId];
            if (report == null)
                return;

            // Populates the tree list for the first time.
            //
            if (report.ContextTree != 0)
                tree.PopulateTree();

            // Populates all list controls.
            //
            foreach (OReportField field in report.ReportFields)
            {
                Control control = this.FindControl(field.ControlIdentifier);

                if (control != null)
                {
                    if (field.ControlType == (int)EnumReportControlType.DropdownList)
                        BindToList(control as UIFieldDropDownList, report, field);
                    else if (field.ControlType == (int)EnumReportControlType.RadioButtonList)
                        BindToList(control as UIFieldRadioList, report, field);
                    else if (field.ControlType == (int)EnumReportControlType.MultiSelectList)
                        BindToList(control as UIFieldListBox, report, field);
                    else if (field.ControlType == (int)EnumReportControlType.ContextTree)
                        (control as UIFieldTreeList).PopulateTree();
                }
            }

            PopulateTemplateDetails(Security.DecryptGuid(Request["ID"]));

        }

    }
    
    /// <summary>
    /// 
    /// </summary>
    /// <param name="reportId"></param>
    protected void PopulateTemplateDetails(Guid reportId)
    {
        //populate template info
        List<OReportTemplate> templates = OReportTemplate.GetViewableReportTemplates(reportId, (Guid)AppSession.User.ObjectID);
        TemplateDetails_Template.Bind(templates);
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
            Guid reportId = Security.DecryptGuid(Request["ID"]);
            OReport report = TablesLogic.tReport[reportId];
            OReportField field = null;
            foreach (OReportField reportField in report.ReportFields)
                if (reportField.ControlIdentifier == ((Control)sender).ID)
                {
                    field = reportField;
                    break;
                }
            CascadeChange(field);
        }
    }

    protected void ClearTemplateSession()
    {
        Session["ReportDataSource"] = null;
        Session["ReportID"] = null;
        Session["ReportTemplateID"] = null;
    }

    /// ------------------------------------------------------------------
    /// <summary>
    /// Panel search.
    /// </summary>
    /// <param name="e"></param>
    /// ------------------------------------------------------------------
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        try
        {
            ClearTemplateSession();
            //delete existing template session value
            if (checkUseTemplate.Checked && TemplateDetails_Template.SelectedIndex == 0)
            {
                panel.Message = Resources.Errors.Report_SelectTemplate;
                return;
            }

            Guid reportId = Security.DecryptGuid(Request["ID"]);
            OReport report = TablesLogic.tReport[reportId];
            Session["ReportID"] = reportId;
            List<global::Parameter> paramList = ConstructParameters(report);

            if (checkUseTemplate.Checked)
            {
                OReportTemplate temp = null;
                if (TemplateDetails_Template.SelectedIndex != 0)
                {
                    Session["ReportTemplateID"] = TemplateDetails_Template.SelectedValue;
                    temp = TablesLogic.tReportTemplate.Load(new Guid(TemplateDetails_Template.SelectedValue));
                }
                else
                    Session["ReportTemplateID"] = null;

                //taking the template name as report name
                if (temp != null)
                    Session["ReportCaption"] = TranslateReportItem(temp.ObjectName);
                else
                    Session["ReportCaption"] = TranslateReportItem(report.ReportName);

                //for dynamic report / spreadsheet report, i.e when template is not specified, or the template type is not rdl/rpt
                if (temp == null || temp.RdlBytes == null)
                {
                    // KF BEGIN
                    //Session["ReportDataSource"] = null;
                    DiskCache.Remove("ReportDataSourceType");
                    DiskCache.Remove("ReportDataSource");
                    DataTable dt = null;
                    if (report.UseCSharpQuery == (int)EnumApplicationGeneral.No || 
                        report.UseCSharpQuery == null)
                    {
                        dt = Analysis.DoQuery(report.ReportQuery, paramList.ToArray());
                        //Session["ReportDataSource"] = dt;
                        DiskCache.Add("ReportDataSourceType", "DataTable");
                        DiskCache.Add("ReportDataSource", (DataTable)dt);
                    }
                    else
                    {
                        using (Connection c = new Connection())
                        {
                            object result = Analysis.InvokeMethod(report.CSharpMethodName, paramList.ToArray());

                            if (result is DataSet)
                            {
                                //Rachel. Update display column name
                                OReport.UpdateTableColumnName((DataSet)result);
                                OReport.RemoveDataTableColumn((DataSet)result);
                                DiskCache.Add("ReportDataSourceType", "DataSet");
                                DiskCache.Add("ReportDataSource", (DataSet)result);
                            }
                            if (result is DataTable)
                            {
                                //Rachel. Update display column name
                                OReport.UpdateTableColumnName((DataTable)result);
                                OReport.RemoveDataTableColumn((DataTable)result);
                                DiskCache.Add("ReportDataSourceType", "DataTable");
                                DiskCache.Add("ReportDataSource", (DataTable)result);
                            }
                            c.Commit();
                        }
                    }

                    //Set visible column at start
                    if (DiskCache.ContainsKey("ReportDataSource"))
                    {
                        //plus 2 column (first two column for grouping)
                        if (report.VisibleColumnAtStart != null)
                            Window.Open("report.aspx?VisibleColumnAtStart=" + HttpUtility.UrlEncode(Security.Encrypt((report.VisibleColumnAtStart.Value + 2).ToString())), "AnacleEAM_Report");
                        else
                            Window.Open("report.aspx", "AnacleEAM_Report");
                    }
                    // KF END
                }
                else
                {
                    if (temp.TemplateType == (int)TemplateTypeName.rdlreport)
                    {
                        Session["ReportParameter"] = paramList.ToArray();
                        Window.Open("reportviewer.aspx", "AnacleEAM_Report");
                    }
                    else if (temp.TemplateType == (int)TemplateTypeName.crystalreport)
                    {
                        Session["ReportParameter"] = paramList.ToArray();
                        Window.Open("crystalreportviewer.aspx", "AnacleEAM_Report");
                    }
                }
            }
            else //don't use template
            {
                if (report.ReportType == 1) //spreadsheet report 
                {
                    Session["ReportCaption"] = TranslateReportItem(report.ReportName);
                    if (checkUseTemplate.Checked)
                        Session["ReportTemplateID"] = TemplateDetails_Template.SelectedValue;
                    else
                        Session["ReportTemplateID"] = null;

                    // KF BEGIN
                    //Session["ReportDataSource"] = null;
                    DiskCache.Remove("ReportDataSourceType");
                    DiskCache.Remove("ReportDataSource");
                    DataTable dt = null;
                    if (report.UseCSharpQuery == 0 || report.UseCSharpQuery == null)
                    {
                        dt = Analysis.DoQuery(report.ReportQuery, paramList.ToArray());
                        //Session["ReportDataSource"] = dt;
                        DiskCache.Add("ReportDataSourceType", "DataTable");
                        DiskCache.Add("ReportDataSource", (DataTable)dt);
                    }
                    else
                    {
                        using (Connection c = new Connection())
                        {
                            object result = Analysis.InvokeMethod(report.CSharpMethodName, paramList.ToArray());

                            if (result is DataSet)
                            {
                                if (checkUseTemplate.Checked)
                                {
                                    DiskCache.Add("ReportDataSourceType", "DataSet");
                                    DiskCache.Add("ReportDataSource", (DataSet)result);
                                }
                                else
                                {
                                    DataSet ds = (DataSet)result;

                                    DiskCache.Add("ReportDataSourceType", "DataTable");
                                    DiskCache.Add("ReportDataSource", (DataTable)ds.Tables[0]);
                                }
                            }
                            if (result is DataTable)
                            {
                                DiskCache.Add("ReportDataSourceType", "DataTable");
                                DiskCache.Add("ReportDataSource", (DataTable)result);
                            }
                            c.Commit();
                        }
                    }

                    //if (DiskCache.GetValue("ReportDataSourceType") == "DataTable")
                    //{
                    //    if (DiskCache.GetDataTable("ReportDataSource").Rows.Count>0)
                    //    { 
                    //        if (report.VisibleColumnAtStart != null)
                    //            Window.Open("report.aspx?VisibleColumnAtStart=" + HttpUtility.UrlEncode(Security.Encrypt((report.VisibleColumnAtStart.Value + 2).ToString())), "AnacleEAM_Report");
                    //        else
                    //            Window.Open("report.aspx", "AnacleEAM_Report");
                    //    }
                    //}
                    //if (DiskCache.GetValue("ReportDataSource") == "DataSet")
                    //{
                    //    if(DiskCache.GetDataSet("ReportDataSource").Tables[0].Rows.Count>0)
                    //    { 
                    //        if (report.VisibleColumnAtStart != null)
                    //            Window.Open("report.aspx?VisibleColumnAtStart=" + HttpUtility.UrlEncode(Security.Encrypt((report.VisibleColumnAtStart.Value + 2).ToString())), "AnacleEAM_Report");
                    //        else
                    //            Window.Open("report.aspx", "AnacleEAM_Report");
                    //    }
                    //}

                    //Set visible column at start
                    if (DiskCache.ContainsKey("ReportDataSource"))
                    {
                        //plus 2 column (first two column for grouping)
                        if (report.VisibleColumnAtStart != null)
                            Window.Open("report.aspx?VisibleColumnAtStart=" + HttpUtility.UrlEncode(Security.Encrypt((report.VisibleColumnAtStart.Value + 2).ToString())), "AnacleEAM_Report");
                        else
                            Window.Open("report.aspx", "AnacleEAM_Report");
                    }
                    // KF END
                }
                else if (report.ReportType == 0) //rdl report with embedded sql
                {
                    Session["ReportParameter"] = paramList.ToArray();
                    Window.Open("reportviewer.aspx", "AnacleEAM_Report");
                }
                //16Jul09: 'crystal report' type is removed
                //else if (report.ReportType == 2) 
                //{
                //    Session["ReportParameter"] = paramList.ToArray();
                //    Window.Open("crystalreportviewer.aspx", "AnacleEAM_Report");
                //}
            }
        }
        catch (Exception ex)
        {
            if (ex.InnerException != null)
                panel.Message = ex.InnerException.Message;
            else
                panel.Message = ex.Message;
        }
    }

    protected void reportTemplatedrop_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (TemplateDetails_Template.SelectedIndex == 0)
            this.panelTemplateDetails.Visible = false;
        else
        {
            Guid templateID = new Guid(TemplateDetails_Template.SelectedValue);
            OReportTemplate template = TablesLogic.tReportTemplate[templateID];

            if (template.TemplateType == null)
            {
                // Show template details only if the 
                // template is a spreadsheet report layout.
                //
                this.panelTemplateDetails.Visible = true;

                this.TemplateDetails_Creator.Text = String.Format("{0} on {1}", template.CreatorUser.ObjectName, template.CreatedDateTime.Value.AddSeconds(-1).ToFriendlyString());
                this.TemplateDetails_Description.Text = template.Description;
            }
            else
            {
                // If this template is an RDL or Crystal Reports
                // template, then hide the template details.
                //
                this.panelTemplateDetails.Visible = false;
            }
        }
    }

    protected void editTemplate_OnClick(object sender, EventArgs e)
    {
        if (TemplateDetails_Template.SelectedIndex == 0)
        {
            panel.Message = Resources.Errors.Report_SelectTemplate;
            return;
        }
        //check if the user has right to edit the template
        else if (!OReportTemplate.IsEditableTemplate(new Guid(this.TemplateDetails_Template.SelectedValue), (Guid)AppSession.User.ObjectID))
        {
            panel.Message = Resources.Errors.ReportTemplate_EditDenied;
            return;
        }
        else
        {
            //open edit template page
            Window.OpenEditObjectPage(
                Page, "OReportTemplate", TemplateDetails_Template.SelectedValue, "");
        }
    }
    protected void deleteTemplate_OnClick(object sender, EventArgs e)
    {
        if (TemplateDetails_Template.SelectedIndex == 0)
        {
            panel.Message = Resources.Errors.Report_SelectTemplate;
            return;
        }
        else
        {
            //delete the template and repopulate the list
            if (!OReportTemplate.DeleteTemplate(new Guid(TemplateDetails_Template.SelectedValue), (Guid)AppSession.User.ObjectID))
            {
                panel.Message = Resources.Errors.ReportTemplate_EditDenied;
                return;
            }
            else
            {
                panel.Message = Resources.Messages.General_ItemDeleted;
                //refresh template drop down list
                PopulateTemplateDetails(Security.DecryptGuid(Request["ID"]));
                reportTemplatedrop_SelectedIndexChanged(null, null);
            }
        }

    }

    protected TreePopulater Equipment_AcquireTreePopulater(object sender)
    {        //Check which equipment to load based on the location ID.
        object eqptId = null;
        if (Request["syncId"] != null)
            eqptId = new Guid(Security.Decrypt(Request["syncId"]));
        return new EquipmentTreePopulater((eqptId != null ? (object)eqptId : null), true, true, "");

    }

    protected TreePopulater Location_AcquireTreePopulater(object sender)
    {
        object locId = null;
        if (Request["syncId"] != null)
            locId = ((OEquipment)TablesLogic.tEquipment.LoadObject(new Guid(Security.Decrypt(Request["syncId"])))).LocationID;

        return new LocationEquipmentTreePopulater((locId != null ? locId : null), true, true, true, "");
    }


    //--------------------------------------------------------------------
    /// <summary>
    /// Cascade changes down to the next level control.
    /// </summary>
    //--------------------------------------------------------------------
    protected void CascadeChange(object obj)
    {
        Guid reportId = Security.DecryptGuid(Request["ID"]);
        OReport report = TablesLogic.tReport[reportId];

        if (obj != null)
        {
            //Rachel. Allow one control to cascade multiple controls.            
            DataList<OReportField> cascadedFieldList = null;

            if (obj is OReport)
                cascadedFieldList = ((OReport)obj).CascadeControl;
            if (obj is OReportField)
                cascadedFieldList = ((OReportField)obj).CascadeControl;
            if (cascadedFieldList == null)
                return;

            foreach (OReportField cascadedField in cascadedFieldList)
            {
                Control c = this.FindControl(cascadedField.ControlIdentifier);
                //becareful of infinite loop here (if it is point to itself)
                if (c != null)
                {
                    if (cascadedField.ObjectID != ((PersistentObject)obj).ObjectID)
                    {
                        if (c is UIFieldDropDownList)
                            BindToList(c as UIFieldDropDownList, report, cascadedField);
                        else if (c is UIFieldRadioList)
                            BindToList(c as UIFieldRadioList, report, cascadedField);
                        else if (c is UIFieldListBox)
                            BindToList(c as UIFieldListBox, report, cascadedField);
                        //Rachel. Do not cascade next level, as now one field can update multiple fields, sometimes it takes too much time to download
                        //CascadeChange(cascadedField);
                    }
                }
            }
        }
    }


    //--------------------------------------------------------------------
    /// <summary>
    /// This is called when the treeview is updated, in order to update
    /// the cascaded dropdown.
    /// </summary>
    //--------------------------------------------------------------------
    protected void SelectedNodeChanged()
    {
        Guid reportId = Security.DecryptGuid(Request["ID"]);
        OReport report = TablesLogic.tReport[reportId];

        CascadeChange(report);
    }


    //--------------------------------------------------------------------
    /// <summary>
    /// This is called when the generic treeview is updated.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    //--------------------------------------------------------------------
    protected void panel_SelectedNodeChanged(object sender, EventArgs e)
    {
        SelectedNodeChanged();
    }


    //--------------------------------------------------------------------
    /// <summary>
    /// This is called when the equipment treeview is changed.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    //--------------------------------------------------------------------
    protected void Equipment_SelectedNodeChanged(object sender, EventArgs e)
    {
        LocationPath.Text = "";
        EquipmentPath.Text = "";
        if (Equipment.SelectedValue != "")
        {
            OLocation loc = (OLocation)TablesLogic.tLocation[new Guid(Equipment.SelectedValue)];
            OEquipment eqp = (OEquipment)TablesLogic.tEquipment[new Guid(Equipment.SelectedValue)];

            if (loc != null)
            {
                LocationPath.Text = loc.Path;
            }
            else if (eqp != null)
            {
                if (eqp.IsPhysicalEquipment == 0)
                    LocationPath.Text = "";
                else LocationPath.Text = eqp.Location.Path;
                EquipmentPath.Text = eqp.Path;
            }

            Location.SelectedValue = "";
        }
        SelectedNodeChanged();
    }


    //--------------------------------------------------------------------
    /// <summary>
    /// This is called when the location treeview is changed.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    //--------------------------------------------------------------------
    protected void Location_SelectedNodeChanged(object sender, EventArgs e)
    {
        LocationPath.Text = "";
        EquipmentPath.Text = "";
        if (Location.SelectedValue != "")
        {
            OLocation loc = (OLocation)TablesLogic.tLocation[new Guid(Location.SelectedValue)];
            OEquipment eqp = (OEquipment)TablesLogic.tEquipment[new Guid(Location.SelectedValue)];

            if (loc != null)
            {
                EquipmentPath.Text = "";
                LocationPath.Text = loc.Path;
            }
            else if (eqp != null)
            {
                LocationPath.Text = eqp.Location.Path;
                EquipmentPath.Text = eqp.Path;
            }

            Equipment.SelectedValue = "";
        }
        SelectedNodeChanged();
    }

    /// <summary>
    /// Occurs when the user checks or unchecks the Use Template checkbox.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void checkUseTemplate_CheckedChanged(object sender, EventArgs e)
    {
        if (checkUseTemplate.Checked)
        {
            this.panelReportTemplate.Visible = true;
            PopulateTemplateDetails(Security.DecryptGuid(Request["ID"]));
        }
        else
            this.panelReportTemplate.Visible = false;
    }

    /// ------------------------------------------------------------------
    /// <summary>
    /// Event to handle the dropdown list change to cascade the change
    /// downwards to other dropdown lists.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    /// ------------------------------------------------------------------
    void report_search_aspx_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (sender != null)
        {
            // find the report field corresponding to this control
            //
            Guid reportId = Security.DecryptGuid(Request["ID"]);
            OReport report = TablesLogic.tReport[reportId];
            OReportField field = null;
            foreach (OReportField reportField in report.ReportFields)
                if (reportField.ControlIdentifier == ((Control)sender).ID)
                {
                    field = reportField;
                    break;
                }
            CascadeChange(field);
        }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="MethodName"></param>
    /// <param name="paramList"></param>
    /// <returns></returns>
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
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form2" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:search ID="panel" runat="server" Caption="" AddButtonVisible="false" BaseTable="tApplicationSetting"
            GridViewID="gridResult" OnSearch="panel_Search" EditButtonVisible="false" OnSelectedNodeChanged="panel_SelectedNodeChanged" />
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabstripSearch" BorderStyle="NotSet" meta:resourcekey="tabstripSearchResource1">
                <ui:UITabView runat="server" ID="tabSearch" Caption="Search" BorderStyle="NotSet"
                    meta:resourcekey="tabSearchResource3">
                    <ui:UIGridView runat="server" ID="gridResult" Visible="False" DataKeyNames="ObjectID"
                        GridLines="Both" meta:resourcekey="gridResultResource1" RowErrorColor="" ShowCaption="False"
                        ShowCommands="False" Style="clear: both;">
                        <PagerSettings Mode="NumericFirstLast" />
                    </ui:UIGridView>
                    <ui:UIFieldCheckBox runat="server" ID="checkUseTemplate" Caption="Use Layout" Text="Yes, use a saved report layout"
                        OnCheckedChanged="checkUseTemplate_CheckedChanged" meta:resourcekey="checkUseTemplateResource2"
                        TextAlign="Right">
                    </ui:UIFieldCheckBox>
                    <ui:UIPanel runat="server" ID="panelReportTemplate" Visible="False" BorderStyle="NotSet"
                        meta:resourcekey="panelReportTemplateResource1">
                        <ui:UIFieldDropDownList ID="TemplateDetails_Template" runat="server" Caption="Choose Layout"
                            OnSelectedIndexChanged="reportTemplatedrop_SelectedIndexChanged" meta:resourcekey="TemplateDetails_TemplateResource2">
                        </ui:UIFieldDropDownList>
                        <ui:UIPanel runat="server" ID="panelTemplateDetails" Visible="False" BorderStyle="NotSet"
                            meta:resourcekey="panelTemplateDetailsResource1">
                            <table cellpadding='0' cellspacing='0' border='0'>
                                <tr>
                                    <td style="width: 158px">
                                    </td>
                                    <td>
                                        <ui:UIButton ID="buttonEditTemplate" runat="server" ImageUrl="~/images/edit.gif"
                                            Text="Edit Layout Details" OnClick="editTemplate_OnClick" meta:resourcekey="buttonEditTemplateResource2" />
                                        <ui:UIButton ID="buttonDeleteTemplate" runat="server" ImageUrl="~/images/delete.gif"
                                            Text="Delete Layout" OnClick="deleteTemplate_OnClick" ConfirmText="Are you sure you wish to delete this l?"
                                            meta:resourcekey="buttonDeleteTemplateResource2" />
                                    </td>
                                </tr>
                            </table>
                            <ui:UIFieldLabel ID="TemplateDetails_Description" runat="server" Caption="Description"
                                CssClass="div-audit"
                                DataFormatString="" meta:resourcekey="TemplateDetails_DescriptionResource2">
                            </ui:UIFieldLabel>
                            <ui:UIFieldLabel ID="TemplateDetails_Creator" runat="server" Caption="Created By"
                                CssClass="div-audit"
                                DataFormatString="" meta:resourcekey="TemplateDetails_CreatorResource2">
                            </ui:UIFieldLabel>
                        </ui:UIPanel>
                    </ui:UIPanel>
                    <ui:UISeparator ID="Sep1" runat="server" meta:resourcekey="Sep1Resource1" />
                    <ui:UIPanel ID="Panel_LocationEqptTree" runat="server" Visible="False" BorderStyle="NotSet"
                        meta:resourcekey="Panel_LocationEqptTreeResource1">
                        <ui:UITabStrip runat="server" ID="UITabStrip1" meta:resourcekey="UITabStrip1Resource2"
                            BorderStyle="NotSet">
                            <ui:UITabView runat="server" ID="uitabview1" Caption="By Location" meta:resourcekey="uitabview3Resource2"
                                BorderStyle="NotSet">
                                <ui:UIFieldTreeList runat="server" ID="Location" Caption="Select" meta:resourcekey="LocationResource1"
                                    ToolTip="Use this to select the location that this work applies to." Style="float: left;
                                    table-layout: fixed;" border="0" cellpadding="2" cellspacing="0" Height="20px"
                                    Width="99%" OnAcquireTreePopulater="Location_AcquireTreePopulater" OnSelectedNodeChanged="Location_SelectedNodeChanged"
                                    ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                            </ui:UITabView>
                            <ui:UITabView runat="server" ID="uitabview2" Caption="By Equipment" meta:resourcekey="uitabview4Resource2"
                                BorderStyle="NotSet">
                                <ui:UIFieldTreeList ID="Equipment" runat="server" border="0" Caption="Select" cellpadding="2"
                                    cellspacing="0" Height="20px" meta:resourcekey="EquipmentResource1" OnAcquireTreePopulater="Equipment_AcquireTreePopulater"
                                    OnSelectedNodeChanged="Equipment_SelectedNodeChanged" Style="float: left; table-layout: fixed;"
                                    ToolTip="Use this to select the equipment that this work applies to." Width="99%"
                                    ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                                </ui:UIFieldTreeList>
                            </ui:UITabView>
                        </ui:UITabStrip>
                        <br />
                        <ui:UIFieldLabel ID="LocationPath" runat="server" Caption="Location Path" DataFormatString=""
                            meta:resourcekey="LocationPathResource2" />
                        <ui:UIFieldLabel ID="EquipmentPath" runat="server" Caption="Equipment Path" DataFormatString=""
                            meta:resourcekey="EquipmentPathResource2" />
                        <ui:UISeparator ID="UISeparator1" runat="server" meta:resourcekey="UISeparator1Resource1" />
                    </ui:UIPanel>
                </ui:UITabView>
            </ui:UITabStrip>
            <asp:Label runat="server" ID="labelReportInvalid" Visible="False" meta:resourcekey="labelReportInvalidResource3">The report is invalid or it does not exist.</asp:Label>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
