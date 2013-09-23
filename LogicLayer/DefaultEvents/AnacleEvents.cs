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

namespace LogicLayer.Events
{
    [Serializable]
    public partial class AnacleEvents : IAnacleEvents
    {
        #region IAnacleEvents Members

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Accept;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Activate;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Approve;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Assign;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Agree;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Award;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Cancel;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Close;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Collect;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Commit;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Complete;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Confirm;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Consent;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Deliver;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> End;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Execute;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Evaluate;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Finalize;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Plan;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Recommend;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Receive;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Release;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Reject;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> RejectForRedraft;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Return;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> ReturnForRedraft;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> ReturnToInProgress;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Reverse;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Rollback;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Terminate;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Start;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Verify;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Vote;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> InProgress;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> RemindRespondent;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Update;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SaveAsDraft;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Submit;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitToHelpdesk;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForAdjustment;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForAssessment;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForAcceptance;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForAction;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForActivation;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForAgreement;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForApproval;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForAssignment;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForAward;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForClosure;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForCollection;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForCommitment;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForCompletion;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForConfirmation;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForConsentment;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForDelivery;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForExecution;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForEvaluation;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForFinalization;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForInvitation;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForModification;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForPlanning;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForQuotation;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForRecommendation;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForReceipt;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForRelease;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForVerification;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForVetting;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForVoting;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> WaitForClient;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> WaitForContractor;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> WaitForCustomer;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> WaitForMaterial;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> WaitForRequestor;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> WaitForSupplier;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> WaitForTenant;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> WaitForVendor;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> WaitForOthers;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> PendingAdjustment;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> OPCReadingBreached;

        #endregion
    }
}
