//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
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

using Anacle.DataFramework;

namespace LogicLayer
{
    [Database("#database"), Map("Catalogue")]
    public partial class TCatalogue : LogicLayerSchema<OCatalogue>
    {
        public SchemaInt IsCatalogueItem;
        [Default(0)]
        public SchemaInt IsGeneratedFromEquipmentType;
        public SchemaString StockCode;
        public SchemaString Manufacturer;
        public SchemaString Model;
        public SchemaGuid UnitOfMeasureID;
        public SchemaDecimal UnitPrice;
        public SchemaGuid EquipmentTypeID;
        public SchemaInt InventoryCatalogType;

        public TCatalogue Children { get { return OneToMany<TCatalogue>("ParentID"); } }
        public TCatalogue Parent { get { return OneToOne<TCatalogue>("ParentID"); } }
        public TCode UnitOfMeasure { get { return OneToOne<TCode>("UnitOfMeasureID"); } }
        public TEquipmentType EquipmentType { get { return OneToOne<TEquipmentType>("EquipmentTypeID"); } }
    }


    /// <summary>
    /// Represents a master catalogue of store items that can be tracked
    /// by this system. Apart from tracking stock code, manufacturer 
    /// information, this also tracks the standard unit price for this 
    /// item, which may then be used in a purchase agreement to cost 
    /// for purchase of store items in a purchase order.
    /// </summary>
    public abstract partial class OCatalogue : LogicLayerPersistentObject, IHierarchy
    {
        /// <summary>
        /// [Column] Gets or sets a value that indicates whether this
        /// catalogue item is catalogue type or a physical item.
        /// <para></para>
        /// 	<list>
        /// 		<item>0 - Catalogue Type</item>
        /// 		<item>1 - Catalogue Item</item>
        /// 	</list>
        /// </summary>
        public abstract int? IsCatalogueItem { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag that indicates whether
        /// this catalog object is automatically generated 
        /// from an equipment type.
        /// </summary>
        public abstract int? IsGeneratedFromEquipmentType { get; set; }
        
        /// <summary>
        /// [Column] Gets or sets the stock code of this catalogue
        /// item.
        /// </summary>
        public abstract string StockCode { get; set; }
        
        /// <summary>
        /// [Column] Gets or sets manufacture of this item.
        /// </summary>
        public abstract string Manufacturer { get; set; }
        
        /// <summary>
        /// [Column] Gets or sets model of this item.
        /// </summary>
        public abstract string Model { get; set; }
        
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table.
        /// </summary>
        public abstract Guid? UnitOfMeasureID { get; set; }
        
        /// <summary>
        /// [Column] Gets or sets the foreign key to the EquipmentType
        /// table.
        /// </summary>
        public abstract Guid? EquipmentTypeID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value indicating the type
        /// of the inventory catalog
        /// <list>
        ///     <item>0 - Consumable (like bulbs, lamps, wires)</item>
        ///     <item>1 - Non-Consumable (like chairs, tables)</item>
        ///     <item>2 - Equipment (like air-condition, AHU, HVACs, elevators)</item>
        /// </list>
        /// </summary>
        public abstract int? InventoryCatalogType { get; set; }

        /// <summary>
        /// [Column] Gets or sets the standard unit price in dollar value 
        /// of this catalogue item.
        /// </summary>
        public abstract Decimal? UnitPrice { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OCatalogue objects that represents
        /// the next level catalogue items under this current item.
        /// </summary>
        public abstract DataList<OCatalogue> Children { get; }

        /// <summary>
        /// Gets or sets the OCatalogue object that represents the 
        /// parent catalogue that this current item belongs under.
        /// </summary>
        public abstract OCatalogue Parent { get; set; }

        /// <summary>
        /// Gets or sets the OCode object that represents the unit of measure that the catalogue item belongs to.
        /// </summary>
        public abstract OCode UnitOfMeasure { get; set;}
        
        /// <summary>
        /// Gets the equipment type associated with this catalog.
        /// </summary>
        public abstract OEquipmentType EquipmentType { get; set; }


        /// <summary>
        /// [Column] 
        /// </summary>
        public string InventoryCatalogTypeText
        {
            get
            {
                if (InventoryCatalogType == LogicLayer.InventoryCatalogType.Consumable)
                    return Resources.Strings.InventoryCatalogType_Consumable;
                else if (InventoryCatalogType == LogicLayer.InventoryCatalogType.NonConsumable)
                    return Resources.Strings.InventoryCatalogType_NonConsumable;
                else if (InventoryCatalogType == LogicLayer.InventoryCatalogType.Equipment)
                    return Resources.Strings.InventoryCatalogType_Equipment;
                return "";
            }
        }


        /// <summary>
        /// Returns a flag to indicate if this Catalog is deactivatable.
        /// It is NOT deactivatable when:
        /// 1. There is at least a store item that is tied to this catalog.
        /// 2. There are undeleted contracts tied to this catalog.
        /// </summary>
        /// <returns></returns>
        public bool IsDeactivableAnywhere()
        {
            if (TablesLogic.tStore.LoadList(
                TablesLogic.tStore.StoreItems.CatalogueID == this.ObjectID &
                TablesLogic.tStore.StoreItems.IsDeleted == 0).Count > 0)
                return false;

            // If there are any undeleted contracts tied to this material
            // catalog.
            //
            if (TablesLogic.tContract.Select(TablesLogic.tContract.ObjectID.Count())
                .Where(
                TablesLogic.tContract.IsDeleted == 0 &
                TablesLogic.tContract.ContractPriceMaterials.ObjectID == this.ObjectID) > 0)
                return false;

            return true;
        }

        
        /// <summary>
        /// Disallows delete if:
        /// 1. There is at least a store item that is tied to this catalog.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if (IsGeneratedFromEquipmentType == 1)
                return false;

            if (!IsDeactivableAnywhere())
                return false;

            return base.IsDeactivatable();
        }
        
        
        //---------------------------------------------------------------
        /// <summary>
        /// 
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static List<OCatalogue> FindCatalogue(bool IsCatalogueItem, string value,
            bool showNonEquipmentTypeCatalogues, bool showEquipmentTypeCatalogues)
        {
            return TablesLogic.tCatalogue[
                (
                (showNonEquipmentTypeCatalogues ?
                TablesLogic.tCatalogue.IsGeneratedFromEquipmentType == 0 : Query.False) |
                (showEquipmentTypeCatalogues ?
                TablesLogic.tCatalogue.IsGeneratedFromEquipmentType == 1 : Query.False)
                ) &

                (TablesLogic.tCatalogue.ObjectName.Like("%" + value + "%") |
                TablesLogic.tCatalogue.StockCode.Like("%" + value + "%")) &
                TablesLogic.tCatalogue.IsCatalogueItem == (IsCatalogueItem ? 1 : 0)];
        }


        /// <summary>
        /// Gets a Yes/No text indicating whether this item is a catalogue item.
        /// </summary>
        public string IsCatalogueItemText
        {
            get
            {
                if (IsCatalogueItem == 0)
                    return "Catalog Type";
                else
                    return "Catalog Item";
            }
        }


        /// <summary>
        /// Gets the parent path up until this node in the catalogue tree.
        /// 
        /// This differs from the normal Path property in that it shows
        /// the path of the entire tree if the 
        /// </summary>
        public string DeletedItemsPath
        {
            get
            {
                string path = this.ObjectName;
                OCatalogue catalogue = this;
                while (catalogue != null)
                {

                    catalogue = TablesLogic.tCatalogue.Load(TablesLogic.tCatalogue.ObjectID == catalogue.ParentID, true);
                    if (catalogue != null)
                        path = catalogue.ObjectName + " > " + path;
                }
                return path;
            }
        }
    }


