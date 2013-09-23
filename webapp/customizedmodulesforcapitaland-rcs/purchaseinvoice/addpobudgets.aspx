<%@ Page Language="C#" Inherits="PageBase" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>

<script runat="server">
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            gridResults.Columns[4].HeaderText += gridResults.Columns[4].HeaderText + " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
            gridResults.Columns[5].HeaderText += gridResults.Columns[5].HeaderText + " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
        }
    }


    /// <summary>
    /// Initializes the controls
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
    }


    /// <summary>
    /// Performs a search using a custom condition
    /// together with the automatically-generated condition.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        OPurchaseInvoice invoice = Session["::SessionObject::"] as OPurchaseInvoice;

        e.CustomCondition =
            TablesLogic.tBudgetTransactionLog.PurchaseBudget.PurchaseOrderID == invoice.PurchaseOrderID;
    }

    /// <summary>
    /// Adds the WJ item object into the session object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndAddSelected(object sender, EventArgs e)
    {
        OPurchaseInvoice invoice = Session["::SessionObject::"] as OPurchaseInvoice;

        // 2011.01.07
        // Kim Foong
        // Hash table to store budget periods related to the transaction logs.
        // 
        Hashtable relatedBudgetPeriods = new Hashtable();
        
        List<OPurchaseBudget> purchaseBudgets = new List<OPurchaseBudget>();
        foreach (GridViewRow row in gridResults.GetSelectedRows())
        {
            // Create an add object
            //
            OBudgetTransactionLog log = TablesLogic.tBudgetTransactionLog.Load((Guid)gridResults.DataKeys[row.RowIndex][0]);

            OPurchaseBudget purchaseBudget = TablesLogic.tPurchaseBudget.Create();
            purchaseBudget.BudgetID = log.BudgetID;
            purchaseBudget.AccountID = log.AccountID;
            purchaseBudget.Amount = log.TransactionAmount;
            purchaseBudget.StartDate = log.DateOfExpenditure;
            purchaseBudget.EndDate = log.DateOfExpenditure;
            purchaseBudget.AccrualFrequencyInMonths = 1;
            purchaseBudget.TransferFromBudgetTransactionLogID = log.ObjectID;
            purchaseBudgets.Add(purchaseBudget);

            // 2011.01.07
            // Kim Foong
            // Force the purchase budget to use the following year's budget by setting the
            // following year's accrual if the budget period for the original year is closed.
            //
            if (OApplicationSetting.Current.AllowInvoiceToUseCurrentYearBudgetIfPreviousIsClosed == 1)
            {
                if (relatedBudgetPeriods[purchaseBudget.BudgetID.Value] == null)
                {
                    relatedBudgetPeriods[purchaseBudget.BudgetID.Value] = new ArrayList();
                    ArrayList periods = (ArrayList)relatedBudgetPeriods[purchaseBudget.BudgetID.Value];
                    
                    // We only load budgets that are closed. Those are not yet closed,
                    // or have not been created yet, we'll ignore.
                    // 
                    List<OBudgetPeriod> budgetPeriods = TablesLogic.tBudgetPeriod.LoadList(
                        TablesLogic.tBudgetPeriod.BudgetID == purchaseBudget.BudgetID,
                        TablesLogic.tBudgetPeriod.StartDate.Asc);
                    foreach (OBudgetPeriod budgetPeriod in budgetPeriods)
                        periods.Add(budgetPeriod);
                }
                
                // 2011.01.07
                // Kim Foong
                // Force the purchase budget to use the following year's budget by setting the
                // following year's accrual if the budget period for the original year is closed.
                //
                DateTime originalDate = purchaseBudget.StartDate.Value;

                purchaseBudget.StartDate = OPurchaseBudget.GetAccrualDateToCommitToNonClosedBudget(
                    (ArrayList)relatedBudgetPeriods[purchaseBudget.BudgetID.Value], purchaseBudget.StartDate.Value);
                purchaseBudget.EndDate = purchaseBudget.StartDate;
                if (purchaseBudget.StartDate.Value != originalDate)
                    purchaseBudget.AccrualDateModifiedDueToBudgetClosed = 1;
            }
        }
        if (!panelAddItems.IsValid)
            return;

        invoice.PurchaseBudgets.AddRange(purchaseBudgets);
        Window.Opener.ClickUIButton("buttonItemsAdded");
        Window.Close();
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
    <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1" BorderStyle="NotSet">
        <web:search runat="server" ID="panel" Caption="Add Purchase Order Budgets" GridViewID="gridResults" AddSelectedButtonVisible="true" AddButtonVisible="false" EditButtonVisible="false" BaseTable="tBudgetTransactionLog" OnSearch="panel_Search" OnPopulateForm="panel_PopulateForm" SearchType="ObjectQuery" SearchAssignedOnly="false" OnValidateAndAddSelected="panel_ValidateAndAddSelected"></web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="uitabview1" Caption="Search" meta:resourcekey="uitabview1Resource1">
                    <ui:uifieldtextbox runat="server" id="textItemNumber" meta:resourcekey="textItemNumberResource1"  PropertyName="PurchaseBudget.ItemNumber" SearchType="Range" Caption="Item Number">
                    </ui:uifieldtextbox>
                    <ui:uifielddatetime runat="server" id="dateDateOfExpenditure" meta:resourcekey="dateDateOfExpenditureResource1" PropertyName="DateOfExpenditure" SearchType="Range" Caption="Date of Expenditure">
                    </ui:uifielddatetime>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview2" Caption="Results" meta:resourcekey="uitabview2Resource1">
                    <ui:UIObjectPanel runat="server" ID="panelAddItems" meta:resourcekey="panelAddItemsResource1">
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" BindObjectsToRows="true" meta:resourcekey="gridResultsResource1" Width="100%" SortExpression="ObjectName" RowErrorColor="" SetValidationGroupForSelectedRowsOnly="true">
                            <Columns>
                                <ui:UIGridViewBoundColumn PropertyName="PurchaseBudget.ItemNumber" meta:resourcekey="UIGridViewBoundColumnResource1" HeaderText="Line Number" />
                                <ui:UIGridViewBoundColumn PropertyName="Budget.ObjectName" meta:resourcekey="UIGridViewBoundColumnResource2" HeaderText="Budget" />
                                <ui:UIGridViewBoundColumn PropertyName="Account.Path" HeaderText="Account" meta:resourcekey="UIGridViewBoundColumnResource3" />
                                <ui:UIGridViewBoundColumn PropertyName="DateOfExpenditure" HeaderText="Date of Expenditure" meta:resourcekey="UIGridViewBoundColumnResource4" />
                                <ui:UIGridViewBoundColumn PropertyName="TransactionAmount" HeaderText="Amount Left" meta:resourcekey="UIGridViewBoundColumnResource5" />
                                <ui:UIGridViewTemplateColumn HeaderText="Amount" meta:resourcekey="UIGridViewTemplateColumnResource1">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textUnitPrice" meta:resourcekey="textUnitPriceResource1" Caption="Unit Price" PropertyName="UnitPriceInSelectedCurrency" ShowCaption="false" FieldLayout="Flow" ValidateRequiredField="true" ValidateDataTypeCheck="true" ValidationDataType="Currency" ValidateRangeField='true' ValidationRangeMin="0" ValidationRangeMinInclusive="false" ValidationRangeType="Currency">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                    </ui:UIObjectPanel>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
