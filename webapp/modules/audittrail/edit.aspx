<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" 
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
        // OXXXX obj = (OXXXX)panel.SessionObject;
        //panel.ObjectPanel.BindObjectToControls(obj);
    }
    
    
    /// <summary>
    /// Saves the calendar to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using(Connection c = new Connection())
        {
            // OXXXX obj = (OXXXX)panel.SessionObject;
            //panel.ObjectPanel.BindControlsToObject(obj);

            // Validate
            //
            // if(!obj.ValidationSomething)
            //    someControl.ErrorMessage = "Please enter a valid value.";
            //
            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            //obj.Save();
            c.Commit();
        }
    }




</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:object runat="server" ID="panel" Caption="XXXX" BaseTable="tXXXX" meta:resourcekey="panelResource1"
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" >
                    <ui:UITabView ID="tabDetails" runat="server"  Caption="Details">
                        <web:base ID="objectBase" runat="server" ObjectNameCaption="XXXX Name" meta:resourcekey="objectBaseResource1">
                        </web:base>
                        
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabMemo" Caption="Memo"  >
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabAttachments"  Caption="Attachments">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
