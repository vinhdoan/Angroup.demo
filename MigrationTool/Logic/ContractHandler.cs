using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using Anacle.DataFramework;
using LogicLayer;

namespace DataMigration.Logic
{
    public class ContractHandler : Migratable
    {
        public ContractHandler(string mapFrom, string mapTo)
            : base(mapFrom, mapTo)
        { }

        public ContractHandler(string mapFrom, string mapTo, string sourceFile)
            : base(mapFrom, mapTo, sourceFile)
        { }

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportContractHandler(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void ImportContractHandler(DataTable table)
        {
            //Dictionary<string, WorkflowObject> wk = Workflow.Objects;
            foreach(DataRow dr in table.Rows)
            {
                try
                {
                    string description = Convert.ToString(dr[Map["DESCRIPTION"]]);
                    string serviceLocation = Convert.ToString(dr[Map["ServiceLocation"]]);
                    string provideMaintenance = Convert.ToString(dr[Map["Provides Maintenance Works? (Y/N)"]]);
                    string typeOfService = Convert.ToString(dr[Map["TypeOfService"]]);
                    //string fixedPrice = Convert.ToString(dr[Map["Provides Fixed Pricing Agreement? (Y/N)"]]).Trim();
                    
                    //string fixedRateGroup = "";
                    //string priceFactor = "";

                    //if fixed price is N then fixedrategroup and pricefactor can be null
                    /*
                    if (fixedPrice == "Y" || fixedPrice == "y" || fixedPrice == "Yes" || fixedPrice == "YES")
                    {
                        fixedRateGroup = Convert.ToString(dr[Map["FixedRate"]]);
                        priceFactor = Convert.ToString(dr[Map["PriceFactor"]]);

                        if (fixedRateGroup == null || priceFactor == null)
                            throw new Exception("Fixed rate group and Price factor data is required if contract provides Fixed Pricing Agreement");
                    }
                    */
                    string contractManager = Convert.ToString(dr[Map["ContractManager"]]);
                    string vendor = Convert.ToString(dr[Map["VENDOR NAME"]]);
                    //string management = Convert.ToString(dr[Map["MANAGEMENT"]]);
                    string contactPerson = Convert.ToString(dr[Map["CONTACT PERSON"]]);
                    string contactCellphone = Convert.ToString(dr[Map["CONTACT CELLPHONE"]]);
                    //trim internal space in contact cellphone
                    contactCellphone = TrimInternalSpace(contactCellphone);
                    string contactPhone = Convert.ToString(dr[Map["CONTACT PHONE"]]);
                    string contactEmail = Convert.ToString(dr[Map["CONTACT EMAIL"]]);
                    string contactFax = Convert.ToString(dr[Map["CONTACT FAX"]]);
                    //string vendorAddress = Convert.ToString(dr[Map["VENDOR ADDRESS"]]);
                    //int optionPeriod = Convert.ToInt32(dr[Map["Option Period"]]);
                    decimal contractSum = Convert.ToDecimal(dr[Map["CONTRACT SUM"]]);
                    //string contractGroup = dr[Map["ContractGroup"]].ToString() == string.Empty ? "" : Convert.ToString(dr[Map["ContractGroup"]]);
                    DateTime startDate = new DateTime();
                    DateTime endDate = new DateTime();
                    startDate = Convert.ToDateTime(dr[Map["START DATE"]]);
                    endDate = Convert.ToDateTime(dr[Map["END DATE"]]);
                    if (startDate > endDate)
                        throw new Exception("Contract Start Date must be smaller than Contract End Date");

                    string terms = Convert.ToString(dr[Map["TERMS (FREE TEXT)"]]);
                    string warranty = Convert.ToString(dr[Map["WARRANTY (FREE TEXT)"]]);
                    string insurance = Convert.ToString(dr[Map["INSURANCE (FREE TEXT)"]]);
                    /*
                    vendorAddress = vendorAddress.Replace('\n',' ');
                    if (dr[Map["CONSUMPTION THRESHOLD"]].ToString() == string.Empty)
                        throw new Exception("Consumption Threshold cannot be empty");
                    decimal consumptionThreshold = Convert.ToDecimal(dr[Map["CONSUMPTION THRESHOLD"]]);
                    */

                    if (description == null || serviceLocation == null ||
                        provideMaintenance == null || typeOfService == null || 
                        vendor == null || 
                        contactPerson == null || contactCellphone == null || contactEmail == null ||
                        startDate == null || endDate == null)
                        throw new Exception("Compulsory data cannot be left empty");

                    OContract contract = TablesLogic.tContract.Load(
                        TablesLogic.tContract.ObjectName == description &
                        TablesLogic.tContract.IsDeleted == 0);

                    if (contract == null)
                        contract = TablesLogic.tContract.Create();

                    string[] locationPath = serviceLocation.Trim('|').Split('|');
                    if(contract != null)
                    {
                        contract.ObjectName = description;
                        contract.Description = description;
                        
                        contract.Locations.Clear();
                        for (int i = 0; i < locationPath.Length; i++)
                        {
                            OLocation location = null;
                            if (locationPath[i] != string.Empty)
                            {
                                location = GetLocation(locationPath[i]);
                                if (location != null)
                                    contract.Locations.AddGuid(new Guid(location.ObjectID.ToString()));
                                else
                                    throw new Exception("invalid service location");
                            }
                        }

                        if (provideMaintenance == "Y" || provideMaintenance == "Yes" || provideMaintenance == "YES")
                        {
                            contract.ProvideMaintenance = 1;
                        }
                        else if (provideMaintenance == "N" || provideMaintenance == "No" || provideMaintenance == "NO")
                        {
                            contract.ProvideMaintenance = 0;
                        }
                        else
                            throw new Exception("invalid ProvideMaintenance");

                        if (typeOfService.Contains("All"))
                        {
                            List<OCode> list = TablesLogic.tCode.LoadList(
                                TablesLogic.tCode.CodeType.ObjectName == "TypeOfService" &
                                TablesLogic.tCode.IsDeleted == 0);
                            if (list != null)
                                foreach (OCode tos in list)
                                    contract.TypeOfServices.AddGuid(new Guid(tos.ObjectID.ToString()));
                        }
                        else
                        {
                            string[] tosPath = typeOfService.Trim('|').Split('|');
                            contract.TypeOfServices.Clear();
                            for (int i = 0; i < tosPath.Length; i++)
                            {
                                OCode tos = GetTypeOfService(tosPath[i]);
                                if (tos != null)
                                    contract.TypeOfServices.AddGuid(new Guid(tos.ObjectID.ToString()));
                                else
                                    throw new Exception("invalid TypeOfService");
                            }
                        }

                        /*
                        OContractPriceService contractPriceService = null;
                        if (contract.ProvidePricingAgreement == 1)
                        {                            
                            string[] group = fixedRateGroup.Trim().Split(',');
                            OFixedRate rate = null;
                            string parentID = "";
                            for (int i = 0; i < group.Length; i++)
                            {
                                string groupItem = group[i].Trim();
                                if (parentID != null && parentID.ToString() != string.Empty)
                                    rate = TablesLogic.tFixedRate.Load(
                                        TablesLogic.tFixedRate.ObjectName == groupItem &
                                        TablesLogic.tFixedRate.ParentID == new Guid(parentID) &
                                        TablesLogic.tFixedRate.IsDeleted == 0);
                                else
                                    rate = TablesLogic.tFixedRate.Load(
                                        TablesLogic.tFixedRate.ObjectName == groupItem &
                                        TablesLogic.tFixedRate.IsDeleted == 0);
                                if (rate != null)
                                    parentID = rate.ObjectID.ToString();
                            }
                            if (rate == null)
                                throw new Exception("invalid fix rate group");
                            else
                            {
                                bool isNew = false;
                                contractPriceService = TablesLogic.tContractPriceServices.Load(
                                    TablesLogic.tContractPriceServices.ContractID == contract.ObjectID &
                                    TablesLogic.tContractPriceServices.FixedRateID == rate.ObjectID &
                                    TablesLogic.tContractPriceServices.IsDeleted == 0);
                                if (contractPriceService == null)
                                {
                                    contractPriceService = TablesLogic.tContractPriceServices.Create();
                                    contractPriceService.ContractID = contract.ObjectID;
                                    isNew = true;
                                }
                                contractPriceService.FixedRateID = rate.ObjectID;
                                contractPriceService.PriceFactor = Convert.ToDecimal(priceFactor);

                                if (Convert.ToInt32(contract.ProvidePricingAgreement) == 1 && isNew)
                                    contract.ContractPriceServices.AddGuid(new Guid(contractPriceService.ObjectID.ToString()));
                                //else if (Convert.ToInt32(contract.ProvidePricingAgreement) == 0)
                                //    throw new Exception("Fixed Rate Group is not added because Provide Fixed Pricing Agreement value is 'N'");
                            }
                        }
                         * */

                        OUserBase ubase = TablesLogic.tUserBase.Load(
                            TablesLogic.tUserBase.LoginName == contractManager &
                            TablesLogic.tUserBase.IsDeleted == 0);
                        if (ubase != null)
                        {
                            OUser user = TablesLogic.tUser.Load(
                                TablesLogic.tUser.UserBaseID == ubase.ObjectID &
                                TablesLogic.tUser.IsDeleted == 0);
                            if (user != null)
                                contract.ContractManagerID = user.ObjectID;
                            else
                                throw new Exception("User with login name as " + contractManager + " does not exist");
                        }
                        else
                            throw new Exception("invalid login name");

                        OVendor contractVendor = TablesLogic.tVendor.Load(
                            TablesLogic.tVendor.ObjectName == vendor &
                            TablesLogic.tVendor.IsDeleted == 0);
                        if (contractVendor != null)
                        {
                            contract.VendorID = contractVendor.ObjectID;
                            SaveObject(contractVendor);
                        }
                        else
                            throw new Exception("invalid vendor");

                        contract.ContactPerson = contactPerson;
                        contract.ContactCellphone = contactCellphone;
                        contract.ContactPhone = contactPhone;
                        contract.ContactEmail = contactEmail;
                        contract.ContactFax = contactFax;

                        contract.ContractSum = contractSum;
                        contract.ContractStartDate = startDate;
                        contract.ContractEndDate = endDate;
                        contract.Terms = terms == null ? string.Empty : terms;
                        contract.Warranty = warranty == null ? string.Empty : warranty;
                        contract.Insurance = insurance == null ? string.Empty : insurance;

                        SaveObject(contract);
                        ActivateObject(contract);

                        if (contract.CurrentActivity.ObjectName != "InProgress")
                        {
                            contract.TriggerWorkflowEvent("Start");
                            contract.Save();
                        }
                    }
                    else
                        throw new Exception("Base Contract needs to be migrated successfully before migrating Extended Contract");
                }
                catch(Exception ex)
                {
                    dr[ERROR_MSG_COL] = ex.Message;
                }
            }
        }

        private string TrimInternalSpace(string number)
        {
            string result = "";
            string[] list = number.Trim().Split(' ');
            for (int i = 0; i < list.Length; i++)
            {
                result = string.Concat(result, list[i].Trim());
            }
            return result;
        }

        //to load an OLocation object specified by location full path.
        public static OLocation GetLocation(string locationPath)
        {
            bool check = true;
            OLocation location = null;
            string parentID = "";

            string[] list = locationPath.Trim().Split(',');

            for (int j = 0; j < list.Length; j++)
            {
                string listItem = list[j].Trim();
                if (check)
                {
                    if (parentID != null && parentID.ToString() != string.Empty)
                        location = TablesLogic.tLocation.Load(
                            TablesLogic.tLocation.ObjectName == listItem &
                            TablesLogic.tLocation.ParentID == new Guid(parentID) &
                            TablesLogic.tLocation.IsDeleted == 0);
                    else
                        location = TablesLogic.tLocation.Load(
                            TablesLogic.tLocation.ObjectName == listItem &
                            TablesLogic.tLocation.IsDeleted == 0);

                    if (location != null)
                        parentID = location.ObjectID.ToString();
                    else
                        check = false;
                }
                else
                    break;
            }
            return location;
        }

        /// <summary>
        /// to check whether the passed in location is in the location list that the contract covers.
        /// </summary>
        /// <param name="location"></param>
        /// <param name="contract"></param>
        /// <returns></returns>
        private bool CheckContractLocation(OLocation location, OContract contract)
        {
            foreach (OLocation loc in contract.Locations)
            {
                if (location.ObjectID == location.ObjectID)
                    return true;
            }
            return false;
        }

        //to load an OCode object specified by the full path of code
        public OCode GetTypeOfService(string tosPath)
        {
            bool check = true;
            OCode tos = null;
            string parentID = "";
            string[] list = tosPath.Trim().Split(',');
            
            for (int j = 0; j < list.Length; j++)
            {
                string listItem = list[j].Trim();
                if (check)
                {
                    if (parentID != null && parentID.ToString() != string.Empty)
                        tos = TablesLogic.tCode.Load(
                            TablesLogic.tCode.ObjectName == listItem &
                            TablesLogic.tCode.ParentID == new Guid(parentID) &
                            TablesLogic.tCode.IsDeleted == 0);
                    else
                        tos = TablesLogic.tCode.Load(
                            TablesLogic.tCode.ObjectName == listItem &
                            TablesLogic.tCode.IsDeleted == 0);
                
                    if (tos != null)
                        parentID = tos.ObjectID.ToString();
                    else
                        check=false;
                }
                else
                    break;
            }
            return tos;
        }
    }
}
