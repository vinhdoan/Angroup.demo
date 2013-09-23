<%@ Page Language="C#" Inherits="PageBase" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        ((UIPageBase)this.Page).ScriptManager.RegisterPostBackControl(UploadButton);

    }
    
    protected void UploadButton_Click(object sender, EventArgs e)
    {
        if (FileUploadControl.PostedFile == null)
            StatusLabel.Text = "No file";
        else
            StatusLabel.Text = "File uploaded, file size = " + FileUploadControl.PostedFile.ContentLength;
        UploadDialogBox.Visible = false;
    }


    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
    }

    protected void ShowUploadButton_Click(object sender, EventArgs e)
    {
        UploadDialogBox.Visible = true;
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <ui:UIPanel runat='server' id="UploadPanel">
            <asp:Button runat="server" ID="ShowUploadButton" Text="Show Upload Dialog Box" OnClick="ShowUploadButton_Click" />
            <asp:Label runat="server" ID="StatusLabel"></asp:Label>
            
            <asp:Panel runat='server' ID="UploadDialogBox" Visible="false">
                <asp:Button runat="server" ID="UploadButton" OnClick="UploadButton_Click" Text="Upload" />
                <ui:uifieldinputfile runat='server' ID="FileUploadControl" />
                <div style='clear:both'></div>
            </asp:Panel>
        </ui:UIPanel>
    </div>
    </form>
</body>
</html>
