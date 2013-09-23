//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Data.Odbc;
using System.Data.Sql;
using System.Data.SqlClient;
using System.Text;
using System.Globalization;
using Anacle.DataFramework;

namespace LogicLayer
{
    //--------------------------------------------------------------------
    /// <summary>
    /// This is the Reports class that will be used by the Report 
    /// Builder to call methods within this class. 
    /// <para></para>
    /// All reports/dashboards that are to be exposed to the Report 
    /// Builder at the Web Application layer must declare one of the 
    /// following prototypes:
    /// <para></para>
    ///     public static DataTable ReportMethodName(ReportParameters 
    ///         parameters);
    /// <para></para>
    ///     public static DataSet ReportMethodName(ReportParameters 
    ///         parameters);
    /// 
    /// </summary>
    //--------------------------------------------------------------------
    public partial class Reports
    {

        /// <summary>
        /// method to return the expression condition to filter out those records that are not accessible to position's locations/equipments
        /// </summary>
        /// <param name="currentUserID"></param>
        /// <param name="roleNameCode">role code.</param>
        /// <param name="isLocation"> if this is true, it will be based on location, else equipment</param>
        /// <param name="hierarchyPathColumn">pass in the column to be built condition, forexample, TablesLogic.tContract.Locations.HierarchyPath</param>
        /// <returns></returns>
        public static ExpressionCondition GetAccessibleCondition(string currentUserID, bool isLocation, SchemaString hierarchyPathColumn, params string[] roleNameCode)
        {
            OUser user = TablesLogic.tUser.Load(new Guid(currentUserID));
            List<OPosition> positions = OPosition.GetPositionsByUserByRoleCode(user, roleNameCode);                

            if (positions != null && positions.Count > 0)
            { 
                foreach (OPosition position in positions)
                {
                    if (isLocation)
                    {
                        ExpressionCondition cond = null;
                        foreach (OLocation location in position.LocationAccess)
                        {
                            if (cond == null)
                                cond = hierarchyPathColumn.Like(location.HierarchyPath + "%");
                            else
                                cond = cond | hierarchyPathColumn.Like(location.HierarchyPath + "%");
                        }
                        return cond;
                    }
                    else
                    {
                        ExpressionCondition cond = null;
                        foreach (OEquipment equipment in position.EquipmentAccess)
                        {
                            if (cond == null)
                                cond = hierarchyPathColumn.Like(equipment.HierarchyPath + "%");
                            else
                                cond = cond | hierarchyPathColumn.Like(equipment.HierarchyPath + "%");
                        }
                        return cond;
                    }
                }                                
            }            
            return null;
        }

        

        /// <summary>
        /// list down all works with scheduled end date has passed current date and has not been closed within certain milestone
        /// </summary>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static DataTable GetWorkAgingReport(ReportParameters parameters)
        {
            ExpressionCondition basicCond = (parameters.GetString("TreeviewObject") == "LOCATION" || parameters.GetString("TreeviewObject") == "" ?
                                        (parameters.GetString("TreeviewID") == "" ? GetAccessibleCondition(parameters.GetString("UserID"),true, TablesLogic.tWork.Location.HierarchyPath,"") :
                                        TablesLogic.tWork.Location.HierarchyPath.Like(TablesLogic.tLocation.Load(new Guid(parameters.GetString("TreeviewID"))).HierarchyPath + "%")) :
                                        (parameters.GetString("TreeviewID") == "" ? GetAccessibleCondition(parameters.GetString("UserID"),true, TablesLogic.tWork.Equipment.HierarchyPath,"") :
                                        TablesLogic.tWork.Equipment.HierarchyPath.Like(TablesLogic.tEquipment.Load(new Guid(parameters.GetString("TreeviewID"))).HierarchyPath + "%")))
                                        & TablesLogic.tWork.CurrentActivity.ObjectName != "WORK_REJECTED" & TablesLogic.tWork.CurrentActivity.ObjectName != "WORK_CLOSED" & TablesLogic.tWork.IsDeleted == 0
                //for some works at certain status without type of service and type of work
                                        & TablesLogic.tWork.TypeOfWorkID != null & TablesLogic.tWork.TypeOfServiceID != null
                                        & (parameters.GetString("TypeOfWork") == "" ? Query.True : TablesLogic.tWork.TypeOfWorkID == parameters.GetString("TypeOfWork"))
                                        & (parameters.GetString("TypeofService") == "" ? Query.True : TablesLogic.tWork.TypeOfServiceID == parameters.GetString("TypeofService"));

            DataTable dt = TablesLogic.tWork.SelectDistinct(TablesLogic.tWork.TypeOfWorkID, TablesLogic.tWork.TypeOfWork.ObjectName.As("WorkType"), TablesLogic.tWork.TypeOfService.ObjectName.As("TypeofService"), TablesLogic.tWork.TypeOfServiceID)
                           .Where(TablesLogic.tWork.ScheduledEndDateTime != null & basicCond)
                           .OrderBy(TablesLogic.tWork.TypeOfWork.ObjectName.Asc, TablesLogic.tWork.TypeOfService.ObjectName.Asc);

            DataTable returnDt = new DataTable();
            returnDt.Columns.Add("WorkType");
            returnDt.Columns.Add("TypeofService");
            returnDt.Columns.Add("One", typeof(int));
            returnDt.Columns.Add("Two", typeof(int));
            returnDt.Columns.Add("Three", typeof(int));
            returnDt.Columns.Add("Four", typeof(int));
            returnDt.Columns.Add("FivePlus", typeof(int));


            // unclosed within one day
            DataTable oneday = TablesLogic.tWork.Select(TablesLogic.tWork.ObjectNumber.Count(), TablesLogic.tWork.TypeOfServiceID)
                               .Where(TablesLogic.tWork.ScheduledEndDateTime >= DateTime.Now.AddDays(-1) & TablesLogic.tWork.ScheduledEndDateTime <= DateTime.Now & basicCond)
                               .GroupBy(TablesLogic.tWork.TypeOfServiceID);

            // unclosed within two day
            DataTable twoDay = TablesLogic.tWork.Select(TablesLogic.tWork.ObjectNumber.Count(), TablesLogic.tWork.TypeOfServiceID)
                               .Where(TablesLogic.tWork.ScheduledEndDateTime >= DateTime.Now.AddDays(-2) & TablesLogic.tWork.ScheduledEndDateTime < DateTime.Now.AddDays(-1) & basicCond)
                               .GroupBy(TablesLogic.tWork.TypeOfServiceID); ;

            // unclosed within three day
            DataTable threeDay = TablesLogic.tWork.Select(TablesLogic.tWork.ObjectNumber.Count(), TablesLogic.tWork.TypeOfServiceID)
                                .Where(TablesLogic.tWork.ScheduledEndDateTime >= DateTime.Now.AddDays(-3) & TablesLogic.tWork.ScheduledEndDateTime < DateTime.Now.AddDays(-2) & basicCond)
                                .GroupBy(TablesLogic.tWork.TypeOfServiceID); ;
            //unclosed within four day
            DataTable fourDay = TablesLogic.tWork.Select(TablesLogic.tWork.ObjectNumber.Count(), TablesLogic.tWork.TypeOfServiceID)
                                .Where(TablesLogic.tWork.ScheduledEndDateTime >= DateTime.Now.AddDays(-4) & TablesLogic.tWork.ScheduledEndDateTime < DateTime.Now.AddDays(-3) & basicCond)
                                .GroupBy(TablesLogic.tWork.TypeOfServiceID); ;
            //all unclosed
            DataTable fivePlus = TablesLogic.tWork.Select(TablesLogic.tWork.ObjectNumber.Count(), TablesLogic.tWork.TypeOfServiceID)
                                .Where(TablesLogic.tWork.ScheduledEndDateTime < DateTime.Now.AddDays(-4) & basicCond)
                                .GroupBy(TablesLogic.tWork.TypeOfServiceID); ;

            foreach (DataRow row in dt.Rows)
            {
                int one = 0, two = 0, three = 0, four = 0, five = 0;
                //search for the correct type of service
                foreach (DataRow details in oneday.Rows)
                    if (details["TypeOfServiceID"].ToString() == row["TypeOfServiceID"].ToString() && details[0] != DBNull.Value)
                    {
                        one = (int)details[0];
                        break;
                    }

                foreach (DataRow details in twoDay.Rows)
                    if (details["TypeOfServiceID"].ToString() == row["TypeOfServiceID"].ToString() && details[0] != DBNull.Value)
                    {
                        two = (int)details[0];
                        break;
                    }

                foreach (DataRow details in threeDay.Rows)
                    if (details["TypeOfServiceID"].ToString() == row["TypeOfServiceID"].ToString() && details[0] != DBNull.Value)
                    {
                        three = (int)details[0];
                        break;
                    }

                foreach (DataRow details in fourDay.Rows)
                    if (details["TypeOfServiceID"].ToString() == row["TypeOfServiceID"].ToString() && details[0] != DBNull.Value)
                    {
                        four = (int)details[0];
                        break;
                    }

                foreach (DataRow details in fivePlus.Rows)
                    if (details["TypeOfServiceID"].ToString() == row["TypeOfServiceID"].ToString() && details[0] != DBNull.Value)
                    {
                        five = (int)details[0];
                        break;
                    }

                //to avoid default value case. Set it to 0
                returnDt.Rows.Add(new Object[] { row["WorkType"], row["TypeOfService"], one, two, three, four, five });
            }
            return returnDt;

        }

        /// <summary>
        /// Total number of works that complies with the SLA, group by type of service. Only applicable for work with SLA applied to
        /// </summary>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static DataTable GetWorkComplianceReport(ReportParameters parameters)
        {
            ExpressionCondition basicCond = (parameters.GetString("TreeviewObject") == "LOCATION" || parameters.GetString("TreeviewObject") == "" ?
                                        (parameters.GetString("TreeviewID") == "" ? GetAccessibleCondition(parameters.GetString("UserID"), true, TablesLogic.tWork.Location.HierarchyPath, "") :
                                        TablesLogic.tWork.Location.HierarchyPath.Like(TablesLogic.tLocation.Load(new Guid(parameters.GetString("TreeviewID"))).HierarchyPath + "%")) :
                                        (parameters.GetString("TreeviewID") == "" ? GetAccessibleCondition(parameters.GetString("UserID"), true, TablesLogic.tWork.Equipment.HierarchyPath, "") :
                                        TablesLogic.tWork.Equipment.HierarchyPath.Like(TablesLogic.tEquipment.Load(new Guid(parameters.GetString("TreeviewID"))).HierarchyPath + "%")))
                                        & TablesLogic.tWork.CurrentActivity.ObjectName != "WORK_REJECTED" & TablesLogic.tWork.IsDeleted == 0
                //for some works at certain status without type of service and type of work
                                        & TablesLogic.tWork.TypeOfWorkID != null & TablesLogic.tWork.TypeOfServiceID != null
                                         & (parameters.GetString("TypeOfWork") == "" ? Query.True : TablesLogic.tWork.TypeOfWorkID == parameters.GetString("TypeOfWork"))
                                        & (parameters.GetString("TypeofService") == "" ? Query.True : TablesLogic.tWork.TypeOfServiceID == parameters.GetString("TypeofService"));

            //retrieve all work with SLA
            DataTable allWork = TablesLogic.tWork.Select(TablesLogic.tWork.TypeOfServiceID, TablesLogic.tWork.TypeOfService.ObjectName.As("TypeOfService"),
                                    TablesLogic.tWork.TypeOfWork.ObjectName.As("TypeOfWork"),
                                    TablesLogic.tWork.AcknowledgementDateTimeLimit.Count().As("TotalAck"),
                                    TablesLogic.tWork.ArrivalDateTimeLimit.Count().As("TotalArr"), TablesLogic.tWork.CompletionDateTimeLimit.Count().As("TotalComp"))
                                .Where(basicCond
                //the work must have SLA tied to
                                & (TablesLogic.tWork.AcknowledgementDateTimeLimit != null | TablesLogic.tWork.ArrivalDateTimeLimit != null | TablesLogic.tWork.CompletionDateTimeLimit != null))
                                .GroupBy(TablesLogic.tWork.TypeOfServiceID, TablesLogic.tWork.TypeOfService.ObjectName, TablesLogic.tWork.TypeOfWork.ObjectName)
                                .OrderBy(TablesLogic.tWork.TypeOfService.ObjectName.Asc);

            //Number of cases meeting the acknowledgement SLA
            DataTable ack = TablesLogic.tWork.Select(TablesLogic.tWork.TypeOfServiceID, TablesLogic.tWork.AcknowledgementDateTime.Count().As("Ack"))
                                .Where(basicCond
                //AcknowledgementDateTime <= AcknowledgementDateTimeLimit
                                & (TablesLogic.tWork.AcknowledgementDateTime <= TablesLogic.tWork.AcknowledgementDateTimeLimit))
                                .GroupBy(TablesLogic.tWork.TypeOfServiceID);

            //Number of cases meeting the arrival SLA
            DataTable arr = TablesLogic.tWork.Select(TablesLogic.tWork.TypeOfServiceID, TablesLogic.tWork.ArrivalDateTime.Count().As("Arr"))
                                .Where(basicCond
                                & (TablesLogic.tWork.ArrivalDateTime <= TablesLogic.tWork.ArrivalDateTimeLimit))
                                .GroupBy(TablesLogic.tWork.TypeOfServiceID);

            //Number of cases meeting the complete SLA
            DataTable comp = TablesLogic.tWork.Select(TablesLogic.tWork.TypeOfServiceID, TablesLogic.tWork.ActualEndDateTime.Count().As("Comp"))
                                .Where(basicCond
                                & (TablesLogic.tWork.ActualEndDateTime <= TablesLogic.tWork.CompletionDateTimeLimit))
                                .GroupBy(TablesLogic.tWork.TypeOfServiceID);

            DataTable returnDt = new DataTable();
            returnDt.Columns.Add("TypeOfService");
            returnDt.Columns.Add("TypeOfWork");
            returnDt.Columns.Add("AckPerc", typeof(decimal));
            returnDt.Columns.Add("ArrPerc", typeof(decimal));
            returnDt.Columns.Add("CompPerc", typeof(decimal));

            foreach (DataRow row in allWork.Rows)
            {
                decimal totalAckWork = Convert.ToDecimal(row["TotalAck"].ToString());
                decimal totalArrWork = Convert.ToDecimal(row["TotalArr"].ToString());
                decimal totalCompWork = Convert.ToDecimal(row["TotalComp"].ToString());



                DataRow returnRow = returnDt.NewRow();
                returnRow["TypeOfService"] = row["TypeOfService"];
                returnRow["TypeOfWork"] = row["TypeOfWork"];
                //default percentage to 0
                returnRow["ArrPerc"] = 0.0M;
                returnRow["AckPerc"] = 0.0M;
                returnRow["CompPerc"] = 0.0M;


                foreach (DataRow details in ack.Rows)
                    if (details["TypeOfServiceID"].ToString() == row["TypeOfServiceID"].ToString())
                    {
                        returnRow["AckPerc"] = (Convert.ToDecimal(details[1].ToString()) / totalAckWork) * 100;
                        break;
                    }
                foreach (DataRow details in arr.Rows)
                    if (details["TypeOfServiceID"].ToString() == row["TypeOfServiceID"].ToString())
                    {
                        returnRow["ArrPerc"] = (Convert.ToDecimal(details[1].ToString()) / totalArrWork) * 100;
                        break;
                    }

                foreach (DataRow details in arr.Rows)
                    if (details["TypeOfServiceID"].ToString() == row["TypeOfServiceID"].ToString())
                    {
                        returnRow["CompPerc"] = (Convert.ToDecimal(details[1].ToString()) / totalCompWork) * 100;
                        break;
                    }

                returnDt.Rows.Add(returnRow);
            }
            return returnDt;
        }

