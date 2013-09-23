<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" 
    UICulture="auto" meta:resourcekey="PageResource1" %>

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
        OOPCAEServer opcAeServer = (OOPCAEServer)panel.SessionObject;
        panel.ObjectPanel.BindObjectToControls(opcAeServer);
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
            OOPCAEServer opcAeServer = (OOPCAEServer)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(opcAeServer);

            // Save
            //
            opcAeServer.Save();
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
            <web:object runat="server" ID="panel" Caption="OPC AE Server" BaseTable="tOPCAEServer" 
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" 
                    meta:resourcekey="tabObjectResource1" >
                    <ui:UITabView ID="uitabview1" runat="server"  Caption="Details" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview1Resource1">
                        <web:base ID="objectBase" runat="server" ObjectNameCaption="Server Name" ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1">
                        </web:base>
                        <ui:UIFieldTextBox runat="server" ID="textDescription" 
                            PropertyName="Description" Caption="Server Description" 
                            ValidateRequiredField='True' MaxLength="255" InternalControlWidth="95%" 
                            meta:resourcekey="textDescriptionResource1"></ui:UIFieldTextBox>
                        <ui:UIFieldCheckBox runat="server" ID="checkReceivingEventsEnabled" 
                            PropertyName="ReceivingEventsEnabled" Caption="Events Enabled" 
                            Text="Yes, enable receiving of events from this AE server." 
                            meta:resourcekey="checkReceivingEventsEnabledResource1" TextAlign="Right"></ui:UIFieldCheckBox>
                        <ui:UIFieldTextBox runat="server" ID="textBufferTimeInMilliseconds" Span="Half" 
                            PropertyName="BufferTimeInMilliseconds" Caption="Buffer Time" 
                            ValidateRequiredField='True' ValidateDataTypeCheck='True' 
                            ValidationDataType="Integer" ValidateRangeField="True" ValidationRangeMin="0" 
                            ValidationRangeType="Integer" InternalControlWidth="95%" 
                            meta:resourcekey="textBufferTimeInMillisecondsResource1"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textMaxNumberOfEventsPerCallback" 
                            Span="Half" PropertyName="MaxNumberOfEventsPerCallback" Caption="Buffer Time" 
                            ValidateRequiredField='True' ValidateDataTypeCheck='True' 
                            ValidationDataType="Integer" ValidateRangeField="True" ValidationRangeMin="0" 
                            ValidationRangeType="Integer" InternalControlWidth="95%" 
                            meta:resourcekey="textMaxNumberOfEventsPerCallbackResource1"></ui:UIFieldTextBox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview3Resource1" >
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="uitabview2" runat="server" Caption="Attachments" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview2Resource1">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
