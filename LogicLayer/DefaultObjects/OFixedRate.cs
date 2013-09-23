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
    /// <summary>
    /// Summary description for OChecklist
    /// </summary>
    [Database("#database"), Map("FixedRate")]
    [Serializable] public partial class TFixedRate : LogicLayerSchema<OFixedRate>
    {
        [Default(0)]
        public SchemaInt IsFixedRate;
        [Size(2000)]
        public SchemaString LongDescription;
        public SchemaString ItemCode;
        public SchemaDecimal UnitPrice;
        [Size(255)]
        public SchemaString PageNumber;
        public SchemaGuid UnitOfMeasureID;

        public TFixedRate Parent { get { return OneToOne<TFixedRate>("ParentID"); } }
        public TFixedRate Children { get { return OneToMany<TFixedRate>("ParentID"); } }
        public TCode UnitOfMeasure { get { return OneToOne<TCode>("UnitOfMeasureID"); } }
    }


    /// <summary>
    /// Represents a fixed rate item or a fixed rate group. A
    /// fixed rate item is a record describing services that 
    /// can be provided by an external vendor to the user's
    /// company. When used in a purchase agreement, it
    /// indicates the services and the unit price that the
    /// vendor provides to the company when a purchase order
    /// is raised for those services to the vendor.
    /// </summary>
    public abstract partial class OFixedRate : LogicLayerPersistentObject, IHierarchy
    {
        /// <summary>
        /// [Column] Gets or sets a value that indicates whether this fixed rate item is a fixed rate group or a physical item.
        /// <para></para>
        /// 	<list>
        /// 		<item>0 - Fixed Rate Group</item>
        /// 		<item>1 - Fixed Rate Item</item>
        /// 	</list>
        /// </summary>
        public abstract int? IsFixedRate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the long description for this fixed 
        /// rate item. This is represented as a TEXT field in the database, 
        /// and has no limitation on the length. In contrast, the ObjectName field 
        /// can only hold up to 255 characters. 
        /// <para></para>
        /// This is applicable only if IsFixedRate = 1.
        /// </summary>
        public abstract string LongDescription { get; set; }

        /// <summary>
        /// [Column] Gets or sets the item code for this
        /// fixed rate.
        /// </summary>
        public abstract string ItemCode { get; set; }

        /// <summary>
        /// [Column] Gets or sets the unit price of this item.
        /// </summary>
        public abstract decimal? UnitPrice { get; set; }

        /// <summary>
        /// [Column] Gets or sets the page number for this fixed rate 
        /// item. This is applicable only if IsFixedRate = 1.
        /// </summary>
        public abstract string PageNumber { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table.
        /// </summary>
        public abstract Guid? UnitOfMeasureID { get; set; }

        /// <summary>
        /// Gets or sets the OFixedRate object that represents the parent fixed rate that this current fixed rate item belongs under.
        /// </summary>
        public abstract OFixedRate Parent { get; }

        /// <summary>
        /// Gets a one-to-many list of O objects that represents the 
        /// next level fixed rate items under this current item.
        /// </summary>
        public abstract DataList<OFixedRate> Children { get; }

        /// <summary>
        /// Gets or sets the OCode object that represents the unit of 
        /// measure for this item.
        /// </summary>
        public abstract OCode UnitOfMeasure { get; }


        /// <summary>
        /// Overriden to prevent deactivation.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            // If there are any undeleted contracts tied to this service
            // catalog.
            //
            if (TablesLogic.tContract.Select(TablesLogic.tContract.ObjectID.Count())
                .Where(
                TablesLogic.tContract.IsDeleted == 0 &
                TablesLogic.tContract.ContractPriceServices.ObjectID == this.ObjectID) > 0)
                return false;

            return true;
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Search for a fixed rate book/folder/item based on the
        /// name.
        /// </summary>
        /// <param name="isFixedRate"></param>
        /// <param name="value"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static List<OFixedRate> FindFixedRate(bool isFixedRate, string value)
        {
            return TablesLogic.tFixedRate[
                TablesLogic.tFixedRate.ObjectName.Like("%" + value + "%") &
                TablesLogic.tFixedRate.IsFixedRate == (isFixedRate ? 1 : 0)];
        }


    }
    
}