        public static DataTable GetVendorReport(ReportParameters parameters)
        {
            DataTable dtReturn = new DataTable();
            dtReturn.Columns.Add("Vendor Name", typeof(string));
            dtReturn.Columns.Add("Vendor Type", typeof(string));
            dtReturn.Columns.Add("Vendor Classification", typeof(string));
            dtReturn.Columns.Add("Operation Address", typeof(string));
            dtReturn.Columns.Add("Operation Cellphone", typeof(string));
            dtReturn.Columns.Add("Operation Email", typeof(string));
            dtReturn.Columns.Add("Operation Phone", typeof(string));
            dtReturn.Columns.Add("Operation Contact Person", typeof(string));
            dtReturn.Columns.Add("Debarred", typeof(string));
            dtReturn.Columns.Add("Debarment Start", typeof(DateTime));
            dtReturn.Columns["Debarment Start"].ExtendedProperties["DataFormatString"] = "{0:dd-MMM-yyyy}";
            dtReturn.Columns.Add("Debarment End", typeof(DateTime));
            dtReturn.Columns["Debarment End"].ExtendedProperties["DataFormatString"] = "{0:dd-MMM-yyyy}";
            dtReturn.Columns.Add("Billing Location Contact Person", typeof(string));
            dtReturn.Columns.Add("Billing Location Address", typeof(string));
            dtReturn.Columns.Add("Billing Location Phone", typeof(string));
            dtReturn.Columns.Add("Billing Location Country", typeof(string));
            dtReturn.Columns.Add("Billing Location State", typeof(string));
            dtReturn.Columns.Add("Billing Location City", typeof(string));
            dtReturn.Columns.Add("Billing Location Cellphone", typeof(string));
            dtReturn.Columns.Add("Billing Location Email", typeof(string));
            dtReturn.Columns.Add("Billing Location Fax", typeof(string));
            dtReturn.Columns.Add("Operation Location Country", typeof(string));
            dtReturn.Columns.Add("Operation Location State", typeof(string));
            dtReturn.Columns.Add("Operating Location City", typeof(string));
            dtReturn.Columns.Add("Operation Location Fax", typeof(string));

            DataTable dt = TablesLogic.tVendor.SelectDistinct(
                    TablesLogic.tVendor.ObjectID,
                    TablesLogic.tVendor.ObjectName,
                    TablesLogic.tVendor.VendorClassification.ObjectName.As("VendorClassification"),
                    TablesLogic.tVendor.OperatingAddress,
                    TablesLogic.tVendor.OperatingCellPhone,
                    TablesLogic.tVendor.OperatingEmail,
                    TablesLogic.tVendor.OperatingPhone,
                    TablesLogic.tVendor.OperatingContactPerson,
                    TablesLogic.tVendor.IsDebarred,
                    TablesLogic.tVendor.DebarmentStartDate,
                    TablesLogic.tVendor.DebarmentEndDate,
                    TablesLogic.tVendor.BillingContactPerson,
                    TablesLogic.tVendor.BillingAddress,
                    TablesLogic.tVendor.BillingPhone,
                    TablesLogic.tVendor.BillingAddressCountry,
                    TablesLogic.tVendor.BillingAddressState,
                    TablesLogic.tVendor.BillingAddressCity,
                    TablesLogic.tVendor.BillingCellPhone,
                    TablesLogic.tVendor.BillingEmail,
                    TablesLogic.tVendor.BillingFax,
                    TablesLogic.tVendor.OperatingAddressCountry,
                    TablesLogic.tVendor.OperatingAddressState,
                    TablesLogic.tVendor.OperatingAddressCity,
                    TablesLogic.tVendor.OperatingFax)
                    .Where(
                    TablesLogic.tVendor.IsDeleted == 0
                    & (parameters.GetString("FILTER_DEBARRED") == "" ? Query.True : TablesLogic.tVendor.IsDebarred == parameters.GetString("FILTER_DEBARRED"))
                    & (parameters.GetString("FILTER_DEBARMENTSTARTFROM") == "" ? Query.True : TablesLogic.tVendor.DebarmentStartDate >= parameters.GetDateTime("FILTER_DEBARMENTSTARTFROM"))
                    & (parameters.GetString("FILTER_DEBARMENTSTARTTO") == "" ? Query.True : TablesLogic.tVendor.DebarmentStartDate <= parameters.GetDateTime("FILTER_DEBARMENTSTARTTO"))
                    & (parameters.GetString("FILTER_DEBARMENTENDFROM") == "" ? Query.True : TablesLogic.tVendor.DebarmentEndDate >= parameters.GetDateTime("FILTER_DEBARMENTENDFROM"))
                    & (parameters.GetString("FILTER_DEBARMENTENDTO") == "" ? Query.True : TablesLogic.tVendor.DebarmentEndDate <= parameters.GetDateTime("FILTER_DEBARMENTENDTO"))
                    & TablesLogic.tVendor.OperatingAddress.Like("%" + parameters.GetString("FILTER_OPERATIONADDRESS") + "%")
                    & TablesLogic.tVendor.BillingAddress.Like("%" + parameters.GetString("FILTER_BILLINGADDRESS") + "%")
                    & TablesLogic.tVendor.ObjectName.Like("%" + parameters.GetString("FILTER_VENDORNAME") + "%")
                    & (parameters.GetString("FILTER_VENDORTYPE") == "" ? Query.True : TablesLogic.tVendor.VendorTypes.ObjectID == parameters.GetString("FILTER_VENDORTYPE"))
                    & (parameters.GetString("FILTER_VENDORCLASSIFICATION") == "" ? Query.True : TablesLogic.tVendor.VendorClassificationID == parameters.GetString("FILTER_VENDORCLASSIFICATION"))
                   );

            foreach (DataRow row in dt.Rows)
            {
                DataRow returnRow = dtReturn.NewRow();
                returnRow["Vendor Name"] = row["ObjectName"];
                returnRow["Vendor Classification"] = row["VendorClassification"];
                returnRow["Operation Address"] = row["OperatingAddress"];
                returnRow["Operation Cellphone"] = row["OperatingCellPhone"];
                returnRow["Operation Email"] = row["OperatingEmail"];
                returnRow["Operation Phone"] = row["OperatingPhone"];
                returnRow["Operation Contact Person"] = row["OperatingContactPerson"];
                if (row["IsDebarred"].ToString() == "1")
                    returnRow["Debarred"] = "Yes";
                if (row["IsDebarred"].ToString() == "0")
                    returnRow["Debarred"] = "No";
                returnRow["Debarment Start"] = row["DebarmentStartDate"];
                returnRow["Debarment End"] = row["DebarmentEndDate"];
                returnRow["Billing Location Contact Person"] = row["BillingContactPerson"];
                returnRow["Billing Location Address"] = row["BillingAddress"];
                returnRow["Billing Location Phone"] = row["BillingPhone"];
                returnRow["Billing Location Country"] = row["BillingAddressCountry"];
                returnRow["Billing Location State"] = row["BillingAddressState"];
                returnRow["Billing Location City"] = row["BillingAddressCity"];
                returnRow["Billing Location Cellphone"] = row["BillingCellPhone"];
                returnRow["Billing Location Email"] = row["BillingEmail"];
                returnRow["Billing Location Fax"] = row["BillingFax"];
                returnRow["Operation Location Country"] = row["OperatingAddressCountry"];
                returnRow["Operation Location State"] = row["OperatingAddressState"];
                returnRow["Operating Location City"] = row["OperatingAddressCity"];
                returnRow["Operation Location Fax"] = row["OperatingFax"];

                OVendor vendortype = TablesLogic.tVendor[new Guid(row["ObjectID"].ToString())];

                string vendortypestring = "";
                foreach (OCode codename in vendortype.VendorTypes)
                {
                    vendortypestring = vendortypestring + codename.ObjectName + ", ";
                }
                if(vendortypestring != "")
                    returnRow["Vendor Type"] = vendortypestring.Remove(vendortypestring.Length - 2);

                dtReturn.Rows.Add(returnRow);
            }
            return dtReturn;
        }

