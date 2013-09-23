<%@ Page Language="C#" Inherits="PageBase" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            OCalendar calendar = TablesLogic.tCalendar.Create();
            Session["Calendar"] = calendar;

            // Initialize fields in the calendar
            // object.
            calendar.ObjectName = "My Calendar";
            calendar.IsWorkDay0 = 1;
            calendar.IsWorkDay1 = 1;
            calendar.IsWorkDay2 = 1;
            calendar.IsWorkDay3 = 1;
            calendar.IsWorkDay4 = 1;
            calendar.IsWorkDay5 = 1;
            calendar.IsWorkDay6 = 1;

            // Bind from the calendar object to the
            // controls within the objectpanel, and
            // the nestedPanel. Controls within 
            // nestedObjectpanel will NOT be bound.
            //
            objectpanel.BindObjectToControls(calendar);
        }
    }


    /// <summary>
    /// Binds data keyed into the UI to the object 
    /// in session, then saves it.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonBindAndSave_Click(object sender, EventArgs e)
    {
        OCalendar calendar = Session["Calendar"] as OCalendar;
        
        // Bind data from the controls in the objectpanel,
        // nestedPanel to the calendar object. Controls
        // within the nestedObjectPanel will NOT be bound.
        //
        objectpanel.BindControlsToObject(calendar);

        using (Connection c = new Connection())
        {
            calendar.Save();
            c.Commit();
        }

        labelMessage.Text = "Saved successfully.";
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <%-- Data is not bound to and from this control because
             it exists outside of the objectpanel. --%>
        <ui:UIFieldLabel runat="server" ID="labelModifiedDateTime"
            Caption="Modified Date/Time" 
            PropertyName="ModifiedDateTime"
            DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" />

        <ui:UIObjectPanel runat="server" ID="objectpanel">
            <ui:UIFieldTextBox runat="server" ID="textObjectName" 
                Caption="Calendar Name" PropertyName="ObjectName">
            </ui:UIFieldTextBox>
            <ui:UIFieldLabel runat="server" ID="labelCreatedDateTime"
                Caption="Created Date/Time" PropertyName="CreatedDateTime"
                DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}">
            </ui:UIFieldLabel>
            <ui:UIFieldCheckBox ID="IsWorkDay0" runat="server" 
                Caption="Work Day" Text="Sunday"
                PropertyName="IsWorkDay0">
            </ui:UIFieldCheckBox>
            
            <%-- Data is bound to and from controls within 
                 this panel. --%>
            <ui:UIPanel runat="server" ID="nestedPanel">
                <ui:UIFieldCheckBox ID="IsWorkDay1" runat="server" 
                    Text="Monday" PropertyName="IsWorkDay1">
                    </ui:UIFieldCheckBox>
                <ui:UIFieldCheckBox ID="IsWorkDay2" runat="server" 
                    Text="Tuesday" PropertyName="IsWorkDay2">
                    </ui:UIFieldCheckBox>
            </ui:UIPanel>
                
            <%-- Data is NOT bound to and from this control because
                 it exists within a nested object panel. --%>
            <ui:UIObjectPanel runat="server" ID="nestedObjectpanel">
                <ui:UIFieldCheckBox ID="IsWorkDay3" runat="server" 
                    Text="Wednesday" PropertyName="IsWorkDay3">
                    </ui:UIFieldCheckBox>
                <ui:UIFieldCheckBox ID="IsWorkDay4" runat="server" 
                    Text="Thursday" PropertyName="IsWorkDay4">
                    </ui:UIFieldCheckBox>
                <ui:UIFieldCheckBox ID="IsWorkDay5" runat="server" 
                    Text="Friday" PropertyName="IsWorkDay5">
                    </ui:UIFieldCheckBox>
                <ui:UIFieldCheckBox ID="IsWorkDay6" runat="server" 
                    Text="Saturday" PropertyName="IsWorkDay6">
                    </ui:UIFieldCheckBox>
            </ui:UIObjectPanel>
                
            <br />
            <br />
            <ui:uibutton runat="server" ID="buttonBindAndSave" 
                ImageUrl="~/images/tick.gif" Text="Save"
                OnClick="buttonBindAndSave_Click" />
            <asp:Label runat="server" ID="labelMessage"></asp:Label>
        </ui:UIObjectPanel>
    </div>
    </form>
</body>
</html>
