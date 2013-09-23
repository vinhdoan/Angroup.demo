//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TOPCDAServer : LogicLayerSchema<OOPCDAServer>
    {
        [Size(255)]
        public SchemaString Description;
        [Default(1)]
        public SchemaInt AutomaticPollingEnabled;
        public SchemaInt SampleIntervalInMinutes;
        public SchemaInt NumberOfMinutesToKeepHistory;

        public TPoint Points { get { return OneToMany<TPoint>("OPCDAServerID"); } }
    }


    /// <summary>
    /// Represents an OPC DA Server record that contains a group of
    /// points. 
    /// </summary>
    [Serializable]
    public abstract partial class OOPCDAServer : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the description of the 
        /// DA server.
        /// </summary>
        public abstract String Description { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating whether
        /// automatic polling is enabled.
        /// </summary>
        public abstract int? AutomaticPollingEnabled { get; set; }

        /// <summary>
        /// [Column] Gets or sets the sampling interval in
        /// the number of minutes. For performance reasons, 
        /// this applies to all points in this OPC DA Server
        /// group.
        /// </summary>
        public abstract int? SampleIntervalInMinutes { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of minutes to
        /// keep the reading history. For performance reasons, 
        /// this applies to all points in this OPC DA Server
        /// group.
        /// </summary>
        public abstract int? NumberOfMinutesToKeepHistory { get; set; }

        /// <summary>
        /// Gets a list of OPoint objects represent the
        /// list of points associated with this OPC DA
        /// server.
        /// </summary>
        public abstract DataList<OPoint> Points { get; }


        /// <summary>
        /// Returns a string of text representing whether
        /// receiving events from this AE server is enabled.
        /// </summary>
        public string AutomaticPollingEnabledText
        {
            get
            {
                if (AutomaticPollingEnabled == 0)
                    return Resources.Strings.General_No;
                else if (AutomaticPollingEnabled == 1)
                    return Resources.Strings.General_Yes;
                return "";
            }
        }

        /// <summary>
        /// Returns a flag indicating whether the OPC DA
        /// server object can be deactivated. It can be deactivated
        /// if:
        /// <list>
        ///     <item>1 - There are points associated with the
        ///     OPC DA server object.</item>
        /// </list>
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if ((int)TablesLogic.tPoint.Select(
                TablesLogic.tPoint.ObjectID.Count())
                .Where(
                TablesLogic.tPoint.IsDeleted == 0 &
                TablesLogic.tPoint.OPCDAServerID == this.ObjectID) > 0)
                return false;

            return base.IsDeactivatable();
        }


        /// <summary>
        /// Gets a list of all OPC DA servers.
        /// </summary>
        /// <returns></returns>
        public static List<OOPCDAServer> GetAllOPCDAServers()
        {
            return TablesLogic.tOPCDAServer.LoadAll();
        }
    }
}

