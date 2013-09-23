<%@ Control Language="C#" ClassName="objectSearchPanel" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
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
    
    /// <summary>
    /// Value for the maximum number of results returned by the search
    /// </summary>
    protected int maxSearchResult = 300;

    /// <summary>
    /// Gets or sets maximum number of results returned by the search
    /// </summary>
    [DefaultValue(300), Localizable(false)]
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

    /// <summary>
    /// Gets or sets the visibility of the simple search textbox.
    /// </summary>
    [DefaultValue(""), Localizable(false)]
    public string SearchTextBoxHint
    {
        get
        {
            return this.labelHint.Text;
        }
        set
        {
            labelHint.Text = value;
        }
    }

    /// <summary>
    /// Gets or sets the visibility of the simple search textbox.
    /// </summary>
    [DefaultValue(false), Localizable(false)]
    public bool SearchTextBoxVisible
    {
        get
        {
            return this.panelSimpleSearch.Visible;
        }
        set
        {
            this.panelSimpleSearch.Visible = value;
            this.spanSearch.Visible = !value;
        }
    }

    /// <summary>
    /// Gets or sets the caption that appears in the title of
    /// the objectSearchPanel.ascx control.
    /// </summary>
    [Localizable(true), Description("Gets or sets the caption that appears in the title of the objectSearchPanel.ascx control.")]
    public string Caption
    {
        get
        {
            return labelCaption.Text;
        }
        set
        {
            labelCaption.Text = value;
        }
    }


    /// <summary>
    /// Gets or sets the message that appears in the message bar. The message
    /// bar will show only if the Message property is not an empty string.
    /// </summary>
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    [Description("Gets or sets the message that appears in the message bar. The message bar will show only if the Message property is not an empty string.")]
    public string Message
    {
        get
        {
            return labelMessage.Text;
        }
        set
        {
            if (value != null && value.Trim() != "")
                panelMessage.Update();
            labelMessage.Text = value;
        }
    }


    /// <summary>
    /// Gets the UIObjectPanel that contains this search panel control.
    /// <para></para>
    /// Note: A UITabStrip is a subclass of the UIObjectPanel class.
    /// </summary>
    [Browsable(false), DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    [Description("Gets the UIObjectPanel that contains this search panel control.")]
    public UIObjectPanel ObjectPanel
    {
        get
        {
            // look for the containing UIForm control, and calls
            // the ValidateControls method.
            //
            Control c = this.Parent;
            while (c != null)
            {
                if (c is UIObjectPanel)
                    break;
                c = c.Parent;
            }

            // Perform the validation if possible. If the validation
            // fails, then we simply return just return without
            // calling the Clicked event.
            //
            if (c != null && c is UIObjectPanel)
                return (UIObjectPanel)c;
            else
                throw new Exception("The web:panel control must be placed in a UIObjectPanel control, but it is currently not.");
        }
    }

    /// <summary>
    /// The ID of the UIGridView control to which all results will be bound.
    /// </summary>
    protected string gridViewID = "";


    /// <summary>
    /// Gets or sets the ID of the UIGridView control to which all results will be bound.
    /// </summary>
    [DefaultValue(""), Localizable(false), IDReferenceProperty]
    [Description("Gets or sets the ID of the UIGridView control to which all results will be bound.")]
    public string GridViewID
    {
        get
        {
            return gridViewID;
        }
        set
        {
            gridViewID = value;
        }
    }


    /// <summary>
    /// The UIGridView control to which all results will be bound.
    /// </summary>
    [Browsable(false), DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    public UIGridView GridView
    {
        get
        {
            Control c = null;
            if (NamingContainer != null)
                c = NamingContainer.FindControl(gridViewID);
            if (c == null)
                c = Page.FindControl(gridViewID);
            if (c is UIGridView)
                return (UIGridView)c;
            else
                throw new Exception("There are no UIGridViews with the ID '" + gridViewID + "'");
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


    /// <summary>
    /// Gets or sets a value to indicate whether the search will be performed
    /// using a select using (tXXXX.Select) query or an Object (tXXXX.LoadList) 
    /// query.
    /// </summary>
    /// <remarks>
    /// There are two modes of searching: SelectQuery, ObjectQuery.
    /// <para></para>
    /// The SelectQuery is achieved by using the TablesLogic.tXXXX.Select(column1,
    /// column2, ...).Where(condition) method. The columns used for the query
    /// will be based on the Bound columns' PropertyName defined in the UIGridView.
    /// <para></para>
    /// The advantage of this method is fast because it performs the entire search 
    /// in a single SQL query. The disadvantage is that complex computations or
    /// transformation of data is more difficult to achieve.
    /// <para></para>
    /// The ObjectQuery is achieved by using the TablesLogic.tXXXX.LoadList(condition) 
    /// method. This method loads all objects and binds it to the UIGridView, and
    /// data from the individual PersistentObject's properties will be bound to 
    /// each individual column.
    /// <para></para>
    /// The advantage of this method is more flexibility because it uses the 
    /// PersistentObject properties, which can either be the object's database field,
    /// or a transformation programmed in C#. The disadvantage is that
    /// this method can be potentially slow, especially when the properties are
    /// too complex to compute, or executes additional queries, which mean more 
    /// access to the database.
    /// </remarks>
    [Description("Gets or sets a value to indicate whether the search will be performed using a select using (tXXXX.Select) query or an Object (tXXXX.LoadList) query.")]
    public PanelSearchType SearchType
    {
        get
        {
            if (ViewState["SearchType"] == null)
                return PanelSearchType.SelectQuery;
            return (PanelSearchType)ViewState["SearchType"];
        }
        set
        {
            ViewState["SearchType"] = value;
        }
    }


    /// <summary>
    /// Contains a list of all possible search types that the objectSearchPanel.ascx
    /// control supports.
    /// </summary>
    public enum PanelSearchType
    {
        SelectQuery,
        ObjectQuery
    }


    /// <summary>
    /// Gets or sets a flag to indicate if the Create New button is visible.
    /// </summary>
    [DefaultValue(true), Localizable(false)]
    [Description("Gets or sets a flag to indicate if the Create New button is visible.")]
    public bool AddButtonVisible
    {
        get
        {
            return spanAdd.Visible;
        }
        set
        {
            spanAdd.Visible = value;
        }
    }


    /// <summary>
    /// Gets or sets a flag to indicate if the Create New button is visible.
    /// </summary>
    [DefaultValue(true), Localizable(false)]
    [Description("Gets or sets a flag to indicate if the Add Selected button is visible.")]
    public bool AddSelectedButtonVisible
    {
        get
        {
            //return spanAddSelected.Visible;
            return commandAddSelected.Visible;
            //return buttonAddSelected.Visible;
        }
        set
        {
            //spanAddSelected.Visible = value;
            //buttonAddSelected.Visible = value;
            //literalBreak.Visible = value;
            commandAddSelected.Visible = value;
            commandVisibleSet = true;
        }
    }


    /// <summary>
    /// A flag to indicate if the Edit button is visible
    /// </summary>
    private bool editButtonVisible = true;


    /// <summary>
    /// Gets or sets a flag to indicate if the Edit button
    /// is visible.
    /// </summary>
    [DefaultValue(true), Localizable(false)]
    [Description("Gets or sets a flag to indicate if the Edit button is visible.")]
    public bool EditButtonVisible
    {
        get
        {
            return editButtonVisible;
        }
        set
        {
            editButtonVisible = value;
            spanEdit.Visible = value;
        }
    }


    /// <summary>
    /// Gets or sets a flag that indicates if the Close Window button
    /// is visible to the user.
    /// </summary>
    [DefaultValue(true), Localizable(false)]
    public bool CloseWindowButtonVisible
    {
        get
        {
            return buttonCancel.Visible;
        }
        set
        {
            buttonCancel.Visible = value;
        }
    }


    /// <summary>
    /// Gets or sets a flag to indicate if the Show Items Assigned to Me
    /// checkbox is visible.
    /// </summary>
    [DefaultValue(false), Localizable(false)]
    [Description("Gets or sets a flag to indicate if the Show Items Assigned to Me checkbox is visible.")]
    public bool AssignedCheckboxVisible
    {
        get
        {
            return divAssignedOnly.Visible;
        }
        set
        {
            divAssignedOnly.Visible = value;
        }
    }

    /// <summary>
    /// Value for the ID of the advanced search panel
    /// </summary>
    protected string advSearchID = "";

    /// <summary>
    /// Gets or sets the visibility of the simple search textbox.
    /// </summary>
    [DefaultValue(""), Localizable(false), IDReferenceProperty]
    public string AdvancedSearchPanelID
    {
        get
        {
            return this.advSearchID;
        }
        set
        {
            this.advSearchID = value;
        }
    }

    /// <summary>
    /// Gets the Panel control identified by the ID specified in AdvancedSearchPanelID.
    /// </summary>
    [DefaultValue(""), Localizable(false), IDReferenceProperty]
    [Description("Gets the Panel control identified by the ID specified in AdvancedSearchPanelID.")]
    public UIPanel AdvancedSearchPanel
    {
        get
        {
            Control c = null;
            if (NamingContainer != null)
                c = NamingContainer.FindControl(advSearchID);
            if (c == null)
                c = Page.FindControl(advSearchID);
            if (c is UIPanel)
                return (UIPanel)c;
            else
                throw new Exception("There are no Panels with the ID '" + advSearchID + "'");
        }
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
    /// Gets or sets a boolean value indicating whether the 
    /// Show Items Assigned to Me checkbox is checked.
    /// </summary>
    [DefaultValue(true), Localizable(false)]
    [Description("Gets or sets a boolean value indicating whether the Show Items Assigned to Me checkbox is checked.")]
    public bool SearchAssignedOnly
    {
        get
        {
            return AssignedOnly.Checked;
        }
        set
        {
            AssignedOnly.Checked = value;
        }
    }


    bool editAccess = false;
    int editColumnIndex = -1;
    int viewColumnIndex = -1;
    int deleteColumnIndex = -1;

    bool commandVisibleSet = false;
    UIButton buttonAddSelected = new UIButton();
    Literal literalBreak = new Literal();
    UIGridViewCommand commandAddSelected = new UIGridViewCommand();


    /// <summary>
    /// Initialize.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnInit(EventArgs e)
    {
        // grid view events
        //
        if (GridView != null)
        {
            GridView.Action += new UIGridView.RowActionEventHandler(SearchResultView_Action);
            GridView.RowDataBound += new GridViewRowEventHandler(GridView_RowDataBound);
            GridView.KeepLinksToObjectListInSession = false;
            GridView.AcquireObject += new UIGridView.AcquireObjectHandler(GridView_AcquireObject);

            if (Request["TYPE"] != null && Request["TYPE"].Trim() != "")
                editAccess = AppSession.User.AllowEditAll(Security.Decrypt(Request["TYPE"]));

            // Add a "Add Selected" button at the top of the gridview.
            //
            /*
            buttonAddSelected.ID = "buttonAddSelected2";
            buttonAddSelected.Text = "Add Selected";
            buttonAddSelected.ImageUrl = "~/images/add.gif";
            buttonAddSelected.Click += new EventHandler(buttonAddSelected_Click);
            GridView.Parent.Controls.AddAt(0, buttonAddSelected);

            literalBreak.ID = "literalBreak";
            literalBreak.Text = "<br/>";
            GridView.Parent.Controls.AddAt(1, literalBreak);
             * */
            commandAddSelected.CommandText = Resources.Strings.Results_AddSelected;
            commandAddSelected.CommandName = "AddSelected";
            commandAddSelected.ImageUrl = "~/images/add.gif";
            commandAddSelected.CausesValidation = true;
            if (!commandVisibleSet)
                commandAddSelected.Visible = false;
            GridView.Commands.Add(commandAddSelected);

        }

        base.OnInit(e);
    }


    /// <summary>
    /// Temporary hashtable used for quick access to the list of objects
    /// loaded from the database.
    /// 
    /// This variable will be populated only when the search button is
    /// clicked for the first time.
    /// </summary>
    private Hashtable hashObjects = null;


    /// <summary>
    /// Handle the method to load the object from the database
    /// and return it to the GridView for populating content.
    /// </summary>
    /// <param name="key"></param>
    /// <returns></returns>
    object GridView_AcquireObject(ArrayList list, object key)
    {
        if (SearchType == PanelSearchType.ObjectQuery)
        {
            if (hashObjects != null)
                return hashObjects[key];
            else
            {
                if (table == null)
                    GetBaseTable();

                if (list != null)
                {
                    hashObjects = new Hashtable();
                    IEnumerable ie = table.LoadObjects(table.ObjectID.In(list));
                    foreach (PersistentObject po in ie)
                        hashObjects[po.ObjectID.Value] = po;
                    return hashObjects[(Guid)key];
                }

                return table.LoadObject((Guid)key);
            }
        }

        return null;
    }


    Hashtable listOfAssignedObjects = null;


    /// <summary>
    /// This checks if the object at the current row is assigned to the
    /// current user, and shows or hides the "Edit" icon accordingly.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    void GridView_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (GridView.DataKeys[e.Row.RowIndex][0] == DBNull.Value)
            {
                if (editColumnIndex != -1)
                    if (e.Row.Cells[editColumnIndex].Controls.Count > 0)
                        e.Row.Cells[editColumnIndex].Controls[0].Visible = false;
                if (viewColumnIndex != -1)
                    if (e.Row.Cells[viewColumnIndex].Controls.Count > 0)
                        e.Row.Cells[viewColumnIndex].Controls[0].Visible = false;
                if (deleteColumnIndex != -1)
                    if (e.Row.Cells[deleteColumnIndex].Controls.Count > 0)
                        e.Row.Cells[deleteColumnIndex].Controls[0].Visible = false;

                return;
            }

            // Do not bother to hide/show the edit button if
            // the user has already selected to show only tasks assigned to her/himself.
            //
            // 2010.11.15
            // Chin Weng
            // Bug fix to include the !divAssignedOnly.Visible condition
            //
            if (!divAssignedOnly.Visible || (divAssignedOnly.Visible && !AssignedOnly.Checked))
            {
                Guid objectId = (Guid)GridView.DataKeys[e.Row.RowIndex][0];

                if (listOfAssignedObjects == null)
                {
                    List<Guid> listOfIds = new List<Guid>();
                    foreach (Guid id in GridView.ListOfDataKeys)
                        listOfIds.Add(id);
                    listOfAssignedObjects = OActivity.GetAssignmentHash(AppSession.User, listOfIds);
                }

                if (editColumnIndex != -1 && !editAccess && listOfAssignedObjects[objectId] == null)
                {
                    if (e.Row.Cells[editColumnIndex].Controls.Count > 0)
                        e.Row.Cells[editColumnIndex].Controls[0].Visible = false;
                }
            }
        }
    }


    /// <summary>
    /// Performs the appropriate action on the object, or objects selected
    /// via the checkbox.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="objectIds"></param>
    void SearchResultView_Action(object sender, string commandName, List<object> objectIds)
    {
        GetBaseTable();

        if (commandName == "DeleteObject")
        {
            bool deleted = false;

            try
            {
                Hashtable undeletedItems = new Hashtable();
                int numberOfItemsDeleted = 0;
                using (Connection c = new Connection())
                {
                    foreach (Guid objectId in objectIds)
                    {
                        PersistentObject o = table.LoadObject(objectId);
                        if (o != null)
                        {
                            bool wasDeleted = o.Deactivate();
                            if (wasDeleted)
                            {
                                deleted = true;
                                numberOfItemsDeleted++;
                            }
                            else
                                undeletedItems[objectId] = true;
                        }
                    }
                    c.Commit();
                }

                // redo search immediately after delete;
                //
                if (deleted)
                {
                    buttonSearch_Click(this, null);

                    if (numberOfItemsDeleted != objectIds.Count)
                    {
                        // Re-check those items in the checkbox
                        // that were not successfully deleted.
                        foreach (GridViewRow row in this.GridView.Rows)
                        {
                            object key = this.GridView.DataKeys[row.RowIndex][0];
                            if (undeletedItems[key] != null)
                                ((CheckBox)row.Cells[0].Controls[0]).Checked = true;
                            else
                                ((CheckBox)row.Cells[0].Controls[0]).Checked = false;
                        }
                    }
                }

                // show message to user indicating status.
                //
                string message = "";
                if (numberOfItemsDeleted > 0)
                    message += String.Format(Resources.Messages.General_ItemsDeleted, numberOfItemsDeleted) + " ";
                if (numberOfItemsDeleted != objectIds.Count)
                    message += String.Format(Resources.Messages.General_ItemsCannotBeDeleted, (objectIds.Count - numberOfItemsDeleted));
                this.Message = message;
            }
            catch (Exception ex)
            {
                this.Message = ex.Message;
            }
        }
        else if (commandName == "EditObject")
        {
            if (objectIds.Count > 0)
            {
                // pop-up the edit page for this object type
                //
                Window.OpenEditObjectPage(this.Page,
                    Security.Decrypt(Request["TYPE"]), objectIds[0].ToString(), "");
            }
        }
        else if (commandName == "ViewObject")
        {
            if (objectIds.Count > 0)
            {
                // pop-up the edit page for this object type
                //
                Window.OpenViewObjectPage(this.Page,
                    Security.Decrypt(Request["TYPE"]), objectIds[0].ToString(), "");
            }
        }
        else if (commandName == "AddSelected")
        {
            // Gets the parent UIObjectPanel that contains the UIGridView.
            // Then checks for any error messages in there.
            //
            Control control = GridView;
            while (control != null && !(control is UIObjectPanel))
                control = control.Parent;
            UIObjectPanel containingObjectPanel = control as UIObjectPanel;
            if (containingObjectPanel == null)
                throw new Exception("Unable to find a UIObjectPanel that contains the search results GridView");

            // Ensures that the everything in the object
            // panel is valid to begin within.
            //
            this.Message = "";
            if (!containingObjectPanel.IsValid)
            {
                this.Message = containingObjectPanel.CheckErrorMessages();
                return;
            }

            // Ensure that the current object is stored in session
            //
            if (Session["::SessionObject::"] == null)
            {
                Window.Close();
                return;
            }

            // Ensures that at least one item in the row is selected.
            //
            int count = 0;
            List<GridViewRow> selectedRows = new List<GridViewRow>();
            foreach (GridViewRow row in GridView.Rows)
            {
                if (row.Cells[0].Controls[0] is CheckBox &&
                    ((CheckBox)row.Cells[0].Controls[0]).Checked)
                {
                    selectedRows.Add(row);
                    count++;
                }
            }
            if (count == 0)
            {
                this.Message = Resources.Errors.General_SelectOneOrMoreItemsToAdd;
                return;
            }

            // Call the ValidateAndAddSelected event. It's up to the developer to 
            // decide what to do inside, and how to refresh the parent window,
            // and whether he/she wants the window to close.
            //
            if (ValidateAndAddSelected != null)
                ValidateAndAddSelected(this, EventArgs.Empty);

            // Show any error messages
            //
            if (!containingObjectPanel.IsValid)
            {
                this.Message = containingObjectPanel.CheckErrorMessages();
                return;
            }

            // Clear up all selected checkboxes
            //
            foreach (GridViewRow row in GridView.Rows)
                if (row.Cells[0].Controls[0] is CheckBox)
                    ((CheckBox)row.Cells[0].Controls[0]).Checked = false;
        }

    }

    /// <summary>
    /// Load.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnLoad(EventArgs e)
    {
        this.Message = "";

        base.OnLoad(e);

        int i = 0;
        if (Request["TYPE"] != null && Request["TYPE"].Trim() != "")
        {
            foreach (DataControlField column in GridView.Grid.Columns)
            {
                if (column is ButtonField)
                {
                    ButtonField buttonColumn = column as ButtonField;
                    if (buttonColumn.CommandName == "EditObject")
                        editColumnIndex = i;
                    if (buttonColumn.CommandName == "ViewObject")
                    {
                        buttonColumn.Visible = AppSession.User.AllowViewAll(Security.Decrypt(Request["TYPE"]));
                        viewColumnIndex = i;
                    }
                    if (buttonColumn.CommandName == "DeleteObject")
                    {
                        buttonColumn.Visible = AppSession.User.AllowDeleteAll(Security.Decrypt(Request["TYPE"]));
                        deleteColumnIndex = i;
                    }
                }
                i++;
            }

            foreach (UIGridViewCommand command in GridView.Commands)
            {
                if (command.CommandName == "DeleteObject")
                    command.Visible = AppSession.User.AllowDeleteAll(Security.Decrypt(Request["TYPE"]));
            }

            // For china, set the page size to 10 records.
            //
            if (ConfigurationManager.AppSettings["CustomizedInstance"] == "CHINAOPS")
            {
                this.GridView.PageSize = 10;
            }

        }

        if (!IsPostBack)
        {
            if (PopulateForm != null)
                PopulateForm(this, new EventArgs());

            SearchTextBoxVisible = !(simpleSearchFields.Trim() == "");

            buttonAdd.Text = buttonAdd.Text;
            // hide the advance search, if simple search is enabled
            if (panelSimpleSearch.Visible)
            {
                if (advSearchID != "")
                {
                    UIPanel advancedSearchPanel = AdvancedSearchPanel;
                    if (advancedSearchPanel != null)
                        advancedSearchPanel.Visible = AdvancedSearchOnLoad;
                }
                else
                {
                    //hide the show advance search button if no advancesearchpanelid is provided
                    buttonAdvanceSearch.Visible = false;
                }
            }




            // check access control, and hide the relevant view/edit/create buttons
            //
            if (Request["TYPE"] != null && Request["TYPE"].Trim() != "")
            {
                buttonAdd.Visible = AppSession.User.AllowCreate(Security.Decrypt(Request["TYPE"]));
                buttonEdit.Visible = AppSession.User.AllowEditAll(Security.Decrypt(Request["TYPE"]));
            }


            linkClose.Attributes["onclick"] = "document.getElementById('" + tableMessage.ClientID + "').style.visibility = 'hidden'";

            SetSearchOnEnter(this.ObjectPanel);

            if (AutoSearchOnLoad)
                PerformSearch();

        }




    }


    /// <summary>
    /// Recursively gets the first tree list. 
    /// </summary>
    /// <param name="c"></param>
    /// <returns></returns>
    protected UIFieldTreeList GetUIFieldTreeList(Control c)
    {
        if (c is UIFieldTreeList)
            return (UIFieldTreeList)c;

        foreach (Control child in c.Controls)
        {
            UIFieldTreeList t = GetUIFieldTreeList(child);
            if (t != null)
                return t;
        }
        return null;
    }

    /// <summary>
    /// 
    /// </summary>
    protected void SetButtonAdvancedSearch()
    {
        if (advSearchID != "")
        {
            buttonAdvanceSearch.Text = (AdvancedSearchPanel.Visible ? Resources.Strings.AdvancedSearch_Hide : Resources.Strings.AdvancedSearch_Show);
            buttonAdvanceSearch.Font.Bold = !AdvancedSearchPanel.Visible;
        }
    }


    /// <summary>
    /// Pre-render.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        panelMessage.Visible = this.Message.Trim() != "";

        Window.WriteJavascript(
            "function Refresh() { " +
            Page.ClientScript.GetPostBackEventReference(buttonSearchNoFocus.LinkButton, "") + " }");

        SetButtonAdvancedSearch();

        // NEW: 2011.06.07, Kien Trung
        // implement enter keypress to perform search when
        // 'enter' key is pressed.
        SetSearchOnEnter(this.ObjectPanel);

        // Ensure that the Edit button appears only when the first UIField control
        // is selected.
        //
        if (EditButtonVisible)
        {
            UIFieldTreeList treeList = GetUIFieldTreeList(this.Page);
            if (treeList != null)
                spanEditAfterTreeSelected.Visible = treeList.SelectedValue != "";
        }
    }


    private void SetSearchOnEnter(Control control)
    {
        //if (control is UIObjectPanel)
        //    ((UIObjectPanel)control).Attributes.Add("onkeypress", "return clickButton(event,'" + buttonSearchHidden.ClientID + "')");

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
            if (control is TextBox)
                ((TextBox)control).Attributes.Add("onkeypress", "return clickButton(event,'" + buttonSearchHidden.ClientID + "')");

            foreach (Control childControl in control.Controls)
                SetSearchOnEnter(childControl);
        }
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
    /// Clear data entered into all controls.
    /// </summary>
    /// <param name="control"></param>
    void ClearDropDownListControls(Control control)
    {
        if (control.GetType().IsSubclassOf(typeof(UIFieldBase)) && control is UIFieldDropDownList)
        {
            ((UIFieldBase)control).ControlValue = null;
            ((UIFieldBase)control).ControlValueTo = null;
        }
        else
        {
            foreach (Control childControl in control.Controls)
                ClearDropDownListControls(childControl);
        }
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
    /// The Search event handler.
    /// </summary>
    /// <param name="e"></param>
    public delegate void SearchEventHandler(SearchEventArgs e);


    /// <summary>
    /// Occurs when the user performs a search by clicking on the
    /// Perform Search button, or when the application calls
    /// the PerformSearch() method.
    /// </summary>
    [Browsable(true)]
    public event SearchEventHandler Search;

    /// <summary>
    /// The Process Result event handler.
    /// </summary>
    /// <param name="e"></param>
    public delegate void ProcessResultEventHandler(Object e);

    /// <summary>
    /// Occurs before the search result binds to the gridview
    /// in PerformSearch() method.
    /// </summary>
    [Browsable(true)]
    public event ProcessResultEventHandler ProcessResult;


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
    /// Builds an ExpressionCondition from all UIField controls on the page.
    /// </summary>
    /// <returns>An ExpressionCondition representing the tree of the
    /// SQL WHERE condition.</returns>
    public ExpressionCondition GetCondition()
    {
        if (Validate != null)
            Validate(this, new EventArgs());

        string errorMessage = ObjectPanel.CheckErrorMessages();
        if (errorMessage != null)
        {
            this.Message = errorMessage;
            return null;
        }

        if (ObjectPanel == null || GridView == null)
            return null;

        GetBaseTable();
        ExpressionCondition cond = null;
        try
        {
            cond = UIBinder.BuildCondition(table, ObjectPanel);
            if (cond == null)
                cond = Query.True;
        }
        catch
        {
            this.Message = ObjectPanel.CheckErrorMessages();
            return null;
        }

        // add condition to filter works that are assigned to the current user
        //
        if (divAssignedOnly.Visible && AssignedOnly.Checked)
        {
            TActivity tActivity = (TActivity)UIBinder.GetValue(table, "CurrentActivity", false);

            if (tActivity != null)
            {
                cond = cond &
                    (tActivity.Users.ObjectID == AppSession.User.ObjectID |
                    tActivity.Positions.ObjectID.In(AppSession.User.Positions));
            }
        }

        // build condition for the simple search textbox
        //
        if (simpleSearchFields.Trim() != "" && SimpleSearch.Text.Trim() != "")
        {
            string[] fields = simpleSearchFields.Split(',');
            string searchvalue = SimpleSearch.Text.Trim();
            ExpressionCondition scond = null;

            foreach (string field in fields)
            {
                if (scond == null)
                    scond = ((ExpressionDataString)UIBinder.GetValue(table, field.Trim(), false)).Like("%" + searchvalue + "%");
                else
                    scond = scond | ((ExpressionDataString)UIBinder.GetValue(table, field.Trim(), false)).Like("%" + searchvalue + "%");

            }

            cond = cond & (scond);
        }

        cond = cond & ((ExpressionData)UIBinder.GetValue(table, "IsDeleted", false)) == 0;

        return cond;
    }


    /// <summary>
    /// Builds an ExpressionCondition from all UIField controls on the page,
    /// then calls the Search event and ANDs the built condition and 
    /// any custom condition that the developer has defined in the
    /// SearchEventArgs.CustomCondition field.
    /// </summary>
    /// <returns>An ExpressionCondition representing the tree of the
    /// SQL WHERE condition.</returns>
    public ExpressionCondition GetConditionAndCustomCondition()
    {
        ExpressionCondition cond = GetCondition();
        if (cond == null)
            return Query.True;

        SearchEventArgs searchEventArgs = new SearchEventArgs(cond);
        if (Search != null)
            Search(searchEventArgs);

        // build the where condition automatically
        //
        if (searchEventArgs.CustomCondition != null)
        {
            ExpressionCondition cond2 = searchEventArgs.CustomCondition;
            if (cond2 == null)
                cond2 = Query.True;
            cond = cond & cond2;
        }
        return cond;
    }


    bool refreshTree = false;


    /// <summary>
    /// Peforms a search by:
    /// <list>
    /// <item>1. Obtaining the search condition through the data entered 
    ///          into the fields.</item>
    /// <item>2. Call the custom search for any add-on conditions</item>
    /// <item>3. Construct and execute the query</item>
    /// <item>4. Bind the results to the grid.</item>
    /// </list>
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonSearch_Click(object sender, EventArgs e)
    {
        this.Message = "";
        if (!ObjectPanel.IsValid)
        {
            this.Message = ObjectPanel.CheckErrorMessages();
            return;
        }

        try
        {
            System.Data.DataTable dt = null;
            IEnumerable ie = null;
            ArrayList al = new ArrayList();
            // build the condition from the form input
            //
            ExpressionCondition cond = GetCondition();
            if (cond == null)
                return;

            // call the delegate function to see if there are additional conditions,
            // or if there is a custom dataset queried by the delegate function.
            //
            SearchEventArgs searchEventArgs = new SearchEventArgs(cond);
            if (Search != null)
                Search(searchEventArgs);

            using (Connection t = new Connection(IsolationLevel.NoTransaction))
            {
                if (searchEventArgs.CustomResultTable == null)
                {
                    // build the where condition automatically
                    //
                    if (searchEventArgs.CustomCondition != null)
                    {
                        ExpressionCondition cond2 = searchEventArgs.CustomCondition;
                        if (cond2 == null)
                            cond2 = Query.True;
                        cond = cond & cond2;
                    }

                    // build condition to test if object is currently assigned
                    // to logged on user
                    //
                    if (divAssignedOnly.Visible && AssignedOnly.Checked)
                    {
                        TActivity tActivity = (TActivity)UIBinder.GetValue(table, "CurrentActivity", false);

                        if (tActivity != null)
                        {
                            cond = cond &
                                (tActivity.Users.ObjectID == AppSession.User.ObjectID |
                                tActivity.Positions.ObjectID.In(AppSession.User.Positions));
                        }
                    }

                    if (SearchType == PanelSearchType.SelectQuery)
                    {
                        // get the results for the select().where() query
                        //
                        // build the select clause automatically
                        //
                        List<ColumnAs> selectColumns = new List<ColumnAs>();
                        foreach (DataControlField c in this.GridView.Columns)
                        {
                            if (c is BoundField)
                            {
                                object obj = UIBinder.GetValue(table, ((BoundField)c).DataField, false);
                                if (obj is ExpressionData)
                                    selectColumns.Add(((ExpressionData)obj).As(((BoundField)c).DataField));

                            }
                        }

                        // make sure the main table's object ID is selected, and that the
                        // main table's object's isDeleted flag = 0
                        //
                        selectColumns.Add(((ExpressionData)UIBinder.GetValue(table, "ObjectID", false)).As("ObjectID"));

                        Query query = table.SelectDistinctTop(maxSearchResult + 1, selectColumns.ToArray()).Where(cond);
                        if (searchEventArgs.CustomGroupBy != null)
                            query = query.GroupBy(searchEventArgs.CustomGroupBy);
                        if (searchEventArgs.CustomHavingCondition != null)
                            query = query.Having(searchEventArgs.CustomHavingCondition);
                        if (searchEventArgs.CustomSortOrder != null)
                            query = query.OrderBy(searchEventArgs.CustomSortOrder.ToArray());

                        dt = query;

                        if (dt.Rows.Count > maxSearchResult)
                        {
                            dt.Rows.RemoveAt(maxSearchResult);
                            //display msg
                            this.Message = String.Format(Resources.Strings.SearchPanel_ResultExceedMax, this.maxSearchResult);
                        }
                    }
                    else
                    {
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



                        // Build a temporary hash table so
                        // that we can use it in the "AcquireObject".
                        // event handler.
                        //
                        hashObjects = new Hashtable();
                        foreach (PersistentObject p in ie)
                        {
                            hashObjects[p.ObjectID.Value] = p;
                            al.Add(p);
                        }

                        if (al.Count > maxSearchResult)
                        {
                            al.RemoveAt(maxSearchResult);
                            //display msg   
                            this.Message = String.Format(Resources.Strings.SearchPanel_ResultExceedMax, this.maxSearchResult);
                        }
                    }
                }
                else
                {
                    dt = searchEventArgs.CustomResultTable;
                }

                if (dt != null)
                {
                    if (ProcessResult != null)
                        ProcessResult(dt);

                    GridView.DataSource = dt;
                    if (dt.Rows.Count == 0)
                    {
                        GridView.EmptyDataText = Resources.Strings.GridView_NoItems;
                        GridView.CheckBoxColumnVisible = false;
                    }
                }
                else if (al != null)
                {
                    if (ProcessResult != null)
                        ProcessResult(al);

                    GridView.DataSource = al;
                    if (al.Count == 0)
                    {
                        GridView.EmptyDataText = Resources.Strings.GridView_NoItems;
                        GridView.CheckBoxColumnVisible = false;
                    }
                }


                GridView.DataBind();

                // If there is a tree list, refresh it.
                //
                if (refreshTree && EditButtonVisible)
                {
                    UIFieldTreeList treeList = GetUIFieldTreeList(this.Page);
                    if (treeList != null)
                    {
                        string selectedValue = treeList.SelectedValue;
                        treeList.PopulateTree(true);
                        treeList.SelectedValue = selectedValue;
                    }
                }

                if (sender == buttonSearch || sender == buttonSearchHidden || sender == buttonSimpleSearch)
                {
                    GridView.SetFocus();
                    //SimpleSearch.SetFocus();
                    SimpleSearch.Focus();
                }

                t.Commit();
            }
        }
        catch (Exception ex)
        {
            this.Message = ex.Message + "<br/>" + ex.StackTrace.Replace("\n", "<br/>");
        }
    }


    /// <summary>
    /// Programmatically performs a search, as if the user has clicked
    /// on the Perform Search button.
    /// </summary>
    public void PerformSearch()
    {
        buttonSearch_Click(this, new EventArgs());
    }


    /// <summary>
    /// Refresh the treeview if necessary, and re-do the search
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonSearchNoFocus_Click(object sender, EventArgs e)
    {
        refreshTree = true;
        buttonSearch_Click(sender, e);
    }

    protected void buttonSearchHidden_Click(object sender, EventArgs e)
    {
        buttonSearch_Click(sender, new EventArgs());
    }

    /// <summary>
    /// This event resets all fields in the page.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonReset_Click(object sender, EventArgs e)
    {
        // recursively traverses through all controls in the list, and
        // sets the value to null to all controls.
        // 
        if (ObjectPanel != null)
            ClearControls(ObjectPanel);

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


    /// <summary>
    /// This adds a new item by opening up the object edit window with
    /// the appropriate querystring parameters.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAdd_Click(object sender, EventArgs e)
    {
        string additionalQueryString = "";
        if (EditButtonVisible)
        {
            UIFieldTreeList treeList = GetUIFieldTreeList(this.Page);
            if (treeList != null && treeList.SelectedValue != "")
                additionalQueryString = "TREEOBJID=" + HttpUtility.UrlEncode(Security.Encrypt(treeList.SelectedValue));
        }

        Window.OpenAddObjectPage(this.Page, Security.Decrypt(Request["TYPE"]), additionalQueryString);
    }


    /// <summary>
    /// Occurs when the user clicks on the Close Window button,
    /// which instructs the system to close the window.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonCancel_Click(object sender, EventArgs e)
    {
        Window.Close();
    }


    /// <summary>
    /// This edits the item selected on the results grid by opening
    /// up the object edit window with the appropriate querystring
    /// parameters.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonEdit_Click(object sender, EventArgs e)
    {
        UIFieldTreeList treeList = GetUIFieldTreeList(this.Page);

        if (treeList != null && treeList.SelectedValue != "")
        {
            Window.OpenEditObjectPage(this.Page, Security.Decrypt(Request["TYPE"]),
                treeList.SelectedValue, "");
        }
    }


    /// <summary>
    /// Occurs when the user clicks on the Search button, 
    /// before the search is actually run against the database.
    /// </summary>
    public event EventHandler Validate;


    /// <summary>
    /// Occurs when the form is first loaded. This event is
    /// not called during post backs.
    /// </summary>
    public event EventHandler PopulateForm;


    /// <summary>
    /// Occurs after the user clicks the Add Selected button,
    /// and after all the necessary validations have taken
    /// place.
    /// </summary>
    public event EventHandler ValidateAndAddSelected;

    protected void buttonAdvanceSearch_Click(object sender, EventArgs e)
    {
        AdvancedSearchPanel.Visible = !AdvancedSearchPanel.Visible;
        ClearDropDownListControls(this.AdvancedSearchPanel);
        //buttonAdvanceSearch.Font.Bold = AdvancedSearchPanel.Visible;

    }

    protected void buttonSimpleSearch_Click(object sender, EventArgs e)
    {
        buttonSearch_Click(sender, e);
    }
</script>

<div style="min-width: 800px">
    <ui:UIPanel runat="server" ID="panelMain" Style="font-size: 0pt">
        <div class='search-caption'>
            <asp:Label ID="labelCaption" runat="server" meta:resourcekey="labelCaptionResource1"></asp:Label>
            <ui:UIButton runat="server" ID="buttonAdd" ImageUrl="~/images/plus.ico"
                Font-Bold="true" Text="Create New" OnClick="buttonAdd_Click" ConfirmText="" meta:resourcekey="buttonAddResource1">
            </ui:UIButton>
        </div>
        <div class='search-buttons'>
            <table cellpadding="0" cellspacing="0" border="0" width="100%">
                <tr>
                    <td>
                        <table border='0' cellpadding='0' cellspacing='0'>
                            <tr>
                                <td>
                                    <ui:UIPanel runat="server" ID="spanSearch">
                                        <ui:UIButton runat="server" ID="buttonSearch" ImageUrl="~/images/find.gif" Text="Perform Search"
                                            Font-Bold="true" CausesValidation="true" OnClick="buttonSearch_Click" ConfirmText=""
                                            meta:resourcekey="buttonSearchResource1"></ui:UIButton>
                                    </ui:UIPanel>
                                </td>
                                <td>
                                    <asp:Button runat="server" ID="buttonSearchHidden" UseSubmitBehavior="false" Style="display: none"
                                        OnClick="buttonSearchHidden_Click" />
                                    <ui:UIButton runat="server" ID="buttonSearchNoFocus" Text="" OnClick="buttonSearchNoFocus_Click"
                                        Style="display: none" ConfirmText="" meta:resourcekey="buttonSearchNoFocusResource1">
                                    </ui:UIButton>
                                </td>
                                <td>
                                    <ui:UIPanel runat="server" ID="spanAdd">
                                    </ui:UIPanel>
                                </td>
                                <td>
                                    <ui:UIButton runat="server" ID="buttonCancel" ImageUrl="~/images/window-delete-big.gif"
                                        Text="Close Window" Visible="false" OnClick="buttonCancel_Click" meta:resourcekey="buttonCancelResource1">
                                    </ui:UIButton>
                                </td>
                                <td>
                                    <ui:UIPanel runat="server" ID="spanEditAfterTreeSelected">
                                        <ui:UIPanel runat="server" ID="spanEdit">
                                            <ui:UIButton runat="server" ID="buttonEdit" ImageUrl="~/images/symbol-edit-big.gif"
                                                Font-Bold="true" Text="Edit Item" OnClick="buttonEdit_Click" ConfirmText="" meta:resourcekey="buttonEditResource1">
                                            </ui:UIButton>
                                        </ui:UIPanel>
                                    </ui:UIPanel>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td align="right">
                        <ui:UIPanel runat="server" ID="divAssignedOnly" Visible="false">
                            <asp:Image runat="server" ID="imageUser" ImageUrl="~/images/assigned.gif" ImageAlign="absMiddle" />
                            <asp:CheckBox runat="server" ID="AssignedOnly" Text="Show only items assigned to me"
                                Checked="false" meta:resourcekey="AssignedOnlyResource1"></asp:CheckBox>
                            &nbsp; &nbsp; &nbsp;
                        </ui:UIPanel>
                    </td>
                </tr>
            </table>
        </div>
        <ui:UIPanel runat="server" ID="panelSimpleSearch" BorderStyle="NotSet">
            <div style='padding: 12px 12px 0px 170px; font-size: 12pt'>
                <asp:TextBox runat="server" ID="SimpleSearch" Width="600px" Height="30px"></asp:TextBox>
                <asp:Label runat="server" ID="labelHint" Width="98%" Text="" CssClass="field-hint"></asp:Label>
                <asp:TextBoxWatermarkExtender runat="server" ID="twe" TargetControlID="SimpleSearch" 
                    WatermarkCssClass="field-hint" WatermarkText="Search...">
                </asp:TextBoxWatermarkExtender>
            </div>
            <table>
                <tr>
                    <td width="158px">
                    </td>
                    <td align="left">
                        <ui:UIPanel runat="server" ID="spanSimpleSearch">
                            <ui:UIButton runat="server" ID="buttonSimpleSearch" ImageUrl="~/images/find.gif"
                                Text="Search" Font-Bold="true" CausesValidation="true" ConfirmText="" OnClick="buttonSimpleSearch_Click"
                                meta:resourcekey="buttonSearchResource1"></ui:UIButton>
                            <ui:UIButton runat="server" ID="buttonReset" ImageUrl="~/images/symbol-refresh-big.gif"
                                Font-Bold="true" Text="Reset All Fields" OnClick="buttonReset_Click" ConfirmText=""
                                meta:resourcekey="buttonResetResource1"></ui:UIButton>
                            <ui:UIButton runat="server" ID="buttonAdvanceSearch" Text="Advanced Search" OnClick="buttonAdvanceSearch_Click" />
                        </ui:UIPanel>
                    </td>
                </tr>
            </table>
        </ui:UIPanel>
        <ui:UIPanel runat="server" ID="panelMessage" HorizontalAlign="Center">
            <div runat="server" id="tableMessage" class="object-message" style="top: -50px; width: 100%;
                position: absolute;">
                <table style="width: 100%" cellpadding="5">
                    <tr>
                        <td>
                            <table border="0" cellspacing="0" cellpadding="0" width="100%">
                                <tr valign="top">
                                    <td align="left">
                                        <asp:Label runat='server' ID='labelMessage' meta:resourcekey="labelMessageResource1">
                                        </asp:Label>
                                    </td>
                                    <td align="right">
                                        <asp:HyperLink runat="server" ID="linkClose" Text="Hide" NavigateUrl="javascript:void(0)"></asp:HyperLink>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </div>
            <asp:AnimationExtender ID="AnimationExtender1" runat="server" TargetControlID="tableMessage">
                <Animations>
                    <OnLoad>
                        <Parallel duration="0.3">
                            <FadeIn fps="10"></FadeIn>
                            <Move vertical="50" fps="10"></Move>
                        </Parallel>
                    </OnLoad>
                </Animations>
            </asp:AnimationExtender>
            <asp:AlwaysVisibleControlExtender runat="server" ID="acv1" TargetControlID="tableMessage">
            </asp:AlwaysVisibleControlExtender>
        </ui:UIPanel>
    </ui:UIPanel>
</div>
