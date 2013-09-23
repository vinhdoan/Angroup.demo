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
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using BarcodeLib;
using Anacle.DataFramework;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
namespace LogicLayer
{
  public partial class TEquipment : LogicLayerSchema<OEquipment>
    {
      public SchemaGuid ReminderUser1ID;
      public SchemaGuid ReminderUser2ID;
      public SchemaGuid ReminderUser3ID;
      public SchemaGuid ReminderUser4ID;
      
      [Default(0)]
      public SchemaInt EndReminderDays1;
      public SchemaInt EndReminderDays2;
      public SchemaInt EndReminderDays3;
      public SchemaInt EndReminderDays4;

      public SchemaDateTime LastReminderDate;

      public TEquipmentReminder EquipmentReminders { get { return OneToMany<TEquipmentReminder>("EquipmentID"); } }
      public TUser ReminderUser1 { get { return OneToOne<TUser>("ReminderUser1ID"); } }
      public TUser ReminderUser2 { get { return OneToOne<TUser>("ReminderUser2ID"); } }
      public TUser ReminderUser3 { get { return OneToOne<TUser>("ReminderUser3ID"); } }
      public TUser ReminderUser4 { get { return OneToOne<TUser>("ReminderUser4ID"); } }
      //for LocationStockTake
      public SchemaInt Status;
      public SchemaInt IsMissing;
      public SchemaGuid LocationStockTakeID;
      [Size(20)]
      public SchemaString SAPFixedAssetCode ;
      public SchemaString Make;
      [Size(255)]
      public SchemaString Vendor;
      public SchemaText Description;
      [Size(20)]
      public SchemaString SAPIOCenter;
      [Size(20)]
      public SchemaString SAPFixedAssetSerial;
      [Size(20)]
      public SchemaString PurchaseOrderNumber;
      [Size(20)]
      public SchemaString Ownership;
      [Size(20)]
      public SchemaString Division;
      [Size(20)]
      public SchemaString Department;
      [Size(10)]
      public SchemaString SoftwareVersionNumber;
      //[Default(0)]
      // public SchemaInt IsWrittenOff;
      public TStore Store { get { return OneToOne<TStore>("StoreID"); } }

      public SchemaGuid CurrencyID;
      public SchemaInt WarrantyPeriod;
      public SchemaString WarrantyUnit;
      public SchemaString Warranty;
      public SchemaString InvoiceNumber;
      public SchemaGuid PurchaseOrderID;
      public TCurrency Currency { get { return OneToOne<TCurrency>("CurrencyID"); } }
      public SchemaDecimal PriceAtCurrency;

      public SchemaInt VolumeLicense;
      public SchemaInt IsSharedOwnership;
      public SchemaDecimal OwnershipPercentage;

      public SchemaInt Designation;
    }


