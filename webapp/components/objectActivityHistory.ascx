<%@ Control Language="C#" ClassName="objectActivityHistory" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.ComponentModel" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Register src="objectPanel.ascx" tagPrefix="web2" tagName="object" %>

<script runat="server">
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        // Add the Click event to the tabview containing this control.
        // 
        if (!gridWorkStatusHistory.Visible)
        {
            Control currentControl = this;
            while (currentControl != null)
            {
                if (currentControl is UITabView)
                {
                    ((UITabView)currentControl).Click += new EventHandler(objectActivityHistory_Click);
                    break;
                }
                currentControl = currentControl.Parent;
            }
        }
    }
    
    /// <summary>
    /// Finds and returns the objectPanel.ascx control.
    /// </summary>
    /// <param name="c"></param>
    /// <returns></returns>
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
    /// Binds the activity histories to the gridview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    void objectActivityHistory_Click(object sender, EventArgs e)
    {
        objectPanel panel = getPanel(this.Page);
        LogicLayerPersistentObject logicLayerPersistentObject = panel.SessionObject as LogicLayerPersistentObject;
        if (logicLayerPersistentObject != null)
        {
            // The activity histories are delay-loaded when the user clicks on the
            // tab containing this control. As it is expected that the
            // activity history table can be very huge, this is to help
            // speed up the opening of the edit page of an object.
            //
            gridWorkStatusHistory.DataSource = logicLayerPersistentObject.ActivityHistories;
            gridWorkStatusHistory.DataBind();
            gridWorkStatusHistory.Visible = true;

            RemoveClickEvent();
        }
    }

    
    /// <summary>
    /// Remove click event
    /// </summary>
    void RemoveClickEvent()
    {
        // Remove the Click event so that it does not trigger again.
        // 
        Control currentControl = this;
        while (currentControl != null)
        {
            if (currentControl is UITabView)
            {
                ((UITabView)currentControl).Click -= new EventHandler(objectActivityHistory_Click);
                break;
            }
            currentControl = currentControl.Parent;
        }
    }

    protected void gridWorkStatusHistory_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[1].Text != "&nbsp;")
            {
                e.Row.Cells[1].Text = Convert.ToDateTime(e.Row.Cells[1].Text).ToFriendlyString();
            }
        }
    }
</script>


<ui:uigridview runat="server" ID="gridWorkStatusHistory" Visible='false' 
    SortExpression="CreatedDateTime desc" PageSize="100" Caption="Status History" 
    CheckBoxColumnVisible="false" 
    KeyName="ObjectID" meta:resourcekey="gridWorkStatusHistoryResource1" OnRowDataBound="gridWorkStatusHistory_RowDataBound"> 
    <Columns>
        <ui:UIGridViewBoundColumn PropertyName="CreatedDateTime" HeaderText="Date/Time" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" meta:resourcekey="UIGridViewBoundColumnResource1">
        </ui:UIGridViewBoundColumn>
        <ui:UIGridViewBoundColumn PropertyName="CreatedUser" HeaderStyle-Width="150px" HeaderText="User" meta:resourcekey="UIGridViewBoundColumnResource2">
        </ui:UIGridViewBoundColumn>
        <ui:UIGridViewBoundColumn PropertyName="TriggeringEventName" ResourceName="Resources.WorkflowEvents" HeaderText="Action" meta:resourcekey="UIGridViewBoundColumnResource3">
        </ui:UIGridViewBoundColumn>
        <ui:UIGridViewBoundColumn PropertyName="CurrentStateName" ResourceName="Resources.WorkflowStates" HeaderText="Status" meta:resourcekey="UIGridViewBoundColumnResource4">
        </ui:UIGridViewBoundColumn>
        <ui:UIGridViewBoundColumn HeaderText="Comments" PropertyName="TaskPreviousComments" meta:resourcekey="UIGridViewBoundColumnResource5">
        </ui:UIGridViewBoundColumn>
    </Columns>
</ui:uigridview>

