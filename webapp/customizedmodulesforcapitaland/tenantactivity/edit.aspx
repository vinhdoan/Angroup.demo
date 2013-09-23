<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" 
    UICulture="auto" meta:resourcekey="PageResource2" %>

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
        OTenantActivity activity = (OTenantActivity)panel.SessionObject;
        
        List<OUser> tenants= TablesLogic.tUser.LoadList(TablesLogic.tUser.isTenant==1);
        dropTenant.Bind(tenants, "ObjectName", "ObjectID");
        ddlActivityType.Bind(OCode.GetCodesByType("TenantActivityType",activity.ActivityTypeID));
        panel.ObjectPanel.BindObjectToControls(activity);
    }
    
    
    /// <summary>
    /// Saves the calendar to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using(Connection c = new Connection())
        {
            OTenantActivity obj = (OTenantActivity)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(obj);

            // Validate
            //
            // if(!obj.ValidationSomething)
            //    someControl.ErrorMessage = "Please enter a valid value.";
            //
            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            obj.Save();
            c.Commit();
        }
    }




    protected void dropTenant_SelectedIndexChanged(object sender, EventArgs e)
    {
        OTenantActivity activity = panel.SessionObject as OTenantActivity;
        panel.ObjectPanel.BindControlsToObject(activity);
        if (dropTenant.SelectedValue != "")
            activity.Tenants.AddGuid(new Guid(dropTenant.SelectedValue));
        panel.ObjectPanel.BindObjectToControls(activity);
    }

    protected void gv_Tenants_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "RemoveObject")
        {
            OTenantActivity activity = panel.SessionObject as OTenantActivity;
            panel.ObjectPanel.BindControlsToObject(activity);
            foreach (Guid id in objectIds)
                activity.Tenants.RemoveGuid(id);
            panel.ObjectPanel.BindObjectToControls(activity);
        }
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
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Tenant Activity" BaseTable="tTenantActivity" 
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" meta:resourcekey="tabObjectResource1" >
                    <ui:UITabView ID="tabDetails" runat="server" Caption="Details" BorderStyle="NotSet" meta:resourcekey="tabDetailsResource2">
                        <web:base ID="objectBase" runat="server" ObjectNameVisible="false" ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1">
                        </web:base>
                        <ui:uifielddatetime runat="server" id="dateDateTimeOfActivity" ShowTimeControls="True" PropertyName="DateTimeOfActivity" Caption="Date" ValidaterequiredField="True" Span="Half" meta:resourcekey="dateDateTimeOfActivityResource2" ShowDateControls="True"></ui:uifielddatetime>
                        <ui:UIFieldDropDownList runat="server" ID="ddlActivityType" PropertyName="ActivityTypeID" Caption="Activity Type" ValidaterequiredField="True" meta:resourcekey="ddlActivityTypeResource1"></ui:UIFieldDropDownList>
                        <ui:UIFieldSearchableDropDownList runat="server" id="dropTenant" Caption="Tenant" OnSelectedIndexChanged="dropTenant_SelectedIndexChanged" meta:resourcekey="dropTenantResource2" SearchInterval="300"></ui:UIFieldSearchableDropDownList>
                        <table width="96%">
                            <tr>
                                <td width="96%">
                                    <ui:UIGridView runat="server" ID="gv_Tenants" PropertyName="Tenants"
                                       Caption="List of Tenants" ValidateRequiredField="True"
                                        KeyName="ObjectID" 
                                        BindObjectsToRows="True" DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" 
                                        style="clear:both;" OnAction="gv_Tenants_Action" meta:resourcekey="gv_TenantsResource1"> 
                                        <PagerSettings Mode="NumericFirstLast" />
                                        <commands>
                                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="RemoveObject" CommandText="Remove Selected" ConfirmText="Are you sure you wish to remove the selected items?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                                        </commands>
                                        <Columns>
                                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" CommandText="Remove Selected" ConfirmText="Are you sure you wish to remove the selected items?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewButtonColumn>
                                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Tenant's Name" meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                        </Columns>
                                    </ui:UIGridView>
                                </td>
                            </tr>
                        </table>
                        <ui:uifieldtextbox runat="server" id="textNameOfStaff" PropertyName="NameOfStaff" CAption="Name of Staff" InternalControlWidth="95%" meta:resourcekey="textNameOfStaffResource2"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat="server" id="textAgenda" PropertyName="Agenda" CAption="Agenda" InternalControlWidth="95%" meta:resourcekey="textAgendaResource2"></ui:uifieldtextbox>
                        <ui:uifieldtextbox runat="server" id="textDescription" PropertyName="Description" CAption="Description" TextMode="MultiLine" Rows="10" InternalControlWidth="95%" meta:resourcekey="textDescriptionResource2"></ui:uifieldtextbox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" BorderStyle="NotSet" meta:resourcekey="tabMemoResource2"  >
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabAttachments"  Caption="Attachments" BorderStyle="NotSet" meta:resourcekey="tabAttachmentsResource2">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
