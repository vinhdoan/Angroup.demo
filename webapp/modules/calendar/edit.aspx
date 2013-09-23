<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase"
    Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">
    
    /// <summary>
    /// Saves the calendar to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        OCalendar calendar = panel.SessionObject as OCalendar;

        // Validate
        //
        if (calendar.IsDuplicateName())
            objectBase.ObjectName.ErrorMessage = Resources.Errors.General_NameDuplicate;

        if (calendar.IsWorkDay0 == 0 && calendar.IsWorkDay1 == 0 &&
            calendar.IsWorkDay2 == 0 && calendar.IsWorkDay3 == 0 &&
            calendar.IsWorkDay4 == 0 && calendar.IsWorkDay5 == 0 &&
            calendar.IsWorkDay6 == 0)
            IsWorkDay0.ErrorMessage = Resources.Errors.Calendar_NoWorkDays;

        if (!panel.ObjectPanel.IsValid)
            return;

    }


    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CalendarHoliday_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OCalendarHoliday calendarHoliday =
            CalendarHoliday_SubPanel.SessionObject as OCalendarHoliday;

        // Binds the calendar holiday object to the UIObjectPanel
        // that contains the CalendarHoliday_SubPanel.
        //
        CalendarHoliday_SubPanel.ObjectPanel.BindObjectToControls(calendarHoliday);
    }


    /// <summary>
    /// Updates the object by inserting it into the main object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CalendarHoliday_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        // Gets the main object from the main panel's SessionObject.
        //
        OCalendar calendar = panel.SessionObject as OCalendar;

        // Gets the sub object.
        //
        OCalendarHoliday calendarHoliday =
            CalendarHoliday_SubPanel.SessionObject as OCalendarHoliday;

        // Binds the data from the controls to the sub-object.
        CalendarHoliday_SubPanel.ObjectPanel.BindControlsToObject(
            calendarHoliday);

        // Adds the sub-object into the main object.
        //
        calendar.HolidayDates.Add(calendarHoliday);

        // Binds the main object to the panel containing
        // the gridview, so as to update the gridview.
        //
        panelHolidayDates.BindObjectToControls(calendar);
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet"
        type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain">
        <web:object runat="server" ID="panel" Caption="Calendar" BaseTable="tCalendar"
            meta:resourcekey="panelResource1" OnValidateAndSave="panel_ValidateAndSave"
            AutomaticBindingAndSaving="true"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="uitabview1" runat="server" Caption="Details"
                    meta:resourcekey="uitabview1Resource1">
                    <web:base ID="objectBase" runat="server" ObjectNumberVisible="false"
                        ObjectNameCaption="Calendar Name" ObjectNumberValidateRequiredField="true"
                        meta:resourcekey="objectBaseResource1"></web:base>
                    <ui:UIFieldCheckBox ID="IsWorkDay0" runat="server" Caption="Work Day"
                        Text="Sunday" PropertyName="IsWorkDay0" meta:resourcekey="IsWorkDay0Resource1"
                        ToolTip="The days of the week that are working days.">
                    </ui:UIFieldCheckBox>
                    <ui:UIFieldCheckBox ID="IsWorkDay1" runat="server" Text="Monday"
                        PropertyName="IsWorkDay1" meta:resourcekey="IsWorkDay1Resource1">
                    </ui:UIFieldCheckBox>
                    <ui:UIFieldCheckBox ID="IsWorkDay2" runat="server" Text="Tuesday"
                        PropertyName="IsWorkDay2" meta:resourcekey="IsWorkDay2Resource1">
                    </ui:UIFieldCheckBox>
                    <ui:UIFieldCheckBox ID="IsWorkDay3" runat="server" Text="Wednesday"
                        PropertyName="IsWorkDay3" meta:resourcekey="IsWorkDay3Resource1">
                    </ui:UIFieldCheckBox>
                    <ui:UIFieldCheckBox ID="IsWorkDay4" runat="server" Text="Thursday"
                        PropertyName="IsWorkDay4" meta:resourcekey="IsWorkDay4Resource1">
                    </ui:UIFieldCheckBox>
                    <ui:UIFieldCheckBox ID="IsWorkDay5" runat="server" Text="Friday"
                        PropertyName="IsWorkDay5" meta:resourcekey="IsWorkDay5Resource1">
                    </ui:UIFieldCheckBox>
                    <ui:UIFieldCheckBox ID="IsWorkDay6" runat="server" Text="Saturday"
                        PropertyName="IsWorkDay6" meta:resourcekey="IsWorkDay6Resource1">
                    </ui:UIFieldCheckBox>
                    <br />
                    <br />
                    <br />
                    <ui:UIPanel runat='server' ID="panelHolidayDates">
                        <ui:UIGridView ID="HolidayDates" runat="server" Caption="Holiday Dates"
                            PropertyName="HolidayDates" SortExpression="HolidayDate"
                            KeyName="ObjectID" meta:resourcekey="HolidayDatesResource1"
                            Width="100%">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject"
                                    HeaderText="" meta:resourcekey="UIGridViewColumnResource1">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" ConfirmText="Are you sure you wish to delete this item?"
                                    CommandName="DeleteObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource2">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="Description"
                                    meta:resourcekey="UIGridViewColumnResource3">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn DataFormatString="{0:dd-MMM-yyyy}"
                                    PropertyName="HolidayDate" HeaderText="Date" meta:resourcekey="UIGridViewColumnResource4">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject"
                                    meta:resourcekey="UIGridViewCommandResource1"></ui:UIGridViewCommand>
                                <ui:UIGridViewCommand CommandText="Add" ImageUrl="~/images/add.gif"
                                    CommandName="AddObject" meta:resourcekey="UIGridViewCommandResource2">
                                </ui:UIGridViewCommand>
                            </Commands>
                        </ui:UIGridView>
                        <ui:UIObjectPanel ID="CalendarHoliday_Panel" runat="server" Width="100%"
                            meta:resourcekey="CalendarHoliday_PanelResource1">
                            <web:subpanel runat="server" ID="CalendarHoliday_SubPanel" GridViewID="HolidayDates"
                                OnPopulateForm="CalendarHoliday_SubPanel_PopulateForm" OnValidateAndUpdate="CalendarHoliday_SubPanel_ValidateAndUpdate">
                            </web:subpanel>
                            &nbsp;
                            <ui:UIFieldTextBox ID="CalendarHoliday_Name" runat="server" Caption="Name"
                                PropertyName="ObjectName" ValidateRequiredField="True" meta:resourcekey="CalendarHoliday_NameResource1"
                                ToolTip="The name of the holiday, for example, Christmas, New Year, etc."
                                MaxLength="255" />
                            <ui:UIFieldDateTime ID="CalendarHoliday_HolidayDate" runat="server"
                                Caption="Date" PropertyName="HolidayDate" Span="Half" ValidateRequiredField="True"
                                ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                                meta:resourcekey="CalendarHoliday_HolidayDateResource1" ShowTimeControls="False"
                                ToolTip="The date on which the holiday falls." />
                        </ui:UIObjectPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview3" Caption="Memo" meta:resourcekey="uitabview3Resource1">
                    <web:memo runat="server" ID="memo1"></web:memo>
                </ui:UITabView>
                <ui:UITabView ID="uitabview2" runat="server" Caption="Attachments"
                    meta:resourcekey="uitabview2Resource1">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
