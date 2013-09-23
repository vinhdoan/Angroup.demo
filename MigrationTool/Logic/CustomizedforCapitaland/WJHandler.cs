using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Data;
using Anacle.DataFramework;
using LogicLayer;

namespace DataMigration.Logic
{
    public class WJHandler : Migratable
    {
        public WJHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        { }

        public WJHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();

                ImportWJHandler(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void Migarate(bool assignTypeOfSvcOnly)
        {
            try
            {
                DataTable table = GetDatasource();
                ImportWJHandler(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }


        private string IsNull(string v, string alt)
        {
            if (v == null) return alt;
            return v;
        }


        private void ImportWJHandler(DataTable table)
        {
            foreach (DataRow dr in table.Rows)
            {
                try
                {
                    //DEFINE THE LOCATION
                    string l = "Twenty Anson";
                    string lGroup = "Operations";
                    OLocation loc = TablesLogic.tLocation.Load(TablesLogic.tLocation.ObjectName == l
                        & TablesLogic.tLocation.Parent.ObjectName == lGroup);

                    string WJNo = ConvertToString(dr[map["WJ Number"]]);
                    string WJDescription = ConvertToString(dr[map["Description"]]);
                    string WJRecoverable = ConvertToString(dr[map["Recoverable"]]);
                    string WJBackgroundType = ConvertToString(dr[map["Background Type"]]);
                    string WJBudgetGroup = ConvertToString(dr[map["Budget Group"]]);
                    string WJTransactionTypeGroup = ConvertToString(dr[map["Transaction Type Group"]]);
                    string WJTransactionType = ConvertToString(dr[map["Transaction Type"]]);
                    string WJTermContract = ConvertToString(dr[map["Term Contract"]]);
                    string WJRequestorName = ConvertToString(dr[map["Requestor Name"]]);
                    string WJDateRequired = ConvertToString(dr[map["Date Required"]]);
                    string WJDateEnd = ConvertToString(dr[map["Date End"]]);
                    string WJBackground = ConvertToString(dr[map["Background"]]);
                    string WJScope = ConvertToString(dr[map["Scope"]]);
                    string WJHasWarranty = ConvertToString(dr[map["Has Warranty"]]);
                    string ItemReceiptMode = ConvertToString(dr[map["Line Item Receipt Mode"]]);
                    string ItemDescription = ConvertToString(dr[map["Line Item Description"]]);
                    string ItemQuantity = ConvertToString(dr[map["Line Item Quantity"]]);
                    string ItemPrice = ConvertToString(dr[map["Line Item Unit Price"]]);
                    string VendorName = ConvertToString(dr[map["Vendor Name"]]);
                    string VendorContactPerson = ConvertToString(dr[map["Vendor Contact Person"]]);
                    string VendorDateofQuotation = ConvertToString(dr[map["Date of Quotation"]]);
                    string VendorQuotationRef = ConvertToString(dr[map["Quotation Ref No"]]);
                    string VendorPrice = ConvertToString(dr[map["Vendor Price"]]);
                    string BudgetAccount = ConvertToString(dr[map["Budget Account"]]);
                    string BudgetAccrualDate = ConvertToString(dr[map["Accrual Date"]]);

                    //Validate Location
                    if (loc == null)
                        throw new Exception("Location " + l + " does not exist");

                    //Validate WJNo
                    if (String.IsNullOrEmpty(WJNo))
                        throw new Exception("WJ Number can not be left empty");
                    if (TablesLogic.tRequestForQuotation.Load(TablesLogic.tRequestForQuotation.ObjectNumber == WJNo) != null)
                        throw new Exception("This WJ number is already existed in the system");

                    //Validate WJBackgroundType
                    if (String.IsNullOrEmpty(WJBackgroundType))
                        throw new Exception("WJ Background Type can not be left empty");
                    List<OCode> WJBackgroundTypeCode = OCode.FindCodesByType(WJBackgroundType, "BackgroundType");
                    if (WJBackgroundTypeCode.Count != 1)
                        throw new Exception("WJ Background Type returns 0 or more than 1 result");

                    //Validate WJBudgetGroup
                    if (String.IsNullOrEmpty(WJBudgetGroup))
                        throw new Exception("WJ Budget Group can not be left empty");
                    OBudgetGroup BudgetGroup = TablesLogic.tBudgetGroup.Load(TablesLogic.tBudgetGroup.ObjectName == WJBudgetGroup);

                    //Validate WJTransactionTypeGroup
                    if (String.IsNullOrEmpty(WJTransactionTypeGroup))
                        throw new Exception("WJTransactionTypeGroup can not be left empty");
                    List<OCode> WJTransactionTypeGroupCode = OCode.FindCodesByType(WJTransactionTypeGroup, "PurchaseTypeClassification");
                    if (WJTransactionTypeGroupCode.Count != 1)
                        throw new Exception("WJTransactionTypeGroup returns 0 or more than 1 result");

                    //Validate WJTransactionType
                    if (String.IsNullOrEmpty(WJTransactionType))
                        throw new Exception("WJTransactionType can not be left empty");
                    List<OCode> WJTransactionTypeCode = OCode.FindCodesByType(WJTransactionType, "PurchaseType");
                    if (WJTransactionTypeCode.Count != 1)
                        throw new Exception("WJTransactionTypeCode returns 0 or more than 1 result");

                    //Validate WJRequestorName
                    OUser requestor = TablesLogic.tUser.Load(
                           TablesLogic.tUser.ObjectName == WJRequestorName &
                           TablesLogic.tUser.IsDeleted == 0);
                    if (requestor == null)
                        throw new Exception("This Requestor Name does not exist");

                    //Validate ItemReceiptMode
                    int? ItemReceiptModeNumber = new int?();
                    //if (ItemReceiptMode == "Dollar Amount")
                    //    ItemReceiptModeNumber = (int)ReceiptModeType.Dollar;
                    //else if (ItemReceiptMode == "Quantity")
                    //    ItemReceiptModeNumber = (int)ReceiptModeType.Quantity;
                    //else
                    //    throw new Exception("ItemReceiptMode is not valid");
                    ItemReceiptModeNumber = (int)ReceiptModeType.Quantity;

                    //Validate VendorName
                    OVendor vendor;
                    if (String.IsNullOrEmpty(VendorName))
                        throw new Exception("VendorName can not be left empty");
                    vendor = TablesLogic.tVendor.Load(TablesLogic.tVendor.ObjectName == VendorName);
                    if (vendor == null)
                        throw new Exception("Vendor does not exist");

                    //Validate BudgetAccount
                    if (String.IsNullOrEmpty(BudgetAccount))
                        throw new Exception("Budget Account can not be left empty");
                    string[] listAccounts = BudgetAccount.Trim('>').Split('>');
                    OAccount account = findAccount(listAccounts);

                    //Validate Budget
                    OBudget budget = TablesLogic.tBudget.Load(TablesLogic.tBudget.ObjectName == "Budget for " + l + " (" + lGroup + ")");
                    if (budget == null)
                        throw new Exception("Budget does not exist");

                    ORequestForQuotation newRFQ = TablesLogic.tRequestForQuotation.Create();
                    newRFQ.LocationID = loc.ObjectID;
                    newRFQ.ObjectNumber = WJNo;
                    newRFQ.Description = WJDescription;
                    newRFQ.IsRecoverable = translateYesNo(WJRecoverable);
                    newRFQ.BackgroundTypeID = WJBackgroundTypeCode[0].ObjectID;
                    newRFQ.BudgetGroupID = BudgetGroup.ObjectID;
                    newRFQ.TransactionTypeGroupID = WJTransactionTypeGroupCode[0].ObjectID;
                    newRFQ.PurchaseTypeID = WJTransactionTypeCode[0].ObjectID;
                    newRFQ.IsTermContract = translateYesNo(WJTermContract);
                    newRFQ.RequestorName = requestor.ObjectName;
                    newRFQ.RequestorID = requestor.ObjectID;
                    newRFQ.DateRequired = Convert.ToDateTime(WJDateRequired);
                    newRFQ.DateEnd = Convert.ToDateTime(WJDateEnd);
                    newRFQ.Background = WJBackground;
                    newRFQ.Scope = WJScope;
                    newRFQ.hasWarranty = translateYesNo(WJHasWarranty);
                    newRFQ.RFQTitle = WJNo + ": " + WJDescription;

                    //Add item
                    ORequestForQuotationItem rfqi = TablesLogic.tRequestForQuotationItem.Create();
                    rfqi.ReceiptMode = ItemReceiptModeNumber;
                    rfqi.ItemDescription = ItemDescription;
                    rfqi.QuantityRequired = rfqi.QuantityProvided = Convert.ToDecimal(ItemQuantity);
                    rfqi.ItemNumber = 1;
                    rfqi.RecoverableAmount = rfqi.RecoverableAmountInSelectedCurrency = 0;
                    rfqi.AdditionalDescription = "";
                    rfqi.ItemType = (int)PurchaseItemType.Others;
                    List<OCode> uom = OCode.FindCodesByType("Each", "UnitOfMeasure");
                    rfqi.UnitOfMeasureID = uom[0].ObjectID;
                    OCurrency currency = TablesLogic.tCurrency.Load(TablesLogic.tCurrency.ObjectName == "SGD");
                    rfqi.CurrencyID = currency.ObjectID;
                    rfqi.AwardedVendorID = vendor.ObjectID;
                    newRFQ.RequestForQuotationItems.Add(rfqi);

                    //Add vendor
                    newRFQ.RequestForQuotationVendors.Add(newRFQ.CreateRequestForQuotationVendor(vendor.ObjectID));
                    newRFQ.RequestForQuotationVendors[0].ObjectNumber = VendorQuotationRef;
                    newRFQ.RequestForQuotationVendors[0].CurrencyID = currency.ObjectID;
                    newRFQ.RequestForQuotationVendors[0].IsSubmitted = 1;
                    if (!String.IsNullOrEmpty(VendorDateofQuotation))
                        newRFQ.RequestForQuotationVendors[0].DateOfQuotation = Convert.ToDateTime(VendorDateofQuotation);
                    newRFQ.RequestForQuotationVendors[0].IsExchangeRateDefined = 0;
                    newRFQ.RequestForQuotationVendors[0].ForeignToBaseExchangeRate = 1;
                    newRFQ.RequestForQuotationVendors[0].RequestForQuotationVendorItems[0].UnitPrice =
                        newRFQ.RequestForQuotationVendors[0].RequestForQuotationVendorItems[0].UnitPriceInSelectedCurrency = Convert.ToDecimal(ItemPrice);

                    //Update Award
                    newRFQ.RequestForQuotationItems[0].AwardedRequestForQuotationVendorItemID = newRFQ.RequestForQuotationVendors[0].RequestForQuotationVendorItems[0].ObjectID;

                    //Add Budget
                    newRFQ.BudgetDistributionMode = (int)BudgetDistribution.EntireAmount;
                    for (int i = 0; i < Convert.ToInt32(ItemQuantity); i++)
                    {
                        DateTime? accrualDate = Convert.ToDateTime(BudgetAccrualDate).AddMonths(i);
                        OPurchaseBudget pb = TablesLogic.tPurchaseBudget.Create();
                        pb.AccountID = account.ObjectID;
                        pb.StartDate = pb.EndDate = accrualDate;
                        pb.BudgetID = budget.ObjectID;
                        pb.ItemNumber = 1;
                        pb.AccrualFrequencyInMonths = 1;
                        pb.Amount = Convert.ToDecimal(ItemPrice);
                        pb.RequestForQuotationID = rfqi.ObjectID;
                        newRFQ.PurchaseBudgets.Add(pb);
                    }

                    SaveObject(newRFQ);
                    ActivateObject(newRFQ);

                    using (Connection c = new Connection())
                    {
                        newRFQ.SaveAndTransit("SaveAsDraft");
                        newRFQ.ComputeTempBudgetSummaries();
                        c.Commit();
                    }
                }
                catch (Exception ex)
                {
                    dr[ERROR_MSG_COL] = ex.Message;
                }
            }
        }

        private OAccount findAccount(string[] list)
        {
            string parentID = "";
            OAccount account;

            for (int i = 0; i < list.Length; i++)
            {
                string strBudgetAccount = list[i].Trim();

                if (parentID != null && parentID.ToString() != string.Empty)
                {
                    if (i == list.Length - 1)
                        account = TablesLogic.tAccount.Load(
                                    TablesLogic.tAccount.ObjectName == strBudgetAccount &
                                    TablesLogic.tAccount.ParentID == new Guid(parentID) &
                                    TablesLogic.tAccount.Type == 1 &
                                    TablesLogic.tAccount.IsDeleted == 0);
                    else
                        account = TablesLogic.tAccount.Load(
                                TablesLogic.tAccount.ObjectName == strBudgetAccount &
                                TablesLogic.tAccount.ParentID == new Guid(parentID) &
                                TablesLogic.tAccount.Type == 0 &
                                TablesLogic.tAccount.IsDeleted == 0);
                }
                else
                {
                    if (i == list.Length - 1)
                        account = TablesLogic.tAccount.Load(
                                    TablesLogic.tAccount.ObjectName == strBudgetAccount &
                                    TablesLogic.tAccount.ParentID == null &
                                    TablesLogic.tAccount.Type == 1 &
                                    TablesLogic.tAccount.IsDeleted == 0);
                    else
                        account = TablesLogic.tAccount.Load(
                                    TablesLogic.tAccount.ObjectName == strBudgetAccount &
                                    TablesLogic.tAccount.ParentID == null &
                                    TablesLogic.tAccount.Type == 0 &
                                    TablesLogic.tAccount.IsDeleted == 0);
                }
                if (account == null)
                    throw new Exception("Account '" + strBudgetAccount + "' does not exist");
                else if (i == list.Length - 1)
                    return account;

                parentID = account.ObjectID.ToString();
            }

            return null;
        }

        private int? translateYesNo(string i)
        {
            if (i == "Yes")
                return 1;
            else if (i == "No")
                return 0;
            else
                return null;
        }
    }
}