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
    /// Show the 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Guid auditTrailId = (Guid)gridResults.DataKeys[e.Row.RowIndex][0];
            List<OAuditTrailField> auditTrailFields = TablesAuditTrail.tAuditTrailField.LoadList(
                TablesAuditTrail.tAuditTrailField.AuditTrailID == auditTrailId,
                TablesAuditTrail.tAuditTrailField.FieldName.Asc
                );

            // Construct a HTML table of the new/old field names and values.
            //
            StringBuilder sb = new StringBuilder();
            sb.Append("<table border='1' cellspacing='0' style='border: solid 1px #cccccc; border-collapse: collapse'>");
            sb.Append("<tr style='color:black; background-color:#dddddd'><td style='border: solid 1px #cccccc'><b>Field Name</b></td>");
            sb.Append("<td style='border: solid 1px #cccccc'><b>Old Value</b></td>");
            sb.Append("<td style='border: solid 1px #cccccc'><b>New Value</b></td></tr>");
            foreach (OAuditTrailField auditTrailField in auditTrailFields)
            {
                sb.Append("<tr>");
                sb.Append("<td style='border: solid 1px #cccccc'>" + auditTrailField.FieldName + " </td>");
                if (auditTrailField.OldReadableValue == null)
                    sb.Append("<td style='border: solid 1px #cccccc'>" + auditTrailField.OldDBValue + " </td>");
                else
                    sb.Append("<td style='border: solid 1px #cccccc'>" + auditTrailField.OldReadableValue + " </td>");

                if (auditTrailField.NewReadableValue == null)
                    sb.Append("<td style='border: solid 1px #cccccc'>" + auditTrailField.NewDBValue + " </td>");
                else
                    sb.Append("<td style='border: solid 1px #cccccc'>" + auditTrailField.NewReadableValue + " </td>");
                sb.Append("</tr>");
            }
            sb.Append("</table>");

            e.Row.Cells[11].Text = sb.ToString();
        }
    }


    /// <summary>
    /// Add custom conditions.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition = Query.True;

        //if (textObjectType.Text != "")
        //    e.CustomCondition = e.CustomCondition &
        //        (TablesAuditTrail.tAuditTrail.AuditObjectTypeName.Like("%" + textObjectType.Text + "%") |
        //        TablesAuditTrail.tAuditTrail.AssociatedObjectTypeName.Like("%" + textObjectType.Text + "%"));

        //if (textObjectDescription.Text != "")
        //    e.CustomCondition = e.CustomCondition &
        //        (TablesAuditTrail.tAuditTrail.AuditObjectDescription.Like("%" + textObjectDescription.Text + "%") |
        //        TablesAuditTrail.tAuditTrail.AssociatedObjectDescription.Like("%" + textObjectDescription.Text + "%"));

        //if (textObjectNumber.Text != "")
        //    e.CustomCondition = e.CustomCondition &
        //        (TablesAuditTrail.tAuditTrail.AuditObjectNumber.Like("%" + textObjectNumber.Text + "%") |
        //        TablesAuditTrail.tAuditTrail.AssociatedObjectNumber.Like("%" + textObjectNumber.Text + "%"));


        List<ColumnOrder> orderColumns = new List<ColumnOrder>();
        orderColumns.Add(TablesAuditTrail.tAuditTrail.ModifiedDateTime.Desc);

        e.CustomSortOrder = orderColumns;
    }

    protected void gridResults_Action(object sender, string commandName, List<object> dataKeys)
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
        <web:search runat="server" ID="panel" Caption="Audit Trail" GridViewID="gridResults"
            EditButtonVisible="false" BaseTable="TablesAuditTrail.tAuditTrail" SearchTextBoxHint="E.g.: Object Type Name, Description, Object Number"
            AutoSearchOnLoad="false" MaximumNumberOfResults="300" 
            SearchTextBoxPropertyNames="AuditObjectTypeName,AssociatedObjectTypeName,AuditObjectDescription,AssociatedObjectDescription,AuditObjectNumber,AssociatedObjectNumber"
            AdvancedSearchPanelID="panelAdvanced" meta:resourcekey="panelResource1" SearchType="ObjectQuery"
            OnPopulateForm="panel_PopulateForm" OnSearch="panel_Search"></web:search>
        <div class="div-form">
            <%--<ui:UITabStrip runat="server" ID="tabSearch">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" >--%>
            <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                <%--<ui:uifieldtextbox runat='server' id="textObjectType" Caption="Object Type"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat='server' id="textObjectDescription" Caption="Object Description"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat='server' id="textObjectNumber" Caption="Object Number"></ui:uifieldtextbox>
                        <ui:uiseparator runat="server" id="Uiseparator1" />--%>
                <ui:UIFieldDateTime runat='server' ID="textModifiedDateTime" PropertyName="ModifiedDateTime"
                    Caption="Updated Date/Time" SearchType="Range" ShowTimeControls="false">
                </ui:UIFieldDateTime>
                <ui:UIFieldTextBox runat='server' ID="textModifiedUser" PropertyName="ModifiedUser"
                    Caption="Updated By">
                </ui:UIFieldTextBox>
            </ui:UIPanel>
            <%--</ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" >--%>
            <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" SortExpression="ModifiedDateTime DESC, ConnectionUpdateNumber DESC"
                OnRowDataBound="gridResults_RowDataBound" OnAction="gridResults_Action">
                <Columns>
                    <ui:UIGridViewBoundColumn PropertyName="AuditObjectTypeName" HeaderText="Audit Object Type">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="AuditObjectNumber" HeaderText="Object Number">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="AuditObjectDescription" HeaderText="Description">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="AuditObjectNewVersionNumber" HeaderText="Version Number">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="AssociatedObjectTypeName" HeaderText="Associated Object Type">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="AssociatedObjectNumber" HeaderText="Object Number">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="AssociatedObjectDescription" HeaderText="Description">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="DatabaseActionText" HeaderText="Database Action">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="SubActionText" HeaderText="Sub-Action">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="DatabaseTableName" HeaderText="Database Table Name">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn HeaderText="Field Updates">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="ConnectionUpdateNumber" HeaderText="Update No."
                        Visible="false">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="ModifiedDateTime" HeaderText="Updated Date/Time"
                        DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}">
                    </ui:UIGridViewBoundColumn>
                    <ui:UIGridViewBoundColumn PropertyName="ModifiedUser" HeaderText="Updated By">
                    </ui:UIGridViewBoundColumn>
                </Columns>
            </ui:UIGridView>
            <%--</ui:UITabView>
                </ui:UITabStrip>--%>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
