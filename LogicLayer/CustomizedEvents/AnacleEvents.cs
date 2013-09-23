//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
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

namespace LogicLayer.Events
{
    public partial class AnacleEvents : IAnacleEvents
    {
        #region IAnacleEvents Members

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> DLP;
        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForApproval_Cancellation;
        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForReconciliation;
        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForApproval_CancelAndRevise;
        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> CreateChildRFQs;

        // Retained for compatibility (otherwise, older workflows might crash).
        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitforApproval_CancelAndRevise;

        // Expire Event for China
        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Expire;
        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForApproval_Invoice;
        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> PendingApproval_Invoice;
        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForApproval_IWF;
        //Event for Marcom
        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> InvoiceSubmittedForApproval;
        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> PendingInvoiceApproval;

        // Kien Trung
        // Event for Capitaland Malaysia Ops
        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Support;
        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForApproval_InvoiceCancellation;
        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForApproval_RfqCancellation;

        // Event for CapitaLand RCS
        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForApproval_Supporter;
        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Approve_Supporter;

        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Setup;

        // Event for Inventory module
        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> Request;

        // Event for HDB
        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForAcknowledgement;
        public event EventHandler<System.Workflow.Activities.ExternalDataEventArgs> SubmitForResolution;

        #endregion IAnacleEvents Members
    }
}