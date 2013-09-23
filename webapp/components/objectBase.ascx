<%@ Control Language="C#" ClassName="objectBase" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Collections.ObjectModel" %>
<%@ Import Namespace="System.Drawing.Imaging" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.Workflow.ComponentModel" %>
<%@ Import Namespace="System.Workflow.ComponentModel.Design" %>
<%@ Import Namespace="System.Workflow.Activities" %>
<%@ Import Namespace="System.Workflow.Runtime" %>
<%@ Import Namespace="System.ComponentModel" %>
<%@ Import Namespace="System.ComponentModel.Design" %>
<%@ Import Namespace="System.ComponentModel.Design.Serialization" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="Anacle.WorkflowFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Src="objectPanel.ascx" TagName="object" TagPrefix="web2" %>
<%@ Register Src="objectAudit.ascx" TagName="objectAudit" TagPrefix="web2" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">
        
    /// <summary>
    /// Gets or sets the Object Name TextBox's Caption
    /// property.
    /// </summary>
    public string ObjectNameCaption
    {
        get
        {
            return _objectName.Caption;
        }
        set
        {
            _objectName.Caption = value;
            labelObjectName.Text = value;
        }
    }


    /// <summary>
    /// Gets or sets the Object Number TextBox's Caption
    /// property.
    /// </summary>
    public string ObjectNumberCaption
    {
        get
        {
            return _objectNumber.Caption;
        }
        set
        {
            _objectNumber.Caption = value;
            labelObjectNumber.Text = value;
        }
    }


    /// <summary>
    /// Gets or sets the Object Name TextBox's Tooltip
    /// property.
    /// </summary>
    public string ObjectNameTooltip
    {
        get
        {
            return _objectName.ToolTip;
        }
        set
        {
            _objectName.ToolTip = value;
        }
    }


    /// <summary>
    /// Gets or sets the Object Number TextBox's Tooltip
    /// </summary>
    public string ObjectNumberTooltip
    {
        get
        {
            return _objectNumber.ToolTip;
        }
        set
        {
            _objectNumber.ToolTip = value;
        }
    }


    /// <summary>
    /// Gets or sets the Object Name TextBox's MaxLength.
    /// </summary>
    public int ObjectNameMaxLength
    {
        get
        {
            return _objectName.MaxLength;
        }
        set
        {
            _objectName.MaxLength = value;
        }
    }


    /// <summary>
    /// Gets or sets the Object Name TextBox's MaxLength.
    /// </summary>
    public int ObjectNumberMaxLength
    {
        get
        {
            return _objectNumber.MaxLength;
        }
        set
        {
            _objectNumber.MaxLength = value;
        }
    }


    /// <summary>
    /// Gets or sets the Assigned User(s) TextBox's Visible property.
    /// </summary>
    [DefaultValue(true), Localizable(false)]
    public bool AssignedUserVisible
    {
        get
        {
            return objectAudit.AssignedUserVisible;
        }
        set
        {
            objectAudit.AssignedUserVisible = value;
        }
    }


    /// <summary>
    /// Gets or sets a flag to indicate whether the Object Name
    /// TextBox is visible.
    /// </summary>
    [DefaultValue(null), Localizable(false)]
    public bool ObjectNameVisible
    {
        get
        {
            return _objectName.Visible;
        }
        set
        {
            _objectName.Visible = value;
            objectNameCell.Visible = value;
        }
    }


    /// <summary>
    /// Gets or sets a flag to indicate whether the Object Name
    /// TextBox is enabled.
    /// </summary>
    [DefaultValue(null), Localizable(false)]
    public bool ObjectNameEnabled
    {
        get
        {
            return _objectName.Enabled;
        }
        set
        {
            _objectName.Enabled = value;
        }
    }

    /// <summary>
    /// Gets or sets a flag to indicate whether the Object Name
    /// TextBox is a compulsory field.
    /// </summary>
    [DefaultValue(null), Localizable(false)]
    public bool ObjectNameValidateRequiredField
    {
        get
        {
            return _objectName.ValidateRequiredField;
        }
        set
        {
            _objectName.ValidateRequiredField = value;
            labelObjectNameRequired.Visible = value;
        }
    }


    /// <summary>
    /// Gets or sets a flag to indicate whether the Object Number
    /// TextBox is visible.
    /// </summary>
    [DefaultValue(null), Localizable(false)]
    public bool ObjectNumberVisible
    {
        get
        {
            return _objectNumber.Visible;
        }
        set
        {
            _objectNumber.Visible = value;
            objectNumberCell.Visible = value;
        }
    }


    /// <summary>
    /// Gets or sets a flag to indicate whether the Object Number
    /// TextBox is enabled.
    /// </summary>
    [DefaultValue(null), Localizable(false)]
    public bool ObjectNumberEnabled
    {
        get
        {
            return _objectNumber.Enabled;
        }
        set
        {
            _objectNumber.Enabled = value;
        }
    }


    /// <summary>
    /// Gets or sets a flag to indicate whether the Object Number
    /// TextBox is a compulsory field.
    /// </summary>
    [DefaultValue(null), Localizable(false)]
    public bool ObjectNumberValidateRequiredField
    {
        get
        {
            return _objectNumber.ValidateRequiredField;
        }
        set
        {
            _objectNumber.ValidateRequiredField = value;
            labelObjectNumberRequired.Visible = value;
        }
    }


    /// <summary>
    /// Gets the object name UIFieldTextBox control.
    /// </summary>
    [DefaultValue(null), Localizable(false)]
    public UIFieldTextBox ObjectName
    {
        get
        {
            return _objectName;
        }
    }

    /// <summary>
    /// Gets the object number UIFieldTextBox control.
    /// </summary>
    [DefaultValue(null), Localizable(false)]
    public UIFieldTextBox ObjectNumber
    {
        get
        {
            return _objectNumber;
        }
    }


    /// <summary>
    /// Gets the radio button list that contains the
    /// list of all available workflow actions at the
    /// object's current state.
    /// </summary>
    public UIFieldRadioList WorkflowActionRadioList
    {
        get
        {
            return workflowActionRadioList;
        }
    }


    /// <summary>
    /// Gets the current object's state name.
    /// </summary>
    public string CurrentObjectState
    {
        get
        {
            LogicLayerPersistentObject logicLayerPersistentObject = getPanel(Page).SessionObject as LogicLayerPersistentObject;

            if (logicLayerPersistentObject != null &&
                logicLayerPersistentObject.CurrentActivity != null &&
                logicLayerPersistentObject.CurrentActivity.ObjectName != null &&
                logicLayerPersistentObject.CurrentActivity.ObjectName.Trim() != "")
                return logicLayerPersistentObject.CurrentActivity.ObjectName;
            return "Start";
        }
    }


    /// <summary>
    /// Gets the name of the action that the user has selected
    /// in the workflow action radio button list.
    /// </summary>
    public string SelectedActionText
    {
        get
        {
            if (workflowActionRadioListActual.Items.Count > 0 &&
                workflowActionRadioListActual.SelectedIndex >= 0)
                return workflowActionRadioListActual.Items[workflowActionRadioListActual.SelectedIndex].Text;
            return "";
        }
    }


    /// <summary>
    /// Gets the event name of the action that the user has selected
    /// in the workflow action radio button list. This event name must
    /// be one of the events defined in the IAnacleEvent interface,
    /// or any interface decorated with the ExternalDataExchange attribute.
    /// </summary>
    public string SelectedAction
    {
        get
        {
            if (workflowActionRadioListActual.Items.Count > 0 &&
                workflowActionRadioListActual.SelectedIndex >= 0)
                return workflowActionRadioListActual.Items[workflowActionRadioListActual.SelectedIndex].Value;
            return "";
        }
    }


    // 2010.10.15
    // Kim Foong
    /// <summary>
    /// Gets the actual workflow action radio button list.
    /// </summary>
    private UIFieldRadioList WorkflowActionRadioListActual
    {
        get
        {
            return this.workflowActionRadioListActual;
        }
    }


    /// <summary>
    /// Initialize events.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        workflowActionRadioListActual.SelectedIndexChanged += new EventHandler(workflowActionRadioListActual_SelectedIndexChanged);
        objectPanel panel = getPanel(Page);
        panel.PopulateForm += new EventHandler(panel_PopulateForm);
        panel.ObjectBase = this;

        //if (ConfigurationManager.AppSettings["CustomizedInstance"] == "CHINAOPS")
        //{
        //    labelAssignedUserPositions.PropertyName = "AssignedUserPositions";
        //}
        //if (!(panel.SessionObject is LogicLayerPersistentObject))
        //{
        //    labelAssignedUserNames.PropertyName = "";
        //    labelAssignedUserPositions.PropertyName = "";
        //}

    }


    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="obj"></param>
    void panel_PopulateForm(object sender, EventArgs e)
    {
        // Clear the comments text box.
        //
        PersistentObject sessionObject = getPanel(Page).SessionObject;
        if (sessionObject is LogicLayerPersistentObject)
        {
            if (((LogicLayerPersistentObject)sessionObject).CurrentActivity != null)
            {
                ((LogicLayerPersistentObject)sessionObject).CurrentActivity.TaskCurrentComments = "";

                if (((LogicLayerPersistentObject)sessionObject).CurrentActivity.CurrentApprovalLevel != null)
                    labelCurrentApprovalLevel.Text = ((LogicLayerPersistentObject)sessionObject).CurrentActivity.CurrentApprovalLevel.ToString();
                else
                    labelCurrentApprovalLevel.Text = "";

                if (((LogicLayerPersistentObject)sessionObject).CurrentActivity.NumberOfApprovalsAtCurrentLevel != null)
                    labelApprovals.Text = ((LogicLayerPersistentObject)sessionObject).CurrentActivity.NumberOfApprovalsAtCurrentLevel.ToString();
                else
                    labelApprovals.Text = "";

                if (((LogicLayerPersistentObject)sessionObject).CurrentActivity.NumberOfApprovalsRequiredAtCurrentLevel != null)
                    labelApprovalsRequired.Text = ((LogicLayerPersistentObject)sessionObject).CurrentActivity.NumberOfApprovalsRequiredAtCurrentLevel.ToString();
                else
                    labelApprovalsRequired.Text = "";
            }
        }

        BindWorkflowTransitionDropdownList(getPanel(Page).SessionObject);
    }


    /// <summary>
    /// Gets the list item such that the value of
    /// corresponds to the eventName specified.
    /// </summary>
    /// <param name="eventName"></param>
    /// <returns></returns>
    public ListItem GetWorkflowRadioListItem(string eventName)
    {
        return workflowActionRadioList.Items.FindByValue(eventName);
    }


    /// <summary>
    /// Initializes the workflow transition dropdown list
    /// with a list of all transitions available to the user.
    /// </summary>
    protected void BindWorkflowTransitionDropdownList(PersistentObject persistentObject)
    {
        LogicLayerPersistentObject logicLayerPersistentObject = persistentObject as LogicLayerPersistentObject;

        if (logicLayerPersistentObject != null &&
            logicLayerPersistentObject.CurrentActivity != null) /*&&
            logicLayerPersistentObject.CurrentActivity.WorkflowInstanceID != null)*/
        {
            // Translate and set the name of the current status to the
            // label on the user interface.
            //
            if (logicLayerPersistentObject.CurrentActivity != null)
            {
                string currentStateName = "";
                if (logicLayerPersistentObject.CurrentActivity.ObjectName != null)
                    currentStateName = logicLayerPersistentObject.CurrentActivity.ObjectName;

                string translatedStateName = Resources.WorkflowStates.ResourceManager.GetString(currentStateName);
                if (translatedStateName == null)
                    translatedStateName = logicLayerPersistentObject.CurrentActivity.ObjectName;

                labelWorkflowName.Text = translatedStateName;

                buttonViewWorkflow.Visible = false;

                // 2010.11.09
                // Kim Foong
                // Sets the color for the various states (currently hard-coded)
                //
                System.Drawing.Color workflowColor = System.Drawing.Color.LimeGreen;
                if (currentStateName.Contains("Pending"))
                    workflowColor = System.Drawing.Color.Magenta;
                else if (currentStateName.Contains("InProgress"))
                    workflowColor = System.Drawing.Color.Magenta;
                else if (currentStateName.Contains("Approved"))
                    workflowColor = System.Drawing.Color.LimeGreen;
                else if (currentStateName.Contains("Awarded"))
                    workflowColor = System.Drawing.Color.LimeGreen;
                else if (currentStateName.Contains("Cancelled"))
                    workflowColor = System.Drawing.Color.Gray;
                else if (currentStateName.Contains("Close"))
                    workflowColor = System.Drawing.Color.Gray;
                else if (currentStateName.Contains("Start"))
                    workflowColor = System.Drawing.Color.Navy;
                else if (currentStateName.Contains("Draft"))
                    workflowColor = System.Drawing.Color.Navy;
                else if (currentStateName.Contains("Reject"))
                    workflowColor = System.Drawing.Color.Red;

                labelWorkflowName.ForeColor = workflowColor;

                // 2011.03.16
                // Kim Foong
                // Added this to show the windows workflow state for debugging purpose.
                //
                //labelWindowsWorkflowState.Text =
                //    new StateMachineWorkflowInstance(((WindowsWorkflowEngine)WindowsWorkflowEngine.Engine).WorkflowRuntime,
                //    new Guid(logicLayerPersistentObject.CurrentActivity.WorkflowInstanceID)).CurrentStateName;
                labelWindowsWorkflowState.Text = logicLayerPersistentObject.CurrentActivity.CurrentStateName;
            }

            // Adds the first line item into the radio button list.
            // This allows the user to save the object without performing
            // any transition to another state.
            //
            workflowActionRadioListActual.SelectedIndex = -1;
            workflowActionRadioList.Items.Clear();
            if (!persistentObject.IsNew)
            {
                workflowActionRadioList.Items.Add(new ListItem(Resources.Strings.Workflow_NoAction, "-"));
                workflowActionRadioList.Items[0].Selected = true;
            }


            // Gets the list of all events that can be triggered on
            // the workflow at its current status.
            //
            if (logicLayerPersistentObject.CurrentActivity != null)
            {
                string workflowInstanceId =
                    logicLayerPersistentObject.CurrentActivity.WorkflowInstanceID;
                //List<WorkflowEventInfo> workflowEvents = WorkflowEngine.Engine.GetWorkflowEvents(workflowInstanceId);
                List<WorkflowEventInfo> workflowEvents = WorkflowEngine.Engine.GetWorkflowEvents(persistentObject, logicLayerPersistentObject.CurrentActivity.CurrentStateName, workflowInstanceId);

                // 2010.10.15
                // Kim Foong
                // Since we are unable to get the order of the events from the workflow.xoml
                // file, we have to force the ordering.
                //
                List<string> eventNames = new List<string>();
                foreach (WorkflowEventInfo workflowEvent in workflowEvents)
                {
                    string eventName = workflowEvent.EventName;
                    if (eventName.Contains("SaveAsDraft"))
                        eventName = "000:" + eventName;
                    else if (eventName.Contains("Approve"))
                        eventName = "010:" + eventName;
                    else if (eventName.Contains("Reject"))
                        eventName = "011:" + eventName;
                    else if (eventName.Contains("Close"))
                        eventName = "900:" + eventName;
                    else if (eventName.Contains("Cancel"))
                        eventName = "901:" + eventName;
                    else
                        eventName = "500:" + eventName;
                    eventNames.Add(eventName);
                }
                eventNames.Sort();

                // 2010.10.15
                // Kim Foong
                // Modify the loop to use the eventNames list
                //
                //foreach (WorkflowEventInfo workflowEvent in workflowEvents)
                foreach (string eventName in eventNames)
                {
                    // 2010.10.15
                    // Kim Foong
                    // Modify this to use eventName
                    //string translatedText = Resources.WorkflowEvents.ResourceManager.GetString(
                    //    workflowEvent.EventName);
                    //if (translatedText == null)
                    //    translatedText = workflowEvent.EventName;
                    //ListItem item = new ListItem(translatedText, workflowEvent.EventName);
                    //workflowActionRadioList.Items.Add(item);
                    string actualEventName = eventName.Split(':')[1];
                    string translatedText = Resources.WorkflowEvents.ResourceManager.GetString(actualEventName);
                    if (translatedText == null)
                        translatedText = actualEventName;

                    ListItem item = new ListItem(translatedText, actualEventName);
                    workflowActionRadioList.Items.Add(item);
                }
                if (workflowActionRadioList.Items.Count > 0)
                    workflowActionRadioList.SelectedIndex = 0;

                workflowActionRadioListActual.Items.Clear();
                foreach (ListItem item in workflowActionRadioList.Items)
                    workflowActionRadioListActual.Items.Add(new ListItem(item.Text, item.Value));
                if (workflowActionRadioListActual.Items.Count > 0)
                    workflowActionRadioListActual.SelectedIndex = 0;
            }
        }
        else
        {
            panelWorkflow.Visible = false;
            tableCurrentStatus.Style["display"] = "none";
        }

    }


    /// <summary>
    /// Finds and returns the objectPanel object.
    /// </summary>
    /// <param name="c">The control within which to find.</param>
    /// <returns>The objectPanel.ascx object.</returns>
    protected objectPanel getPanel(Control c)
    {
        if (c.GetType() == typeof(objectPanel))
            return (objectPanel)c;
        foreach (Control child in c.Controls)
        {
            objectPanel o = getPanel(child);
            if (o != null)
                return o;
        }
        return null;
    }



    /// <summary>
    /// Occurs when the workflow status UIFieldDropDownList
    /// is changed.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    void workflowActionRadioListActual_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (WorkflowTransitionSelected != null)
            WorkflowTransitionSelected(sender, e);
    }



    /// <summary>
    /// Hides/shows elements
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        panelNumberOfApprovals.Visible = labelApprovalsRequired.Text != "" && labelApprovalsRequired.Text != "0";
        panelApprovalLevel.Visible = labelCurrentApprovalLevel.Text != "";

        objectNumberCell.Attributes["class"] = (this.ObjectNumberValidateRequiredField && this.ObjectNumberEnabled ? "field-required" : "");
        objectNameCell.Attributes["class"] = (this.ObjectNameValidateRequiredField && this.ObjectNameEnabled ? "field-required" : "");

        UpdateWorkflowActionRadionListActualItems();

        // 2010.10.15
        // Kim Foong
        // Hides the radio button list if the workflow buttons are shown at the top,
        // shows the radio button list if the workflow buttons are not shown.
        // 
        workflowActionRadioListActual.Visible = !getPanel(Page).ShowWorkflowActionAsButtons && workflowActionRadioListActual.IsContainerEnabled();
    }


    public void UpdateWorkflowActionRadionListActualItems()
    {
        // 2010.10.15
        // Kim Foong
        // Create a data table to be used to form the workflow buttons
        //
        System.Data.DataTable dt = new System.Data.DataTable();
        dt.Columns.Add("CommandName", typeof(string));
        dt.Columns.Add("Text", typeof(string));
        dt.Columns.Add("ImageUrl", typeof(string));
        dt.Columns.Add("Comment", typeof(string));

        // hide the action dropdownlist if its is disabled
        //
        // 2010.10.15
        // Kim Foong
        // Modified the following line to show the radio list based on whether
        // the object panel shows the action buttons at the top.
        //
        workflowActionRadioListActual.Visible = !getPanel(Page).ShowWorkflowActionAsButtons && workflowActionRadioListActual.IsContainerEnabled();

        string previousSelectedValue = workflowActionRadioListActual.SelectedValue;
        workflowActionRadioListActual.Items.Clear();
        foreach (ListItem item in workflowActionRadioList.Items)
        {
            if (item.Enabled)
            {
                workflowActionRadioListActual.Items.Add(new ListItem(item.Text, item.Value));

                // 2010.10.15
                // Kim Foong
                //
                // 2011.06.09, Kien Trung
                // NEW: Add full text of button text to another field
                // display it as tooltip
                // Substring the button text if the button length > 7.
                if (item.Value == "-")
                    dt.Rows.Add(item.Value, Resources.Strings.Workflow_Save, "~/images/workflow_save.png", item.Text);
                else
                {
                    string[] texts = item.Text.Split(' ');
                    if (texts.Length > 1)
                        dt.Rows.Add(item.Value, texts[0] + "...", "~/images/workflow_" + item.Value + ".png", item.Text);
                    else
                        dt.Rows.Add(item.Value, texts[0], "~/images/workflow_" + item.Value + ".png", item.Text);
                }
            }
        }
        if (previousSelectedValue != "")
            workflowActionRadioListActual.SelectedValue = previousSelectedValue;
        else
        {
            if (workflowActionRadioListActual.Items.Count > 0)
                workflowActionRadioListActual.SelectedIndex = 0;
        }

        // 2010.10.15
        // Kim Foong
        // Form the buttons.
        //
        objectPanel op = getPanel(Page);
        op.DataListWorkflowButtons.DataSource = dt;
        op.DataListWorkflowButtons.DataBind();
    }


    public event EventHandler WorkflowTransitionSelected;

    /// <summary>
    /// Pops up the workflow screen.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonViewWorkflow_Click(object sender, EventArgs e)
    {
        objectPanel a = getPanel(this.Page);
        a.FocusWindow = false;

        LogicLayerPersistentObject logicLayerPersistentObject = a.SessionObject as LogicLayerPersistentObject;

        int workflowVersionNumber = 0;

        if (logicLayerPersistentObject.CurrentActivity != null)
        {
            if (logicLayerPersistentObject.CurrentActivity.WorkflowVersionNumber != null)
                workflowVersionNumber = (int)logicLayerPersistentObject.CurrentActivity.WorkflowVersionNumber;
        }

        //Window.Open("../../images/wf.jpg", "_blank");

        Window.Open(ResolveUrl("~/modules/workflowrepository/WFDiagram.aspx?") + QueryString.New("OBJTYPE", Security.Encrypt(a.SessionObject.GetType().BaseType.Name))
                                                                       + QueryString.New("OBJSTATUS", Security.Encrypt(logicLayerPersistentObject.CurrentActivity.ObjectName))
                                                                       + QueryString.New("WFVER", Security.Encrypt(workflowVersionNumber.ToString())), "_blank");

    }

    /*

    /// <summary>
    /// Checks if the current persistent object is 
    /// in the specified state, and if the user
    /// has selected any of the actions specified
    /// in the selectedActionNames parameter.
    /// </summary>
    /// <param name="currentStateName"></param>
    /// <param name="actionName"></param>
    /// <returns></returns>
    public bool CheckStateAndSelectedAction(string currentStateName, params string[] selectedActionNames)
    {
        bool found = false;
        if (selectedActionNames != null)
            foreach (string selectedActionName in selectedActionNames)
                if (SelectedAction == selectedActionName)
                {
                    found = true;
                    break;
                }

        return found && CurrentObjectState == currentStateName;
    }

    /// <summary>
    /// Check if the current persistent object is in the state
    /// specified by stateNames parameter.
    /// </summary>
    /// <param name="stateNames"></param>
    /// <returns></returns>
    public bool CheckCurrentState(params string[] stateNames)
    {
        bool found = false;
        if (stateNames != null)
            foreach (string stateName in stateNames)
                if (CurrentObjectState == stateName)
                {
                    found = true;
                    break;
                }
        return found;
    }
*/

    /*
    /// <summary>
    /// Check if the selected next action is in the list
    /// specified by actionNames parameter.
    /// </summary>
    /// <param name="actionNames"></param>
    /// <returns></returns>
    public bool CheckSelectedAction(params string[] actionNames)
    {
        bool found = false;
        if (actionNames != null)
            foreach (string actionName in actionNames)
                if (SelectedAction == actionName)
                {
                    found = true;
                    break;
                }
        return found;
    }


    /// <summary>
    /// When current persistent object is in the state specified by currentStateName,
    /// disable the action specified by eventName 
    /// </summary>
    /// <param name="currentStateName"></param>
    /// <param name="eventName"></param>
    /// <param name="enabledFlag"></param>
    public void SetAction(string currentStateName, string eventName, bool enabledFlag)
    {
        ListItem listItem = null;
        if (CurrentObjectState == currentStateName)
        {
            listItem = this.WorkflowActionRadioList.Items.FindByValue(eventName);
            if (listItem != null)
            {
                listItem.Enabled = enabledFlag;
            }
        }
    }
    */
