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
        ONotificationMilestones obj = (ONotificationMilestones)panel.SessionObject;
        dropObjectTypeName.Bind(
            OFunction.GetObjectTypeNamesByImplementation(obj.ObjectTypeName, typeof(INotificationEnabled)), "ObjectTypeName", "ObjectTypeName");
        
        foreach (ListItem item in dropObjectTypeName.Items)
        {
            string translatedText = Resources.Objects.ResourceManager.GetString(item.Text);
            if (translatedText != null && translatedText != "")
                item.Text = translatedText;
        }

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
            ONotificationMilestones obj = (ONotificationMilestones)panel.SessionObject;
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
        <web:object runat="server" ID="panel" Caption="Notification Milestones" BaseTable="tNotificationMilestones"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" 
                meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="tabDetails" runat="server" Caption="Details" 
                    BorderStyle="NotSet" meta:resourcekey="tabDetailsResource1">
                    <web:base ID="objectBase" runat="server" ObjectNameCaption="Milestones Name" ObjectNumberVisible="false"
                    meta:resourcekey="objectBaseResource1"></web:base>
                    <ui:UIFieldDropDownList runat="server" ID="dropObjectTypeName" PropertyName="ObjectTypeName"
                        Caption="Object Type Name" ValidateRequiredField="True" 
                        meta:resourcekey="dropObjectTypeNameResource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldTextBox runat="server" ID="textStates" Caption="States" 
                        PropertyName="States" MaxLength="255"
                        ValidateRequiredField="True" InternalControlWidth="95%" 
                        meta:resourcekey="textStatesResource1">
                    </ui:UIFieldTextBox>
                    <ui:UISeparator runat="server" ID="sep1" Caption="Milestone 1" 
                        meta:resourcekey="sep1Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="textMilestoneName1" PropertyName="MilestoneName1"
                        Caption="Name" InternalControlWidth="95%" 
                        meta:resourcekey="textMilestoneName1Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="textExpectedField1" PropertyName="ExpectedField1"
                        Caption="Expected Field" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="textExpectedField1Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="textDateTimeLimitField1" PropertyName="DateTimeLimitField1"
                        Caption="Date/Time Limit Field" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="textDateTimeLimitField1Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="textReferenceField1" PropertyName="ReferenceField1"
                        Caption="Reference Field" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="textReferenceField1Resource1" />
                    <ui:UISeparator runat="server" ID="UISeparator1" Caption="Milestone 2" 
                        meta:resourcekey="UISeparator1Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="textMilestoneName2" PropertyName="MilestoneName2"
                        Caption="Name" InternalControlWidth="95%" 
                        meta:resourcekey="textMilestoneName2Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="textExpectedField2" PropertyName="ExpectedField2"
                        Caption="Expected Field" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="textExpectedField2Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="textDateTimeLimitField2" PropertyName="DateTimeLimitField2"
                        Caption="Date/Time Limit Field" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="textDateTimeLimitField2Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="textReferenceField2" PropertyName="ReferenceField2"
                        Caption="Reference Field" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="textReferenceField2Resource1" />
                    <ui:UISeparator runat="server" ID="UISeparator2" Caption="Milestone 3" 
                        meta:resourcekey="UISeparator2Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="textMilestoneName3" PropertyName="MilestoneName3"
                        Caption="Name" InternalControlWidth="95%" 
                        meta:resourcekey="textMilestoneName3Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="textExpectedField3" PropertyName="ExpectedField3"
                        Caption="Expected Field" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="textExpectedField3Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="textDateTimeLimitField3" PropertyName="DateTimeLimitField3"
                        Caption="Date/Time Limit Field" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="textDateTimeLimitField3Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="textReferenceField3" PropertyName="ReferenceField3"
                        Caption="Reference Field" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="textReferenceField3Resource1" />
                        
                    <ui:UISeparator runat="server" ID="UISeparator3" Caption="Milestone 4" 
                        meta:resourcekey="UISeparator3Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="textMilestoneName4" PropertyName="MilestoneName4"
                        Caption="Name" InternalControlWidth="95%" 
                        meta:resourcekey="textMilestoneName4Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="textExpectedField4" PropertyName="ExpectedField4"
                        Caption="Notify If" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="textExpectedField4Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="textDateTimeLimitField4" PropertyName="DateTimeLimitField4"
                        Caption="Date/Time Limit Field" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="textDateTimeLimitField4Resource1" />
                    <ui:UIFieldTextBox runat="server" ID="textReferenceField4" PropertyName="ReferenceField4"
                        Caption="Reference Field" Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="textReferenceField4Resource1" />
                    </ui:UIFieldTextBox>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" BorderStyle="NotSet" 
                    meta:resourcekey="tabMemoResource1">
                    <web:memo runat="server" ID="memo1"></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabAttachments" Caption="Attachments" 
                    BorderStyle="NotSet" meta:resourcekey="tabAttachmentsResource1">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
