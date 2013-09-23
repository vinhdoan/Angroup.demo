<%@ Page Language="C#" Inherits="PageBase" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    protected void button_Click(object sender, EventArgs e)
    {
        // Perform custom validation.
        //
        if (drop.SelectedValue == "0" && textbox.Text != "ABC")
        {
            textbox.ErrorMessage = "You must enter ABC";
        }
        else if (drop.SelectedValue == "1" && textbox.Text == "DEF")
        {
            textbox.ErrorMessage = "You must not enter DEF";
        }

        // Test if our custom validation succeeded.
        //
        if (objectpanel.IsValid)
        {
            labelMessage.Text = "Validation succeeded.";
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
            <ui:UIFieldDropDownList runat="server" ID="drop" 
                Caption="Dropdownlist">
                <Items>
                    <asp:ListItem Value="0">You must enter 
                        ABC in the text box</asp:ListItem>
                    <asp:ListItem Value="1">You must NOT enter 
                        DEF in the text box</asp:ListItem>
                </Items>
            </ui:UIFieldDropDownList>
            <ui:UIFieldTextBox runat="server" ID="textbox" 
                Caption="Textbox" ValidateRequiredField="true">
            </ui:UIFieldTextBox>
            <br />
            <br />
            <asp:Label runat="server" ID="labelMessage">
            </asp:Label>
            <br />
            <br />
            <ui:UIButton runat="server" ID="button"
                ImageUrl="~/images/tick.gif"
                Text="Validate" OnClick="button_Click" />
        </ui:UIObjectPanel>
    </form>
</body>
</html>
