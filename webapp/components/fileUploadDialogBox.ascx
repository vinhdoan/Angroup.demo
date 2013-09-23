<%@ Control Language="C#" ClassName="fileuploaddialogbox" %>
<%@ Import Namespace="System.ComponentModel" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    
    private bool cancelled = true;

    /// <summary>
    /// Gets or sets the title of the dialog box.
    /// </summary>
    public bool Cancelled
    {
        get { return cancelled; }
        set { cancelled = value; }
    }

    [DefaultValue(true)]
    public bool FileUploadMultiple
    {
        get { return buttonAttachMore.Visible; }
        set
        {
            buttonAttachMore.Visible =
                hintFileUpload.Visible = value;
        }

    }

    public string FileUploadDescription
    {
        get { return ""; }
        set { }
    }

    /// <summary>
    /// Gets or sets the title of the dialog box.
    /// </summary>
    public string Title
    {
        get { return FileUploadDialogBox.Title; }
        set { FileUploadDialogBox.Title = value; }
    }


    /// <summary>
    /// Gets or sets the maximum number of files that can be uploaded in one go.
    /// (This file upload control only allows up to 10 files)
    /// </summary>
    [DefaultValue(2)]
    public int NumberOfFileUploads
    {
        get
        {
            if (FileUpload10.Visible) return 10;
            if (FileUpload09.Visible) return 9;
            if (FileUpload08.Visible) return 8;
            if (FileUpload07.Visible) return 7;
            if (FileUpload06.Visible) return 6;
            if (FileUpload05.Visible) return 5;
            if (FileUpload04.Visible) return 4;
            if (FileUpload03.Visible) return 3;
            if (FileUpload02.Visible) return 2;
            if (FileUpload01.Visible) return 1;
            return 0;
        }
        set
        {
            FileUpload01.Visible = FileDescription01.Visible = value >= 1;
            FileUpload02.Visible = FileDescription02.Visible = value >= 2;
            FileUpload03.Visible = FileDescription03.Visible = value >= 3;
            FileUpload04.Visible = FileDescription04.Visible = value >= 4;
            FileUpload05.Visible = FileDescription05.Visible = value >= 5;
            FileUpload06.Visible = FileDescription06.Visible = value >= 6;
            FileUpload07.Visible = FileDescription07.Visible = value >= 7;
            FileUpload08.Visible = FileDescription08.Visible = value >= 8;
            FileUpload09.Visible = FileDescription09.Visible = value >= 9;
            FileUpload10.Visible = FileDescription10.Visible = value >= 10;
        }
    }


    /// <summary>
    /// This event is fired when files are successfully uploaded. 
    /// </summary>
    public event EventHandler Uploaded;


    /// <summary>
    /// Gets the list of files uploaded by the user. If the dialog box has been cancelled
    /// by the user, then this method returns null.
    /// </summary>
    /// <returns></returns>
    public List<HttpPostedFile> GetUploadFiles()
    {
        if (cancelled)
            return null;

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


        return postedFiles;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    public List<OAttachment> GetAttachmentFiles()
    {
        List<OAttachment> attachments = new List<OAttachment>();

        if (FileUpload01.Control.PostedFile != null && FileUpload01.Control.PostedFile.ContentLength > 0)
            attachments.Add(GenerateUploadedAttachment(FileUpload01.Control.PostedFile, FileDescription01.Text.Trim()));
        if (FileUpload02.Control.PostedFile != null && FileUpload02.Control.PostedFile.ContentLength > 0)
            attachments.Add(GenerateUploadedAttachment(FileUpload02.Control.PostedFile, FileDescription02.Text.Trim()));
        if (FileUpload03.Control.PostedFile != null && FileUpload03.Control.PostedFile.ContentLength > 0)
            attachments.Add(GenerateUploadedAttachment(FileUpload03.Control.PostedFile, FileDescription03.Text.Trim()));
        if (FileUpload04.Control.PostedFile != null && FileUpload04.Control.PostedFile.ContentLength > 0)
            attachments.Add(GenerateUploadedAttachment(FileUpload04.Control.PostedFile, FileDescription04.Text.Trim()));
        if (FileUpload05.Control.PostedFile != null && FileUpload05.Control.PostedFile.ContentLength > 0)
            attachments.Add(GenerateUploadedAttachment(FileUpload05.Control.PostedFile, FileDescription05.Text.Trim()));
        if (FileUpload06.Control.PostedFile != null && FileUpload06.Control.PostedFile.ContentLength > 0)
            attachments.Add(GenerateUploadedAttachment(FileUpload06.Control.PostedFile, FileDescription06.Text.Trim()));
        if (FileUpload07.Control.PostedFile != null && FileUpload07.Control.PostedFile.ContentLength > 0)
            attachments.Add(GenerateUploadedAttachment(FileUpload07.Control.PostedFile, FileDescription07.Text.Trim()));
        if (FileUpload08.Control.PostedFile != null && FileUpload08.Control.PostedFile.ContentLength > 0)
            attachments.Add(GenerateUploadedAttachment(FileUpload08.Control.PostedFile, FileDescription08.Text.Trim()));
        if (FileUpload09.Control.PostedFile != null && FileUpload09.Control.PostedFile.ContentLength > 0)
            attachments.Add(GenerateUploadedAttachment(FileUpload09.Control.PostedFile, FileDescription09.Text.Trim()));
        if (FileUpload10.Control.PostedFile != null && FileUpload10.Control.PostedFile.ContentLength > 0)
            attachments.Add(GenerateUploadedAttachment(FileUpload10.Control.PostedFile, FileDescription10.Text.Trim()));

        return attachments;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="postedFile"></param>
    /// <param name="description"></param>
    /// <returns></returns>
    protected OAttachment GenerateUploadedAttachment(HttpPostedFile postedFile, string description)
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
            a.FileDescription = description;

            return a;
        }

        return null;
    }

    /// <summary>
    /// Occurs when the page is loaded.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        ((UIPageBase)Page).ScriptManager.RegisterPostBackControl(FileUploadDialogBox.Button1);

    }


    /// <summary>
    /// Shows the dialog.
    /// </summary>
    public void Show()
    {
        this.FileUploadDescription = "";
        FileUploadDialogBox.Show();
    }


    /// <summary>
    /// Occurs when the user clicks on any of the buttons.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void FileUploadDialogBox_ButtonClicked(object sender, ButtonClickedEventArgs e)
    {
        FileUploadDialogBox.Hide();

        if (e.CommandName == "Upload")
        {
            cancelled = false;
            if (Uploaded != null)
                Uploaded(this, EventArgs.Empty);
        }
        else
        {
            cancelled = true;
        }
    }

    protected void buttonAttachMore_Click(object sender, EventArgs e)
    {
        this.NumberOfFileUploads++;
    }
