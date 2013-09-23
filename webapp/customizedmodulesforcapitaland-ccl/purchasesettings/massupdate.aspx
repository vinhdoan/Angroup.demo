<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource2" %>

<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    
    /// <summary>
    /// Occurs when the page loads up.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            treeLocation.PopulateTree();
            checkboxListPurchaseType.Bind(OCode.GetCodesByType("PurchaseType", null));
            BudgetGroupID.Bind(AppSession.User.GetAllAccessibleBudgetGroup("OPurchaseSettings", null));
        
        }
    }


    /// <summary>
    /// Constructs and returns the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, false, false, "OPurchaseSettings", false, false);
    }

    
    /// <summary>
    /// Occurs when the user clicks on the buttons.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    protected void panel_Click(object sender, string commandName)
    {
        if (commandName == "Update")
        {
            if (!panelMain.IsValid)
            {
                panel.Message = panelMain.CheckErrorMessages();
                return;
            }
            
            List<string> selectedLocations = treeLocation.CheckedValues;
            List<Guid> selectedLocationIds = new List<Guid>();
            foreach (string selectedLocationId in selectedLocations)
                selectedLocationIds.Add(new Guid(selectedLocationId));

            List<Guid> selectedPurchaseTypeIds = new List<Guid>();
            foreach (ListItem item in checkboxListPurchaseType.Items)
                if (item.Selected)
                    selectedPurchaseTypeIds.Add(new Guid(item.Value));

            List<Guid> selectedBudgetGrpIDs = new List<Guid>();
            foreach (ListItem item in BudgetGroupID.Items)
                if (item.Selected)
                    selectedBudgetGrpIDs.Add(new Guid(item.Value));
            
            // Validation
            //
            if (selectedLocationIds.Count == 0)
                treeLocation.ErrorMessage = Resources.Errors.PurchaseSettings_NoLocationsSelected;
            
            if (selectedPurchaseTypeIds.Count == 0)
                checkboxListPurchaseType.ErrorMessage = Resources.Errors.PurchaseSettings_NoPurchaseTypesSelected;

            if (selectedBudgetGrpIDs.Count == 0)
                BudgetGroupID.ErrorMessage = Resources.Errors.PurchaseSettings_NoBudgetGroupSelected;


            if (!panelMain.IsValid)
            {
                panel.Message = panelMain.CheckErrorMessages();
                return;
            }

            // Update
            //
            foreach (Guid locationId in selectedLocationIds)
            {
                foreach (Guid purchaseTypeId in selectedPurchaseTypeIds)
                {
                    foreach (Guid budgetGroupID in selectedBudgetGrpIDs)
                    {
                        // Try to load an existing purchase setting based on the
                        // location ID and purchase type ID.
                        //
                        OPurchaseSettings purchaseSettings =
                            TablesLogic.tPurchaseSettings.Load(
                            TablesLogic.tPurchaseSettings.LocationID == locationId &
                            TablesLogic.tPurchaseSettings.PurchaseTypeID == purchaseTypeId &
                            TablesLogic.tPurchaseSettings.BudgetGroupID == budgetGroupID);

                        // If it does not exist, then we create a new
                        // purchase setting object.
                        //
                        if (purchaseSettings == null)
                        {
                            purchaseSettings = TablesLogic.tPurchaseSettings.Create();
                            purchaseSettings.LocationID = locationId;
                            purchaseSettings.PurchaseTypeID = purchaseTypeId;
                            purchaseSettings.BudgetGroupID = budgetGroupID;
                        }

                        // Then update all the relevant fields and save it into the database.
                        //
                        panelMain.BindControlsToObject(purchaseSettings);
                        using (Connection c = new Connection())
                        {
                            purchaseSettings.Save();
                            c.Commit();
                        }
                    }
                }
            }

            panel.Message = Resources.Messages.PurchaseSettings_PurchaseSettingsUpdated;
            Window.Opener.Refresh();
        }

        if (commandName == "CloseWindow")
        {
            Window.Close();
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head2" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>

    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" 
        meta:resourcekey="panelMainResource1" BorderStyle="NotSet">
        <web:pagepanel runat="server" ID="panel" Caption="Update Multiple Purchase Settings" 
            Button1_Caption="Update" Button1_CommandName="Update" Button1_CausesValidation='true' Button1_ImageUrl="~/images/symbol-check-big.gif"
            Button2_Caption="Close Window" Button2_CommandName="CloseWindow" Button2_CausesValidation="false" Button2_ImageUrl="~/images/Window-Delete-big.gif"
            OnClick="panel_Click">
        </web:pagepanel>
        
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="UITabStrip1" 
                meta:resourcekey="UITabStrip1Resource1" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="tabQuickSetting" 
                    meta:resourcekey="tabQuickSettingResource1" Caption="Location / Purchase Type" 
                    BorderStyle="NotSet">
                        <div style="height: 350px">
                    <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" 
                                TreeListDisplayMode="FullyVisible" meta:resourcekey="treeLocationResource1"
                        OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" ShowCheckBoxes="All" 
                                TreeValueMode="SelectedNode" />
                        </div>
                    <ui:UIFieldCheckboxList runat="server" ID="checkboxListPurchaseType" meta:resourcekey="checkboxListPurchaseTypeResource1"
                        Caption="Purchase Type" TextAlign="Right">
                    </ui:UIFieldCheckboxList>
                        <br>
                    </br>
                        <br>
                    </br>
                        <br>
                    </br>
                        <ui:UIFieldCheckboxList runat='server' ID="BudgetGroupID" 
                            Caption="Budget Group" meta:resourcekey="BudgetGroupIDResource1" 
                            TextAlign="Right" >
                        </ui:UIFieldCheckboxList>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="UITabView1" Caption="Settings" 
                    meta:resourcekey="UITabView1Resource1" BorderStyle="NotSet">
                    <ui:UISeparator runat="server" ID="sep1" Caption="Quotations" meta:resourcekey="sep1Resource1"/>
                    <ui:UIPanel runat='server' ID="panelQuotationsProperties" BorderStyle="NotSet" 
                        meta:resourcekey="panelQuotationsPropertiesResource1">
                        <table cellpadding='1' cellspacing='0' border='0' style="width: 100%">
                            <tr class="field-required">
                                <td style="width: 150px">
                                    <asp:Label runat="server" ID="labelPolicy" meta:resourcekey="labelPolicyResource1" Text="Policy*:"></asp:Label>
                                </td>
                                <td>
                                    <asp:Label runat="server" ID="labelMinimumNumberOfQuotationsPolicy1" meta:resourcekey="labelMinimumNumberOfQuotationsPolicy1Resource1" Text="All Request for Quotations must have a minimum of" />
                                    <ui:UIFieldTextBox runat="server" ID="textMinimumNumberOfQuotations" 
                                        meta:resourcekey="textMinimumNumberOfQuotationsResource1" PropertyName="MinimumNumberOfQuotations"
                                        Caption="Minimum Quotations" FieldLayout="Flow" InternalControlWidth="30px"
                                        ShowCaption="False" ValidateRequiredField="True">
                                    </ui:UIFieldTextBox>
                                    <asp:Label runat="server" ID="labelMinimumNumberOfQuotationsPolicy2" meta:resourcekey="labelMinimumNumberOfQuotationsPolicy2Resource1" Text="quotation(s) (except those below" />
                                    <ui:UIFieldTextBox runat="server" ID="textMinimumApplicableRFQAmount" 
                                        meta:resourcekey="textMinimumApplicableRFQAmountResource1" ShowCaption="False"
                                        FieldLayout="Flow" ValidateRequiredField="True" PropertyName="MinimumApplicableRFQAmount"
                                        Caption="Policy" InternalControlWidth="120px" 
                                        DataFormatString="{0:#,##0.00}">
                                    </ui:UIFieldTextBox>
                                    <asp:Label runat="server" ID="labelMinimumNumberOfQuotationsPolicy3" Text=")" 
                                        meta:resourcekey="labelMinimumNumberOfQuotationsPolicy3Resource2" />
                                </td>
                            </tr>
                        </table>
                    </ui:UIPanel>
                    <ui:UIFieldRadioList runat='server' ID="radioMinimumNumberOfQuotationsPolicy" 
                        meta:resourcekey="radioMinimumNumberOfQuotationsPolicyResource1" 
                        Caption="Min Quotation Policy" ValidateRequiredField="True" PropertyName="MinimumNumberOfQuotationsPolicy"
                        RepeatColumns="0" TextAlign="Right">
                        <Items>
                            <asp:ListItem Text="Not required " Value="0" meta:resourcekey="ListItemResource1" Selected="True"></asp:ListItem>
                            <asp:ListItem Text="Preferred " Value="1" meta:resourcekey="ListItemResource2"></asp:ListItem>
                            <asp:ListItem Text="Required " Value="2" meta:resourcekey="ListItemResource3"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UISeparator runat="server" ID="UISeparator1" Caption="Purchase Orders" meta:resourcekey="UISeparator1Resource1" />
                    <ui:UIPanel runat='server' ID="panelPurchaseOrderProperties" 
                        meta:resourcekey="panelPurchaseOrderPropertiesResource1" BorderStyle="NotSet">
                        <table cellpadding='1' cellspacing='0' border='0' style="width: 100%">
                            <tr class="field-required">
                                <td style="width: 150px">
                                    <asp:Label runat="server" ID="labelPolicy2" meta:resourcekey="labelPolicy2Resource1" Text="Policy*:"></asp:Label>
                                </td>
                                <td>
                                    <asp:Label runat="server" ID="labelMinimumApplicablePOAmountFront" 
                                        meta:resourcekey="labelMinimumApplicablePOAmountFrontResource1" Text="
                                        All POs (except those below"></asp:Label>
                                    <ui:UIFieldTextBox runat="server" ID="textMinimumApplicablePOAmount" 
                                        ShowCaption="False" meta:resourcekey="textMinimumApplicablePOAmountResource1"
                                        FieldLayout="Flow" ValidateRequiredField="True" PropertyName="MinimumApplicablePOAmount"
                                        Caption="Policy" InternalControlWidth="120px" 
                                        DataFormatString="{0:#,##0.00}">
                                    </ui:UIFieldTextBox>
                                    <asp:Label runat="server" ID="labelMinimumApplicablePOAmountBack" 
                                        meta:resourcekey="labelMinimumApplicablePOAmountBackResource1" 
                                        Text=") must be generated from RFQs."></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </ui:UIPanel>
                    <ui:UIFieldRadioList runat='server' ID="radioRFQToPOPolicy" 
                        Caption="RFQ-to-PO Policy" meta:resourcekey="radioRFQToPOPolicyResource1" 
                        ValidateRequiredField="True" PropertyName="RFQToPOPolicy"
                        RepeatColumns="0" TextAlign="Right">
                        <Items>
                            <asp:ListItem Text="Not required " Value="0" meta:resourcekey="ListItemResource4" Selected="True"></asp:ListItem>
                            <asp:ListItem Text="Preferred " Value="1" meta:resourcekey="ListItemResource5"></asp:ListItem>
                            <asp:ListItem Text="Required " Value="2" meta:resourcekey="ListItemResource6"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UISeparator runat="server" ID="UISeparator2" Caption="Budgeting" meta:resourcekey="UISeparator2Resource1" />
                    <ui:UIFieldRadioList runat="server" ID="radioBudgetValidationPolicy" 
                        PropertyName="BudgetValidationPolicy" meta:resourcekey="radioBudgetValidationPolicyResource1"
                        Caption="Budget Validation Policy" ValidateRequiredField="True" 
                        TextAlign="Right">
                        <Items>
                            <asp:ListItem Value="0" Text="Budget = Line Items" meta:resourcekey="ListItemResource7" Selected="True"></asp:ListItem>
                            <asp:ListItem Value="1" Text="Budget <= Line Items" meta:resourcekey="ListItemResource8"></asp:ListItem>
                            <asp:ListItem Value="2" Text="Budget Not Required" meta:resourcekey="ListItemResource9"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UISeparator runat="server" ID="UISeparator3" Caption="Invoice" meta:resourcekey="UISeparator3Resource1" />
                    <ui:UIFieldCheckBox runat="server" ID="cbAllowPOClosure" Caption= "PO Closure" 
                        Text="Yes, allow PO to be closed even if the Invoice amount is not equals to the PO amount." 
                        PropertyName="IsPOAllowedClosure" meta:resourcekey="cbAllowPOClosureResource1" 
                        TextAlign="Right"></ui:UIFieldCheckBox>
                    <ui:UIFieldCheckBox runat="server" ID="InvoiceLargerThanPO" Caption= "Invoice Amount"
                    Text="Yes, allow the Invoice amount to be greater than the PO amount"
                     PropertyName="InvoiceLargerThanPO"
                    meta:resourcekey="InvoiceLargerThanPOResource1" TextAlign="Right"></ui:UIFieldCheckBox>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
