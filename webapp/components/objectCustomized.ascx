<%@ Control Language="C#" ClassName="objectCustomized" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.ComponentModel" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Src="objectsubpanel.ascx" TagPrefix="web2" TagName="subpanel" %>
<%@ Register Src="objectPanel.ascx" TagPrefix="web2" TagName="object" %>

<script runat="server">
    //Rachel 13April 2007. Customized object
    [Localizable(false), Browsable(true)]
    public string GridViewPropertyName
    {
        get
        {
            return this.gridFields.PropertyName;
        }
        set
        {
            if (value == "" || value.Trim() == "")
                throw new Exception("Error encountered while trying to build customized object control. GridViewPropertyName has not been specified");
            this.gridFields.PropertyName = value;
        }
    }
    [Localizable(false), Browsable(true), DefaultValue(true)]
    public bool PreviewButtonVisible
    {
        get
        {
            return this.buttonPreview.Visible;
        }
        set
        {
            this.buttonPreview.Visible = value;
        }
    }
    [Localizable(false), Browsable(true), DefaultValue(false)]
    public bool ValidateGridFieldsRequired
    {
        get
        {
            return this.gridFields.ValidateRequiredField;
        }
        set
        {
            this.gridFields.ValidateRequiredField = value;
        }
    }


    public PersistentObject SessionObject
    {
        get { return gridFields_SubPanel.SessionObject; }
    }


    public UIObjectPanel ObjectPanel
    {
        get { return gridFields_SubPanel.ObjectPanel; }
    }
    

    //populate data for all list fields 
    //and bind the data for each fields if required 
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!IsPostBack)
        {

            //populate code type list with all available code type in the system
            this.field_CodeTypeID.Bind(TablesLogic.tCodeType[Query.True]);
            //dynamically build all the drop down list details to allow translation of its content
            this.field_ControlSpan.Items.Add(new ListItem(Resources.Strings.CustomizedObject_ControlSpan_Half, "Half"));
            this.field_ControlSpan.Items.Add(new ListItem(Resources.Strings.CustomizedObject_ControlSpan_Full, "Full"));
            this.field_ControlType.Items.Add(new ListItem(Resources.Strings.CustomizedObject_ControlType_TextBox, "TextBox"));
            this.field_ControlType.Items.Add(new ListItem(Resources.Strings.CustomizedObject_ControlType_Date, "Date"));
            this.field_ControlType.Items.Add(new ListItem(Resources.Strings.CustomizedObject_ControlType_DateTime, "DateTime"));
            this.field_ControlType.Items.Add(new ListItem(Resources.Strings.CustomizedObject_ControlType_CheckBox, "CheckBox"));
            this.field_ControlType.Items.Add(new ListItem(Resources.Strings.CustomizedObject_ControlType_DropDownList, "DropDownList"));
            this.field_ControlType.Items.Add(new ListItem(Resources.Strings.CustomizedObject_ControlType_RadioList, "RadioList"));
            this.field_ControlType.Items.Add(new ListItem(Resources.Strings.CustomizedObject_ControlType_Separator, "Separator"));
            this.field_DataType.Items.Add(new ListItem(Resources.Strings.CustomizedObject_DataType_String, "String"));
            this.field_DataType.Items.Add(new ListItem(Resources.Strings.CustomizedObject_DataType_Integer, "Integer"));
            this.field_DataType.Items.Add(new ListItem(Resources.Strings.CustomizedObject_DataType_Double, "Double"));
            this.field_DataType.Items.Add(new ListItem(Resources.Strings.CustomizedObject_DataType_Decimal, "Decimal"));
            this.field_DataType.Items.Add(new ListItem(Resources.Strings.CustomizedObject_DataType_DateTime, "DateTime"));
        }
    }


    // hunts for the objectPanel.ascx control and finds the PersistentObject
    //
    protected objectPanel getPanel(Control c)
    {
        if (c.GetType() == typeof(objectPanel))
            return (objectPanel)c;
        foreach (Control child in c.Controls)
        {
            objectPanel o = getPanel(child);
            if (o != null)
                return o;
        }
        return null;
    }
    private ArrayList GetGridViewItems()
    {
        object list = UIBinder.GetValue(getPanel(Page).SessionObject, GridViewPropertyName, false);
        if (!(list is DataListBase))
            throw new Exception("Error encounter while building customized control: property " + GridViewPropertyName + " does not refer to a datalistbase object");
        ArrayList cusFields = new ArrayList();
        foreach (object field in (IEnumerable)list)
        {
            cusFields.Add(field);
        }
        return cusFields;
    }
    protected void ObjectFields_ObjectPanel_OnPopulate(object sender, EventArgs e)
    {
        PersistentObject obj = gridFields_SubPanel.SessionObject;

        OCustomizedField field = (OCustomizedField)obj;
        //unable to get correct Isnew Value if the object has not been saved to database.
        //Lazy way: if Column Name is not null then it's editing object        
        SetDisplayOrderList(field);
        //Disable active for new case
        if (field.IsNew)
        {
            field.IsActive = 1;
            this.field_isActive.Enabled = false;
        }
        else
        {
            this.field_isActive.Enabled = true;
        }


        if (FieldPopulate != null)
            FieldPopulate(sender, EventArgs.Empty);

        gridFields_SubPanel.ObjectPanel.BindObjectToControls(obj);
    }
    private void SetDisplayOrderList(OCustomizedField cusObj)
    {
        //get number of items in  gridfield 
        int count = GetGridViewItems().Count;
        DisplayOrder.Items.Clear();

        for (int i = 0; i < (cusObj.DisplayOrder == null ? count + 1 : count); i++)
        {
            DisplayOrder.Items.Add(new ListItem((i + 1).ToString(), (i + 1).ToString()));
        }

        if (cusObj.ColumnName == null)
            cusObj.DisplayOrder = DisplayOrder.Items.Count;

    }

    protected void ObjectFields_ValidateAndUpdate(object sender, EventArgs e)
    {
        PersistentObject obj = gridFields_SubPanel.SessionObject;
        gridFields_SubPanel.ObjectPanel.BindControlsToObject(obj);
        OCustomizedField current = (OCustomizedField)obj;

        //allow other control to do extra setting for the customized field
        if (FieldUpdating != null)
            FieldUpdating(this, e);
        
        //caption must be unique in the list
        ArrayList list = GetGridViewItems();
        foreach (OCustomizedField field in list)
        {
            if (field.ControlCaption.ToUpper().Trim() == current.ControlCaption.ToUpper().Trim() && field.ColumnName != current.ColumnName)
            {
                field_ControlCaption.ErrorMessage = Resources.Errors.General_NameDuplicate;
                break;
            }
        }
        //range validation for date time must be in correct date time format
        if (current.ValidateRangeField == 1)
        {
            bool checkMin = (current.ValidateRangeMin.Trim() != "");
            bool checkMax = (current.ValidateRangeMax.Trim() != "");
            
            //at least one range specify
            if (!checkMin && !checkMax)
            {
                this.field_ValidateRangeField.ErrorMessage = Resources.Errors.CustomizedObject_NoRangeSpecify;
            }
            if (current.DataType == "DateTime")
            {
                try
                {
                    if (checkMin)
                        Convert.ToDateTime(current.ValidateRangeMin);
                }
                catch
                {
                    this.field_ValidateRangeMin.ErrorMessage = Resources.Errors.CustomizedObject_InvalidMinDateTime;
                }
                try
                {
                    if (checkMax)
                        Convert.ToDateTime(current.ValidateRangeMax);

                    if (!this.field_ValidateRangeMax.ValidateCompare(Convert.ToDateTime(current.ValidateRangeMax), Convert.ToDateTime(current.ValidateRangeMin), ValidationCompareOperator.GreaterThan))
                    {
                        this.field_ValidateRangeMax.ErrorMessage = Resources.Errors.CustomizedObject_MaxLessMinDateTime;
                    }
                }
                catch
                {
                    this.field_ValidateRangeMax.ErrorMessage = Resources.Errors.CustomizedObject_InvalidMaxDateTime;
                }
                
                    
                
                    
                
            }
            else if (current.DataType == "Integer")
            {
                try
                {
                    if (checkMin)
                        Convert.ToInt32(current.ValidateRangeMin);
                }
                catch
                {
                    this.field_ValidateRangeMin.ErrorMessage = Resources.Errors.CustomizedObject_InvalidMinInteger;
                }
                try
                {
                    if (checkMax)
                        Convert.ToInt32(current.ValidateRangeMax);
                    
                    if (!this.field_ValidateRangeMax.ValidateCompare(Convert.ToInt64(current.ValidateRangeMax), Convert.ToInt64(current.ValidateRangeMin), ValidationCompareOperator.GreaterThan))
                    {
                        this.field_ValidateRangeMax.ErrorMessage = Resources.Errors.CustomizedObject_MaxLessMinInteger;
                    }
                }
                catch
                {
                    this.field_ValidateRangeMax.ErrorMessage = Resources.Errors.CustomizedObject_InvalidMaxInteger;
                }
                
                
            }
            else if (current.DataType == "Double")
            {
                try
                {
                    if (checkMin)
                        Convert.ToDouble(current.ValidateRangeMin);
                }
                catch
                {
                    this.field_ValidateRangeMin.ErrorMessage = Resources.Errors.CustomizedObject_InvalidMinDouble;
                }
                try
                {
                    if (checkMax)
                        Convert.ToDouble(current.ValidateRangeMax);

                    if (!this.field_ValidateRangeMax.ValidateCompare(Convert.ToDouble(current.ValidateRangeMax), Convert.ToDouble(current.ValidateRangeMin), ValidationCompareOperator.GreaterThan))
                    {
                        this.field_ValidateRangeMax.ErrorMessage = Resources.Errors.CustomizedObject_MaxLessMinDouble;
                    }
                }
                catch
                {
                    this.field_ValidateRangeMax.ErrorMessage = Resources.Errors.CustomizedObject_InvalidMaxDouble;
                }
            }
            else if (current.DataType == "Decimal")
            {
                try
                {
                    if (checkMin)
                        Convert.ToDecimal(current.ValidateRangeMin);
                }
                catch
                {
                    this.field_ValidateRangeMin.ErrorMessage = Resources.Errors.CustomizedObject_InvalidMinDecimal;
                }
                try
                {
                    if (checkMax)
                        Convert.ToDecimal(current.ValidateRangeMax);

                    if (!this.field_ValidateRangeMax.ValidateCompare(Convert.ToDecimal(current.ValidateRangeMax), Convert.ToDecimal(current.ValidateRangeMin), ValidationCompareOperator.GreaterThan))
                    {
                        this.field_ValidateRangeMax.ErrorMessage = Resources.Errors.CustomizedObject_MaxLessMinDecimal;
                    }
                }
                catch
                {
                    this.field_ValidateRangeMax.ErrorMessage = Resources.Errors.CustomizedObject_InvalidMaxDecimal;
                }
            }
        }
        
        //column Name should be set only once
        if (current.ColumnName == null || current.ColumnName == "")
        {
            current.ColumnName = obj.ObjectID.Value.ToString();
        }
        //if control type is dropdownlist, radiolist, check box, set data type to string (no validation make)
        if (current.ControlType == "DropDownList" || current.ControlType == "RadioList" || current.ControlType == "CheckBox")
        {
            current.DataType = "String";
            current.ValidateRangeField = 0;
        }
        if (current.ControlType == "Separator")
            current.ControlSpan = "Full";
        if (current.ControlType != "TextBox")
        {
            current.MaxLength = null;
            current.MultiLineTextBox = 0;
        }
        else
        {
            //maximum 4000 char
            if (current.MaxLength == null)
                current.MaxLength = 4000;
        }
        
        //allow other control to do extra setting for the customized field
        if (FieldUpdate != null)
            FieldUpdate(this.FieldUpdate, EventArgs.Empty);


        objectPanel opanel = getPanel(Page);
        PersistentObject persistentObject = opanel.SessionObject;
        if (persistentObject is LogicLayerPersistentObject &&
            obj is OCustomizedAttributeField)
        {
            ((LogicLayerPersistentObject)persistentObject).CustomizedAttributeFields.Add(
                (OCustomizedAttributeField)obj);

            //reorder display order        
            LogicLayer.Global.ReorderItems(GetGridViewItems(), obj, "DisplayOrder");

            panelFields.BindObjectToControls(opanel.SessionObject);
        }
    }
    
    
    
    protected void field_ControlType_SelectedIndexChanged(object sender, EventArgs e)
    {


    }
    protected void field_IsPopulatedByCode_SelectedIndexChanged(object sender, EventArgs e)
    {


    }
    protected void field_ValidateRangeField_CheckedChanged(object sender, EventArgs e)
    {


    }
    protected void ObjectFields_Removed(object sender, EventArgs e)
    {
        //reorder display order        
        LogicLayer.Global.ReorderItems(GetGridViewItems(), null, "DisplayOrder");

        if (FieldDeleted != null)
            FieldDeleted(this, new EventArgs());

    }
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        //it's better to set hide and show of fields at prerender rather than the event handler of individual field
        this.panelTextBoxField.Visible = this.field_ControlType.SelectedValue.ToUpper() == "TEXTBOX";
        if (this.field_ControlType.SelectedValue.ToUpper() == "DROPDOWNLIST" ||
            this.field_ControlType.SelectedValue.ToUpper() == "RADIOLIST")
            panelListField.Visible = true;

        else
            panelListField.Visible = false;

        //Pre select data type as datetime if control type is date time
        if (this.field_ControlType.SelectedValue == "DateTime" ||
            this.field_ControlType.SelectedValue == "Date")
        {
            this.field_DataType.SelectedValue = "DateTime";
            this.field_DataType.Enabled = false;
        }
        else
            this.field_DataType.Enabled = true;

        this.field_CheckBoxCaption.Visible = (this.field_ControlType.SelectedValue == "CheckBox");

        //hide data type if control type is drop down. radio , check box
        if (this.field_ControlType.SelectedValue == "DropDownList" ||
            this.field_ControlType.SelectedValue == "RadioList" ||
            this.field_ControlType.SelectedValue == "CheckBox")
            this.field_DataType.Visible = false;
        else
            this.field_DataType.Visible = true;

        if (this.field_IsPopulatedByCode.SelectedValue == "1")
        {
            this.panelListCode.Visible = true;
            this.panelListValue.Visible = false;
        }
        else if (this.field_IsPopulatedByCode.SelectedValue == "0")
        {
            this.panelListCode.Visible = false;
            this.panelListValue.Visible = true;
        }
        else
        {
            this.panelListCode.Visible = false;
            this.panelListValue.Visible = false;
        }
        //validate range is only for text box and date time control and not for string
        if ((field_ControlType.SelectedValue == "TextBox" ||
            field_ControlType.SelectedValue == "DateTime" ||
            field_ControlType.SelectedValue == "Date")
            && field_DataType.SelectedValue != "String")
        {
            this.field_ValidateRangeField.Visible = true;
        }
        else
        {
            this.field_ValidateRangeField.Visible = false;
            //make sure validate range won't be shown
            this.field_ValidateRangeField.Checked = false;
        }
        this.panelValidateRage.Visible = this.field_ValidateRangeField.Checked;

        //hide all details if it's a separator
        if (this.field_ControlType.SelectedValue == "Separator")
        {
            panelSeparator.Visible = false;
        }
        else
            panelSeparator.Visible = true;


    }
    protected void gridFields_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        //translate item
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //if Control type is dropdownlist and radio list. datatype should be null =="-"
            if (e.Row.Cells[5].Text == "DropDownList" || e.Row.Cells[5].Text == "RadioList" || e.Row.Cells[5].Text == "CheckBox" || e.Row.Cells[5].Text == "Separator")
            {
                e.Row.Cells[7].Text = "-";
            }
            else
            {
                //datatype
                e.Row.Cells[7].Text = Resources.Strings.ResourceManager.GetString("CustomizedObject_DataType_" + e.Row.Cells[7].Text);
            }
            //control type            
            e.Row.Cells[5].Text = Resources.Strings.ResourceManager.GetString("CustomizedObject_ControlType_" + e.Row.Cells[5].Text);
            //control span
            e.Row.Cells[6].Text = Resources.Strings.ResourceManager.GetString("CustomizedObject_ControlSpan_" + e.Row.Cells[6].Text);

        }

    }
    protected void buttonPreview_Click(object sender, EventArgs e)
    {
        string sessionKey = "CustomizedFieldList";
        Session[sessionKey] = GetGridViewItems();

        string url = Page.Request.ApplicationPath + "/" + "modules/customizedobject/preview.aspx?ID=" + Security.Encrypt(sessionKey);
        string target = "_new";
        int popupWidth = 1000;
        int popupHeight = 500;
        getPanel(Page).FocusWindow = false;
        Window.WriteJavascript("window.open('" + url + "', '" + target +
            "', 'toolbar=no, width=" + popupWidth +
            ", height=" + popupHeight +
            ", top='+(screen.height-" + (popupHeight + 50) + ")/2+'" +
            ", left='+(screen.width-" + (popupWidth + 10) + ")/2+', " +
            "resizable=yes, scrollbars=yes');");

    }

    //delegate the updating sub object event
    public event EventHandler FieldUpdating;
    public event EventHandler FieldUpdate;
    public event EventHandler FieldUpdated;
    public event EventHandler FieldPopulate;
    public event EventHandler FieldDeleted;
    