    /// <summary>
    /// Contains values enumerating all inventory catalog types.
    /// </summary>
    public class InventoryCatalogType
    {
        /// <summary>
        /// A consumable inventory. Consumables are inventory
        /// that can be consumed in a Work object for maintenance.
        /// They cannot be issued to an Issue Location store.
        /// <para></para>
        /// Each consumable inventory is a collection and individual
        /// items are not tracked separately.
        /// <para></para>
        /// Examples of consumables are bulbs, lamps, wires and
        /// other spare parts.
        /// </summary>
        public const int Consumable = 0;

        /// <summary>
        /// A non-consumable inventory. Non-consumables are inventory
        /// that cannot be consumed in a Work object for maintenance.
        /// They can be issued to an Issue Location store.
        /// <para></para>
        /// Each non-consumable is a collection, and individual items
        /// are not tracked separately.
        /// <para></para>
        /// Examples of non-consumables are chairs, tables, television,
        /// and minor equipment.
        /// </summary>
        public const int NonConsumable = 1;

        /// <summary>
        /// An equipment inventory. Equipment are capital expenditure
        /// items that cannot be used in a Work object for maintenance.
        /// They can be issued to an Issue Location store.
        /// <para></para>
        /// Each equipment inventory represents 1 unit of that equipment.
        /// Multiple equipment in the same store are represented by multiple
        /// StoreBinItem records.
        /// <para></para>
        /// Examples of non-consumables are chairs, tables, television,
        /// and minor equipment.
        /// </summary>
        public const int Equipment = 2;
    }
}