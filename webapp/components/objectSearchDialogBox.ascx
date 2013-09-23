<%@ Control Language="C#" ClassName="objectSearchDialogBox" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.ComponentModel" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="Anacle.WorkflowFramework" %>

<script language="javascript">
    function clickButton(e, buttonid) {

        var evt = e ? e : window.event;
        var bt = document.getElementById(buttonid);

        if (evt.keyCode == 13 || evt.which == 13) {
            evt.returnValue = false;
            evt.cancel = true;
            bt.click();
            return false;
        }
    }


</script>

<script runat="server">
    private List<object> selectedDataKeys;

    private List<GridViewRow> selectedRows;

    public List<GridViewRow> SelectedRows
    {
        get { return selectedRows; }
    }

    public List<object> SelectedDataKeys
    {
        get { return selectedDataKeys; }
    }

    public string SimpleTextboxHint
    {
        get
        {
            return this.labelHint.Text;
        }
        set
        {
            this.labelHint.Text = value;
        }
    }

    /// <summary>
    /// Gets or sets a flag indicating whether the search should be automatically
    /// performed when the page is loaded.
    /// </summary>
    [DefaultValue(false)]
    public bool AutoSearchOnLoad
    {
        get
        {
            if (ViewState["AutoSearchOnLoad"] == null)
                return false;
            return (bool)ViewState["AutoSearchOnLoad"];
        }
        set
        {
            ViewState["AutoSearchOnLoad"] = value;
        }
    }

    [DefaultValue(false)]
    public bool AdvancedSearchOnLoad
    {
        get
        {
            if (ViewState["AdvancedSearchOnLoad"] == null)
                return false;
            return (bool)ViewState["AdvancedSearchOnLoad"];
        }
        set
        {
            ViewState["AdvancedSearchOnLoad"] = value;
        }
    }

    [DefaultValue(true)]
    public bool ButtonAddVisible
    {
        get
        {
            if (SearchDialogBox.Button1.Visible == null)
                return true;
            return (bool)SearchDialogBox.Button1.Visible;
        }
        set
        {
            SearchDialogBox.Button1.Visible = value;
        }
    }

    [DefaultValue(true)]
    public bool AdvancedSearchButtonVisible
    {
        get
        {
            if (ShowHideAdvancedSearch.Visible == null)
                return true;
            return (bool)ShowHideAdvancedSearch.Visible;
        }
        set
        {
            ShowHideAdvancedSearch.Visible = value;
        }
    }

    public UIGridView SearchUIGridView
    {
        get
        {
            return this.SearchGridView;
        }
    }

    /// <summary>
    /// 
    /// </summary>
    public event EventHandler Selected;

    /// <summary>
    /// 
    /// </summary>
    public event EventHandler Cleared;

    /// <summary>
    /// The Search event handler.
    /// </summary>
    /// <param name="e"></param>
    public delegate void SearchEventHandler(SearchEventArgs e);

    [Browsable(true)]
    public event SearchEventHandler Searched;

    public string Title
    {
        get { return SearchDialogBox.Title; }
        set { SearchDialogBox.Title = value; }
    }

    public string ButtonAddText
    {
        get { return SearchDialogBox.Button1.Text; }
        set { SearchDialogBox.Button1.Text = value; }
    }

    public string ButtonAddImageURL
    {
        get { return SearchDialogBox.Button1.ImageUrl; }
        set { SearchDialogBox.Button1.ImageUrl = value; }
    }

    public string ButtonSelectText
    {
        get { return buttonSelect.Text; }
        set { buttonSelect.Text = value; }
    }

    public string ButtonSelectImageURL
    {
        get { return buttonSelect.ImageUrl; }
        set { buttonSelect.ImageUrl = value; }
    }

    public bool Enabled
    {
        get { return buttonSelect.Enabled; }
        set { buttonSelect.Enabled = value; buttonClear.Enabled = value; }
    }

    public UIButton ButtonSelect
    {
        get { return buttonSelect; }
    }

    public UIButton ButtonClear
    {
        get { return buttonClear; }
    }

    public string ButtonClearText
    {
        get { return buttonClear.Text; }
        set { buttonClear.Text = value; }
    }

    public string ButtonClearImageURL
    {
        get { return buttonClear.ImageUrl; }
        set { buttonClear.ImageUrl = value; }
    }

    [DefaultValue(true)]
    public bool AllowMultipleSelection
    {
        get { return SearchGridView.CheckBoxColumnVisible; }
        set
        {
            SearchGridView.CheckBoxColumnVisible = value;
            SearchDialogBox.Button1.Visible = value;
        }
    }


    public int PageSize
    {
        get { return SearchGridView.PageSize; }
        set { SearchGridView.PageSize = value; }
    }

    /// <summary>
    /// The name of the base table as declared in the TablesLogic class.
    /// This should be something like "tWork", or "tLocation", or
    /// "tUser".
    /// </summary>
    protected string baseTable;


    /// <summary>
    /// Gets or sets the name of the base table as declared in the TablesLogic
    /// class. This should be something like "tWork", or "tLocation", or
    /// "tUser".
    /// </summary>
    public string BaseTable
    {
        get
        {
            return baseTable;
        }
        set
        {
            baseTable = value;
        }
    }

    SchemaBase table = null;

    /// <summary>
    /// Reflect on the Tables class and get the object whose name is
    /// specified in the BaseTable property.
    /// </summary>
    private void GetBaseTable()
    {
        Type baseTableType = typeof(TablesLogic);
        string baseTableName = baseTable;
        if (baseTable.StartsWith("TablesLogic."))
        {
            baseTableType = typeof(TablesLogic);
            baseTableName = baseTableName.Replace("TablesLogic.", "");
        }
        else if (baseTable.StartsWith("TablesWorkflow."))
        {
            baseTableType = typeof(TablesWorkflow);
            baseTableName = baseTableName.Replace("TablesWorkflow.", "");
        }
        else if (baseTable.StartsWith("TablesAuditTrail."))
        {
            baseTableType = typeof(TablesAuditTrail);
            baseTableName = baseTableName.Replace("TablesAuditTrail.", "");
        }

        table = (SchemaBase)UIBinder.GetValue(baseTableType, baseTableName, true);
        if (table == null)
            throw new Exception("Unknown table '" + baseTable + "'");
    }

    /// <summary>
    /// Comma seperated values of property names used for simple search
    /// </summary>
    protected string simpleSearchFields = "";

    /// <summary>
    /// Gets or sets the visibility of the simple search textbox.
    /// </summary>
    [DefaultValue(""), Localizable(false)]
    public string SearchTextBoxPropertyNames
    {
        get
        {
            return this.simpleSearchFields;
        }
        set
        {
            this.simpleSearchFields = value;
        }
    }

    /// <summary>
    /// Builds an ExpressionCondition from all UIField controls on the page.
    /// </summary>
    /// <returns>An ExpressionCondition representing the tree of the
    /// SQL WHERE condition.</returns>
    public ExpressionCondition GetCondition()
    {
        ExpressionCondition cond = null;


        GetBaseTable();

        try
        {
            cond = UIBinder.BuildCondition(table, AdvancedPanel);
            if (cond == null)
                cond = Query.True;
        }
        catch
        {
            return null;
        }


        // build condition for the simple search textbox
        if (SearchTextBox.Text.Trim() != "")
        {
            string[] fields = simpleSearchFields.Split(',');
            string searchvalue = SearchTextBox.Text.Trim();
            string[] searchvalueArray = SearchTextBox.Text.Trim().Split(' ');
            ExpressionCondition scond = null;

            if (SearchType == PanelSearchType.Phrase)
            {
                foreach (string field in fields)
                {
                    if (scond == null)
                        scond = ((ExpressionDataString)UIBinder.GetValue(table, field.Trim(), false)).Like("%" + searchvalue + "%");
                    else
                        scond = scond | ((ExpressionDataString)UIBinder.GetValue(table, field.Trim(), false)).Like("%" + searchvalue + "%");

                }
            }

            if (SearchType == PanelSearchType.Word)
            {
                foreach (string field in fields)
                {
                    for (int j = 0; j < searchvalueArray.Length; j++)
                    {
                        if (scond == null)
                            scond = ((ExpressionDataString)UIBinder.GetValue(table, field.Trim(), false)).Like("%" + searchvalueArray[j] + "%");
                        else
                            scond = scond | ((ExpressionDataString)UIBinder.GetValue(table, field.Trim(), false)).Like("%" + searchvalueArray[j] + "%");
                    }

                }
            }

            ExpressionCondition acond = Query.False;
            selectedDataKeys = new List<object>();

            foreach (GridViewRow GVR in SearchGridView.Rows)
            {
                if (GVR.RowType == DataControlRowType.DataRow)
                {
                    CheckBox checkbox = GVR.Cells[0].Controls[0] as CheckBox;
                    if (checkbox != null && checkbox.Checked)
                    {
                        if (acond == null)
                            acond = ((ExpressionData)UIBinder.GetValue(table, "ObjectID", false)) == (Guid)(SearchGridView.DataKeys[GVR.RowIndex].Value);
                        else
                            acond = acond | ((ExpressionData)UIBinder.GetValue(table, "ObjectID", false)) == (Guid)(SearchGridView.DataKeys[GVR.RowIndex].Value);
                        selectedDataKeys.Add(SearchGridView.DataKeys[GVR.RowIndex].Value);
                    }
                }
            }

            cond = (cond & (scond)) | acond;
        }

        cond = cond & ((ExpressionData)UIBinder.GetValue(table, "IsDeleted", false)) == 0;

        return cond;
    }

    [Description("Gets or sets a value to indicate whether the search will be performed using a select using (tXXXX.Select) query or an Object (tXXXX.LoadList) query.")]
    public PanelSearchType SearchType
    {
        get
        {
            if (ViewState["SearchType"] == null)
                return PanelSearchType.Phrase;
            return (PanelSearchType)ViewState["SearchType"];
        }
        set
        {
            ViewState["SearchType"] = value;
        }
    }

    /// <summary>
    /// Contains a list of all possible search types that the objectSearchDialogBox.ascx
    /// control supports.
    /// </summary>
    public enum PanelSearchType
    {
        Word,
        Phrase
    }

    /// <summary>
    /// Value for the maximum number of results returned by the search
    /// </summary>
    protected int maxSearchResult = 300;

    /// <summary>
    /// Gets or sets maximum number of results returned by the search
    /// </summary>
    [DefaultValue(500), Localizable(false)]
    public int MaximumNumberOfResults
    {
        get
        {
            return this.maxSearchResult;
        }
        set
        {
            this.maxSearchResult = value;
        }
    }

    [PersistenceMode(PersistenceMode.InnerProperty)]
    public virtual List<DataControlField> Columns
    {
        get { return SearchGridView.Columns; }
    }

    [PersistenceMode(PersistenceMode.InnerProperty)]
    public virtual UIObjectPanel AdvancedPanel
    {
        get { return MainPanel; }
    }

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
    }

    public void DataBind()
    {
        SearchGridView.DataBind();
    }


    public void Hide()
    {
        SearchDialogBox.Hide();
    }

    /// <summary>
    /// Clear data entered into all controls.
    /// </summary>
    /// <param name="control"></param>
    void ClearControls(Control control)
    {
        if (control.GetType().IsSubclassOf(typeof(UIFieldBase)))
        {
            ((UIFieldBase)control).ControlValue = null;
            ((UIFieldBase)control).ControlValueTo = null;
        }
        else
        {
            foreach (Control childControl in control.Controls)
                ClearControls(childControl);
        }
    }


    /// <summary>
    /// Set ImageClearUrl for date time control in components
    /// Cannot be display if set it at aspx page.
    /// currently, there is no other solution.
    /// </summary>
    /// <param name="control"></param>
    private void SetDateTimeControlsImage(Control control)
    {

        if (control.GetType().IsSubclassOf(typeof(UIFieldBase)))
        {
            if (control is UIFieldDateTime)
            {
                ((UIFieldDateTime)control).ImageClearUrl = ResolveUrl("~/images/cross.gif");
                ((UIFieldDateTime)control).Control.ImageClearUrl = ResolveUrl("~/images/cross.gif");
            }

        }
        else
        {
            foreach (Control childControl in control.Controls)
                SetDateTimeControlsImage(childControl);
        }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="control"></param>
    private void SetSearchOnEnter(Control control)
    {

        SearchTextBox.Attributes.Add("onkeypress", "return clickButton(event,'" + buttonSearchHidden.ClientID + "')");

        // NEW: 2011.06.07, Kien Trung
        // implement keypress attributes to capture enter key
        // perform search when there is text box with key press enter.
        if (control.GetType().IsSubclassOf(typeof(UIFieldBase)))
        {
            if (control is UIFieldTextBox)
                ((UIFieldTextBox)control).Attributes.Add("onkeypress", "return clickButton(event,'" + buttonSearchHidden.ClientID + "')");

        }
        else
        {
            foreach (Control childControl in control.Controls)
                SetSearchOnEnter(childControl);
        }
    }

    public void Show()
    {
        SearchTextBox.Text = "";

        AdvancedPanel.Visible = AdvancedSearchOnLoad;

        // Clear values of all the advanced controls
        //
        ClearControls(MainPanel);

        // Auto search on showing
        //
        if (AutoSearchOnLoad)
            SearchButton_Click(this, EventArgs.Empty);
        else
        {
            SearchGridView.DataSource = null;
            SearchGridView.DataBind();
        }

        // Hide or show checkboxes search grid view
        // if allow multiple selection.
        if (AllowMultipleSelection)
        {
            foreach (GridViewRow row in this.SearchGridView.Rows)
            {
                ((CheckBox)row.Cells[0].Controls[0]).Checked = false;
            }
        }

        SetSearchOnEnter(AdvancedPanel);


        SearchDialogBox.Show();

        SearchTextBox.Focus();

        SearchTextBox.AutoCompleteType = AutoCompleteType.Search;

    }



    protected void SearchButton_Click(object sender, EventArgs e)
    {
        // build the condition from the form input
        //
        ExpressionCondition cond = GetCondition();
        if (cond == null)
            return;

        IEnumerable ie = null;

        // call the delegate function to see if there are additional conditions,
        // or if there is a custom dataset queried by the delegate function.
        //
        SearchEventArgs searchEventArgs = new SearchEventArgs(cond);
        if (Searched != null)
            Searched(searchEventArgs);

        // build the TablesLogic.tXXXX[] query
        //
        if (searchEventArgs.CustomCondition != null)
        {
            ExpressionCondition cond2 = searchEventArgs.CustomCondition;
            if (cond2 == null)
                cond2 = Query.True;
            cond = cond & cond2;
        }

        // build the TablesLogic.tXXXX[] query
        //
        if (searchEventArgs.CustomSortOrder != null)
        {
            if (searchEventArgs.CustomHavingCondition != null)
                ie = table.LoadObjects(cond, searchEventArgs.CustomHavingCondition, false, maxSearchResult + 1, searchEventArgs.CustomSortOrder.ToArray());
            else
                ie = table.LoadObjects(cond, null, false, maxSearchResult + 1, searchEventArgs.CustomSortOrder.ToArray());
        }
        else
        {
            if (searchEventArgs.CustomHavingCondition != null)
                ie = table.LoadObjects(cond, searchEventArgs.CustomHavingCondition, false, maxSearchResult + 1, null);
            else
                ie = table.LoadObjects(cond, null, false, maxSearchResult + 1, null);
        }

        SearchGridView.DataSource = ie;
        SearchGridView.DataBind();

        SearchTextBox.Focus();
        SearchTextBox.AutoCompleteType = AutoCompleteType.Search;
    }


    protected void SearchGridView_Action(object sender, string commandName, List<object> dataKeys)
    {
        selectedDataKeys = dataKeys;
        selectedRows = SearchGridView.GetSelectedRows();

        SearchDialogBox.Hide();
        if (Selected != null)
            Selected(this, EventArgs.Empty);
    }



    protected void buttonAdd_Click(object sender, EventArgs e)
    {
        selectedDataKeys = SearchGridView.GetSelectedKeys();
        selectedRows = SearchGridView.GetSelectedRows();

        SearchDialogBox.Hide();

        if (Selected != null)
            Selected(this, EventArgs.Empty);

    }

    protected void buttonCancel_Click(object sender, EventArgs e)
    {
        Hide();

    }

    protected void buttonSearchHidden_Click(object sender, EventArgs e)
    {
        SearchButton_Click(this, EventArgs.Empty);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
    }


    protected void Page_PreRender(object sender, EventArgs e)
    {
        SetSearchOnEnter(this.AdvancedPanel);

        SetDateTimeControlsImage(this.AdvancedPanel);

        ShowHideAdvancedSearch.Font.Bold = MainPanel.Visible;
    }

    /// <summary>
    /// Represents a set of arguments to be used by the Search event
    /// to customize the condition of the search, or the results of
    /// the search.
    /// </summary>
    public class SearchEventArgs
    {
        /// <summary>
        /// The ExpressionCondition representing the SQL where condition
        /// built automatically from all UIField controls using their
        /// PropertyName and the value entered by the user.
        /// </summary>
        public readonly ExpressionCondition InputCondition = null;

        /// <summary>
        /// The ExpressionCondition representing the SQL where condition
        /// that will be AND-ed with the InputCondition (the condition
        /// built automatically from all UIField controls using their
        /// PropertyName and the value entered by the user) to form
        /// the condition used to run against the database.
        /// </summary>
        public ExpressionCondition CustomCondition = null;

        /// <summary>
        /// An array of ExpressionData representing the columns
        /// in the table or the output to group the results by.
        /// </summary>
        public ExpressionData[] CustomGroupBy = null;

        /// <summary>
        /// The ExpressionCondition representing the SQL having
        /// condition that will be used as part of the query.
        /// </summary>
        public ExpressionCondition CustomHavingCondition = null;

        /// <summary>
        /// The order that the results should be sorted by.
        /// <para></para>
        /// Note: The results are always sorted by ObjectName by default. 
        /// </summary>
        public List<ColumnOrder> CustomSortOrder = null;

        /// <summary>
        /// The custom result DataTable that will be bound to the results.
        /// When specified, the objectSearchPanel.ascx will not perform
        /// a search against the database but instead bind this 
        /// CustomResultTable to the GridView.
        /// </summary>
        public System.Data.DataTable CustomResultTable = null;


        /// <summary>
        /// Constructor.
        /// </summary>
        /// <param name="conditionFromUserInput"></param>
        public SearchEventArgs(ExpressionCondition conditionFromUserInput)
        {
            InputCondition = conditionFromUserInput;
        }
    }

    protected void buttonSelect_Click(object sender, EventArgs e)
    {
        Show();
    }

    protected void buttonClear_Click(object sender, EventArgs e)
    {
        if (Cleared != null)
            Cleared(this, EventArgs.Empty);
    }


    protected void SearchDialogBox_ButtonClicked(object sender, ButtonClickedEventArgs e)
    {
        if (e.CommandName == "Cancel")
            Hide();
        if (e.CommandName == "Add")
        {
            selectedDataKeys = SearchGridView.GetSelectedKeys();
            selectedRows = SearchGridView.GetSelectedRows();

            SearchDialogBox.Hide();

            if (Selected != null)
                Selected(this, EventArgs.Empty);
        }
    }

    protected void ShowHideAdvancedSearch_Click(object sender, EventArgs e)
    {
        MainPanel.Visible = !MainPanel.Visible;
    }

    protected void SearchGridView_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            // Default to check the box if item has no awarded vendor.
            //
            CheckBox checkbox = e.Row.Cells[0].Controls[0] as CheckBox;
            if (checkbox != null && selectedDataKeys != null &&
                selectedDataKeys.Contains(SearchGridView.DataKeys[e.Row.RowIndex].Value))
            {
                checkbox.Checked = true;
            }
        }
    }
