<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OCase currentCase = (OCase)panel.SessionObject;

        objectBase.ObjectNumberVisible = !currentCase.IsNew;

        if (!IsPostBack && currentCase.IsNew)
        {
            currentCase.RequestorID = AppSession.User.ObjectID;
            currentCase.RequestorName = AppSession.User.ObjectName;
            currentCase.RequestorPhone = AppSession.User.UserBase.Phone;
            currentCase.RequestorFax = AppSession.User.UserBase.Fax;

            currentCase.RequestorEmail = AppSession.User.UserBase.Email;
            currentCase.RequestorCellPhone = AppSession.User.UserBase.Cellphone;
        }

        Location.PopulateTree();
        Equipment.PopulateTree();
        RequestorType.Bind(OCode.GetCodesByType("RequestorType", currentCase.RequestorType));
        BindRequestor(currentCase);

        if (!RequestorID.Visible && panel.SessionObject.IsNew)
            currentCase.RequestorID = AppSession.User.ObjectID;

        panel.ObjectPanel.BindObjectToControls(currentCase);
    }

    /// <summary>
    /// Validates and saves the work request object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OCase currentCase = panel.SessionObject as OCase;
            panel.ObjectPanel.BindControlsToObject(currentCase);

            // Validate
            //
            if (objectBase.SelectedAction=="Close" && 
                !currentCase.ValidateAllDocumentsClosedOrCancelled())
            {
                gridWorks.ErrorMessage = Resources.Errors.Case_RelatedDocumentsNotClosedOrCancelled;
                gridRequestForQuotations.ErrorMessage = Resources.Errors.Case_RelatedDocumentsNotClosedOrCancelled;
                gridPurchaseOrders.ErrorMessage = Resources.Errors.Case_RelatedDocumentsNotClosedOrCancelled;
            }
            if (!panel.ObjectPanel.IsValid)
                return;
            
            // Save
            //
            if (!RequestorID.Visible && currentCase.IsNew)
                ((OCase)currentCase).RequestorID = AppSession.User.ObjectID;
            
            currentCase.Save();
            c.Commit();
        }
    }

    /// <summary>
    /// Populates the case sub-form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Work_ObjectPanel_PopulateForm(object sender, EventArgs e)
    {
        OCase currentCase = panel.SessionObject as OCase;
        OWork work = (OWork)Work_SubPanel.SessionObject;

        work.WorkDescription = currentCase.ProblemDescription;
        work.Priority = currentCase.Priority;
        work.LocationID = currentCase.LocationID;
        work.EquipmentID = currentCase.EquipmentID;

        Work_Location.PopulateTree();
        Work_Equipment.PopulateTree();

        BindCodes(work);

        Work_SubPanel.ObjectPanel.BindObjectToControls(work);

        if (work.CurrentActivity != null &&
            work.CurrentActivity.ObjectName != null)
            panelWorkDetails.Enabled = work.CurrentActivity.ObjectName.Is("Start", "Draft");
    }

    /// <summary>
    /// Binds data to the drop down lists.
    /// </summary>
    /// <param name="work"></param>
    void BindCodes(OWork work)
    {
        if (work.TypeOfWorkID == null)
            work.TypeOfServiceID = null;

        if (work.TypeOfServiceID == null)
            work.TypeOfProblemID = null;

        Work_TypeOfWorkID.Bind(OCode.GetWorkTypes(AppSession.User, Security.Decrypt(Request["TYPE"]), work.TypeOfWorkID));

        Work_TypeOfServiceID.Items.Clear();
        if (work.TypeOfWorkID != null)
            Work_TypeOfServiceID.Bind(OCode.GetTypeOfServices(AppSession.User, work.TypeOfWorkID, Security.Decrypt(Request["TYPE"]), work.TypeOfServiceID));

        Work_TypeOfProblemID.Items.Clear();
        if (work.TypeOfServiceID != null)
            Work_TypeOfProblemID.Bind(OCode.GetCodesByTypeAndParentID("TypeOfProblem", work.TypeOfServiceID, work.TypeOfProblemID));
    }



    /// <summary>
    /// Binds data to the requestor drop down list.
    /// </summary>
    /// <param name="workRequest"></param>
    protected void BindRequestor(OCase currentCase)
    {
        RequestorID.Bind(OUser.GetUsersByPositions(OPosition.GetPositionsByRoleCode("WORKCALLER")));
    }

    /// <summary>
    /// Occurs when user mades selection in the requestor drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void RequestorID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OCase currentCase = (OCase)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(currentCase);

        currentCase.RequestorName = "";
        currentCase.RequestorPhone = "";
        currentCase.RequestorEmail = "";
        currentCase.RequestorFax = "";
        currentCase.RequestorCellPhone = "";

        if (currentCase.RequestorID != null)
        {
            OUser user = TablesLogic.tUser[currentCase.RequestorID.Value];
            if (user != null)
            {
                currentCase.RequestorName = user.ObjectName;
                currentCase.RequestorPhone = user.UserBase.Phone;
                currentCase.RequestorEmail = user.UserBase.Email;
                currentCase.RequestorFax = user.UserBase.Fax;
                currentCase.RequestorCellPhone = user.UserBase.Cellphone;
            }
        }
        panel.ObjectPanel.BindObjectToControls(currentCase);
    }

    /// <summary>
    /// Hides/shows elements
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        RequestorType.Visible = RequestorID.SelectedIndex == 0;
        Workflow_Setting();
    }

    /// <summary>
    /// Hides/shows controls and action selection for transitting to new state.
    /// </summary>
    protected void Workflow_Setting()
    {
        tabDetails.Enabled = objectBase.CurrentObjectState.Is("Start", "PendingHelpdesk", "PendingExecution");
        tabProblem.Enabled = objectBase.CurrentObjectState.Is("Start", "PendingHelpdesk", "PendingExecution");

        tabWorkAndPurchaseOrders.Visible = objectBase.CurrentObjectState.Is("PendingHelpdesk", "PendingExecution", "Close");
        tabWorkAndPurchaseOrders.Enabled = objectBase.CurrentObjectState.Is("PendingHelpdesk", "PendingExecution");

        RequestorID.Visible = objectBase.SelectedAction != "SubmitToHelpdesk";
        RequestorID.Enabled = objectBase.SelectedAction != "SubmitToHelpdesk";

        panelRequestor.Enabled = panelRequestorDetails.Enabled = (objectBase.CurrentObjectState == "Start");

        ListItem item = objectBase.GetWorkflowRadioListItem("SubmitToHelpdesk");
        if (item != null)
            item.Enabled = Workflow.CurrentUser.HasRole("WORKREQUESTOR");

        if (objectBase.SelectedAction == "SubmitToHelpdesk")
        {
            RequestorID.SelectedValue = Workflow.CurrentUser.ObjectID.ToString();
            RequestorName.Text = Workflow.CurrentUser.ObjectName;
            RequestorCellPhone.Text = Workflow.CurrentUser.UserBase.Cellphone;
            RequestorFax.Text = Workflow.CurrentUser.UserBase.Fax;
            RequestorEmail.Text = Workflow.CurrentUser.UserBase.Email;
            RequestorPhone.Text = Workflow.CurrentUser.UserBase.Phone;
        }
    }

    /// <summary>
    /// Constructs the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater Location_AcquireTreePopulater(object sender)
    {
        OCase currentCase = panel.SessionObject as OCase;
        return new LocationTreePopulater(currentCase.LocationID, false, true, Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// Occurs when user selects location in the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Location_SelectedNodeChanged(object sender, EventArgs e)
    {
        OCase currentCase = panel.SessionObject as OCase;
        panel.ObjectPanel.BindControlsToObject(currentCase);
        currentCase.EquipmentID = null;
        BindRequestor(currentCase);
        panel.ObjectPanel.BindObjectToControls(currentCase);
    }

    /// <summary>
    /// Occurs when user changes the work location.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Work_Location_SelectedNodeChanged(object sender, EventArgs e)
    {
        OWork work = Work_SubPanel.SessionObject as OWork;
        Work_SubPanel.ObjectPanel.BindControlsToObject(work);
        work.EquipmentID = null;
        Work_SubPanel.ObjectPanel.BindObjectToControls(work);
    }

    /// <summary>
    /// Constructs the equipment tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater Equipment_AcquireTreePopulater(object sender)
    {
        OCase currentCase = panel.SessionObject as OCase;
        return new EquipmentTreePopulater(currentCase.EquipmentID, false, true, Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// Occurs when user selects an equipment in the equipment tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Equipment_SelectedNodeChanged(object sender, EventArgs e)
    {
        OCase currentCase = panel.SessionObject as OCase;
        panel.ObjectPanel.BindControlsToObject(currentCase);

        if (currentCase.Equipment != null)
        {
            currentCase.Location = currentCase.Equipment.Location;
            BindRequestor(currentCase);
        }
        panel.ObjectPanel.BindObjectToControls(currentCase);
    }

    /// <summary>
    /// Occurs when the equipment for this work is changed.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Work_Equipment_SelectedNodeChanged(object sender, EventArgs e)
    {
        OWork work = Work_SubPanel.SessionObject as OWork;
        Work_SubPanel.ObjectPanel.BindControlsToObject(work);
        if (work.Equipment != null)
            work.LocationID = work.Equipment.LocationID;
        Work_SubPanel.ObjectPanel.BindObjectToControls(work);
    }

    /// <summary>
    /// Occurs when the type of work changes.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Work_TypeOfWorkID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = (OWork)Work_SubPanel.SessionObject;
        Work_SubPanel.ObjectPanel.BindControlsToObject(work);
        BindCodes(work);

        Work_SubPanel.ObjectPanel.BindObjectToControls(work);
    }


    /// <summary>
    /// Occurs when the type of service changes.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Work_TypeOfServiceID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = (OWork)Work_SubPanel.SessionObject;
        Work_SubPanel.ObjectPanel.BindControlsToObject(work);
        BindCodes(work);

        Work_SubPanel.ObjectPanel.BindObjectToControls(work);
    }


    /// <summary>
    /// Occurs when the type of problem changes.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Work_TypeOfProblemID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OWork work = (OWork)Work_SubPanel.SessionObject;
        Work_SubPanel.ObjectPanel.BindControlsToObject(work);
        BindCodes(work);

        Work_SubPanel.ObjectPanel.BindObjectToControls(work);
    }


    /// <summary>
    /// Occurs when the 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Work_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OCase currentCase = panel.SessionObject as OCase;

        OWork work = Work_SubPanel.SessionObject as OWork;
        Work_SubPanel.ObjectPanel.BindControlsToObject(work);

        currentCase.Works.Add(work);
        panelWorks.BindObjectToControls(currentCase);
    }


    /// <summary>
    /// Populates the request for quotation sub panel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelRequestForQuotation_PopulateForm(object sender, EventArgs e)
    {
        OCase currentCase = panel.SessionObject as OCase;
        ORequestForQuotation rfq = subpanelRequestForQuotation.SessionObject as ORequestForQuotation;

        if (subpanelRequestForQuotation.IsAddingObject)
        {
            rfq.LocationID = currentCase.LocationID;
            rfq.EquipmentID = currentCase.EquipmentID;
        }
        rfq.Description = currentCase.ProblemDescription;

        treeRFQLocation.PopulateTree();
        treeRFQEquipment.PopulateTree();

        dropPurchaseType.Bind(OCode.GetCodesByType("PurchaseType", rfq.PurchaseTypeID));
        subpanelRequestForQuotation.ObjectPanel.BindObjectToControls(rfq);

        if (rfq.CurrentActivity != null &&
            rfq.CurrentActivity.ObjectName != null)
            panelRequestForQuotationDetails.Enabled = rfq.CurrentActivity.ObjectName.Is("Start", "Draft");
    }


    /// <summary>
    /// Occurs when the user updates the case's RFQ.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelRequestForQuotation_ValidateAndUpdate(object sender, EventArgs e)
    {
        OCase currentCase = panel.SessionObject as OCase;
        ORequestForQuotation rfq = subpanelRequestForQuotation.SessionObject as ORequestForQuotation;
        subpanelRequestForQuotation.ObjectPanel.BindControlsToObject(rfq);

        // Validate
        //

        currentCase.RequestForQuotations.Add(rfq);
        panelRequestForQuotations.BindObjectToControls(currentCase);
    }

    /// <summary>
    /// Constructs and returns the equipment tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeRFQEquipment_AcquireTreePopulater(object sender)
    {
        ORequestForQuotation rfq = subpanelRequestForQuotation.SessionObject as ORequestForQuotation;
        return new EquipmentTreePopulater(rfq.EquipmentID, false, true, Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// Constructs and returns the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeRFQLocation_AcquireTreePopulater(object sender)
    {
        ORequestForQuotation rfq = subpanelRequestForQuotation.SessionObject as ORequestForQuotation;
        return new LocationTreePopulater(rfq.LocationID, false, true, Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// Occurs when the user selects an item in the location treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeRFQLocation_SelectedNodeChanged(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = subpanelRequestForQuotation.SessionObject as ORequestForQuotation;
        subpanelRequestForQuotation.ObjectPanel.BindControlsToObject(rfq);
        rfq.EquipmentID = null;
        subpanelRequestForQuotation.ObjectPanel.BindObjectToControls(rfq);
    }


    /// <summary>
    /// Occurs when the user selects an item in the equipment treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeRFQEquipment_SelectedNodeChanged(object sender, EventArgs e)
    {
        ORequestForQuotation rfq = subpanelRequestForQuotation.SessionObject as ORequestForQuotation;
        subpanelRequestForQuotation.ObjectPanel.BindControlsToObject(rfq);
        if (rfq.Equipment != null)
            rfq.LocationID = rfq.Equipment.LocationID;
        subpanelRequestForQuotation.ObjectPanel.BindObjectToControls(rfq);
    }

    /// <summary>
    /// Occurs when the user edits or adds a new PO.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelPurchaseOrder_PopulateForm(object sender, EventArgs e)
    {
        OCase currentCase = panel.SessionObject as OCase;
        OPurchaseOrder po = subpanelPurchaseOrder.SessionObject as OPurchaseOrder;

        if (subpanelPurchaseOrder.IsAddingObject)
        {
            po.LocationID = currentCase.LocationID;
            po.EquipmentID = currentCase.EquipmentID;
        }
        po.DateOfOrder = DateTime.Today;
        po.Description = currentCase.ProblemDescription;

        treePOLocation.PopulateTree();
        treePOEquipment.PopulateTree();

        dropPOPurchaseType.Bind(OCode.GetCodesByType("PurchaseType", po.PurchaseTypeID));
        subpanelPurchaseOrder.ObjectPanel.BindObjectToControls(po);

        if (po.CurrentActivity != null &&
            po.CurrentActivity.ObjectName != null)
            panelPurchaseOrderDetails.Enabled = po.CurrentActivity.ObjectName.Is("Start", "Draft");
    }

    /// <summary>
    /// Occurs when the user updates the PO.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void subpanelPurchaseOrder_ValidateAndUpdate(object sender, EventArgs e)
    {
        OCase currentCase = panel.SessionObject as OCase;
        OPurchaseOrder po = subpanelPurchaseOrder.SessionObject as OPurchaseOrder;
        subpanelPurchaseOrder.ObjectPanel.BindControlsToObject(po);

        // Validate
        //

        currentCase.PurchaseOrders.Add(po);
        panelPurchaseOrders.BindObjectToControls(currentCase);
    }


    /// <summary>
    /// Constructs and returns the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treePOLocation_AcquireTreePopulater(object sender)
    {
        OPurchaseOrder po = subpanelPurchaseOrder.SessionObject as OPurchaseOrder;
        return new LocationTreePopulater(po.LocationID, false, true,
            Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected void treePOLocation_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = subpanelPurchaseOrder.SessionObject as OPurchaseOrder;
        subpanelPurchaseOrder.ObjectPanel.BindControlsToObject(po);
        po.EquipmentID = null;
        subpanelPurchaseOrder.ObjectPanel.BindObjectToControls(po);
    }

    /// <summary>
    /// Constructs and returns the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treePOEquipment_AcquireTreePopulater(object sender)
    {
        OPurchaseOrder po = subpanelPurchaseOrder.SessionObject as OPurchaseOrder;
        return new EquipmentTreePopulater(po.EquipmentID, false, true,
            Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected void treePOEquipment_SelectedNodeChanged(object sender, EventArgs e)
    {
        OPurchaseOrder po = subpanelPurchaseOrder.SessionObject as OPurchaseOrder;
        subpanelPurchaseOrder.ObjectPanel.BindControlsToObject(po);
        if (po.Equipment != null)
            po.LocationID = po.Equipment.LocationID;
        subpanelPurchaseOrder.ObjectPanel.BindObjectToControls(po);
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain">
        <web:object runat="server" ID="panel" Caption="Case" BaseTable="tCase" OnPopulateForm="panel_PopulateForm"
            OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                <ui:UITabView runat="server" ID="tabDetails" Caption="Details" meta:resourcekey="tabDetailsResource1">
                    <web:base runat="server" ID="objectBase" ObjectNameVisible="false" ObjectNumberCaption="Work Number"
                        ObjectNumberEnabled="false" ObjectNumberVisible="false"></web:base>
                    <ui:UIFieldTreeList runat="server" ID="Location" Caption="Location" OnSelectedNodeChanged="Location_SelectedNodeChanged"
                        ValidateRequiredField="true" OnAcquireTreePopulater="Location_AcquireTreePopulater"
                        ToolTip="Use this to select the location that this case applies to." PropertyName="LocationID"
                        meta:resourcekey="LocationResource1" />
                    <ui:UIFieldTreeList runat="server" ID="Equipment" Caption="Equipment" OnSelectedNodeChanged="Equipment_SelectedNodeChanged"
                        OnAcquireTreePopulater="Equipment_AcquireTreePopulater" ToolTip="Use this to select the equipment that this case applies to."
                        PropertyName="EquipmentID" meta:resourcekey="EquipmentResource1" />
                    <br />
                    <br />
                    <ui:UIGridView runat="server" ID="LocationHistory" PropertyName="LocationHistoryForOneMonth" CheckBoxColumnVisible="false"
                        Caption="Location History" Width="100%" AllowPaging="True" AllowSorting="True"
                        meta:resourcekey="LocationHistoryResource1" PagingEnabled="True" RowErrorColor="">
                        <Columns>
                            <ui:UIGridViewBoundColumn PropertyName="ObjectNumber" HeaderText="Case Number" meta:resourcekey="UIGridViewColumnResource9">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="CreatedDateTime" HeaderText="Date/Time" meta:resourcekey="UIGridViewColumnResource10">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="RequestorName" HeaderText="Requestor Name"
                                meta:resourcekey="UIGridViewColumnResource11">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="ProblemDescription" HeaderText="Problem Description"
                                meta:resourcekey="UIGridViewColumnResource12">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Priority" HeaderText="Priority" meta:resourcekey="UIGridViewColumnResource13">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Location" HeaderText="Location" meta:resourcekey="UIGridViewColumnResource14">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Equipment" HeaderText="Equipment" meta:resourcekey="UIGridViewColumnResource15">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="StatusName" HeaderText="Status" ResourceName="Resources.WorkflowStates"
                                meta:resourcekey="UIGridViewColumnResource16">
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabProblem" Caption="Problem" meta:resourcekey="tabWorkResource1">
                    <ui:UIPanel runat="server" ID="panelRequestor" meta:resourcekey="panelRequestorResource1">
                        <ui:UISeparator ID="sep1" runat="server" Caption="Requestor" meta:resourcekey="sep1Resource1" />
                        <ui:UIFieldDropDownList runat="server" ID="RequestorID" PropertyName="RequestorID"
                            Caption="Requestor" OnSelectedIndexChanged="RequestorID_SelectedIndexChanged"
                            ToolTip="The Requestor that made the request for this work. Leave this empty if the Requestor does not exist in this list. You can key in his or her name below in the 'Name' field."
                            meta:resourcekey="RequestorIDResource2">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="RequestorType" PropertyName="RequestorType"
                            Caption="Requestor Type" ToolTip="The type of Requestor." meta:resourcekey="RequestorTypeResource2">
                        </ui:UIFieldDropDownList>
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panelRequestorDetails" meta:resourcekey="panelRequestorDetailsResource1">
                        <ui:UIFieldTextBox ID="RequestorName" runat="server" Caption="Name" PropertyName="RequestorName"
                            ValidateRequiredField="True" ToolTip="The name of the Requestor to refer by."
                            meta:resourcekey="RequestorNameResource2" />
                        <ui:UIFieldTextBox ID="RequestorCellPhone" runat="server" Caption="Cell Phone" PropertyName="RequestorCellPhone"
                            Span="Half" meta:resourcekey="RequestorCellResource1" />
                        <ui:UIFieldTextBox ID="RequestorEmail" runat="server" Caption="Email" PropertyName="RequestorEmail"
                            Span="Half" meta:resourcekey="RequestorEmailResource1" />
                        <ui:UIFieldTextBox ID="RequestorFax" runat="server" Caption="Fax" PropertyName="RequestorFax"
                            Span="Half" meta:resourcekey="RequestorFaxResource1" />
                        <ui:UIFieldTextBox ID="RequestorPhone" runat="server" Caption="Phone" PropertyName="RequestorPhone"
                            Span="Half" meta:resourcekey="RequestorPhoneResource1" />
                    </ui:UIPanel>
                    <ui:UISeparator ID="Separator1" runat="server" Caption="Problem" meta:resourcekey="Separator1Resource1" />
                    <ui:UIFieldDropDownList runat="server" ID="Priority" PropertyName="Priority" Caption="Priority"
                        ValidateRequiredField="True" Span="Half" meta:resourcekey="PriorityResource1">
                        <Items>
                            <asp:ListItem Text="0 (Lowest)" Selected="True" Value="0" meta:resourcekey="ListItemResource1">
                            </asp:ListItem>
                            <asp:ListItem Text="1" Value="1" meta:resourcekey="ListItemResource2">
                            </asp:ListItem>
                            <asp:ListItem Text="2" Value="2" meta:resourcekey="ListItemResource3">
                            </asp:ListItem>
                            <asp:ListItem Text="3 (Highest)" Value="3" meta:resourcekey="ListItemResource4">
                            </asp:ListItem>
                        </Items>
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldTextBox ID="ProblemDescription" runat="server" Caption="Problem Description"
                        PropertyName="ProblemDescription" ValidateRequiredField="True" MaxLength="255"
                        meta:resourcekey="ProblemDescriptionResource1" />
                    <br />
                    <br />
                    <ui:UIGridView runat="server" ID="RequestorHistory" PropertyName="RequestorHistoryForOneMonth"
                        Caption="Requestor History" Width="100%" AllowPaging="True" AllowSorting="True" CheckBoxColumnVisible="false"
                        meta:resourcekey="RequestorHistoryResource1" PagingEnabled="True" RowErrorColor="">
                        <Columns>
                            <ui:UIGridViewBoundColumn PropertyName="ObjectNumber" HeaderText="Case Number" meta:resourcekey="UIGridViewColumnResource17">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="CreatedDateTime" HeaderText="Date/Time" meta:resourcekey="UIGridViewColumnResource18">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="RequestorName" HeaderText="Requestor Name"
                                meta:resourcekey="UIGridViewColumnResource19">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="ProblemDescription" HeaderText="Problem Description"
                                meta:resourcekey="UIGridViewColumnResource20">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Priority" HeaderText="Priority" meta:resourcekey="UIGridViewColumnResource21">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Location" HeaderText="Location" meta:resourcekey="UIGridViewColumnResource22">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="Equipment" HeaderText="Equipment" meta:resourcekey="UIGridViewColumnResource23">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="StatusName" HeaderText="Status" ResourceName="Resources.WorkflowStates"
                                meta:resourcekey="UIGridViewColumnResource24">
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabWorkAndPurchaseOrders" Caption="Work" meta:resourcekey="tabWorkAndPurchaseOrdersResource1">
                    <ui:UIFieldCheckBox runat="server" ID="checkIsAutoClose" PropertyName="IsAutoClose" Caption="Auto Closure" Text="Yes, automatically close this case when all related documents below are closed or cancelled."></ui:UIFieldCheckBox>
                    <ui:UIPanel runat="server" ID="panelWorks">
                        <ui:UIGridView runat="server" ID="gridWorks" PropertyName="Works" Caption="Works"
                            meta:resourcekey="WorksResource1">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject"
                                    HeaderText="" meta:resourceKey="UIGridViewColumnResource1">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="RemoveObject"
                                    ConfirmText="Are you sure you wish to delete this item?" HeaderText="" meta:resourcekey="UIGridViewColumnResource2">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ObjectNumber" HeaderText="Work Number"
                                    meta:resourcekey="UIGridViewColumnResource3">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Location.Path" HeaderText="Location">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Equipment.Path" HeaderText="Equipment">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="TypeOfWork.ObjectName" HeaderText="Type of Work"
                                    meta:resourcekey="UIGridViewColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="TypeOfService.ObjectName" HeaderText="Type of Service"
                                    meta:resourcekey="UIGridViewColumnResource5">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="TypeOfProblem.ObjectName" HeaderText="Type of Problem">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Priority" HeaderText="Priority">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="WorkDescription" HeaderText="Work Description"
                                    meta:resourcekey="UIGridViewColumnResource6">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CurrentActivity.ObjectName" HeaderText="Status"
                                    ResourceName="Resources.WorkflowStates" meta:resourcekey="UIGridViewColumnResource8">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourceKey="UIGridViewCommandResource1">
                                </ui:UIGridViewCommand>
                                <ui:UIGridViewCommand CommandText="Add" ImageUrl="~/images/add.gif" CommandName="AddObject"
                                    meta:resourceKey="UIGridViewCommandResource2"></ui:UIGridViewCommand>
                            </Commands>
                        </ui:UIGridView>
                    </ui:UIPanel>
                    <ui:UIObjectPanel runat="server" ID="Work_ObjectPanel" meta:resourcekey="Work_ObjectPanelResource1">
                        <web:subpanel runat="server" ID="Work_SubPanel" GridViewID="gridWorks" OnPopulateForm="Work_ObjectPanel_PopulateForm"
                            OnValidateAndUpdate="Work_SubPanel_ValidateAndUpdate"></web:subpanel>
                        <ui:UIPanel runat="server" ID="panelWorkDetails">
                            <ui:UIFieldTreeList runat="server" ID="Work_Location" Caption="Select" OnSelectedNodeChanged="Work_Location_SelectedNodeChanged"
                                OnAcquireTreePopulater="Location_AcquireTreePopulater" ToolTip="Use this to select the location that this work applies to."
                                PropertyName="LocationID" meta:resourcekey="Work_LocationResource1" ValidateRequiredField='true' />
                            <ui:UIFieldTreeList runat="server" ID="Work_Equipment" Caption="Select" OnSelectedNodeChanged="Work_Equipment_SelectedNodeChanged"
                                OnAcquireTreePopulater="Equipment_AcquireTreePopulater" ToolTip="Use this to select the equipment that this work applies to."
                                PropertyName="EquipmentID" meta:resourcekey="Work_EquipmentResource1" />
                            <br />
                            <ui:UIFieldDropDownList runat="server" ID="Work_TypeOfWorkID" PropertyName="TypeOfWorkID"
                                Caption="Type of Work" ValidateRequiredField="True" OnSelectedIndexChanged="Work_TypeOfWorkID_SelectedIndexChanged"
                                meta:resourcekey="Work_TypeOfWorkIDResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="Work_TypeOfServiceID" PropertyName="TypeOfServiceID"
                                Caption="Type of Service" ValidateRequiredField="True" OnSelectedIndexChanged="Work_TypeOfServiceID_SelectedIndexChanged"
                                meta:resourcekey="Work_TypeOfServiceIDResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="Work_TypeOfProblemID" PropertyName="TypeOfProblemID"
                                Caption="Type of Problem" ValidateRequiredField="True" OnSelectedIndexChanged="Work_TypeOfProblemID_SelectedIndexChanged"
                                meta:resourcekey="Work_TypeOfProblemIDResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="UIFieldDropDownList1" PropertyName="Priority"
                                Caption="Priority" ValidateRequiredField="True" Span="Half" meta:resourcekey="PriorityResource1">
                                <Items>
                                    <asp:ListItem Text="0 (Lowest)" Selected="True" Value="0" meta:resourceKey="ListItemResource9">
                                    </asp:ListItem>
                                    <asp:ListItem Text="1" Value="1" meta:resourceKey="ListItemResource10">
                                    </asp:ListItem>
                                    <asp:ListItem Text="2" Value="2" meta:resourceKey="ListItemResource11">
                                    </asp:ListItem>
                                    <asp:ListItem Text="3 (Highest)" Value="3" meta:resourceKey="ListItemResource12">
                                    </asp:ListItem>
                                </Items>
                            </ui:UIFieldDropDownList>
                            <ui:UIFieldTextBox ID="WorkDescription" runat="server" Caption="Work Description"
                                PropertyName="WorkDescription" ValidateRequiredField="True" MaxLength="255" meta:resourcekey="WorkDescriptionResource2" />
                        </ui:UIPanel>
                    </ui:UIObjectPanel>
                    <br />
                    <br />
                    <ui:UIPanel runat="server" ID="panelRequestForQuotations">
                        <ui:UIGridView runat="server" ID="gridRequestForQuotations" PropertyName="RequestForQuotations"
                            Caption="Request for Quotations">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject"
                                    HeaderText="">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="RemoveObject"
                                    ConfirmText="Are you sure you wish to delete this item?" HeaderText="">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn HeaderText="RFQ Number" PropertyName="ObjectNumber">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Location" PropertyName="Location.Path">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Equipment" PropertyName="Equipment.Path">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Description" PropertyName="Description">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Date Required" PropertyName="DateRequired"
                                    DataFormatString="{0:dd-MMM-yyyy}">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Type" PropertyName="PurchaseType.ObjectName">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CurrentActivity.ObjectName"
                                    HeaderText="Status" ResourceName="Resources.WorkflowStates">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject"></ui:UIGridViewCommand>
                                <ui:UIGridViewCommand CommandText="Add" ImageUrl="~/images/add.gif" CommandName="AddObject">
                                </ui:UIGridViewCommand>
                            </Commands>
                        </ui:UIGridView>
                    </ui:UIPanel>
                    <ui:UIObjectPanel runat="server" ID="panelRequestForQuotation">
                        <web:subpanel runat="server" ID="subpanelRequestForQuotation" GridViewID="gridRequestForQuotations"
                            OnPopulateForm="subpanelRequestForQuotation_PopulateForm" OnValidateAndUpdate="subpanelRequestForQuotation_ValidateAndUpdate">
                        </web:subpanel>
                        <ui:UIPanel runat="server" ID="panelRequestForQuotationDetails">
                            <ui:UIFieldTreeList runat="server" ID="treeRFQLocation" Caption="Location" ToolTip="Use this to select the location that this work applies to."
                                PropertyName="LocationID" ValidateRequiredField='true' OnSelectedNodeChanged="treeRFQLocation_SelectedNodeChanged"
                                OnAcquireTreePopulater="treeRFQLocation_AcquireTreePopulater" />
                            <ui:UIFieldTreeList runat="server" ID="treeRFQEquipment" Caption="Equipment" ToolTip="Use this to select the equipment that this work applies to."
                                PropertyName="EquipmentID" OnSelectedNodeChanged="treeRFQEquipment_SelectedNodeChanged"
                                OnAcquireTreePopulater="treeRFQEquipment_AcquireTreePopulater" />
                            <ui:UIFieldTextBox runat="server" ID="textDescription" Caption="Description" MaxLength="255"
                                PropertyName="Description" ValidateRequiredField="true">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldDateTime runat="server" ID="dateDateRequired" Caption="Date Required"
                                PropertyName="DateRequired" ValidateRequiredField="true">
                            </ui:UIFieldDateTime>
                            <ui:UIFieldDropDownList runat="server" ID="dropPurchaseType" Caption="Purchase Type"
                                PropertyName="PurchaseTypeID" ValidateRequiredField="true">
                            </ui:UIFieldDropDownList>
                        </ui:UIPanel>
                    </ui:UIObjectPanel>
                    <br />
                    <br />
                    <ui:UIPanel runat="server" ID="panelPurchaseOrders">
                        <ui:UIGridView runat="server" ID="gridPurchaseOrders" PropertyName="PurchaseOrders"
                            Caption="Purchase Orders">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject"
                                    HeaderText="">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="RemoveObject"
                                    ConfirmText="Are you sure you wish to delete this item?" HeaderText="">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn HeaderText="PO Number" PropertyName="ObjectNumber">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Location" PropertyName="Location.Path">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Equipment" PropertyName="Equipment.Path">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Description" PropertyName="Description">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Date Required" PropertyName="DateRequired"
                                    DataFormatString="{0:dd-MMM-yyyy}">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Date of PO" PropertyName="DateOfOrder" DataFormatString="{0:dd-MMM-yyyy}">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Type" PropertyName="PurchaseType.ObjectName">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CurrentActivity.ObjectName"
                                    HeaderText="Status" ResourceName="Resources.WorkflowStates">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject"></ui:UIGridViewCommand>
                                <ui:UIGridViewCommand CommandText="Add" ImageUrl="~/images/add.gif" CommandName="AddObject">
                                </ui:UIGridViewCommand>
                            </Commands>
                        </ui:UIGridView>
                    </ui:UIPanel>
                    <ui:UIObjectPanel runat="server" ID="panelPurchaseOrder">
                        <web:subpanel runat="server" ID="subpanelPurchaseOrder" GridViewID="gridPurchaseOrders"
                            OnPopulateForm="subpanelPurchaseOrder_PopulateForm" OnValidateAndUpdate="subpanelPurchaseOrder_ValidateAndUpdate">
                        </web:subpanel>
                        <ui:UIPanel runat="server" ID="panelPurchaseOrderDetails">
                            <ui:UIFieldTreeList runat="server" ID="treePOLocation" Caption="Location" ToolTip="Use this to select the location that this work applies to."
                                PropertyName="LocationID" ValidateRequiredField='true' OnAcquireTreePopulater="treePOLocation_AcquireTreePopulater"
                                OnSelectedNodeChanged="treePOLocation_SelectedNodeChanged" />
                            <ui:UIFieldTreeList runat="server" ID="treePOEquipment" Caption="Equipment" ToolTip="Use this to select the equipment that this work applies to."
                                PropertyName="EquipmentID" OnAcquireTreePopulater="treePOEquipment_AcquireTreePopulater"
                                OnSelectedNodeChanged="treePOEquipment_SelectedNodeChanged" />
                            <ui:UIFieldTextBox runat="server" ID="textPODescription" Caption="Description" MaxLength="255"
                                PropertyName="Description" ValidateRequiredField="true">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldDateTime runat="server" ID="textPODateOfOrder" Caption="Date of PO" PropertyName="DateOfOrder"
                                ValidateRequiredField="true" Span="Half">
                            </ui:UIFieldDateTime>
                            <ui:UIFieldDateTime runat="server" ID="textPODateRequired" Caption="Date Required"
                                PropertyName="DateRequired" ValidateRequiredField="true" Span="Half">
                            </ui:UIFieldDateTime>
                            <ui:UIFieldDropDownList runat="server" ID="dropPOPurchaseType" Caption="Purchase Type"
                                PropertyName="PurchaseTypeID" ValidateRequiredField="true">
                            </ui:UIFieldDropDownList>
                        </ui:UIPanel>
                    </ui:UIObjectPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview3" Caption="Memo" meta:resourcekey="uitabview3Resource1">
                    <web:memo runat="server" ID="memo1"></web:memo>
                </ui:UITabView>
                <ui:UITabView ID="uitabview2" runat="server" Caption="Attachments" meta:resourcekey="uitabview2Resource1">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
