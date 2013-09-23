<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" %>

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
        OMeter meter = panel.SessionObject as OMeter;
       
        List<OPosition> positions = AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"]));
        ddlLocation.Bind(OLocation.GetLocationsByType("Building", false, positions, meter.LocationID));
        // 2010.08.27
        // Default the meter type to an increasing meter for CapitaLand.
        //
        if (meter.IsIncreasingMeter == null)
            meter.IsIncreasingMeter = 1;
        textBarcode.Enabled = ddlLocation.Enabled=TypeOfMeterID.Enabled=textMaximumReading.Enabled=
            dropUnit.Enabled=txtBMSCode.Enabled=radioIsIncreasingMeter.Enabled=textFactor.Enabled=
            !meter.IsInUsing();
        
            
        TypeOfMeterID.Bind(OCode.GetCodesByType("AmosMeterType", meter.TypeOfMeterID));

        dropUnit.Bind(OCode.GetCodesByType("UnitOfMeasure", meter.UnitOfMeasureID));
        

        if (meter.IsNew)
        {
            meter.TypeOfMeterID = OApplicationSetting.Current.DefaultMeterTypeID;
            meter.UnitOfMeasureID = OApplicationSetting.Current.DefaultUnitOfMeasureID;
            meter.IsActive = 1;
        }

        panel.ObjectPanel.BindObjectToControls(meter);

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
            OMeter meter = panel.SessionObject as OMeter;
            OMeter obj = null;

            if (meter.Barcode != null && meter.Barcode != "")
                obj = TablesLogic.tMeter.Load(
                    TablesLogic.tMeter.Barcode == meter.Barcode &
                    TablesLogic.tMeter.IsActive == 1 &
                    TablesLogic.tMeter.ObjectID != meter.ObjectID);
            if (obj != null)
                textBarcode.ErrorMessage = Resources.Errors.Point_DuplicateBarcode;

            if (radioIsIncreasingMeter.SelectedIndex == 0)
            {
                meter.MaximumReading = null;
                meter.Factor = null;
            }

            ///*
            // * 2010.06.02
            // * Kim Foong
            // * To prevent creation of new points with the same name. 
            // * (and this happens often) 
            // * 
            if (meter.IsDuplicateName())
                objectBase.ObjectName.ErrorMessage = Resources.Errors.Meter_DuplicateName;
            meter.Save();
            c.Commit();
        }
    }

    //protected TreePopulater TreeTrigger_AcquireTreePopulater(object sender)
    //{
    //    OPoint pt = (OPoint)panel.SessionObject;
    //    return new PointTriggerTreePopulater(pt.PointTriggerID, false, true,
    //        Security.Decrypt(Request["TYPE"]));

    //}

    /// <summary>
    /// Occurs when the Location/Equipment radio button list
    /// is selected.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioIsApplicableForLocation_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Occurs when the user selects an item in Breach radio
    /// button list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioCreateWorkOnBreach_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        OMeter meter = panel.SessionObject as OMeter;
        panel.ObjectPanel.BindControlsToObject(meter);

        textMaximumReading.Visible = radioIsIncreasingMeter.SelectedValue == "1";
        textFactor.Visible = radioIsIncreasingMeter.SelectedValue == "1";
    }




    /// <summary>
    /// Constructs and returns the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    //protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    //{
    //    OMeter meter = panel.SessionObject as OMeter;
    //    return new LocationTreePopulaterForCapitaland(meter.LocationID, false
    //        , true, Security.Decrypt(Request["TYPE"]), true, false);
    //}





    /// <summary>
    /// Refreshes the readings.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    //protected void buttonRefresh_Click(object sender, EventArgs e)
    //{
    //    OPoint point = panel.SessionObject as OPoint;
    //    gridReadings.DataSource = OReading.GetReadingsByPoint(point.ObjectID.Value, 1000);
    //    gridReadings.DataBind();
    //    gridReadings.Visible = true;
    //}


    /// <summary>
    /// Occurs when the user selects an item in the increasing meter radio button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioIsIncreasingMeter_SelectedIndexChanged(object sender, EventArgs e)
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
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" >
        <web:object runat="server" ID="panel" Caption="Meter" BaseTable="tMeter" OnPopulateForm="panel_PopulateForm" AutomaticBindingAndSaving="false" OnValidateAndSave="panel_ValidateAndSave"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" >
                <ui:UITabView ID="uitabview1" runat="server" Caption="Details" BorderStyle="NotSet" >
                    <ui:uipanel runat="server" id="panelDetails" BorderStyle="NotSet" >
                        <web:base ID="objectBase" runat="server" ObjectNameCaption="Meter Name" ObjectNumberVisible="false"></web:base>
                            <ui:UIFieldCheckBox runat="server" ID="IsActive" PropertyName="IsActive" Caption="Is Active" Text="Yes, this Meter is active, and can be linked to a Point" TextAlign="Right" />
                            
                            <ui:UIFieldDropDownList runat="server" ID="ddlLocation" PropertyName="LocationID" Caption ="location" ValidateRequiredField="True">
                            </ui:UIFieldDropDownList>

                            <ui:UIFieldTextBox runat="server" ID="textBarcode" PropertyName="Barcode" Caption="Barcode" InternalControlWidth="95%" >
                            </ui:UIFieldTextBox>
                            
                             <ui:UIFieldDropDownList runat="server" ID="dropUnit" PropertyName="UnitOfMeasureID" Caption="Unit Of Measure" ValidateRequiredField="True">
                            </ui:UIFieldDropDownList>
                            
                            <ui:UIFieldTextBox runat="server" ID="txtBMSCode" Caption="BMS Code" 
                            PropertyName="BMSCode" InternalControlWidth="95%">
                            </ui:UIFieldTextBox>
                            
                            
                            <ui:UIFieldDropDownList runat="server" ID="TypeOfMeterID" PropertyName="TypeOfMeterID" Caption="Type of Meter" ValidateRequiredField="True" >
                            </ui:UIFieldDropDownList>
                            
                            <ui:UIFieldRadioList runat="server" ID="radioIsIncreasingMeter" Caption="Type" PropertyName="IsIncreasingMeter" ValidateRequiredField="True" OnSelectedIndexChanged="radioIsIncreasingMeter_SelectedIndexChanged" meta:resourcekey="radioIsIncreasingMeterResource1" TextAlign="Right">
                                <Items>
                                    <asp:ListItem Value="0" Text="Absolute Reading (for readings from temperature, vibration sensors, etc that do not increase over time)"></asp:ListItem>
                                    <asp:ListItem Value="1" Text="Increasing Reading (for readings from electrical meters, water meters, etc that always increase over time)"></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                            
                            <ui:UIFieldTextBox runat="server" ID="textMaximumReading" 
                                    Caption="Maximum Reading" PropertyName="MaximumReading" 
                                    ValidateRangeField="True" 
                                    ValidateDataTypeCheck="True" ValidationDataType="Currency" 
                                    ValidationRangeMin="0" ValidationRangeMinInclusive="False" 
                                    ValidationRangeType='Currency' Span="Half" InternalControlWidth="95%">
                                </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox runat="server" ID="textFactor" Caption="Factor" 
                                    PropertyName="Factor" ValidateRequiredField='True' ValidateRangeField="True" 
                                    ValidationRangeType='Currency' ValidateDataTypeCheck="True" 
                                    ValidationRangeMin="0" ValidationRangeMinInclusive="False" Span="Half" 
                                    InternalControlWidth="95%">
                                </ui:UIFieldTextBox>

                    </ui:uipanel>            
                </ui:UITabView>
                
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" BorderStyle="NotSet" meta:resourcekey="tabMemoResource1">
                    <web:memo runat="server" ID="memo1"></web:memo>
                </ui:UITabView>
                <ui:UITabView ID="tabAttachments" runat="server" Caption="Attachments" BorderStyle="NotSet" meta:resourcekey="tabAttachmentsResource1">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
