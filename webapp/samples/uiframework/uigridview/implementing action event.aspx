<%@ Page Language="C#" Inherits="PageBase" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@ Import Namespace="System.Data" %>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            DataTable dt = TablesLogic.tWork.Select(
                TablesLogic.tWork.ObjectID,
                TablesLogic.tWork.ObjectNumber,
                TablesLogic.tWork.WorkDescription,
                TablesLogic.tWork.TypeOfService.ObjectName.As("TypeOfService"),
                TablesLogic.tWork.TypeOfWork.ObjectName.As("TypeOfWork"));

            grid.DataSource = dt;
            grid.DataBind();
        }
    }

    /// <summary>
    /// Handles the action event.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void grid_Action(object sender, string commandName, 
        List<object> dataKeys)
    {
        labelMessage.Text = commandName + ": ";

        // Show the list of all selected work ObjectIDs
        //
        foreach (object dataKey in dataKeys)
        {
            labelMessage.Text += dataKey.ToString() + "; ";
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form2" runat="server">
    <ui:UIPanel ID="panel" runat="server">
        <ui:UIGridView runat="server" ID="grid" Caption="Works" 
            OnAction="grid_Action">
            <Commands>
                <ui:UIGridViewCommand ImageUrl="~/images/tick.gif"
                    CommandText="Select Multiple" 
                    CommandName="SelectMultiple" />
            </Commands>
            <Columns>
                <ui:UIGridViewButtonColumn ImageUrl="~/images/tick.gif" 
                    CommandName="Select">
                </ui:UIGridViewButtonColumn>
                <ui:UIGridViewBoundColumn PropertyName="ObjectNumber"
                    HeaderText="Work Number">
                </ui:UIGridViewBoundColumn>
                <ui:UIGridViewBoundColumn PropertyName="WorkDescription"
                    HeaderText="Description">
                </ui:UIGridViewBoundColumn>
                <ui:UIGridViewBoundColumn PropertyName="TypeOfService"
                    HeaderText="Type of Service">
                </ui:UIGridViewBoundColumn>
                <ui:UIGridViewBoundColumn PropertyName="TypeOfWork"
                    HeaderText="Type of Work">
                </ui:UIGridViewBoundColumn>
            </Columns>
        </ui:UIGridView>
        <br />
        <br />
        <asp:Label runat="server" ID="labelMessage"></asp:Label>
    </ui:UIPanel>
    </form>
</body>
</html>
