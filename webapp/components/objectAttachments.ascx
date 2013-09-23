<%@ Control Language="C#" ClassName="objectAttachments" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.ComponentModel" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Src="objectPanel.ascx" TagPrefix="web2" TagName="object" %>
<%@ Register Src="fileUploadDialogBox.ascx" TagName="fileUploadDialogBox" TagPrefix="web2" %>

<script runat="server">
    /// <summary>
    /// Gets or sets the document code type of the document that
    /// is to be uploaded.
    /// </summary>
    [Localizable(false), Browsable(true)]
    public string DocumentCodeType
    {
        get
        {
            //default to "DocumentType"
            if (ViewState["DocumentCodeType"] != null)
                return ViewState["DocumentCodeType"].ToString();
            else
                return "DocumentType";
        }
        set
        {
            //Default to DocumentType if not specified
            if (value == "" || value.Trim() == "")
                ViewState["DocumentCodeType"] = "DocumentType";
            else
                ViewState["DocumentCodeType"] = value;
        }
    }


    /// <summary>
    /// Initializes the control.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        // Register the buttonUpload button to force a full
        // postback whenever a file is uploaded.
        //
    }


    /// <summary>
    /// Loads a list of document types from the OCode table.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!IsPostBack)
        {
            LogicLayerPersistentObject o = getPersistentObject(Page) as LogicLayerPersistentObject;
            BindAttachments(o);
        }
    }



    // 2011.06.22, Kien Trung
    // NEW: Gets or set ValidateRequiredField of gridview.
    //
    public bool ValidateRequiredField
    {
        get { return gridDocument.ValidateRequiredField; }
        set { gridDocument.ValidateRequiredField = value; }
    }

    // 2010.12.22
    // Kim Foong
    public string ErrorMessage
    {
        get { return gridDocument.ErrorMessage; }
        set { gridDocument.ErrorMessage = value; }
    }


    /// <summary>
    /// Binds attachments to the gridview and 
    /// updates the tab view caption to reflect
    /// the number of attachments.
    /// </summary>
    /// <param name="o"></param>
    protected void BindAttachments(LogicLayerPersistentObject o)
    {
        if (o != null)
        {
            gridDocument.DataSource = o.Attachments;
            gridDocument.DataBind();

            Control currentControl = this;
            while (currentControl != null)
            {
                if (currentControl is UITabView)
                {
                    string text = ((UITabView)currentControl).Caption;
                    int index = text.IndexOf(" (");
                    if (index >= 0)
                        text = text.Substring(0, index);

                    objectPanel panel = getPanel(Page);
                    if (panel.SessionObject is LogicLayerPersistentObject)
                        ((UITabView)currentControl).Caption = text + " (" +
                            ((LogicLayerPersistentObject)panel.SessionObject).Attachments.Count + ")";
                }
                currentControl = currentControl.Parent;
            }
        }
    }


    /// <summary>
    /// Occurs when the user clicks on a button in the UIGridView.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="objectIds"></param>
    protected void gridDocument_Action(object sender, string commandName, System.Collections.Generic.List<object> objectIds)
    {
        if (commandName == "UploadDocument")
        {
            fileUploadDialog.FileUploadMultiple = true;
            fileUploadDialog.NumberOfFileUploads = 10;
            fileUploadDialog.Show();
        }
        if (commandName == "ViewDocument")
        {
            // View the document, so load it from
            // database and let user download it.
            //
            using (Connection c = new Connection())
            {
                foreach (Guid objectId in objectIds)
                {
                    string contentType = "";
                    string fileName = "";
                    LogicLayerPersistentObject o = getPersistentObject(Page) as LogicLayerPersistentObject;
                    if (o != null)
                        foreach (OAttachment b in o.Attachments)
                            if (b.ObjectID.Value == objectId)
                            {
                                getPanel(Page).FocusWindow = false;
                                Window.Download(b.FileBytes, b.Filename, b.ContentType);
                                break;
                            }
                }
            }
        }
        if (commandName == "DeleteDocument")
        {
            // remove the document from the database.
            //
            LogicLayerPersistentObject o = getPersistentObject(Page);
            if (o != null)
            {
                foreach (Guid objectId in objectIds)
                    o.Attachments.RemoveGuid(objectId);

                BindAttachments(o);
            }

            if (Page is UIPageBase)
                ((UIPageBase)Page).SetModifiedFlag();
        }
    }


    /// <summary>
    /// Finds and returns the objectPanel.ascx control.
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


    // hunts for the objectPanel.ascx control and finds the PersistentObject
    // the OAttachment object to the attached object
    //
    /// <summary>
    /// Finds the objectPanel.ascx control, then returns the CurrentObject
    /// stored in that control.
    /// </summary>
    /// <param name="c"></param>
    /// <returns></returns>
    protected LogicLayerPersistentObject getPersistentObject(Control c)
    {
        if (c.GetType() == typeof(objectPanel))
        {
            //return (LogicLayerPersistentObject)((objectPanel)c).CurrentObject;
            return ((objectPanel)c).SessionObject as LogicLayerPersistentObject;
        }
        foreach (Control child in c.Controls)
        {
            LogicLayerPersistentObject o = getPersistentObject(child);
            if (o != null)
                return o;
        }
        return null;
    }

    /*
    /// <summary>
    /// Uploads the document.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonUpload_Click(object sender, EventArgs e)
    {
        List<HttpPostedFile> postedFiles = new List<HttpPostedFile>();

        if (FileUpload01.Control.PostedFile != null)
            postedFiles.Add(FileUpload01.Control.PostedFile);
        if (FileUpload02.Control.PostedFile != null)
            postedFiles.Add(FileUpload02.Control.PostedFile);
        if (FileUpload03.Control.PostedFile != null)
            postedFiles.Add(FileUpload03.Control.PostedFile);
        if (FileUpload04.Control.PostedFile != null)
            postedFiles.Add(FileUpload04.Control.PostedFile);
        if (FileUpload05.Control.PostedFile != null)
            postedFiles.Add(FileUpload05.Control.PostedFile);
        if (FileUpload06.Control.PostedFile != null)
            postedFiles.Add(FileUpload06.Control.PostedFile);
        if (FileUpload07.Control.PostedFile != null)
            postedFiles.Add(FileUpload07.Control.PostedFile);
        if (FileUpload08.Control.PostedFile != null)
            postedFiles.Add(FileUpload08.Control.PostedFile);
        if (FileUpload09.Control.PostedFile != null)
            postedFiles.Add(FileUpload09.Control.PostedFile);
        if (FileUpload10.Control.PostedFile != null)
            postedFiles.Add(FileUpload10.Control.PostedFile);

        if (postedFiles.Count > 0)
        {
            foreach (HttpPostedFile postedFile in postedFiles)
            {
                if (postedFile != null && postedFile.ContentLength > 0)
                {
                    OAttachment a = TablesLogic.tAttachment.Create();
                    byte[] fileBytes = new byte[postedFile.ContentLength];
                    postedFile.InputStream.Position = 0;
                    postedFile.InputStream.Read(fileBytes, 0, fileBytes.Length);

                    a.FileBytes = fileBytes;
                    a.Filename = Path.GetFileName(postedFile.FileName);
                    a.FileSize = postedFile.ContentLength;
                    a.ContentType = postedFile.ContentType;
                    if (this.dropAttachmentTypeID.SelectedValue != "")
                        a.AttachmentTypeID = new Guid(this.dropAttachmentTypeID.SelectedValue);
                    a.FileDescription = this.documentDescription.Text;

                    objectPanel panel = getPanel(Page);
                    LogicLayerPersistentObject o = panel.SessionObject as LogicLayerPersistentObject;
                    if (o != null)
                    {
                        o.Attachments.Add(a);
                        BindAttachments(o);

                        if (Page is UIPageBase)
                            ((UIPageBase)Page).SetModifiedFlag();
                    }


                    // clear error message when attachment uploaded
                    //
                    if (panel.ObjectPanel.CheckErrorMessages() == null)
                        panel.Message = "";
                }
            }
        }

        //clear other details
        this.dropAttachmentTypeID.SelectedIndex = 0;
        this.documentDescription.Text = "";

    }
    */


    /// <summary>
    /// Hides the input file control if this control is disabled.
    /// Also updates the tabview's caption to show the number
    /// of attachments in this object.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
    }

    protected void gridDocument_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string Attachment = "";

            Attachment = String.Format(Resources.Strings.GeneralDisplayTitleFontColor, e.Row.Cells[5].Text);

            if (e.Row.Cells[4].Text != "&nbsp;" && e.Row.Cells[3].Text != "&nbsp;")
                Attachment += String.Format(Resources.Strings.GeneralDisplayCreatedTimeByUserNameFontColor, Convert.ToDateTime(e.Row.Cells[4].Text).ToFriendlyString(), e.Row.Cells[3].Text);
            else
                Attachment += String.Format(Resources.Strings.GeneralDisplayCreatedTimeByUserNameFontColor, DateTime.Now.AddSeconds(-1).ToFriendlyString(), AppSession.User.ObjectName);

            e.Row.Cells[5].Text = Attachment;
        }

        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[3].Visible = false;
            e.Row.Cells[4].Visible = false;
        }
    }

    protected void fileUploadDialog_Uploaded(object sender, EventArgs e)
    {

        objectPanel panel = getPanel(Page);
        LogicLayerPersistentObject o = panel.SessionObject as LogicLayerPersistentObject;
        
        if (o != null)
        {
            o.Attachments.AddRange(fileUploadDialog.GetAttachmentFiles());
            BindAttachments(o);

            if (Page is UIPageBase)
                ((UIPageBase)Page).SetModifiedFlag();
        }


        // clear error message when attachment uploaded
        //
        if (panel.ObjectPanel.CheckErrorMessages() == null)
            panel.Message = "";

    }
