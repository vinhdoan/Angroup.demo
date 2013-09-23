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
    [Database("#database"), Map("ServiceLevel")]
    [Serializable] public partial class TServiceLevel : LogicLayerSchema<OServiceLevel>
    {
        public SchemaGuid LocationID;

        public TServiceLevelDetail ServiceLevelDetails { get { return OneToMany<TServiceLevelDetail>("ServiceLevelID"); } }
        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
    }


    /// <summary>
    /// Represents a collection of limits applicable during the 
    /// execution of a work. These limits indicate the expected
    /// duration that a work is to be acknowledged by, responded 
    /// by arriving on site, and completed by.
    /// </summary>
    [Serializable] public abstract partial class OServiceLevel : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Location table 
        /// that indicates the location (and those under) that this
        /// service level applies to.
        /// </summary>
        public abstract Guid? LocationID { get;set; }

        /// <summary>
        /// Gets a one-to-many list of OServiceLevelDetail objects 
        /// that represents a list of limits categorized by the priority
        /// and types of service.
        /// </summary>
        public abstract DataList<OServiceLevelDetail> ServiceLevelDetails { get; set; }

        /// <summary>
        /// Gets or sets the OLocation object that represents
        /// the location (and those under) that this
        /// service level applies to.
        /// </summary>
        public abstract OLocation Location { get; set; }


        public OServiceLevel()
        {
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Check if a duplicate service level detail exists. A service
        /// level detail is duplicate if the following are the same:
        /// - Step Number
        /// - Type of Service
        /// - Priority
        /// Returns true if so, false otherwise.
        /// </summary>
        /// <param name="detail"></param>
        /// <returns></returns>
        //----------------------------------------------------------------
        public bool HasDuplicateServiceLevelDetail(OServiceLevelDetail detail)
        {
            foreach (OServiceLevelDetail slDetail in ServiceLevelDetails)
            {
                if (slDetail.StepNumber == detail.StepNumber &&
                    slDetail.TypeOfServiceID == detail.TypeOfServiceID &&
                    slDetail.Priority == detail.Priority &&
                    slDetail.ObjectID != detail.ObjectID)
                {
                    return true;
                }
            }
            return false;
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Checks if there is a service level defined for the same location.
        /// Returns true if so, false otherwise.
        /// </summary>
        /// <returns></returns>
        //----------------------------------------------------------------
        public bool IsDuplicateLocation()
        {
            return TablesLogic.tServiceLevel[
                TablesLogic.tServiceLevel.LocationID == this.LocationID &
                TablesLogic.tServiceLevel.ObjectID != this.ObjectID].Count > 0;

        }
    }
}

