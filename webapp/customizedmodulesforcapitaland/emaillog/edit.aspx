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
        OEmailLog obj = panel.SessionObject as OEmailLog;
        panel.ObjectPanel.BindObjectToControls(obj);
    }

    /// <summary>
    /// Validates and saves the equipment object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        
    }

    /// <summary>
    /// Constructs and returns the equipment tree.
    /// </summary>
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Email" BaseTable="tEmailLog"
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Details" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" ObjectNameTooltip="The equipment name as displayed on screen."
                            meta:resourcekey="objectBaseResource1"></web:base>
                        <ui:UIFieldLabel runat="server" ID="labelEmailSubject" PropertyName="Subject" Caption="Subject" Font-Bold="true" ForeColor="GradientActiveCaption" ></ui:UIFieldLabel>
                        <br />
                        <br />
                        <ui:UIFieldLabel runat="server" ID="labelEmailBody" PropertyName="EmailBody" Caption="Email Body" ForeColor="GradientActiveCaption"></ui:UIFieldLabel>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>

