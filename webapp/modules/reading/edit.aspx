<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

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
        OReading obj = (OReading)panel.SessionObject;
        panel.ObjectPanel.BindObjectToControls(obj);

        if (obj.IsNew)
        {
            obj.Source = ReadingSource.Direct;
        }

        if (obj.CreateOnBreachWorkID == null && (obj.Source == ReadingSource.Direct || obj.Source == ReadingSource.PDA))
            panelReading.Enabled = true;
        else
            panelReading.Enabled = false;
    }


    /// <summary>
    /// Saves the calendar to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OReading obj = (OReading)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(obj);

            // Validate
            //
            // if(!obj.ValidationSomething)
            //    someControl.ErrorMessage = "Please enter a valid value.";
            //
            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            obj.Save();
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
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
        meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Reading" BaseTable="tReading" OnPopulateForm="panel_PopulateForm"
            OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1" SaveAndNewButtonVisible="false"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" 
                meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="tabDetails" runat="server" Caption="Details" 
                    BorderStyle="NotSet" meta:resourcekey="tabDetailsResource1">
                    <web:base ID="objectBase" runat="server" ObjectNameVisible="false" ObjectNumberVisible="false">
                    </web:base>
                    <ui:uifieldlabel runat="server" id="labelSource" PropertyName="SourceName" 
                        Caption="Source" DataFormatString="" meta:resourcekey="labelSourceResource1"></ui:uifieldlabel>
                    <ui:uipanel runat="server" id="panelReading" BorderStyle="NotSet" 
                        meta:resourcekey="panelReadingResource1">
                        <ui:UIFieldTextBox runat="server" Caption="Reading" ID="tbReading" PropertyName="Reading"
                            Span="Half" ValidateRequiredField="True" ValidateDataTypeCheck="True" 
                            ValidationDataType="Double" InternalControlWidth="95%" 
                            meta:resourcekey="tbReadingResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldDateTime runat="server" Caption="Date Of Reading" ID="tbDate" PropertyName="DateOfReading"
                            ShowTimeControls="True" ValidateRequiredField="True" 
                            meta:resourcekey="tbDateResource1" ShowDateControls="True">
                        </ui:UIFieldDateTime>
                    </ui:uipanel>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