</script>
<web2:fileuploaddialogbox runat="server" ID="fileUploadDialog" Cancelled="false" FileUploadMultiple="true" OnUploaded="fileUploadDialog_Uploaded" />
<ui:UIGridView runat='server' ID="gridDocument" OnAction="gridDocument_Action" Caption="Attachments"
    CaptionWidth="120px" KeyName="ObjectID" meta:resourcekey="gridDocumentResource1"
    OnRowDataBound="gridDocument_RowDataBound">
    <Commands>
        <ui:UIGridViewCommand CommandName="DeleteDocument" CommandText="Delete" ImageUrl="../images/delete.gif"
            ConfirmText="Are you sure you wish to delete the selected documents?" meta:resourcekey="UIGridViewCommandResource1" />
        <ui:UIGridViewCommand CommandName="UploadDocument" CommandText="Upload" ImageUrl="../images/upload.png" />
    </Commands>
    <Columns>
        <ui:UIGridViewButtonColumn ImageUrl="../images/view.gif" CommandName="ViewDocument"
            HeaderText="" meta:resourcekey="UIGridViewColumnResource1" AlwaysEnabled="true">
        </ui:UIGridViewButtonColumn>
        <ui:UIGridViewButtonColumn ImageUrl="../images/delete.gif" CommandName="DeleteDocument"
            HeaderText="" ConfirmText="Are you sure you wish to delete this document?" meta:resourcekey="UIGridViewColumnResource2">
        </ui:UIGridViewButtonColumn>
        <ui:UIGridViewBoundColumn PropertyName="CreatedUser" HeaderText="Created User">
        </ui:UIGridViewBoundColumn>
        <ui:UIGridViewBoundColumn PropertyName="CreatedDateTime" HeaderText="Created Date Time">
        </ui:UIGridViewBoundColumn>
        <ui:UIGridViewBoundColumn PropertyName="Filename" HeaderText="File Name" meta:resourcekey="UIGridViewColumnResource3">
        </ui:UIGridViewBoundColumn>
        <ui:UIGridViewBoundColumn PropertyName="FileSize" HeaderText="File Size (bytes)"
            DataFormatString="{0:#,##0}" meta:resourcekey="UIGridViewColumnResource4">
        </ui:UIGridViewBoundColumn>
        <ui:UIGridViewBoundColumn PropertyName="FileDescription" HeaderText="File Description">
        </ui:UIGridViewBoundColumn>
    </Columns>
</ui:UIGridView>
