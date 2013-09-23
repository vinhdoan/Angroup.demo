<%@ Page Language="C#" Inherits="PageBase" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    // If the Click event of the tab is not implemented,
    // (tabDetails being an example), clicking on
    // the tab does NOT trigger a post-back.
    

    /// <summary>
    /// When the Click event of a tab is implemented,
    /// clicking on the tab causes a post-back that
    /// will fire the Click event.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void tabMemo_Click(object sender, EventArgs e)
    {
        labelMessage.Text = "Memo tab clicked.";
    }


    /// <summary>
    /// When the Click event of a tab is implemented,
    /// clicking on the tab causes a post-back that
    /// will fire the Click event.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void tabAttachment_Click(object sender, EventArgs e)
    {
        labelMessage.Text = "Attachment tab clicked.";
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIPanel runat="server" ID="panel">
        <ui:UITabStrip runat="server" ID="tabstrip">
            <ui:UITabView runat="server" ID="tabDetails" Caption="Details">
                This is the details tab.
            </ui:UITabView>
            <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" 
                OnClick="tabMemo_Click">
                This is the memo tab.
            </ui:UITabView>
            <ui:UITabView runat="server" ID="tabAttachment" Caption="Attachments"
                OnClick="tabAttachment_Click">
                This is the attachment tab.
            </ui:UITabView>
        </ui:UITabStrip>
        
        <br />
        <br />
        <asp:Label runat="server" ID="labelMessage" />
    </ui:UIPanel>
    </form>
</body>
</html>