        public static DataTable GetContractReport(ReportParameters parameters)
        {
            DataTable dtReturn = new DataTable();
            dtReturn.Columns.Add("Contract Name", typeof(string));
            dtReturn.Columns["Contract Name"].ExtendedProperties["Width"] = "500px";
            dtReturn.Columns.Add("Contract Description", typeof(string));
            dtReturn.Columns["Contract Description"].ExtendedProperties["Width"] = "500px";
            dtReturn.Columns.Add("Contract Start Date", typeof(DateTime));
            dtReturn.Columns["Contract Start Date"].ExtendedProperties["DataFormatString"] = "{0:dd-MMM-yyyy}";
            dtReturn.Columns.Add("Contract End Date", typeof(DateTime));
            dtReturn.Columns["Contract End Date"].ExtendedProperties["DataFormatString"] = "{0:dd-MMM-yyyy}";
            dtReturn.Columns.Add("Contract Terms", typeof(string));
            dtReturn.Columns.Add("Contract Warranty", typeof(string));
            dtReturn.Columns.Add("Contract Sum($)", typeof(decimal));
            dtReturn.Columns.Add("Contract Manager", typeof(string));
            dtReturn.Columns.Add("Contact Person Name", typeof(string));
            dtReturn.Columns.Add("Contact Person Cellphone", typeof(string));
            dtReturn.Columns.Add("Contact Person Email", typeof(string));
            dtReturn.Columns.Add("Provide Adhoc Maintenance", typeof(string));
            dtReturn.Columns.Add("Locations", typeof(string));
            dtReturn.Columns["Locations"].ExtendedProperties["Width"] = "500px";
            dtReturn.Columns.Add("Type of Services", typeof(string));
            dtReturn.Columns["Type of Services"].ExtendedProperties["Width"] = "500px";
            dtReturn.Columns.Add("Provide Purchasing Agreement", typeof(string));
            dtReturn.Columns.Add("Materials Agreement", typeof(string));
            dtReturn.Columns["Materials Agreement"].ExtendedProperties["Width"] = "500px";
            dtReturn.Columns.Add("Service Agreement", typeof(string));
            dtReturn.Columns["Service Agreement"].ExtendedProperties["Width"] = "800px";
            dtReturn.Columns.Add("Vendor Name", typeof(string));
            dtReturn.Columns.Add("Vendor Type", typeof(string));
            dtReturn.Columns.Add("Vendor Classification", typeof(string));


            dtReturn.Columns.Add("Contact Person Fax", typeof(string));
            dtReturn.Columns.Add("Contact Person Phone", typeof(string));
            dtReturn.Columns.Add("Person 1 To Remind", typeof(string));
            dtReturn.Columns.Add("Person 2 To Remind", typeof(string));
            dtReturn.Columns.Add("Person 3 To Remind", typeof(string));
            dtReturn.Columns.Add("Person 4 To Remind", typeof(string));

            dtReturn.Columns.Add("Reminder Days 1", typeof(int));
            dtReturn.Columns.Add("Reminder Days 2", typeof(int));
            dtReturn.Columns.Add("Reminder Days 3", typeof(int));
            dtReturn.Columns.Add("Reminder Days 4", typeof(int));

            ExpressionCondition cond = GetAccessibleCondition(parameters.GetString("UserID"),true, TablesLogic.tContract.Locations.HierarchyPath, "");
            if (cond == null)
                cond = Query.False;

            DataTable dt = TablesLogic.tContract.SelectDistinct(TablesLogic.tContract.ObjectID,
                                TablesLogic.tContract.ObjectName,
                                TablesLogic.tContract.Description,
                                TablesLogic.tContract.ContractStartDate,
                                TablesLogic.tContract.ContractEndDate,
                                TablesLogic.tContract.Terms,
                                TablesLogic.tContract.Warranty,
                                TablesLogic.tContract.ContractSum,
                                TablesLogic.tContract.ContractManager.ObjectName.As("Manager"),
                                TablesLogic.tContract.ContactPerson,
                                TablesLogic.tContract.ContactCellphone,
                                TablesLogic.tContract.ContactPhone,
                                TablesLogic.tContract.ContactEmail,
                                TablesLogic.tContract.ContactFax,
                                TablesLogic.tContract.Reminder1User.ObjectName.As("User1"),
                                TablesLogic.tContract.Reminder2User.ObjectName.As("User2"),
                                TablesLogic.tContract.Reminder3User.ObjectName.As("User3"),
                                TablesLogic.tContract.Reminder4User.ObjectName.As("User4"),
                                TablesLogic.tContract.EndReminderDays1,
                                TablesLogic.tContract.EndReminderDays2,
                                TablesLogic.tContract.EndReminderDays3,
                                TablesLogic.tContract.EndReminderDays4,
                                TablesLogic.tContract.Vendor.ObjectName.As("Vendor"),
                                TablesLogic.tContract.Vendor.VendorClassification.ObjectName.As("VendorClassification"),
                                TablesLogic.tContract.ProvideMaintenance,
                                TablesLogic.tContract.ProvidePricingAgreement)
                        .Where(TablesLogic.tContract.IsDeleted == 0
                        & TablesLogic.tContract.ObjectName.Like("%" + parameters.GetString("FILTER_CONTRACTNAME") + "%")
                        & TablesLogic.tContract.Description.Like("%" + parameters.GetString("FILTER_DESCRIPTION") + "%")
                        & TablesLogic.tContract.Terms.Like("%" + parameters.GetString("FILTER_TERMS") + "%")
                         & TablesLogic.tContract.Insurance.Like("%" + parameters.GetString("FILTER_INSURANTCE") + "%")
                        & TablesLogic.tContract.Warranty.Like("%" + parameters.GetString("FILTER_WARRANTY") + "%")
                        & TablesLogic.tContract.Vendor.ObjectName.Like("%" + parameters.GetString("FILTER_VENDORNAME") + "%")
                        & (parameters.GetString("FILTER_CONTRACTSTARTFROM") == "" ? Query.True :
                            TablesLogic.tContract.ContractStartDate >= parameters.GetDateTime("FILTER_CONTRACTSTARTFROM"))
                         & (parameters.GetString("FILTER_CONTRACTSTARTTO") == "" ? Query.True :
                            TablesLogic.tContract.ContractStartDate < parameters.GetDateTime("FILTER_CONTRACTSTARTTO").Value.AddDays(1))
                        & (parameters.GetString("FILTER_CONTRACTENDFROM") == "" ? Query.True :
                            TablesLogic.tContract.ContractEndDate >= parameters.GetDateTime("FILTER_CONTRACTENDFROM"))
                         & (parameters.GetString("FILTER_CONTRACTENDTO") == "" ? Query.True :
                            TablesLogic.tContract.ContractEndDate < parameters.GetDateTime("FILTER_CONTRACTENDTO").Value.AddDays(1))
                         & (parameters.GetString("FILTER_CONTRACTSUMFROM") == "" ? Query.True :
                            TablesLogic.tContract.ContractSum >= parameters.GetDecimal("FILTER_CONTRACTSUMFROM"))
                        & (parameters.GetString("FILTER_CONTRACTSUMTO") == "" ? Query.True :
                           TablesLogic.tContract.ContractSum <= parameters.GetDecimal("FILTER_CONTRACTSUMTO"))
                        & (parameters.GetString("TreeviewID") == "" ? cond :
                            TablesLogic.tContract.Locations.HierarchyPath.Like(TablesLogic.tLocation.Load(new Guid(parameters.GetString("TreeviewID"))).HierarchyPath + "%"))
                        & (parameters.GetString("FILTER_CONTRACTEXPIRED") == "" ? Query.True :
                            TablesLogic.tContract.ContractEndDate <= DateTime.Now.AddMonths(parameters.GetInteger("FILTER_CONTRACTEXPIRED").Value))
                        & (parameters.GetString("FILTER_SHOWCLOSEDCONTRACT") == "" ? TablesLogic.tContract.CurrentActivity.ObjectName != "CONTRACT_CLOSED" :
                            Query.True)
                        & (parameters.GetString("FILTER_VENDORTYPE") == "" ? Query.True : TablesLogic.tContract.Vendor.VendorTypes.ObjectID == parameters.GetString("FILTER_VENDORTYPE"))
                        & (parameters.GetString("FILTER_VENDORCLASSIFICATION") == "" ? Query.True : TablesLogic.tContract.Vendor.VendorClassificationID == parameters.GetString("FILTER_VENDORCLASSIFICATION")));

            foreach (DataRow row in dt.Rows)
            {
                DataRow returnRow = dtReturn.NewRow();
                returnRow["Contract Name"] = row["ObjectName"];
                returnRow["Contract Description"] = row["Description"];
                returnRow["Contract Start Date"] = row["ContractStartDate"];
                returnRow["Contract End Date"] = row["ContractEndDate"];
                returnRow["Contract Terms"] = row["Terms"];
                returnRow["Contract Warranty"] = row["Warranty"];
                returnRow["Contract Sum($)"] = row["ContractSum"];
                returnRow["Contract Manager"] = row["Manager"];
                returnRow["Contact Person Name"] = row["ContactPerson"];
                returnRow["Contact Person Cellphone"] = row["ContactCellphone"];
                returnRow["Contact Person Email"] = row["ContactEmail"];


                returnRow["Contact Person Fax"] = row["ContactFax"];
                returnRow["Contact Person Phone"] = row["ContactPhone"];
                returnRow["Person 1 To Remind"] = row["User1"];
                returnRow["Person 2 To Remind"] = row["User2"];
                returnRow["Person 3 To Remind"] = row["User3"];
                returnRow["Person 4 To Remind"] = row["User4"];

                returnRow["Reminder Days 1"] = row["EndReminderDays1"];
                returnRow["Reminder Days 2"] = row["EndReminderDays2"];
                returnRow["Reminder Days 3"] = row["EndReminderDays3"];
                returnRow["Reminder Days 4"] = row["EndReminderDays4"];
                returnRow["Vendor Name"] = row["Vendor"];
                returnRow["Vendor Classification"] = row["VendorClassification"];

               
                OContract contract = TablesLogic.tContract[new Guid(row["ObjectID"].ToString())];


                string vendortypestring = "";
                foreach (OCode codename in contract.Vendor.VendorTypes)
                {
                    vendortypestring = vendortypestring + codename.ObjectName + ", ";
                }
                if (vendortypestring != "")
                    returnRow["Vendor Type"] = vendortypestring.Remove(vendortypestring.Length - 2);


                //Retrieve all locations, type of services,. of the contract
                if (row["ProvideMaintenance"] != DBNull.Value && row["ProvideMaintenance"].ToString() == "1")
                {
                    returnRow["Provide Adhoc Maintenance"] = Resources.Strings.General_Yes;

                    string locations = "";
                    foreach (OLocation loc in contract.Locations)
                    {
                        if (locations == "")
                            locations = loc.Path;
                        else
                            locations += ", " + loc.Path;
                    }
                    returnRow["Locations"] = locations;

                    string services = "";
                    foreach (OCode code in contract.TypeOfServices)
                    {
                        if (services == "")
                            services = code.Path;
                        else
                            services += ", " + code.Path;
                    }
                    returnRow["Type of Services"] = services;
                }
                else
                    returnRow["Provide Adhoc Maintenance"] = Resources.Strings.General_No;

                if (row["ProvidePricingAgreement"] != DBNull.Value && row["ProvidePricingAgreement"].ToString() == "1")
                {
                    returnRow["Provide Purchasing Agreement"] = Resources.Strings.General_Yes;
                    string materials = "";
                    foreach (OContractPriceMaterial contractMat in contract.ContractPriceMaterials)
                    {
                        if (materials == "")
                            materials = contractMat.Catalogue.Path;
                        else
                            materials += ", " + contractMat.Catalogue.Path;
                    }
                    returnRow["Materials Agreement"] = materials;

                    string services = "";
                    foreach (OContractPriceService contractSev in contract.ContractPriceServices)
                    {
                        if (services == "")
                            services = contractSev.FixedRate.Path;
                        else
                            services += ", " + contractSev.FixedRate.Path;
                    }
                    returnRow["Service Agreement"] = services;
                }
                else
                    returnRow["Provide Purchasing Agreement"] = Resources.Strings.General_No;

                dtReturn.Rows.Add(returnRow);
            }
            return dtReturn;



        }

        public static decimal GetLocationTotalGFA(OLocation loc)
        {
            decimal totalGFA = 0;
            if (loc.IsPhysicalLocation == 1)
            {
                if (loc.GrossFloorArea != null)
                    totalGFA = loc.GrossFloorArea.Value;
            }
            else
            {
                List<OLocation> locationList = TablesLogic.tLocation[TablesLogic.tLocation.ParentID == loc.ObjectID];
                foreach (OLocation location in locationList)
                    totalGFA += GetLocationTotalGFA(location);
            }
            return totalGFA;

            TWork w1 = new TWork();
            TWork w2 = new TWork();

            w1.Select(
                w1.ObjectID)
            .Where(
                w2.Select(w2.ObjectID.Count()).Where(w2.ParentID==w1.ObjectID) == 0
            );

        }

       
        #region Survey Report

        /// <summary>
        /// Datatable for Report that return AverageRatingReport        
        /// </summary>
        /// <returns>DataTable</returns>
        public static DataTable AverageRatingReport(ReportParameters parameters)
        {
            string F_SurveyGroupID = "";
            string F_EvaluatedPartyID = "";
            string F_SurveyPlannerIDs = "";
            if (parameters.GetString("F_SurveyGroupID") != "")
                F_SurveyGroupID = parameters.GetString("F_SurveyGroupID");
            if (parameters.GetString("F_EvaluatedPartyID") != "")
                F_EvaluatedPartyID = parameters.GetString("F_EvaluatedPartyID");
            if (parameters.GetList("F_SurveyPlannerIDs").Count > 0)
            {
                F_SurveyPlannerIDs = "(";
                for (int i = 0; i < parameters.GetList("F_SurveyPlannerIDs").Count; i++)
                {
                    if (i == ((parameters.GetList("F_SurveyPlannerIDs").Count) - 1))
                        F_SurveyPlannerIDs += "'" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "')";
                    else
                        F_SurveyPlannerIDs += "'" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "',";
                }
            }

            if (F_SurveyPlannerIDs == "" || F_SurveyGroupID == "")
            {
                DataTable ErrorDT = new DataTable();
                ErrorDT.Columns.Add("Error Message");
                ErrorDT.Rows.Add(new Object[] { "Please select all filters in order to generate the report correctly." });
                return ErrorDT;
            }

            DataSet dts = Connection.ExecuteQuery("#database",
                @"
select
*,
	cast(case when t2.totalexpectedrespondent = 0
		then 0
		else 100*cast(t2.numberofrespondent as decimal(19,2))/cast(t2.totalexpectedrespondent as decimal(19,2))
		end as decimal(19,2))
as percentage
from
(
	select
	*,
		isnull(
			(select
			count(scicr.checklistresponseid)
			from 
			surveychecklistitemchecklistresponse scicr 
			where
			scicr.checklistresponseid = t1.cr_objectid
			and scicr.surveychecklistitemid = t1.sci_objectid)
		,0)
	as isselected,
		isnull(
			(select
			count(scicr.checklistresponseid)
			from 
			surveychecklistitemchecklistresponse scicr 
			where
			scicr.checklistresponseid = t1.cr_objectid
			and scicr.surveychecklistitemid in
				(select objectid from surveychecklistitem sci
				where sci.isdeleted = 0
				and sci.surveyplannerid = sp_objectid
                and ((sci.evaluatedpartyname = t1.evaluatedname and sci.evaluatedpartyid is null) or 
                    ((sci.evaluatedpartyname <> t1.evaluatedname or sci.evaluatedpartyname is null) and sci.evaluatedpartyid = t1.evaluatedpartyid and sci.evaluatedpartyid is not null))
                and sci.isoverall = 1
				and sci.checklistitemtype = 0)
			group by
			scicr.checklistresponseid)
		,0)
	as numberofrespondent,
		(select count(objectid) from surveychecklistitem sci
		where sci.isdeleted = 0
		and sci.surveyplannerid = sp_objectid
        and ((sci.evaluatedpartyname = t1.evaluatedname and sci.evaluatedpartyid is null) or 
            ((sci.evaluatedpartyname <> t1.evaluatedname or sci.evaluatedpartyname is null) and sci.evaluatedpartyid = t1.evaluatedpartyid and sci.evaluatedpartyid is not null))
        and sci.isoverall = 1
		and sci.checklistitemtype = 0)
	as totalexpectedrespondent
	from
	(
		select
			sci.objectid
		as sci_objectid,
			sci.objectname 
		as sci_objectname,
			cr.objectid 
		as cr_objectid,
			cr.scorenumerator 
		as cr_scorenumerator,
			cr.objectname 
		as cr_objectname,
			case when srt.contractmandatory = 0 then sci.evaluatedpartyname
				else v.objectname
			end 
		as evaluatedname,
            sci.evaluatedpartyid
        as evaluatedpartyid,
			sp.objectid
		as sp_objectid,
			sp.performanceperiodfrom
		as sp_performanceperiodfrom
		from
		[surveychecklistitem] sci
		left join [surveyplanner] sp on (sp.isdeleted = 0 and sci.surveyplannerid = sp.objectid)
		left join [surveyresponseto] srt on (srt.isdeleted = 0 and sci.surveyresponsetoid = srt.objectid)
		left join [surveytrade] st on (st.isdeleted = 0 and srt.surveytradeid = st.objectid)
		left join [checklistresponseset] crs on (crs.isdeleted = 0 and sci.checklistresponsesetid = crs.objectid)
		left join [checklistresponse] cr on (cr.isdeleted = 0 and cr.checklistresponsesetid = crs.objectid)
		left join [contract] c on (c.isdeleted = 0 and srt.contractid = c.objectid)
		left join [vendor] v on (v.isdeleted = 0 and c.vendorid = v.objectid)
		where
		sci.isdeleted = 0
		and sci.surveyplannerid in " + F_SurveyPlannerIDs + @"
		and sci.checklistitemtype = 0
        and sci.isoverall = 1
		and st.surveygroupid = '" + F_SurveyGroupID + @"'
		and (('" + F_EvaluatedPartyID + @"' = '' and srt.contractmandatory = 0) or ('" + F_EvaluatedPartyID + @"' <> '' and sci.evaluatedpartyid = '" + F_EvaluatedPartyID + @"'))
		group by sci.objectid,sci.objectname,cr.objectid,cr.scorenumerator,cr.objectname,sci.evaluatedpartyname,sci.evaluatedpartyid,v.objectname,srt.contractmandatory,sp.objectid,sp.performanceperiodfrom
	) t1
) t2
order by t2.sp_performanceperiodfrom,t2.sp_objectid,t2.sci_objectname asc
"
                );


            if (dts.Tables.Count > 0 && dts.Tables[0].Rows.Count > 0)
            {
                return dts.Tables[0];
            }
            else
            {
                DataTable ErrorDT = new DataTable();
                ErrorDT.Columns.Add("Error Message");
                ErrorDT.Rows.Add(new Object[] { "Query returns zero table." });
                return ErrorDT;
            }

        }

