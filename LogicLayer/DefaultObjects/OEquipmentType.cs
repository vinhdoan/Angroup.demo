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
    [Database("#database"), Map("EquipmentType")]
    [Serializable] public partial class TEquipmentType : LogicLayerSchema<OEquipmentType>
    {
        public SchemaInt IsLeafType;
        public SchemaInt IsReportableType;
        public SchemaGuid CatalogueID;
        public SchemaString RunningNumberCode;

        public TEquipmentType Children { get { return OneToMany<TEquipmentType>("ParentID"); } }
        public TEquipmentType Parent { get { return OneToOne<TEquipmentType>("ParentID"); } }

        public TEquipment Equipment { get { return OneToMany<TEquipment>("EquipmentTypeID"); } }
        public TEquipmentTypePoint EquipmentTypePoints { get { return OneToMany<TEquipmentTypePoint>("EquipmentTypeID"); } }
        public TEquipmentTypeSpare EquipmentTypeSpares { get { return OneToMany<TEquipmentTypeSpare>("EquipmentTypeID"); } }
        public TCatalogue Catalog { get { return OneToOne<TCatalogue>("CatalogueID"); } }
    }


    /// <summary>
    /// Represents an equipment type or a folder for containing equipment types.
    /// </summary>
    public abstract partial class OEquipmentType : LogicLayerPersistentObject, IHierarchy
    {
        /// <summary>
        /// [Column] Gets or sets a value that 
        /// indicates whether this is a leaf type.
        /// </summary>
        public abstract int? IsLeafType { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates whether
        /// equipment of this equipment type is used for reporting.
        /// </summary>
        public abstract int? IsReportableType { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to
        /// the Catalog table that indicates the
        /// catalog object associated with this
        /// equipment type. Note that the Catalog table also
        /// has a EquipmentTypeID foreign key that
        /// joins this EquipmentType table.
        /// </summary>
        public abstract Guid? CatalogueID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a running number code that 
        /// can be added to an Equipment if set up
        /// in the Running Number Generator.
        /// </summary>
        public abstract String RunningNumberCode { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OEquipmentType
        /// objects that represents the next level
        /// equipment type under this current one.
        /// </summary>
        public abstract DataList<OEquipmentType> Children { get; }

        /// <summary>
        /// Gets or sets the OEquipmentType object 
        /// that represents the parent equipment 
        /// type this current one belongs under.
        /// </summary>
        public abstract OEquipmentType Parent { get; }

        /// <summary>
        /// Gets a one-to-many list of OEquipment
        /// objects that represents the list of
        /// equipment that associated with this
        /// equipment type.
        /// </summary>
        public abstract DataList<OEquipment> Equipment { get; }
               
        /// <summary>
        /// Gets a one-to-many list of 
        /// OEquipmenTypePoint objects that 
        /// represents the list of points 
        /// associated with this equipment type.
        /// </summary>
        public abstract DataList<OEquipmentTypePoint> EquipmentTypePoints { get; }

        /// <summary>
        /// Gets a one-to-many list of 
        /// OEquipmentTypeSpare objects that 
        /// represents the list of spares associated 
        /// with this equipment type.
        /// </summary>
        public abstract DataList<OEquipmentTypeSpare> EquipmentTypeSpares { get; }


        /// <summary>
        /// Gets the catalog object that is associated to this 
        /// equipment type object. This property always returns
        /// a valid Catalog object.
        /// </summary>
        public abstract OCatalogue Catalog { get; set; }


        /// <summary>
        /// Overrides the Saving method to create a associated
        /// OCatalogue object or update its name and ParentID 
        /// if it exists.
        /// </summary>
        public override void Saving()
        {
            base.Saving();

            if (this.Catalog == null)
            {
                OCatalogue catalog = TablesLogic.tCatalogue.Create();
                this.Catalog = catalog;
            }
            this.Catalog.ObjectName = this.ObjectName;
            this.Catalog.EquipmentTypeID = this.ObjectID;
            this.Catalog.IsGeneratedFromEquipmentType = 1;
            
            // This ensures that an equipment type folder 
            // must also correspond to a catalog folder
            // as well.
            //
            this.Catalog.IsCatalogueItem = this.IsLeafType;

            if (this.Catalog.IsCatalogueItem == 1)
            {
                this.Catalog.InventoryCatalogType = InventoryCatalogType.Equipment;
                this.Catalog.UnitOfMeasureID = OApplicationSetting.Current.EquipmentUnitOfMeasureID;
                if (this.Catalog.UnitOfMeasure == null)
                    throw new Exception(Resources.Strings.Equipment_UnitOfMeasureNotDefined);
            }

            // We need to determine the corresponding ObjectID
            // of the parent catalog by referring to the parent
            // equipment.
            //
            if (this.Parent != null)
                this.Catalog.ParentID = this.Parent.CatalogueID;
        }


        /// <summary>
        /// Disallows delete if the EquipmentType is defined for an existing Equipment.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if (this.ParentID == null)
                return false;

            if (Catalog !=null && !Catalog.IsDeactivableAnywhere())
                return false;

            if (TablesLogic.tEquipment.LoadList(
                TablesLogic.tEquipment.EquipmentTypeID == this.ObjectID).Count > 0)
                return false;

            return base.IsDeactivatable();
        }


        /// <summary>
        /// Overrides the Deactivating method to deactivate
        /// the Catalog.
        /// </summary>
        public override void Deactivating()
        {
            base.Deactivating();

            if (this.Catalog != null)
            {
                this.Catalog.IsGeneratedFromEquipmentType = null;
                this.Catalog.Deactivate();
            }
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Tests if the object's parent is a cyclical reference back
        /// to itself.
        /// </summary>
        /// <returns></returns>
        //---------------------------------------------------------------
        public bool IsCyclicalReference()
        {
            OEquipmentType equipmentType = this;
            while (true)
            {
                equipmentType = equipmentType.Parent;
                if (equipmentType == null)
                    return false;
                if (equipmentType.ObjectID == this.ObjectID)
                    return true;
            }
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Get all root codes.
        /// </summary>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static List<OEquipmentType> GetRootEquipmentTypes()
        {
            return TablesLogic.tEquipmentType[TablesLogic.tEquipmentType.ParentID == null];
        }


        //---------------------------------------------------------------
        /// <summary>
        /// 
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static List<OEquipmentType> FindEquipmentType(bool isLeafType, string value)
        {
            return TablesLogic.tEquipmentType[
                TablesLogic.tEquipmentType.ObjectName.Like("%" + value + "%") &
                TablesLogic.tEquipmentType.IsLeafType == (isLeafType ? 1 : 0)];
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Check if there are no equipment type spares. Returns true
        /// if there are, false otherwise.
        /// </summary>
        /// <param name="equipmentTypeSpare"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public bool HasDuplicateSpares(OEquipmentTypeSpare equipmentTypeSpare)
        {
            foreach (OEquipmentTypeSpare spare in EquipmentTypeSpares)
            {
                if (spare.ObjectID != equipmentTypeSpare.ObjectID &&
                    spare.CatalogueID == equipmentTypeSpare.CatalogueID)
                {
                    return true;
                }
            }
            return false;
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Get the list of equipment type spares in this equipment type,
        /// and all the quantity available of that item in the specified bin.
        /// </summary>
        /// <param name="storeBinId"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public DataTable GetEquipmentTypeSparesAndQuantity(Guid? storeBinId)
        {
            DataTable dt = Data.LeftJoin(
                "ObjectID",
                Query.Select(
                TablesLogic.tEquipmentTypeSpare.Catalogue.ObjectID,
                TablesLogic.tEquipmentTypeSpare.Catalogue.ObjectName,
                TablesLogic.tEquipmentTypeSpare.Catalogue.StockCode,
                TablesLogic.tEquipmentTypeSpare.Catalogue.Manufacturer,
                TablesLogic.tEquipmentTypeSpare.Catalogue.Model,
                TablesLogic.tEquipmentTypeSpare.Catalogue.UnitOfMeasure.ObjectName.As("UnitOfMeasure"),
                TablesLogic.tEquipmentTypeSpare.Quantity.As("SpareQuantity"))
                .Where(
                TablesLogic.tEquipmentTypeSpare.EquipmentTypeID == this.ObjectID &
                TablesLogic.tEquipmentTypeSpare.IsDeleted == 0),

                Query.Select(
                TablesLogic.tStoreBinItem.Catalogue.ObjectID,
                TablesLogic.tStoreBinItem.PhysicalQuantity.Sum().As("Qty"))
                .Where(
                TablesLogic.tStoreBinItem.StoreBinID == storeBinId &
                TablesLogic.tStoreBinItem.IsDeleted == 0)
                .GroupBy(
                TablesLogic.tStoreBinItem.Catalogue.ObjectID),

                Query.Select(
                TablesLogic.tStoreBinReservation.CatalogueID.As("ObjectID"),
                TablesLogic.tStoreBinReservation.BaseQuantityReserved.Sum().As("QuantityReserved"))
                .Where(
                TablesLogic.tStoreBinReservation.StoreBinID == storeBinId)
                .GroupBy(
                TablesLogic.tStoreBinReservation.CatalogueID));

            foreach (DataRow dr in dt.Rows)
            {
                decimal qty = dr["Qty"] == DBNull.Value ? 0 : (decimal)dr["Qty"];
                decimal qtyres = dr["QuantityReserved"] == DBNull.Value ? 0 : (decimal)dr["QuantityReserved"];
                dr["Qty"] = qty - qtyres;
            }

            return dt;
        }
    }
}