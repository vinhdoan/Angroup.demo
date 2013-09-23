<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" 
    UICulture="auto" meta:resourcekey="PageResource1" %>

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
        ORunningNumberGenerator rng = (ORunningNumberGenerator)panel.SessionObject;

        dropObjectTypeName.Bind(OFunction.GetObjectTypeNamesByImplementation("", typeof(IAutoGenerateRunningNumber)), "ObjectTypeName", "ObjectTypeName");
        foreach (ListItem item in dropObjectTypeName.Items)
        {
            string translatedText = Resources.Objects.ResourceManager.GetString(item.Text);
            if (translatedText != null && translatedText != "")
                item.Text = translatedText;
        }
        
        panel.ObjectPanel.BindObjectToControls(rng);
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
            ORunningNumberGenerator rng = (ORunningNumberGenerator)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(rng);

            // Validate
            
            if (!rng.checkFormat(rng))
            {
                textFormatString.ErrorMessage = Resources.Errors.RunningNumberGenerator_FormatStringInvalid;
            }

            if (!rng.ValidateNoDuplicateObjectTypeName())
            {
                dropObjectTypeName.ErrorMessage = Resources.Errors.RunningNumberGenerator_DuplicateObjectTypeName;
                
                // 2010.04.27
                // Check for duplicate FLEE condition.
                //
                textFleeCondition.ErrorMessage = Resources.Errors.RunningNumberGenerator_DuplicateObjectTypeName;
            }
            
            if (!panel.ObjectPanel.IsValid)
               return;

            // Save
            //
            rng.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// Populates the format string text box.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioFormatString_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (radioFormatString.SelectedValue != "")
        {
            textFormatString.Text = radioFormatString.SelectedValue;
            textFormatString_TextChanged(sender, e);
        }
    }


    /// <summary>
    /// Hide/shows controls.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        ORunningNumberGenerator rng = panel.SessionObject as ORunningNumberGenerator;
        dropObjectTypeName.Enabled = rng.IsNew;

        textFLEEAdditionalCodeExpression.Visible = checkUsesAdditionalCode.Checked;
    }

    
    /// <summary>
    /// Occurs when the user changes the text in the Format 
    /// String textbox.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void textFormatString_TextChanged(object sender, EventArgs e)
    {
        ORunningNumberGenerator rng = panel.SessionObject as ORunningNumberGenerator;
        panel.ObjectPanel.BindControlsToObject(rng);
        int p0 = 1234;
        DateTime p1 = DateTime.Now;
        string p2 = rng.ObjectTypeCode;
        string p3 = "";
        string p4 = "";
        
        if (rng.IsLocationOrEquipmentCodeAdded == 1 ||
            rng.IsLocationOrEquipmentCodeAdded == 2)
            p3 = "LOC";

        if (rng.UsesAdditionalCode == 1)
            p4 = "P4";

        try
        {
            labelExampleOutput.Text = String.Format(rng.FormatString, p0, p1, p2, p3, p4);
        }
        catch
        {
            labelExampleOutput.Text = "";
            textFormatString.ErrorMessage = Resources.Errors.RunningNumberGenerator_FormatStringInvalid;
            
        }
    }

    protected void checkUsesAdditionalCode_CheckedChanged(object sender, EventArgs e)
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
        <ui:UIObjectPanel runat="server" ID="panelMain" 
            BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Running Number Generator" BaseTable="tRunningNumberGenerator" 
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" 
                    BorderStyle="NotSet" meta:resourcekey="tabObjectResource1" >
                    <ui:UITabView ID="tabDetails" runat="server"  Caption="Details" BorderStyle="NotSet" 
                        meta:resourcekey="tabDetailsResource1">
                        <web:base ID="objectBase" runat="server" ObjectNameVisible="false" ObjectNumberVisible="false">
                        </web:base>
                        <ui:UIFieldDropDownList runat="server" ID="dropObjectTypeName" 
                            Caption="Object Type Name" PropertyName="ObjectTypeName" 
                            ValidateRequiredField="True" meta:resourcekey="dropObjectTypeNameResource1"></ui:UIFieldDropDownList>
                        <ui:uifieldtextbox runat='server' id="textFleeCondition" PropertyName="FLEECondition" CAption="Applicable Condition" 
                            MaxLength="500" InternalControlWidth="95%" meta:resourcekey="textFleeConditionResource1">
                        </ui:uifieldtextbox>
                        <ui:UIFieldTextBox runat="server" id="textObjectTypePrefix" 
                            Caption="Object Type Code" PropertyName="ObjectTypeCode" 
                            ValidateRequiredField="True" InternalControlWidth="95%" 
                            meta:resourcekey="textObjectTypePrefixResource1"></ui:UIFieldTextBox>
                        <ui:UIFieldRadioList runat="server" ID="radioRunningNumberBehavior" 
                            Caption="Running Number Behavior" PropertyName="RunningNumberBehavior" 
                            ValidateRequiredField="True" 
                            meta:resourcekey="radioRunningNumberBehaviorResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource1" 
                                    Text="The running number increments forever."></asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource2" 
                                    Text="The running number increments, but resets to zero every month."></asp:ListItem>
                                <asp:ListItem Value="2" meta:resourcekey="ListItemResource3" 
                                    Text="The running number increments, but resets to zero every year."></asp:ListItem>
                                <asp:ListItem Value="3" 
                                    Text="The running number increments and resets to zero every year, but include the current year/month in the running number."></asp:ListItem>    
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:uifieldradiolist runat="server" id="radioIsLocationOrEquipmentCodeAdded" 
                            Caption="Location/Equipment Code" PropertyName="IsLocationOrEquipmentCodeAdded" 
                            ValidateRequiredField="True" 
                            meta:resourcekey="radioIsLocationOrEquipmentCodeAddedResource1" 
                            TextAlign="Right">
                            <Items>
                                <asp:ListItem text="No Location or Equipment code is added to the running number" 
                                    Value="0" meta:resourcekey="ListItemResource4"></asp:ListItem>
                                <asp:ListItem text="Only the Location code is added to the running number" 
                                    Value="2" meta:resourcekey="ListItemResource5"></asp:ListItem>
                                <asp:ListItem text="The Location code or Equipment code (if the Equipment is selected in the Object) is added to the running number" 
                                    Value="1" meta:resourcekey="ListItemResource6"></asp:ListItem>
                            </Items>
                        </ui:uifieldradiolist>
                        <div style='clear:both'></div>
                        <br />
                        <ui:UIFieldCheckBox runat="server" ID="checkUsesAdditionalCode" 
                            PropertyName="UsesAdditionalCode" Caption="Use Additional Code" 
                            Text="Yes, include an additional code to the running number" 
                            OnCheckedChanged="checkUsesAdditionalCode_CheckedChanged" 
                            meta:resourcekey="checkUsesAdditionalCodeResource1" TextAlign="Right"></ui:UIFieldCheckBox>
                        <ui:UIFieldTextBox runat="server" ID="textFLEEAdditionalCodeExpression" 
                            PropertyName="FLEEAdditionalCodeExpression" ValidateRequiredField="True" 
                            MaxLength="500" Caption="FLEE Expression" InternalControlWidth="95%" 
                            meta:resourcekey="textFLEEAdditionalCodeExpressionResource1"></ui:UIFieldTextBox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabFormatting" Caption="Formatting" BorderStyle="NotSet" 
                        meta:resourcekey="tabFormattingResource1"  >
                        <ui:UIFieldDropDownList runat="server" ID="radioFormatString" 
                            Caption="Sample Formats" 
                            OnSelectedIndexChanged="radioFormatString_SelectedIndexChanged" 
                            meta:resourcekey="radioFormatStringResource1">
                            <Items>
                                <asp:ListItem meta:resourcekey="ListItemResource7"></asp:ListItem>
                                <asp:ListItem Value="{2}/{1:yyyy}/{0:000000}" 
                                    meta:resourcekey="ListItemResource8" 
                                    Text="PO/2009/000001 (object code, 4-digit year, and a 6-digit running number)"></asp:ListItem>
                                <asp:ListItem Value="{2}/{1:yy}/{0:000000}" 
                                    meta:resourcekey="ListItemResource9" 
                                    Text="PO/09/000001 (object code, 2-digit year, and a 6-digit running number)"></asp:ListItem>
                                <asp:ListItem Value="{2}/{1:yyyy}/{0:000000}" 
                                    meta:resourcekey="ListItemResource10" 
                                    Text="PO/2009/000001 (object code, 4-digit year, and 4-digit running number)"></asp:ListItem>
                                <asp:ListItem Value="{3}/{2}/{1:yyyy}/{0:000000}" 
                                    meta:resourcekey="ListItemResource11" 
                                    Text="LOC/PO/2009/000001 (location code, object code, 4-digit year, and 4-digit running number)"></asp:ListItem>
                                <asp:ListItem Value="{3}/{2}/{1:yyyy}/{0:000000}" 
                                    meta:resourcekey="ListItemResource12" 
                                    Text="PO/LOC/09/000001 (object code, location code, 4-digit year, and 4-digit running number)"></asp:ListItem>
                                <asp:ListItem Value="{2}/{1:yyyyMM}/{0:0000}" 
                                    meta:resourcekey="ListItemResource13" 
                                    Text="PO/200907/0001 (object code, 4-digit year, 2-digit month, and 4-digit running number)"></asp:ListItem>
                                <asp:ListItem Value="{3}/{2}/{1:yyyyMM}/{0:0000}" 
                                    meta:resourcekey="ListItemResource14" 
                                    Text="LOC/PO/200907/0001 (location code, object code, 4-digit year, 2-digit month, and 4-digit running number)"></asp:ListItem>
                                <asp:ListItem Value="{2}/{3}/{1:yyyyMM}/{0:0000}" 
                                    meta:resourcekey="ListItemResource15" 
                                    Text="PO/LOC/200907/0001 (object code, location code, 4-digit year, 2-digit month, and 4-digit running number)"></asp:ListItem>
                                <asp:ListItem Value="{2}/{1:yyMM}/{0:0000}" 
                                    meta:resourcekey="ListItemResource16" 
                                    Text="PO/0907/0001 (object code, 2-digit year and month, and 4-digit running number)"></asp:ListItem>
                                <asp:ListItem Value="{3}/{2}/{1:yyMM}/{0:0000}" 
                                    meta:resourcekey="ListItemResource17" 
                                    Text="LOC/PO/0907/0001 (location code, object code, 2-digit year and month, and 4-digit running number)"></asp:ListItem>
                                <asp:ListItem Value="{2}/{3}/{1:yyMM}/{0:0000}" 
                                    meta:resourcekey="ListItemResource18" 
                                    Text="PO/LOC/0907/0001 (object code, location code, 2-digit year and month, and 4-digit running number)"></asp:ListItem>
                            </Items>
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox runat="server" ID="textFormatString" 
                            Caption="Formatting String" PropertyName="FormatString" 
                            ValidateRequiredField="True" OnTextChanged="textFormatString_TextChanged" 
                            InternalControlWidth="95%" meta:resourcekey="textFormatStringResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldLabel runat="server" ID="labelExampleOutput" 
                            Caption="Example Output" DataFormatString="" 
                            meta:resourcekey="labelExampleOutputResource1">
                        </ui:UIFieldLabel>
                        <ui:UIHint runat="server" ID="hintFormatString" 
                            meta:resourcekey="hintFormatStringResource1" Text="Use the following placeholders to tell the system how to construct the running number.
                            <br/><br/><b>{0}</b><br/>
                            The actual running number. To pad the running number with zeroes so 
                            that the running number fills up 6 digits, you can write {0:000000}. 
                            The number of zeroes after the colon ':' indicates the length to pad the
                            running number so it always occupies the number of digits.
                            <hr style='height: 1px' />
                            <b>{1}</b>
                            <br/>
                            The date the running number is generated for. To generate a 4-digit 
                            year for a running number that resets yearly, use {1:yyyy}. You can also 
                            generate a 2-digit year by writing {1:yy}. To generate a 4-digit year and
                            a 2-digit month, use {1:yyyyMM}. If the running number increments forever,
                            and you do not need the date to be included as part of the running number,
                            then exclude the {1} placeholder from the format string totally.<br />
                            <br/>
                            Note: 'yyyy' must be in lowercase and 'MM' must be in uppercase.
                            <hr style='height: 1px'/>
                            <b>{2}</b>
                            <br/>
                            The object type code. This is usually an abbreviation for the type
                            of object that has been created. For example, the object type code for 
                            a Purchase Order is usually PO, and the object type code for a Store Adjustment
                            is usually SA.
                            <br/>
                            <br/>
                            This is the same code that you specify in the
                            'Object Type Code' text box in the previous tab.
                            <hr style='height: 1px'/>
                            <b>{3}</b>
                            <br/>
                            The location/equipment code. This code, obtained from the task's
                            locations/equipments will only be used if the 'Location/Equipment Code' 
                            is checked. 
                            <br/>
                            <br/>
                            <br/>"></ui:UIHint>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" 
                        BorderStyle="NotSet" meta:resourcekey="tabMemoResource1"  >
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabAttachments"  Caption="Attachments" BorderStyle="NotSet" 
                        meta:resourcekey="tabAttachmentsResource1">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
