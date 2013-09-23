<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        ORole role = panel.SessionObject as ORole;

        checkboxlistReports.Bind(OReport.GetAllReports(), "CategoryAndReportName", "ObjectID");
        checkboxlistDashboards.Bind(ODashboard.GetAllDashboards(), "ObjectName", "ObjectID");
        listFunctions.Bind(OFunction.GetAllFunctions(), "CategoryAndFunctionName", "ObjectID");

        panel.ObjectPanel.BindObjectToControls(role);
    }


    /// <summary>
    /// Validates and saves the role object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            ORole role = panel.SessionObject as ORole;
            panel.ObjectPanel.BindControlsToObject(role);

            // Validate
            //
            gridRoleFunction.ErrorMessage = "";
            if (role.IsDuplicateRoleCode())
                textRoleCode.ErrorMessage = Resources.Errors.Role_DuplicateRoleCode;

            // Save
            //
            role.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// Occurs when the user clicks on the Add Function button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAddFunction_Click(object sender, EventArgs e)
    {
        bool isExisted = false;
        ORole role = panel.SessionObject as ORole;
        panel.ObjectPanel.BindControlsToObject(role);
        panel.Message = "";

        foreach (ListItem item in (IEnumerable)listFunctions.Items)
        {
            if (item.Selected == true)
            {
                isExisted = false;
                foreach (ORoleFunction roleFunction in role.RoleFunctions)
                {
                    if (roleFunction.FunctionID == new Guid(item.Value))
                    {
                        isExisted = true;
                    }
                }
                if (!isExisted)
                {
                    ORoleFunction newRoleFunction = TablesLogic.tRoleFunction.Create();
                    newRoleFunction.FunctionID = new Guid(item.Value);
                    role.RoleFunctions.Add(newRoleFunction);
                }
            }
        }

        panel.ObjectPanel.BindObjectToControls(role);
    }

    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="serveR" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Role" BaseTable="tRole" OnPopulateForm="panel_PopulateForm"
                OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1"></web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" 
                    meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Details" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" ObjectNameVisible="false">
                        </web:base>
                        <ui:UIFieldTextBox runat="server" ID="textRoleCode" Caption="Role Code" PropertyName="RoleCode"
                            ValidateRequiredField="True" InternalControlWidth="95%" 
                            meta:resourcekey="textRoleCodeResource1" />
                        <ui:uihint runat="server" id="hintRoleCode" ImageUrl="~/images/error.gif" 
                            meta:resourcekey="hintRoleCodeResource1">
                            <asp:Table runat="server" CellPadding="4" CellSpacing="0" Width="100%">
                                <asp:TableRow runat="server">
                                    <asp:TableCell runat="server" VerticalAlign="Top" Width="16px"><asp:Image 
                                        runat="server" ImageUrl="~/images/error.gif" />
                                    </asp:TableCell>
                                    <asp:TableCell runat="server" VerticalAlign="Top"><asp:Label runat="server"> 
                                    &nbsp;&nbsp;&nbsp;&nbsp;The Role Code is used by the system to perform workflow assignments or 
                                    display a list of users for selection. Modifying the Role Code can cause 
                                    unexpected problems with workflows and modules that expect the Role Code to be a 
                                    pre-defined name.<br />
                                    <br />
                                    For example, the default Work workflow assigns users of the Role Code 
                                    &#39;WORKSUPERVISOR&#39; in the &#39;Pending Execution&#39; stage. Modifying the Role Code to 
                                    anything other than &#39;WORKSUPERVISOR&#39; will prevent the workflow engine from 
                                    finding the right users to assign to the Work.
                                    <br />
                                    <br />
                                    When in doubt, <b>DO NOT</b> modify the Role Code.</asp:Label>
                                    </asp:TableCell>
                                </asp:TableRow>
                            </asp:Table>
                        </ui:uihint>
                        <br />
                        <br />
                        <ui:UIFieldTextBox runat="server" ID="textRoleName" Caption="Role Name" PropertyName="RoleName"
                            ValidateRequiredField="True" InternalControlWidth="95%" 
                            meta:resourcekey="textRoleNameResource1" />
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabFunction" Caption="Function" 
                        meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                        <ui:UIFieldListBox ID="listFunctions" runat="server" 
                            Caption="Available Functions" meta:resourcekey="listFunctionsResource1"></ui:UIFieldListBox>
                        <table>
                            <tr>
                                <td width="120px">
                                </td>
                                <td>
                                    <ui:UIButton ID="buttonAddFunction" runat="server" CommandName="AddFunction" Text="Grant Selected Functions"
                                        ImageUrl="~/images/add.gif" OnClick="buttonAddFunction_Click" 
                                        meta:resourcekey="buttonAddFunctionResource1" />
                                </td>
                            </tr>
                        </table>
                        <br />
                        <ui:UIGridView runat="server" Span="Half" Caption="Granted Functions" BindObjectsToRows="True"
                            SortExpression="Function.CategoryName, Function.SubCategoryName, Function.FunctionName"
                            PropertyName="RoleFunctions" ID="gridRoleFunction"
                            PageSize="500" DataKeyNames="ObjectID" GridLines="Both" 
                            ImageRowErrorUrl="" meta:resourcekey="gridRoleFunctionResource1" 
                            RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="RemoveObject" CommandText="Remove" 
                                    ConfirmText="Are you sure you wish to remove this item?" 
                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
                                    ConfirmText="Are you sure you wish to remove this item?" 
                                    ImageUrl="~/images/delete.gif" 
                                    meta:resourcekey="UIGridViewButtonColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="Function.CategoryName" 
                                    HeaderText="Category" meta:resourcekey="UIGridViewBoundColumnResource1" 
                                    PropertyName="Function.CategoryName" ResourceAssemblyName="" 
                                    SortExpression="Function.CategoryName">
                                    <HeaderStyle HorizontalAlign="Left" Width="130px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Function.SubCategoryName" 
                                    HeaderText="Sub Category" meta:resourcekey="UIGridViewBoundColumnResource2" 
                                    PropertyName="Function.SubCategoryName" ResourceAssemblyName="" 
                                    SortExpression="Function.SubCategoryName">
                                    <HeaderStyle HorizontalAlign="Left" Width="130px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Function.FunctionName" 
                                    HeaderText="Function" meta:resourcekey="UIGridViewBoundColumnResource3" 
                                    PropertyName="Function.FunctionName" ResourceAssemblyName="" 
                                    SortExpression="Function.FunctionName">
                                    <HeaderStyle HorizontalAlign="Left" Width="130px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Allow Create" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource1">
                                    <ItemTemplate>
                                        <cc1:UIFieldCheckBox ID="ckb_Create" runat="server" CaptionWidth="1px" 
                                            FieldLayout="Flow" meta:resourcekey="ckb_CreateResource1" 
                                            PropertyName="AllowCreate" ShowCaption="False" TextAlign="Right">
                                        </cc1:UIFieldCheckBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" Width="150px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Allow Edit All" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource2">
                                    <ItemTemplate>
                                        <cc1:UIFieldCheckBox ID="ckb_Edit" runat="server" CaptionWidth="1px" 
                                            FieldLayout="Flow" meta:resourcekey="ckb_EditResource1" 
                                            PropertyName="AllowEditAll" ShowCaption="False" TextAlign="Right">
                                        </cc1:UIFieldCheckBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" Width="150px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Allow View All" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource3">
                                    <ItemTemplate>
                                        <cc1:UIFieldCheckBox ID="ckb_View" runat="server" CaptionWidth="1px" 
                                            FieldLayout="Flow" meta:resourcekey="ckb_ViewResource1" 
                                            PropertyName="AllowViewAll" ShowCaption="False" TextAlign="Right">
                                        </cc1:UIFieldCheckBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" Width="150px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Allow Delete All" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource4">
                                    <ItemTemplate>
                                        <cc1:UIFieldCheckBox ID="ckb_Delete" runat="server" CaptionWidth="1px" 
                                            FieldLayout="Flow" meta:resourcekey="ckb_DeleteResource1" 
                                            PropertyName="AllowDeleteAll" ShowCaption="False" TextAlign="Right">
                                        </cc1:UIFieldCheckBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" Width="150px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewBoundColumn DataField="Function.CategoryAndFunctionName" 
                                    meta:resourcekey="UIGridViewBoundColumnResource4" 
                                    PropertyName="Function.CategoryAndFunctionName" ResourceAssemblyName="" 
                                    SortExpression="Function.CategoryAndFunctionName" Visible="False">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="IsNew" 
                                    meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="IsNew" 
                                    ResourceAssemblyName="" SortExpression="IsNew" Visible="False">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="CreatedDateTime" 
                                    meta:resourcekey="UIGridViewBoundColumnResource6" 
                                    PropertyName="CreatedDateTime" ResourceAssemblyName="" 
                                    SortExpression="CreatedDateTime" Visible="False">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel ID="RoleFunction_ObjectPanel" runat="server" 
                            BorderStyle="NotSet" meta:resourcekey="RoleFunction_ObjectPanelResource1">
                            <web:subpanel runat="server" ID="RoleFunction_SubPanel" GridViewID="gridRoleFunction" />
                        </ui:UIObjectPanel>
                        &nbsp; &nbsp;&nbsp;
                        <br />
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabReports" Caption="Reports" 
                        BorderStyle="NotSet" meta:resourcekey="tabReportsResource1" >
                        <ui:UIFieldCheckBoxList runat="server" ID="checkboxlistReports" 
                            Caption="Granted Reports" PropertyName="ReportRole" 
                            meta:resourcekey="checkboxlistReportsResource1" TextAlign="Right" ></ui:UIFieldCheckBoxList>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabDashboards" Caption="Dashboards" 
                        BorderStyle="NotSet" meta:resourcekey="tabDashboardsResource1" >
                        <ui:UIFieldCheckBoxList runat="server" ID="checkboxlistDashboards" 
                            Caption="Granted Dashboards" PropertyName="DashboardRole" 
                            meta:resourcekey="checkboxlistDashboardsResource1" TextAlign="Right"></ui:UIFieldCheckBoxList>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" BorderStyle="NotSet" 
                        meta:resourcekey="tabMemoResource1" >
                        <web:memo ID="Memo1" runat="server"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Attachments" 
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>

