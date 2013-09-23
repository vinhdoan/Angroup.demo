<%@ Control Language="C#" ClassName="objectPanel" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.ComponentModel" %>
<%@ Import Namespace="System.Workflow.ComponentModel.Compiler" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="Anacle.WorkflowFramework" %>

<script runat="server">

    public bool CommentTextValidateRequiredField
    {
        get
        {
            return textTaskCurrentComments.ValidateRequiredField;
        }
        set
        {
            textTaskCurrentComments.ValidateRequiredField = value;
        }
    }

    /// <summary>
    /// Gets or sets a flag that indicates if the Close Window button
    /// is visible to the user.
    /// </summary>
    [DefaultValue(true), Localizable(false)]
    public bool CloneButtonVisible
    {
        get { return spanCloneButtons.Visible; }
        set { spanCloneButtons.Visible = value; }
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
    /// Gets or sets a flag to indicate if the Delete button is visible.
    /// </summary>
    [DefaultValue(true), Localizable(false)]
    public bool DeleteButtonVisible
    {
        get
        {
            return spanDelete2.Visible;
        }
        set
        {
            spanDelete2.Visible = value;
        }
    }

    /// <summary>
    /// Gets or sets a flag to indicate if the ShowWorkflowDialog is show before transit.
    /// </summary>
    ///
    bool showWorkflowDialogBox = true;
    [DefaultValue(true), Localizable(false)]
    public bool ShowWorkflowDialogBox
    {
        get
        {
            return showWorkflowDialogBox;
        }
        set
        {
            showWorkflowDialogBox = value;
        }
    }

    /// <summary>
    /// Gets or sets a flag to indicate if the Save button is visible.
    /// </summary>
    [DefaultValue(true), Localizable(false)]
    public bool SaveButtonsVisible
    {
        get
        {
            return spanSaveButtonsInner.Visible;
        }
        set
        {
            spanSaveButtonsInner.Visible = value;
        }
    }

    /// <summary>
    /// Gets or sets a flag to indicate if the "Save" button
    /// is visible.
    /// <para></para>
    /// NOTE: This property is different from the SaveButtonsVisible
    /// (note the plural form), which sets the visible flag
    /// of the span containing ALL save buttons.
    /// </summary>
    [DefaultValue(true), Localizable(false)]
    public bool SaveButtonVisible
    {
        get
        {
            return this.buttOnValidateAndSave.Visible;
        }
        set
        {
            this.buttOnValidateAndSave.Visible = value;
        }
    }

    /// <summary>
    /// Gets or sets a flag to indicate if the "Save and Close" button
    /// is visible.
    /// <para></para>
    /// NOTE: This property is different from the SaveButtonsVisible
    /// (note the plural form), which sets the visible flag
    /// of the span containing ALL save buttons.
    /// </summary>
    [DefaultValue(true), Localizable(false)]
    public bool SaveAndCloseButtonVisible
    {
        get
        {
            return this.buttOnValidateAndSaveAndClose.Visible;
        }
        set
        {
            this.buttOnValidateAndSaveAndClose.Visible = value;
        }
    }

    /// <summary>
    /// Gets or sets a flag to indicate if the "Save and Create" button
    /// is visible.
    /// <para></para>
    /// NOTE: This property is different from the SaveButtonsVisible
    /// (note the plural form), which sets the visible flag
    /// of the span containing ALL save buttons.
    /// </summary>
    [DefaultValue(true), Localizable(false)]
    public bool SaveAndNewButtonVisible
    {
        get
        {
            return this.buttOnValidateAndSaveAndNew.Visible;
        }
        set
        {
            this.buttOnValidateAndSaveAndNew.Visible = value;
        }
    }

    // 2010.08.16
    // Kim Foong
    // Added spell-check capability for all forms.
    /// <summary>
    /// Gets or sets a flag to indicate if the "Spell Check" button
    /// is visible.
    /// </summary>
    [DefaultValue(true), Localizable(false)]
    public bool SpellCheckButtonVisible
    {
        get
        {
            return this.panelSpellCheck.Visible;
        }
        set
        {
            this.panelSpellCheck.Visible = value;
        }
    }

    /// <summary>
    /// Gets or sets a flag to indicate whether customized
    /// object fields should be shown in the edit page.
    /// </summary>
    [DefaultValue(true), Localizable(false)]
    public bool EnableCustomizedObjects
    {
        get
        {
            if (ViewState["EnableCustomizedObjects"] == null)
                return true;
            return (bool)ViewState["EnableCustomizedObjects"];
        }
        set
        {
            ViewState["EnableCustomizedObjects"] = true;
        }
    }

    /// <summary>
    /// Gets or sets a flag to indicate if the document template
    /// dropdown is visible.
    /// </summary>
    [DefaultValue(true), Localizable(false)]
    public bool DocumentTemplatesDropDownVisible
    {
        get
        {
            return panelDocumentTemplates.Visible;
        }
        set
        {
            panelDocumentTemplates.Visible = value;
        }
    }

    /// <summary>
    /// Gets or sets the confirmation text that will appear if the user clicks
    /// on any of the save button.
    /// </summary>
    public string SavingConfirmationText
    {
        get
        {
            return buttOnValidateAndSave.ConfirmText;
        }
        set
        {
            buttOnValidateAndSaveAndClose.ConfirmText = value;
            buttOnValidateAndSaveAndNew.ConfirmText = value;
            buttOnValidateAndSave.ConfirmText = value;
        }
    }

    /// <summary>
    /// Gets or sets the number of objectSubPanel.ascx controls that are open.
    /// <para></para>
    /// This is set only by the objectSubPanel.ascx control, and the
    /// application must NOT set this directly.
    /// </summary>
    [Browsable(false), DefaultValue(0), Localizable(false)]
    public int SubPanelCount
    {
        get
        {
            if (textSubPanelCount.Text == "")
                textSubPanelCount.Text = "0";
            return Convert.ToInt32(textSubPanelCount.Text);
        }
        set
        {
            textSubPanelCount.Text = value.ToString();
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
    public PersistentObject SessionObject
    {
        get
        {
            // Updates the current object's ID into the viewstate.
            if (!IsPostBack)
                UpdateCurrentObjectInstanceKey();

            return Page.Session[GetObjectSessionKey()] as PersistentObject;
        }
    }

    // 2010.10.15
    // Kim Foong
    /// <summary>
    /// Gets the datalist control for the workflow buttons.
    /// </summary>
    public DataList DataListWorkflowButtons
    {
        get
        {
            return this.datalistWorkflowButtons;
        }
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
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
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

            // Updates the current object's ID into the viewstate
            //
            if (!IsPostBack)
                UpdateCurrentObjectInstanceKey();

            // There might be quite a good number of loads from the database,
            // and each may open a connection separately. To improve performance
            // wrap a connection boundary around the binding.
            //
            using (Connection c = new Connection())
            {
                ObjectPanel.BindObjectToControls(value);
            }
        }
    }

    /// <summary>
    /// Gets or sets the caption that appears in the title of
    /// the objectPanel.ascx control.
    /// </summary>
    [Localizable(true)]
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
    public string Message
    {
        get
        {
            return labelMessage.Text;
        }
        set
        {
            this.tableMessage.Style.Remove("background-color");

            if (value.Trim() != "")
                panelMessage.Update();
            labelMessage.Text = value;
        }
    }

    /// <summary>
    /// Gets or sets the message that appears in the message bar. The message
    /// bar will show only if the Message property is not an empty string.
    /// </summary>
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    public string PopupMessage
    {
        get
        {
            return labelPopupMessage.Text;
        }
        set
        {
            if (value.Trim() != "")
                popupMessage.Show();
            labelPopupMessage.Text = value;
        }
    }

    /// <summary>
    /// A flag that indicates whether the object panel in
    /// the current page will support automatic binding to/from
    /// and the user interface and automatic saving.
    /// </summary>
    private bool automaticBindingAndSaving = false;

    /// <summary>
    /// Gets or sets a flag that indicates whether the object panel in
    /// the current page will support automatic binding to/from
    /// and the user interface and automatic saving.
    /// <para></para>
    /// By default, this property is false.
    /// </summary>
    public bool AutomaticBindingAndSaving
    {
        get { return automaticBindingAndSaving; }
        set { automaticBindingAndSaving = true; }
    }

    // 2010.10.15
    // Kim Foong
    /// <summary>
    /// Gets or sets a flag that indicates whether the workflow
    /// actions should be shown in as buttons at the top of the page.
    /// </summary>
    public bool ShowWorkflowActionAsButtons
    {
        get { return spanWorkflowButtons.Visible; }
        set { spanWorkflowButtons.Visible = value; }
    }

    /// <summary>
    /// The name of the base table as declared in the TablesLogic class.
    /// This should be something like "tWork", or "tLocation", or
    /// "tUser".
    /// </summary>
    protected string baseTable = "";

    /// <summary>
    /// Gets or sets the name of the base table as declared in the TablesLogic
    /// class. This should be something like "tWork", or "tLocation", or
    /// "tUser".
    /// </summary>
    [DefaultValue(""), Localizable(false)]
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

    /// <summary>
    /// Gets the UIObjectPanel that contains this edit panel.
    /// <para></para>
    /// Note: A UITabStrip is a subclass of the UIObjectPanel class.
    /// </summary>
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
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
            if (c != null && c is UIObjectPanel)
                return (UIObjectPanel)c;
            else
                throw new Exception("The web:panel control must be placed in a UIObjectPanel control, but it is currently not.");
        }
    }

    /// <summary>
    /// A flag to indicate if this window should be in focus after
    /// the request or post back of this page is complete. If this
    /// is true, a javascript will be emitted to focus the window
    /// that is display this page.
    /// </summary>
    bool focusWindow = true;

    /// <summary>
    /// Gets or sets a flag to indicate if this window should be in focus after
    /// the request or post back of this page is complete. If this
    /// is true, a javascript will be emitted to focus the window
    /// that is display this page.
    /// </summary>
    public bool FocusWindow
    {
        get
        {
            return focusWindow;
        }
        set
        {
            focusWindow = value;
        }
    }

    /// <summary>
    /// Gets or sets a flag that indicates whether or
    /// not the parent opener window should be refreshed
    /// after the user saves the object.
    /// </summary>
    public bool RefreshOpenerAfterSave
    {
        get
        {
            if (ViewState["RefreshOpenerAfterSave"] == null)
                return true;
            return (bool)ViewState["RefreshOpenerAfterSave"];
        }
        set
        {
            ViewState["RefreshOpenerAfterSave"] = value;
        }
    }

    /// <summary>
    /// The object base control.
    /// </summary>
    protected object objectBase;

    /// <summary>
    /// Gets or sets the object base control.
    /// </summary>
    public object ObjectBase
    {
        get { return objectBase; }
        set { objectBase = value; }
    }

    /// <summary>
    /// Gets a key representing the uniqueness of the object
    /// that is to be used to determine if the page is
    /// editing or viewing the correctly loaded persistent
    /// object.
    /// </summary>
    /// <param name="persistentObject"></param>
    /// <returns></returns>
    protected string GetObjectInstanceKey(PersistentObject persistentObject)
    {
        if (System.Configuration.ConfigurationManager.AppSettings["LoadTesting"] == "true")
            return "";

        string key = persistentObject.ObjectID.ToString() + "::";
        if (persistentObject.Base.ModifiedDateTime != null)
            key = key + persistentObject.Base.ModifiedDateTime.Value.ToString("yyyy-MM-dd HH:mm:ss.f");

        return Security.Encrypt(key);
    }

    /// <summary>
    /// Sets the current object's ID into a hidden INPUT value
    /// of this page.
    /// </summary>
    /// <param name="id"></param>
    protected void UpdateCurrentObjectInstanceKey()
    {
        PersistentObject persistentObject = Session[GetObjectSessionKey()] as PersistentObject;
        if (persistentObject == null)
            return;

        CurrentObjectInstanceKey.Value = GetObjectInstanceKey(persistentObject);
    }

    /// <summary>
    /// Each time a post back occurs, the ObjectID of the
    /// persistent object in session is compared with the one stored
    /// in the hidden INPUT. If they are different, then the page disables
    /// itself and an error is shown.
    /// </summary>
    /// <param name="id"></param>
    protected void AssertCurrentObjectInstanceIsValid()
    {
        PersistentObject persistentObject = Session[GetObjectSessionKey()] as PersistentObject;
        if (persistentObject == null)
            return;
        if (Page.Request.Form[CurrentObjectInstanceKey.UniqueID] == null ||
            Page.Request.Form[CurrentObjectInstanceKey.UniqueID] == "")
            return;

        if ((string)Page.Request.Form[CurrentObjectInstanceKey.UniqueID] == GetObjectInstanceKey(persistentObject))
            return;

        string path = Page.Request.ApplicationPath;
        if (!path.EndsWith("/"))
            path = path + "/";
        Response.Redirect(path + "/appobjecterr.aspx");

    }

    /// <summary>
    /// Clears all keys created by the previous edit page.
    /// </summary>
    protected void ClearPageSession()
    {
        string pageSessionPath = "::SessionEditPagePath::";
        if (Request["N"] != null)
            pageSessionPath = pageSessionPath + Request["N"];

        // Clears all session variables that contains this
        // page's full request path. All other session
        // variables are retained.
        //
        string path = (string)Session[pageSessionPath];
        if (path != null && path != Page.Request.Path)
        {
            for (int i = Session.Keys.Count - 1; i >= 0; i--)
            {
                string key = Session.Keys[i];
                if (key.Contains(path))
                    Session.RemoveAt(i);
            }
        }

        // Once we are done clearing the data,
        // Set this page's path into the session,
        // so that it can be cleared the next time.
        //
        Session[pageSessionPath] = Page.Request.Path;

        // Clear also the persistent object and the workflow
        // as they are likely to be taking up a lot of space
        // in memory.
        //
        //Session[GetObjectSessionKey()] = null;
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
    /// Initializes the PersistentObject by loading it from
    /// the database, or by creating a new one, depending
    /// on the parameter passed in via the query string.
    /// </summary>
    /// <returns></returns>
    protected void InitializePersistentObject()
    {
        string arg = Security.Decrypt(Request["ID"]);
        string[] args = arg.Split(':');

        // This should be an abstract class that provides
        // the security settings of this object. In
        // Anacle.EAM v6.0, security settings are
        // stored in the database.
        //
        spanDelete.Visible = AppSession.User.AllowDeleteAll(Security.Decrypt(Request["TYPE"]));

        GetBaseTable();
        if (table == null)
            throw new Exception("Unknown table '" + baseTable + "'");

        Type persistentObjectType = table.GetPersistentObjectType();

        // Create or load the object depending on the mode
        //
        PersistentObject o = null;
        if (args[0] == "NEW")
        {
            o = table.CreateObject() as PersistentObject;
            buttonDelete.Enabled = false;
        }
        else if (args[0] == "NEW2")
        {
            buttonDelete.Enabled = false;
            o = this.SessionObject as PersistentObject;
        }
        else if (args[0] == "EDIT" || args[0] == "VIEW") // for EDIT ALL
        {
            o = table.LoadObject(new Guid(args[1]), true) as PersistentObject;
            if (o == null)
                throw new Exception("Unable to load the object from the database. Please make sure you have specified the correct BaseTable in the objectPanel control and the correct ObjectID through the querystring. Also make sure that the object that you are loading has not been deleted from the database, or has its IsDeleted flag set to 1.");
        }

        Page.Session[GetObjectSessionKey()] = o;
    }

    /// <summary>
    /// Occurs when the page is initialized.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        // Clear all previous edit page's Session
        // values. This helps to free up a little Session
        // memory.
        //
        if (!IsPostBack)
        {
            ClearPageSession();
            InitializePersistentObject();
        }

        // Clear all session values and initialize the customized
        // object.
        //
        if (EnableCustomizedObjects)
        {
            if (!IsPostBack)
                ClearCustomizedObjectSession();
            InitCustomizedObject();
        }
    }

    /// <summary>
    /// Occurs when the initialization of the form is complete
    /// and the controls have been loaded.
    /// </summary>
    /// <remarks>
    /// There are several modes that the objectPanel.ascx control
    /// handles, and this mode is passed into this page through
    /// ID in the querystring. The modes handled by this control are:
    /// NEW, EDIT, VIEW.
    /// <para></para>
    /// If the mode is NEW, the following happens:
    /// <list>
    /// <item>Creates a new PersistentObject from the schema specified in the BaseTable</item>
    /// <item>Binds the PersistentObject to the form controls.</item>
    /// <item>Calls the PopulateForm event.</item>
    /// <item>Binds the PersistentObject to the form controls again.</item>
    /// <item>Creates and populates customized object fields.</item>
    /// </list>
    /// If the mode is EDIT, the following happens:
    /// <list>
    /// <item>Loads a PersistentObject from the schema specified in the BaseTable, and using
    /// the ObjectID specified in the query string.</item>
    /// <item>If the PersistentObject has been deactivated, disables the entire page.</item>
    /// <item>Binds the PersistentObject to the form controls.</item>
    /// <item>Calls the PopulateForm event.</item>
    /// <item>Binds the PersistentObject to the form controls again.</item>
    /// <item>Creates and populates customized object fields.</item>
    /// </list>
    /// If the mode is VIEW, the following happens:
    /// <list>
    /// <item>Loads a PersistentObject from the schema specified in the BaseTable, and using
    /// the ObjectID specified in the query string.</item>
    /// <item>Disables the entire page.</item>
    /// <item>Binds the PersistentObject to the form controls.</item>
    /// <item>Calls the PopulateForm event.</item>
    /// <item>Binds the PersistentObject to the form controls again.</item>
    /// <item>Creates and populates customized object fields.</item>
    /// </list>
    /// </remarks>
    /// <param name="e"></param>
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        AssertCurrentObjectInstanceIsValid();

        // this is where we load / create the new object
        // depends entirely on the ID query string
        //
        if (!IsPostBack)
        {
            PersistentObject o = this.SessionObject as PersistentObject;
            bool disablePage = false;

            string arg = Security.Decrypt(Request["ID"]);
            string[] args = arg.Split(':');
            if (args[0] == "VIEW")
                disablePage = true;
            if (args[0] == "EDIT")
            {
                if (o is LogicLayerPersistentObject &&
                    ((LogicLayerPersistentObject)o).CurrentActivity != null &&
                    !((LogicLayerPersistentObject)o).CurrentActivity.IsAssignedToUser(AppSession.User) &&
                    !AppSession.User.AllowEditAll(Security.Decrypt(Request["TYPE"])))
                    disablePage = true;
            }

            // 2010.05.19
            // Kim Foong
            // If the user does not have create rights, hide the save and new button.
            //
            if (!AppSession.User.AllowCreate(Security.Decrypt(Request["TYPE"])))
                buttOnValidateAndSaveAndNew.Visible = false;

            // If the object has been deleted, then disable the page.
            //
            if (o.IsDeleted == 1)
                disablePage = true;

            // sometimes the object may be lost. if that is the case,
            // make sure we don't go any further,
            // and close the window.
            //
            if (o == null)
            {
                Window.Close();
            }
            else
            {
                if (disablePage)
                    DisablePage();

                CallPopulateFormEvent();

                if (EnableCustomizedObjects)
                    PopulateCustomizedObject();

                // Show any message that a previous page might have passed in
                //
                if (Request["MESSAGE"] != null)
                    this.Message = Request["MESSAGE"];
            }

            linkClose.Attributes["onclick"] = "document.getElementById('" + tableMessage.ClientID + "').style.visibility = 'hidden'";
            //popupMessage.Button1.Attributes["onclick"] = "document.getElementById('" + popupMessage.ClientID + "').style.visibility = 'hidden'";
            // 2010.08.16
            // Kim Foong
            // Added spell-check capability for all forms
            //
            linkSpellCheck.Attributes["onclick"] = "checkSpelling();";
            imageSpellCheck.Attributes["onclick"] = "checkSpelling();";
            Page.ClientScript.RegisterClientScriptInclude("NetSpell", Page.Request.ApplicationPath + "/scripts/spell.js");
        }

        //int miliSecs = 1000 * 10;
        //string strScriptAlert = @"window.setInterval('ShowAlert()'," + miliSecs.ToString() + @");";
        //ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "Alert", strScriptAlert, true);

        // 2010.10.15
        // Kim Foong
        // If the workflow actions are shown at the top of the page as
        // buttons, then we must do update the workflow action radio button list
        // in the objectBase and force a call to PreRender.
        //
        if (IsPostBack && ShowWorkflowActionAsButtons)
        {
            foreach (DataListItem item in this.datalistWorkflowButtons.Items)
            {
                UIButton button = item.FindControl("buttonWorkflowAction") as UIButton;
                if (button.LinkButton.UniqueID == Request.Form["__EVENTTARGET"])
                {
                    UIFieldRadioList radioList = GetObjectBaseWorkflowActionRadioListActual() as UIFieldRadioList;
                    if (radioList != null)
                        radioList.SelectedValue = button.CommandName;

                    MethodInfo mi = this.Page.GetType().GetMethod("OnPreRender", BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
                    if (mi != null)
                        mi.Invoke(this.Page, new object[] { EventArgs.Empty });
                    break;
                }
            }
        }
    }

    /// <summary>
    /// Sometimes the page is used for viewing a separate object so the session key should be different from the edit page session key
    /// if it is view object and with Query String N then we use different session object key
    /// </summary>
    /// <returns></returns>
    protected string GetObjectSessionKey()
    {
        string arg = Security.Decrypt(Request["ID"]);
        string[] args = arg.Split(':');
        if (Request["N"] != null)
        {
            return "::SessionObject::" + "_" + Request["N"];
        }
        else
            return "::SessionObject::";
    }

    /// <summary>
    /// Disables the entire page by setting the Enabled flag of the buttons
    /// and the ObjectPanel to false.
    /// </summary>
    public void DisablePage()
    {
        // disable the controls container
        //
        buttonDelete.Enabled = false;
        buttOnValidateAndSave.Enabled = false;
        buttOnValidateAndSaveAndNew.Enabled = false;
        buttOnValidateAndSaveAndClose.Enabled = false;

        if (ObjectPanel != null && ObjectPanel is WebControl)
            ((WebControl)ObjectPanel).Enabled = false;
    }

    /// <summary>
    /// Calls the populate form event, and automatically
    /// binds the session object to the user interface, if automatic
    /// binding is turned on.
    /// </summary>
    protected void CallPopulateFormEvent()
    {
        using (Connection c = new Connection())
        {
            if (PopulateForm != null)
                PopulateForm(this, EventArgs.Empty);

            if (AutomaticBindingAndSaving)
                this.ObjectPanel.BindObjectToControls(this.SessionObject);

            // Populate the document template dropdowns
            //
            // 2011 04 30
            // Kien Trung
            // comment out since it's not needed any more.
            // set it up in document template module.
            //tessa add in 05Mar2010
            List<ODocumentTemplate> docTemplates = ODocumentTemplate.GetDocumentTemplates(this.SessionObject.GetType().BaseType.Name, this.SessionObject, GetObjectBaseCurrentObjectState());

            //if(docTemplates.Count>0 && this.SessionObject.GetType().BaseType.Name == "OPurchaseOrder")
            //{
            //    ODocumentTemplate poPdf = TablesLogic.tDocumentTemplate.Create();
            //    poPdf.FileDescription = "PO PDF";
            //    docTemplates.Add(poPdf);
            //}

            listDocumentTemplatesList.DataSource = docTemplates;
            listDocumentTemplatesList.DataBind();
        }
    }

    /// <summary>
    /// Registers the save buttons for a full PostBack instead
    /// of an AJAX partial postback.
    /// <para></para>
    /// This method can be called by the .aspx during the page's
    /// OnInit event.
    /// </summary>
    public void RegisterPostBackControlForSaveButtons()
    {
        // Register the buttonUpload button to force a full
        // postback whenever a file is uploaded.
        //
        if (Page is UIPageBase)
        {
            ((UIPageBase)Page).ScriptManager.RegisterPostBackControl(buttOnValidateAndSave);
            ((UIPageBase)Page).ScriptManager.RegisterPostBackControl(buttOnValidateAndSaveAndClose);
            ((UIPageBase)Page).ScriptManager.RegisterPostBackControl(buttOnValidateAndSaveAndNew);
        }
    }

    /// <summary>
    /// Hides/shows element.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        //Rachel 13April 2007 Customized object
        //set visibility of the no attribute message
        if (NoAttributeMessageID != null)
        {
            Control control = Page.FindControl(NoAttributeMessageID);
            if (control != null)
                control.Visible = !HasAttributeField;
        }

        //endrachel

        // hide the delete button if the object cannot be deactivated
        PersistentObject po = this.SessionObject;
        if (po != null)
            buttonDelete.Visible = po.IsDeactivatable();

        // Show the clone button only if the object
        // is cloneable.
        //
        buttonClone.Visible = (po is ICloneable);
        buttonClone.Enabled = !po.IsNew;

        // Show message only if the message is not an empty string
        //
        panelMessage.Visible = this.Message.Trim() != "";
        //panelMessage.Visible = true;

        // Hide all save buttons if at least one of the sub panels is
        // open.
        //
        // 2010.10.17
        // Chee Meng
        // Allow save buttons to be visible even if the subpanels are open

        //spanCloneButtons.Visible =
        //    spanSaveButtons.Visible = (SubPanelCount == 0);

        // Emits a javascript to focus this window after it loads.
        //
        if (focusWindow)
            Window.WriteJavascript("if( window.focus ) window.focus();");

        // Set a javascript to pop up a confirmation dialog when the
        // user clicks on a cancel button when some items have been
        // detected as modified.
        //
        buttonCancel.OnClickScript =
            "if( document.getElementById('ModifiedFlag') && document.getElementById('ModifiedFlag').value!='' ) " +
            "if( !confirm( '" + Resources.Messages.General_ItemModifiedConfirmClose + "' ) ) return false; ";

        // added so that we can force a refresh in pop-ups
        //
        Window.WriteJavascript(
            "function Refresh() { " +
            Page.ClientScript.GetPostBackEventReference(buttonRefresh.LinkButton, "") + " }");
        Window.WriteJavascript(
            "function RefreshSession() { " +
            Page.ClientScript.GetPostBackEventReference(buttonRefreshSession.LinkButton, "") + " }");
        // added to reset the timer on prerender.

        Window.WriteJavascript(
            @"
                var timeToPrompt = 1000 * 60 * 15;
                var mytime;
                function endSession() {
                    alert('" + Resources.Messages.Session_Expiring + @"');
                    RefreshSession();
                    mytime = window.setTimeout('endSession();', timeToPrompt);
                }
                function stopTimer() {
                    clearTimeout(mytime);
                    mytime = window.setTimeout('endSession();', timeToPrompt);
                }
                window.onload = function() { mytime = window.setTimeout('endSession();', timeToPrompt); }
        ");

        if (IsPostBack)
            Window.WriteJavascript("stopTimer();");

        // When the object is new or when the document template list
        // is empty hide the generate document template button.
        //
        if (listDocumentTemplatesList.Items.Count == 0 || SessionObject.IsNew)
            panelDocumentTemplates.Visible = false;
        else
            panelDocumentTemplates.Visible = true;

        // 2010.05.18
        // Kim Foong
        // Disable the workflow save button if there are no approvers
        //
        // 2011.05.07
        // Kien Trung
        // Added to disable the workflow save button if the user already approved the task at current level.
        //
        modalWorkflowPopup.Button1.Enabled = !(labelNoApproversFound.Visible || labelRequiredApproved.Visible || labelNoAuthorizedApproved.Visible);

        if (panelSpellCheck.Enabled && panelSpellCheck.IsContainerEnabled())
        {
            imageSpellCheck.Style.Remove("opacity");
            imageSpellCheck.Style.Remove("-moz-opacity");
            imageSpellCheck.Style.Remove("filter");
            linkSpellCheck.Attributes.Remove("disabled");
        }
        else
        {
            imageSpellCheck.Style["opacity"] = "0.25";
            imageSpellCheck.Style["-moz-opacity"] = "0.25";
            imageSpellCheck.Style["filter"] = "alpha(opacity=25)";
            linkSpellCheck.Attributes["disabled"] = "true";
        }

        // 2010.10.15
        // Kim Foong
        // Hides the action buttons, if the objectbase's workflow action radio buttons
        // are disabled.
        //
        UIFieldRadioList radioList = GetObjectBaseWorkflowActionRadioListActual();
        if (radioList != null)
        {
            datalistWorkflowButtons.Visible = radioList.IsContainerEnabled();
            spanWorkflowSeparator.Visible = datalistWorkflowButtons.Items.Count > 0 && radioList.IsContainerEnabled() && ShowWorkflowActionAsButtons;
        }
    }

    /// <summary>
    /// Occurs when the Close button is clicked.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonCancel_Click(object sender, EventArgs e)
    {
        Window.Close();
    }

    /// <summary>
    /// Occurs when the hidden Refresh button is clicked via
    /// javascript from another page.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonRefresh_Click(object sender, EventArgs e)
    {
        CallPopulateFormEvent();
    }

    /// <summary>
    /// Occurs when the user clicks on the alert box to refresh
    /// the session.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonRefreshSession_Click(object sender, EventArgs e)
    {
    }

    /// <summary>
    /// Occurs when the delete button is clicked.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonDelete_Click(object sender, EventArgs e)
    {
        ObjectPanel.ClearErrorMessages();

        using (Connection c = new Connection())
        {
            PersistentObject obj = SessionObject;
            obj.Deactivate();

            if (Page is UIPageBase)
                ((UIPageBase)Page).ClearModifiedFlag();

            this.Message = Resources.Messages.General_ItemDeleted;
            buttOnValidateAndSave.Enabled = false;
            buttonDelete.Enabled = false;
            buttOnValidateAndSaveAndClose.Enabled = false;
            if (ObjectPanel != null && ObjectPanel is WebControl)
                ((WebControl)ObjectPanel).Enabled = false;

            c.Commit();

            if (RefreshOpenerAfterSave)
                Window.Opener.Refresh();
        }
        DisablePage();
    }

    /// <summary>
    /// Gets the currently object state in the dropdown list of the
    /// objectBase control.
    /// </summary>
    /// <returns></returns>
    private string GetObjectBaseCurrentObjectState()
    {
        object objectBase = ObjectBase;

        if (objectBase != null)
            return objectBase.GetType().
                GetProperty("CurrentObjectState").GetValue(ObjectBase, null).ToString();
        else
            return "-";
    }

    /// <summary>
    /// Gets the currently selected action in the dropdown list of the
    /// objectBase control.
    /// </summary>
    /// <returns></returns>
    private string GetObjectBaseSelectedAction()
    {
        object objectBase = ObjectBase;

        if (objectBase != null)
            return ObjectBase.GetType().
                GetProperty("SelectedAction").GetValue(ObjectBase, null).ToString();
        else
            return "";
    }

    /// <summary>
    /// Gets the currently selected text in the dropdown list of the
    /// objectBase control.
    /// </summary>
    /// <returns></returns>
    private string GetObjectBaseSelectedActionText()
    {
        object objectBase = ObjectBase;

        if (objectBase != null)
            return ObjectBase.GetType().
                GetProperty("SelectedActionText").GetValue(ObjectBase, null).ToString();
        else
            return "";
    }

    // 2010.10.15
    // Kim Foong
    /// <summary>
    /// Gest the actual workflow radio button list from the objectbase control
    /// </summary>
    /// <returns></returns>
    private UIFieldRadioList GetObjectBaseWorkflowActionRadioListActual()
    {
        object objectBase = ObjectBase;

        if (objectBase != null)
            return objectBase.GetType().
                GetProperty("WorkflowActionRadioListActual", BindingFlags.NonPublic | BindingFlags.Instance).GetValue(objectBase, null) as UIFieldRadioList;
        else
            return null;
    }

    /// <summary>
    /// Validates that there are no errors.
    /// </summary>
    protected bool IsValid()
    {
        // Note: Basic validation has already been performed,
        // as it usually happens with normal ASP.NET controls.
        //
        if (!ObjectPanel.IsValid)
        {
            this.Message = ObjectPanel.CheckErrorMessages();
            return false;
        }
        return true;
    }

    /// <summary>
    /// Saves the PersistentObject into the database.
    /// </summary>
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
    /// <item>7. The Saving event will be called.</item>
    /// <item>8. The PersistentObject is saved by calling the Save() method.</item>
    /// <item>9. The PopulateForm event will be called.</item>
    /// <item>10. The Saved event will be called.</item>
    /// </list>
    /// </remarks>
    private bool SaveObjectAndTransit()
    {
        bool save = false;

        // Touch the session object to force it to save,
        // regardless whether the user has made any changes to
        // the fields.
        //
        SessionObject.Touch();

        try
        {
            // Clears all error messages.
            //
            this.ObjectPanel.ClearErrorMessages();

            // Save the object into the database
            //
            using (Connection c = new Connection())
            {
                // If binding is automatic, then perform the binding
                // before calling the Save event.
                //
                if (AutomaticBindingAndSaving)
                {
                    this.ObjectPanel.BindControlsToObject(this.SessionObject);

                    // Calls the Validate event
                    //
                    if (Validate != null)
                        Validate(this.ObjectPanel, this.SessionObject);

                    if (!ObjectPanel.IsValid)
                    {
                        this.Message = ObjectPanel.CheckErrorMessages();
                        return false;
                    }

                    // Calls the Saving event.
                    //
                    if (Saving != null)
                        Saving(this.ObjectPanel, this.SessionObject);

                    this.SessionObject.Save();
                }
                else
                {
                    // Take care of the validation, pre-processing.
                    // and post-processing.
                    //
                    if (ValidateAndSave != null)
                    {
                        ValidateAndSave(this, EventArgs.Empty);
                        if (!ObjectPanel.IsValid)
                        {
                            this.Message = ObjectPanel.CheckErrorMessages();
                            return false;
                        }
                    }
                }

                // Saves the customized object fields and attributes.
                //
                if (EnableCustomizedObjects)
                    SaveCustomizedObject(SessionObject.ObjectID.Value);

                // Perform workflow transition. Note that the Transit
                // method must be called when we are OUTSIDE of the
                // connection boundary.
                //
                // Bear in mind that the actual transition of the workflow
                // occurs within a different thread, and has no visibility
                // of any variables kept within this thread. Also, any
                // variables set on the SessionObject before calling the
                // Transit method will be lost, because it will be reloaded
                // again in the workflow thread.
                //
                if (SessionObject is LogicLayerPersistentObject)
                {
                    try
                    {
                        ((LogicLayerPersistentObject)SessionObject).TriggerWorkflowEvent(GetObjectBaseSelectedAction());

                        if (((LogicLayerPersistentObject)SessionObject).CurrentActivity != null)
                        {
                            ((LogicLayerPersistentObject)SessionObject).CurrentActivity.Priority = Convert.ToInt16(dropApprovalImportance.SelectedValue);
                            ((LogicLayerPersistentObject)SessionObject).CurrentActivity.Save();
                        }
                    }
                    catch (WorkflowTransitionException ex)
                    {
                        this.Message =
                            String.Format(
                            Resources.Errors.Workflow_TransitionErrorRecordLocked,
                            Resources.Errors.Workflow_TransitionInvalid);
                        this.DisablePage();
                        throw ex;
                    }
                    catch (WorkflowAssignmentException ex)
                    {
                        this.Message =
                            String.Format(
                            Resources.Errors.Workflow_TransitionErrorRecordLocked,
                            Resources.Errors.Workflow_NoUsersToAssign);
                        this.DisablePage();
                        throw ex;
                    }
                    catch (Exception ex)
                    {
                        this.DisablePage();
                        throw new Exception(String.Format(
                            Resources.Errors.Workflow_TransitionErrorRecordLocked,
                            ex.Message));
                    }
                }
                c.Commit();
            }

            save = true;
            this.Message = "<img src='" + ResolveClientUrl("~/images/tick2.png") + "' style='border: 0px' /> <b>" + Resources.Messages.General_ItemSaved + "</b>";
            this.tableMessage.Style["background-color"] = "#ccffcc";

            //this.PopupMessage = "<img src='" + ResolveClientUrl("~/images/tick2.png") + "' style='border: 0px' /> <b>" + Resources.Messages.General_ItemSaved + "</b>";
            //this.popupMessage.MainPanel.Attributes["color"] = "#ccffcc";

            buttonDelete.Enabled = true;

            UpdateCurrentObjectInstanceKey();
            if (RefreshOpenerAfterSave)
                Window.Opener.Refresh();

            if (Page is UIPageBase)
                ((UIPageBase)Page).ClearModifiedFlag();

            // If it is found that the object is no longer assigned to
            // the current user because of a change in workflow assignments,
            // then disable the entire page.
            //
            if (SessionObject is LogicLayerPersistentObject &&
                ((LogicLayerPersistentObject)SessionObject).CurrentActivity != null &&
                !((LogicLayerPersistentObject)SessionObject).CurrentActivity.IsAssignedToUser(AppSession.User) &&
                !AppSession.User.AllowEditAll(Security.Decrypt(Request["TYPE"])))
                DisablePage();
        }
        catch (OutOfMemoryException ex)
        {
            // Catch the OutOfMemory exception
            //
            HttpRuntime.UnloadAppDomain();
            Response.Redirect(Request.ApplicationPath + "/applogin.aspx");
        }
        catch (ObjectModifiedException ex)
        {
            // Catch and handle the object modified exception
            //
            // Clear the URL of the message querystring
            //
            string rawUrl = Page.Request.RawUrl;
            if (rawUrl.Contains("MESSAGE="))
            {
                int indexOfMessage = rawUrl.IndexOf("MESSAGE=");
                int indexOfAmpersand = rawUrl.IndexOf("&", indexOfMessage);
                if (indexOfAmpersand < 0)
                    indexOfAmpersand = rawUrl.Length;
                rawUrl = rawUrl.Remove(indexOfMessage, indexOfAmpersand - indexOfMessage);
            }

            // Redirect to this same URL again and show
            // a new message.
            //
            Response.Redirect(rawUrl +
                (Page.Request.RawUrl.Contains("?") ? "&" : "?") +
                "MESSAGE=" + HttpUtility.UrlEncode(Resources.Errors.General_ObjectModified));
        }
        catch (Exception ex)
        {
            string errorMessage = ObjectPanel.CheckErrorMessages();
            if (errorMessage != null)
                this.Message = errorMessage;
            else
                ShowException(ex);
        }

        CallPopulateFormEvent();

        // Calls the Saved event.
        //
        if (AutomaticBindingAndSaving)
        {
            if (Saved != null)
                Saved(this.ObjectPanel, this.SessionObject);
        }

        return save;
    }

    /// <summary>
    /// Shows an exception in the message label.
    /// </summary>
    /// <param name="ex"></param>
    protected void ShowException(Exception ex)
    {
        StringBuilder sb = new StringBuilder();
        Exception currentException = ex;
        while (currentException != null)
        {
            sb.Append(currentException.Message + "\n" + currentException.StackTrace + "\n\n");
            currentException = currentException.InnerException;
        }
        this.Message =
            HttpUtility.HtmlEncode(sb.ToString()).Replace("\n", "<br>");
    }

    /// <summary>
    /// Shows the workflow dialog.
    /// </summary>
    protected void ShowWorkflowDialog()
    {
        try
        {
            labelMessage.Text = "";
            labelPopupMessage.Text = "";
            //labelSelectedAction.Text = GetObjectBaseSelectedActionText();
            //labelSelectedAction.Visible = false;
            //sep1.Caption = GetObjectBaseSelectedActionText();
            modalWorkflowPopup.Title = GetObjectBaseSelectedActionText();
            textTaskCurrentComments.Text = "";

            int priority = (((LogicLayerPersistentObject)SessionObject).CurrentActivity.Priority == null ? 0 : ((LogicLayerPersistentObject)SessionObject).CurrentActivity.Priority.Value);
            dropApprovalImportance.SelectedValue = priority.ToString();

            // 2011.12.22 ptb
            // Customized for OWork RCS
            if (((LogicLayerPersistentObject)SessionObject) is OWork)
            {
                OWork work = (OWork)((LogicLayerPersistentObject)SessionObject);
                if (GetObjectBaseSelectedAction().StartsWith("SubmitForClosure") && OWork.ValidateInventoryItems(false, work))
                {
                    textConfirmation.Visible = true;
                    textConfirmation.Text = Resources.Messages.Work_CloseConfirmation;
                    CommentTextValidateRequiredField = true;
                }
                else if (GetObjectBaseSelectedAction().StartsWith("Cancel") && OWork.ValidateInventoryItems(true, work))
                {
                    textConfirmation.Visible = true;
                    textConfirmation.Text = Resources.Messages.Work_CancelConfirmation;
                    CommentTextValidateRequiredField = true;
                }
                else
                {
                    textConfirmation.Visible = false;
                    CommentTextValidateRequiredField = false;
                }
            }

            // Populate the approval process dropdown list
            //
            if (GetObjectBaseSelectedAction().StartsWith("SubmitForApproval"))
            {
                // 2010.04.23
                // We must bind controls to object to get the latest
                // data entered from the user interface, so that
                // when we call GetApprovalProcesses, we have the
                // latest data to obtain the TaskLocations/
                // TaskEquipment/TaskTypeOfServices/TaskAmount.
                //
                this.ObjectPanel.BindControlsToObject(this.SessionObject);

                panelApprovalProcess.Visible = true;
                dropApprovalProcess.Visible = true;
                dropApprovalImportance.Visible = true;

                dropApprovalProcess.Bind(
                    OApprovalProcess.GetApprovalProcesses(
                    (LogicLayerPersistentObject)SessionObject),
                    "Description", "ObjectID", false);

                if (dropApprovalProcess.Items.Count == 1)
                    dropApprovalProcess.Enabled = false;
                else
                    dropApprovalProcess.Enabled = true;

                // 2010.05.16
                // Kim Foong
                // Resets the skip checkbox to true, so that it's always by default
                // set to true whenever the dialog box opens up.
                //
                checkSkipLevels.Checked = true;

                if (dropApprovalProcess.Items.Count > 0 &&
                    dropApprovalProcess.Items[0].Value != "")
                    ShowApprovalHierarchy(new Guid(dropApprovalProcess.Items[0].Value));
                else
                    ShowApprovalHierarchy(null);

            }
            else if (GetObjectBaseSelectedAction() == "Approve")
            {
                panelApprovalProcess.Visible = true;
                dropApprovalProcess.Visible = false;
                dropApprovalImportance.Visible = false;

                if (SessionObject is LogicLayerPersistentObject)
                    ShowApprovalHierarchy(((LogicLayerPersistentObject)SessionObject).CurrentActivity.ApprovalProcessID);
            }
            else
            {
                panelApprovalProcess.Visible = false;
                dropApprovalProcess.Visible = true;
                dropApprovalImportance.Visible = false;
            }

            modalWorkflowPopup.Show();
            mainPanel.Update();
        }
        catch (Exception ex)
        {
            ShowException(ex);
        }
    }

    /// <summary>
    /// Hides the workflow dialog.
    /// </summary>
    protected void HideWorkflowDialog()
    {
        modalWorkflowPopup.Hide();
        panelApprovalProcess.Visible = false;
        mainPanel.Update();
    }

    /// <summary>
    /// Show the approval hierarchy on the gridview.
    /// </summary>
    /// <param name="approvalProcessDetailId"></param>
    protected void ShowApprovalHierarchy(Guid? approvalProcessId)
    {
        // Bind the object before displaying the approval
        // hierarchy, because displaying the approval hierarchy
        //
        // 2010.04.23
        // This should not be included here, but rather in the
        // ShowApprovalDialog above.
        //
        // this.ObjectPanel.BindControlsToObject(this.SessionObject);

        if (approvalProcessId == null)
        {
            labelModeOfForwarding.Text = "";
            gridApprovalProcess.DataSource = null;
            gridApprovalProcess.DataBind();

            gridApprovalProcess.Visible = false;
            labelApproved.Visible = false;
            labelApprovalNotRequired.Visible = false;
            labelNoApproversFound.Visible = false;
            labelNoAuthorizedApproved.Visible = false;
            labelRequiredApproved.Visible = false;
        }
        else
        {
            OApprovalProcess approvalProcess =
                TablesLogic.tApprovalProcess.Load(approvalProcessId);

            labelModeOfForwarding.Text = approvalProcess.ModeOfForwardingText;

            gridApprovalProcess.Columns[4].Visible =
                approvalProcess.ModeOfForwarding == ApprovalModeOfForwarding.Direct ||
                approvalProcess.ModeOfForwarding == ApprovalModeOfForwarding.Hierarchical ||
                approvalProcess.ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithLastRejectedSkipping ||
                approvalProcess.ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithRequestorAndLastRejectedSkipping;

            if (SessionObject is LogicLayerPersistentObject)
            {
                List<OApprovalHierarchyLevel> approvalHierarchyLevels = new List<OApprovalHierarchyLevel>();
                int? nextApprovalLevel = 0;

                if ((approvalProcess.ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithLastRejectedSkipping ||
                    approvalProcess.ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithRequestorAndLastRejectedSkipping) &&
                    ((LogicLayerPersistentObject)SessionObject).CurrentActivity.CurrentApprovalLevel == null &&
                    ((LogicLayerPersistentObject)SessionObject).CurrentActivity.LastApprovalLevel != null)
                {

                    if (((LogicLayerPersistentObject)SessionObject).CurrentActivity.PreviousTaskAmount !=
                        ((LogicLayerPersistentObject)SessionObject).TaskAmount)
                        checkSkipLevels.Checked = false;
                    else
                        checkSkipLevels.Checked = true;

                    // Case of cancellation, force the task to go throught
                    // approval hierarchy again.
                    //
                    if (GetObjectBaseSelectedAction().Contains("Cancel"))
                        checkSkipLevels.Checked = false;

                    checkSkipLevels.Enabled = false;
                }
                else if (approvalProcess.ModeOfForwarding != ApprovalModeOfForwarding.HierarchicalWithLastRejectedSkipping &&
                    approvalProcess.ModeOfForwarding != ApprovalModeOfForwarding.HierarchicalWithRequestorAndLastRejectedSkipping)
                    checkSkipLevels.Checked = false;

                if (approvalProcess.ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithRequestorAndLastRejectedSkipping &&
                    ((LogicLayerPersistentObject)SessionObject).CurrentActivity.CurrentApprovalLevel == null)
                {
                    checkSkipNextLevels.Checked = true;

                    List<OApprovalHierarchyLevel> levels = new List<OApprovalHierarchyLevel>();
                    approvalProcess.GetApprovalHierarchyLevels((LogicLayerPersistentObject)SessionObject, levels, out nextApprovalLevel);

                    int lastLevelIndex = levels.FindLastIndex((l) => l.Positions.Find((p) =>
                        p.Users.Find((u) => u.ObjectID == AppSession.User.ObjectID) != null) != null |
                        l.Users.Find((u) => u.ObjectID == AppSession.User.ObjectID) != null);

                    if (levels.Count > lastLevelIndex + 1 &&
                        lastLevelIndex != -1)
                        ((LogicLayerPersistentObject)SessionObject).CurrentActivity.NextApprovalLevel = levels[lastLevelIndex + 1].ApprovalLevel;

                    checkSkipNextLevels.Enabled = false;
                }

                // 2010.05.16
                // Kim Foong
                // Pass in the checkSkipLevels value to skip approval levels
                // where applicable.
                //
                ((LogicLayerPersistentObject)SessionObject).CurrentActivity.SkipToLastRejectedLevel = checkSkipLevels.Checked ? (int)EnumApplicationGeneral.Yes : (int)EnumApplicationGeneral.No;
                ((LogicLayerPersistentObject)SessionObject).CurrentActivity.SkipToNextRequiredApprovalLevel = checkSkipNextLevels.Checked ? (int)EnumApplicationGeneral.Yes : (int)EnumApplicationGeneral.No;

                // 2010.05.16
                // Kim Foong
                checkSkipLevels.Visible =
                    (approvalProcess.ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithLastRejectedSkipping ||
                    approvalProcess.ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithRequestorAndLastRejectedSkipping) &&
                    ((LogicLayerPersistentObject)SessionObject).CurrentActivity.CurrentApprovalLevel == null &&
                    ((LogicLayerPersistentObject)SessionObject).CurrentActivity.LastApprovalLevel != null;

                checkSkipNextLevels.Visible =
                    (approvalProcess.ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithRequestorAndLastRejectedSkipping) &&
                    ((LogicLayerPersistentObject)SessionObject).CurrentActivity.CurrentApprovalLevel == null &&
                    ((LogicLayerPersistentObject)SessionObject).CurrentActivity.NextApprovalLevel != null;

                // 2010.05.16
                // Kim Foong
                int approvalResult =
                    approvalProcess.GetApprovalHierarchyLevels(
                    (LogicLayerPersistentObject)SessionObject,
                    approvalHierarchyLevels,
                    out nextApprovalLevel);

                // 2011.02.11
                // Kien Trung
                // if there is no approval found.
                // Uncheck skip to last level and reload the approval hierarchy again.
                //
                if (approvalResult == ApprovalResult.NoApproversFound &&
                    (approvalProcess.ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithLastRejectedSkipping ||
                    approvalProcess.ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithRequestorAndLastRejectedSkipping))
                {
                    checkSkipLevels.Checked = false;

                    ((LogicLayerPersistentObject)SessionObject).CurrentActivity.SkipToLastRejectedLevel = checkSkipLevels.Checked ? (int)EnumApplicationGeneral.Yes : (int)EnumApplicationGeneral.No;
                    approvalResult =
                        approvalProcess.GetApprovalHierarchyLevels(
                        (LogicLayerPersistentObject)SessionObject,
                        approvalHierarchyLevels,
                        out nextApprovalLevel);
                }

                int lastIndex = approvalHierarchyLevels.FindLastIndex((l) => l.Positions.Find((p) =>
                    p.Users.Find((u) => u.ObjectID == AppSession.User.ObjectID) != null) != null |
                    l.Users.Find((u) => u.ObjectID == AppSession.User.ObjectID) != null);

                approvalResult = ((((LogicLayerPersistentObject)SessionObject).CurrentActivity.ApprovedUsers.Find(AppSession.User.ObjectID.Value) != null) ? ApprovalResult.UnableToApprove : approvalResult);
                approvalResult = (approvalResult == ApprovalResult.NoApproversFound && checkSkipNextLevels.Checked ? ApprovalResult.UnableToSubmit : approvalResult);
                if (GetObjectBaseSelectedAction().StartsWith("SubmitForApproval"))
                {
                    if (approvalProcess.ModeOfForwarding != ApprovalModeOfForwarding.None
                        && approvalHierarchyLevels.Count == lastIndex + 1)
                        approvalResult = ApprovalResult.UnableToSubmit;
                }

                gridApprovalProcess.DataSource = approvalHierarchyLevels;
                gridApprovalProcess.DataBind();

                gridApprovalProcess.Visible = approvalResult == ApprovalResult.ApprovalRequired;
                labelApproved.Visible = approvalResult == ApprovalResult.Approved;
                labelApprovalNotRequired.Visible = approvalResult == ApprovalResult.NoApprovalRequired;
                labelNoAuthorizedApproved.Visible = approvalResult == ApprovalResult.UnableToSubmit;
                labelNoApproversFound.Visible = approvalResult == ApprovalResult.NoApproversFound;
                labelRequiredApproved.Visible = approvalResult == ApprovalResult.UnableToApprove;
            }
        }
    }

    /// <summary>
    /// Occurs when the user selects a different approval process, in
    /// which case, we will update the approval hierarchy details on
    /// the grid.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropApprovalProcess_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (dropApprovalProcess.SelectedValue == "")
            ShowApprovalHierarchy(null);
        else
            ShowApprovalHierarchy(new Guid(dropApprovalProcess.SelectedValue));
    }

    /// <summary>
    /// Occurs when the Save Item button is clicked.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttOnValidateAndSave_Click(object sender, EventArgs e)
    {
        try
        {
            if (!IsValid())
                return;

            string selectedAction = GetObjectBaseSelectedAction();
            if (selectedAction != "-" && selectedAction != "" &&
                (ShowWorkflowDialogBox || selectedAction.StartsWith("SubmitForApproval")))
            {
                textClickedButton.Text = "buttOnValidateAndSave";
                ProcessSubPanel(this.ObjectPanel, 0);

                // 2011.08.20, Kien Trung
                // Bug Fixed: Calls the Validate event before showing the workflow dialog.
                //
                if (Validate != null)
                    Validate(this.ObjectPanel, this.SessionObject);

                if (!ObjectPanel.IsValid)
                {
                    this.Message = ObjectPanel.CheckErrorMessages();
                    return;
                }

                // 2010.10.17
                // Chee Meng
                // Checks if any sub panels are open and validate page for errors
                if (Page.IsValid)
                    ShowWorkflowDialog();
            }
            else
            {
                // 2010.10.17
                // Chee Meng
                // Checks if any sub panels are open and validate page for errors
                //if (SubPanelCount > 0)
                {
                    ProcessSubPanel(this.ObjectPanel, 0);
                    if (Page.IsValid)
                        SaveObjectAndTransit();
                }
            }
        }
        catch (Exception ex)
        {
            ShowException(ex);
        }
    }

    // 2010.10.17
    // Chee Meng
    // Recursive function to validate all the open subpanels
    protected void ProcessSubPanel(Control c, int countSubPanel)
    {
        foreach (Control child in c.Controls)
        {
            if (child.GetType().FullName == "ASP.objectSubPanel" && countSubPanel < SubPanelCount)
            {
                UIObjectPanel subObjectPanel = getPanel(child);
                Page.Validate(subObjectPanel.ClientID);
                /// Manually calls the click buttonUpdate event as per normal
                /// Get the subObjectPanel error messages and append to this ObjectPanel.Message

                if (Page.IsValid)
                {
                    //PropertyInfo IsAddingObject = child.GetType().GetProperty("IsAddingObject", BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static | BindingFlags.Instance);
                    PropertyInfo isVisible = child.GetType().GetProperty("Visible", BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static | BindingFlags.Instance);
                    if ((bool)isVisible.GetValue(child, null) == true)
                    {
                        MethodInfo buttonUpdate_Click = child.GetType().GetMethod("buttonUpdate_Click", BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static | BindingFlags.Instance);
                        buttonUpdate_Click.Invoke(child, new object[] { null, EventArgs.Empty });
                    }
                }
                if (subObjectPanel.CheckErrorMessages() != null && subObjectPanel.CheckErrorMessages() != string.Empty)
                {
                    this.Message = subObjectPanel.CheckErrorMessages();
                }
                countSubPanel = countSubPanel + 1;
            }
            else
            {
                ProcessSubPanel(child, countSubPanel);
            }
        }
    }

    // 2010.10.17
    // Chee Meng
    // Gets UIObjectPanel from control
    protected UIObjectPanel getPanel(Control c)
    {
        c = c.Parent;
        while (c != null)
        {
            if (c is UIObjectPanel)
                break;
            c = c.Parent;
        }
        if (c != null && c is UIObjectPanel)
            return (UIObjectPanel)c;
        else
            return null;
    }

    /// <summary>
    /// Occurs when the Save and New button is clicked.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttOnValidateAndSaveAndNew_Click(object sender, EventArgs e)
    {
        try
        {
            if (!IsValid())
                return;

            string selectedAction = GetObjectBaseSelectedAction();
            if (selectedAction != "-" && selectedAction != "" && (ShowWorkflowDialogBox || selectedAction.StartsWith("SubmitForApproval")))
            {
                textClickedButton.Text = "buttOnValidateAndSaveAndNew";
                ProcessSubPanel(this.ObjectPanel, 0);

                // 2011.08.20, Kien Trung
                // Bug Fixed: Calls the Validate event before showing the workflow dialog.
                //
                if (Validate != null)
                    Validate(this.ObjectPanel, this.SessionObject);

                if (!ObjectPanel.IsValid)
                {
                    this.Message = ObjectPanel.CheckErrorMessages();
                    return;
                }

                // 2010.10.17
                // Chee Meng
                // Checks if any sub panels are open and validate page for errors
                if (Page.IsValid)
                    ShowWorkflowDialog();
            }
            else
            {
                // 2010.10.17
                // Chee Meng
                // Checks if any sub panels are open and validate page for errors
                //if (SubPanelCount > 0)
                {
                    ProcessSubPanel(this.ObjectPanel, 0);
                    if (Page.IsValid)
                        if (SaveObjectAndTransit())
                        {
                            string queryString = "";
                            foreach (string key in Page.Request.QueryString.Keys)
                                if (key != "TYPE" && key != "ID" && key != "MESSAGE")
                                    queryString += (queryString == "" ? "" : "&") + key + "=" + HttpUtility.UrlEncode(Page.Request.QueryString[key]);
                            queryString += (queryString == "" ? "" : "&") + "MESSAGE=" + Resources.Messages.General_ItemSavedAndNew;

                            Window.OpenAddObjectPage(Page, Security.Decrypt(Request["TYPE"]), queryString);
                        }
                }
            }
        }
        catch (Exception ex)
        {
            ShowException(ex);
        }

    }

    /// <summary>
    /// Occurs when the Save and Close button is clicked.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttOnValidateAndSaveAndClose_Click(object sender, EventArgs e)
    {
        try
        {
            if (!IsValid())
                return;

            string selectedAction = GetObjectBaseSelectedAction();
            if (selectedAction != "-" && selectedAction != "" && (ShowWorkflowDialogBox || selectedAction == "SubmitForApproval"))
            {
                textClickedButton.Text = "buttOnValidateAndSaveAndClose";
                ProcessSubPanel(this.ObjectPanel, 0);

                // 2011.08.20, Kien Trung
                // Bug Fixed: Calls the Validate event before showing the workflow dialog.
                //
                if (Validate != null)
                    Validate(this.ObjectPanel, this.SessionObject);

                if (!ObjectPanel.IsValid)
                {
                    this.Message = ObjectPanel.CheckErrorMessages();
                    return;
                }

                // 2010.10.17
                // Chee Meng
                // Checks if any sub panels are open and validate page for errors
                if (Page.IsValid)
                    ShowWorkflowDialog();
            }
            else
            {
                // 2010.10.17
                // Chee Meng
                // Checks if any sub panels are open and validate page for errors
                //if (SubPanelCount > 0)
                {
                    ProcessSubPanel(this.ObjectPanel, 0);
                    if (Page.IsValid)
                    {
                        SaveObjectAndTransit();
                        Window.Close();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowException(ex);
        }
    }

    protected void buttOnValidateAndSaveWorkflowPopup_Click(object sender, EventArgs e)
    {
        // If the validation has failed, return.
        //
        //if (!panelWorkflowPopup.IsValid)
        return;

        // Update the current activity's comments and approval
        // hierarchy.
        //
        if (SessionObject is LogicLayerPersistentObject)
        {
            ((LogicLayerPersistentObject)SessionObject).CurrentActivity.TriggeringEventName = GetObjectBaseSelectedAction();
            ((LogicLayerPersistentObject)SessionObject).CurrentActivity.TaskCurrentComments = textTaskCurrentComments.Text;
            if (dropApprovalProcess.Visible)
            {
                ((LogicLayerPersistentObject)SessionObject).CurrentActivity.ApprovalProcessID = new Guid(dropApprovalProcess.SelectedValue);
                ((LogicLayerPersistentObject)SessionObject).CurrentActivity.Priority = Convert.ToInt16(dropApprovalImportance.SelectedValue);
            }
        }
        HideWorkflowDialog();

        // Follow up with the button action.
        //
        string clickedButton = (string)textClickedButton.Text;
        if (clickedButton == "buttOnValidateAndSave")
        {
            SaveObjectAndTransit();
        }
        else if (clickedButton == "buttOnValidateAndSaveAndNew")
        {
            if (SaveObjectAndTransit())
            {
                string queryString = "";
                foreach (string key in Page.Request.QueryString.Keys)
                    if (key != "TYPE" && key != "ID" && key != "MESSAGE")
                        queryString += (queryString == "" ? "" : "&") + key + "=" + HttpUtility.UrlEncode(Page.Request.QueryString[key]);
                queryString += (queryString == "" ? "" : "&") + "MESSAGE=" + Resources.Messages.General_ItemSavedAndNew;

                Window.OpenAddObjectPage(Page, Security.Decrypt(Request["TYPE"]), queryString);
            }
        }
        else if (clickedButton == "buttOnValidateAndSaveAndClose")
        {
            if (SaveObjectAndTransit())
                Window.Close();
        }
    }

    protected void buttonCancelWorkflowPopup_Click(object sender, EventArgs e)
    {
        HideWorkflowDialog();
    }

    public delegate void ObjectEventHandler(object sender, PersistentObject obj);

    /// <summary>
    /// Occurs immediately when the form is loaded and when the
    /// PersistentObject is saved successfully into the database.
    /// </summary>
    public event EventHandler PopulateForm;

    /// <summary>
    /// Occurs when the panel tries to save the object
    /// into the database.
    /// </summary>
    public event EventHandler ValidateAndSave;

    /// <summary>
    /// Occurs when the panel after basic validation,
    /// before the object is saved into the database.
    /// </summary>
    public event ObjectEventHandler Validate;

    /// <summary>
    /// Occurs when the panel after basic validation,
    /// before the object is saved into the database.
    /// </summary>
    public event ObjectEventHandler Saving;

    /// <summary>
    /// Occurs when the panel the object is saved successfully
    /// into the database.
    /// </summary>
    public event ObjectEventHandler Saved;

    #region CustomizedObject_13Apr2007

    /// <summary>
    /// Gets or sets a flag that indicates if this object
    /// has attributes.
    /// </summary>
    private bool HasAttributeField
    {
        get
        {
            if (Session["HasAttributeField"] == null)
                return false;
            return Convert.ToBoolean(Session["HasAttributeField"]);
        }
        set
        {
            Session["HasAttributeField"] = value;
        }
    }

    /// <summary>
    /// Gets or sets a flag that indicates if the object has
    /// records.
    /// </summary>
    private bool HasRecordField
    {
        get
        {
            if (Session["HasRecordField"] == null)
                return false;
            return Convert.ToBoolean(Session["HasRecordField"]);

        }
        set
        {
            Session["HasRecordField"] = value;
        }
    }

    /// <summary>
    /// Gets or sets the attached property name.
    /// </summary>
    private string AttachedPropertyName
    {
        get
        {
            if (Session["AttachedPropertyName"] == null)
                return null;
            else
                return Session["AttachedPropertyName"].ToString();
        }
        set
        {
            Session["AttachedPropertyName"] = value;
        }
    }

    /// <summary>
    /// Gets or sets the GUID of the attached property.
    /// </summary>
    [Browsable(false), DefaultValue(null), Localizable(false)]
    private Guid? AttributeAttachedPropertyID
    {
        get
        {
            if (Session["AttributeAttachedPropertyID"] == null)
                return null;
            return new Guid(Session["AttributeAttachedPropertyID"].ToString());
        }
        set
        {
            Session["AttributeAttachedPropertyID"] = value;
        }
    }

    /// <summary>
    /// Store a list of control ID build by Customized Attribute component,
    /// in order to remove from the page those when necessary
    /// </summary>
    private List<OCustomizedAttributeField> CurrentAttributeFieldList
    {
        get
        {
            if (Session["AttributeFieldIDList"] == null)
                return null;
            return (List<OCustomizedAttributeField>)Session["AttributeFieldIDList"];
        }
        set
        {
            Session["AttributeFieldIDList"] = value;
        }
    }

    /// <summary>
    /// Store the id of the tabview control that hold all attribute fields,
    /// in order to remove from the page those when necessary
    /// </summary>
    private string AttributeTabViewID
    {
        get
        {
            if (Session["AttributeTabViewID"] == null)
                return null;
            return Session["AttributeTabViewID"].ToString();
        }
        set
        {
            Session["AttributeTabViewID"] = value;
        }
    }

    /// <summary>
    /// Gets the current PersistentObjectID.
    /// </summary>
    private Guid? CurrentObjectID
    {
        get
        {
            //for edit and view request
            try
            {
                //string objectID = Security.Decrypt(Request["ID"]).Split(':')[1];
                //sometimes ID is not passed in (usually for add new object)
                //return new Guid(objectID);
                return SessionObject.ObjectID;
            }
            catch
            {
                return null;
            }
        }
    }
    private string NoAttributeMessageID
    {
        get
        {
            if (Session["AttributeMessageID"] == null)
                return null;
            return Session["AttributeMessageID"].ToString();
        }
        set
        {
            Session["AttributeMessageID"] = value;
        }
    }

    private void ClearCustomizedObjectSession()
    {
        Session["HasAttributeField"] = null;
        Session["HasRecordField"] = null;
        Session["AttachedPropertyName"] = null;
        Session["AttributeAttachedPropertyID"] = null;
        Session["AttributeFieldIDList"] = null;
        Session["AttributeTabViewID"] = null;
        Session["AttributeMessageID"] = null;
    }

    //retrieve object type id to get correct list of object record field
    protected OCustomizedRecordObject GetCurrentObjectType()
    {
        if (Request["TYPE"] != null)
        {
            string objectTypeID = Security.Decrypt(Request["TYPE"].ToString());
            List<OCustomizedRecordObject> record = TablesLogic.tCustomizedRecordObject[TablesLogic.tCustomizedRecordObject.AttachedObjectName == objectTypeID];
            if (record != null && record.Count > 0)
                return record[0];
            else
                return null;
        }
        return null;
    }
    //Add customized object record fields at the tabstrip before memo or attachment.(else last tabstrip)
    protected void InitObjectRecordFields()
    {
        OCustomizedRecordObject record = GetCurrentObjectType();
        if (record != null)
        {
            InitCustomizedFields(Resources.Strings.CustomizedObject_Fields, (record.TabViewPosition == null ? -1 : record.TabViewPosition.Value), record.CustomizedRecordFields, null);
            HasRecordField = true;
        }
        else
        {
            HasRecordField = false;
        }
    }
    protected void PopulateCustomizedRecordFieldValues()
    {
        if (HasRecordField)
            BindCustomizedFieldValues(TablesLogic.tCustomizedRecordFieldValue[TablesLogic.tCustomizedRecordFieldValue.AttachedObjectID == CurrentObjectID]);

    }

    protected void SaveCustomizedRecordObject(Guid objID)
    {
        if (!HasRecordField)
            return;
        OCustomizedRecordObject record = GetCurrentObjectType();
        if (record != null)
        {
            using (Connection c = new Connection())
            {
                foreach (OCustomizedRecordField field in record.CustomizedRecordFields)
                {
                    //do not set value for separator field
                    if (field.ControlType == "Separator")
                        continue;
                    //update existing record value if exist, else create new
                    List<OCustomizedRecordFieldValue> fieldValues = TablesLogic.tCustomizedRecordFieldValue[TablesLogic.tCustomizedRecordFieldValue.AttachedObjectID == objID & TablesLogic.tCustomizedRecordFieldValue.ColumnName == field.ColumnName];
                    OCustomizedRecordFieldValue fieldValue;
                    if (fieldValues == null || fieldValues.Count == 0)
                    {
                        fieldValue = TablesLogic.tCustomizedRecordFieldValue.Create();
                        fieldValue.AttachedObjectID = objID;
                        fieldValue.ColumnName = field.ColumnName;
                    }
                    else
                        fieldValue = fieldValues[0];
                    Control control = Page.FindControl(field.ColumnName);
                    if (control != null && control is UIFieldBase)
                    {
                        if (((UIFieldBase)control).ControlValue != null && ((UIFieldBase)control).ControlValue.ToString().Trim() != "")
                            fieldValue.FieldValue = Convert.ToString(((UIFieldBase)control).ControlValue);
                        else
                            fieldValue.FieldValue = null;
                        //do not save if the field value is empty for add case
                        if (!fieldValue.IsNew || (fieldValue.IsNew && fieldValue.FieldValue != null))
                            fieldValue.Save();
                    }
                }
                c.Commit();
            }

        }

    }

    protected void InitObjectAttributeFields()
    {
        //initialize attached property name and attribute tab view ID
        if (AttachedPropertyName == null)
        {
            string[] setting = OCustomizedObjectConsumer.GetAttachedObjectSetting(BaseTable);
            if (setting != null)
            {
                AttachedPropertyName = setting[0];
                AttributeTabViewID = setting[1];
            }
            else
            {
                EmptyAttributeSetting();
                return;
            }
        }

        //initialize attribute attached property at the first time an object is edited (not for add case)
        if (AttributeAttachedPropertyID == null && CurrentObjectID != null)
        {
            //AttributeAttachedPropertyID = OCustomizedObjectConsumer.GetAttachedObjectAttributeID(BaseTable, AttachedPropertyName, CurrentObjectID.Value);
            if (SessionObject.DataRow[AttachedPropertyName] != null &&
                SessionObject.DataRow[AttachedPropertyName] != DBNull.Value)
                AttributeAttachedPropertyID = (Guid)SessionObject.DataRow[AttachedPropertyName];
            GetAttributeFieldsForInitialization();
        }

        if (AttributeTabViewID == null)
            return;
        if (HasAttributeField)
        {
            InitCustomizedFields(null, -1, CurrentAttributeFieldList, AttributeTabViewID);
        }
    }
    private void InitNoAttributeMessage()
    {
        if (AttributeTabViewID != null)
        {
            UITabView tabView = Page.FindControl(AttributeTabViewID) as UITabView;
            UIFieldLabel message;
            if (NoAttributeMessageID == null || Page.FindControl(NoAttributeMessageID) == null)
            {
                //for attribute fields, if there is no fields, display a label that say there is no attribute fields
                message = new UIFieldLabel();
                tabView.Controls.Add(message);
                message.ID = "___customizedAttributesMessage___";
                message.ForeColor = System.Drawing.Color.Red;
                message.ControlValue = Resources.Messages.CustomizedObject_NoAttributeFields;
                message.CaptionWidth = new Unit("1");
                NoAttributeMessageID = message.ID;
            }
        }
    }

    /// <summary>
    /// set all flag for initialization and loading of attribute fields to false to avoid any attempt to build attribute fields
    /// </summary>
    private void EmptyAttributeSetting()
    {
        CurrentAttributeFieldList = null;
        HasAttributeField = false;
        AttributeAttachedPropertyID = null;
    }
    /// <summary>
    /// retrieve attribute fields based on the latest attribute attachedpropertyID.
    /// And update the currentAttributeFieldList, and hasattributeField
    /// </summary>
    /// <returns></returns>
    private void GetAttributeFieldsForInitialization()
    {
        if (AttributeAttachedPropertyID == null)
        {
            EmptyAttributeSetting();
            return;
        }
        else
        {
            List<OCustomizedAttributeField> fields = OCustomizedObjectConsumer.GetCustomizedAttributeFields(BaseTable, AttributeAttachedPropertyID.Value, true);
            if (fields == null || fields.Count == 0)
                HasAttributeField = false;
            else
            {
                HasAttributeField = true;
                if (CurrentAttributeFieldList == null)
                    CurrentAttributeFieldList = new List<OCustomizedAttributeField>();
                CurrentAttributeFieldList = fields;
            }

        }

    }
    /// <summary>
    /// this function will be called by the page that display attribute fields, whenever the attribte type if changed. (i.e. LocationTypeID is change)
    /// rebuild the attribute fields and set attributeattachedpropertyId to new id
    /// </summary>

    public void UpdateCustomizedAttributeFields(Guid? newPropertyID)
    {
        InitNoAttributeMessage();
        //if the same propertyid, do not proceed
        if (AttributeAttachedPropertyID != null && newPropertyID != null && AttributeAttachedPropertyID.Value.ToString().Equals(newPropertyID.Value.ToString()))
            return;
        //Remove the current attribute fields
        //set the current attribute visibility to false
        if (CurrentAttributeFieldList != null)
        {
            foreach (OCustomizedAttributeField field in CurrentAttributeFieldList)
            {
                Control control = Page.FindControl(field.ColumnName);
                if (control != null)
                    control.Visible = false;
            }
        }
        EmptyAttributeSetting();
        AttributeAttachedPropertyID = newPropertyID;
        GetAttributeFieldsForInitialization();
        if (CurrentAttributeFieldList != null && CurrentAttributeFieldList.Count > 0)
        {
            if (AttributeTabViewID == null)
                return;
            InitCustomizedFields(null, -1, CurrentAttributeFieldList, AttributeTabViewID);
        }
    }

    protected void PopulateCustomizedAttributeFieldValues()
    {
        if (!HasAttributeField)
            return;
        BindCustomizedFieldValues(TablesLogic.tCustomizedAttributeFieldValue[TablesLogic.tCustomizedAttributeFieldValue.AttachedObjectID == CurrentObjectID & TablesLogic.tCustomizedAttributeFieldValue.AttachedPropertyID == AttributeAttachedPropertyID.Value]);
    }

    protected void SaveCustomizedAttributeObject(Guid objID)
    {
        if (!HasAttributeField)
            return;
        //get all the attribute fields for the object
        List<OCustomizedAttributeField> fields = OCustomizedObjectConsumer.GetCustomizedAttributeFields(BaseTable, AttributeAttachedPropertyID.Value, false);
        if (fields == null || fields.Count == 0)
            return;
        using (Connection c = new Connection())
        {
            foreach (OCustomizedAttributeField field in fields)
            {
                if (field.IsVisible == 0)
                    continue;
                //update existing record value if exist, else create new
                List<OCustomizedAttributeFieldValue> fieldValues = TablesLogic.tCustomizedAttributeFieldValue[TablesLogic.tCustomizedAttributeFieldValue.AttachedObjectID == objID & TablesLogic.tCustomizedAttributeFieldValue.AttachedPropertyID == AttributeAttachedPropertyID.Value & TablesLogic.tCustomizedAttributeFieldValue.ColumnName == field.ColumnName];
                OCustomizedAttributeFieldValue fieldValue;
                if (fieldValues == null || fieldValues.Count == 0)
                {
                    fieldValue = TablesLogic.tCustomizedAttributeFieldValue.Create();
                    //fieldValue.AttachedObjectID = currentObject.ObjectID;
                    fieldValue.AttachedObjectID = SessionObject.ObjectID;
                    fieldValue.AttachedPropertyID = AttributeAttachedPropertyID;
                    fieldValue.ColumnName = field.ColumnName;
                }
                else
                    fieldValue = fieldValues[0];
                Control control = Page.FindControl(field.ColumnName);
                if (control != null && control is UIFieldBase)
                {
                    if (((UIFieldBase)control).ControlValue != null && ((UIFieldBase)control).ControlValue.ToString().Trim() != "")
                        fieldValue.FieldValue = Convert.ToString(((UIFieldBase)control).ControlValue);
                    else
                        fieldValue.FieldValue = null;
                    //do not save if the field value is empty for add case
                    if (!fieldValue.IsNew || (fieldValue.IsNew && fieldValue.FieldValue != null))
                        fieldValue.Save();
                }
            }
            c.Commit();
        }
    }
    protected void SaveCustomizedObject(Guid objID)
    {
        //Save object record value
        SaveCustomizedRecordObject(objID);
        //Save object attribute value
        SaveCustomizedAttributeObject(objID);

    }
    protected void BindCustomizedFieldValues(IEnumerable fieldData)
    {
        foreach (OCustomizedFieldValue field in fieldData)
        {
            Control control = Page.FindControl(field.ColumnName);
            if (control != null && control is UIFieldBase)
            {
                //to avoid user updating the setting of the control such as changing from string to integer type, do not display those value
                try
                {
                    UIFieldBase fieldControl = (UIFieldBase)control;
                    if (fieldControl.ValidateDataTypeCheck)
                    {
                        if (fieldControl.ValidationDataType == ValidationDataType.Currency)
                            Convert.ToDecimal(field.FieldValue);
                        else if (fieldControl.ValidationDataType == ValidationDataType.Date)
                            Convert.ToDateTime(field.FieldValue);
                        else if (fieldControl.ValidationDataType == ValidationDataType.Double)
                            Convert.ToDouble(field.FieldValue);
                        else if (fieldControl.ValidationDataType == ValidationDataType.Integer)
                            Convert.ToInt32(field.FieldValue);
                    }
                    //Control such as checkbox only accept boolean or int value, not string. Convert to boolean first before pass in
                    if (control is UIFieldCheckBox)
                        ((UIFieldBase)control).ControlValue = Convert.ToBoolean(field.FieldValue);
                    else
                        ((UIFieldBase)control).ControlValue = field.FieldValue;

                }
                catch
                {
                }

            }
        }
    }

    /// <summary>
    ///
    /// </summary>
    protected void PopulateCustomizedObject()
    {
        PopulateCustomizedRecordFieldValues();
        //populate object attribute details
        PopulateCustomizedAttributeFieldValues();

    }

    protected void InitCustomizedObject()
    {
        //Add customized object record fields at the tabstrip at the stage that populate form has been called and on every postback
        InitObjectRecordFields();
        //add object attribute fields
        InitObjectAttributeFields();
        InitNoAttributeMessage();
    }
    /// <summary>
    /// //Add customized object record fields at the tabstrip before memo or attachment.(else last tabstrip)
    /// </summary>
    /// <param name="tabViewCaption"></param>
    /// <param name="tabViewPosition"></param>
    /// <param name="fields"></param>
    /// <param name="tabViewID">pass in a null value if a new tabview is to be created to add the fields</param>
    /// <returns>return the tabview ID that is created from this method</returns>
    protected void InitCustomizedFields(string tabViewCaption, int? tabViewPosition, IEnumerable fields, string controlID)
    {
        Control container = null;
        //if the container controlID exist, do not create new control
        if (controlID != null)
        {
            container = Page.FindControl(controlID);
            if (container == null)
                throw new Exception("Error encountered while building customized object control. There is no control with id: " + controlID + " exist in the page");
            if (container is UITabView)
                ((UITabView)container).Update();
        }
        else
        {
            //create a tab view to accomodate all of the fields
            container = new UITabView();
            ((UITabView)container).CssClass = "div-form";
            //Explicit set the tabview ID
            container.ID = "___customizedAttributeContainer___";
            InsertTabviewToPage(((UITabView)container), tabViewPosition);
            ((UITabView)container).Caption = tabViewCaption;
            ((UITabView)container).Update();
        }

        if (container is UITabView)
            OCustomizedObjectConsumer.BuildCustomizedControls(((UITabView)container), fields);
        else
            OCustomizedObjectConsumer.BuildCustomizedControls(container, fields);
    }

    protected void InsertTabviewToPage(UITabView tab, int? position)
    {
        UITabStrip tabStrip = GetPageTabStrip(Page);
        //Hash table contain the position for each tab. Since the tabstrip control contains more than just tabview
        Hashtable viewIndex = new Hashtable();
        //get number of visible tab views in the tabstrip
        int count = 0;
        for (int i = 0; i < tabStrip.Controls.Count; i++)
        {
            if (tabStrip.Controls[i] is UITabView && tabStrip.Controls[i].Visible)
            {
                count++;
                viewIndex.Add(count, i);
            }
        }
        //if the desired position is higher than number of visible tabview, insert the tabview at the end, else at desired position
        if (position == null || position < 0 || position > count)
            tabStrip.Controls.Add(tab);
        else
        {
            //Get the index of the tabview currently at the tabviewposition
            int tabIndex = Convert.ToInt32(viewIndex[position.Value]);
            tabStrip.Controls.AddAt(tabIndex + 1, tab);
        }
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="c"></param>
    /// <returns></returns>
    protected UITabStrip GetPageTabStrip(Control c)
    {
        if (c.GetType() == typeof(UITabStrip))
            return (UITabStrip)c;
        foreach (Control child in c.Controls)
        {
            UITabStrip o = GetPageTabStrip(child);
            if (o != null)
                return o;
        }
        return null;
    }
    #endregion
    //end Rachel

    /// <summary>
    /// Binds the URL of the document template to the hyperlink.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void listDocumentTemplatesList_ItemDataBound(object sender, DataListItemEventArgs e)
    {
        Label linkGenerateDocument = e.Item.FindControl("linkGenerateDocument") as Label;
        ODocumentTemplate template = e.Item.DataItem as ODocumentTemplate;

        // 2011 04 30
        // Kien Trung
        // commented out since it's no longer needed.
        // Use document temaplate instead.
        //if (template.FileDescription == "PO PDF")
        //{
        //    linkGenerateDocument.Text =
        //        "<a target='document' href='" + Page.Request.ApplicationPath + "/customizedmodulesforcapitaland/purchaseorder/generatePOinPDF.aspx?session="
        //             + GetObjectSessionKey() + "'>" + template.FileDescription + "</a>";
        //}
        //else

        linkGenerateDocument.Text =
            "<div><a target='document' href='" + ResolveUrl("~/components/document.aspx?") +
                "templateID=" + Security.EncryptToHex(template.ObjectID.Value.ToString()) +
                "&t=" + DateTime.Now.ToString("hhmmssfff") +
                "&session=" + GetObjectSessionKey() +
                "&format=" + HttpUtility.UrlEncode(Security.Encrypt("word")) + "'>" + template.FileDescription + "</a></div>";

    }

    /// <summary>
    /// Clone the object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonClone_Click(object sender, EventArgs e)
    {
        ICloneable c = this.SessionObject as ICloneable;

        if (c != null)
        {
            Window.OpenAddObjectPage(this.Page, c.Clone() as PersistentObject, "MESSAGE=" + HttpUtility.UrlEncode(Resources.Messages.Generate_ItemCloned));
        }
    }

    /// <summary>
    /// Display the total approvals given.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridApprovalProcess_RowDataBound(object sender, GridViewRowEventArgs e)
    {

    }

    // 2010.05.16
    // Kim Foong
    // Implementation of the choice to allow skipping or not.
    //
    protected void checkSkipLevels_CheckedChanged(object sender, EventArgs e)
    {
        if (dropApprovalProcess.SelectedValue == "")
            ShowApprovalHierarchy(null);
        else
            ShowApprovalHierarchy(new Guid(dropApprovalProcess.SelectedValue));
    }

    // 2010.10.15
    // Kim Foong
    // A flag that indicates if the workflow separator visibility has already
    // been set once if the datalistWorkflowButtons_ItemDataBound method.
    //
    bool spanWorkflowSeparatorVisibilitySet = false;

    // 2010.10.15
    // Kim Foong
    /// <summary>
    /// Creates the workflow buttons
    /// </summary>
    /// <param name="source"></param>
    /// <param name="e"></param>
    protected void datalistWorkflowButtons_ItemDataBound(object sender, DataListItemEventArgs e)
    {
        System.Data.DataRowView drv = e.Item.DataItem as System.Data.DataRowView;

        UIButton buttonWorkflowAction = e.Item.FindControl("buttonWorkflowAction") as UIButton;
        if (buttonWorkflowAction != null)
        {
            buttonWorkflowAction.CommandArgument = drv["CommandName"].ToString();
            buttonWorkflowAction.CommandName = drv["CommandName"].ToString();
            buttonWorkflowAction.Text = drv["Text"].ToString();
            buttonWorkflowAction.ImageUrl = drv["ImageUrl"].ToString();
            buttonWorkflowAction.CausesValidation = true;
            buttonWorkflowAction.ToolTip = drv["Comment"].ToString();
        }

        if (!spanWorkflowSeparatorVisibilitySet)
        {
            spanWorkflowSeparator.Visible = GetObjectBaseWorkflowActionRadioListActual().IsContainerEnabled() && ShowWorkflowActionAsButtons;
            spanWorkflowSeparatorVisibilitySet = true;
        }
    }

    // 2010.10.15
    // Kim Foong
    /// <summary>
    /// Occurs when the user click the workflow buttons.
    /// </summary>
    /// <param name="source"></param>
    /// <param name="e"></param>
    protected void datalistWorkflowButtons_ItemCommand(object source, DataListCommandEventArgs e)
    {
        buttOnValidateAndSave_Click(source, EventArgs.Empty);
    }

    /// <summary>
    ///
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void modalWorkflowPopup_ButtonClicked(object sender, ButtonClickedEventArgs e)
    {
        //if (!panelWorkflowPopup.IsValid)
        //return;

        if (e.CommandName == "Confirm")
        {
            // Update the current activity's comments and approval
            // hierarchy.
            //
            if (SessionObject is LogicLayerPersistentObject)
            {
                ((LogicLayerPersistentObject)SessionObject).CurrentActivity.TriggeringEventName = GetObjectBaseSelectedAction();
                ((LogicLayerPersistentObject)SessionObject).CurrentActivity.TaskCurrentComments = textTaskCurrentComments.Text;
                if (dropApprovalProcess.Visible)
                {
                    ((LogicLayerPersistentObject)SessionObject).CurrentActivity.ApprovalProcessID = new Guid(dropApprovalProcess.SelectedValue);
                    ((LogicLayerPersistentObject)SessionObject).CurrentActivity.Priority = Convert.ToInt16(dropApprovalImportance.SelectedValue);
                }
            }
            HideWorkflowDialog();

            // Follow up with the button action.
            //
            string clickedButton = (string)textClickedButton.Text;
            if (clickedButton == "buttOnValidateAndSave")
            {
                SaveObjectAndTransit();
            }
            else if (clickedButton == "buttOnValidateAndSaveAndNew")
            {
                if (SaveObjectAndTransit())
                {
                    string queryString = "";
                    foreach (string key in Page.Request.QueryString.Keys)
                        if (key != "TYPE" && key != "ID" && key != "MESSAGE")
                            queryString += (queryString == "" ? "" : "&") + key + "=" + HttpUtility.UrlEncode(Page.Request.QueryString[key]);
                    queryString += (queryString == "" ? "" : "&") + "MESSAGE=" + Resources.Messages.General_ItemSavedAndNew;

                    Window.OpenAddObjectPage(Page, Security.Decrypt(Request["TYPE"]), queryString);
                }
            }
            else if (clickedButton == "buttOnValidateAndSaveAndClose")
            {
                if (SaveObjectAndTransit())
                    Window.Close();
            }
        }

    }

    protected void popupMessage_ButtonClicked(object sender, ButtonClickedEventArgs e)
    {
        labelPopupMessage.Text = "";
    }
</script>

<div style="min-width: 800px">
    <ui:UIPanel runat="server" ID="mainPanel">
        <table border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td class='object-name'>
                    <asp:Label ID="labelCaption" runat="server" meta:resourcekey="labelCaptionResource1"
                        Text="Object Name"></asp:Label>
                </td>
            </tr>
            <tr>
                <td class='object-buttons'>
                    <table cellpadding='0' cellspacing='0' border='0'>
                        <tr>
                            <%--
                            2010.10.15
                            Kim Foong
                            Added the following TD tag to store the workflow buttons.

                            NOTE: The "nowrap" attribute set to all the TDs in this table.
                            (This is to prevent long buttons from causing the entire row to wrap.)
                            (No other solution currently)
                             --%>
                            <td nowrap="true">
                                <span runat='server' id="spanWorkflowButtons" visible="false">
                                    <asp:DataList runat='server' ID='datalistWorkflowButtons' OnItemDataBound="datalistWorkflowButtons_ItemDataBound"
                                        RepeatColumns="0" RepeatLayout="Flow" RepeatDirection="Horizontal" OnItemCommand="datalistWorkflowButtons_ItemCommand">
                                        <ItemTemplate>
                                            <ui:UIButton runat="server" ID="buttonWorkflowAction" Font-Bold="true" />
                                        </ItemTemplate>
                                    </asp:DataList>
                                </span><span runat='server' id='spanWorkflowSeparator' visible="false">
                                    <asp:Image runat="server" ID="imageSeparator" ImageUrl="~/images/workflow_sep.png"
                                        ImageAlign="AbsMiddle" />
                                    &nbsp; &nbsp; </span>
                            </td>
                            <%-- END --%>
                            <td nowrap="true">
                                <ui:UIPanel runat="server" ID="spanSaveButtons">
                                    <ui:UIPanel runat="server" ID="spanSaveButtonsInner">
                                        <ui:UIButton runat="server" ID="buttOnValidateAndSave" ImageUrl="~/images/disk-big.gif"
                                            Text="Save" CausesValidation="true" OnClick="buttOnValidateAndSave_Click" meta:resourcekey="buttOnValidateAndSaveResource1">
                                        </ui:UIButton>
                                        <ui:UIButton runat="server" ID="buttOnValidateAndSaveAndClose" ImageUrl="~/images/disk-big.gif"
                                            CausesValidation="true" Text="Save and Close" OnClick="buttOnValidateAndSaveAndClose_Click"
                                            meta:resourcekey="buttOnValidateAndSaveAndCloseResource1"></ui:UIButton>
                                        <ui:UIButton runat="server" ID="buttOnValidateAndSaveAndNew" ImageUrl="~/images/disksave-big.gif"
                                            CausesValidation="true" Text="Save and New" OnClick="buttOnValidateAndSaveAndNew_Click"
                                            meta:resourcekey="buttOnValidateAndSaveAndNewResource1"></ui:UIButton>
                                    </ui:UIPanel>
                                </ui:UIPanel>
                            </td>
                            <td nowrap="true">
                                <ui:UIPanel runat="server" ID="spanCloneButtons">
                                    <ui:UIButton runat="server" ID="buttonClone" ImageUrl="~/images/clone-big.png" ConfirmText="Please remember to save this item first before cloning it.\n\nAre you sure you wish to continue?"
                                        Text="Clone" CausesValidation='false' OnClick="buttonClone_Click" meta:resourcekey="buttonCloneResource1" />
                                </ui:UIPanel>
                            </td>
                            <td nowrap="true">
                                <ui:UIPanel runat="server" ID="spanDelete">
                                    <ui:UIPanel runat='server' ID="spanDelete2">
                                        <ui:UIButton runat="server" ID="buttonDelete" ImageUrl="~/images/delete-big.png"
                                            CausesValidation="false" Text="Delete Item" OnClick="buttonDelete_Click" ConfirmText="Are you sure you wish to delete this?\n\nPlease note that related items may no longer be accessible if you choose to delete this item."
                                            meta:resourcekey="buttonDeleteResource1"></ui:UIButton>
                                    </ui:UIPanel>
                                </ui:UIPanel>
                            </td>
                            <td nowrap="true">
                                <ui:UIPanel runat="server" ID="panelSpellCheck" Visible='false'>
                                    <asp:Image runat='server' ID="imageSpellCheck" ImageUrl="~/images/spellcheck.png"
                                        ImageAlign="AbsMiddle" />
                                    <asp:HyperLink runat='server' ID="linkSpellCheck" Text="Spell Check" NavigateUrl="javascript:void(0)" />
                                    &nbsp;&nbsp;
                                </ui:UIPanel>
                            </td>
                            <td nowrap="true">
                                <ui:UIButton runat="server" ID="buttonCancel" ImageUrl="~/images/window-delete-big.gif"
                                    AlwaysEnabled="true" Text="Close Window" OnClick="buttonCancel_Click" meta:resourcekey="buttonCancelResource1">
                                </ui:UIButton>
                                <div style="display: none">
                                    <ui:UIButton runat="server" ID="buttonRefresh" ImageUrl="" Text="" OnClick="buttonRefresh_Click"
                                        CausesValidation="false"></ui:UIButton>
                                    <ui:UIButton runat="server" ID="buttonRefreshSession" ImageUrl="" Text="" OnClick="buttonRefreshSession_Click"
                                        CausesValidation="false"></ui:UIButton>
                                </div>
                            </td>
                            <td nowrap="true" style="cursor: pointer">
                                <ui:UIPanel runat="server" ID="panelDocumentTemplates" Visible="false">
                                    <asp:Panel runat="server" ID="panelGeneratePulldown">
                                        <asp:Image runat="server" ID="imageGenerateDocument" ImageUrl='~/images/printer-large.png'
                                            ImageAlign="absmiddle" />
                                        <asp:Image runat="server" ID="imageSubmenu" ImageUrl='~/images/submenu.gif' ImageAlign="absmiddle" />
                                    </asp:Panel>
                                    <asp:Panel runat="server" ID="panelDocumentTemplatesList" Style="display: none; padding: 4px"
                                        Width="200px" CssClass="menu-dropdown">
                                        <div class="menu-dropdown-header" style="height: 16px">
                                            <asp:Label runat="server" ID="labelDocuments" Text="Select document to generate"
                                                Font-Bold="true" meta:resourcekey="labelDocumentsResource1"></asp:Label>
                                        </div>
                                        <asp:DataList runat="server" ID="listDocumentTemplatesList" OnItemDataBound="listDocumentTemplatesList_ItemDataBound"
                                            ItemStyle-Height="16px">
                                            <ItemTemplate>
                                                <asp:Label runat="server" ID="linkGenerateDocument"></asp:Label>
                                            </ItemTemplate>
                                        </asp:DataList>
                                    </asp:Panel>
                                    <asp:PopupControlExtender ID="PopupControlExtender1" runat="server" PopupControlID="panelDocumentTemplatesList"
                                        TargetControlID="panelGeneratePulldown" Position="Bottom">
                                    </asp:PopupControlExtender>
                                </ui:UIPanel>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
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
        <asp:TextBox runat="server" ID="textSubPanelCount" Visible="false"></asp:TextBox>
        <asp:TextBox runat="server" ID="textClickedButton" Visible="false"></asp:TextBox>
        <input id="CurrentObjectInstanceKey" type="hidden" runat="server" value="" />
    </ui:UIPanel>
    <ui:UIDialogBox runat="server" ID="popupMessage" Title="Message" DialogWidth="400px"
        ScrollBars="Auto" Button1AlwaysEnabled="true" Button1AutoClosesDialogBox="true"
        Button1CausesValidation="false" Button1CommandName="Hide" Button1Text="Close"
        OnButtonClicked="popupMessage_ButtonClicked">
        <asp:Label runat='server' ID='labelPopupMessage' Font-Size="9pt" Font-Bold="true"
            ForeColor="Red" meta:resourcekey="labelMessageResource1"></asp:Label>
    </ui:UIDialogBox>
    <ui:UIDialogBox runat="server" ID="modalWorkflowPopup" Title="" DialogWidth="600px"
        Button1AlwaysEnabled="false" Button1ImageUrl="~/images/tick.gif" Button1CausesValidation="true"
        Button1AutoClosesDialogBox="false" Button1FontBold="true" Button1Text="Confirm"
        Button1CommandName="Confirm" Button2AlwaysEnabled="false" Button2ImageUrl="~/images/delete.gif"
        Button2CausesValidation="false" Button2FontBold="true" Button2Text="Cancel" Button2CommandName="Cancel"
        OnButtonClicked="modalWorkflowPopup_ButtonClicked">
        <ui:UIPanel runat="server" ID="panelModalWorkflowPopup" BorderStyle="NotSet">
            <ui:UIFieldLabel runat="server" ID="textConfirmation" ShowCaption="false" HtmlEncoded="false">
            </ui:UIFieldLabel>
            <ui:UIFieldTextBox runat="server" ID="textTaskCurrentComments" Caption="Comments"
                CaptionPosition="Top" Font-Size="Small" MaxLength="1000" TextMode="MultiLine"
                Rows="3" ToolTip="Enter your comment here." meta:resourcekey="textTaskCurrentCommentsResource1">
            </ui:UIFieldTextBox>
        </ui:UIPanel>
        <ui:UIPanel runat="server" ID="panelApprovalProcess">
            <ui:UIFieldDropDownList runat="server" ID="dropApprovalImportance" Caption="Importance"
                ToolTip="Set importance of this WJ to indicate urgency of your task." Span="Half"
                InternalControlWidth="100px" PropertyName="" ValidateRequiredField="true">
                <Items>
                    <asp:ListItem Text="Low" Value="0"></asp:ListItem>
                    <asp:ListItem Text="Normal" Value="1" Selected="True"></asp:ListItem>
                    <asp:ListItem Text="High (Urgent)" Value="3"></asp:ListItem>
                </Items>
            </ui:UIFieldDropDownList>
            <ui:UIFieldDropDownList runat="server" ID="dropApprovalProcess" Caption="Approval Process"
                ValidateRequiredField="true" OnSelectedIndexChanged="dropApprovalProcess_SelectedIndexChanged">
            </ui:UIFieldDropDownList>
            <ui:UIFieldLabel runat="server" ID="labelModeOfForwarding" Caption="Mode of Forwarding">
            </ui:UIFieldLabel>
            <ui:UIFieldCheckBox runat="server" ID="checkSkipLevels" Caption="Skip Levels?" ForeColor="Red"
                Font-Size="8pt" Text="Yes, skip to the last level that rejected this task." Checked='true'
                OnCheckedChanged="checkSkipLevels_CheckedChanged">
            </ui:UIFieldCheckBox>
            <ui:UIFieldCheckBox runat="server" ID="checkSkipNextLevels" Caption="Skip Next Required Levels?"
                ForeColor="Blue" Font-Size="8pt" Text="Yes, skip to the next level if the you are an approver in the process."
                Checked='false'>
            </ui:UIFieldCheckBox>
            <asp:Label runat="server" ID="labelApprovalNotRequired" Text="No approval is required for this process."></asp:Label>
            <asp:Label runat="server" ID="labelApproved" Text="You are the authorized approver."
                ForeColor="DarkGreen" Font-Bold="true" Font-Size="9pt"></asp:Label>
            <asp:Label runat="server" ID="labelNoAuthorizedApproved" Text="You are not the authorized to submit the task."
                ForeColor="Red" Font-Bold="true" Font-Size="9pt"></asp:Label>
            <asp:Label runat="server" ID="labelNoApproversFound" Text="There are no approvers authorized to approve this process."
                ForeColor="red" Font-Bold="true" Font-Size="9pt"></asp:Label>
            <asp:Label runat="server" ID="labelRequiredApproved" Text="You have already approved the task at this level."
                ForeColor="DarkGreen" Font-Bold="true" Font-Size="9pt"></asp:Label>
            <ui:UIGridView runat="server" ID="gridApprovalProcess" Caption="Approver Hierarchy"
                ShowCaption="false" SortExpression="FinalApprovalLimit ASC" CheckBoxColumnVisible="false"
                OnRowDataBound="gridApprovalProcess_RowDataBound">
                <Columns>
                    <ui:UIGridViewBoundColumn HeaderText="Approval Level" PropertyName="ApprovalLevel">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn HeaderText="Approval Limit" PropertyName="FinalApprovalLimit"
                        DataFormatString="{0:#,##0.00}">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn HeaderText="Users" PropertyName="UsersToBeAssignedNames">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn HeaderText="Positions" PropertyName="PositionNamesWithUserNames">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn HeaderText="Roles" PropertyName="RoleNames">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn HeaderText="Approvals Required" PropertyName="NumberOfApprovalsRequired">
                    </ui:UIGridViewBoundColumn>
                </Columns>
            </ui:UIGridView>
        </ui:UIPanel>
    </ui:UIDialogBox>
    <%# Eval("FileDescription") %>
</div>