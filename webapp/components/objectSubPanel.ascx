<%@ Control Language="C#" ClassName="objectSubPanel" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.ComponentModel" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System.Workflow.ComponentModel.Compiler" %>
<%@ Import Namespace="Anacle.WorkflowFramework" %>
<%@ Register Src="objectPanel.ascx" TagPrefix="web2" TagName="object" %>

<script runat="server">
    /// <summary>
    /// Gets or sets a flag to indicate if the Update buttons are visible.
    /// </summary>
    [DefaultValue(true), Localizable(false)]
    public bool UpdateButtonsVisible
    {
        get
        {
            return spanUpdateButtons.Visible;
        }
        set
        {
            spanUpdateButtons.Visible = value;
        }
    }

    private bool updatePopupVisible = false;

    /// <summary>
    /// 2011 06 02, Kien Trung, Update a flag to set modal popup visibility
    /// Gets or sets a flag to indicate if the subpanel popup is visible.
    /// By default the UpdatePopupVisible is set to false, then the normal
    /// subpanel will be visible.
    /// If the UpdatePopupVisible is set to true, a modal popup will be visible.
    /// </summary>
    [DefaultValue(false), Localizable(false)]
    public bool UpdatePopupVisible
    {
        get
        {
            return popupAdd.Enabled;
        }
        set
        {
            popupAdd.Enabled = value;
        }
    }


    /// <summary>
    /// Gets or sets a flag to indicate if the Update button is visible.
    /// <para></para>
    /// If the UpdateButtonsVisible is set to false, then both
    /// 'Update' and 'UpdateAndNew' buttons will be invisible, regardless
    /// of this flag.
    /// </summary>
    [DefaultValue(true), Localizable(false)]
    public bool UpdateButtonVisible
    {
        get
        {
            return buttonUpdate.Visible;
        }
        set
        {
            buttonUpdate.Visible = value;
        }
    }


    /// <summary>
    /// Gets or sets a flag to indicate if the Update and New button is visible.
    /// <para></para>
    /// If the UpdateButtonsVisible is set to false, then both
    /// 'Update' and 'UpdateAndNew' buttons will be invisible, regardless
    /// of this flag.
    /// </summary>
    [DefaultValue(true), Localizable(false)]
    public bool UpdateAndNewButtonVisible
    {
        get
        {
            return buttonUpdateAndNew.Visible;
        }
        set
        {
            buttonUpdateAndNew.Visible = value;
        }
    }


    /// <summary>
    /// Gets or sets the visible property of the cancel button.
    /// </summary>
    public bool CancelVisible
    {
        get { return spanCancel.Visible; }
        set { spanCancel.Visible = value; }
    }


    /// <summary>
    /// Gets or sets the confirmation text that will appear if the user clicks
    /// on any of the Update button.
    /// </summary>
    public string SavingConfirmationText
    {
        get
        {
            return buttonUpdate.ConfirmText;
        }
        set
        {
            buttonUpdate.ConfirmText = value;
        }
    }


    /// <summary>
    /// Gets the object currently stored in the session. 
    /// <para>
    /// </para>
    /// Application developers are encouraged to use this
    /// together with the panel's BindObjectToControls
    /// and BindControlsToObject methods to perform
    /// binding, instead of CurrentObject.
    /// </summary>
    [Browsable(false)]
    public LogicLayerPersistentObject SessionObject
    {
        get { return Page.Session[GetObjectSessionKey()] as LogicLayerPersistentObject; }
    }


    PersistentObject currentObject;
    

    /// <summary>
    /// Gets the object currently stored in the session and
    /// binds it to and from the user interface at the same time.
    /// <para>
    /// </para>
    /// Application developers are encouraged to use SessionObject
    /// together with the panel's BindObjectToControls and 
    /// BindControlsToObject methods instead of this.
    /// </summary>
    [Obsolete("Consider using SessionObject instead.")]
    [Browsable(false)]
    [DefaultValue(null), Localizable(false)]
    public PersistentObject CurrentObject
    {
        get
        {
            if (currentObject == null)
            {
                PersistentObject o = (PersistentObject)Page.Session[GetObjectSessionKey()];
                if (o != null)
                    ObjectPanel.BindControlsToObject(o);
                currentObject = o;
            }
            return currentObject;
        }
        set
        {
            // set the object
            //
            currentObject = value;
            Page.Session[GetObjectSessionKey()] = value;
            ObjectPanel.BindObjectToControls(value);
        }
    }


    /// <summary>
    /// Gets the parent UIObjectPanel object.
    /// </summary>
    [DefaultValue(null), Localizable(false)]
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
    /// The ID of the UIGridView control to which this objectSubPanel.ascx
    /// control will respond.
    /// </summary>
    protected string gridViewID;


    /// <summary>
    /// Gets or sets ID of the UIGridView control to which this objectSubPanel.ascx
    /// control will respond.
    /// </summary>
    [DefaultValue(null), Localizable(false), IDReferenceProperty]
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
    /// The UIGridView control to which this objectSubPanel.ascx
    /// control will respond.
    /// </summary>
    [DefaultValue(null), Localizable(false)]
    public UIGridView GridView
    {
        get
        {
            if (gridViewID == null || gridViewID.Trim() == "")
                throw new ArgumentException("A GridViewID must be specified in the subpanel.", "GridViewID");
            
            Control c = null;

            List<Control> controls = new List<Control>();
            
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
    /// Gets or sets the comma-separated column names that this SubPanel 
    /// component will use to create multiple copies of the object. For 
    /// each object that is created, the column names of the fields will 
    /// be copied from the MultiSelectGrid's datatable to the object 
    /// automatically.
    /// </summary>
    protected string multiSelectColumnNames;
    public string MultiSelectColumnNames
    {
        get
        {
            return multiSelectColumnNames;
        }
        set
        {
            multiSelectColumnNames = value;
        }
    }



    /// <summary>
    /// Gets a boolean value indicating if the SubPanel is currently in
    /// Adding Object mode. Returns true if so, returns false if it is
    /// in Editing Object mode.
    /// </summary>
    public bool IsAddingObject
    {
        get
        {
            return ((string)ViewState["Action"]) == "AddObject";
        }
    }
    
    
    /// <summary>
    /// A flag that indicates whether the object subpanel in
    /// the current page will support automatic binding to/from
    /// and the user interface and automatic adding into
    /// the list.
    /// </summary>
    private bool automaticBindingAndAdding = false;


    /// <summary>
    /// Gets or sets a flag that indicates whether the object subpanel in
    /// the current page will support automatic binding to/from
    /// and the user interface and automatic adding into
    /// the list.
    /// </summary>
    public bool AutomaticBindingAndAdding
    {
        get { return automaticBindingAndAdding; }
        set { automaticBindingAndAdding = value; }
    }


    /// <summary>
    /// Gets the session object key.
    /// </summary>
    /// <returns></returns>
    protected string GetObjectSessionKey()
    {
        return Page.Request.Path + "::" + this.UniqueID;
    }
    
    
    /// <summary>
    /// Occurs when the control is initializing.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnInit(EventArgs e)
    {
        UIGridView g = GridView;
        if (g != null)
        {
            g.Action += new UIGridView.RowActionEventHandler(g_Action);
        }
        base.OnInit(e);
    }


    /// <summary>
    /// Occurs when the control is being loaded.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!IsPostBack)
        {
            // 2011 06 02, Kien Trung, MODIFIED
            // Set the properties to modal popup
            //
            popupAdd.PopupControlID = ObjectPanel.ID;
            if (UpdatePopupVisible)
            {
                ObjectPanel.Width = Unit.Percentage(80);
                ObjectPanel.Height = Unit.Percentage(80);
                ObjectPanel.BackColor = System.Drawing.Color.White;
            }
            
            this.Visible = false;
            ObjectPanel.Visible = false;
        }

        // 2011 06 02, Kien Trung, MODIFIED
        if (this.Visible && UpdatePopupVisible)
        {
            ObjectPanel.Visible = true;
            popupAdd.Show();
        }
        

    }


    /// <summary>
    /// Finds and returns the objectPanel.ascx control in this page.
    /// </summary>
    /// <param name="c"></param>
    /// <returns></returns>
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


    /// <summary>
    /// Finds and returns the nearest parent UIObjectPanel that
    /// contains this objectSubPanel.ascx control.
    /// </summary>
    /// <param name="c"></param>
    /// <returns></returns>
    protected UIObjectPanel getNearestObjectPanel(Control c)
    {
        int count = 0;

        while (c != null)
        {
            if (c is UIObjectPanel)
            {
                count++;
                if (count == 2)
                    return (UIObjectPanel)c;
            }
            c = c.Parent;
        }
        return null;
    }


    /// <summary>
    /// Finds and returns the objectSubPanel.ascx control contained in the 
    /// specified UIObjectPanel control.
    /// </summary>
    /// <param name="c"></param>
    protected objectSubPanel getSubObjectPanel(Control c)
    {
        foreach (Control child in c.Controls)
        {
            if (child is UIObjectPanel)
                return null;
            else if (child is objectSubPanel)
                return (objectSubPanel)child;
            else
            {
                objectSubPanel sp = getSubObjectPanel(child);
                if (sp != null)
                    return sp;
            }
        }
        return null;
    }


    /// <summary>
    /// Finds and returns the nearest panel or subpanel and extracts
    /// the current object.
    /// </summary>
    /// <param name="c"></param>
    /// <returns></returns>
    protected PersistentObject getNearestPanelSessionObject(Control c)
    {
        UIObjectPanel p = getNearestObjectPanel(c);

        if (p != null)
        {
            objectSubPanel subPanel = getSubObjectPanel(p);
            if (subPanel != null)
                return subPanel.SessionObject;
        }

        objectPanel panel = getPanel(Page);
        if (panel != null)
            return panel.SessionObject;

        return null;
    }


    /// <summary>
    /// Binds the parent object to the user interface so
    /// that the grid view can be updated.
    /// </summary>
    protected void BindParentObjectToControls()
    {
        UIObjectPanel nearestObjectPanel = getNearestObjectPanel(this);
        objectSubPanel nearestSubPanel = null;
        if (nearestObjectPanel != null)
            nearestSubPanel = getSubObjectPanel(nearestObjectPanel);
        if (nearestSubPanel == null)
        {
            objectPanel p = getPanel(Page);
            p.ObjectPanel.BindObjectToControls(p.SessionObject);
        }
        else
        {
            nearestSubPanel.ObjectPanel.BindObjectToControls(nearestSubPanel.SessionObject);
        }
    }


    /// <summary>
    /// Binds the parent object to the user interface so
    /// that the grid view can be updated.
    /// </summary>
    protected void BindParentControlsToObject()
    {
        UIObjectPanel nearestObjectPanel = getNearestObjectPanel(this);
        objectSubPanel nearestSubPanel = null;
        if (nearestObjectPanel != null)
            nearestSubPanel = getSubObjectPanel(nearestObjectPanel);
        if (nearestSubPanel == null)
        {
            objectPanel p = getPanel(Page);
            p.ObjectPanel.BindControlsToObject(p.SessionObject);
        }
        else
        {
            nearestSubPanel.ObjectPanel.BindControlsToObject(nearestSubPanel.SessionObject);
        }
    }


    /// <summary>
    /// Calls the PopulateForm event and binds the object
    /// to the user interface if automatic binding is enabled.
    /// </summary>
    protected void CallPopulateFormEvent()
    {
        if (PopulateForm != null)
            PopulateForm(this, EventArgs.Empty);

        if (AutomaticBindingAndAdding)
            this.ObjectPanel.BindObjectToControls(this.SessionObject);
    }


    /// <summary>
    /// Adds the current session object into the list of
    /// the nearest parent panel/subpanel's session object 
    /// and binds the parent object to the user interface.
    /// </summary>
    protected void AddSessionObjectToList()
    {
        PersistentObject o = getNearestPanelSessionObject(this);

        PropertyInfo pi = o.GetType().GetProperty(this.GridView.PropertyName);
        if (pi != null)
        {
            DataListBase dataListBase = pi.GetValue(o, null) as DataListBase;

            if (dataListBase != null)
                dataListBase.AddObject(this.SessionObject);
        }
        BindParentObjectToControls();
    }
    
    
    /// <summary>
    /// Shows the UIObjectPanel that contains this objectSubPanel.ascx
    /// control.
    /// </summary>
    void ShowPanel()
    {
        getPanel(Page).Message = "";
        if (!this.Visible)
        {
            this.Visible = true;
            ObjectPanel.Visible = true;
            getPanel(Page).SubPanelCount++;
        }

        // 2011 06 02, Kien Trung, MODIFIED
        // if UpdatePopupVisible set to true
        // show modal popup.
        //
        if (this.Visible && UpdatePopupVisible)
            popupAdd.Show();
        
        ObjectPanel.ClearErrorMessages();

        foreach (DataControlField field in GridView.Grid.Columns)
        {
            if (field is ButtonField && ((ButtonField)field).CommandName != "EditObject")
                field.Visible = false;
            //((TemplateField)field).
        }
        
        foreach (Control button in GridView.ActionButtons)
            button.Visible = false;
        
        // KF BEGIN 2007.05.08
        //GridView.Enabled = false;
        //GridView.AllowSorting = false;
        //GridView.PagerSettings.Visible = false;
        // KF END
    }


    /// <summary>
    /// Hides the panel, and make all necessary bindings to the user interface.
    /// </summary>
    public void HidePanel()
    {
        if (this.Visible)
        {
            this.Visible = false;
            ObjectPanel.Visible = false;
            getPanel(Page).SubPanelCount--;
        }

        // 2011 06 02, Kien Trung, MODIFIED
        // If UpdatePopupVisible is set to true
        // Hide the popup when user click cancel.
        //
        if (!this.Visible && UpdatePopupVisible)
            popupAdd.Hide();

        foreach (DataControlField field in GridView.Grid.Columns)
            if (field is ButtonField)
                field.Visible = true;
        foreach (Control button in GridView.ActionButtons)
            button.Visible = true;
        // KF BEGIN 2007.05.08
        //GridView.AllowSorting = true;
        //GridView.Enabled = true;
        //GridView.AllowSorting = true;
        //GridView.PagerSettings.Visible = true;
        // KF END

        // Clear the reference to the current object in session memory
        //
        Session[GetObjectSessionKey()] = null;
    }


    /// <summary>
    /// Occurs when the user clicks on any button in the UIGridView control.
    /// </summary>
    /// <remarks>
    /// This event handles only buttons with the following CommandNames:
    /// AddObject, EditObject, DeleteObject.
    /// <para></para>
    /// When an AddObject button is clicked, the following happens:
    /// <list>
    /// <item>1. Creates a new PersistentObject of the appropriate type.</item>
    /// <item>2. Binds the new PersistentObject to the form controls.</item>
    /// <item>3. Calls the PopulateForm event.</item>
    /// <item>4. Binds the new PersistentObject to the form controls again.</item>
    /// </list>
    /// <para></para>
    /// When an EditObject button is clicked, the following happens:
    /// <list>
    /// <item>1. Loads the PersistentObject based on the ObjectID.</item>
    /// <item>2. Binds the loaded PersistentObject to the form controls.</item>
    /// <item>3. Calls the PopulateForm event.</item>
    /// <item>4. Binds the loaded PersistentObject to the form controls again.</item>
    /// </list>
    /// <para></para>
    /// When an DeleteObject button is clicked, the following happens:
    /// <list>
    /// <item>1. Loops and removes all PersistentObjects from the list.</item>
    /// </list>
    /// </remarks>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="objectIds"></param>
    void g_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "EditObject" && this.ObjectPanel.Visible)
        {
            // If the user clicks on the Edit object button
            // when he/she is currently editing another object,
            // try to update that object.
            //
            Page.Validate(this.ObjectPanel.ClientID);
            UpdateObject();
            if (!this.ObjectPanel.IsValid)
                return;
        }
        
        if (commandName == "AddObject" || commandName == "EditObject" || commandName == "DeleteObject" || commandName == "RemoveObject")
        {
            PersistentObject pageObject = getPanel(Page).SessionObject;
            object list = null;
            pageObject = getNearestPanelSessionObject(this);
            list = UIBinder.GetValue(pageObject, GridView.PropertyName, false);

            if (!(list is DataListBase))
                throw new Exception("'" + GridView.PropertyName + "' in the object does not refer to an object of DataListBase type.");

            Type persistentObjectType = ((DataListBase)list).GetObjectType();

            if (commandName == "AddObject")
            {
                ViewState["Action"] = commandName;
                ShowPanel();
                SchemaBase table = SchemaFactory.GetSchemaByObjectType(persistentObjectType);
                if (table == null)
                    throw new Exception("Unable to get Schema class for the persistent object type '" + persistentObjectType.Name + "'. Did you forget to declare public TXXXX tXXXX = SchemaFactory.Get<TXXXX>() in the TablesLogic class?");
                
                LogicLayerPersistentObject o = table.CreateObject() as LogicLayerPersistentObject;
                
                Page.Session[GetObjectSessionKey()] = o;

                CallPopulateFormEvent();

                buttonCancel.Visible = true;
            }
            if (commandName == "EditObject")
            {
                ViewState["Action"] = commandName;
                ShowPanel();
                LogicLayerPersistentObject o = null;
                Guid id = new Guid();
                foreach (Guid gid in objectIds)
                {
                    id = gid;
                    break;
                }
                o = ((DataListBase)list).FindObject(id) as LogicLayerPersistentObject;
                Page.Session[GetObjectSessionKey()] = o;

                CallPopulateFormEvent();

                o.BackupData();
                buttonCancel.Visible = true;
            }
            if (commandName == "DeleteObject" || commandName == "RemoveObject")
            {
                ViewState["Action"] = commandName;

                BindParentControlsToObject();
                foreach (Guid id in objectIds)
                    ((DataListBase)list).RemoveGuid(id);
                if (Removed != null)
                    Removed(this, EventArgs.Empty);

                HidePanel();
                BindParentObjectToControls();
                buttonCancel.Visible = false;
            }
        }
    }


    /// <summary>
    /// Programmatically switches the sub panel into AddObject mode,
    /// as if the user has clicked on the AddObject button in the
    /// UIGridView control.
    /// </summary>
    public void AddObject()
    {
        g_Action(null, "AddObject", new List<object>());
    }


    /// <summary>
    /// Adds a new sub object programmatically, and opens the UIObjectPanel
    /// to allow the user to edit it.
    /// <para></para>
    /// This is useful in scenarios where the application needs to create
    /// a new object and pre-populate it with data based on external input.
    /// </summary>
    /// <param name="obj"></param>
    public void AddObject(LogicLayerPersistentObject o)
    {
        ViewState["Action"] = "AddObject";
        Page.Session[GetObjectSessionKey()] = o;
        ShowPanel();

        CallPopulateFormEvent();
        
        buttonCancel.Visible = true;
    }


    /// <summary>
    /// Programmatically switches the sub panel into EditObject mode,
    /// as if the user has clicked on an EditObject button in one
    /// of the rows in the UIGridView control.
    /// </summary>
    /// <param name="objectId">The ObjectID of the PersistentObject
    /// to edit.</param>
    public void EditObject(LogicLayerPersistentObject o)
    {
        ViewState["Action"] = "EditObject";
        Page.Session[GetObjectSessionKey()] = o;
        ShowPanel();

        CallPopulateFormEvent();

        o.BackupData();
        buttonCancel.Visible = true;
    }


    /// <summary>
    /// Programmatically switches the sub panel into EditObject mode,
    /// as if the user has clicked on an EditObject button in one
    /// of the rows in the UIGridView control.
    /// </summary>
    /// <param name="objectId">The ObjectID of the PersistentObject
    /// to edit.</param>
    public void EditObject(Guid objectId)
    {
        List<object> list = new List<object>();

        list.Add(objectId);
        g_Action(null, "EditObject", list);
    }


    /// <summary>
    /// Performs an update programmatically, as if the user clicked on
    /// the Update button.
    /// </summary>
    public void UpdateObject()
    {
        UpdateObject(false);
    }


    /// <summary>
    /// Performs a cancel programmatically, as if the user clicked on
    /// the Cancel button.
    /// </summary>
    public void Cancel()
    {
        buttonCancel_Click(this, new EventArgs());
    }


    /// <remarks>
    /// The following happens in this method:
    /// <list>
    /// <item>1. Binds the data entered in the form controls to the PersistentObject.</item>
    /// <item>2. All error messages are cleared from the controls within the UIObjectPanel/UITabStrip control.</item>
    /// <item>3. All basic validations are performed on all controls within the UIObjectPanel/UITabStrip control.</item>
    /// <item>4. If at least one of the controls encounter a validation error, the first error will be displayed, and
    /// the processing stops. The object is NOT saved.</item>
    /// <item>5. If the basic validation succeeds, the Validate event will be called for
    /// the application to perform other customized validation. The application must set
    /// an error message to the control that failed validation.</item>
    /// <item>6. If at least one of the controls encounter a validation error, the first error will be displayed, and
    /// the processing stops. The object is NOT saved.</item>
    /// <item>7. The Updating event will be called.</item>
    /// <item>8. Adds the object to the DataListBase, if we are adding a new object.</item>
    /// <item>9. The Updated event will be called.</item>
    /// <item>10. Clears the backup data created by the PersistentObject to allow canceling changes.</item>
    /// <item>11. Hides the UIObjectPanel associated with this objectSubPanel.ascx control.</item>
    /// </list>
    /// </remarks>
    protected void UpdateObject(bool addNew)
    {
        // Note: Basic validation has already been performed.
        //
        if (!ObjectPanel.IsValid)
        {
            getPanel(Page).Message = ObjectPanel.CheckErrorMessages();
            return;
        }
        
        // Binds the user interface to the object, if
        // automatic binding is enabled.
        //
        if (AutomaticBindingAndAdding)
        {
            this.ObjectPanel.BindControlsToObject(SessionObject);

            // Calls the Validate event
            //
            if (Validate != null)
                Validate(this.ObjectPanel, this.SessionObject);

            if (!ObjectPanel.IsValid)
            {
                getPanel(Page).Message = ObjectPanel.CheckErrorMessages();
                return;
            }
        }
        
        // Calls the Update event
        //
        if (ValidateAndUpdate != null)
        {
            ValidateAndUpdate(this, EventArgs.Empty);
            if (!ObjectPanel.IsValid)
            {
                getPanel(Page).Message = ObjectPanel.CheckErrorMessages();
                return;
            }
        }

        // Adds the session object into the parent list,
        // if automatic binding is enabled.
        //
        if (AutomaticBindingAndAdding)
        {
            if (Updating != null)
                Updating(this.ObjectPanel, this.SessionObject);

            AddSessionObjectToList();

            if (Updated != null)
                Updated(this.ObjectPanel, this.SessionObject);

        }
        
        if (((string)ViewState["Action"]) == "AddObject")
            getPanel(Page).Message = Resources.Messages.General_ItemAdded;
        else
            getPanel(Page).Message = Resources.Messages.General_ItemUpdated;

        // Clears backup.
        //
        SessionObject.ObjectError = "";
        SessionObject.ClearBackup();

        if (!addNew)
        {
            // Hide the UIObjectPanel
            //
            HidePanel();
        }
        else
        {
            g_Action(this, "AddObject", null);
        }
    }



    /// <summary>
    /// Occurs when the user clicks the Cancel button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonCancel_Click(object sender, EventArgs e)
    {
        if ((string)ViewState["Action"] == "EditObject")
            SessionObject.RestoreData();

        PersistentObject obj = SessionObject;
        if (Cancelled != null)
            Cancelled(ObjectPanel, EventArgs.Empty);

        getPanel(Page).Message = "";
        
        HidePanel();
    }


    /// <summary>
    /// Occurs when the user clicks the Update button. 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonUpdate_Click(object sender, EventArgs e)
    {
        UpdateObject(false);
    }


    /// <summary>
    /// Occurs when the user clicks on the Update and Add button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonUpdateAndNew_Click(object sender, EventArgs e)
    {
        UpdateObject(true);
    }


    /// <summary>
    /// Handle the text changed event, by adding the items in the 
    /// session DataTable to the list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void MassAdd()
    {
        PersistentObject pageObject = getPanel(Page).SessionObject;
        object list = null;
        list = UIBinder.GetValue(getNearestPanelSessionObject(this), GridView.PropertyName, false);

        if (!(list is DataListBase))
            throw new Exception("'" + GridView.PropertyName + "' in the object does not refer to an object of DataListBase type.");

        Type persistentObjectType = ((DataListBase)list).GetObjectType();

        // we check for errors in each individual object that is to be added.
        //
        DataTable dt = Session["MASSADD"] as DataTable;
        Session.Remove("MASSADD");
        if (dt != null)
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                // create the object
                //
                DataRow dr = dt.Rows[i];
                SchemaBase table = SchemaFactory.GetSchemaByObjectType(persistentObjectType);
                PersistentObject obj = table.CreateObject();

                // bind the values from the data source to the
                // fields/properties
                //
                string[] columnNames = multiSelectColumnNames.Split(',');
                if (columnNames.Length == 0)
                    throw new Exception("The SubPanel is unable to bind data to objects because no column names have been specified in the MultiSelectColumnNames attribute.");
                foreach (string columnName in columnNames)
                {
                    if (!dt.Columns.Contains(columnName))
                        throw new Exception("The SubPanel is unable to bind data to objects because the column '" + columnName + "' does not exist in the MultiSelectGrid's data source.");
                    object v = dr[columnName];
                    UIBinder.SetValue(obj, columnName, v);
                }

                Session[GetObjectSessionKey()] = obj;
                ((DataListBase)list).AddObject(obj);
                obj.ClearBackup();
            }
            getPanel(Page).Message = Resources.Messages.General_ItemsAdded;
        }
        BindParentObjectToControls();
        HidePanel();
    }


    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        UIObjectPanel op = this.ObjectPanel;
        if (op != null)
            op.EndingHtml = "<div style='clear:both'></div></div>";
    }

    protected override void Render(HtmlTextWriter writer)
    {
        base.Render(writer);
        writer.Write("<div class='subobject-panel'><div style='clear:both'></div>");
    }

    
    public delegate void ObjectEventHandler(object sender, PersistentObject obj);
    

    /// <summary>
    /// Occurs after the user has clicked on AddObject or EditObject button,
    /// or when the application adds a new object programmatically through
    /// the AddObject method.
    /// </summary>
    public event EventHandler PopulateForm;


    /// <summary>
    /// Occurs after the user clicks on the Update button. 
    /// This is applicable if AutomaticBindingAndAdding is false.
    /// </summary>
    public event EventHandler ValidateAndUpdate;


    /// <summary>
    /// Occurs before the object is about to be updated.
    /// </summary>
    [Obsolete("Consider using ValidateAndUpdate")]
    public event ObjectEventHandler Updating;


    /// <summary>
    /// Occurs after the object has been updated.
    /// </summary>
    [Obsolete("Consider using ValidateAndUpdate")]
    public event ObjectEventHandler Updated;


    /// <summary>
    /// Occurs when the object is to be validated.
    /// </summary>
    [Obsolete("Consider using ValidateAndUpdate")]
    public event ObjectEventHandler Validate;


    /// <summary>
    /// Occurs after the user removes items by clicking on the Remove
    /// buttons in the grid view.
    /// </summary>
    public event EventHandler Removed;
    
    
    /// <summary>
    /// Occurs after the user clicks on the Cancel button.
    /// </summary>
    public event EventHandler Cancelled;
