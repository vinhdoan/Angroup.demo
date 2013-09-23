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
        OPurchaseSettings purchaseSettings = (OPurchaseSettings)panel.SessionObject;

        if (Request["TREEOBJID"] != null)
        {
            Guid id = Security.DecryptGuid(Request["TREEOBJID"]);
            OLocation location = TablesLogic.tLocation[id];
            purchaseSettings.Location = location;
        }

        treeLocation.PopulateTree();
        dropPurchaseType.Bind(OCode.GetCodesByType("PurchaseType", purchaseSettings.PurchaseTypeID));
        panel.ObjectPanel.BindObjectToControls(purchaseSettings);
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
            OPurchaseSettings purchaseSettings = (OPurchaseSettings)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(purchaseSettings);

            // Validate
            //
            if (!purchaseSettings.ValidateNoDuplicateLocation())
                treeLocation.ErrorMessage = Resources.Errors.PurchaseSettings_DuplicateLocation;

            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            purchaseSettings.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// Constructs and returns the location tree
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        OPurchaseSettings purchaseSettings = (OPurchaseSettings)panel.SessionObject;
        return new LocationTreePopulater(purchaseSettings.LocationID, true, true, Security.Decrypt(Request["TYPE"]));
    }


    /// <summary>
    /// Hides/shows controls.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

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
    <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Purchase Settings" BaseTable="tPurchaseSettings"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="tabDetails" runat="server" Caption="Details" meta:resourcekey="tabDetailsResource1">
                    <web:base ID="objectBase" runat="server" ObjectNameVisible="false" ObjectNumberVisible="false">
                    </web:base>
                    <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" PropertyName="LocationID" meta:resourcekey="treeLocationResource1"
                        ValidateRequiredField="true" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater"
                        ToolTip="Use this to select the location that this set of settings applies to." />
                    <ui:UIFieldDropDownList runat="server" ID="dropPurchaseType" PropertyName="PurchaseTypeID" meta:resourcekey="dropPurchaseTypeResource1"
                        Caption="Purchase Type" ValidateRequiredField="true">
                    </ui:UIFieldDropDownList>
                    <ui:UISeparator runat="server" ID="sep1" Caption="Quotations" meta:resourcekey="sep1Resource1" />
                    <ui:UIPanel runat='server' ID="panelQuotationsProperties">
                        <table cellpadding='1' cellspacing='0' border='0' style="width: 100%">
                            <tr class="field-required">
                                <td style="width: 150px">
                                    <asp:Label runat="server" ID="labelPolicy" Text="Policy*:" meta:resourcekey="labelPolicyResource1"></asp:Label>
                                </td>
                                <td>
                                    <asp:Label runat="server" ID="labelMinimumNumberOfQuotationsPolicy1" meta:resourcekey="labelMinimumNumberOfQuotationsPolicy1Resource1" Text="All Request for Quotations must have a minimum of" />
                                    <ui:UIFieldTextBox runat="server" ID="textMinimumNumberOfQuotations" meta:resourcekey="textMinimumNumberOfQuotationsResource1"
                                        PropertyName="MinimumNumberOfQuotations"
                                        Caption="Minimum Quotations" CaptionWidth="120px" FieldLayout="Flow" InternalControlWidth="30px"
                                        ShowCaption="false"
                                        ValidateRequiredField="true">
                                    </ui:UIFieldTextBox>
                                    <asp:Label runat="server" ID="labelMinimumNumberOfQuotationsPolicy2" Text="quotation(s) (except those below" meta:resourcekey="labelMinimumNumberOfQuotationsPolicy2Resource1" />
                                    <ui:UIFieldTextBox runat="server" ID="textMinimumApplicableRFQAmount" ShowCaption="false" meta:resourcekey="textMinimumApplicableRFQAmountResource1"
                                        FieldLayout="Flow" ValidateRequiredField="true" PropertyName="MinimumApplicableRFQAmount"
                                        Caption="Policy" InternalControlWidth="120px" DataFormatString="{0:#,##0.00}">
                                    </ui:UIFieldTextBox>
                                    <asp:Label runat="server" ID="labelMinimumNumberOfQuotationsPolicy3" Text=")" meta:resourcekey="labelMinimumNumberOfQuotationsPolicy3Resource1"/>
                                </td>
                            </tr>
                        </table>
                    </ui:UIPanel>
                    <ui:UIFieldRadioList runat='server' ID="radioMinimumNumberOfQuotationsPolicy" Caption="Min Quotation Policy" meta:resourcekey="radioMinimumNumberOfQuotationsPolicyResource1"
                        CaptionWidth="120px" ValidateRequiredField="true" PropertyName="MinimumNumberOfQuotationsPolicy" RepeatColumns="0" RepeatDirection="Horizontal">
                        <Items>
                            <asp:ListItem Text="Not required " meta:resourcekey="ListItemResource1" Value="0"></asp:ListItem>
                            <asp:ListItem Text="Preferred " meta:resourcekey="ListItemResource2"
                                Value="1"></asp:ListItem>
                            <asp:ListItem Text="Required " Value="2" meta:resourcekey="ListItemResource3"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UISeparator runat="server" ID="UISeparator1" Caption="Purchase Orders" meta:resourcekey="UISeparator1Resource1" />
                    <ui:UIPanel runat='server' ID="panelPurchaseOrderProperties" meta:resourcekey="panelPurchaseOrderPropertiesResource1">
                        <table cellpadding='1' cellspacing='0' border='0' style="width: 100%">
                            <tr class="field-required">
                                <td style="width: 150px">
                                    <asp:Label runat="server" ID="labelPolicy2" Text="Policy*:" meta:resourcekey="labelPolicy2Resource1"></asp:Label>
                                </td>
                                <td>
                                    <asp:Label runat="server" ID="labelMinimumApplicablePOAmountFront" meta:resourcekey="labelMinimumApplicablePOAmountFrontResource1">
                                        All POs (except those below</asp:Label>
                                    <ui:UIFieldTextBox runat="server" ID="textMinimumApplicablePOAmount" meta:resourcekey="textMinimumApplicablePOAmountResource1" ShowCaption="false"
                                        FieldLayout="Flow" ValidateRequiredField="true" PropertyName="MinimumApplicablePOAmount"
                                        Caption="Policy" InternalControlWidth="120px" DataFormatString="{0:#,##0.00}">
                                    </ui:UIFieldTextBox>
                                    <asp:Label runat="server" ID="labelMinimumApplicablePOAmountBack" meta:resourcekey="labelMinimumApplicablePOAmountBackResource1">) must be generated from RFQs.</asp:Label>
                                </td>
                            </tr>
                        </table>
                    </ui:UIPanel>
                    <ui:UIFieldRadioList runat='server' ID="radioRFQToPOPolicy" Caption="RFQ-to-PO Policy" meta:resourcekey="radioRFQToPOPolicyResource1"
                        CaptionWidth="120px" ValidateRequiredField="true" PropertyName="RFQToPOPolicy" RepeatColumns="0" RepeatDirection="Horizontal">
                        <Items>
                            <asp:ListItem Text="Not required " meta:resourcekey="ListItemResource4" Value="0"></asp:ListItem>
                            <asp:ListItem Text="Preferred " meta:resourcekey="ListItemResource5"
                                Value="1"></asp:ListItem>
                            <asp:ListItem Text="Required " meta:resourcekey="ListItemResource6"
                                Value="2"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIFieldCheckBox runat="server" ID="cbAllowPOClosure" Caption= "Allow Closure if PO amount <> IR Amount" PropertyName="IsPOAllowedClosure"></ui:UIFieldCheckBox>
                    <ui:UISeparator runat="server" ID="UISeparator2" Caption="Budgeting" meta:resourcekey="UISeparator2Resource1" />
                    <ui:UIFieldRadioList runat="server" id="radioBudgetValidationPolicy" meta:resourcekey="radioBudgetValidationPolicyResource1" PropertyName="BudgetValidationPolicy" Caption="Budget Validation Policy" ValidateRequiredField="true">
                        <Items>
                            <asp:ListItem Value="0" Text="Budget = Line Items" meta:resourcekey="ListItemResource7"></asp:ListItem>
                            <asp:ListItem Value="1" Text="Budget <= Line Items" meta:resourcekey="ListItemResource8"></asp:ListItem>
                            <asp:ListItem Value="2" Text="Budget Not Required" meta:resourcekey="ListItemResource9"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" meta:resourcekey="tabMemoResource1">
                    <web:memo runat="server" ID="memo1"></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabAttachments" meta:resourcekey="tabAttachmentsResource1" Caption="Attachments">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
