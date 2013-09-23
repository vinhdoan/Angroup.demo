<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<script runat="server">

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Perform search.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        
    }
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
            <web:search runat="server" ID="panel" Caption="Audit Trail (Database Update)" GridViewID="gridResults" EditButtonVisible="false"
                BaseTable="TablesAuditTrail.tAuditTrailField" meta:resourcekey="panelResource1" SearchType="ObjectQuery" OnPopulateForm="panel_PopulateForm" OnSearch="panel_Search">
            </web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" >
                        <ui:uifieldtextbox runat='server' id="textTableName" PropertyName="AuditTrail.DatabaseTableName" Caption="Database Table Name"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat='server' id="textFieldName" PropertyName="FieldName" Caption="Database Field Name"></ui:uifieldtextbox>
                        <ui:uifielddatetime runat='server' id="textModifiedDateTime" PropertyName="ModifiedDateTime" Caption="Updated Date/Time" SearchType="Range" ShowTimeControls="false"></ui:uifielddatetime>
                        <ui:uifieldtextbox runat='server' id="textModifiedUser" PropertyName="ModifiedUser" Caption="Updated By"></ui:uifieldtextbox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" >
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" SortExpression="AuditTrail.ModifiedDateTime DESC, AuditTrail.ConnectionUpdateNumber DESC, FieldName">
                            <Columns>
                                <ui:UIGridViewBoundColumn PropertyName="AuditTrail.AuditObjectID" HeaderText="ObjectID">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="AuditTrail.AssociatedObjectID" HeaderText="ObjectID (Associated)">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="AuditTrail.DatabaseActionText" HeaderText="Database Action">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="AuditTrail.DatabaseTableName" HeaderText="Database Table Name">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="FieldName" HeaderText="Database Field Name">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="OldDBValue" HeaderText="Old Value">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="OldReadableValue" HeaderText="Joined Desc" >
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="NewDBValue" HeaderText="New Value">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="NewReadableValue" HeaderText="Joined Desc" >
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="AuditTrail.ConnectionUpdateNumber" Headertext="Update No." Visible="false" >
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="SequenceNumber" Headertext="Seq No." Visible="false" >
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="AuditTrail.ModifiedDateTime" HeaderText="Updated Date/Time" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="AuditTrail.ModifiedUser" HeaderText="Updated By">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