</script>

<ui:UIButton runat="server" ID="buttonSelect" Text="" ImageUrl="" CausesValidation="false"
    OnClick="buttonSelect_Click" Font-Bold="true" />
<ui:UIButton runat="server" ID="buttonClear" Text="Clear" ImageUrl="~/images/cross.png"
    CausesValidation="false" Visible="false" Font-Bold="true" OnClick="buttonClear_Click" />
<ui:UIDialogBox runat="server" ID="SearchDialogBox" DialogWidth="650px" Button1AlwaysEnabled="true"
    Button1AutoClosesDialogBox="true" Button1CausesValidation="false" Button1CommandName="Add"
    Button1FontBold="true" Button1Text="Add Selected" Button1ImageUrl="~/images/add.gif"
    Button2AlwaysEnabled="true" Button2AutoClosesDialogBox="true" Button2CausesValidation="false"
    Button2CommandName="Cancel" Button2FontBold="true" Button2Text="Cancel" Button2ImageUrl="~/images/delete.gif"
    OnButtonClicked="SearchDialogBox_ButtonClicked">
    <%--<div style='width:780px; height: 450px; right'>--%>
    <%--<div style='padding: 0px 0px 0px 0px; font-size:8pt'>
            
        </div>--%>
    <ui:UIPanel runat="server" ID="panelDialogSearch" BorderStyle="NotSet">
        <table>
            <tr>
                <td style='width: 370px'>
                    <asp:TextBox runat="server" ID="SearchTextBox" Width="98%"></asp:TextBox>
                    <asp:TextBoxWatermarkExtender runat="server" ID="twe" TargetControlID="SearchTextBox"
                        WatermarkCssClass="field-hint" WatermarkText="Write something you want to search...">
                    </asp:TextBoxWatermarkExtender>
                </td>
                <td align="left">
                    <ui:UIButton runat="server" ID="SearchButton" Text="Search" ImageUrl="~/images/view.gif"
                        OnClick="SearchButton_Click" />
                    <ui:UIButton runat="server" ID="ShowHideAdvancedSearch" Text="Show Advanced Search"
                        OnClick="ShowHideAdvancedSearch_Click" />
                    <asp:Button runat="server" ID="buttonSearchHidden" UseSubmitBehavior="false" Style="display: none"
                        OnClick="buttonSearchHidden_Click" />
                </td>
            </tr>
            <tr>
                <asp:Label runat="server" ID="labelHint" Width="98%" Text="" CssClass="field-hint"></asp:Label>
            </tr>
        </table>
        <br />
        <ui:UIObjectPanel runat="server" ID="MainPanel" BorderStyle="NotSet" Width="700px"
            Visible="false">
        </ui:UIObjectPanel>
        <ui:UIGridView runat="server" ID="SearchGridView" CheckBoxColumnVisible="false" OnAction="SearchGridView_Action"
            DataKeyNames="ObjectID" BindObjectsToRows="true" Width="100%" ScrollableRows="true"
            ScrollableHeight="300px" AllowPaging="false" OnRowDataBound="SearchGridView_RowDataBound">
            <Columns>
            </Columns>
        </ui:UIGridView>
    </ui:UIPanel>
    <%--</div>--%>
