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
        OFixedRate fixedRate = panel.SessionObject as OFixedRate;

        if (Request["TREEOBJID"] != null && TablesLogic.tFixedRate[Security.DecryptGuid(Request["TREEOBJID"])] != null)
        {
            OFixedRate parentRate = TablesLogic.tFixedRate[Security.DecryptGuid(Request["TREEOBJID"])];
            if (parentRate != null && parentRate.IsFixedRate == 1)
                fixedRate.ParentID = null;
            else
                fixedRate.ParentID = Security.DecryptGuid(Request["TREEOBJID"]);
        }
        ParentID.PopulateTree();
        ParentID.Enabled = fixedRate.IsNew;
        UnitOfMeasureID.Bind(OCode.GetCodesByType("UnitOfMeasure", fixedRate.UnitOfMeasureID));

        if (!IsPostBack)
        {
            DefaultChargeOut.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            UnitPrice.Caption += " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
        }
        panel.ObjectPanel.BindObjectToControls(fixedRate);
    }


    /// <summary>
    /// Occurs when the user selects an item in the Fixed Rate dropdown
    /// list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void IsFixedRate_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Constructs and returns a fixed rate tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater ParentID_AcquireTreePopulater(object sender)
    {
        return new FixedRateTreePopulater(panel.SessionObject.ParentID, true, false);
    }


    /// <summary>
    /// Occurs when the users selects a node in the Belongs Under treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ParentID_SelectedNodeChanged(object sender, EventArgs e)
    {
    }





    /// <summary>
    /// Hides/shows and enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        ratePanel.Visible = IsFixedRate.SelectedIndex == 1;
    }


    /// <summary>
    /// Validates and saves the fixed rate object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OFixedRate fixedRate = panel.SessionObject as OFixedRate;
            panel.ObjectPanel.BindControlsToObject(fixedRate);

            // Validate
            //
            if (fixedRate.IsDuplicateName())
                objectBase.ObjectName.ErrorMessage = Resources.Errors.General_NameDuplicate;
            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            fixedRate.Save();
            c.Commit();
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Service Catalog" BaseTable="tFixedRate"
                OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Details" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <web:base runat="server" ID="objectBase" ObjectNumberVisible="true" ObjectNameTooltip="The item name as displayed on screen."
                            meta:resourcekey="objectBaseResource1" ObjectNumberCaption="Item Code"></web:base>
                        <ui:UIFieldTreeList runat="server" ID="ParentID" PropertyName="ParentID" Caption="Belongs Under"
                            OnAcquireTreePopulater="ParentID_AcquireTreePopulater" OnSelectedNodeChanged="ParentID_SelectedNodeChanged"
                            ToolTip="Indicates the book or group under which this item belongs." meta:resourcekey="ParentIDResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                        <ui:UIPanel runat="server" ID="nonBookPanel" meta:resourcekey="nonBookPanelResource1" BorderStyle="NotSet">
                            <ui:UIFieldRadioList runat="server" ID="IsFixedRate" PropertyName="IsFixedRate" OnSelectedIndexChanged="IsFixedRate_SelectedIndexChanged"
                                Caption="Fixed Rate Type" ValidateRequiredField="True" ToolTip="Indicates if this item is a group or a physical fixed rate item."
                                meta:resourcekey="IsFixedRateResource1" TextAlign="Right">
                                <Items>
                                    <asp:ListItem Value="0" Selected="True" meta:resourcekey="ListItemResource3" Text="Fixed Rate Group "></asp:ListItem>
                                    <asp:ListItem Value="1" meta:resourcekey="ListItemResource4" Text="Physical Fixed Rate Item "></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            <ui:UIPanel runat="server" ID="ratePanel" meta:resourcekey="ratePanelResource1" BorderStyle="NotSet">
                                <ui:UIFieldTextBox runat="server" ID="LongDescription" PropertyName="LongDescription"
                                    Caption="Long Description" TextMode="MultiLine" Rows="3" ToolTip="The long description of this fixed rate item."
                                    meta:resourcekey="LongDescriptionResource1" InternalControlWidth="95%" />
                                <ui:UIFieldTextBox runat="server" ID="UnitPrice" PropertyName="UnitPrice" Caption="Unit Price"
                                    ValidateRequiredField="True" Span="Half" ToolTip="The unit price of dollars of this fixed rate item."
                                    ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True"
                                    ValidationRangeMin="0" ValidationRangeMax="99999999999999" ValidationRangeType="Currency"
                                    meta:resourcekey="UnitPriceResource1" ValidationNumberOfDecimalPlaces="2" InternalControlWidth="95%" />
                                <ui:UIFieldTextBox runat="server" ID="textItemCode" PropertyName="ItemCode" Caption="Item Code" meta:resourcekey="textItemCodeResource1" InternalControlWidth="95%"></ui:UIFieldTextBox>
                                <ui:UIFieldDropDownList runat="server" ID="UnitOfMeasureID" PropertyName="UnitOfMeasureID"
                                    Caption="Unit of Measure" ValidateRequiredField="True" Span="Half" ToolTip="The unit of measure for this fixed rate item."
                                    meta:resourcekey="UnitOfMeasureIDResource1" />
                                <ui:UIFieldTextBox ID="DefaultChargeOut" runat="server" 
                                    Caption="Default Charge Out" DataFormatString="{0:#,##0.00}"
                                    PropertyName="DefaultChargeOut" Span="Half" ValidateDataTypeCheck="True"
                                    ValidationDataType="Currency"
                                    ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeMax="99999999999999"
                                    ValidationRangeType="Currency" InternalControlWidth="95%" meta:resourcekey="DefaultChargeOutResource1"/>
                                <ui:UIFieldTextBox runat="server" ID="PageNumber" PropertyName="PageNumber" Caption="Page Number"
                                    Span="Half" ToolTip="The page number of the item." meta:resourcekey="PageNumberResource1" InternalControlWidth="95%" />
                            </ui:UIPanel>
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo"  meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
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