</script>

<!--Grid view. Map the propertyName to the corresponding property in the object schema class-->
<table width="100%">
    <tr>
        <td width="100%" align="right">
            <ui:UIButton runat="server" ID="buttonPreview" OnClick="buttonPreview_Click" ImageUrl="~/images/Symbol-Refresh-big.gif"
                Text="Preview" meta:resourcekey="buttonPreviewResource1" />
        </td>
    </tr>
</table>
<ui:uipanel runat="server" id="panelFields">
<ui:UIGridView ID="gridFields" runat="server" Caption="Fields" KeyName="ObjectID"
    SortExpression="[DisplayOrder] asc" OnRowDataBound="gridFields_RowDataBound"
    AllowPaging="True" AllowSorting="True" CaptionWidth="120px"
    meta:resourcekey="gridFieldsResource1" PagingEnabled="True"
    Width="100%">
    <Columns>
        <ui:UIGridViewButtonColumn CommandName="EditObject" ImageUrl="~/images/edit.gif"
            HeaderText="" meta:resourcekey="UIGridViewColumnResource1">
        </ui:UIGridViewButtonColumn>
        <ui:UIGridViewButtonColumn CommandName="DeleteObject" ImageUrl="~/images/delete.gif"
            ConfirmText="Are you sure you wish to delete this item?" 
            HeaderText="" meta:resourcekey="UIGridViewColumnResource2">
        </ui:UIGridViewButtonColumn>
        <ui:UIGridViewBoundColumn HeaderText="Display Order" PropertyName="DisplayOrder" meta:resourcekey="UIGridViewColumnResource4">
        </ui:UIGridViewBoundColumn>
        <ui:UIGridViewBoundColumn HeaderText="Control Caption" PropertyName="ControlCaption" meta:resourcekey="UIGridViewColumnResource4">
        </ui:UIGridViewBoundColumn>
        <ui:UIGridViewBoundColumn HeaderText="Control Type" PropertyName="ControlType" meta:resourcekey="UIGridViewColumnResource5">
        </ui:UIGridViewBoundColumn>
        <ui:UIGridViewBoundColumn HeaderText="Control Span" PropertyName="ControlSpan" meta:resourcekey="UIGridViewColumnResource6">
        </ui:UIGridViewBoundColumn>
        <ui:UIGridViewBoundColumn HeaderText="Data Type" PropertyName="DataType" meta:resourcekey="UIGridViewColumnResource7">
        </ui:UIGridViewBoundColumn>
    </Columns>
    <Commands>
        <ui:UIGridViewCommand CommandName="DeleteObject" CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete selected item?"
            ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
        <ui:UIGridViewCommand CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif"
            meta:resourcekey="UIGridViewCommandResource2" />
    </Commands>
