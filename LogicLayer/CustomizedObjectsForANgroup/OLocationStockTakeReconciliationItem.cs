//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 5.0
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

using Anacle.DataFramework; //DataFramework

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OStoreStockTakeItem
    /// </summary>
    [Database("#database"), Map("LocationStockTakeReconciliationItem")]
    public partial class TLocationStockTakeReconciliationItem : LogicLayerSchema<OLocationStockTakeReconciliationItem>
    {
        public SchemaGuid LocationStockTakeID;

        public SchemaGuid CatalogueID;
        public SchemaGuid EquipmentID;
        public SchemaGuid LocationID;
        public SchemaInt StockTakeItemType;
        public SchemaInt IsManuallyAdded;
        public SchemaGuid LocationStockTakeItemID;
        public SchemaString Barcode;

        [Size(255)]
        public SchemaString Remarks;

        /// <summary>
        /// Captures the physical quantity of the catalogue item at stock take start.
        /// </summary>
        public SchemaDecimal PhysicalQuantity;
        public SchemaDecimal ObservedQuantity;

        public SchemaInt Action;

        //for create new equipment
        public SchemaString EquipmentName;
        public SchemaGuid EquipmentParentID;
        public SchemaGuid EquipmentTypeID;
        public SchemaDateTime DateOfOwnership;
        public SchemaDecimal PriceAtOwnership;
        public SchemaString SerialNumber;

        public TCatalogue Catalogue { get { return OneToOne<TCatalogue>("CatalogueID"); } }
        public TEquipment Equipment { get { return OneToOne<TEquipment>("EquipmentID"); } }
        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
        public TLocationStockTakeItem LocationStockTakeItem { get { return OneToOne<TLocationStockTakeItem>("LocationStockTakeItemID"); } }

        public SchemaInt ReconciliationType;
        public SchemaString ScannedCode;
    }

    public abstract partial class OLocationStockTakeReconciliationItem : LogicLayerPersistentObject //WorkflowPersistentObject
    {
        public abstract Guid? LocationStockTakeID { get; set; }

        public abstract Guid? CatalogueID { get; set; }
        public abstract Guid? EquipmentID { get; set; }
        public abstract Guid? LocationID { get; set; }
        public abstract int? StockTakeItemType { get; set; }

        public abstract int? IsManuallyAdded { get; set; }
        public abstract Guid? LocationStockTakeItemID { get; set; }

        public abstract string Barcode { get; set; }
        public abstract string Remarks { get; set; }

        public abstract Decimal? PhysicalQuantity { get; set; }
        public abstract Decimal? ObservedQuantity { get; set; }


        public abstract int? Action { get; set; }

        //for new equipment
        public abstract string EquipmentName { get; set; }
        public abstract Guid? EquipmentParentID { get; set; }
        public abstract Guid? EquipmentTypeID { get; set; }
        public abstract DateTime? DateOfOwnership { get; set; }
        public abstract decimal? PriceAtOwnership { get; set; }
        public abstract string SerialNumber { get; set; }

        public abstract OCatalogue Catalogue { get; set; }
        public abstract OEquipment Equipment { get; set; }
        public abstract OLocation Location { get; set; }
        public abstract OLocationStockTakeItem LocationStockTakeItem { get; set; }
        public abstract int? ReconciliationType { get; set; }
        public abstract string ScannedCode { get; set; }
        public string ItemName
        {
            get
            {
                if (Action == LocationStockTakeReconciliationAction.CreateNewEquipment && EquipmentName != null)
                    return EquipmentName;
                else if (Action == LocationStockTakeReconciliationAction.TransferToAnotherLocation && Equipment != null)
                    return Equipment.ObjectName;
                else
                {
                    if (Catalogue == null && Equipment == null)
                        return Remarks;
                    else if (StockTakeItemType == LocationStockTakeItemType.NonConsumable && Catalogue != null)
                        return Catalogue.ObjectName;
                    else if (StockTakeItemType == LocationStockTakeItemType.Equipment && Equipment != null)
                        return Equipment.ObjectName;
                    else
                        return Remarks;
                }

            }
        }

        public string ItemType
        {
            get
            {
                if (StockTakeItemType != null && StockTakeItemType.Value == 0)
                    return Resources.Strings.LocationStockTakeItemType_Equipment;
                else
                    return Resources.Strings.LocationStockTakeItemType_NonConsumable;
            }
        }
    }


    public class LocationStockTakeReconciliationAction
    {
        public static int NoAction = 0;
        public static int MarkAsMissing = 1;
        public static int CreateNewEquipment = 2;
        public static int TransferToAnotherLocation = 3;
    }
    public class ReconciliationType
    {
        public static int ExistingButNotFound = 0;
        public static int ScannedCodeMatched = 1;
        public static int ScannedCodeNotMatched = 2;
    }
}

