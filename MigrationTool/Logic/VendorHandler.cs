using System;
using System.Data;
using LogicLayer;

namespace DataMigration.Logic
{
    public class VendorHandler : Migratable
    {
        public VendorHandler(string mapFrom, string mapTo)
            : base(mapFrom, mapTo)
        { }

        public VendorHandler(string mapFrom, string mapTo, string sourceFile)
            : base(mapFrom, mapTo, sourceFile)
        { }

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportVendorHandler(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void ImportVendorHandler(DataTable table)
        {
            foreach (DataRow dr in table.Rows)
            {
                try
                {
                    string name = Convert.ToString(dr[Map["Vendor Name"]]);
                    string taxCode = Convert.ToString(dr[Map["Tax Code"]]);
                    string currencyCode = Convert.ToString(dr[Map["Currency Code"]]);
                    string operatingCountry = Convert.ToString(dr[Map["Operating Country"]]);
                    string operatingState = Convert.ToString(dr[Map["Operating State"]]);
                    string operatingCity = Convert.ToString(dr[Map["Operating City"]]);
                    string operatingAddress = Convert.ToString(dr[Map["Operating Address"]]);
                    string operatingCellphone = Convert.ToString(dr[Map["Operating Cellphone"]]);
                    string operatingPhone = Convert.ToString(dr[Map["Operating Phone"]]);
                    string operatingEmail = Convert.ToString(dr[Map["Operating Email"]]);
                    string operatingFax = Convert.ToString(dr[Map["Operating Fax"]]);
                    string operatingContactPerson = Convert.ToString(dr[Map["Operating Contact Person"]]);

                    string billingCountry = Convert.ToString(dr[Map["Billing Country"]]);
                    string billingState = Convert.ToString(dr[Map["Billing State"]]);
                    string billingCity = Convert.ToString(dr[Map["Billing City"]]);
                    string billingAddress = Convert.ToString(dr[Map["Billing Address"]]);
                    string billingCellphone = Convert.ToString(dr[Map["Billing Cellphone"]]);
                    string billingPhone = Convert.ToString(dr[Map["Billing Phone"]]);
                    string billingEmail = Convert.ToString(dr[Map["Billing Email"]]);
                    string billingFax = Convert.ToString(dr[Map["Billing Fax"]]);
                    string billingContactPerson = Convert.ToString(dr[Map["Billing Contact Person"]]);

                    if (name == null)
                        throw new Exception("compulsory data must not be null");
                    if (taxCode == null || taxCode.Trim() == "")
                        throw new Exception("Tax Code is compulsory");
                    if (currencyCode == null || currencyCode.Trim() == "")
                        throw new Exception("Currency Code is compulsory");

                    OVendor vendor = TablesLogic.tVendor.Load(
                        TablesLogic.tVendor.ObjectName == name.Trim() &
                        TablesLogic.tVendor.IsDeleted == 0);
                    if (vendor == null)
                        vendor = TablesLogic.tVendor.Create();

                    vendor.ObjectName = name.Trim();

                    OTaxCode tc = TablesLogic.tTaxCode.Load(
                        TablesLogic.tTaxCode.ObjectName == taxCode);
                    if (tc != null)
                        vendor.TaxCodeID = tc.ObjectID;
                    else
                        throw new Exception("The tax code '" + taxCode + "' cannot be found.");

                    OCurrency cur = TablesLogic.tCurrency.Load(
                        TablesLogic.tCurrency.ObjectName == currencyCode);
                    if (cur != null)
                        vendor.CurrencyID = cur.ObjectID;
                    else
                        throw new Exception("The currency code '" + currencyCode + "' cannot be found.");

                    if (operatingCountry != null && operatingCountry.Trim() != "")
                        vendor.OperatingAddressCountry = operatingCountry;
                    if (operatingState != null && operatingState.Trim() != "")
                        vendor.OperatingAddressState = operatingState;
                    if (operatingCity != null && operatingCity.Trim() != "")
                        vendor.OperatingAddressCity = operatingCity;
                    if (operatingAddress != null && operatingAddress.Trim() != "")
                        vendor.OperatingAddress = operatingAddress;
                    if (operatingCellphone != null && operatingCellphone.Trim() != "")
                        vendor.OperatingCellPhone = operatingCellphone;
                    if (operatingPhone != null && operatingPhone.Trim() != "")
                        vendor.OperatingPhone = operatingPhone;
                    if (operatingFax != null && operatingFax.Trim() != "")
                        vendor.OperatingFax = operatingFax;
                    if (operatingEmail != null && operatingEmail.Trim() != "")
                        vendor.OperatingEmail = operatingEmail;
                    if (operatingContactPerson != null && operatingContactPerson.Trim() != "")
                        vendor.OperatingContactPerson = operatingContactPerson;

                    if (billingCountry != null && billingCountry.Trim() != "")
                        vendor.BillingAddressCountry = billingCountry;
                    if (billingState != null && billingState.Trim() != "")
                        vendor.BillingAddressState = billingState;
                    if (billingCity != null && billingCity.Trim() != "")
                        vendor.BillingAddressCity = billingCity;
                    if (billingAddress != null && billingAddress.Trim() != "")
                        vendor.BillingAddress = billingAddress;
                    if (billingCellphone != null && billingCellphone.Trim() != "")
                        vendor.BillingCellPhone = billingCellphone;
                    if (billingPhone != null && billingPhone.Trim() != "")
                        vendor.BillingPhone = billingPhone;
                    if (billingFax != null && billingFax.Trim() != "")
                        vendor.BillingFax = billingFax;
                    if (billingEmail != null && billingEmail.Trim() != "")
                        vendor.BillingEmail = billingEmail;
                    if (billingContactPerson != null && billingContactPerson.Trim() != "")
                        vendor.BillingContactPerson = billingContactPerson;

                    if (operatingContactPerson != null && operatingContactPerson.Trim() != "")
                    {
                        OVendorContact contact = TablesLogic.tVendorContact.Load
                            (TablesLogic.tVendorContact.ObjectName == operatingContactPerson.Trim() &
                            TablesLogic.tVendorContact.VendorID == vendor.ObjectID);

                        if (contact == null)
                            contact = TablesLogic.tVendorContact.Create();

                        contact.ObjectName = operatingContactPerson.Trim();
                        contact.Phone = operatingPhone;
                        contact.Cellphone = operatingCellphone;
                        contact.Email = operatingEmail;
                        contact.Fax = operatingFax;
                        contact.VendorID = vendor.ObjectID;

                        SaveObject(contact);
                        ActivateObject(contact);
                    }

                    SaveObject(vendor);
                    ActivateObject(vendor);
                }
                catch (Exception ex)
                {
                    dr[ERROR_MSG_COL] = ex.Message;
                }
            }
        }
    }
}