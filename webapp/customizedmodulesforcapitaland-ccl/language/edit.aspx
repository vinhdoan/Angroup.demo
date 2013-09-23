<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">

/// <summary>
/// Populates the form.
/// </summary>
/// <param name="sender"></param>
/// <param name="e"></param>
protected void panel_PopulateForm(object sender, EventArgs e)
{
    OLanguage language = panel.SessionObject as OLanguage;
    panel.ObjectPanel.BindObjectToControls(language);
}


/// <summary>
/// Validates and saves the language object into the database.
/// </summary>
/// <param name="sender"></param>
/// <param name="e"></param>
protected void panel_ValidateAndSave(object sender, EventArgs e)
{
    using (Connection c = new Connection())
    {
        OLanguage language = panel.SessionObject as OLanguage;
        panel.ObjectPanel.BindControlsToObject(language);

        language.Save();
        c.Commit();
    }
}
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="serveR" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Language" BaseTable="tLanguage" OnPopulateForm="panel_PopulateForm"
                meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave"></web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" 
                    meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Details" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" ObjectNameCaption="Language Name"
                            meta:resourcekey="objectBaseResource1"></web:base>
                        <ui:UIFieldTextBox ID="UIFieldTextBox1" runat="server" PropertyName="CultureCode" Caption="Culture Code"
                            ValidateRequiredField="True" InternalControlWidth="95%" 
                            meta:resourcekey="UIFieldTextBoxResource1" />
                        <ui:UIFieldTextBox ID="DisplayOrder" runat="server" PropertyName="DisplayOrder" 
                            Caption="Display Order" ValidateRangeField="True" ValidateRequiredField="True" 
                            ValidationRangeMin="1" ValidationRangeType="Integer" 
                            InternalControlWidth="95%" meta:resourcekey="DisplayOrderResource1" />
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo"  
                        meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                        <web:memo ID="Memo1" runat="server"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Attachments" 
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
