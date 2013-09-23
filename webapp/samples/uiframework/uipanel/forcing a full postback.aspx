<%@ Page Language="C#" Inherits="PageBase" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        
        // Tells the ASP.NET AJAX engine to do
        // a full postback for the 
        // buttonWithFullPostback button is clicked.
        //
        this.ScriptManager.RegisterPostBackControl(buttonWithFullPostback);
    }

    protected void buttonWithAJAXPostback_Click(object sender, 
        EventArgs e)
    {
        label.Text = "AJAX Postback: " + DateTime.Now.ToString();
    }

    protected void buttonWithFullPostback_Click(object sender, 
        EventArgs e)
    {
        label.Text = "Full Postback: " + DateTime.Now.ToString();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <ui:UIPanel runat="server" ID="panel1">
            <asp:Label runat="server" ID="label"></asp:Label>
            <br />
            <br />
            <ui:UIButton runat="server" ID="buttonWithFullPostback" 
                ImageUrl="~/images/tick.gif" Text="Full Postback" 
                OnClick="buttonWithFullPostback_Click" />
            <br />
            <br />
            <ui:UIButton runat="server" ID="buttonWithAJAXPostback" 
                ImageUrl="~/images/tick.gif" Text="AJAX Postback" 
                OnClick="buttonWithAJAXPostback_Click" />
        </ui:UIPanel>
    </div>
    </form>
</body>
</html>