    /// <summary>
    /// Represents a equipment or a folder of equipment. 
    /// The equipment is a hierarchical structure that may
    /// contain the main equipment assembly and its sub-assemblies.
    /// Each equipment, regardless of its assembly structure,
    /// must be associated with a location.
    /// </summary>
    public abstract partial class OEquipment : LogicLayerPersistentObject, IHierarchy
    {
        public abstract Guid? ReminderUser1ID { get; set; }
        public abstract Guid? ReminderUser2ID { get; set; }
        public abstract Guid? ReminderUser3ID { get; set; }
        public abstract Guid? ReminderUser4ID { get; set; }
        public abstract int? WarrantyPeriod { get; set; }
        public abstract string WarrantyUnit { get; set; }
        public abstract string Warranty { get; set; }
        public abstract string InvoiceNumber { get; set; }
        public abstract Guid? PurchaseOrderID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of 
        /// days left before the end of the 
        /// contract to send out a reminder e-mail.
        /// The user can specify up to 4 periods.
        /// </summary>
        public abstract int? EndReminderDays1 { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of 
        /// days left before the end of the 
        /// contract to send out a reminder e-mail.
        /// The user can specify up to 4 periods.
        /// </summary>
        public abstract int? EndReminderDays2 { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of 
        /// days left before the end of the 
        /// contract to send out a reminder e-mail.
        /// The user can specify up to 4 periods.
        /// </summary>
        public abstract int? EndReminderDays3 { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of 
        /// days left before the end of the 
        /// contract to send out a reminder e-mail.
        /// The user can specify up to 4 periods.
        /// </summary>
        public abstract int? EndReminderDays4 { get; set; }

        /// <summary>
        /// [Column] Gets or sets the last date
        /// that a reminder was sent.
        /// </summary>
        public abstract DateTime? LastReminderDate { get; set; }

        public abstract DataList<OEquipmentReminder> EquipmentReminders { get; set; }
        public abstract OUser ReminderUser1 { get; set; }
        public abstract OUser ReminderUser2 { get; set; }
        public abstract OUser ReminderUser3 { get; set; }
        public abstract OUser ReminderUser4 { get; set; }
        public abstract int? Status { get; set; }
        public abstract String Make { get; set; }
        public abstract String Vendor { get; set; }
        public abstract String Description { get; set; }
        public abstract String SAPIOCenter { get; set; }
        public abstract String SAPFixedAssetSerial { get; set; }
        public abstract String PurchaseOrderNumber { get; set; }
        public abstract String Ownership { get; set; }
        public abstract String Division { get; set; }
        public abstract String Department { get; set; }
        public abstract String SoftwareVersionNumber { get; set; }

        /// <summary>
        /// [Column] Gets or sets the Currency
        /// </summary>
        public abstract Guid? CurrencyID { get; set; }
        public abstract OCurrency Currency { get; set; }
        /// <summary>
        /// [Column] Gets or sets the Price at the Currency
        /// </summary>
        public abstract decimal? PriceAtCurrency { get; set; }
        /// <summary>
        /// [Column] Gets or sets the number of bulk licenses
        /// </summary>
        public abstract int? VolumeLicense { get; set; }
        public abstract int? IsSharedOwnership { get; set; }
        public abstract decimal? OwnershipPercentage { get; set; }
        /// <summary>
        /// [Column] Gets or sets the Designation, Production/Testing environment (Capitaland-IT)
        /// </summary>
        public abstract int? Designation { get; set; }

        /// <summary>
        /// [Column] Gets or sets the availability 
        /// of this equipment
        /// </summary>
        public abstract int? IsMissing { get; set; }

        /// <summary>
        /// [Column] Gets or sets the LocationStockTakeID 
        /// of this equipment, indicating whether this equipment
        /// is created by a LocationStockTake
        /// </summary>
        public abstract Guid? LocationStockTakeID { get; set; }

        public abstract string SAPFixedAssetCode { get; set; }
        //public abstract int? IsWrittenOff {get;set;}
        public abstract OStore Store { get; set; }

        /// <summary>
        /// To generate a datatable that can be used by barcode print out template in RDL.
        /// </summary>
        /// <param name="p_al_EquipmentID"></param>
        /// <returns></returns>
        ///
        public static DataTable GenerateBarcodePrintOutData(ArrayList p_al_EquipmentID)
        {
            DataTable Result = new DataTable();
            Result.TableName = "Body";
            if (p_al_EquipmentID != null)
            {
                Result = (DataTable)TablesLogic.tEquipment.Select(
                    TablesLogic.tEquipment.Barcode.As("TagNumber"))
                    .Where(
                    TablesLogic.tEquipment.ObjectID.In(p_al_EquipmentID))
                    .OrderBy(
                    TablesLogic.tEquipment.Barcode.Asc);

                Result.Columns.Add("TagNumberBarcode");
                Barcode B = new Barcode();
                System.Drawing.Image BarcodeImage = null;
                foreach (DataRow dr in Result.Rows)
                {
                    string barcode = "NO BARCODE";
                    if (dr["TagNumber"] == DBNull.Value || dr["TagNumber"].ToString().Trim() == "")
                        dr["TagNumber"] = barcode;

                    string s = "";
                    foreach (char c in dr["TagNumber"].ToString())
                        if ((int)c < 128)
                            s = s + c;
                        else
                            s = s + "?";
                    dr["TagNumber"] = s;
                    BarcodeImage = B.Encode(TYPE.CODE128B, dr["TagNumber"].ToString(), Color.Black, Color.White, 180, 40);
                    dr["TagNumberBarcode"] = Convert.ToBase64String(ImageToByte(BarcodeImage, ImageFormat.Png));
                }
            }
            return Result;
        }
        protected static byte[] ImageToByte(System.Drawing.Image img, ImageFormat imageFormat)
        {
            byte[] byteArray = new byte[0];
            using (MemoryStream stream = new MemoryStream())
            {
                img.Save(stream, imageFormat);
                stream.Close();
                byteArray = stream.ToArray();
            }
            return byteArray;
        }
        public void WriteOff()
        {
            using (Connection c = new Connection())
            {
                //this.IsWrittenOff = 1; 
                OStoreBinItem storeBinItem = TablesLogic.tStoreBinItem.Load(this.StoreBinItemID);
                if (storeBinItem != null)
                    storeBinItem.PhysicalQuantity = 0;
                storeBinItem.Save();
                this.Save();
                c.Commit();
            }

        }
        //public string IsWrittenOffText
        //{
        //    get
        //    {
        //        if (this.IsWrittenOff == 1)
        //            return "Yes";
        //        else
        //            return "No";
        //    }
        //}
        public string EquipmentStatus
        {
            get
            {
                switch (this.Status)
                {
                    case 0:
                        return Resources.Strings.EquipmentStatus_PendingAcceptance;
                    case 1:
                        return Resources.Strings.EquipmentStatus_Confirmed;
                    case 2:
                        return Resources.Strings.EquipmentStatus_PendingWriteOff;
                    case 3:
                        return Resources.Strings.EquipmentStatus_Retired;
                    case 4:
                        return Resources.Strings.EquipmentStatus_Active;
                    case 5:
                        return Resources.Strings.EquipmentStatus_Damaged;
                    case 6:
                        return Resources.Strings.EquipmentStatus_InRepair;
                    case 7:
                        return Resources.Strings.EquipmentStatus_WrittenOff;
                    default:
                        return Resources.Strings.EquipmentStatus_Active;
                }
            }
        }
        //---------------------------------------------------------------
        /// <summary>
        /// Get a list of equipment under the current equipment/system 
        /// that are of a specified type.
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public List<OEquipment> GetEquipmentByEquipmentType(OEquipmentType type)
        {
            Guid? typeId = null;
            if (type != null)
                typeId = type.ObjectID;

            return TablesLogic.tEquipment[
                TablesLogic.tEquipment.IsPhysicalEquipment == 1 &
                TablesLogic.tEquipment.HierarchyPath.Like(this.HierarchyPath + "%") &
                TablesLogic.tEquipment.EquipmentTypeID == typeId &
                (TablesLogic.tEquipment.Status != EquipmentStatusType.WrittenOff | TablesLogic.tEquipment.Status == null)];
        }
        public static DataTable EquipmentStatusTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("StatusName");
            dt.Columns.Add("StatusValue", typeof(int));
            dt.Rows.Add(new object[] { Resources.Strings.EquipmentStatus_Active, EquipmentStatusType.Active });
            dt.Rows.Add(new object[] { Resources.Strings.EquipmentStatus_Damaged, EquipmentStatusType.Damaged });
            dt.Rows.Add(new object[] { Resources.Strings.EquipmentStatus_InRepair, EquipmentStatusType.InRepair });
            dt.Rows.Add(new object[] { Resources.Strings.EquipmentStatus_PendingWriteOff, EquipmentStatusType.PendingWriteOff });
            dt.Rows.Add(new object[] { Resources.Strings.EquipmentStatus_WrittenOff, EquipmentStatusType.WrittenOff });
            //dt.Rows.Add(new object[]{Resources.Strings.EquipmentStatus_PendingAcceptance,EquipmentStatusType.PendingAcceptance});
            //dt.Rows.Add(new object[] { Resources.Strings.EquipmentStatus_Confirmed, EquipmentStatusType.Confirmed });
            //dt.Rows.Add(new object[] { Resources.Strings.EquipmentStatus_Retired, EquipmentStatusType.Retired });
            
            return dt;

        }
        public string PurchaseOrderInvoiceNumbers()
        {
            
            DataTable dt = TablesLogic.tPurchaseInvoice.Select(TablesLogic.tPurchaseInvoice.ReferenceNumber)
                .Where(TablesLogic.tPurchaseInvoice.PurchaseOrderID == this.PurchaseOrderID &
                TablesLogic.tPurchaseInvoice.CurrentActivity.ObjectName == "Approved" &
                TablesLogic.tPurchaseInvoice.InvoiceType == 0);
            string subString = "";
            int key = 0;
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (dt.Rows[i][0].ToString() != "")
                {
                    key++;
                    if(key==1)
                        subString += dt.Rows[i][0].ToString();
                    else
                        subString += ", " + dt.Rows[i][0].ToString();
                }
            }
            
            return subString;
        }
        public override void Saving2()
        {
            base.Saving2();
            if (System.Configuration.ConfigurationManager.AppSettings["CustomizedInstance"] == "CHINAOPS" && this.IsPhysicalEquipment == 1)
            {
                string objectTypeName = "OEquipment";
                string codes="["+getEquipmentTypeRunningNumber()+"]"+"["+getLocationRunningNumber() + "]";
                int number = ORunningNumber.GenerateNextNumber(DateTime.Now, objectTypeName, codes);
                this.ObjectNumber = getLocationRunningNumber() + "-" + getEquipmentTypeRunningNumber() + "-" +number.ToString("00000000");
            }
        }
        public string getLocationRunningNumber()
        {
           
            DataTable ls = TablesLogic.tLocation.Select(
                TablesLogic.tLocation.RunningNumberCode,
                TablesLogic.tLocation.Parent.RunningNumberCode,
                TablesLogic.tLocation.Parent.Parent.RunningNumberCode,
                TablesLogic.tLocation.Parent.Parent.Parent.RunningNumberCode,
                TablesLogic.tLocation.Parent.Parent.Parent.Parent.RunningNumberCode,
                TablesLogic.tLocation.Parent.Parent.Parent.Parent.Parent.RunningNumberCode,
                TablesLogic.tLocation.Parent.Parent.Parent.Parent.Parent.Parent.RunningNumberCode,
                TablesLogic.tLocation.Parent.Parent.Parent.Parent.Parent.Parent.Parent.RunningNumberCode,
                TablesLogic.tLocation.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.RunningNumberCode,
                TablesLogic.tLocation.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.RunningNumberCode)
             .Where(
                 TablesLogic.tLocation.ObjectID == this.LocationID);

            foreach (DataRow dr in ls.Rows)
            {
                foreach (object id in dr.ItemArray)
                    if (id != DBNull.Value)
                    {
                        return id.ToString();
                    }
            }
        
            return "";
        }
        public string getEquipmentTypeRunningNumber()
        {
            DataTable ls = TablesLogic.tEquipmentType.Select(
               TablesLogic.tEquipmentType.RunningNumberCode,
               TablesLogic.tEquipmentType.Parent.RunningNumberCode,
               TablesLogic.tEquipmentType.Parent.Parent.RunningNumberCode,
               TablesLogic.tEquipmentType.Parent.Parent.Parent.RunningNumberCode,
               TablesLogic.tEquipmentType.Parent.Parent.Parent.Parent.RunningNumberCode,
               TablesLogic.tEquipmentType.Parent.Parent.Parent.Parent.Parent.RunningNumberCode,
               TablesLogic.tEquipmentType.Parent.Parent.Parent.Parent.Parent.Parent.RunningNumberCode,
               TablesLogic.tEquipmentType.Parent.Parent.Parent.Parent.Parent.Parent.Parent.RunningNumberCode,
               TablesLogic.tEquipmentType.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.RunningNumberCode,
               TablesLogic.tEquipmentType.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.RunningNumberCode)
            .Where(
                TablesLogic.tEquipmentType.ObjectID == this.EquipmentTypeID);

            foreach (DataRow dr in ls.Rows)
            {
                foreach (object id in dr.ItemArray)
                    if (id != DBNull.Value)
                    {
                        return id.ToString();
                    }
            }

            return "";
           
        }
    }
    public class EquipmentStatusType
    {
        public const int PendingAcceptance = 0;
        public const int Confirmed = 1;
        public const int PendingWriteOff = 2;
        public const int Retired = 3;
        public const int Active = 4;
        public const int Damaged = 5;
        public const int InRepair = 6;
        public const int WrittenOff = 7;
    }

    /// <summary>
    /// 15th Dec 2010 - CM
    /// Added for Capitaland-IT
    /// </summary>
    public class EquipmentDesignation
    {
        public const int Testing = 0;
        public const int Production = 1;
    }
}