</ui:UIGridView>
<!--add an object panel to wrap the fields of object in the above grid view. Naming convention is the objectName_ObjectPanel-->
<ui:UIObjectPanel ID="ObjectFields_ObjectPanel" runat="server" meta:resourcekey="ObjectFields_ObjectPanelResource1">
    <!--sub panel that include update, cancel button for adding and editing of object in the above grid view. 
    Set the objectPanelID to the id of the above object panel for it to know which fields belong to the editing/adding of the object. 
    Set GridViewID to the id of the above gridview for it to know which gridview will be updated when user make changes to the object list.-->
    <web2:subpanel ID="gridFields_SubPanel" GridViewID="gridFields" 
        runat="server" OnPopulateForm="ObjectFields_ObjectPanel_OnPopulate" 
        OnValidateAndUpdate="ObjectFields_ValidateAndUpdate" OnRemoved="ObjectFields_Removed" />
    <!--all fields belong to the sub object go here. 
    Set caption for the field
    Set the propertyName of the field to the corresponding column name of the object. Set validation if necessary-->
    <ui:UIFieldDropDownList ID="DisplayOrder" runat="server" Caption="Display Order"
        PropertyName="DisplayOrder" Span="Half" ValidateRequiredField="True" ToolTip="The order of display of the search field. Lower appears first."
        meta:resourcekey="DisplayOrderResource1">
    </ui:UIFieldDropDownList>
    <br />
    <br />
    <ui:UIFieldTextBox ID="field_ControlCaption" Span="Half" Caption="Column Caption"
        PropertyName="ControlCaption" ToolTip="The field's caption to be displayed on edit page"
        runat="server" ValidateRequiredField="True" meta:resourcekey="field_ControlCaptionResource1" />
    <ui:UIFieldDropDownList ID="field_ControlType" runat="server" PropertyName="ControlType"
        Span="Half" OnSelectedIndexChanged="field_ControlType_SelectedIndexChanged" Caption="Control Type"
        ToolTip="Set the control type for user to input value" ValidateRequiredField="True"
        meta:resourcekey="field_ControlTypeResource1">
    </ui:UIFieldDropDownList>
    <ui:UIPanel ID="panelSeparator" runat="server" meta:resourcekey="panelSeparatorResource1">
        <ui:UIFieldTextBox ID="field_ToolTip" Caption="ToolTip" PropertyName="ToolTip" ToolTip="More description about the control that will be displayed when user mouse over the information icon"
            MaxLength="255" runat="server" meta:resourcekey="field_ToolTipResource1" />
        <ui:UIFieldRadioList ID="field_isActive" Caption="Active" PropertyName="IsActive"
            runat="server" ToolTip="Indicate whether the field is editable by user" RepeatColumns="0"
            RepeatDirection="Vertical" ValidateRequiredField="True" meta:resourcekey="field_isActiveResource1">
            <Items>
                <asp:ListItem Selected="True" Value="1" meta:resourcekey="ListItemResource1">Yes, this field is still active.</asp:ListItem>
                <asp:ListItem Value="0" meta:resourcekey="ListItemResource2">No, this field is no longer active and user should not be allowed to enter any value</asp:ListItem>
            </Items>
        </ui:UIFieldRadioList>
        <ui:UIFieldDropDownList ID="field_ControlSpan" runat="server" PropertyName="ControlSpan"
            Span="Half" Caption="Control Span" ToolTip="Set display of the field, either occupied half or entire row"
            ValidateRequiredField="True" meta:resourcekey="field_ControlSpanResource1">
        </ui:UIFieldDropDownList>
        <ui:UIFieldDropDownList ID="field_DataType" runat="server" Caption="Data Type" PropertyName="DataType"
            Span="Half" ValidateRequiredField="True" ToolTip="The data type of the search field."
            meta:resourcekey="field_DataTypeResource1">
        </ui:UIFieldDropDownList>
        <ui:UIFieldTextBox ID="field_CheckBoxCaption" Span="Half" Caption="Checkbox Caption"
            PropertyName="CheckboxCaption" ToolTip="The caption of the check box" runat="server"
            ValidateRequiredField="True" meta:resourcekey="field_CheckBoxCaptionResource1" />
        <ui:UIPanel runat="server" ID="panelTextBoxField" Visible="False" meta:resourcekey="panelTextBoxFieldResource1">
            <ui:UIFieldTextBox ID="field_MaxLength" runat="server" PropertyName="MaxLength" Span="Half"
                Caption="Maximum Length" ToolTip="Specify maximum number of characters to be entered in the field"
                ValidateDataTypeCheck="True" ValidationDataType="Integer" ValidateRangeField="True"
                ValidationRangeMax="4000" meta:resourcekey="field_MaxLengthResource1" />
            <ui:UIFieldCheckBox ID="field_MultiLineTextBox" runat="server" PropertyName="MultiLineTextBox"
                Span="Half" Text="Yes, This is a multi-line text box." Caption="Multi-line" meta:resourcekey="field_MultiLineTextBoxResource1" />
        </ui:UIPanel>
        <br />
        <ui:UIPanel runat="server" ID="panelListField" Visible="False" meta:resourcekey="panelListFieldResource1">
            <ui:UIFieldRadioList ID="field_IsPopulatedByCode" OnSelectedIndexChanged="field_IsPopulatedByCode_SelectedIndexChanged"
                runat="server" Caption="Populate by Code?" ValidateRequiredField="True" ToolTip="Indicate whether to populate the drop down list with a list of codes"
                PropertyName="IsPopulatedByCode" RepeatColumns="0" RepeatDirection="Vertical"
                meta:resourcekey="field_IsPopulatedByCodeResource1">
                <Items>
                    <asp:ListItem selected="True" value="1" meta:resourcekey="ListItemResource11">Yes, populate this dropdown list with a list of codes having the following code type</asp:ListItem>
                    <asp:ListItem value="0" meta:resourcekey="ListItemResource12">No, populate this dropdown list with the following list</asp:ListItem>
                </Items>
            </ui:UIFieldRadioList>
            <br />
            <ui:UIPanel runat="server" ID="panelListCode" Visible="False" meta:resourcekey="panelListCodeResource1">
                <ui:UIFieldDropDownList runat="server" ID="field_CodeTypeID" PropertyName="CodeTypeID"
                    Span="Half" Caption="Code Type" ValidateRequiredField="True" ToolTip="Specify the code type whose codes make a list to populate this field."
                    meta:resourcekey="field_CodeTypeIDResource1">
                </ui:UIFieldDropDownList>
            </ui:UIPanel>
            <br />
            <ui:UIPanel runat="server" ID="panelListValue" Visible="False" meta:resourcekey="panelListValueResource1">
                <ui:UIFieldTextBox runat="server" ID="field_TextList" PropertyName="TextList" Caption="Text List"
                    ToolTip="A comma separated list of text that will appear to the user for selection"
                    ValidateRequiredField="True" MaxLength="0" meta:resourcekey="field_TextListResource1" />
                <ui:UIFieldTextBox runat="server" ID="field_ValueList" PropertyName="ValueList" Caption="Value List"
                    ToolTip="The comma separated list of values that corresponds to the text list."
                    ValidateRequiredField="True" MaxLength="0" meta:resourcekey="field_ValueListResource1" />
            </ui:UIPanel>
        </ui:UIPanel>
        <ui:UISeparator runat="server" ID="sep1" Caption="Validation" meta:resourcekey="sep1Resource1" />
        <ui:UIFieldCheckBox runat="server" ID="field_ValidateRequiredField" PropertyName="ValidateRequiredField"
            ToolTip="Indicate whether the field is a compulsory field." Caption="Required"
            Text="Yes, this field is required" meta:resourcekey="field_ValidateRequiredFieldResource1" />
        <ui:UIFieldCheckBox runat="server" ID="field_ValidateRangeField" PropertyName="ValidateRangeField"
            ToolTip="Indicate whether the field's value must be within a specific range"
            Caption="Range" Text="Yes, this field must be within a fixed range"  OnCheckedChanged="field_ValidateRangeField_CheckedChanged"
            meta:resourcekey="field_ValidateRangeFieldResource1" />
        <br />
        <ui:UIPanel runat="server" ID="panelValidateRage" Visible="False" meta:resourcekey="panelValidateRageResource1">
            <ui:UIFieldTextBox runat="server" ID="field_ValidateRangeMin" PropertyName="ValidateRangeMin"
                Span="Half" Caption="Range Min" ToolTip="The minimum value of the range that this field could accept. Acceptable format depends on the data type of the control. For date range, using format yyyy/mm/dd. For date time range, using format yyyy/mm/dd hh:mm:ss"
                meta:resourcekey="field_ValidateRangeMinResource1" />
            <ui:UIFieldTextBox runat="server" ID="field_ValidateRangeMax" PropertyName="ValidateRangeMax"
                Span="Half" Caption="Range Max" ToolTip="The maximum value of the range that this field could accept. Acceptable format depends on the data type of the control. For date range, using format yyyy/mm/dd. For date time range, using format yyyy/mm/dd hh:mm:ss"
                meta:resourcekey="field_ValidateRangeMaxResource1" />
        </ui:UIPanel>
    </ui:UIPanel>
    <br />
    <br />
</ui:UIObjectPanel>
</ui:uipanel>