</script>
<%--2011 06 02, Kien Trung, MODIFIED
    Add Link button and modal popup extender control
    enable avaibility of popup panel --%>
<asp:LinkButton runat="server" ID="buttonAddHidden" />
<asp:ModalPopupExtender runat='server' ID="popupAdd" Enabled="false"
    BackgroundCssClass="modalBackground" TargetControlID="buttonAddHidden">
</asp:ModalPopupExtender>
<%--2011 06 02, Kien Trung, END--%>

<table border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
        <td class='subobject-buttons'>
            <ui:UIPanel ID="panel_ValidateAndUpdate" runat="server">
                <table border='0' cellpadding='0' cellspacing='0'>
                    <tr>
                        <td>
                            <ui:UIPanel runat="server" ID="spanUpdateButtons">
                                <ui:UIButton runat="server" ID="buttonUpdate" ImageUrl="~/images/check-big.png" CausesValidation="true"
                                    Text="Update" OnClick="buttonUpdate_Click" meta:resourcekey="buttOnValidateAndSaveResource1">
                                </ui:UIButton>
                                <ui:UIButton runat="server" ID="buttonUpdateAndNew" ImageUrl="~/images/add-big.png" CausesValidation="true"
                                    Text="Update and New" OnClick="buttonUpdateAndNew_Click" meta:resourcekey="buttOnValidateAndSaveAndNewResource1">
                                </ui:UIButton>
                            </ui:UIPanel>
                        </td>
                        <td>
                            <ui:UIPanel runat="server" ID="spanCancel">
                                <ui:UIButton runat="server" ID="buttonCancel" ImageUrl="~/images/delete-big.png"
                                    Text="Cancel" OnClick="buttonCancel_Click" meta:resourcekey="buttonCancelResource1" AlwaysEnabled="true">
                                </ui:UIButton>
                            </ui:UIPanel>
                        </td>
                    </tr>
                </table>
            </ui:UIPanel>
        </td>
    </tr>
</table>
