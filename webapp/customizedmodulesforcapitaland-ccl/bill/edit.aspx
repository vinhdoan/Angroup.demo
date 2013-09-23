<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" %>

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
        OBill obj = (OBill)panel.SessionObject;

        panel.ObjectPanel.BindObjectToControls(obj);
    }

    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        OBill obj = panel.SessionObject as OBill;
        return new LocationTreePopulaterForCapitaland(obj.LocationID, false, true, Security.Decrypt(Request["TYPE"]), false, false);
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
            OBill obj = (OBill)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(obj);

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
    <ui:UIObjectPanel runat="server" ID="panelMain">
        <web:object runat="server" ID="panel" Caption="Bill" BaseTable="tBill" meta:resourcekey="panelResource1"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject">
                <ui:UITabView ID="tabDetails" runat="server" Caption="Details">
                    <web:base ID="objectBase" runat="server" ObjectNameVisible="false" meta:resourcekey="objectBaseResource1"
                        ObjectNumberVisible="true" ObjectNumberCaption="Bill Number"></web:base>
                    <ui:UIFieldTextBox ID="textLocation" runat="server" Caption="Location" InternalControlWidth="95%"
                        PropertyName="Location.Path" Span="Full" Enabled="False" meta:resourcekey="ContactAmosOrgIDResource1" />
                    <ui:UIPanel ID="panelAmos" runat="server" BorderStyle="NotSet" caption="Amos" Enabled="False"
                        meta:resourcekey="panelAmosResource1">
                        <ui:UISeparator runat="server" ID="AmosSeparator" Caption="Amos" meta:resourcekey="AmosSeparatorResource1" />
                        <ui:UIFieldTextBox ID="textAmosBatchID" runat="server" Caption="Amos Batch ID" InternalControlWidth="95%"
                            PropertyName="BatchID" Span="Half" Enabled="False" meta:resourcekey="ContactAmosOrgIDResource1" />
                        <ui:UIFieldTextBox ID="textAmosAssetID" runat="server" Caption="Amos Asset ID" InternalControlWidth="95%"
                            PropertyName="AssetID" Span="Half" Enabled="False" meta:resourcekey="ContactAmosOrgIDResource1" />
                        <ui:UIFieldTextBox ID="textAmosDebtorID" runat="server" Caption="Amos Debtor ID"
                            InternalControlWidth="95%" PropertyName="DebtorID" Span="Half" Enabled="False"
                            meta:resourcekey="AmosContactIDResource1" />
                        <ui:UIFieldTextBox ID="textAmosLeaseID" runat="server" Caption="Amos Lease ID" InternalControlWidth="95%"
                            PropertyName="LeaseID" Span="Half" Enabled="False" meta:resourcekey="AmosBillAddressIDResource1" />
                        <ui:UIFieldTextBox ID="textAmosSuiteID" runat="server" Caption="Amos Suite ID" InternalControlWidth="95%"
                            PropertyName="SuiteID" Span="Half" Enabled="False" meta:resourcekey="AmosBillAddressIDResource1" />
                        <ui:UIFieldTextBox ID="textAmosContactID" runat="server" Caption="Amos Contact ID"
                            InternalControlWidth="95%" PropertyName="ContactID" Span="Half" Enabled="False"
                            meta:resourcekey="AddressLine1Resource1" />
                        <ui:UIFieldTextBox ID="textAmosAddressID" runat="server" Caption="Amos Address ID"
                            InternalControlWidth="95%" PropertyName="AddressID" Span="Half" Enabled="False"
                            meta:resourcekey="AddressLine2Resource1" />
                        <ui:UIFieldTextBox ID="updatedOn" runat="server" Caption="Updated On" InternalControlWidth="95%"
                            DataFormatString="{0:dd-MMM-yyyy}" PropertyName="updatedOn" Span="Half" Enabled="False"
                            meta:resourcekey="contactUpdatedOnResource1" />
                    </ui:UIPanel>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
