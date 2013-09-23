<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OReportTemplate template = (OReportTemplate)panel.SessionObject;

        panel.ObjectPanel.BindObjectToControls(template);
    }


    /// <summary>
    /// Validates and saves the report template object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OReportTemplate template = (OReportTemplate)panel.SessionObject;

            // 2010.11.23
            // Li Shan
            // Added the following line.
            panel.ObjectPanel.BindControlsToObject(template);
            
            if (template.IsNew)
                template.CreatorID = AppSession.User.ObjectID;

            template.Save();
            c.Commit();
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain">
        <web:object runat="server" ID="panel" Caption="Report Template" BaseTable="tReportTemplate" EditButtonVisible="false"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                <ui:UITabView runat="server" ID="uitabview1" Caption="Details" meta:resourcekey="uitabview1Resource1">
                    <web:base runat="server" ID="objectBase" ObjectNumberVisible="false"></web:base>
                    <ui:UIFieldTextBox runat="server" ID="TemplateDescription" PropertyName="Description"
                        Caption="Description" Rows="2" TextMode="MultiLine" ToolTip="Description of the report template"
                        meta:resourcekey="TemplateDescriptionResource1">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldRadioList runat="server" PropertyName="AccessControl" ID="AccessControl"
                        Caption="Access Control" ToolTip="Set whether the template could be edited by other users or just by the template creator"
                        meta:resourcekey="AccessControlResource1">
                        <Items>
                            <asp:ListItem Value="1" Selected="True" meta:resourcekey="ListItemResource1">Editable by all users</asp:ListItem>
                            <asp:ListItem Value="2" meta:resourcekey="ListItemResource2">Editable by me and viewable by all users</asp:ListItem>
                            <asp:ListItem Value="3" meta:resourcekey="ListItemResource3">Editable and viewable by me only</asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>

