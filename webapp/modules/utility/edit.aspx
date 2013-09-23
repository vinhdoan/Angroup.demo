<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectpanel.ascx" TagPrefix="web" TagName="object" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">
    
    /// <summary>
    /// Constructs and returns the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater locationTree_TreePopulater(object sender)
    {
        List<OLocation> oLocation = TablesLogic.tLocation[Query.True];
        return new LocationTreePopulater(oLocation, false, true, Security.Decrypt(Request["TYPE"]));
    }
    
    
    // need to change
    /// <summary>
    /// When the location treeview changes, 
    /// the system must clear all UtilityValue objects from the Utility object, 
    /// and then for each s for the selected Location’s LocationType, 
    /// create a corresponding UtilityValue and add it the Utility object’s UtilityValues. 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void locationTree_SelectedNodeChanged(object sender, EventArgs e)
    {
        OUtility oUtility = ((OUtility)panelUtility.SessionObject);
        panelUtility.ObjectPanel.BindControlsToObject(oUtility);
        
        if (locationTree.SelectedValue != "")
        {
            OLocation objLocation = TablesLogic.tLocation[new Guid(locationTree.SelectedValue)];
            if (oUtility.UtilityValues.Count > 0)
                oUtility.UtilityValues.Clear();
            foreach (OLocationTypeUtility locationTypeUtility in objLocation.LocationType.LocationTypeUtilities)
            {
                OUtilityValue oUtilityValues = TablesLogic.tUtilityValue.Create();
                oUtilityValues.LocationTypeUtilityID = locationTypeUtility.ObjectID;
                oUtility.UtilityValues.Add(oUtilityValues);
            }
        }
        else
            if (oUtility.UtilityValues.Count > 0)
                oUtility.UtilityValues.Clear();

        panelUtility.ObjectPanel.BindObjectToControls(oUtility);
    }

    /// <summary>
    /// Validates and saves the utility object to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panelUtility_Save(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OUtility utility = panelUtility.SessionObject as OUtility;
            panelUtility.ObjectPanel.BindControlsToObject(utility);


            // Validate
            //
            if (StartDate.DateTime != null && EndDate.DateTime != null)
            {
                if (utility.StartDate.Value > utility.EndDate.Value)
                {
                    EndDate.ErrorMessage = Resources.Errors.Utility_DatetimeInvalid;
                }
            }
            bool bValueInValid = false;
            bool bValueNegative = false;
            foreach (OUtilityValue valueItem in utility.UtilityValues)
            {
                if (valueItem.Value != null)
                {
                    if (valueItem.Value <= 0)
                    {
                        bValueNegative = true;
                    }
                    
                    bValueInValid = true;
                }
            }
            if (bValueInValid == false)
                UtilityValuesGrid.ErrorMessage = Resources.Errors.Utility_UtilityValueInvalid;
            if (bValueNegative == true)
                UtilityValuesGrid.ErrorMessage = Resources.Errors.Utility_UtilityValueNegative;
            if (!panelUtility.ObjectPanel.IsValid)
                return;

            // Save
            utility.Save();
            c.Commit();
        }
    }

    protected void panelUtility_PopulateForm(object sender, EventArgs e)
    {
        OUtility utility = panelUtility.SessionObject as OUtility;
        
        locationTree.PopulateTree();

        panelUtility.ObjectPanel.BindObjectToControls(utility);
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panelUtility" Caption="Utility" BaseTable="tUtility"
                OnValidateAndSave="panelUtility_Save" OnPopulateForm="panelUtility_PopulateForm" meta:resourcekey="panelResource1" />
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="UtilityStrip" meta:resourcekey="UtilityStripResource1">
                    <ui:UITabView runat="server" ID="tabDetails"  Caption="Details"
                        meta:resourcekey="tabDetailsResource1">
                        <web:base runat="server" ID="objectBase" ObjectNameVisible="false" ObjectNumberVisible="false" />
                        <ui:UIFieldTreeList runat="server" ID="locationTree" Caption="Location" PropertyName="LocationID"
                            ValidateRequiredField="True" OnAcquireTreePopulater="locationTree_TreePopulater"
                            OnSelectedNodeChanged="locationTree_SelectedNodeChanged" meta:resourcekey="locationTreeResource2">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTextBox runat="server" ID="Description" Caption="Description" PropertyName="Description"
                            MaxLength="255" meta:resourcekey="DescriptionResource2"></ui:UIFieldTextBox>
                        <ui:UIFieldDateTime ID="StartDate" runat="server" Caption="Start Date" PropertyName="StartDate"
                            ValidateRequiredField="True" ValidationCompareType="Date" ValidateCompareField="True"
                            ValidationCompareControl="EndDate" ValidationCompareOperator="LessThanEqual"
                            Span="Half" ShowTimeControls="False" ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                            meta:resourcekey="StartDateResource2" />
                        <ui:UIFieldDateTime ID="EndDate" runat="server" Caption="End Date" PropertyName="EndDate"
                            ValidateRequiredField="True" ValidationCompareType="Date" ValidateCompareField="True"
                            ValidationCompareControl="StartDate" ValidationCompareOperator="GreaterThanEqual"
                            Span="Half" ShowTimeControls="False" ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                            meta:resourcekey="EndDateResource2" />
                        <ui:UIGridView ID="UtilityValuesGrid" runat="server" Caption="Utility Values" PropertyName="UtilityValues"
                            BindObjectsToRows="True" KeyName="ObjectID" Width="100%" AllowPaging="True" AllowSorting="True"
                            meta:resourcekey="UtilityValuesGridResource1" PagingEnabled="True" ImageRowErrorUrl=""
                            RowErrorColor="">
                            <Columns>
                                <ui:UIGridViewButtonColumn CommandName="DeleteObject" ImageUrl="~/images/delete.gif"
                                    ConfirmText="Really want to delete?" HeaderText="" meta:resourcekey="UIGridViewColumnResource2">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="LocationTypeUtility.ObjectName" HeaderText="Description"
                                    meta:resourcekey="UIGridViewColumnResource3">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="LocationTypeUtility.UnitOfMeasure.ObjectName"
                                    HeaderText="Unit of Measure" meta:resourcekey="UIGridViewColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Width="60%" HeaderText="Value" 
                                    meta:resourcekey="UIGridViewColumnResource5">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="Value" PropertyName="Value" ValidateRangeField="true" FieldLayout="flow"
                                            ValidationRangeMin="0" ValidateDataTypeCheck="true" ValidationDataType="Double" InternalControlWidth="100px"
                                            Span="Half" meta:resourcekey="ValueResource1" />
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="UtilityPanel" meta:resourcekey="UtilityPanelResource1">
                            <web:subpanel ID="Subpanel1" runat="server" GridViewID="UtilityValuesGrid" >
                            </web:subpanel>
                        </ui:UIObjectPanel>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
