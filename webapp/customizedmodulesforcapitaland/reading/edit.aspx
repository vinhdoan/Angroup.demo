<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

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
        OReading obj = (OReading)panel.SessionObject;

        if (obj.IsNew)
        {
            obj.Source = ReadingSource.Direct;
            obj.DateOfReading = DateTime.Now;
        }
        else
        {
            treeLocation.Enabled = false;
            treeEquipment.Enabled = false;
            dropPoint.Enabled = false;
        }

        if (obj.CreateOnBreachWorkID == null && (obj.Source == ReadingSource.Direct || obj.Source == ReadingSource.PDA) &&
            !(obj.BillToAMOSStatus == 1 | obj.BillToAMOSStatus == 2 | obj.BillToAMOSStatus == 4))
            panelReading.Enabled = true;
        else
            panelReading.Enabled = false;

        dropPoint.Bind(OPoint.GetPointsTable(obj.LocationID, obj.EquipmentID, obj.PointID), "ObjectName", "ObjectID", true);

        // 2011.01.31
        // Kim Foong
        // Removed this.
        //
        //if(obj.Point!=null)
        //{
        //    obj.Factor = obj.Point.Factor;
        //    obj.Discount = obj.Point.Discount;
        //    obj.Tariff = obj.Point.Tariff;
        //}
        panelReading2.Enabled = !(obj.BillToAMOSStatus == 1 | obj.BillToAMOSStatus == 2 | obj.BillToAMOSStatus == 4);
        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();

        panel.ObjectPanel.BindObjectToControls(obj);
    }


    /// <summary>
    /// Saves the calendar to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OReading obj = (OReading)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(obj);

            // Validate
            //
            if (!obj.ValidateLocationEquipment())
            {
                treeLocation.ErrorMessage = Resources.Errors.Reading_LocationEquipmentNotSelected;
                treeEquipment.ErrorMessage = Resources.Errors.Reading_LocationEquipmentNotSelected;
            }
            if (!panel.ObjectPanel.IsValid)
                return;

            OPoint point = TablesLogic.tPoint.Load(TablesLogic.tPoint.ObjectID == obj.PointID, true);

            if (point.IsReadingBackDate(obj.ObjectID, tbDate.DateTime))
                tbDate.ErrorMessage = Resources.Errors.Reading_ReadingBackDate;
            if (point.IsReadingWithTenantExist(obj.ObjectID, obj.DateOfReading))
                tbDate.ErrorMessage = Resources.Errors.Reading_ReadingWithTenantAlreadyExists;

            if (obj.DoesReadingExceedPreviousConsumptionBy1Point5Times())
                hintReading1Point5TimesMoreThanPrevious.Visible = true;
            else
                hintReading1Point5TimesMoreThanPrevious.Visible = false;
            
            // Save
            //
            obj.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        OReading r = panel.SessionObject as OReading;
        return new LocationTreePopulaterForCapitaland(r.LocationID, false, true
            , "OReading", true, false);
    }


    /// <summary>
    /// Constructs the equipment tree populator
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        OReading r = panel.SessionObject as OReading;
        return new EquipmentTreePopulater(r.EquipmentID, false, true, "OReading");
    }


    /// <summary>
    /// Occurs when the user selects a node on the equipment tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeEquipment_SelectedNodeChanged(object sender, EventArgs e)
    {
        treeLocation.SelectedValue = "";

        if (treeEquipment.SelectedValue != "")
            dropPoint.Bind(OPoint.GetPointsTable(null, new Guid(treeEquipment.SelectedValue), null), "ObjectName", "ObjectID", true);
        else
            dropPoint.Items.Clear();
    }


    /// <summary>
    /// Occurs when the user selects a node on the location tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeLocation_SelectedNodeChanged(object sender, EventArgs e)
    {
        treeEquipment.SelectedValue = "";
    
        if (treeLocation.SelectedValue != "")
            dropPoint.Bind(OPoint.GetPointsTable(new Guid(treeLocation.SelectedValue), null, null), "ObjectName", "ObjectID", true);
        else
            dropPoint.Items.Clear();
    }

    protected void dropPoint_SelectedIndexChanged(object sender, EventArgs e)
    {
        OReading obj = (OReading)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(obj);
        
        if (obj.Point != null)
        {
            obj.Factor = obj.Point.Factor;
            obj.Discount = obj.Point.Discount;
            obj.Tariff = obj.Point.Tariff;
            //obj.Consumption = ;
        }

        panel.ObjectPanel.BindObjectToControls(obj);
    }

    protected void tbDate_DateTimeChanged(object sender, EventArgs e)
    {
        OReading obj = (OReading)panel.SessionObject;
        if (!obj.IsNew)
        {
            if (obj.BillToAMOSStatus == 1 || obj.BillToAMOSStatus == 2 || obj.BillToAMOSStatus == 4)
            {
                panel.ObjectPanel.BindObjectToControls(obj);
                tbDate.ErrorMessage = Resources.Errors.Reading_ReadingDateChangeAfterPost;
            }
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
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
        meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Reading" BaseTable="tReading" OnPopulateForm="panel_PopulateForm"
            OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1" SaveAndNewButtonVisible="false"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" 
                meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="tabDetails" runat="server" Caption="Details" 
                    BorderStyle="NotSet" meta:resourcekey="tabDetailsResource1">
                    <web:base ID="objectBase" runat="server" ObjectNameVisible="false" ObjectNumberVisible="false">
                    </web:base>
                    <ui:uifieldtreelist id="treeLocation" runat="server" caption="Location" onacquiretreepopulater="treeLocation_AcquireTreePopulater" OnSelectedNodeChanged="treeLocation_SelectedNodeChanged" PropertyName="LocationID" meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                    </ui:uifieldtreelist>
                    <ui:uifieldtreelist id="treeEquipment" runat="server" caption="Equipment" onacquiretreepopulater="treeEquipment_AcquireTreePopulater" OnSelectedNodeChanged="treeEquipment_SelectedNodeChanged" PropertyName="EquipmentID" meta:resourcekey="treeEquipmentResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                    </ui:uifieldtreelist>
                    <ui:uifieldsearchabledropdownlist runat='server' id="dropPoint" PropertyName="PointID" Caption="Point" ValidaterequiredField="True" OnSelectedIndexChanged="dropPoint_SelectedIndexChanged" meta:resourcekey="dropPointResource1" SearchInterval="300"></ui:uifieldsearchabledropdownlist>
                    <ui:uifieldlabel runat="server" id="labelSource" PropertyName="SourceName" 
                        Caption="Source" DataFormatString="" meta:resourcekey="labelSourceResource1"></ui:uifieldlabel>
                    <ui:uipanel runat="server" id="panelReading" BorderStyle="NotSet" 
                        meta:resourcekey="panelReadingResource1">
                        <ui:UIFieldTextBox runat="server" Caption="Reading" ID="tbReading" PropertyName="Reading"
                            Span="Half" ValidateRequiredField="True" ValidateDataTypeCheck="True" 
                            ValidationDataType="Double" InternalControlWidth="95%" 
                            meta:resourcekey="tbReadingResource1">
                        </ui:UIFieldTextBox>
                        <ui:uihint runat="server" id="hintReading1Point5TimesMoreThanPrevious" 
                            Text="The current reading results in a consumption more than 1.5 times the previous consumption." 
                            Visible="False" 
                            meta:resourcekey="hintReading1Point5TimesMoreThanPreviousResource1"></ui:uihint>
                        <ui:UIFieldDateTime runat="server" Caption="Date Of Reading" ID="tbDate" PropertyName="DateOfReading"
                            ShowTimeControls="True" ValidateRequiredField="True" 
                            meta:resourcekey="tbDateResource1" ShowDateControls="True" OnDateTimeChanged="tbDate_DateTimeChanged">
                        </ui:UIFieldDateTime>
                    </ui:uipanel>
                    <ui:uipanel runat="server" id="panelReading2" BorderStyle="NotSet" meta:resourcekey="panelReading2Resource1" >
                        <ui:UIFieldTextBox runat="server" ID="Factor" Caption="Factor" PropertyName="Factor" InternalControlWidth="95%" meta:resourcekey="FactorResource1" />
                        <ui:UIFieldTextBox runat="server" ID="Tariff" Caption="Tariff" PropertyName="Tariff" InternalControlWidth="95%" meta:resourcekey="TariffResource1" />
                        <ui:UIFieldTextBox runat="server" ID="Discount" Caption="Discount%" PropertyName="Discount" InternalControlWidth="95%" meta:resourcekey="DiscountResource1" />
                        <ui:UIFieldTextBox runat="server" ID="Consumption" Caption="Consumption" PropertyName="Consumption" 
                        Enabled="False" InternalControlWidth="95%" meta:resourcekey="ConsumptionResource1"/>
                        <ui:UIFieldTextBox runat="server" ID="BillToAMOSStatus" Caption="Bill To AMOS Status" PropertyName="BillToAMOSStatusText" 
                        Enabled="False" InternalControlWidth="95%" meta:resourcekey="BillToAMOSStatusResource1"/>
                    </ui:uipanel>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
