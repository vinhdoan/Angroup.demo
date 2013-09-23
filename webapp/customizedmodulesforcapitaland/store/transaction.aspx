<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

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
            <ui:UIPanel runat="server" ID="panelMonth" Width="100%" 
                meta:resourcekey="panelMonthResource1" BorderStyle="NotSet">
                <ui:UIButton ID="buttonPrev" runat="server" ImageUrl="~/images/resultset_previous.gif"
                    Text="Previous Month" OnClick="buttonPrev_Click" meta:resourcekey="buttonPrevResource1" />
                <asp:Label ID="Label1" runat="server" Width="120px" meta:resourcekey="Label1Resource1"></asp:Label>
                <ui:UIButton ID="buttonNext" runat="server" ImageUrl="~/images/resultset_next.gif"
                    Text="Next Month" OnClick="buttonNext_Click" meta:resourcekey="buttonNextResource1" />
            </ui:UIPanel>
            <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1" />
            <ui:UIPanel runat="server" ID="panelTransactions" Width="100%" 
                BorderStyle="NotSet" meta:resourcekey="panelTransactionsResource1" >
                <ui:UIGridView runat="server" ID="gridTransactions" PageSize="1000" SortExpression="DateOfTransaction"
                    Caption="Transactions" KeyName="ObjectID" meta:resourcekey="gridTransactionsResource1"
                    Width="100%" DataKeyNames="ObjectID" GridLines="Both" 
                    RowErrorColor="" style="clear:both;">
                    <PagerSettings Mode="NumericFirstLast" />
                    <Columns>                       
                        <cc1:UIGridViewBoundColumn DataField="SourceObjectNumber" 
                            HeaderText="Transaction Number" 
                            PropertyName="SourceObjectNumber"
                            SortExpression="SourceObjectNumber">
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </cc1:UIGridViewBoundColumn>                                    
                        <cc1:UIGridViewBoundColumn DataField="DateOfTransaction" 
                            DataFormatString="{0:dd-MMM-yyyy hh:mm:ss}" HeaderText="Date of Transaction" 
                            meta:resourceKey="UIGridViewColumnResource1" PropertyName="DateOfTransaction" 
                            ResourceAssemblyName="" SortExpression="DateOfTransaction">
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </cc1:UIGridViewBoundColumn>
                        <cc1:UIGridViewBoundColumn DataField="StoreItem.Catalogue.UnitOfMeasure.ObjectName" 
                            HeaderText="UnitOfMeasure" meta:resourceKey="UIGridViewColumnResource2" 
                            PropertyName="StoreItem.Catalogue.UnitOfMeasure.ObjectName" 
                            ResourceAssemblyName="" 
                            SortExpression="StoreItem.Catalogue.UnitOfMeasure.ObjectName">
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </cc1:UIGridViewBoundColumn>
                        <cc1:UIGridViewBoundColumn DataField="Quantity" 
                            DataFormatString="{0:#,##0.00##}" HeaderText="Quantity" 
                            meta:resourceKey="UIGridViewColumnResource3" PropertyName="Quantity" 
                            ResourceAssemblyName="" SortExpression="Quantity">
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </cc1:UIGridViewBoundColumn>
                        <cc1:UIGridViewBoundColumn DataField="UnitPrice" 
                            DataFormatString="{0:#,##0.00##}" HeaderText="Unit Price ($)" 
                            meta:resourceKey="UIGridViewColumnResource4" PropertyName="UnitPrice" 
                            ResourceAssemblyName="" SortExpression="UnitPrice">
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </cc1:UIGridViewBoundColumn>
                        <cc1:UIGridViewBoundColumn DataField="TransactionTypeText" 
                            HeaderText="Transaction Type" meta:resourceKey="UIGridViewColumnResource5" 
                            PropertyName="TransactionTypeText" ResourceAssemblyName="" 
                            SortExpression="TransactionTypeText">
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </cc1:UIGridViewBoundColumn>
                        <cc1:UIGridViewBoundColumn DataField="User.ObjectName" HeaderText="User Name" 
                            meta:resourceKey="UIGridViewColumnResource6" PropertyName="User.ObjectName" 
                            ResourceAssemblyName="" SortExpression="User.ObjectName">
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </cc1:UIGridViewBoundColumn>
                        <cc1:UIGridViewBoundColumn DataField="Work.ObjectNumber" 
                            HeaderText="Work Number" meta:resourceKey="UIGridViewColumnResource7" 
                            PropertyName="Work.ObjectNumber" ResourceAssemblyName="" 
                            SortExpression="Work.ObjectNumber">
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </cc1:UIGridViewBoundColumn>
                        <cc1:UIGridViewBoundColumn DataField="Remarks" 
                            HeaderText="Remarks" 
                            PropertyName="Remarks" ResourceAssemblyName="" 
                            SortExpression="Remarks">
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </cc1:UIGridViewBoundColumn>
                    </Columns>
                </ui:UIGridView>
            </ui:UIPanel>
        </div>
    </div>
    </form>
</body>
</html>
