<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<script runat="server">

    protected void panel_PopulateForm(object sender, EventArgs e)
    {

        listStatus.Bind(OActivity.GetStatuses(Security.Decrypt(Request["TYPE"])), "ObjectName", "ObjectName");
        foreach (ListItem item in listStatus.Items)
        {
            string translated = Resources.WorkflowStates.ResourceManager.GetString(item.Text);
            if (translated != null && translated != "")
                item.Text = translated;
        }   
    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        
    }

    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        
    }

    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>PKMS.NET</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form2" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:search runat="server" ID="panel" Caption="Vendor Evaluation" GridViewID="gridResults" EditButtonVisible="false"
                BaseTable="tVendorEvaluation" AssignedCheckboxVisible="true" SearchType="ObjectQuery" OnPopulateForm="panel_PopulateForm" OnSearch="panel_Search">
            </web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" >                    
                        <ui:UIFieldTextBox runat="server" ID="textVendorEvaluationNumber" PropertyName="ObjectNumber" Caption="Vendor Evaluation Number" Span="Half"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textContractNumber" PropertyName="Contract.ObjectNumber" Caption="Contract Number" Span="Half"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textVendor" PropertyName="Vendor.ObjectName" Caption="Vendor" Span="full"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textTotalScore" PropertyName="TotalScore" SearchType="Range" Caption="Total Score"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textDescription" PropertyName="EvaluationRemarks" Caption="Evaluation Remarks" Span="full"></ui:UIFieldTextBox>
                        <ui:UIFieldDateTime runat="server" ID="dateStart" PropertyName="StartDate" SearchType="Range" Caption="Start Date"></ui:UIFieldDateTime>
                        <ui:UIFieldDateTime runat="server" ID="dateEnd" PropertyName="EndDate" SearchType="Range" Caption="End Date"></ui:UIFieldDateTime>
                        <ui:UIFieldListBox runat="server" ID="listStatus" PropertyName="CurrentActivity.ObjectName" Caption="Status" meta:resourcekey="listStatusResource1"></ui:UIFieldListBox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" >
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" 
                        OnRowDataBound="gridResults_RowDataBound" SortExpression="EndDate DESC, StartDate DESC, ProjectInformation.ObjectName, TypeOfService.ObjectName, Vendor.ObjectName">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                    CommandName="EditObject" HeaderText="">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" 
                                    CommandName="ViewObject" HeaderText="">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                    CommandName="DeleteObject" HeaderText="" ConfirmText="Are you sure you wish to delete this item?">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ObjectNumber" HeaderText="Evaluation No.">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Vendor.ObjectName" HeaderText="Vendor Name">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Contract.ObjectName" HeaderText="Contract Name">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="StartDate" HeaderText="Start Date" DataFormatString="{0:dd-MMM-yyyy}">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="EndDate" HeaderText="End Date" DataFormatString="{0:dd-MMM-yyyy}">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="TotalScore" HeaderText="Total Score" DataFormatString="{0:#,##0.00}">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CurrentActivity.ObjectName" HeaderText="Status" ResourceName="Resources.WorkflowStates">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject"></ui:UIGridViewCommand>
                            </Commands>
                        </ui:UIGridView>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