        /// <summary>
        /// Datatable for Report that return OverallSatisfactionReport        
        /// </summary>
        /// <returns>DataTable</returns>
        public static DataSet OverallSatisfactionReport(ReportParameters parameters)
        {
            string F_SurveyGroupID = "";
            string F_EvaluatedPartyID = "";
            string F_SurveyPlannerIDs = "";
            if (parameters.GetString("F_SurveyGroupID") != "")
                F_SurveyGroupID = parameters.GetString("F_SurveyGroupID");
            if (parameters.GetString("F_EvaluatedPartyID") != "")
                F_EvaluatedPartyID = parameters.GetString("F_EvaluatedPartyID");
            if (parameters.GetList("F_SurveyPlannerIDs").Count > 0)
            {
                F_SurveyPlannerIDs = "(";
                for (int i = 0; i < parameters.GetList("F_SurveyPlannerIDs").Count; i++)
                {
                    if (i == ((parameters.GetList("F_SurveyPlannerIDs").Count) - 1))
                        F_SurveyPlannerIDs += "'" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "')";
                    else
                        F_SurveyPlannerIDs += "'" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "',";
                }
            }

            if (F_SurveyPlannerIDs == "" || F_SurveyGroupID == "")
            {
                DataSet ds = new DataSet();
                DataTable ErrorDT = new DataTable();
                ErrorDT.Columns.Add("Error Message");
                ErrorDT.Rows.Add(new Object[] { "Please select all filters in order to generate the report correctly." });
                ds.Tables.Add(ErrorDT);
                ds.Tables.Add(new DataTable());
                return ds;
            }

            DataSet dts = Connection.ExecuteQuery("#database",
                @"
select
*,
	cast(case when t2.totalexpectedrespondent = 0
		then 0
		else 100*cast(t2.numberofrespondent as decimal(19,2))/cast(t2.totalexpectedrespondent as decimal(19,2))
		end as decimal(19,2))
as percentage,
1 as orderpriority
from
(
	select
	*,
		isnull(
			(select
			count(scicr.checklistresponseid)
			from 
			surveychecklistitemchecklistresponse scicr 
			where
			scicr.checklistresponseid = t1.cr_objectid
			and scicr.surveychecklistitemid in
				(select objectid from surveychecklistitem sci
				where sci.isdeleted = 0
                and ((sci.evaluatedpartyname = t1.evaluatedname and sci.evaluatedpartyid is null) or 
                    ((sci.evaluatedpartyname <> t1.evaluatedname or sci.evaluatedpartyname is null) and sci.evaluatedpartyid = t1.evaluatedpartyid and sci.evaluatedpartyid is not null))
				and sci.surveyplannerid = t1.sp_objectid
                and sci.isoverall = 1)
			group by
			scicr.checklistresponseid)
		,0)
	as numberofrespondent,
		(select count(objectid) from surveychecklistitem sci
		where sci.isdeleted = 0
        and ((sci.evaluatedpartyname = t1.evaluatedname and sci.evaluatedpartyid is null) or 
            ((sci.evaluatedpartyname <> t1.evaluatedname or sci.evaluatedpartyname is null) and sci.evaluatedpartyid = t1.evaluatedpartyid and sci.evaluatedpartyid is not null))
		and sci.surveyplannerid = t1.sp_objectid
        and sci.isoverall = 1)
	as totalexpectedrespondent
	from
	(
		select
			cr.objectid 
		as cr_objectid,
			cr.scorenumerator 
		as cr_scorenumerator,
			cr.objectname 
		as cr_objectname,
			case when srt.contractmandatory = 0 then sci.evaluatedpartyname
				else v.objectname
			end 
		as evaluatedname,
            sci.evaluatedpartyid
        as evaluatedpartyid,
			sp.objectid
		as sp_objectid,
			sp.performanceperiodfrom
		as sp_performanceperiodfrom,
		sp.objectname as sp_objectname
		from
		[surveychecklistitem] sci
		left join [surveyplanner] sp on (sp.isdeleted = 0 and sci.surveyplannerid = sp.objectid)
		left join [surveyresponseto] srt on (srt.isdeleted = 0 and sci.surveyresponsetoid = srt.objectid)
		left join [surveytrade] st on (st.isdeleted = 0 and srt.surveytradeid = st.objectid)
		left join [checklistresponseset] crs on (crs.isdeleted = 0 and sci.checklistresponsesetid = crs.objectid)
		left join [checklistresponse] cr on (cr.isdeleted = 0 and cr.checklistresponsesetid = crs.objectid)
		left join [contract] c on (c.isdeleted = 0 and srt.contractid = c.objectid)
		left join [vendor] v on (v.isdeleted = 0 and c.vendorid = v.objectid)
		where
		sci.isdeleted = 0
        and sci.checklistitemtype = 0
		and sci.surveyplannerid in " + F_SurveyPlannerIDs + @"
        and sci.isoverall = 1
		and st.surveygroupid = '" + F_SurveyGroupID + @"'
		and (('" + F_EvaluatedPartyID + @"' = '' and srt.contractmandatory = 0) or ('" + F_EvaluatedPartyID + @"' <> '' and sci.evaluatedpartyid = '" + F_EvaluatedPartyID + @"'))
		group by cr.objectid,cr.scorenumerator,cr.objectname,sci.evaluatedpartyname,v.objectname,srt.contractmandatory,sp.objectid,sp.performanceperiodfrom,sci.evaluatedpartyid,sp.objectname
	) t1
) t2
order by t2.sp_performanceperiodfrom asc,t2.sp_objectid asc,t2.cr_scorenumerator asc
"
                );

            if (dts.Tables.Count > 0 && dts.Tables[0].Rows.Count > 0)
            {
                DataTable dt = dts.Tables[0];
                dt.TableName = "OverallLevelOfSatisfaction";
                DataTable dt2 = dt.Clone();

                string evaluatedname = dt.Rows[0]["evaluatedname"].ToString();
                string sp_objectid = dt.Rows[0]["sp_objectid"].ToString();
                DateTime sp_performanceperiodfrom = (DateTime)dt.Rows[0]["sp_performanceperiodfrom"];
                int NumberOfNoResponse = (int)dt.Rows[0]["totalexpectedrespondent"];
                int totalexpectedrespondent = (int)dt.Rows[0]["totalexpectedrespondent"];
                decimal PercentageOfNoResponse = 100M;

                foreach (DataRow dr in dt.Rows)
                {
                    if (dr["sp_objectid"].ToString() == sp_objectid)
                    {
                        NumberOfNoResponse -= (int)dr["numberofrespondent"];
                        PercentageOfNoResponse -= (decimal)dr["percentage"];
                    }
                    else
                    {
                        DataRow new_dr = dt2.NewRow();
                        new_dr["cr_objectid"] = Guid.Empty;
                        new_dr["cr_scorenumerator"] = (int)0;
                        new_dr["cr_objectname"] = "No Response";
                        new_dr["evaluatedname"] = evaluatedname;
                        new_dr["sp_objectid"] = sp_objectid;
                        new_dr["sp_performanceperiodfrom"] = sp_performanceperiodfrom;
                        new_dr["numberofrespondent"] = NumberOfNoResponse;
                        new_dr["totalexpectedrespondent"] = totalexpectedrespondent;
                        new_dr["percentage"] = PercentageOfNoResponse;
                        new_dr["orderpriority"] = (int)0;
                        dt2.Rows.Add(new_dr);

                        evaluatedname = dr["evaluatedname"].ToString();
                        sp_objectid = dr["sp_objectid"].ToString();
                        sp_performanceperiodfrom = (DateTime)dr["sp_performanceperiodfrom"];
                        NumberOfNoResponse = (int)dr["totalexpectedrespondent"];
                        totalexpectedrespondent = (int)dr["totalexpectedrespondent"];
                        PercentageOfNoResponse = 100M;

                        NumberOfNoResponse -= (int)dr["numberofrespondent"];
                        PercentageOfNoResponse -= (decimal)dr["percentage"];
                    }
                }

                DataRow lastnew_dr = dt2.NewRow();
                lastnew_dr["cr_objectid"] = Guid.Empty;
                lastnew_dr["cr_scorenumerator"] = (int)0;
                lastnew_dr["cr_objectname"] = "No Response";
                lastnew_dr["evaluatedname"] = evaluatedname;
                lastnew_dr["sp_objectid"] = sp_objectid;
                lastnew_dr["sp_performanceperiodfrom"] = sp_performanceperiodfrom;
                lastnew_dr["numberofrespondent"] = NumberOfNoResponse;
                lastnew_dr["totalexpectedrespondent"] = totalexpectedrespondent;
                lastnew_dr["percentage"] = PercentageOfNoResponse;
                lastnew_dr["orderpriority"] = (int)0;
                dt2.Rows.Add(lastnew_dr);

                dt.Merge(dt2);
                dt.DefaultView.Sort = "sp_performanceperiodfrom asc, sp_objectid asc, orderpriority asc, cr_scorenumerator asc";

                dt = dt.DefaultView.ToTable();
                dt.TableName = "OverallLevelOfSatisfaction";

                dts.Tables.Add(Reports.Statistics(F_SurveyPlannerIDs, F_SurveyGroupID, F_EvaluatedPartyID, null));
                return dts;

            }
            else
            {
                DataSet ds = new DataSet();
                DataTable ErrorDT = new DataTable("OverallLevelOfSatisfaction");
                ErrorDT.Columns.Add("Error Message");
                ErrorDT.Rows.Add(new Object[] { "Query returns zero table." });
                ds.Tables.Add(ErrorDT);
                ds.Tables.Add(new DataTable("Statistics"));
                return ds;
            }

        }

        /// <summary>
        /// Datatable for Report that return AnalysisOfResponsesOfIndividualQuestions        
        /// </summary>
        /// <returns>DataTable</returns>
        public static DataSet AnalysisOfResponsesOfIndividualQuestions(ReportParameters parameters)
        {
            string F_SurveyGroupID = "";
            string F_EvaluatedPartyID = "";
            string F_SurveyPlannerID = "";
            string F_Questions = "";

            if (parameters.GetString("F_SurveyGroupID") != "")
                F_SurveyGroupID = parameters.GetString("F_SurveyGroupID");
            if (parameters.GetString("F_EvaluatedPartyID") != "")
                F_EvaluatedPartyID = parameters.GetString("F_EvaluatedPartyID");
            if (parameters.GetString("F_SurveyPlannerID") != "")
                F_SurveyPlannerID = parameters.GetString("F_SurveyPlannerID");
            if (parameters.GetList("F_Questions").Count > 0)
            {
                F_Questions = "(";
                for (int i = 0; i < parameters.GetList("F_Questions").Count; i++)
                {
                    if (i == ((parameters.GetList("F_Questions").Count) - 1))
                        F_Questions += "'" + parameters.GetList("F_Questions")[i].ToString() + "')";
                    else
                        F_Questions += "'" + parameters.GetList("F_Questions")[i].ToString() + "',";
                }
            }
            else
            {
                F_Questions = "('')";
            }

            if (F_SurveyPlannerID == "" || F_SurveyGroupID == "" || F_Questions == "('')")
            {
                DataSet ds = new DataSet();
                DataTable ErrorDT = new DataTable("AnalysisResponse");
                ErrorDT.Columns.Add("Error Message");
                ErrorDT.Rows.Add(new Object[] { "Please select all filters in order to generate the report correctly." });
                ds.Tables.Add(ErrorDT);
                ds.Tables.Add(new DataTable("Statistics"));
                return ds;
            }

            DataSet dts = Connection.ExecuteQuery("#database",
                @"
select
*,
	cast(case when t2.totalexpectedrespondent = 0
		then 0
		else 100*cast(t2.numberofrespondent as decimal(19,2))/cast(t2.totalexpectedrespondent as decimal(19,2))
		end as decimal(19,2))
as percentage,
1 as orderpriority
from
(
	select
	*,
		isnull(
			(select
			count(scicr.checklistresponseid)
			from 
			surveychecklistitemchecklistresponse scicr 
			where
			scicr.checklistresponseid = t1.cr_objectid
			and scicr.surveychecklistitemid in
				(select objectid from surveychecklistitem sci
				where sci.isdeleted = 0
                -- 2011.03.23, Kim Foong, added the following line:
                and sci.objectname = t1.sci_objectname
				and sci.surveyplannerid = t1.sp_objectid
                and ((sci.evaluatedpartyname = t1.evaluatedname and sci.evaluatedpartyid is null) or 
                    ((sci.evaluatedpartyname <> t1.evaluatedname or sci.evaluatedpartyname is null) and sci.evaluatedpartyid = t1.evaluatedpartyid and sci.evaluatedpartyid is not null))
                -- 2011.03.23, Kim Foong, changed isoverall = 1 to isoverall = 0
				and sci.checklistitemtype = 0 and sci.isoverall = 0)
			group by
			scicr.checklistresponseid)
		,0)
	as numberofrespondent,
		(select count(objectid) from surveychecklistitem sci
		where sci.isdeleted = 0
		and sci.surveyplannerid = t1.sp_objectid
        and ((sci.evaluatedpartyname = t1.evaluatedname and sci.evaluatedpartyid is null) or 
            ((sci.evaluatedpartyname <> t1.evaluatedname or sci.evaluatedpartyname is null) and sci.evaluatedpartyid = t1.evaluatedpartyid and sci.evaluatedpartyid is not null))
		and sci.checklistitemtype = 0
        and sci.isoverall = 1)
	as totalexpectedrespondent
	from
	(
		select
			sci.objectname 
		as sci_objectname,
			cr.objectid 
		as cr_objectid,
			cr.scorenumerator 
		as cr_scorenumerator,
			cr.objectname 
		as cr_objectname,
			case when srt.contractmandatory = 0 then sci.evaluatedpartyname
				else v.objectname
			end 
		as evaluatedname,
            sci.evaluatedpartyid
        as evaluatedpartyid,
			sp.objectid
		as sp_objectid,
			sp.performanceperiodfrom
		as sp_performanceperiodfrom
		from
		[surveychecklistitem] sci
		left join [surveyplanner] sp on (sp.isdeleted = 0 and sci.surveyplannerid = sp.objectid)
		left join [surveyresponseto] srt on (srt.isdeleted = 0 and sci.surveyresponsetoid = srt.objectid)
		left join [surveytrade] st on (st.isdeleted = 0 and srt.surveytradeid = st.objectid)
		left join [checklistresponseset] crs on (crs.isdeleted = 0 and sci.checklistresponsesetid = crs.objectid)
		left join [checklistresponse] cr on (cr.isdeleted = 0 and cr.checklistresponsesetid = crs.objectid)
		left join [contract] c on (c.isdeleted = 0 and srt.contractid = c.objectid)
		left join [vendor] v on (v.isdeleted = 0 and c.vendorid = v.objectid)
		where
		sci.isdeleted = 0
		and sci.surveyplannerid = '" + F_SurveyPlannerID + @"'
		and sci.checklistitemtype = 0
		and sci.objectname in " + F_Questions + @"
		and st.surveygroupid = '" + F_SurveyGroupID + @"'
		and (('" + F_EvaluatedPartyID + @"' = '' and srt.contractmandatory = 0) or ('" + F_EvaluatedPartyID + @"' <> '' and sci.evaluatedpartyid = '" + F_EvaluatedPartyID + @"'))
		group by sci.objectname,cr.objectid,cr.scorenumerator,cr.objectname,sci.evaluatedpartyname,v.objectname,srt.contractmandatory,sp.objectid,sp.performanceperiodfrom,sci.evaluatedpartyid
	) t1
) t2
order by t2.sp_performanceperiodfrom,t2.sp_objectid,t2.sci_objectname, cr_scorenumerator asc
"
                );


            if (dts.Tables.Count > 0 && dts.Tables[0].Rows.Count > 0)
            {
                DataTable dt = dts.Tables[0];
                DataTable dt2 = dt.Clone();

                string sci_objectname = dt.Rows[0]["sci_objectname"].ToString();
                string evaluatedname = dt.Rows[0]["evaluatedname"].ToString();
                string sp_objectid = dt.Rows[0]["sp_objectid"].ToString();
                DateTime sp_performanceperiodfrom = (DateTime)dt.Rows[0]["sp_performanceperiodfrom"];
                int NumberOfNoResponse = (int)dt.Rows[0]["totalexpectedrespondent"];
                int totalexpectedrespondent = (int)dt.Rows[0]["totalexpectedrespondent"];
                decimal PercentageOfNoResponse = 100M;

                foreach (DataRow dr in dt.Rows)
                {
                    if (dr["sp_objectid"].ToString() == sp_objectid && dr["sci_objectname"].ToString() == sci_objectname)
                    {
                        NumberOfNoResponse -= (int)dr["numberofrespondent"];
                        PercentageOfNoResponse -= (decimal)dr["percentage"];
                    }
                    else
                    {
                        DataRow new_dr = dt2.NewRow();
                        new_dr["sci_objectname"] = sci_objectname;
                        new_dr["cr_objectid"] = Guid.Empty;
                        new_dr["cr_scorenumerator"] = (int)0;
                        new_dr["cr_objectname"] = "No Response";
                        new_dr["evaluatedname"] = evaluatedname;
                        new_dr["sp_objectid"] = sp_objectid;
                        new_dr["sp_performanceperiodfrom"] = sp_performanceperiodfrom;
                        new_dr["numberofrespondent"] = NumberOfNoResponse;
                        new_dr["totalexpectedrespondent"] = totalexpectedrespondent;
                        new_dr["percentage"] = PercentageOfNoResponse;
                        new_dr["orderpriority"] = (int)0;
                        dt2.Rows.Add(new_dr);

                        sci_objectname = dr["sci_objectname"].ToString();
                        evaluatedname = dr["evaluatedname"].ToString();
                        sp_objectid = dr["sp_objectid"].ToString();
                        sp_performanceperiodfrom = (DateTime)dr["sp_performanceperiodfrom"];
                        NumberOfNoResponse = (int)dr["totalexpectedrespondent"];
                        totalexpectedrespondent = (int)dr["totalexpectedrespondent"];
                        PercentageOfNoResponse = 100M;

                        NumberOfNoResponse -= (int)dr["numberofrespondent"];
                        PercentageOfNoResponse -= (decimal)dr["percentage"];
                    }
                }

                DataRow lastnew_dr = dt2.NewRow();
                lastnew_dr["sci_objectname"] = sci_objectname;
                lastnew_dr["cr_scorenumerator"] = (int)0;
                lastnew_dr["cr_objectname"] = "No Response";
                lastnew_dr["evaluatedname"] = evaluatedname;
                lastnew_dr["sp_objectid"] = sp_objectid;
                lastnew_dr["sp_performanceperiodfrom"] = sp_performanceperiodfrom;
                lastnew_dr["numberofrespondent"] = NumberOfNoResponse;
                lastnew_dr["totalexpectedrespondent"] = totalexpectedrespondent;
                lastnew_dr["percentage"] = PercentageOfNoResponse;
                lastnew_dr["orderpriority"] = (int)0;
                dt2.Rows.Add(lastnew_dr);

                dt.Merge(dt2);
                dt.DefaultView.Sort = "sp_performanceperiodfrom asc, sp_objectid asc, orderpriority asc, cr_scorenumerator asc";

                dt.DefaultView.ToTable();
                dt.TableName = "AnalysisResponse";

                dts.Tables.Add(Reports.Statistics("('"+F_SurveyPlannerID+"')", F_SurveyGroupID, F_EvaluatedPartyID, parameters.GetList("F_Questions")));

                return dts;
            }
            else
            {
                DataSet ds = new DataSet();
                DataTable ErrorDT = new DataTable("AnalysisResponse");
                ErrorDT.Columns.Add("Error Message");
                ErrorDT.Rows.Add(new Object[] { "Query returns zero table." });
                ds.Tables.Add(ErrorDT);
                ds.Tables.Add(new DataTable("Statistics"));
                return ds;
            }

        }

