<%@ Control Language="C#" ClassName="objectMemo" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.ComponentModel" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Register Src="objectPanel.ascx" TagPrefix="web2" TagName="object" %>

<script runat="server">
    /// <summary>
    /// Binds the memos to the gridview.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        objectPanel panel = getPanel(Page);
        
        if (!IsPostBack)
        {
            LogicLayerPersistentObject o = panel.SessionObject as LogicLayerPersistentObject;
            BindMemos(o);
        }
        else
            panel.Saved += new objectPanel.ObjectEventHandler(panel_Saved);
    }

    
    /// <summary>
    /// Binds the object memos.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    void panel_Saved(object sender, PersistentObject o)
    {
        BindMemos(o as LogicLayerPersistentObject);
    }


    /// <summary>
    /// Binds the memos to the gridview, and updates
    /// the tab view caption to reflect the number
    /// of memos.
    /// </summary>
    /// <param name="o"></param>
    protected void BindMemos(LogicLayerPersistentObject o)
    {
        if (o != null)
        {
            gridMemo.DataSource = o.Memos;
            gridMemo.DataBind();

            Control currentControl = this;
            while (currentControl != null)
            {
                if (currentControl is UITabView)
                {
                    string text = ((UITabView)currentControl).Caption;
                    int index = text.IndexOf(" (");
                    if (index >= 0)
                        text = text.Substring(0, index);

                    objectPanel panel = getPanel(Page);
                    if (panel.SessionObject is LogicLayerPersistentObject)
                        ((UITabView)currentControl).Caption = text + " (" + ((LogicLayerPersistentObject)panel.SessionObject).Memos.Count + ")";
                }
                currentControl = currentControl.Parent;
            }
        }
    }
    
    
    /// <summary>
    /// Adds the memo into the list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAdd_Click(object sender, EventArgs e)
    {
        if (panelMemo.IsValid)
        {
            this.getPanel(this.Page).Message = "";
            AddMessage();
        }
        else
        {
            this.getPanel(this.Page).Message = panelMemo.CheckErrorMessages();

        }
        
    }


    // hunts for the objectPanel.ascx control and finds the PersistentObject
    // the OAttachment object to the attached object
    //
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
    /// Add a new memo into the list of memos.
    /// </summary>
    protected void AddMessage()
    {
        objectPanel panel = getPanel(Page);
        LogicLayerPersistentObject sessionObject = panel.SessionObject as LogicLayerPersistentObject;

        if (sessionObject != null)
        {
            OMemo memo = TablesLogic.tMemo.Create();
            memo.AttachedObjectID = sessionObject.ObjectID;
            memo.Message = textMessage.Text;
            sessionObject.Memos.Add(memo);

            if (Page is UIPageBase)
                ((UIPageBase)Page).SetModifiedFlag();
        }

        textMessage.Text = "";
        BindMemos(sessionObject);

        panelAddMemo.Visible = !panelAddMemo.Visible;
    }

    protected void gridMemo_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "DeleteObject")
        {
            objectPanel panel = getPanel(Page);
            LogicLayerPersistentObject o = panel.SessionObject as LogicLayerPersistentObject;
            if (o != null)
            {
                foreach (Guid objectId in dataKeys)
                    o.Memos.RemoveGuid(objectId);
            }
            BindMemos(o);
        }

        if (commandName == "Comment")
        {
            panelAddMemo.Visible = !panelAddMemo.Visible;
            textMessage.SetFocus();
        }
    }

    protected void gridMemo_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            objectPanel panel = getPanel(Page);
            LogicLayerPersistentObject o = panel.SessionObject as LogicLayerPersistentObject;
            OMemo m = o.Memos[e.Row.RowIndex];

            string MemoDisplay = "";
            if (m.CreatedUser != null)
                MemoDisplay += String.Format(Resources.Strings.GeneralDisplayTitleFontColor, m.CreatedUser);
            else
                MemoDisplay += String.Format(Resources.Strings.GeneralDisplayTitleFontColor, AppSession.User.ObjectName);

            if (m.CreatedDateTime.HasValue)
                MemoDisplay += String.Format(Resources.Strings.GeneralDisplayCreatedTimeFontColor, m.CreatedDateTime.Value.ToFriendlyString());
            else
                MemoDisplay += String.Format(Resources.Strings.GeneralDisplayCreatedTimeFontColor, DateTime.Now.AddSeconds(-1).ToFriendlyString());

            if (m.Message != null)
                MemoDisplay += m.Message + "<br />";

            e.Row.Cells[2].Text = MemoDisplay;

            if (!m.IsNew && m.CreatedUser != AppSession.User.ObjectName)
                e.Row.Cells[1].Text = "";
        }
    }
</script>

<link href="App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
<ui:UIObjectPanel runat="server" ID="panelMemo">
    <ui:UIGridView runat="server" ID="gridMemo" SortExpression="CreatedDateTime ASC"
        PageSize="100" Caption="Memo" CheckBoxColumnVisible="false" AllowPaging="false" CommandPosition="Bottom"
        meta:resourcekey="gridMemoResource1" OnAction="gridMemo_Action" OnRowDataBound="gridMemo_RowDataBound">
        <Columns>
            <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                ConfirmText="Are you sure you wish to delete this item?" 
                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource3">
                <ItemStyle HorizontalAlign="Right" Width="24px" />
            </ui:UIGridViewButtonColumn>
            <ui:UIGridViewBoundColumn HeaderText="">
                <ItemStyle HorizontalAlign="Left" />
            </ui:UIGridViewBoundColumn>
        </Columns>
        <Commands>
            <ui:UIGridViewCommand CausesValidation="false" ImageUrl="~/images/edit.gif" CommandName="Comment" CommandText="Comment" />
        </Commands>
    </ui:UIGridView>
    <br />
    <ui:UIPanel runat="server" ID="panelAddMemo" Visible="false">
        <ui:UIFieldTextBox runat="server" ID="textMessage" 
            Caption="Enter your message" TextMode="MultiLine" CaptionPosition="Top"
            ToolTip="Enter your message here." MaxLength="0" Span="Full"
            Rows="3" ValidateRequiredField="True">
        </ui:UIFieldTextBox>
        <table cellpadding='0' cellspacing='0' border='0'>
            <tr>
                <td style="width: 5px">
                </td>
                <td>
                    <ui:UIButton runat="server" ID="buttonAdd" Text="Add Message" OnClick="buttonAdd_Click" meta:resourcekey="buttonAddResource1" />
                </td>
            </tr>
        </table>
    </ui:UIPanel>
</ui:UIObjectPanel>

