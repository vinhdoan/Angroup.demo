//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    public class TOPCAEServer : LogicLayerSchema<OOPCAEServer>
    {
        [Size(255)]
        public SchemaString Description;
        [Default(1)]
        public SchemaInt ReceivingEventsEnabled;
        public SchemaInt SampleIntervalInMinutes;
        [Default(5000)]
        public SchemaInt BufferTimeInMilliseconds;
        [Default(20)]
        public SchemaInt MaxNumberOfEventsPerCallback;
        public SchemaInt NumberOfMinutesToKeepHistory;

        public TOPCAEEvent OPCAEEvents { get { return OneToMany<TOPCAEEvent>("OPCAEServerID"); } }
    }


    /// <summary>
    /// Represents an OPC AE Server record that contains a group of
    /// points. 
    /// </summary>
    [Serializable]
    public abstract class OOPCAEServer : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the description of the 
        /// AE server.
        /// </summary>
        public abstract String Description { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating whether
        /// this receiving events from this AE server is enabled.
        /// </summary>
        public abstract int? ReceivingEventsEnabled { get; set; }

        /// <summary>
        /// [Column] Gets or sets the sampling interval in
        /// the number of minutes. For performance reasons, 
        /// this applies to all points in this OPC AE Server
        /// group.
        /// </summary>
        public abstract int? SampleIntervalInMinutes { get; set; }

        /// <summary>
        /// [Column] Gets or sets the buffer is in milliseconds. 
        /// This tells the server how often to send event notifications. 
        /// This is a minimum time - do not send event notifications 
        /// any faster that this is greater than 0, in which case the 
        /// server will send an event notification sooner to obey the 
        /// dwMaxSize parameter. 
        /// <para></para>
        /// A value of 0 means that the server should send event 
        /// notifications as soon as it gets them. 
        /// This parameter along with the dwMaxSize parameter are 
        /// used to improve communications efficiency between client 
        /// and server. 
        /// <para></para>
        /// This parameter is a recommendation from the client, and 
        /// the server is allowed to ignore the parameter. 
        /// </summary>
        public abstract int? BufferTimeInMilliseconds { get; set; }

        /// <summary>
        /// [Column] The requested maximum number of events that will 
        /// be sent in a single callback. A value of 0 means that there is 
        /// no limit to the number of events that will be sent in a single 
        /// callback. 
        /// <para></para>
        /// Note that a value greater than 0, may cause the server to 
        /// call the OnEvent callback more frequently than specified in the BufferTime 
        /// parameter when a large number of events are being generated in 
        /// order to limit the number of events to the MaxSize. 
        /// <para></para>
        /// This parameter is a recommendation from the client and the server is 
        /// allowed to ignore this parameter. 
        /// </summary>
        public abstract int? MaxNumberOfEventsPerCallback { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of minutes to
        /// keep the reading history. For performance reasons, 
        /// this applies to all points in this OPC AE Server
        /// group.
        /// </summary>
        public abstract int? NumberOfMinutesToKeepHistory { get; set; }

        /// <summary>
        /// Gets a list of OPoint objects represent the
        /// list of points associated with this OPC AE
        /// server.
        /// </summary>
        public abstract DataList<OOPCAEEvent> OPCAEEvents { get; }

        /// <summary>
        /// Returns a string of text representing whether
        /// receiving events from this AE server is enabled.
        /// </summary>
        public string ReceivingEventsEnabledText
        {
            get
            {
                if (ReceivingEventsEnabled == 0)
                    return Resources.Strings.General_No;
                else if (ReceivingEventsEnabled == 1)
                    return Resources.Strings.General_Yes;
                return "";
            }
        }

        /// <summary>
        /// Returns a flag indicating whether the OPC AE
        /// server object can be deactivated. It can be deactivated
        /// if:
        /// <list>
        ///     <item>1 - There are points associated with the
        ///     OPC AE server object.</item>
        /// </list>
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if ((int)TablesLogic.
                tOPCAEEvent.Select(TablesLogic.tOPCAEEvent.ObjectID.Count())
                .Where(
                TablesLogic.tOPCAEEvent.IsDeleted == 0 &
                TablesLogic.tOPCAEEvent.OPCAEServerID == this.ObjectID) > 0)
                return false;

            return base.IsDeactivatable();
        }


        /// <summary>
        /// Gets a list of all OPC AE servers.
        /// </summary>
        /// <returns></returns>
        public static List<OOPCAEServer> GetAllOPCAEServers()
        {
            return TablesLogic.tOPCAEServer.LoadAll();
        }
    }
}