</script>

<ui:UIDialogBox runat="server" ID="FileUploadDialogBox" Title="Attach File(s)" Button1Text="Upload"
    Button1CommandName="Upload" Button1ImageUrl="~/images/upload.png" Button1FontBold="true"
    DialogWidth="600px" Button2Text="Cancel" Button2CommandName="Cancel" Button2ImageUrl="~/images/delete.gif"
    OnButtonClicked="FileUploadDialogBox_ButtonClicked">
    <ui:UIPanel runat="server" ID="panelUpload" BorderStyle="NotSet">
        <ui:UIHint runat="server" ID="hintFileUpload" Text="Click 'Browse' to select a file. You can attach files up to a total size of 25 MB"></ui:UIHint>
        <table runat="server" id="UploadAttachmentTable" border='0' cellpadding='2' cellspacing='0'
            style="table-layout: fixed;" class='grid'>
            <tr class='grid-header'>
                <th style="width: 50%">
                    <asp:Label runat="server" ID="InputFileLabel" Text="File to Upload"></asp:Label>
                </th>
                <th style="width: 50%">
                    <asp:Label runat="server" ID="AttachmentDescription" Text="Description"></asp:Label>
                </th>
            </tr>
            <tr class='grid-row'>
                <td>
                    <ui:UIFieldInputFile runat="server" ID="FileUpload01" Caption="File 1" ShowCaption="false">
                    </ui:UIFieldInputFile>
                </td>
                <td>
                    <ui:UIFieldTextBox runat="server" ID="FileDescription01" Caption="" ShowCaption="false"
                        ToolTip="Say something about attachment(s)">
                    </ui:UIFieldTextBox>
                </td>
            </tr>
            <tr class='grid-row'>
                <td>
                    <ui:UIFieldInputFile runat="server" ID="FileUpload02" Caption="File 2" CaptionWidth="50px"
                        ShowCaption="false">
                    </ui:UIFieldInputFile>
                </td>
                <td>
                    <ui:UIFieldTextBox runat="server" ID="FileDescription02" Caption="" ShowCaption="false"
                        ToolTip="Say something about attachment(s)">
                    </ui:UIFieldTextBox>
                </td>
            </tr>
            <tr class='grid-row'>
                <td>
                    <ui:UIFieldInputFile runat="server" ID="FileUpload03" Caption="File 3" CaptionWidth="50px"
                        ShowCaption="false" Visible="false">
                    </ui:UIFieldInputFile>
                </td>
                <td>
                    <ui:UIFieldTextBox runat="server" ID="FileDescription03" Caption="" ShowCaption="false"
                        ToolTip="Say something about attachment(s)" Visible="false">
                    </ui:UIFieldTextBox>
                </td>
            </tr>
            <tr class='grid-row'>
                <td>
                    <ui:UIFieldInputFile runat="server" ID="FileUpload04" Caption="File 4" CaptionWidth="50px"
                        ShowCaption="false" Visible="false">
                    </ui:UIFieldInputFile>
                </td>
                <td>
                    <ui:UIFieldTextBox runat="server" ID="FileDescription04" Caption="" ShowCaption="false"
                        ToolTip="Say something about attachment(s)" Visible="false">
                    </ui:UIFieldTextBox>
                </td>
            </tr>
            <tr class='grid-row'>
                <td>
                    <ui:UIFieldInputFile runat="server" ID="FileUpload05" Caption="File 5" CaptionWidth="50px"
                        ShowCaption="false" Visible="false">
                    </ui:UIFieldInputFile>
                </td>
                <td>
                    <ui:UIFieldTextBox runat="server" ID="FileDescription05" Caption="" ShowCaption="false"
                        ToolTip="Say something about attachment(s)" Visible="false">
                    </ui:UIFieldTextBox>
                </td>
            </tr>
            <tr class='grid-row'>
                <td>
                    <ui:UIFieldInputFile runat="server" ID="FileUpload06" Caption="File 6" CaptionWidth="50px"
                        ShowCaption="false" Visible="false">
                    </ui:UIFieldInputFile>
                </td>
                <td>
                    <ui:UIFieldTextBox runat="server" ID="FileDescription06" Caption="" ShowCaption="false"
                        ToolTip="Say something about attachment(s)" Visible="false">
                    </ui:UIFieldTextBox>
                </td>
            </tr>
            <tr class='grid-row'>
                <td>
                    <ui:UIFieldInputFile runat="server" ID="FileUpload07" Caption="File 7" CaptionWidth="50px"
                        ShowCaption="false" Visible="false">
                    </ui:UIFieldInputFile>
                </td>
                <td>
                    <ui:UIFieldTextBox runat="server" ID="FileDescription07" Caption="" ShowCaption="false"
                        ToolTip="Say something about attachment(s)" Visible="false">
                    </ui:UIFieldTextBox>
                </td>
            </tr>
            <tr class='grid-row'>
                <td>
                    <ui:UIFieldInputFile runat="server" ID="FileUpload08" Caption="File 8" CaptionWidth="50px"
                        ShowCaption="false" Visible="false">
                    </ui:UIFieldInputFile>
                </td>
                <td>
                    <ui:UIFieldTextBox runat="server" ID="FileDescription08" Caption="" ShowCaption="false"
                        ToolTip="Say something about attachment(s)" Visible="false">
                    </ui:UIFieldTextBox>
                </td>
            </tr>
            <tr class='grid-row'>
                <td>
                    <ui:UIFieldInputFile runat="server" ID="FileUpload09" Caption="File 9" CaptionWidth="50px"
                        ShowCaption="false" Visible="false">
                    </ui:UIFieldInputFile>
                </td>
                <td>
                    <ui:UIFieldTextBox runat="server" ID="FileDescription09" Caption="" ShowCaption="false"
                        ToolTip="Say something about attachment(s)" Visible="false">
                    </ui:UIFieldTextBox>
                </td>
            </tr>
            <tr class='grid-row'>
                <td>
                    <ui:UIFieldInputFile runat="server" ID="FileUpload10" Caption="File 10" CaptionWidth="50px"
                        ShowCaption="false" Visible="false">
                    </ui:UIFieldInputFile>
                </td>
                <td>
                    <ui:UIFieldTextBox runat="server" ID="FileDescription10" Caption="" ShowCaption="false"
                        ToolTip="Say something about attachment(s)" Visible="false">
                    </ui:UIFieldTextBox>
                </td>
            </tr>
        </table>
        <br />
        <ui:UIButton runat="server" ID="buttonAttachMore" Text="Attach More Files" OnClick="buttonAttachMore_Click" />
    </ui:UIPanel>
</ui:UIDialogBox>
