using System;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Created by David
    /// </summary>
    public partial class TCampaign : LogicLayerSchema<OCampaign>
    {
        public TLocation LocationsForCampaigns { get { return ManyToMany<TLocation>("CampaignLocation","CampaignID","LocationID"); } }
    }


    /// <summary>
    /// Represents a variation log on the budget.
    /// </summary> 
    public abstract partial class OCampaign : LogicLayerPersistentObject
    {
        public abstract DataList<OLocation> LocationsForCampaigns { get; set; }
        //public static List<OCampaign> GetCampaignsFromLocation(Guid? locationID )
        //{
        //    return TablesLogic.tCampaign.LoadList(
        //        TablesLogic.tLocation.ObjectID==locationID&
        //}
    }
}
