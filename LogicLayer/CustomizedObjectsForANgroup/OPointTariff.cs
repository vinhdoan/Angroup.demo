//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;

using Anacle.DataFramework;
using System.Collections;

namespace LogicLayer
{
    /// <summary>
    /// </summary>
    public partial class TPointTariff : LogicLayerSchema<OPointTariff>
    {
        public SchemaGuid LocationID;
        public SchemaDecimal DefaultTariff;
        public SchemaDecimal DefaultDiscount;

        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
    }



    public abstract partial class OPointTariff : LogicLayerPersistentObject, IHierarchy, IAuditTrailEnabled
    {
        public abstract Guid? LocationID { get; set; }
        public abstract decimal? DefaultTariff { get; set; }
        public abstract decimal? DefaultDiscount { get; set; }

        public abstract OLocation Location { get; set; }


        public override string AuditObjectDescription
        {
            get
            {
                if (this.Location != null)
                    return this.Location.ObjectName;
                return "";
            }
        }


        /// <summary>
        /// Updates all Points's tariffs and discounts.
        /// </summary>
        public override void Saving()
        {
            base.Saving();
            UpdatePointTariffsAndDiscounts();
        }


        /// <summary>
        /// Updates the tariffs and discounts for all
        /// active points and points that are not locked.
        /// </summary>
        public void UpdatePointTariffsAndDiscounts()
        {
            List<OPoint> points = TablesLogic.tPoint.LoadList(
                TablesLogic.tPoint.Location.HierarchyPath.Like(this.Location.HierarchyPath + "%") &
                TablesLogic.tPoint.IsActive == 1 &
                TablesLogic.tPoint.IsLock == 0);

            using (Connection c = new Connection())
            {
                foreach (OPoint point in points)
                {
                    point.Tariff = this.DefaultTariff;
                    point.Discount = this.DefaultDiscount;
                    point.Save();
                }
                c.Commit();
            }
        }


        /// <summary>
        /// Validates to ensure that there is no other
        /// point tariff set up at the same location.
        /// </summary>
        /// <returns></returns>
        public bool ValidateNoDuplicateLocation()
        {
            if ((int)TablesLogic.tPointTariff.Select(
                TablesLogic.tPointTariff.ObjectID.Count())
                .Where(
                TablesLogic.tPointTariff.IsDeleted == 0 &
                TablesLogic.tPointTariff.LocationID == this.LocationID &
                TablesLogic.tPointTariff.ObjectID != this.ObjectID) > 0)
                return false;

            return true;
        }

        
        /// <summary>
        /// Mass update the tariff and discounts.
        /// </summary>
        public static void MassUpdateTariffAndDiscounts(List<Guid> pointTariffIds, decimal newTariff, decimal newDiscount)
        {
            List<OPointTariff> pointTariffs = TablesLogic.tPointTariff.LoadList(
                TablesLogic.tPointTariff.ObjectID.In(pointTariffIds));

            using (Connection c = new Connection())
            {
                foreach (OPointTariff pointTariff in pointTariffs)
                {
                    pointTariff.DefaultTariff = newTariff;
                    pointTariff.DefaultDiscount = newDiscount;
                    pointTariff.Save();
                }
                c.Commit();
            }
        }
    }
}
