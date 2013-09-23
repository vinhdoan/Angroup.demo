<%@ Control Language="C#" ClassName="objectAudit" %>
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
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">
     
    /// <summary>
    /// Gets or sets the Assigned User(s) TextBox's Visible property.
    /// </summary>
    [DefaultValue(true), Localizable(false)]
    public bool AssignedUserVisible
    {
        get
        {
            return panel_HideAssignedUser.Visible;
        }
        set
        {
            panel_HideAssignedUser.Visible = value;
        }
    }


    /// <summary>
    /// Initialize events.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        objectPanel panel = getPanel(Page);
        panel.PopulateForm += new EventHandler(panel_PopulateForm);
        panel.ObjectBase = this;

        if (ConfigurationManager.AppSettings["CustomizedInstance"] == "CHINAOPS")
        {
            labelAssignedUserPositions.PropertyName = "AssignedUserPositions";
        }
        if (!(panel.SessionObject is LogicLayerPersistentObject))
        {
            labelAssignedUserNames.PropertyName = "";
            labelAssignedUserPositions.PropertyName = "";
        }

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
        if (sessionObject is LogicLayerPersistentObject || sessionObject is PersistentObject)
        {
            if (sessionObject is LogicLayerPersistentObject && 
                ((LogicLayerPersistentObject)sessionObject).CurrentActivity != null)
            {
                labelAssignedUserPositions.Text = HttpUtility.HtmlEncode(((LogicLayerPersistentObject)sessionObject).AssignedUserPositionsWithUserNames);
                labelAssignedUserNames.Text = ((LogicLayerPersistentObject)sessionObject).AssignedUserNames;
            }

            if (sessionObject.CreatedDateTime.HasValue)
                CreatedBy.Text = String.Format("{0} on {1}", sessionObject.CreatedUser, sessionObject.CreatedDateTime.Value.AddSeconds(-1).ToFriendlyString());

            if (sessionObject.ModifiedDateTime.HasValue)
                ModifiedBy.Text = String.Format("{0} on {1}", sessionObject.ModifiedUser, sessionObject.ModifiedDateTime.Value.AddSeconds(-1).ToFriendlyString());
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
    /// Hides/shows elements
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        labelAssignedUserPositions.Visible = labelAssignedUserPositions.Text.Trim() != "";
        labelAssignedUserNames.Visible = labelAssignedUserNames.Text.Trim() != "";
    }

</script>

<%--<div class='div-objectbase'>--%>
    <ui:UIPanel runat="server" ID="panelAuditInformation" BorderStyle="NotSet" meta:resourcekey="panelAuditInformationResource2">
        <div style="clear: both">
        </div>
        <ui:UIFieldLabel runat="server" ID="CreatedBy" Caption="First Created By" Span="Full"
            PropertyName="" Font-Size="8pt" ForeColor="Gray" meta:resourcekey="CreatedByResource1"
            DataFormatString="">
        </ui:UIFieldLabel>
        <ui:UIFieldLabel runat="server" ID="ModifiedBy" Caption="Last Modified By" Span="Full"
            Font-Size="8pt" ForeColor="Gray" PropertyName="" meta:resourcekey="ModifiedByResource1"
            DataFormatString="">
        </ui:UIFieldLabel>
        <ui:UIPanel ID="panel_HideAssignedUser" runat="server" BorderStyle="NotSet" meta:resourcekey="panel_HideAssignedUserResource2">
            <ui:UIFieldLabel runat="server" ID="labelAssignedUserNames" Caption="Assigned User(s)"
                Font-Size="8pt" ForeColor="Gray" meta:resourcekey="labelAssignedUserNamesResource1"
                DataFormatString="" />
            <ui:UIFieldLabel runat="server" ID="labelAssignedUserPositions" Caption="Assigned Position(s)"
                Visible='False' Font-Size="8pt" ForeColor="Gray" meta:resourcekey="labelAssignedUserPositionsResource1"
                DataFormatString="" />
        </ui:UIPanel>
        <div style="clear: both">
        </div>
    </ui:UIPanel>
<%--</div>--%>