</ui:UIDialogBox>
<%--
 // 2011.06.27, Kien Trung
 // This part commented out because abell60 already
 // ported UIDialogBox for Capitaland--%>
<%--<asp:LinkButton runat="server" ID="buttonAddHidden" />
<asp:ModalPopupExtender runat='server' ID="SearchDialogBox" PopupControlID="objectPanelPopup"
    BackgroundCssClass="modalBackground" TargetControlID="buttonAddHidden">
</asp:ModalPopupExtender>
<ui:UIObjectPanel runat="server" ID="objectPanelPopup" CssClass="dialog" Width="800px" BackColor="White">
    <table cellpadding='4' cellspacing='0' border='0' style="border-bottom: solid 1px gray; width: 100%">
        <tr>
            <td class="dialog-title">     
                <ui:UIFieldLabel runat="server" ID='labelTitle' Font-Bold="true" Font-Size="Large" FieldLayout="Flow" Span="Half" InternalControlWidth='750px' ShowCaption="false"></ui:UIFieldLabel>
            </td>
        </tr>
    </table>
    <table cellpadding='4' cellspacing='0' border='0' style="border-top: solid 1px gray; width: 100%">
        <tr>
            <td>
                <div style='width:780px; height: 500px; right'>
                    <ui:UIFieldTextBox runat="server" ID="SearchTextBox" Caption="Search" InternalControlWidth="500px" ShowCaption='false' FieldLayout="Flow"></ui:UIFieldTextBox>
                    <ui:UIButton runat="server" ID="SearchButton" Text="" ImageUrl="~/images/view.gif" OnClick="SearchButton_Click" />
                    <asp:Button runat="server" ID="buttonSearchHidden" UseSubmitBehavior="false" style="display:none" OnClick="buttonSearchHidden_Click" />
                    <br />
                    <ui:UIGridView runat="server" ID="SearchGridView" CheckBoxColumnVisible="false" 
                        OnAction="SearchGridView_Action" DataKeyNames="ObjectID"
                        BindObjectsToRows="true"
                        ScrollableRows="true" ScrollableHeight="400px" AllowPaging="false">
                    <Columns>
                    </Columns>
                    </ui:UIGridView>
                </div>
            </td>
        </tr>
    </table>
    <table cellpadding='4' cellspacing='0' border='0' style="border-top: solid 1px gray; width: 100%">
        <tr>
            <td class="dialog-buttons">
                <ui:UIButton runat="server" ID="buttonAdd" CommandName="AddObjects" Text="Add Selected" CausesValidation="true" ImageUrl="~/images/add.gif" OnClick="buttonAdd_Click" Font-Bold="true" />
                <ui:UIButton runat="server" ID="buttonCancel" CommandName="CancelObject" Text="Cancel" CausesValidation="false" ImageUrl="~/images/delete.gif" OnClick="buttonCancel_Click" Font-Bold="true" />
                <asp:Button runat="server" ID="buttonCancelHidden" UseSubmitBehavior="false" style="display:none" OnClick="buttonCancelHidden_Click" />
            </td>
            
        </tr>
    </table>    
</ui:UIObjectPanel>
--%>