//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;


/// <summary>
/// Summary description for CapitalandCompany
/// </summary>

namespace LogicLayer
{
    [Database("#database"), Map("TenantLease")]
    public partial class TTenantLease : LogicLayerSchema<OTenantLease>
    {
        public SchemaGuid TenantID;
        public SchemaGuid LocationID;
        public SchemaDateTime LeaseStartDate;
        public SchemaDateTime LeaseEndDate;
        [Size(10)]
        public SchemaString LeaseStatus;
        public SchemaInt FromAmos;
        public SchemaInt AmosAssetID;
        public SchemaInt AmosSuiteID;
        public SchemaInt AmosLeaseID;
        public SchemaInt AmosOrgID;
        public SchemaInt AmosShopID;

        // 2011.12.14, Kien Trung
        // Modified for CCL, add contact_id, address_id in tenant lease.
        //
        public SchemaInt AmosContactID;
        public SchemaInt AmosAddressID;

        public SchemaDateTime updatedOn;
        public SchemaDateTime LeaseStatusDate;
        public SchemaDateTime HandoverDateTime;
        [Size(255)]
        public SchemaString HandoverRemarks;
        public SchemaDateTime TakeoverDateTime;
        [Size(255)]
        public SchemaString TakeoverRemarks;
        public SchemaDateTime LeaseStatusChangeDate;
        [Size(255)]
        public SchemaString ShopName;
        

        public SchemaDateTime ActualLeaseEndDate;
        public SchemaGuid TenantContactID;

        public TUser Tenant { get { return OneToOne<TUser>("TenantID"); } }
        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
        public TTenantLeaseHOTO TenantLeaseHOTOs { get { return OneToMany<TTenantLeaseHOTO>("TenantLeaseID"); } }
        public TTenantContact TenantContact { get { return OneToOne<TTenantContact>("TenantContactID"); } }
    }


    /// <summary>
    /// </summary>
    public abstract partial class OTenantLease : LogicLayerPersistentObject
    {
        public abstract Guid? TenantID { get; set; }
        public abstract Guid? LocationID { get; set; }
        public abstract DateTime? LeaseStartDate { get; set; }
        public abstract DateTime? LeaseEndDate { get; set; }
        public abstract String LeaseStatus { get; set; }

        public abstract int? FromAmos { get; set; }
        public abstract int? AmosAssetID { get; set; }
        public abstract int? AmosSuiteID { get; set; }
        public abstract int? AmosLeaseID { get; set; }
        public abstract int? AmosOrgID { get; set; }
        public abstract int? AmosShopID { get; set; }
        // 2011.12.14, Kien Trung
        // Modified for CCL, add contact_id, address_id in tenant lease.
        //
        public abstract int? AmosContactID { get; set; }
        public abstract int? AmosAddressID { get; set; }

        public abstract DateTime? updatedOn { get; set; }
        public abstract DateTime? LeaseStatusDate { get; set; }
        public abstract DateTime? LeaseStatusChangeDate { get; set; }

        public abstract OLocation Location { get; set; }
        public abstract OUser Tenant { get; set; }
        public abstract DateTime? HandoverDateTime { get; set; }
        public abstract String HandoverRemarks { get; set; }
        public abstract DateTime? TakeoverDateTime { get; set; }
        public abstract String TakeoverRemarks { get; set; }
        public abstract DataList<OTenantLeaseHOTO> TenantLeaseHOTOs { get; set; }

        public abstract string ShopName { get; set; }
        public abstract DateTime? ActualLeaseEndDate { get; set; }

        public abstract Guid? TenantContactID { get; set; }
        public abstract OTenantContact TenantContact { get; set; }

        public static DataTable dtStatusList()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Status");
            dt.Columns.Add("Abr");
            dt.Rows.Add(new object[] { "Expired", "E" });
            dt.Rows.Add(new object[] { "Extended", "X" });
            dt.Rows.Add(new object[] { "New", "N" });
            dt.Rows.Add(new object[] { "Novated", "O" });
            dt.Rows.Add(new object[] { "Renewal (after expiry)", "R" });
            dt.Rows.Add(new object[] { "Rescinded", "V" });
            dt.Rows.Add(new object[] { "Restructured (before expiry)", "S" });
            dt.Rows.Add(new object[] { "Terminated", "T" });


