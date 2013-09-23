<%@ Page Language="C#" Inherits="PageBase" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
        <%-- Validation in objectpanel1 occurs independently
             of objectpanel2 and objectpanel3 --%>
        <ui:uiobjectpanel runat="server" ID="objectpanel1" 
            BorderColor="Gray" BorderStyle="Solid" BorderWidth="1px">
            <ui:UIFieldTextBox runat="server" ID="textbox1" 
                Caption="TextBox 1"
                ValidateRequiredField="true">
            </ui:UIFieldTextBox>
            <ui:UIButton runat="server" ID="button1"
                 Text="Button 1" />
        </ui:uiobjectpanel>
        <br />
        <br />
        <%-- Validation in objectpanel2 occurs independently
             of objectpanel1. Like data binding, validation
             in objectpanel2 does not affect the nested
             objectpanel3. --%>
        <ui:uiobjectpanel runat="server" ID="objectpanel2"
            BorderColor="Gray" BorderStyle="Solid" BorderWidth="1px">
            <ui:UIFieldTextBox runat="server" ID="textbox2" 
                Caption="TextBox 2"
                ValidateRequiredField="true">
            </ui:UIFieldTextBox>
            <ui:UIButton runat="server" ID="button2"
                Text="Button 2" />

            <br />        
            <br />
            <%-- Validation in objectpanel3 occurs independently
                 of objectpanel1 and objectpanel2 --%>
            <ui:uiobjectpanel runat="server" ID="objectpanel3"
                BorderColor="Gray" BorderStyle="Solid" BorderWidth="1px">
                <ui:UIFieldTextBox runat="server" ID="textbox3" 
                    Caption="TextBox 3"
                    ValidateRequiredField="true">
                </ui:UIFieldTextBox>
                <ui:UIButton runat="server" ID="button3"
                    Text="Button 3" />
            </ui:uiobjectpanel>
        </ui:uiobjectpanel>
    </form>
</body>
</html>