        /// <summary>
        /// Datatable for Report that return SurveyPlannerResultCount        
        /// </summary>
        /// <returns>DataTable</returns>
        public static DataTable SurveyPlannerResultCount(ReportParameters parameters)
        {
            string F_SurveyGroupID = "";
            string F_SurveyPlannerIDs = "";
            string F_SurveyPlanner2IDs = "";

            if (parameters.GetString("F_SurveyGroupID") != "")
                F_SurveyGroupID = parameters.GetString("F_SurveyGroupID");

            if (parameters.GetList("F_SurveyPlannerIDs").Count > 0)
            {
                F_SurveyPlannerIDs = "(";
                F_SurveyPlanner2IDs = "(";
                for (int i = 0; i < parameters.GetList("F_SurveyPlannerIDs").Count; i++)
                {
                    if (i == ((parameters.GetList("F_SurveyPlannerIDs").Count) - 1))
                    {
                        F_SurveyPlannerIDs += "'" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "')";
                        F_SurveyPlanner2IDs += "''" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "'')";
                    }
                    else
                    {
                        F_SurveyPlannerIDs += "'" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "',";
                        F_SurveyPlanner2IDs += "''" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "'',";
                    }
                }
            }

            if (F_SurveyGroupID == "" || F_SurveyPlannerIDs == "")
            {
                DataTable ErrorDT = new DataTable();
                ErrorDT.Columns.Add("Error Message");
                ErrorDT.Rows.Add(new Object[] { "Please select all filters in order to generate the report correctly." });
                return ErrorDT;
            }

            SqlParameter p1 = new SqlParameter("SurveyGroupID", F_SurveyGroupID);
            SqlParameter p2 = new SqlParameter("NA", (object)("'N.A.'"));
            SqlParameter p3 = new SqlParameter("Remaining", (object)("'...'"));
            SqlParameter p4 = new SqlParameter("Percentage", (object)("'%'"));
            SqlParameter p5 = new SqlParameter("dash", (object)("'-'"));

            DataSet dts = Connection.ExecuteQuery("#database",
                @"
-- To generate the columns --
DECLARE @cols NVARCHAR(2000)
SELECT  @cols = COALESCE (@cols + ',[' + case when len(j.objectname) > 50 then substring(j.objectname,1,50) + '...' else j.objectname end + ']',
                         '[' + case when len(j.objectname) > 50 then substring(j.objectname,1,50) + '...' else j.objectname end + ']')
FROM (select top 1 a.checklistresponsesetid, a.objectname
FROM    SurveyChecklistItem a
LEFT JOIN SurveyResponseTo b on a.SurveyResponseToID = b.ObjectID
LEFT JOIN surveytrade c on b.surveytradeid = c.objectid
WHERE	a.SurveyRespondentID = (select top 1 t1.surveyrespondentid
                                from
                                surveychecklistitem t1
                                left join surveyresponseto t2 on t1.surveyresponsetoid = t2.objectid
                                left join surveytrade t3 on t2.surveytradeid = t3.objectid
                                where
                                t1.isdeleted = 0 and t2.isdeleted = 0
                                and t3.isdeleted = 0
                                and t1.surveyplannerid in " + F_SurveyPlannerIDs + @"
                                and t3.surveygroupid = @SurveyGroupID)
AND     a.SurveyResponseToID = (select top 1 t2.objectid
                                from
                                surveychecklistitem t1
                                left join surveyresponseto t2 on t1.surveyresponsetoid = t2.objectid
								left join surveytrade t3 on t2.surveytradeid = t3.objectid
                                where
                                t1.isdeleted = 0
                                and t2.isdeleted = 0 and t3.isdeleted = 0
                                and t1.surveyplannerid in " + F_SurveyPlannerIDs + @"
                                and t3.surveygroupid = @SurveyGroupID) 
AND     a.SurveyPlannerID in " + F_SurveyPlannerIDs + @"
AND     c.SurveyGroupID = @SurveyGroupID
AND		a.checklistresponsesetid is not null
ORDER BY a.stepnumber asc) p
LEFT JOIN [checklistresponseset] clrs on (p.checklistresponsesetid = clrs.objectid and clrs.isdeleted = 0)
LEFT JOIN [checklistresponse] j on (clrs.objectid = j.checklistresponsesetid and j.isdeleted = 0)
ORDER BY j.scorenumerator DESC

IF (@cols is not null)
BEGIN
EXECUTE(N'SELECT * FROM (
			SELECT 
			stepnumber, question, tradename, contractid, evaluatedpartyname, choicename, sum(count) as totalselection,
            ContractNumber,VendorName,SurveyPlannerName
            FROM
                (SELECT 
					  scli.stepnumber as stepnumber,
					  case when len(scli.objectname) > 50 then substring(scli.objectname,1,50) + '+@Remaining+' else scli.objectname end as question
                      , d.objectname as tradename
                      , c.objectid as contractid
					  , case when (c.objectid is not null and v.objectid is not null)
							 then v.objectname
							 else srt.evaluatedpartyname
						end as evaluatedpartyname
                      , c.Objectnumber as ContractNumber
                      , v.ObjectName as VendorName
                      , splan.ObjectName as SurveyPlannerName
					  ,case when scli.checklistitemtype in (1,4) then 0
							 when scli.checklistitemtype in (0,3) then 
								  (select
								  sum(clr.scorenumerator)
								  from [surveychecklistitemchecklistresponse] scliclr
								  left join [checklistresponse] clr on scliclr.checklistresponseid = clr.objectid
								  where scliclr.surveychecklistitemid = scli.objectid			
								  )
						else 0 end as score
					  , case when scliclr.checklistresponseid is null then 0 else 1 end as count
					  , isnull(clr.objectname, '' Not Selected '') as choicename
                FROM    [surveychecklistitem] scli
                LEFT JOIN [surveyplanner] splan on (scli.surveyplannerid = splan.objectid and splan.isdeleted = 0)
                LEFT JOIN [survey] s on (scli.surveyid = s.objectid and s.isdeleted = 0)
				LEFT JOIN [surveyresponseto] srt on (scli.surveyresponsetoid = srt.objectid and srt.isdeleted = 0)
				LEFT JOIN [contract] c on (srt.contractid = c.objectid and srt.contractmandatory = 1 and c.isdeleted = 0)
				LEFT JOIN [vendor] v on (c.vendorid = v.objectid and v.isdeleted = 0)
				LEFT JOIN [surveytrade] st on (srt.surveytradeid = st.objectid and st.isdeleted = 0)
				LEFT JOIN [surveygroup] d on (st.surveygroupid = d.objectid and d.isdeleted = 0)
				LEFT JOIN [surveyrespondent] sr on (scli.surveyrespondentid = sr.objectid and sr.isdeleted = 0)
				LEFT JOIN [checklistresponseset] clrs on (scli.checklistresponsesetid = clrs.objectid and clrs.isdeleted = 0)
				LEFT JOIN [checklistresponse] clr on (clrs.objectid = clr.checklistresponsesetid and clr.isdeleted = 0)
				LEFT JOIN [surveychecklistitemchecklistresponse] scliclr on (scliclr.surveychecklistitemid = scli.objectid and scliclr.checklistresponseid = clr.objectid)
                WHERE   
						scli.isdeleted = 0
						and	scli.surveyrespondentid in
                            (select distinct
                            t1.surveyrespondentid
                            from
                            surveychecklistitem t1
                            left join surveyresponseto t2 on t1.surveyresponsetoid = t2.objectid
                            left join surveytrade t3 on t2.surveytradeid = t3.objectid
                            where
                            t1.isdeleted = 0
                            and t2.isdeleted = 0 and t3.isdeleted = 0
                            and t1.surveyplannerid in " + F_SurveyPlanner2IDs + @"
                            and t3.surveygroupid = '''+@SurveyGroupID+''')
				        and scli.surveyplannerid in " + F_SurveyPlanner2IDs + @"
                        and d.objectid = '''+@SurveyGroupID+'''
                ) p
				GROUP BY p.stepnumber, p.question, p.tradename, p.contractid, p.evaluatedpartyname, p.choicename,p.ContractNumber,p.VendorName,p.SurveyPlannerName
			) gb
            PIVOT
            (
            SUM(gb.totalselection)
            FOR gb.choicename IN
            ( '+
            @cols +' )
            ) AS pvt
'
    )
END
                    ",
                 p1, p2, p3, p4, p5
                 );

            if (dts.Tables.Count > 0)
            {
                DataTable dt = dts.Tables[0];

                dt.Columns[0].ColumnName = "Step No.";
                dt.Columns[1].ColumnName = "Question";
                dt.Columns[2].ColumnName = "Trade";
                dt.Columns[3].ColumnName = "Evaluated Party";
                dt.Columns[4].ColumnName = "Contract Number";
                dt.Columns[5].ColumnName = "Vendor Name";
                dt.Columns[6].ColumnName = "Survey Planner Name";

                return dt;
            }
            else
            {
                DataTable ErrorDT = new DataTable();
                ErrorDT.Columns.Add("Error Message");
                ErrorDT.Rows.Add(new Object[] { "Query returns zero table." });
                return ErrorDT;
            }
        }