            return dt;
        }

        public string TenantNameWithLeasePeriod
        {
            get
            {
                return this.Tenant.ObjectName + " (" +
                    this.LeaseStartDate.Value.ToString("dd-MMM-yy") + " - " +
                    this.LeaseEndDate.Value.ToString("dd-MMM-yy") + ")";
            }
        }

        public string Status
        {
            get { return TranslateStatusName(this.LeaseStatus); }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="status"></param>
        /// <returns></returns>
        public static string TranslateStatusName(string status)
        {
            string s = "";
            if (status == EnumLeaseStatus.Terminated)
                s = "Terminated";
            else if (status == EnumLeaseStatus.Expired)
                s = "Expired";
            else if (status == EnumLeaseStatus.New)
                s = "New";
            else if (status == EnumLeaseStatus.Restructured)
                s = "Restructured (before expiry)";
            else if (status == EnumLeaseStatus.Extended)
                s = "Extended";
            else if (status == EnumLeaseStatus.Rescinded)
                s = "Rescinded";
            else if (status == EnumLeaseStatus.Novated)
                s = "Novated";
            else if (status == EnumLeaseStatus.Renewal)
                s = "Renewal (after expiry)";
            return s;
        }

        /// <summary>
        /// 
        /// </summary>
        public String FromAmosText
        {
            get
            {
                if (this.FromAmos == 1)
                    return "Yes";
                else if (this.FromAmos == 0)
                    return "No";
                else
                    return "";
            }
        }
        public override bool IsDeactivable()
        {
            if (this.FromAmos == 1)
                return false;

            return true;
        }

        //public override bool IsRemovable()
        //{
        //    if (this.FromAmos == 1)
        //        return false;

        //    return true;
        //}

        public static DataTable GetNewTenantLeaseList(OLocation location, Guid? includingLeaseId)
        {
            // 2011.01.31
            // Kim Foong
            // Use the logic of the reading date to load up the list of leases.
            //
            DateTime readingDateTime =
                new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            if (DateTime.Now.Day <= OApplicationSetting.Current.PostingEndDay)
                readingDateTime = readingDateTime.AddMonths(-1);

            List<OTenantLease> tenantLeaseList = TablesLogic.tTenantLease.LoadList(
                (
                (TablesLogic.tTenantLease.LeaseStatus == EnumLeaseStatus.New |
                (TablesLogic.tTenantLease.LeaseStatus == EnumLeaseStatus.Renewal & TablesLogic.tTenantLease.LeaseEndDate >= readingDateTime) |
                // 2011.01.31
                // Kim Foong
                // To include the leases that are extended
                //
                (TablesLogic.tTenantLease.LeaseStatus == EnumLeaseStatus.Extended & TablesLogic.tTenantLease.LeaseEndDate >= readingDateTime)
                ) &
                TablesLogic.tTenantLease.AmosLeaseID != null &
                TablesLogic.tTenantLease.LocationID == location.ObjectID &
                TablesLogic.tTenantLease.IsDeleted == 0) |
                TablesLogic.tTenantLease.ObjectID == includingLeaseId,
                true,
                TablesLogic.tTenantLease.Tenant.ObjectName.Asc, TablesLogic.tTenantLease.LeaseStartDate.Asc);

            DataTable dt = new DataTable();
            dt.Columns.Add(new DataColumn("ObjectName"));
            dt.Columns.Add(new DataColumn("ObjectID"));
            foreach (OTenantLease lease in tenantLeaseList)
            {
                String tenantName = "";
                if (lease.Tenant != null)
                    tenantName = lease.Tenant.ObjectName;

                String startDate = "";
                if (lease.LeaseStartDate != null)
                    startDate = lease.LeaseStartDate.Value.ToString("dd-MMM-yyyy");

                String endDate = "";
                if (lease.LeaseEndDate != null)
                    endDate = lease.LeaseEndDate.Value.ToString("dd-MMM-yyyy");

                DataRow dr = dt.NewRow();
                dr["ObjectName"] = tenantName + " (" + startDate + " - " + endDate + ")";
                dr["ObjectID"] = lease.ObjectID;

                dt.Rows.Add(dr);
            }
            return dt;
        }


        public static DataTable GetNewTenantLease(Guid? includingTenantID)
        {

            List<OTenantLease> tenantLeaseList = TablesLogic.tTenantLease.LoadList(
                (
                (TablesLogic.tTenantLease.LeaseStatus == "N" |
                (TablesLogic.tTenantLease.LeaseStatus == "R") |
                // 2011.01.31
                // Kim Foong
                // To include the leases that are extended
                //
                (TablesLogic.tTenantLease.LeaseStatus == "X")
                ) &
                TablesLogic.tTenantLease.AmosLeaseID != null &
                TablesLogic.tTenantLease.IsDeleted == 0) |
                TablesLogic.tTenantLease.TenantID == includingTenantID,
                true,
                TablesLogic.tTenantLease.Tenant.ObjectName.Asc, TablesLogic.tTenantLease.LeaseStartDate.Asc);

            DataTable dt = new DataTable();
            dt.Columns.Add(new DataColumn("ObjectName"));
            dt.Columns.Add(new DataColumn("ObjectID"));
            dt.Columns.Add(new DataColumn("TenantID"));
            foreach (OTenantLease lease in tenantLeaseList)
            {
                String tenantName = "";
                if (lease.Tenant != null)
                    tenantName = lease.Tenant.ObjectName;

                String startDate = "";
                if (lease.LeaseStartDate != null)
                    startDate = lease.LeaseStartDate.Value.ToString("dd-MMM-yyyy");

                String endDate = "";
                if (lease.LeaseEndDate != null)
                    endDate = lease.LeaseEndDate.Value.ToString("dd-MMM-yyyy");

                DataRow dr = dt.NewRow();
                dr["ObjectName"] = tenantName + " (" + lease.ShopName + ")" + " (" + startDate + " - " + endDate + ")";
                dr["ObjectID"] = lease.ObjectID;
                dr["TenantID"] = lease.TenantID;
                dt.Rows.Add(dr);
            }
            return dt;
        }
    }
    [Database("#database"), Map("TenantLeaseHOTO")]
    public class TTenantLeaseHOTO : LogicLayerSchema<OTenantLeaseHOTO>
    {
        public SchemaGuid StandardHandoverItemID;
        public SchemaString Remarks;
        public SchemaDecimal QuantityHandedOver;
        public SchemaDecimal QuantityTakenOver;
        public SchemaGuid TenantLeaseID;
        public TTenantLease TenantLease { get { return OneToOne<TTenantLease>("TenantLeaseID"); } }
        public TCode StandardHandoverItem { get { return OneToMany<TCode>("StandardHandoverItemID"); } }
    }


    /// <summary>
    /// </summary>
    public abstract class OTenantLeaseHOTO : LogicLayerPersistentObject
    {
        public abstract Guid? StandardHandoverItemID { get; set; }
        public abstract String Remarks { get; set; }
        public abstract decimal? QuantityHandedOver { get; set; }
        public abstract decimal? QuantityTakenOver { get; set; }
        public abstract Guid? TenantLeaseID { get; set; }
        public abstract OTenantLease TenantLease { get; set; }
        public abstract OCode StandardHandoverItem { get; set; }
    }

    /// <summary>
    /// 
    /// </summary>
    public class EnumLeaseStatus
    {
        public const string Terminated = "T";
        public const string Expired = "E";
        public const string New = "N";
        public const string Restructured = "S";
        public const string Extended = "X";
        public const string Rescinded = "V";
        public const string Novated = "O";
        public const string Renewal = "R";

    }
}

