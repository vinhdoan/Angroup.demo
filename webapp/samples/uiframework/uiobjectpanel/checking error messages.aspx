<%@ Page Language="C#" Inherits="PageBase" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    protected void button_Click(object sender, EventArgs e)
    {
        if (objectpanel.IsValid)
        {
            labelMessage.Text = "Validation succeeded";
        }
        else
        {
            labelMessage.Text = "Validation failed: " + objectpanel.CheckErrorMessages();
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="objectpanel">
            <ui:UIFieldTextBox runat="server" ID="text1" Caption="Textbox 1" 
                ValidateRequiredField="true"></ui:UIFieldTextBox>
            <ui:UIFieldTextBox runat="server" ID="text2" Caption="Textbox 2" 
                ValidateRequiredField="true"></ui:UIFieldTextBox>
            <ui:UIFieldTextBox runat="server" ID="text3" Caption="Textbox 3" 
                ValidateRequiredField="true"></ui:UIFieldTextBox>
            <br />
            <br />
            <asp:Label runat="server" ID="labelMessage"></asp:Label>
            <br />
            <br />
            <ui:UIButton runat="server" ID="button" ImageUrl="~/images/tick.gif" 
                Text="Validate" OnClick="button_Click" />
        </ui:UIObjectPanel>
    </form>
</body>
</html>
