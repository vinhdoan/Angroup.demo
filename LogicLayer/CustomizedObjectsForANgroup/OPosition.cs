using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TPosition: LogicLayerSchema<OPosition>
    {
        public TBudgetGroup BudgetGroups { get { return ManyToMany<TBudgetGroup>("BudgetGroupPosition", "PositionID", "BudgetGroupID");}}
        public TCode TenantContactTypes { get { return ManyToMany<TCode>("PositionTenantContactType", "PositionID", "TenantContactTypeID"); } }
        public TUserPermanentPosition PermanentUsers { get { return OneToMany<TUserPermanentPosition>("PositionID"); } }

    }

    public abstract partial class OPosition : LogicLayerPersistentObject, IAuditTrailEnabled
    {
        public abstract DataList<OBudgetGroup> BudgetGroups { get; set; }
        public abstract DataList<OCode> TenantContactTypes { get; set; }


        public string LocationAccessText
        {
            get
            {
                string strLocation = "";
                foreach (OLocation location in this.LocationAccess)
                    strLocation = strLocation == "" ? strLocation + location.ObjectName : strLocation + ", " + location.ObjectName;
                return strLocation;
            }
        }

        public string EquipmentAccessText
        {
            get
            {
                string strEquipment = "";
                foreach (OEquipment equipment in this.EquipmentAccess)
                    strEquipment = strEquipment == "" ? strEquipment + equipment.ObjectName : strEquipment + ", " + equipment.ObjectName;
                return strEquipment;
            }
        }
        /// <summary>
        /// Gets a comma-separated list of position names and the assigned users.
        /// </summary>
        public string PositionNameWithUserNames
        {
            get
            {
                string userNames = "";
                List<OUser> users = TablesLogic.tUser.LoadList(
                    TablesLogic.tUser.Positions.ObjectID.In(this.ObjectID));
                foreach (OUser user in users)
                    userNames += (userNames == "" ? "" : ", ") + user.ObjectName;
                if (userNames == "")
                    userNames = Resources.Strings.Position_NoOne;

                return this.ObjectName + " (" + userNames + ")";
            }
        }


        /// <summary>
        /// Gets or sets a one-to-many list of OUserPermanentPosition objects that 
        /// represents the users assigned to the position
        /// </summary>
        public abstract DataList<OUserPermanentPosition> PermanentUsers { get; set; }


        // 2010.07.10
        // Kim Foong
        /// <summary>
        /// Overrides the Saved method to deactivate invalid OUserPermanentPosition
        /// objects.
        /// </summary>
        public override void Saved()
        {
            base.Saved();

            List<Guid> userIdList = new List<Guid>();
            List<OUserPermanentPosition> ps = TablesLogic.tUserPermanentPosition.LoadList(
                TablesLogic.tUserPermanentPosition.UserID == null |
                TablesLogic.tUserPermanentPosition.PositionID == null);

            foreach (OUserPermanentPosition p in ps)
            {
                if (p.UserID != null)
                    userIdList.Add(p.UserID.Value);
                p.UserID = null;
                p.PositionID = null;
                p.Deactivate();
            }

            foreach (OUserPermanentPosition p in this.PermanentUsers)
                if (p.UserID != null)
                    userIdList.Add(p.UserID.Value);

            OUser.ActivateAndSaveCurrentPositions(userIdList);
        }


        // 2010.07.10
        // Kim Foong
        /// <summary>
        /// Overrides the Deactivated method to deactivate invalid OUserPermanentPosition
        /// objects.
        /// </summary>
        public override void Deactivated()
        {
            base.Deactivated();
            using (Connection c = new Connection())
            {
                List<Guid> userIdList = new List<Guid>();
                List<OUserPermanentPosition> ps = TablesLogic.tUserPermanentPosition.LoadList(
                    TablesLogic.tUserPermanentPosition.PositionID == this.ObjectID);
                foreach (OUserPermanentPosition p in ps)
                {
                    if (p.UserID != null)
                        userIdList.Add(p.UserID.Value);
                    p.UserID = null;
                    p.PositionID = null;
                    p.Deactivate();
                }

                // Deactivate the delegate position records removed
                // from this user.
                //
                List<OUserDelegatedPosition> removedDelegatedPositions = TablesLogic.tUserDelegatedPosition.LoadList(
                    TablesLogic.tUserDelegatedPosition.PositionID == this.ObjectID);
                foreach (OUserDelegatedPosition removedDelegatedPosition in removedDelegatedPositions)
                {
                    if (removedDelegatedPosition.UserID != null)
                        userIdList.Add(removedDelegatedPosition.UserID.Value);

                    removedDelegatedPosition.PositionID = null;
                    removedDelegatedPosition.UserID = null;
                    removedDelegatedPosition.DelegatedByUserID = null;
                    removedDelegatedPosition.Deactivate();
                }

                OUser.ActivateAndSaveCurrentPositions(userIdList);

                c.Commit();
            }
        }
    }

    /// <summary>
    /// 
    /// </summary>
    public enum EnumPositionAssignedFlag
    {
        NotAssigned = 0,
        Assigned = 1,
        Overdue = 2
    }
}
