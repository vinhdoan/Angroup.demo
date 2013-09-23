<%@ Page Language="C#" Inherits="PageBase" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    /// <summary>
    /// It is important the register the controls that performs
    /// the file upload in the OnLoad event.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        this.ScriptManager.RegisterPostBackControl(buttonUpload);
    }
    
    /// <summary>
    /// Uploads the file to the server.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonUpload_Click(object sender, EventArgs e)
    {
        labelMessage.Text = "Uploaded File Size: " + fileUpload.PostedFile.ContentLength;
    }

    
    /// <summary>
    /// Update the time using AJAX postback.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAjax_Click(object sender, EventArgs e)
    {
        labelMessage.Text = DateTime.Now.ToString();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <ui:UIPanel runat="server" ID="panel">
            <ui:UIFieldInputFile runat="server" Caption="Select File"
                id="fileUpload"></ui:UIFieldInputFile>
            <ui:UIButton runat="server" ID="buttonAjax" 
                Text="Show Time (AJAX Postback)"
                OnClick="buttonAjax_Click" />
            <ui:UIButton runat="server" ID="buttonUpload" 
                Text="Upload File (Full Postback)"
                OnClick="buttonUpload_Click" />
            <br />
            <br />
            <br />
            <asp:Label runat="server" ID="labelMessage">
            </asp:Label>
        </ui:UIPanel>
    </div>
    </form>
</body>
</html>
