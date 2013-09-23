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
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIPanel ID="UIPanel1" runat="server">
        <ui:UIGridView runat="server" ID="grid" Caption="Works">
            <Columns>
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
    </ui:UIPanel>
    </form>
</body>
</html>
