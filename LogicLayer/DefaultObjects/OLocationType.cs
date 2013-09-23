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
    /// <summary>
    /// Summary description for OLocationType
    /// </summary>
    [Database("#database"), Map("LocationType")]
    [Serializable] public partial class TLocationType : LogicLayerSchema<OLocationType>
    {
        public SchemaInt IsLeafType;
        public SchemaInt IsReportableType;

        public TLocationType Children { get { return OneToMany<TLocationType>("ParentID"); } }
        public TLocationType Parent { get { return OneToOne<TLocationType>("ParentID"); } }

        public TLocation Location { get { return OneToMany<TLocation>("LocationTypeID"); } }
        public TLocationTypePoint LocationTypePoints { get { return OneToMany<TLocationTypePoint>("LocationTypeID"); } }
        public TLocationTypeUtility LocationTypeUtilities { get { return OneToMany<TLocationTypeUtility>("LocationTypeID"); } }
    }



    public abstract partial class OLocationType : LogicLayerPersistentObject, IHierarchy
    {
        /// <summary>
        /// [Column] Gets or sets a value that indicates whether
        /// the location type is a leaf type.
        /// </summary>
        public abstract int? IsLeafType { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates whether
        /// locations of this location type is used for reporting.
        /// </summary>
        public abstract int? IsReportableType { get; set; }

        /// <summary>
        /// Gets a list of OLocationType objects that represents the location types below the current type. Note that there must NOT be any OLocationType objects below one that is a leaf type.
        /// </summary>
        public abstract DataList<OLocationType> Children { get; }

        /// <summary>
        /// Gets or sets the OLocationType object that 
        /// represents the parent location type that this 
        /// current location type belongs under.
        /// </summary>
        public abstract OLocationType Parent { get; }

        /// <summary>
        /// Gets a list of OLocation objects that represents 
        /// the list of locations that are of this location type.
        /// </summary>
        public abstract DataList<OLocation> Location { get; }

        /// <summary>
        /// Gets a list of OLocationTypePoint objects that
        /// represents a list of points associated with this
        /// current location type.
        /// </summary>
        public abstract DataList<OLocationTypePoint> LocationTypePoints { get; }

        /// <summary>
        /// Gets a list of OLocationTypeUtility objects that
        /// represents a list of utilities associated with this
        /// current location type.
        /// </summary>
        public abstract DataList<OLocationTypeUtility> LocationTypeUtilities { get; }

        /// <summary>
        /// Disallows delete if the LocationType is defined for an existing location.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if (TablesLogic.tLocation.LoadList(
                TablesLogic.tLocation.LocationTypeID == this.ObjectID).Count > 0)
                return false;

            return base.IsDeactivatable();
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
            OLocationType locationType = this;
            while (true)
            {
                locationType = locationType.Parent;
                if (locationType == null)
                    return false;
                if (locationType.ObjectID == this.ObjectID)
                    return true;
            }
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Get all root codes.
        /// </summary>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static List<OLocationType> GetRootLocationTypes()
        {
            return TablesLogic.tLocationType[TablesLogic.tLocationType.ParentID == null];
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Find location types by name and whether or not it is a 
        /// leaf node.
        /// </summary>
        /// <param name="isLeafType"></param>
        /// <param name="value"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static List<OLocationType> FindLocationType(bool isLeafType, string value)
        {
            return TablesLogic.tLocationType[
                TablesLogic.tLocationType.IsLeafType == (isLeafType ? 1 : 0) &
                TablesLogic.tLocationType.ObjectName.Like("%" + value + "%")];
        }


        public override bool IsDeactivable()
        {
            int i = (int)TablesLogic.tLocation.Select(TablesLogic.tLocation.ObjectID.Count())
                .Where(TablesLogic.tLocation.IsDeleted == 0
                & TablesLogic.tLocation.LocationTypeID == this.ObjectID);

            if (i > 0 || this.ObjectName == "All Location Types")
                return false;
            else
                return true;
        }
    }
}