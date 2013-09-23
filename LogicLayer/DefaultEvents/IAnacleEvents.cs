//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//
// WARNING:
// CHANGES TO THIS CODE ARE DISCOURAGED.
// This is due to the fact that the Windows Workflow Foundation
// uses the .NET Serializer to serialize and deserialize during
// the workflow persistence and rehydration. If there are mismatches
// in the classes', fields' names and types, rehydration may fail
// and all existing running workflows will cease to work.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;

using System.Workflow.Activities;
using System.Reflection;

namespace LogicLayer.Events
{
    //===========================================================
    // NOTE: YOU CAN ADD NEW EVENTS, BUT EXISTING
    // EVENTS MUST NEVER BE REMOVED
    //===========================================================

    /// <summary>
    /// Represents a series of events that can be triggered
    /// on a workflow instance.
    /// <para></para>
    /// These events exist for the purpose of providing a
    /// name to the events, but provide no additional 
    /// business logic to them.
    /// </summary>
    [ExternalDataExchange]
    public partial interface IAnacleEvents
    {
        //===========================================================
        // NOTE: YOU CAN ADD NEW EVENTS, BUT EXISTING
        // EVENTS MUST NEVER BE REMOVED
        //===========================================================

        //-----------------------------------------------------------
        // Moving forward actions.
        //-----------------------------------------------------------
        event EventHandler<ExternalDataEventArgs> Accept;
        event EventHandler<ExternalDataEventArgs> Activate;
        event EventHandler<ExternalDataEventArgs> Approve;
        event EventHandler<ExternalDataEventArgs> Assign;
        event EventHandler<ExternalDataEventArgs> Agree;
        event EventHandler<ExternalDataEventArgs> Award;
        event EventHandler<ExternalDataEventArgs> Cancel;
        event EventHandler<ExternalDataEventArgs> Close;
        event EventHandler<ExternalDataEventArgs> Collect;
        event EventHandler<ExternalDataEventArgs> Commit;
        event EventHandler<ExternalDataEventArgs> Complete;
        event EventHandler<ExternalDataEventArgs> Confirm;
        event EventHandler<ExternalDataEventArgs> Consent;
        event EventHandler<ExternalDataEventArgs> Deliver;
        event EventHandler<ExternalDataEventArgs> End;
        event EventHandler<ExternalDataEventArgs> Execute;
        event EventHandler<ExternalDataEventArgs> Evaluate;
        event EventHandler<ExternalDataEventArgs> Finalize;
        event EventHandler<ExternalDataEventArgs> Plan;
        event EventHandler<ExternalDataEventArgs> Recommend;
        event EventHandler<ExternalDataEventArgs> Receive;
        event EventHandler<ExternalDataEventArgs> Release;
        event EventHandler<ExternalDataEventArgs> Reject;
        event EventHandler<ExternalDataEventArgs> RejectForRedraft;
        event EventHandler<ExternalDataEventArgs> Return;
        event EventHandler<ExternalDataEventArgs> ReturnForRedraft;
        event EventHandler<ExternalDataEventArgs> ReturnToInProgress;
        event EventHandler<ExternalDataEventArgs> Reverse;
        event EventHandler<ExternalDataEventArgs> Rollback;
        event EventHandler<ExternalDataEventArgs> Terminate;
        event EventHandler<ExternalDataEventArgs> Start;
        event EventHandler<ExternalDataEventArgs> Verify;
        event EventHandler<ExternalDataEventArgs> Vote;
        event EventHandler<ExternalDataEventArgs> InProgress;
        event EventHandler<ExternalDataEventArgs> RemindRespondent;
        event EventHandler<ExternalDataEventArgs> Update;

        //-----------------------------------------------------------
        // Submission actions.
        //-----------------------------------------------------------
        event EventHandler<ExternalDataEventArgs> SaveAsDraft;
        event EventHandler<ExternalDataEventArgs> Submit;
        event EventHandler<ExternalDataEventArgs> SubmitToHelpdesk;
        event EventHandler<ExternalDataEventArgs> SubmitForAdjustment;
        event EventHandler<ExternalDataEventArgs> SubmitForAssessment;
        event EventHandler<ExternalDataEventArgs> SubmitForAcceptance;
        event EventHandler<ExternalDataEventArgs> SubmitForAction;
        event EventHandler<ExternalDataEventArgs> SubmitForActivation;
        event EventHandler<ExternalDataEventArgs> SubmitForAgreement;
        event EventHandler<ExternalDataEventArgs> SubmitForApproval;
        event EventHandler<ExternalDataEventArgs> SubmitForAssignment;
        event EventHandler<ExternalDataEventArgs> SubmitForAward;
        event EventHandler<ExternalDataEventArgs> SubmitForClosure;
        event EventHandler<ExternalDataEventArgs> SubmitForCollection;
        event EventHandler<ExternalDataEventArgs> SubmitForCommitment;
        event EventHandler<ExternalDataEventArgs> SubmitForCompletion;
        event EventHandler<ExternalDataEventArgs> SubmitForConfirmation;
        event EventHandler<ExternalDataEventArgs> SubmitForConsentment;
        event EventHandler<ExternalDataEventArgs> SubmitForDelivery;
        event EventHandler<ExternalDataEventArgs> SubmitForExecution;
        event EventHandler<ExternalDataEventArgs> SubmitForEvaluation;
        event EventHandler<ExternalDataEventArgs> SubmitForFinalization;
        event EventHandler<ExternalDataEventArgs> SubmitForInvitation;
        event EventHandler<ExternalDataEventArgs> SubmitForModification;
        event EventHandler<ExternalDataEventArgs> SubmitForPlanning;
        event EventHandler<ExternalDataEventArgs> SubmitForQuotation;
        event EventHandler<ExternalDataEventArgs> SubmitForRecommendation;
        event EventHandler<ExternalDataEventArgs> SubmitForReceipt;
        event EventHandler<ExternalDataEventArgs> SubmitForRelease;
        event EventHandler<ExternalDataEventArgs> SubmitForVerification;
        event EventHandler<ExternalDataEventArgs> SubmitForVetting;
        event EventHandler<ExternalDataEventArgs> SubmitForVoting;

        //-----------------------------------------------------------
        // Waiting actions.
        //-----------------------------------------------------------
        event EventHandler<ExternalDataEventArgs> WaitForClient;
        event EventHandler<ExternalDataEventArgs> WaitForContractor;
        event EventHandler<ExternalDataEventArgs> WaitForCustomer;
        event EventHandler<ExternalDataEventArgs> WaitForMaterial;
        event EventHandler<ExternalDataEventArgs> WaitForRequestor;
        event EventHandler<ExternalDataEventArgs> WaitForSupplier;
        event EventHandler<ExternalDataEventArgs> WaitForTenant;
        event EventHandler<ExternalDataEventArgs> WaitForVendor;
        event EventHandler<ExternalDataEventArgs> WaitForOthers;

        //-----------------------------------------------------------
        // Special events.
        //-----------------------------------------------------------
        event EventHandler<ExternalDataEventArgs> OPCReadingBreached;

    }
}
