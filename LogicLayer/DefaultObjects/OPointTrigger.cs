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

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OLocationType
    /// </summary>
    [Database("#database"), Map("PointTrigger")]
    [Serializable]
    public partial class TPointTrigger : LogicLayerSchema<OPointTrigger>
    {
        public SchemaInt IsLeafType;        
        public SchemaGuid TypeOfWorkID;
        public SchemaGuid TypeOfServiceID;
        public SchemaGuid TypeOfProblemID;
        public SchemaInt Priority;
        [Size(255)]
        public SchemaString WorkDescription;
    }


    [Serializable]
    public abstract class OPointTrigger : LogicLayerPersistentObject, IHierarchy
    {
        public abstract int? IsLeafType{ get; set; }
        public abstract Guid? TypeOfWorkID{ get; set; }
        public abstract Guid? TypeOfServiceID{ get; set; }
        public abstract Guid? TypeOfProblemID{ get; set; }
        public abstract int? Priority{ get; set; }
        public abstract String WorkDescription{ get; set; }

        public String TypeOfWorkText
        {
            get {
                return TablesLogic.tCode.Load(TypeOfWorkID).ObjectName;
            }
        }

        public String TypeOfServiceText
        {
            get
            {
                return TablesLogic.tCode.Load(TypeOfServiceID).ObjectName;
            }
        }

        public String TypeOfProblemText
        {
            get
            {
                return TablesLogic.tCode.Load(TypeOfProblemID).ObjectName;
            }
        }

        public String PriorityText
        {
            get
            {
                switch (Priority)
                {
                    case 0: return Resources.Strings.Priority_0;
                    case 1: return Resources.Strings.Priority_1; 
                    case 2: return Resources.Strings.Priority_2; 
                    case 3: return Resources.Strings.Priority_3;
                    default: return "";
                }
            }
        }


        /// <summary>
        /// Disallow delete if:
        /// <para></para>
        /// 1. There is at least one point or one OPCAEEvent
        /// that uses this point trigger.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if ((int)TablesLogic.tPoint.Select(
                TablesLogic.tPoint.ObjectID.Count())
                .Where(
                TablesLogic.tPoint.IsDeleted == 0 &
                TablesLogic.tPoint.PointTriggerID == this.ObjectID) > 0)
                return false;

            if ((int)TablesLogic.tOPCAEEvent.Select(
                TablesLogic.tOPCAEEvent.ObjectID.Count())
                .Where(
                TablesLogic.tOPCAEEvent.IsDeleted == 0 &
                TablesLogic.tOPCAEEvent.PointTriggerID == this.ObjectID) > 0)
                return false;

            return true;
        }
    }
}
   

