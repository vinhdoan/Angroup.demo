//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.IO.Ports;
using System.Configuration;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.ServiceProcess;
using System.Text;
using System.Net;
using System.Net.Mail;
using System.Web;
using System.Web.Services;
using Anacle.DataFramework;
using LogicLayer;
using System.Collections;

namespace Service
{
    public partial class PositionAssignmentService : AnacleServiceBase
    {

        /// <summary>
        /// Executes the service.
        /// </summary>
        public override void OnExecute()
        {
            DateTime now = DateTime.Now;

            using (Connection c = new Connection())
            {
                // Gets all the list of positions that are due to be added
                // to user's accounts.
                //
                List<OUserDelegatedPosition> delegatedPositions = 
                    TablesLogic.tUserDelegatedPosition.LoadList(
                    TablesLogic.tUserDelegatedPosition.DelegatedByUserID != null &
                    (TablesLogic.tUserDelegatedPosition.AssignedFlag == (int)EnumPositionAssignedFlag.NotAssigned &
                    TablesLogic.tUserDelegatedPosition.StartDate !=null &
                    TablesLogic.tUserDelegatedPosition.StartDate < now) |
                    (TablesLogic.tUserDelegatedPosition.EndDate != null &
                    TablesLogic.tUserDelegatedPosition.EndDate < now));

                List<Guid> userIds = new List<Guid>();
                foreach (OUserDelegatedPosition p in delegatedPositions)
                {
                    if (p.StartDate != null && p.StartDate <= now)
                        p.AssignedFlag = (int)EnumPositionAssignedFlag.Assigned;
                    if (p.EndDate != null && p.EndDate <= now)
                        p.AssignedFlag = (int)EnumPositionAssignedFlag.Overdue;
                    
                    if (p.AssignedFlag == (int)EnumPositionAssignedFlag.Overdue)
                        p.Deactivate();
                    else
                        p.Save();
                    userIds.Add(p.UserID.Value);
                }

                // Gets all the list of positions that are due to be removed
                // from user's accounts.
                //
                List<OUserPermanentPosition> permanentPositions = 
                    TablesLogic.tUserPermanentPosition.LoadList(
                    (TablesLogic.tUserPermanentPosition.AssignedFlag == (int)EnumPositionAssignedFlag.NotAssigned &
                    TablesLogic.tUserPermanentPosition.StartDate !=null &
                    TablesLogic.tUserPermanentPosition.StartDate < now) |
                    (TablesLogic.tUserPermanentPosition.EndDate != null &
                    TablesLogic.tUserPermanentPosition.EndDate < now));

                foreach (OUserPermanentPosition p in permanentPositions)
                {
                    if (p.StartDate != null && p.StartDate <= now)
                        p.AssignedFlag = (int)EnumPositionAssignedFlag.Assigned;
                    if (p.EndDate != null && p.EndDate <= now)
                        p.AssignedFlag = (int)EnumPositionAssignedFlag.Overdue;

                    if (p.AssignedFlag == (int)EnumPositionAssignedFlag.Overdue)
                        p.Deactivate();
                    else
                        p.Save();
                    userIds.Add(p.UserID.Value);
                }

                // Then, load up all affected users and
                // perform the activation of the positions.
                //
                OUser.ActivateAndSaveCurrentPositions(userIds);

                c.Commit();
            }

        }

    }
}
