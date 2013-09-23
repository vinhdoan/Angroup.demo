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

using System.Workflow.Activities;

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
    public partial interface IAnacleEvents
    {
        //===========================================================
        // NOTE: YOU CAN ADD NEW EVENTS, BUT EXISTING
        // EVENTS MUST NEVER BE REMOVED
        //===========================================================

        //-----------------------------------------------------------
        // Moving forward actions.
        //-----------------------------------------------------------
        event EventHandler<ExternalDataEventArgs> DLP;
        event EventHandler<ExternalDataEventArgs> SubmitForApproval_Cancellation;
        event EventHandler<ExternalDataEventArgs> SubmitForReconciliation;
        event EventHandler<ExternalDataEventArgs> SubmitForApproval_CancelAndRevise;
        event EventHandler<ExternalDataEventArgs> CreateChildRFQs;

        // Retained for compatibility (otherwise, older workflows might crash).
        event EventHandler<ExternalDataEventArgs> SubmitforApproval_CancelAndRevise;

        // Expired Event for China
        event EventHandler<ExternalDataEventArgs> Expire;
        event EventHandler<ExternalDataEventArgs> SubmitForApproval_Invoice;
        event EventHandler<ExternalDataEventArgs> PendingApproval_Invoice;
        event EventHandler<ExternalDataEventArgs> SubmitForApproval_IWF;
        //Event for Marcom
        event EventHandler<ExternalDataEventArgs> InvoiceSubmittedForApproval;
        event EventHandler<ExternalDataEventArgs> PendingInvoiceApproval;

        // Kien Trung
        // Event for Capitaland Malaysia Ops
        event EventHandler<ExternalDataEventArgs> Support;
        event EventHandler<ExternalDataEventArgs> SubmitForApproval_InvoiceCancellation;
        event EventHandler<ExternalDataEventArgs> SubmitForApproval_RfqCancellation;

        // Event for CapitaLand RCS
        event EventHandler<ExternalDataEventArgs> SubmitForApproval_Supporter;
        event EventHandler<ExternalDataEventArgs> Approve_Supporter;

        event EventHandler<ExternalDataEventArgs> Setup;

        // Event for Inventory module
        event EventHandler<ExternalDataEventArgs> Request;

        // Event for HDB
        event EventHandler<ExternalDataEventArgs> SubmitForAcknowledgement;
        event EventHandler<ExternalDataEventArgs> SubmitForResolution;
    }
}