</script>

<div class='div-objectbase'>
    <ui:UIPanel runat="server" ID="panelObjectNameNumber" BorderStyle="NotSet" meta:resourcekey="panelObjectNameNumberResource2">
        <table cellpadding='0' cellspacing='0' border='0' width="100%">
            <tr>
                <td style='width: 158px' runat="server" id="objectNameCell">
                    <asp:Label runat="server" ID="labelObjectName" Text="Name"></asp:Label><asp:Label
                        runat="server" ID="labelObjectNameRequired" Text="*" Visible="false"></asp:Label><asp:Label
                            runat="server" ID="labelObjectNameColon" Text=":"></asp:Label>
                </td>
                <td>
                    <ui:UIFieldTextBox runat="server" ID="_objectName" Caption="Name" Span="Full" ShowCaption="false"
                        PropertyName="ObjectName" ValidateRequiredField="True" meta:resourcekey="_objectNameResource1"
                        CssClass="object-base" MaxLength="255" InternalControlWidth="95%" />
                </td>
                <td style='width: 158px' runat="server" id="objectNumberCell">
                    <asp:Label runat="server" ID="labelObjectNumber" Text="Number"></asp:Label><asp:Label
                        runat="server" ID="labelObjectNumberRequired" Text="*" Visible="false"></asp:Label><asp:Label
                            runat="server" ID="labelObjectNumberColon" Text=":"></asp:Label>
                </td>
                <td>
                    <ui:UIFieldTextBox runat="server" ID="_objectNumber" Caption="Number" Span="Full"
                        ShowCaption="false" PropertyName="ObjectNumber" meta:resourcekey="_objectNumberResource1"
                        CssClass="object-base" InternalControlWidth="95%" />
                </td>
            </tr>
        </table>
    </ui:UIPanel>
    <ui:UIPanel runat="server" ID="panelAuditInformation" BorderStyle="NotSet" meta:resourcekey="panelAuditInformationResource2">
        <div style="clear: both">
        </div>
        <web2:objectAudit runat="server" ID="objectAudit" />
        <%--<ui:UIFieldLabel runat="server" ID="CreatedBy" Caption="First Created By" Span="Full" PropertyName="" Font-Size="8pt" ForeColor="Gray"
        meta:resourcekey="CreatedByResource1" DataFormatString="">
    </ui:UIFieldLabel>--%>
        <%--<ui:UIFieldLabel runat="server" ID="CreatedDateTime" Caption="Created On" Span="Half" Visible="false"
        PropertyName="CreatedDateTime" meta:resourcekey="CreatedDateTimeResource1" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}">
    </ui:UIFieldLabel>--%>
        <%--<ui:UIFieldLabel runat="server" ID="ModifiedBy" Caption="Last Modified By" Span="Full" Font-Size="8pt" ForeColor="Gray"
        PropertyName="" meta:resourcekey="ModifiedByResource1" 
        DataFormatString="">
    </ui:UIFieldLabel>--%>
        <%--<ui:UIFieldLabel runat="server" ID="ModifiedDateTime" Caption="Modified On" Span="Half"
        PropertyName="ModifiedDateTime" meta:resourcekey="ModifiedDateTimeResource1" Visible="false"
        DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}">
    </ui:UIFieldLabel>--%>
        <%--<ui:UIPanel ID="panel_HideAssignedUser" runat="server" BorderStyle="NotSet"
        meta:resourcekey="panel_HideAssignedUserResource2">
        <ui:UIFieldLabel runat="server" ID="labelAssignedUserNames" Caption="Assigned User(s)"
            Font-Size="8pt" ForeColor="Gray"
            meta:resourcekey="labelAssignedUserNamesResource1" DataFormatString="" />
        <ui:UIFieldLabel runat="server" ID="labelAssignedUserPositions" Caption="Assigned Position(s)"
            Visible='False' Font-Size="8pt" ForeColor="Gray"
            meta:resourcekey="labelAssignedUserPositionsResource1" DataFormatString="" />
    </ui:UIPanel>--%>
        <table runat="server" cellpadding='1' cellspacing='0' border='0' style='width: 49.5%;
            float: left' height="24px" id="tableCurrentStatus">
            <tr>
                <td style='width: 157px'>
                    <asp:Label runat="server" ID="labelCurrentStatus" Text="Current Status:" ForeColor="Gray"
                        Font-Size="8pt" meta:resourcekey="labelCurrentStatusResource1"></asp:Label>
                </td>
                <td runat="server" id="cellCurrentStatus">
                    <ui:UIFieldLabel runat="server" ID="labelWorkflowName" FieldLayout="Flow" ShowCaption="False"
                        InternalControlWidth="" DataFormatString="" Font-Bold="true" Font-Size="11pt"
                        meta:resourcekey="labelWorkflowNameResource2">
                    </ui:UIFieldLabel>
                    <asp:Panel runat="server" ID="panelApprovalLevel" Style='display: inline' meta:resourcekey="panelApprovalLevelResource1">
                        <asp:Label runat="server" ID="labelApprovalLevel1" Text=" (Level " meta:resourcekey="labelApprovalLevel1Resource1"></asp:Label>
                        <ui:UIFieldLabel runat="server" ID="labelCurrentApprovalLevel" FieldLayout="Flow"
                            ShowCaption="False" InternalControlWidth="" DataFormatString="" meta:resourcekey="labelCurrentApprovalLevelResource1">
                        </ui:UIFieldLabel>
                        <asp:Label runat="server" ID="labelApprovalLevel2" Text=")" meta:resourcekey="labelApprovalLevel2Resource1"></asp:Label>
                        <asp:Label runat="server" ID="labelWindowsWorkflowState" ForeColor="White"></asp:Label>
                    </asp:Panel>
                </td>
                <td>
                    <ui:UIButton runat="server" ID="buttonViewWorkflow" OnClick="buttonViewWorkflow_Click"
                        Visible="false" CausesValidation="false" AlwaysEnabled="true" CssClass="" MouseDownCssClass=""
                        Text="View Workflow"></ui:UIButton>
                </td>
            </tr>
        </table>
        <asp:Panel runat="server" ID="panelNumberOfApprovals" meta:resourcekey="panelNumberOfApprovalsResource1">
            <table cellpadding='1' cellspacing='0' border='0' style='width: 49.5%; float: left'
                height="24px">
                <tr>
                    <td style='width: 150px'>
                        <asp:Label runat="server" ID="labelApprovalsGiven" Text="Approvals Given at this Level:"
                            meta:resourcekey="labelApprovalsGivenResource1"></asp:Label>
                    </td>
                    <td>
                        <ui:UIFieldLabel runat="server" ID="labelApprovals" ShowCaption="False" FieldLayout="Flow"
                            InternalControlWidth="10px" DataFormatString="" meta:resourcekey="labelApprovalsResource1">
                        </ui:UIFieldLabel>
                        <asp:Label runat="server" ID="labelOutOf" Text="out of" meta:resourcekey="labelOutOfResource1"></asp:Label>
                        <ui:UIFieldLabel runat="server" ID="labelApprovalsRequired" ShowCaption="False" FieldLayout="Flow"
                            InternalControlWidth="10px" DataFormatString="" meta:resourcekey="labelApprovalsRequiredResource1">
                        </ui:UIFieldLabel>
                    </td>
                </tr>
            </table>
        </asp:Panel>
    </ui:UIPanel>
    <ui:UIPanel runat="server" ID="panelWorkflow" meta:resourcekey="panelWorkflowResource1"
        BorderStyle="NotSet">
        <%--<ui:UISeparator runat="server" ID="sep1" Caption="Task" meta:resourcekey="sep1Resource1" />--%>
        <ui:UIFieldRadioList runat="server" ID="workflowActionRadioList" Caption="Action"
            ValidateRequiredField='True' meta:resourcekey="workflowActionRadioListResource1"
            Visible="False" TextAlign="Right">
        </ui:UIFieldRadioList>
        <ui:UIFieldRadioList runat="server" ID="workflowActionRadioListActual" Caption="Action"
            ValidateRequiredField='True' meta:resourcekey="workflowActionRadioListResource1"
            TextAlign="Right">
        </ui:UIFieldRadioList>
    </ui:UIPanel>
    <ui:UISeparator runat="server" ID="sep" meta:resourcekey="sepResource2" />
</div>
