<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            ViewState["currentMonth"] = DateTime.Now;
            BindItemTransaction();
        }
    }


    protected void BindItemTransaction()
    {
        if (Request["ID"] == null)
            return;

        Guid storeItemId = Security.DecryptGuid(Request["ID"]);
        DateTime dt = (DateTime)ViewState["currentMonth"];

        Label1.Text = dt.ToString("MMM-yyyy");

        gridTransactions.DataSource = OStoreItemTransaction.GetStoreItemTransactions(storeItemId, dt.Year, dt.Month);
        gridTransactions.DataBind();
    }

    protected void buttonPrev_Click(object sender, EventArgs e)
    {
        DateTime dt = (DateTime)ViewState["currentMonth"];
        ViewState["currentMonth"] = dt.AddMonths(-1);
        BindItemTransaction();
        panelMonth.Update();
    }

    protected void buttonNext_Click(object sender, EventArgs e)
    {
        DateTime dt = (DateTime)ViewState["currentMonth"];
        ViewState["currentMonth"] = dt.AddMonths(1);
        BindItemTransaction();
        panelMonth.Update();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Untitled Page</title>
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div style="margin: 8px 8px 8px 8px">
        <div class="div-form">
            <ui:UIPanel runat="server" ID="panelMonth" Width="100%" meta:resourcekey="panelMonthResource1">
                <ui:UIButton ID="buttonPrev" runat="server" ImageUrl="~/images/resultset_previous.gif"
                    Text="Previous Month" OnClick="buttonPrev_Click" meta:resourcekey="buttonPrevResource1" />
                <asp:Label ID="Label1" runat="server" Width="120px" meta:resourcekey="Label1Resource1"></asp:Label>
                <ui:UIButton ID="buttonNext" runat="server" ImageUrl="~/images/resultset_next.gif"
                    Text="Next Month" OnClick="buttonNext_Click" meta:resourcekey="buttonNextResource1" />
            </ui:UIPanel>
            <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1" />
            <ui:UIPanel runat="server" ID="panelTransactions" Width="100%" >
                <ui:UIGridView runat="server" ID="gridTransactions" PageSize="1000" SortExpression="DateOfTransaction"
                    Caption="Transactions" KeyName="ObjectID" meta:resourcekey="gridTransactionsResource1"
                    Width="100%">
                    <Columns>
                        <ui:UIGridViewBoundColumn PropertyName="DateOfTransaction" HeaderText="Date of Transaction"
                            DataFormatString="{0:dd-MMM-yyyy hh:mm:ss}" meta:resourcekey="UIGridViewColumnResource1">
                        </ui:UIGridViewBoundColumn>
                        <ui:UIGridViewBoundColumn PropertyName="StoreItem.Catalogue.UnitOfMeasure.ObjectName"
                            HeaderText="UnitOfMeasure" meta:resourcekey="UIGridViewColumnResource2">
                        </ui:UIGridViewBoundColumn>
                        <ui:UIGridViewBoundColumn PropertyName="Quantity" HeaderText="Quantity" DataFormatString="{0:#,##0.00##}"
                            meta:resourcekey="UIGridViewColumnResource3">
                        </ui:UIGridViewBoundColumn>
                        <ui:UIGridViewBoundColumn PropertyName="UnitPrice" HeaderText="Unit Price ($)" DataFormatString="{0:#,##0.00##}"
                            meta:resourcekey="UIGridViewColumnResource4">
                        </ui:UIGridViewBoundColumn>
                        <ui:UIGridViewBoundColumn PropertyName="TransactionTypeText" HeaderText="Transaction Type"
                            meta:resourcekey="UIGridViewColumnResource5">
                        </ui:UIGridViewBoundColumn>
                        <ui:UIGridViewBoundColumn PropertyName="User.ObjectName" HeaderText="User Name" meta:resourcekey="UIGridViewColumnResource6">
                        </ui:UIGridViewBoundColumn>
                        <ui:UIGridViewBoundColumn PropertyName="Work.ObjectNumber" HeaderText="Work Number"
                            meta:resourcekey="UIGridViewColumnResource7">
                        </ui:UIGridViewBoundColumn>
                    </Columns>
                </ui:UIGridView>
            </ui:UIPanel>
        </div>
    </div>
    </form>
</body>
</html>
