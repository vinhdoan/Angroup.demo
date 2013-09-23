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
        OUnitConversion unitConversion = panel.SessionObject as OUnitConversion;

        FromUnitOfMeasureID.Enabled = unitConversion.IsNew;
        FromUnitOfMeasureID.Bind(OCode.GetCodesByType("UnitOfMeasure", unitConversion.FromUnitOfMeasureID));

        panel.ObjectPanel.BindObjectToControls(unitConversion);
    }


    /// <summary>
    /// Validates and saves the unit conversion object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OUnitConversion unitConversion = panel.SessionObject as OUnitConversion;
            panel.ObjectPanel.BindControlsToObject(unitConversion);

            // Validate
            //
            if (unitConversion.HasDuplicateUnitOfMeasure())
                FromUnitOfMeasureID.ErrorMessage = Resources.Errors.UnitConversion_FromUnitDuplicate;
            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            unitConversion.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// Hides/shows controls
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        if (FromUnitOfMeasureID.SelectedItem != null)
            labelConversionFromUnit.Text = FromUnitOfMeasureID.SelectedItem.Text;
        if (ToUnitOfMeasureID.SelectedItem != null)
            labelConversionToUnit.Text = ToUnitOfMeasureID.SelectedItem.Text;

    }


    /// <summary>
    /// Populates the unit conversions subpanel.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void UnitConversionsTo_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OUnitConversionTo unitConversionTo = UnitConversionsTo_SubPanel.SessionObject as OUnitConversionTo;
        ToUnitOfMeasureID.Bind(OCode.GetCodesByType("UnitOfMeasure", unitConversionTo.ToUnitOfMeasureID));
        
        UnitConversionsTo_SubPanel.ObjectPanel.BindObjectToControls(unitConversionTo);
    }


    /// <summary>
    /// Validates and adds the unit conversion to object into the
    /// main unit conversion object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void UnitConversionsTo_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        OUnitConversionTo unitConversionTo = UnitConversionsTo_SubPanel.SessionObject as OUnitConversionTo;
        UnitConversionsTo_SubPanel.ObjectPanel.BindControlsToObject(unitConversionTo);

        // Validate
        //
        if (FromUnitOfMeasureID.SelectedValue == ToUnitOfMeasureID.SelectedValue &&
            FromUnitOfMeasureID.SelectedValue != "")
            ToUnitOfMeasureID.ErrorMessage = Resources.Errors.UnitConversion_ToUnitOfMeasureInvalid;
        if (!unitConversionTo.ValidateConversionHasLessThanFourDecimalPlaces())
            ConversionFactor.ErrorMessage = String.Format(Resources.Errors.UnitConversion_ConversionFactorMoreThanFourDecimalPlaces, unitConversionTo.ConversionFactor);
        
        if (!panel.ObjectPanel.IsValid)
            return;

        // Add
        //
        OUnitConversion unitConversion = panel.SessionObject as OUnitConversion;
        panel.ObjectPanel.BindControlsToObject(unitConversion);
        unitConversion.UnitConversionsTo.Add(unitConversionTo);
        panel.ObjectPanel.BindObjectToControls(unitConversion);
    }

    
    /// <summary>
    /// Occurs when the user selects the "To" unit of measure.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ToUnitOfMeasureID_SelectedIndexChanged(object sender, EventArgs e)
    {
        
    }

    protected void FromUnitOfMeasureID_SelectedIndexChanged(object sender, EventArgs e)
    {

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
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource2">
            <web:object runat="server" ID="panel" Caption="Unit Conversion" BaseTable="tUnitConversion"
                OnPopulateForm="panel_PopulateForm"
                meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave"></web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" 
                    meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView ID="uitabview1" runat="server"  Caption="Details"
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <web:base ID="objectBase" runat="server" ObjectNumberVisible="false" ObjectNameVisible="false"
                            ObjectNumberValidateRequiredField="true"></web:base>
                        &nbsp; &nbsp; &nbsp; &nbsp;
                        <ui:UIFieldDropDownList ID="FromUnitOfMeasureID" runat="server" Caption="From Unit"
                            PropertyName="FromUnitOfMeasureID" ValidateRequiredField="True" meta:resourcekey="FromUnitOfMeasureIDResource1" OnSelectedIndexChanged="FromUnitOfMeasureID_SelectedIndexChanged">
                        </ui:UIFieldDropDownList>
                        <br />
                        <br />
                        <br />
                        <br />
                        <ui:UIGridView ID="UnitConversionsTo" runat="server" Caption="Conversions" PropertyName="UnitConversionsTo"
                            SortExpression="ToUnitOfMeasure.ObjectName" KeyName="ObjectID" 
                            Width="100%" meta:resourcekey="UnitConversionsToResource1" 
                            DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" 
                            style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="DeleteObject" CommandText="Delete" 
                                    ConfirmText="Are you sure you wish to delete the selected items?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" 
                                    meta:resourceKey="UIGridViewCommandResource2" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                    ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                    ConfirmText="Are you sure you wish to delete this item?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ToUnitOfMeasure.ObjectName" 
                                    HeaderText="To Unit" meta:resourceKey="UIGridViewColumnResource3" 
                                    PropertyName="ToUnitOfMeasure.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="ToUnitOfMeasure.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ConversionFactor" 
                                    DataFormatString="{0:#,##0.####}" HeaderText="Conversion Factor" 
                                    meta:resourceKey="UIGridViewColumnResource4" PropertyName="ConversionFactor" 
                                    ResourceAssemblyName="" SortExpression="ConversionFactor">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel ID="UnitConversionsTo_Panel" runat="server" 
                            meta:resourcekey="UnitConversionsTo_PanelResource1" BorderStyle="NotSet">
                            <web:subpanel runat="server" ID="UnitConversionsTo_SubPanel" GridViewID="UnitConversionsTo"
                                OnPopulateForm="UnitConversionsTo_SubPanel_PopulateForm"
                                OnValidateAndUpdate="UnitConversionsTo_SubPanel_ValidateAndUpdate"></web:subpanel>
                            <ui:UIFieldDropDownList ID="ToUnitOfMeasureID" runat="server" Caption="To Unit" PropertyName="ToUnitOfMeasureID"
                                ValidateRequiredField="True" meta:resourcekey="ToUnitOfMeasureIDResource1" OnSelectedIndexChanged="ToUnitOfMeasureID_SelectedIndexChanged">
                            </ui:UIFieldDropDownList>
                            &nbsp;<br />
                            <br />
                            <table style="width:100%">
                                <tr>
                                    <td style='width: 120px' class="field-required">
                                        <asp:label runat="server" id="labelConversionFactorCaption" 
                                            meta:resourcekey="labelConversionFactorCaptionResource2" 
                                            Text="Conversion Factor*:"></asp:label>
                                    </td>
                                    <td>
                                        <asp:label runat="server" id="labelConversionFactor1" 
                                            meta:resourcekey="labelConversionFactor1Resource2" Text="1"></asp:label>
                                        <asp:label runat="server" id="labelConversionFromUnit" 
                                            meta:resourcekey="labelConversionFromUnitResource2"></asp:label>
                                        <asp:label runat="server" id="labelConversionFactor2" 
                                            meta:resourcekey="labelConversionFactor2Resource2" Text="is equal to"></asp:label>
                                        <ui:UIFieldTextBox ID="ConversionFactor" runat="server" Caption="Conversion Factor"
                                            PropertyName="ConversionFactor" Span="Half" ValidateRequiredField="True" 
                                            ValidateDataTypeCheck="True" showcaption='False' fieldlayout="Flow" InternalControlWidth="100px"
                                            ValidationDataType="Currency" meta:resourcekey="ConversionFactorResource1"></ui:UIFieldTextBox>
                                        <asp:label runat="server" id="labelConversionToUnit" 
                                            meta:resourcekey="labelConversionToUnitResource2"></asp:label>
                                    </td>
                                </tr>
                            </table>
                        </ui:UIObjectPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo"  
                        meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="uitabview2" runat="server"  Caption="Attachments"
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