        /// <summary>
        /// Datatable for Report that return SurveyPlannerResultPercentage        
        /// </summary>
        /// <returns>DataTable</returns>
        public static DataTable SurveyPlannerResultPercentage(ReportParameters parameters)
        {
            string F_SurveyGroupID = "";
            string F_SurveyPlannerIDs = "";
            string F_SurveyPlanner2IDs = "";

            if (parameters.GetString("F_SurveyGroupID") != "")
                F_SurveyGroupID = parameters.GetString("F_SurveyGroupID");

            if (parameters.GetList("F_SurveyPlannerIDs").Count > 0)
            {
                F_SurveyPlannerIDs = "(";
                F_SurveyPlanner2IDs = "(";
                for (int i = 0; i < parameters.GetList("F_SurveyPlannerIDs").Count; i++)
                {
                    if (i == ((parameters.GetList("F_SurveyPlannerIDs").Count) - 1))
                    {
                        F_SurveyPlannerIDs += "'" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "')";
                        F_SurveyPlanner2IDs += "''" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "'')";
                    }
                    else
                    {
                        F_SurveyPlannerIDs += "'" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "',";
                        F_SurveyPlanner2IDs += "''" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "'',";
                    }
                }
            }

            if (F_SurveyGroupID == "" || F_SurveyPlannerIDs == "")
            {
                DataTable ErrorDT = new DataTable();
                ErrorDT.Columns.Add("Error Message");
                ErrorDT.Rows.Add(new Object[] { "Please select all filters in order to generate the report correctly." });
                return ErrorDT;
            }

            SqlParameter p1 = new SqlParameter("SurveyGroupID", F_SurveyGroupID);
            SqlParameter p2 = new SqlParameter("NA", (object)("'N.A.'"));
            SqlParameter p3 = new SqlParameter("Remaining", (object)("'...'"));
            SqlParameter p4 = new SqlParameter("Percentage", (object)("'%'"));
            SqlParameter p5 = new SqlParameter("dash", (object)("'-'"));

            DataSet dts = Connection.ExecuteQuery("#database",
                @"
-- To generate the columns --
DECLARE @cols NVARCHAR(2000)
SELECT  @cols = COALESCE (@cols + ',[' + case when len(j.objectname) > 50 then substring(j.objectname,1,50) + '...' else j.objectname end + ']',
                         '[' + case when len(j.objectname) > 50 then substring(j.objectname,1,50) + '...' else j.objectname end + ']')
FROM (select top 1 a.checklistresponsesetid, a.objectname
FROM    SurveyChecklistItem a
LEFT JOIN SurveyResponseTo b on a.SurveyResponseToID = b.ObjectID
LEFT JOIN surveytrade c on b.surveytradeid = c.objectid
WHERE	a.SurveyRespondentID = (select top 1 t1.surveyrespondentid
                                from
                                surveychecklistitem t1
                                left join surveyresponseto t2 on t1.surveyresponsetoid = t2.objectid
                                left join surveytrade t3 on t2.surveytradeid = t3.objectid
                                where
                                t1.isdeleted = 0 and t2.isdeleted = 0
                                and t3.isdeleted = 0
                                and t1.surveyplannerid in " + F_SurveyPlannerIDs + @"
                                and t3.surveygroupid = @SurveyGroupID)
AND     a.SurveyResponseToID = (select top 1 t2.objectid
                                from
                                surveychecklistitem t1
                                left join surveyresponseto t2 on t1.surveyresponsetoid = t2.objectid
								left join surveytrade t3 on t2.surveytradeid = t3.objectid
                                where
                                t1.isdeleted = 0
                                and t2.isdeleted = 0 and t3.isdeleted = 0
                                and t1.surveyplannerid in " + F_SurveyPlannerIDs + @"
                                and t3.surveygroupid = @SurveyGroupID) 
AND     a.SurveyPlannerID in " + F_SurveyPlannerIDs + @"
AND     c.SurveyGroupID = @SurveyGroupID
AND		a.checklistresponsesetid is not null
ORDER BY a.stepnumber asc) p
LEFT JOIN [checklistresponseset] clrs on (p.checklistresponsesetid = clrs.objectid and clrs.isdeleted = 0)
LEFT JOIN [checklistresponse] j on (clrs.objectid = j.checklistresponsesetid and j.isdeleted = 0)
ORDER BY j.scorenumerator DESC

IF (@cols is not null)
BEGIN
EXECUTE(N'SELECT 
			*
			FROM
			(
			SELECT 
			stepnumber, question, tradename, evaluatedpartyname,contractid,
            contractNumber,vendorName,plannerName,choicename
			,
			cast(case when totalselection = 0
					then 0
					else 100*cast(totalselection as decimal(19,2))/cast(totalrespondent as decimal(19,2))
					end as decimal(19,2))
			as percentage
			FROM
			(
			SELECT stepnumber, question, tradename, contractid, evaluatedpartyname,choicename,sum(count) as totalselection, totalrespondent,
            contractNumber,vendorName,plannerName
			
            FROM
                (SELECT 
					  scli.stepnumber as stepnumber,
					  case when len(scli.objectname) > 50 then substring(scli.objectname,1,50) + '+@Remaining+' else scli.objectname end as question
                      , d.objectname as tradename
                      , c.objectid as contractid
					  , case when (c.objectid is not null and v.objectid is not null)
							 then v.objectname
							 else srt.evaluatedpartyname
						end as evaluatedpartyname
                      , c.ObjectNumber as contractNumber
                      , v.ObjectName as vendorName
                      , splan.ObjectName as plannerName   
					  ,case when scli.checklistitemtype in (1,4) then 0
							 when scli.checklistitemtype in (0,3) then 
								  (select
								  sum(clr.scorenumerator)
								  from [surveychecklistitemchecklistresponse] scliclr
								  left join [checklistresponse] clr on scliclr.checklistresponseid = clr.objectid
								  where scliclr.surveychecklistitemid = scli.objectid			
								  )
						else 0 end as score,
                        (select count(objectid) from [surveychecklistitem]
						where surveyplannerid = scli.surveyplannerid
						and checklistid = scli.checklistid
						and stepnumber = scli.stepnumber
						and ((evaluatedpartyname = scli.evaluatedpartyname and evaluatedpartyid is null) or 
						(evaluatedpartyid = scli.evaluatedpartyid and evaluatedpartyid is not null))
						) as totalrespondent
					  , case when scliclr.checklistresponseid is null then 0 else 1 end as count
					  , isnull(clr.objectname, '' Not Selected '') as choicename
                FROM    [surveychecklistitem] scli
                LEFT JOIN [surveyplanner] splan on (scli.surveyplannerid = splan.objectid and splan.isdeleted = 0)
                LEFT JOIN [survey] s on (scli.surveyid = s.objectid and s.isdeleted = 0)
				LEFT JOIN [surveyresponseto] srt on (scli.surveyresponsetoid = srt.objectid and srt.isdeleted = 0)
				LEFT JOIN [contract] c on (srt.contractid = c.objectid and srt.contractmandatory = 1 and c.isdeleted = 0)
				LEFT JOIN [vendor] v on (c.vendorid = v.objectid and v.isdeleted = 0)
				LEFT JOIN [surveytrade] st on (srt.surveytradeid = st.objectid and st.isdeleted = 0)
				LEFT JOIN [surveygroup] d on (st.surveygroupid = d.objectid and d.isdeleted = 0)
				LEFT JOIN [surveyrespondent] sr on (scli.surveyrespondentid = sr.objectid and sr.isdeleted = 0)
				LEFT JOIN [checklistresponseset] clrs on (scli.checklistresponsesetid = clrs.objectid and clrs.isdeleted = 0)
				LEFT JOIN [checklistresponse] clr on (clrs.objectid = clr.checklistresponsesetid and clr.isdeleted = 0)
				LEFT JOIN [surveychecklistitemchecklistresponse] scliclr on (scliclr.surveychecklistitemid = scli.objectid and scliclr.checklistresponseid = clr.objectid)
                WHERE   
						scli.isdeleted = 0
						and	scli.surveyrespondentid in
                            (select distinct
                            t1.surveyrespondentid
                            from
                            surveychecklistitem t1
                            left join surveyresponseto t2 on t1.surveyresponsetoid = t2.objectid
                            left join surveytrade t3 on t2.surveytradeid = t3.objectid
                            where
                            t1.isdeleted = 0
                            and t2.isdeleted = 0 and t3.isdeleted = 0
                            and t1.surveyplannerid in " + F_SurveyPlanner2IDs + @"
                            and t3.surveygroupid = '''+@SurveyGroupID+''')
				        and scli.surveyplannerid in " + F_SurveyPlanner2IDs + @"
                        and d.objectid = '''+@SurveyGroupID+'''
                ) p
				GROUP BY p.stepnumber, p.question, p.tradename, p.contractid, p.evaluatedpartyname,p.totalrespondent, p.choicename,p.contractNumber,p.vendorName,p.plannerName
			) q
			) r
            PIVOT
            (
            SUM(r.percentage)
            FOR r.choicename IN
            ( '+
            @cols +' )
            ) AS pvt
'
    )
END
                    ",
                 p1, p2, p3, p4, p5
                 );

            if (dts.Tables.Count > 0)
            {
                DataTable dt = dts.Tables[0];

                dt.Columns[0].ColumnName = "Step No.";
                dt.Columns[1].ColumnName = "Question";
                dt.Columns[2].ColumnName = "Trade";
                dt.Columns[3].ColumnName = "Evaluated Party";
                dt.Columns[4].ColumnName = "Contract Number";
                dt.Columns[5].ColumnName = "Vendor Name";
                dt.Columns[6].ColumnName = "Survey Planner Name";

                return dt;
            }
            else
            {
                DataTable ErrorDT = new DataTable();
                ErrorDT.Columns.Add("Error Message");
                ErrorDT.Rows.Add(new Object[] { "Query returns zero table." });
                return ErrorDT;
            }
        }

        /// <summary>
        /// Datatable for Report that return SurveyPlannerResultTotalScore        
        /// </summary>
        /// <returns>DataTable</returns>
        public static DataTable SurveyPlannerResultTotalScore(ReportParameters parameters)
        {
            string F_SurveyGroupID = "";
            string F_SurveyPlannerIDs = "";
            string F_SurveyPlanner2IDs = "";

            if (parameters.GetString("F_SurveyGroupID") != "")
                F_SurveyGroupID = parameters.GetString("F_SurveyGroupID");
           
            if (parameters.GetList("F_SurveyPlannerIDs").Count > 0)
            {
                F_SurveyPlannerIDs = "(";
                F_SurveyPlanner2IDs = "(";
                for (int i = 0; i < parameters.GetList("F_SurveyPlannerIDs").Count; i++)
                {
                    if (i == ((parameters.GetList("F_SurveyPlannerIDs").Count) - 1))
                    {
                        F_SurveyPlannerIDs += "'" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "')";
                        F_SurveyPlanner2IDs += "''" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "'')";
                    }
                    else
                    {
                        F_SurveyPlannerIDs += "'" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "',";
                        F_SurveyPlanner2IDs += "''" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "'',";
                    }
                }
            }

            if (F_SurveyGroupID == "" || F_SurveyPlannerIDs == "")
            {
                DataTable ErrorDT = new DataTable();
                ErrorDT.Columns.Add("Error Message");
                ErrorDT.Rows.Add(new Object[] { "Please select all filters in order to generate the report correctly." });
                return ErrorDT;
            }

            SqlParameter p1 = new SqlParameter("SurveyGroupID", F_SurveyGroupID);
            SqlParameter p2 = new SqlParameter("NA", (object)("'N.A.'"));
            SqlParameter p3 = new SqlParameter("Remaining", (object)("'...'"));
            SqlParameter p4 = new SqlParameter("Percentage", (object)("'%'"));
            SqlParameter p5 = new SqlParameter("dash", (object)("'-'"));

            DataSet dts = Connection.ExecuteQuery("#database",
                @"
-- To generate the columns --

DECLARE @cols NVARCHAR(2000)
SELECT  @cols = COALESCE (@cols + ',[' + case when len(a.objectname) > 50 then substring(a.objectname,1,50) + '...' else a.objectname end + ']',
                         '[' + case when len(a.objectname) > 50 then substring(a.objectname,1,50) + '...' else a.objectname end + ']')
FROM    SurveyChecklistItem a
LEFT JOIN SurveyResponseTo b on a.SurveyResponseToID = b.ObjectID
LEFT JOIN surveytrade c on b.surveytradeid = c.objectid
WHERE	a.SurveyRespondentID = (select top 1 t1.surveyrespondentid
                                from
                                surveychecklistitem t1
                                left join surveyresponseto t2 on t1.surveyresponsetoid = t2.objectid
                                left join surveytrade t3 on t2.surveytradeid = t3.objectid
                                where
                                t1.isdeleted = 0 and t2.isdeleted = 0
                                and t3.isdeleted = 0
                                and t1.surveyplannerid in " + F_SurveyPlannerIDs + @"
                                and t3.surveygroupid = @SurveyGroupID)
AND     a.SurveyResponseToID = (select top 1 t2.objectid
                                from
                                surveychecklistitem t1
                                left join surveyresponseto t2 on t1.surveyresponsetoid = t2.objectid
								left join surveytrade t3 on t2.surveytradeid = t3.objectid
                                where
                                t1.isdeleted = 0
                                and t2.isdeleted = 0 and t3.isdeleted = 0
                                and t1.surveyplannerid in " + F_SurveyPlannerIDs + @"
                                and t3.surveygroupid = @SurveyGroupID) 
AND     a.SurveyPlannerID in " + F_SurveyPlannerIDs + @"
AND     c.SurveyGroupID = @SurveyGroupID
ORDER BY a.stepnumber asc

IF (@cols is not null)
BEGIN
EXECUTE(N'SELECT 
            *
            FROM
                (SELECT 
					  case when len(scli.objectname) > 50 then substring(scli.objectname,1,50) + '+@Remaining+' else scli.objectname end as question
                      , scli.checklistid
                      , d.objectname as tradename
                      , c.objectid as contractid
                      , c.objectnumber as contractnumber
                      , c.objectname as contractname
                      , case when c.contractreferencenumbersuffix is not null then (c.contractreferencenumber + '+@dash+' + c.contractreferencenumbersuffix)
                            else c.contractreferencenumber
                        end as contractreferencenumber
					  , c.contractstartdate
					  , c.contractenddate
					  , case when (c.objectid is not null and v.objectid is not null)
							 then v.objectname
							 else srt.evaluatedpartyname
						end as evaluatedpartyname
					  , srt.surveyid
					  , sr.objectname as surveyrespondentname
                      , v.ObjectName as vendorName
                      , splan.ObjectName as plannerName                        
					  , case when scli.checklistitemtype in (1,4) then scli.description
							 when scli.checklistitemtype in (0,3) then 
								  (select 
								  cast(sum(clr.scorenumerator) as nvarchar(50)) 
								  from [surveychecklistitemchecklistresponse] scliclr
								  left join [checklistresponse] clr on scliclr.checklistresponseid = clr.objectid
								  where scliclr.surveychecklistitemid = scli.objectid			
								  )
							 else '+@NA+' 
						end as score
                FROM    [surveychecklistitem] scli
                LEFT JOIN [surveyplanner] splan on (scli.surveyplannerid = splan.objectid and splan.isdeleted = 0)
                LEFT JOIN [survey] s on (scli.surveyid = s.objectid and s.isdeleted = 0)
				LEFT JOIN [surveyresponseto] srt on (scli.surveyresponsetoid = srt.objectid and srt.isdeleted = 0)
				LEFT JOIN [contract] c on (srt.contractid = c.objectid and srt.contractmandatory = 1 and c.isdeleted = 0)
				LEFT JOIN [vendor] v on (c.vendorid = v.objectid and v.isdeleted = 0)
				LEFT JOIN [surveytrade] st on (srt.surveytradeid = st.objectid and st.isdeleted = 0)
				LEFT JOIN [surveygroup] d on (st.surveygroupid = d.objectid and d.isdeleted = 0)
				LEFT JOIN [surveyrespondent] sr on (scli.surveyrespondentid = sr.objectid and sr.isdeleted = 0)
                WHERE   
						scli.isdeleted = 0
						and	scli.surveyrespondentid in
                            (select distinct
                            t1.surveyrespondentid
                            from
                            surveychecklistitem t1
                            left join surveyresponseto t2 on t1.surveyresponsetoid = t2.objectid
                            left join surveytrade t3 on t2.surveytradeid = t3.objectid
                            where
                            t1.isdeleted = 0
                            and t2.isdeleted = 0 and t3.isdeleted = 0
                            and t1.surveyplannerid in " + F_SurveyPlanner2IDs + @"
                            and t3.surveygroupid = '''+@SurveyGroupID+''')
				        and scli.surveyplannerid in " + F_SurveyPlanner2IDs + @"
                        and d.objectid = '''+@SurveyGroupID+'''

                ) p
            PIVOT
            (
            MAX(p.score)
            FOR p.question IN
            ( '+
            @cols +' )
            ) AS pvt'
    )
END
                    ",
                 p1, p2, p3, p4, p5
                 );

            if (dts.Tables.Count > 0)
            {
                DataTable dt = dts.Tables[0];

                dt.Columns[0].ColumnName = "Checklist ObjectID";
                dt.Columns[1].ColumnName = "Trade";
                dt.Columns[2].ColumnName = "Contract ObjectID";
                dt.Columns[3].ColumnName = "Contract Number";
                dt.Columns[4].ColumnName = "Contract Name";
                dt.Columns[5].ColumnName = "Contract Reference No.";
                dt.Columns[6].ColumnName = "Contract Start Date";
                dt.Columns[7].ColumnName = "Contract End Date";
                dt.Columns[8].ColumnName = "Evaluated Party";
                dt.Columns[9].ColumnName = "Survey ObjectID";
                dt.Columns[10].ColumnName = "Respondent";
                dt.Columns[11].ColumnName = "Vendor Name";
                dt.Columns[12].ColumnName = "Survey Planner Name";

                int TotalNumberOfQuestions = (dt.Columns.Count - 13);
                dt.Columns.Add("Total Score", typeof(decimal));
                dt.Columns["Total Score"].ExtendedProperties["DataFormatString"] = "{0:#,##0.00}";

                List<OChecklistItem> list = TablesLogic.tChecklistItem.LoadList(
                    TablesLogic.tChecklistItem.ChecklistID == new Guid(dt.Rows[0]["Checklist ObjectID"].ToString())
                    ,
                    TablesLogic.tChecklistItem.StepNumber.Asc
                    );

                DataTable dt2 = dt.Clone();

                for (int i = 0; i < TotalNumberOfQuestions; i++)
                {
                    if (((OChecklistItem)list[i]).ChecklistType == ChecklistItemType.Choice ||
                        ((OChecklistItem)list[i]).ChecklistType == ChecklistItemType.MultipleSelections)
                        dt2.Columns[13 + i].DataType = typeof(decimal);
                }

                foreach (DataRow dr in dt.Rows)
                {
                    dr["Total Score"] = 0M;
                    for (int i = 0; i < TotalNumberOfQuestions; i++)
                    {
                        if (((OChecklistItem)list[i]).ChecklistType == ChecklistItemType.Choice ||
                            ((OChecklistItem)list[i]).ChecklistType == ChecklistItemType.MultipleSelections)
                            dr["Total Score"] = (decimal)dr["Total Score"] + (dr[13 + i] == DBNull.Value || dr[13 + i].ToString() == "" ? 0 : Convert.ToDecimal(dr[13 + i].ToString()));
                    }
                    dt2.ImportRow(dr);
                }

                dt2.Columns.Remove(dt2.Columns["Checklist ObjectID"]);
                dt2.Columns.Remove(dt2.Columns["Contract ObjectID"]);
                dt2.Columns.Remove(dt2.Columns["Contract Reference No."]);
                dt2.Columns.Remove(dt2.Columns["Survey ObjectID"]);
                return dt2;
            }
            else
            {
                DataTable ErrorDT = new DataTable();
                ErrorDT.Columns.Add("Error Message");
                ErrorDT.Rows.Add(new Object[] { "Query returns zero table." });
                return ErrorDT;
            }
        }


        /// <summary>
        /// Datatable of statistics on the importance of the survey questions        
        /// </summary>
        /// <returns>DataTable</returns>
        public static DataTable Statistics(String SurveyPlannerID, String SurveyGroupID, String EvaluatedPartyID, List<object> Questions)
        {
            DataSet ds = Connection.ExecuteQuery("#database",
                @"select sci.surveyid as 'Survey',srf.objectid as 'Response',sci.stepnumber as 'StepNumber',
sci.objectname as 'Question', clr.scorenumerator as 'Score', isOverall as 'IsOverall',
(select count([surveychecklistitem].surveyresponsefromid) from [surveychecklistitem]
left join [surveyresponseto] on ([surveyresponseto].isdeleted = 0 and [surveychecklistitem].surveyresponsetoid = [surveyresponseto].objectid)
left join [surveytrade] on ([surveytrade].isdeleted = 0 and [surveyresponseto].surveytradeid = [surveytrade].objectid)
where  [surveychecklistitem].surveyplannerid = sci.surveyplannerid
and [surveytrade].surveygroupid = st.surveygroupid
and ((sci.evaluatedpartyid is null and srt.contractmandatory = 0) or (sci.evaluatedpartyid is not null and [surveychecklistitem].evaluatedpartyid = sci.evaluatedpartyid))
and [surveychecklistitem].isdeleted = 0 and surveyresponsefromid = srf.objectid) as 'NumOfQuestion'
from [surveychecklistitem] sci
left join [surveyresponseto] srt on (srt.isdeleted = 0 and sci.surveyresponsetoid = srt.objectid)
left join [surveyresponsefrom] srf on (srf.isdeleted = 0 and sci.surveyresponsefromid = srf.objectid)
left join [surveytrade] st on (st.isdeleted = 0 and srt.surveytradeid = st.objectid)
left join [SurveyChecklistItemChecklistResponse] scicr on (sci.objectid = scicr.surveychecklistitemid)
left join [CheckListResponse] clr on (clr.isdeleted = 0 and clr.objectid = scicr.CheckListResponseid)
where
sci.isdeleted = 0
and sci.surveyplannerid in " + SurveyPlannerID + @"
and st.surveygroupid = '" + SurveyGroupID + @"'
and (('" + EvaluatedPartyID + @"' = '' and srt.contractmandatory = 0) or ('" + EvaluatedPartyID + @"' <> '' and sci.evaluatedpartyid = '" + EvaluatedPartyID + @"'))
order by srf.objectid,isoverall,sci.objectname"
                );


            SurveyResponseMatrix m = new SurveyResponseMatrix();
            double overallScore = 0;
            String responseID = "";
            String surveyID = "";
            Double[] doubleArray = new Double[0];
            int count = 0;

            foreach (DataRow dr in ds.Tables[0].Rows)
            {
                if (Convert.ToInt32(dr["NumOfQuestion"].ToString()) != 0)
                {
                    bool questionExist = false;

                    if (responseID == "" && surveyID == "")
                    {
                        responseID = dr["Response"].ToString();
                        surveyID = dr["Survey"].ToString();
                        // Temporarily remove the '-1' to fix an index out of bounds error.
                        //doubleArray = new Double[Convert.ToInt32(dr["NumOfQuestion"].ToString()) - 1];
                        doubleArray = new Double[Convert.ToInt32(dr["NumOfQuestion"].ToString())];
                    }
                    else if (dr["Response"].ToString() != responseID || dr["Survey"].ToString() != surveyID)
                    {
                        m.AddSurveyResponse(doubleArray, overallScore);

                        overallScore = 0;
                        count = 0;
                        responseID = dr["Response"].ToString();
                        surveyID = dr["Survey"].ToString();
                        // Temporarily remove the '-1' to fix an index out of bounds error.
                        //doubleArray = new Double[Convert.ToInt32(dr["NumOfQuestion"].ToString()) - 1];
                        doubleArray = new Double[Convert.ToInt32(dr["NumOfQuestion"].ToString())];
                    }

                    foreach (SurveyQuestion question in m.SurveyQuestions)
                    {
                        if (question.QuestionNumber == Convert.ToInt32(dr["StepNumber"].ToString()) &&
                            question.QuestionText == dr["Question"].ToString())
                        {
                            questionExist = true;
                        }
                    }

                    if (!questionExist && dr["IsOverall"].ToString() != "1")
                        m.SurveyQuestions.Add(new SurveyQuestion(Convert.ToInt32(dr["StepNumber"].ToString()), dr["Question"].ToString()));

                    if (dr["IsOverall"].ToString() == "1")
                    {
                        if (dr["Score"].ToString() != "")
                            overallScore = Convert.ToDouble(dr["Score"].ToString());
                        else
                            doubleArray[count] = 0;
                    }
                    else
                    {
                        if (dr["Score"].ToString() != "")
                            doubleArray[count] = Convert.ToDouble(dr["Score"].ToString());
                        else
                            doubleArray[count] = 0;
                        count++;
                    }
                }
            }

            m.AddSurveyResponse(doubleArray, overallScore);

            DataTable Statistics = new DataTable();
            Statistics.Columns.Add("Question");
            Statistics.Columns.Add("Score", typeof(Double)).ExtendedProperties["DataFormatString"] = "{0:#,##0.00}";
            if (m.SurveyResponses.Count >= m.SurveyQuestions.Count)
            {
                m.ComputeSurveyQuestionImportance();
                foreach (SurveyQuestion ques in m.SurveyQuestions)
                {
                    bool addQuestion = true;
                    if (Questions != null)
                    {
                        addQuestion = false;
                        foreach (object question in Questions)
                        {
                            if (question.ToString() == ques.QuestionText)
                                addQuestion = true;
                        }
                    }
                    if (addQuestion)
                    {
                        DataRow dr = Statistics.NewRow();
                        dr["Question"] = ques.QuestionText;
                        dr["Score"] = ques.Importance;
                        Statistics.Rows.Add(dr);
                    }
                }
            }
            Statistics.TableName = "Statistics";
            return Statistics;
        }

        #endregion


        //TVO customize
        #region TVO Report
        /// <summary>
        /// Datatable for Report that return BudgetSummaryReport        
        /// </summary>
        /// <returns></returns>
        public static DataTable BudgetSummaryReport(ReportParameters parameters)
        {
            using(Connection c= new Connection())
            {
            
            DataTable dtReturn = new DataTable();
            // declare column
            dtReturn.Columns.Add("OriginalAmount", typeof(decimal));
            dtReturn.Columns.Add("ReallocatedAmount", typeof(decimal));
            dtReturn.Columns.Add("TotalAdjusted", typeof(decimal));
            dtReturn.Columns.Add("TotalPendingApproval", typeof(decimal));
            dtReturn.Columns.Add("TotalApproved", typeof(decimal));
            dtReturn.Columns.Add("DirectExpense", typeof(decimal));
            dtReturn.Columns.Add("TotalInvoiced", typeof(decimal));
            dtReturn.Columns.Add("TotalPaid", typeof(decimal));
            dtReturn.Columns.Add("TotalAvailable", typeof(decimal));
            dtReturn.Columns.Add("BudgetName");
            dtReturn.Columns.Add("Location");
            dtReturn.Columns.Add("FinancialYear");
            dtReturn.Columns.Add("AccountNameParent");
            dtReturn.Columns.Add("AccountName");
            dtReturn.Columns.Add("AccountAccount");

            string strCheck = parameters.GetString("Budget");
            if (strCheck == "")
            {
                dtReturn.Rows.Add(new Object[] { 
                    DBNull.Value, DBNull.Value, DBNull.Value, DBNull.Value, DBNull.Value, 
                    DBNull.Value, DBNull.Value, DBNull.Value, DBNull.Value, "", 
                    "", "", "", "", "" });
                return dtReturn;
            }

            DataTable dt = new DataTable();
            OBudgetPeriod budgetPeriod = TablesLogic.tBudgetPeriod[new Guid(strCheck)];
            dt = budgetPeriod.GenerateYearlyBudgetView(null);

            string applicationLocations = "";
            foreach(OLocation location in budgetPeriod.Budget.ApplicableLocations)
                applicationLocations += location.Path + "; ";

            //   dt = OYearlyBudget.BuildTreeViewEffect(dt);

            int intdtCount = dt.Rows.Count;
            for (int i = 0; i < intdtCount; i++)
            {
                if (dt.Rows[i]["TotalOpeningBalance"].ToString() != "")
                {

                    OAccount account = TablesLogic.tAccount[new Guid(dt.Rows[i]["AccountID"].ToString())];

                    dtReturn.Rows.Add(new Object[] { 
                        Decimal.Parse(dt.Rows[i]["TotalOpeningBalance"].ToString()),
                        Decimal.Parse(dt.Rows[i]["TotalReallocatedAmount"].ToString()),
                        Decimal.Parse(dt.Rows[i]["TotalBalanceAfterVariation"].ToString()),
                        Decimal.Parse(dt.Rows[i]["TotalPendingApproval"].ToString()),
                        Decimal.Parse(dt.Rows[i]["TotalApproved"].ToString()),
                        Decimal.Parse(dt.Rows[i]["TotalDirectInvoiced"].ToString()),
                        Decimal.Parse(dt.Rows[i]["TotalInvoiceApproved"].ToString()),
                        0M,
                        Decimal.Parse(dt.Rows[i]["TotalAvailableBalance"].ToString()),
                        budgetPeriod.ObjectName,
                        applicationLocations,
                        budgetPeriod.StartDate.Value.Year,
                        (account.Parent ==null ? account.ObjectName: account.Parent.Path),
                        account.ObjectName,
                        account.AccountCode
                    });
                }
            }
            return dtReturn;
        }
             
            
        }



        /// <summary>
        /// caller history report
        /// </summary>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static DataTable CallerHistoryReport(ReportParameters parameters)
        {
            DataTable table = new DataTable();
            table.Columns.Add("Location");
            table.Columns.Add("Equipment");
            table.Columns.Add("Created Date", typeof(DateTime));
            table.Columns.Add("Name");
            table.Columns.Add("CellPhone");
            table.Columns.Add("Email");
            table.Columns.Add("Fax");
            table.Columns.Add("Phone");
            table.Columns.Add("Priority");
            table.Columns.Add("Work Description");
            table.Columns.Add("Work Type");
            table.Columns.Add("Type of service");
            table.Columns.Add("Fault Type");
            table.Columns.Add("Cost");
            table.Columns.Add("Chargeable Amount");
            table.Columns.Add("Status");
            table.Columns.Add("Rejection Reason");


            //string strLocationHirachyPath = LocationHirachyPath(parameters.GetString("TreeviewID"));
            DateTime? FILTER_STARTDATEFROM = parameters.GetDateTime("FILTER_STARTDATEFROM");
            DateTime? FILTER_STARTDATETO = parameters.GetDateTime("FILTER_STARTDATETO");
            DateTime? FILTER_ENDDATEFROM = parameters.GetDateTime("FILTER_ENDDATEFROM");
            DateTime? FILTER_ENDDATETO = parameters.GetDateTime("FILTER_ENDDATETO");
            DataTable tempTable = TablesLogic.tWork.Select(
                TablesLogic.tWork.ObjectID,
                TablesLogic.tWork.LocationID,
                TablesLogic.tWork.CreatedDateTime,
                TablesLogic.tWork.CallerName,
                TablesLogic.tWork.CallerCellPhone,
                TablesLogic.tWork.CallerEmail,
                TablesLogic.tWork.CallerFax,
                TablesLogic.tWork.CallerPhone,
                TablesLogic.tWork.Priority,
                TablesLogic.tWork.WorkDescription,
                TablesLogic.tWork.TypeOfWork.ObjectName,
                TablesLogic.tWork.TypeOfService.ObjectName,
                TablesLogic.tWork.TypeOfProblem.ObjectName,
                TablesLogic.tWork.CurrentActivity.ObjectName)
                .Where(TablesLogic.tWork.IsDeleted == 0 &
                //  & TablesLogic.tWork.Location.HierarchyPath.Like(strLocationHirachyPath + "%")
              (parameters.GetString("TreeviewID") == "" ? GetAccessibleCondition(parameters.GetString("UserID"),true, TablesLogic.tWork.Location.HierarchyPath, "") :
               TablesLogic.tWork.Location.HierarchyPath.Like(TablesLogic.tLocation.Load(new Guid(parameters.GetString("TreeviewID"))).HierarchyPath + "%"))
                & (FILTER_STARTDATEFROM <= DateTime.Parse("1/1/1855") ? Query.True :
                TablesLogic.tWork.CreatedDateTime >= parameters.GetDateTime("FILTER_STARTDATEFROM"))
                & (FILTER_STARTDATETO <= DateTime.Parse("1/1/1855") ? Query.True :
                TablesLogic.tWork.CreatedDateTime < parameters.GetDateTime("FILTER_STARTDATETO").Value.AddDays(1))
                & TablesLogic.tWork.CallerName.Like("%" + parameters.GetString("FILTER_CALLERNAME") + "%")
                );
            
            
            foreach (DataRow row in tempTable.Rows)
            {
                OWork work = TablesLogic.tWork[new Guid(row["ObjectID"].ToString())];
                
                switch (parameters.GetInteger("FILTER_CHARGEABLEAMOUNT"))
                {
                    case 1: if ((parameters.GetDecimal("FILTER_COST") == null ? true : work.TotalActualCost == parameters.GetDecimal("FILTER_COST")) && work.TotalChargeOut < 2000)
                            table.Rows.Add(new object[] { row[1].ToString()==null?"":LocationPath(new Guid(row[1].ToString())),
                            row[2].ToString()==""?"":EquipmentPath(new Guid(row[2].ToString())), 
                            row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13],
                            work.TotalActualCost, work.TotalChargeOut, TranslateWorkStatusToString(row[14].ToString()), row[14].ToString()=="WORK_REJECTED" ? row[15].ToString() : ""});
                        break;
                    case 2: if ((parameters.GetDecimal("FILTER_COST") == null ? true : work.TotalActualCost == parameters.GetDecimal("FILTER_COST")) && work.TotalChargeOut <= 5000 && work.TotalChargeOut >= 2000)
                            table.Rows.Add(new object[] { row[1].ToString()==null?"":LocationPath(new Guid(row[1].ToString())),
                            row[2].ToString()==""?"":EquipmentPath(new Guid(row[2].ToString())), 
                            row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13],
                            work.TotalActualCost, work.TotalChargeOut, TranslateWorkStatusToString(row[14].ToString()), row[14].ToString()=="WORK_REJECTED" ? row[15].ToString() : ""});
                        break;
                    case 3: if ((parameters.GetDecimal("FILTER_COST") == null ? true : work.TotalActualCost == parameters.GetDecimal("FILTER_COST")) && work.TotalChargeOut > 5000)
                            table.Rows.Add(new object[] { row[1].ToString()==null?"":LocationPath(new Guid(row[1].ToString())),
                            row[2].ToString()==""?"":EquipmentPath(new Guid(row[2].ToString())), 
                            row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13],
                            work.TotalActualCost, work.TotalChargeOut, TranslateWorkStatusToString(row[14].ToString()), row[14].ToString()=="WORK_REJECTED" ? row[15].ToString() : ""});
                        break;
                    default: if (parameters.GetDecimal("FILTER_COST") == null ? true : work.TotalActualCost == parameters.GetDecimal("FILTER_COST"))
                            table.Rows.Add(new object[] { row[1].ToString()==null?"":LocationPath(new Guid(row[1].ToString())),
                            row[2].ToString()==""?"":EquipmentPath(new Guid(row[2].ToString())), 
                            row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13],
                            work.TotalActualCost, work.TotalChargeOut, TranslateWorkStatusToString(row[14].ToString()), row[14].ToString()=="WORK_REJECTED" ? row[15].ToString() : ""});
                        break;
                }
                
          }
            return table;
        }

        #region Function of CallerHistoryReport
        /// <summary>
        /// return Location Path
        /// </summary>
        /// <param name="ObjectID"></param>
        /// <returns></returns>
        public static string LocationPath(Guid ObjectID)
        {
            try
            {
                OLocation objLocation = TablesLogic.tLocation[ObjectID];
                return objLocation.Path;
            }
            catch
            {
                return "";
            }
        }

        /// <summary>
        /// return Equipment Path
        /// </summary>
        /// <param name="ObjectID"></param>
        /// <returns></returns>
        public static string EquipmentPath(Guid ObjectID)
        {
            try
            {
                OEquipment objEquipment = TablesLogic.tEquipment[ObjectID];
                return objEquipment.Path;
            }
            catch
            {
                return "";
            }
        }
        public static DataTable Test(ReportParameters parameters) {
            DataTable dtUser = TablesLogic.tUser.Select(TablesLogic.tUser.ObjectID,
                                                        TablesLogic.tUser.ObjectName,
                                                        TablesLogic.tUser.UserBase.Phone,
                                                        TablesLogic.tUser.UserBase.Email)
                                                 .Where(parameters.GetString("F_UserName") == "" ? Query.True : TablesLogic.tUser.ObjectName.Like("%" + parameters.GetString("F_UserName") + "%")&
                                                 TablesLogic.tUser.IsDeleted==0);
            DataTable dt = new DataTable();
            dt.Columns.Add("UserName");
            dt.Columns.Add("PhoneNumber");
            dt.Columns.Add("Email");
            dt.Columns.Add("Date", typeof(DateTime));
            //List<OUser> listuser = TablesLogic.tUser.LoadList(TablesLogic.tUser.IsDeleted == 0 );
            foreach (DataRow row in dtUser.Rows)
            {
                //DataRow row = dt.NewRow();
                //row["UserName"] = u.ObjectName;
                //row["PhoneNumber"] = u.UserBase.Phone;
                //row["Email"] = u.UserBase.Email;
                //row["Date"] = DateTime.Today;
                //dt.Rows.Add(row);
                //OUser u = TablesLogic.tUser.Load(new Guid(row["ObjectID"].ToString());
                dt.Rows.Add(new Object[] { row["ObjectName"].ToString(), row["Phone"].ToString(), row["Email"].ToString(),DateTime.Today });
            }
            return dt;
        }

        /// <summary>
        /// For testing rdl report.
        /// </summary>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static DataTable GetReportAndReportTemplate(ReportParameters parameters)
        {
            List<object> reportList = parameters.GetList("REPORTID");

            DataTable dt = new DataTable();
            dt.Columns.Add("ReportName");
            dt.Columns.Add("ReportType");
            dt.Columns.Add("TemplateName");
            dt.Columns.Add("TemplateType");
            dt.Columns.Add("TemplateFileName");

            DataTable table = TablesLogic.tReport.Select(
                TablesLogic.tReport.ReportName,
                TablesLogic.tReport.ReportType,
                TablesLogic.tReport.ReportTemplate.ObjectName.As("TemplateName"),
                TablesLogic.tReport.ReportTemplate.TemplateType,
                TablesLogic.tReport.ReportTemplate.ObjectNumber.As("TemplateFileName"))
                .Where(
                TablesLogic.tReport.ObjectID.In(reportList) &
                TablesLogic.tReport.IsDeleted == 0)
                .OrderBy(
                TablesLogic.tReport.ReportName.Asc,
                TablesLogic.tReport.ReportTemplate.ObjectName.Asc);

            foreach (DataRow row in table.Rows)
                dt.Rows.Add(new Object[] {
                    row["ReportName"].ToString(),
                    row["ReportType"].ToString(),
                    (row["TemplateName"] == null ? "" : row["TemplateName"].ToString()),
                    (row["TemplateType"] == null ? "" : row["TemplateType"].ToString()),
                    (row["TemplateFileName"] == null ? "" : row["TemplateFileName"].ToString())});
            return dt;
        }

        /// <summary>
        /// for testing purpose: populate report filter value.
        /// </summary>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static DataTable GetReportTemplates(ReportParameters parameters)
        {
            return TablesLogic.tReportTemplate.Select(
                TablesLogic.tReportTemplate.ObjectID,
                TablesLogic.tReportTemplate.ObjectName)
                .Where
                (parameters.GetList("REPORTID") == null ? Query.True :
                TablesLogic.tReportTemplate.Report.ObjectID.In(parameters.GetList("REPORTID")))
                .OrderBy(TablesLogic.tReportTemplate.ObjectName.Asc);
        }

        /// <summary>
        /// translate work status to string
        /// </summary>
        /// <param name="ObjectName"></param>
        /// <returns></returns>
        public static string TranslateWorkStatusToString(string ObjectName)
        {
            switch (ObjectName)
            {
                case "WORK_CLOSED": return "Closed";
                case "WORK_PENDINGACCEPTANCE": return "Pending Acceptance (Internal)";
                case "WORK_PENDINGAPPROVAL": return "Pending Approval";
                case "WORK_PENDINGASSIGNMENT": return "Pending Assignment";
                case "WORK_PENDINGCLOSURE": return "Pending Closure";
                case "WORK_PENDINGCONTRACTOR": return "Pending Contractor";
                case "WORK_PENDINGEXECUTION": return "Pending Execution";
                case "WORK_PENDINGHELPDESK": return "Pending Helpdesk Submission";
                case "WORK_PENDINGMATERIAL": return "Pending Material";
                case "WORK_PENDINGOTHERS": return "Pending Others";
                case "WORK_PENDINGQUOTATION": return "Pending Quotation";
                case "WORK_PENDINGREQUOTATION": return "Pending Amendment";
                case "WORK_PENDINGVERIFICATION": return "Pending Finance Verification";
                case "WORK_PENDINGPLANNING": return "Pending Planning";
                case "WORK_REJECTED": return "Rejected";
                default: return "";
            }
        }

        /// <summary>
        /// return Location HirachyPath by ObjectID
        /// </summary>
        /// <param name="ObjectID"></param>
        /// <returns></returns>
        public static string LocationHirachyPath(string ObjectID)
        {
            if (ObjectID != "")
            {
                OLocation objLocation = TablesLogic.tLocation[new Guid(ObjectID)];
                return objLocation.HierarchyPath;
            }
            return "";
        }

        #endregion

        #endregion

        //Customization by Duy
        #region PurchaseOrderReport

        public static object ConvertToDataRowObject(object x)
        {
            if (x == null)
                return DBNull.Value;
            else
                return x;
        }



        /// <summary>
        /// This build a DataTable according to format of the PO Report 
        /// </summary>
        /// <returns></returns>
        public static DataTable BudgetPeriodSummary(ReportParameters parameters)
        {

            DataTable dt = new DataTable("DataTable");
            string id = parameters.GetString("BudgetPeriodID");
            OBudgetPeriod budgetPeriod = TablesLogic.tBudgetPeriod.Load(new Guid(id));

            //labelBudgetName.Text = BudgetPeriod.Budget.ObjectName;
            //labelBudgetPeriodName.Text = BudgetPeriod.ObjectName;
            //labelStartDate.Text = BudgetPeriod.StartDate.Value.ToString("dd-MMM-yyyy");
            //labelEndDate.Text = BudgetPeriod.EndDate.Value.ToString("dd-MMM-yyyy");

            dt = budgetPeriod.GenerateSummaryBudgetView(null);
            dt.Columns.Add("Location");
            dt.Columns.Add("BudgetName");
            dt.Columns.Add("BudgetPeriodName");
            dt.Columns.Add("StartDate");
            dt.Columns.Add("EndDate");

            StringBuilder sb = new StringBuilder();
            foreach (OLocation location in budgetPeriod.Budget.ApplicableLocations)
                sb.Append(location.Path + ", ");

            foreach (DataRow dr in dt.Rows)
            {
                dr["Location"] = sb.ToString();
                dr["AccountName"] = new StringBuilder().Insert(0, " ", Convert.ToInt32(dr["Level"].ToString())).ToString() +
                dr["AccountName"].ToString();
                dr["BudgetName"] = budgetPeriod.ObjectName;
                dr["BudgetPeriodName"] = budgetPeriod.Budget.ObjectName;
                dr["StartDate"] = budgetPeriod.StartDate.Value.ToString("dd-MMM-yyyy");
                dr["EndDate"] = budgetPeriod.EndDate.Value.ToString("dd-MMM-yyyy");
            }

            return dt;
        }

        /// <summary>
        /// This build a DataTable according to format of the PO Report 
        /// </summary>
        /// <returns></returns>
        public static DataTable BuildTablePurchaseOrderReport()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("ObjectNumber");
            dt.Columns.Add("Description");
            dt.Columns.Add("DateOfOrder");
            dt.Columns.Add("PurchasingManager");
            dt.Columns.Add("Budget");
            dt.Columns.Add("Vender");
            dt.Columns.Add("VendorCountry");
            dt.Columns.Add("VendorState");
            dt.Columns.Add("VenderCity");
            dt.Columns.Add("VenderAddress");
            dt.Columns.Add("VenderCellphone");
            dt.Columns.Add("VenderEmail");
            dt.Columns.Add("VenderFax");
            dt.Columns.Add("VenderPhone");
            dt.Columns.Add("VenderContactPerson");
            dt.Columns.Add("VenderFreightTerms");
            dt.Columns.Add("VenderPaymentTerms");
            dt.Columns.Add("ShipToAddress");
            dt.Columns.Add("ShipToAttention");
            dt.Columns.Add("BillToAddress");
            dt.Columns.Add("BillToAttention");
            dt.Columns.Add("POAmount", typeof(decimal));
            dt.Columns.Add("TotalGR");
            dt.Columns.Add("TotalInvoice");
            dt.Columns.Add("TotalGRAmount", typeof(decimal));
            dt.Columns.Add("TotalInvoiceAmount", typeof(decimal));

            return dt;
        }


        #endregion


    }


}
