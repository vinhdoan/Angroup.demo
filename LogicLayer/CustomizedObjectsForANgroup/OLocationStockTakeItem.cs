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
    [Database("#database"), Map("LocationStockTakeItem")]
    public partial class TLocationStockTakeItem : LogicLayerSchema<OLocationStockTakeItem>
    {
        public SchemaGuid LocationStockTakeID;

        public SchemaGuid CatalogueID;
        public SchemaGuid EquipmentID;
        public SchemaGuid LocationID;
        public SchemaInt StockTakeItemType;
        public SchemaInt IsManuallyAdded;
        public SchemaString Barcode;

        [Size(255)]
        public SchemaString Remarks;

        /// <summary>
        /// Captures the physical quantity of the catalogue item at stock take start.
        /// </summary>
        public SchemaDecimal PhysicalQuantity;
        public SchemaDecimal ObservedQuantity;


        public TCatalogue Catalogue { get { return OneToOne<TCatalogue>("CatalogueID"); } }
        public TEquipment Equipment { get { return OneToOne<TEquipment>("EquipmentID"); } }
        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
        public SchemaString SerialNumber;
        public SchemaString ScannedCode;
    }

    public abstract partial class OLocationStockTakeItem : LogicLayerPersistentObject //WorkflowPersistentObject
    {
        public abstract Guid? LocationStockTakeID { get; set; }

        public abstract Guid? CatalogueID { get; set; }
        public abstract Guid? EquipmentID { get; set; }
        public abstract Guid? LocationID { get; set; }
        public abstract int? StockTakeItemType { get; set; }

        public abstract int? IsManuallyAdded { get; set; }

        public abstract string Barcode { get; set; }
        public abstract string Remarks { get; set; }

        public abstract Decimal? PhysicalQuantity { get; set; }
        public abstract Decimal? ObservedQuantity { get; set; }

        public abstract OCatalogue Catalogue { get; set; }
        public abstract OEquipment Equipment { get; set; }
        public abstract OLocation Location { get; set; }
        public abstract string SerialNumber { get; set; }
        public abstract string ScannedCode { get; set; }

        public string ItemName
        {
            get
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

    public class LocationStockTakeItemType
    {
        public static int Equipment = 0;
        public static int NonConsumable = 1;
    }

}

