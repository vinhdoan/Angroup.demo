<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<script runat="server">

    protected void panel_PopulateForm(object sender, EventArgs e)
    {

    }

    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    //protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    //{
    //    return new LocationTreePopulaterForCapitaland(null, false, true, Security.Decrypt(Request["TYPE"]), false, false);
    //}
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form2" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain">
        <web:search runat="server" ID="panel" Caption="Bill" GridViewID="gridResults" EditButtonVisible="false"
            AutoSearchOnLoad="true" SearchTextBoxHint="E.g.: Bill Number" SearchType="ObjectQuery"
            MaximumNumberOfResults="30" SearchTextBoxPropertyNames="ObjectNumber"
            AdvancedSearchPanelID=""
            BaseTable="tBill" meta:resourcekey="panelResource1" OnPopulateForm="panel_PopulateForm">
        </web:search>
        <div class="div-form">
            <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%">
                <Columns>
                    <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                        meta:resourcekey="UIGridViewColumnResource1">
                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                        <ItemStyle HorizontalAlign="Left" />
                    </ui:UIGridViewButtonColumn>
                    <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" ImageUrl="~/images/view.gif"
                        meta:resourcekey="UIGridViewColumnResource2">
                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                        <ItemStyle HorizontalAlign="Left" />
                    </ui:UIGridViewButtonColumn>
                    <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="DeleteObject"
                        HeaderText="" ConfirmText="Are you sure you wish to delete this item?">
                    </ui:UIGridViewButtonColumn>
                    <ui:UIGridViewBoundColumn PropertyName="ObjectNumber" HeaderText="Bill Number">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="Location.Path" HeaderText="Location">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="BatchID" HeaderText="Batch ID">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="AssetID" HeaderText="Asset ID">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="DebtorID" HeaderText="Debtor ID">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="LeaseID" HeaderText="Lease ID">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="ChargeFrom" HeaderText="Charge From" DataFormatString="{0:dd-MMM-yyyy}">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="ChargeTo" HeaderText="Charge To" DataFormatString="{0:dd-MMM-yyyy}">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="BillStatus" HeaderText="Posted to AMOS?">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </ui:UIGridViewBoundColumn>
                </Columns>
                <Commands>
                    <ui:UIGridViewCommand CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                        ImageUrl="~/images/delete.gif" CommandName="DeleteObject"></ui:UIGridViewCommand>
                </Commands>
            </ui:UIGridView>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
