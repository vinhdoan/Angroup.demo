<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System.Data.OleDb" %>
<%@ Import Namespace="System.IO" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OTechnicianRoster techRoster = panel.SessionObject as OTechnicianRoster;
        treeLocation.PopulateTree();
        ddlYear.Bind(OTechnicianRoster.BindYear(), "Year", "Year");
        ddlMonth.Bind(OTechnicianRoster.BindMonth(), "MonthName", "Month");
        panel.ObjectPanel.BindObjectToControls(techRoster);
        if (techRoster.IsNew)
        {
            ddlYear.SelectedValue = Convert.ToString(DateTime.Today.Year);
            ddlMonth.SelectedValue = Convert.ToString(DateTime.Today.Month);
        }

    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        treeLocation.Enabled = ddlYear.Enabled = ddlMonth.Enabled = TechnicianRosterItems.Rows.Count <= 0 && TechnicianRosterItem_SubPanel.Visible == false;
    }
    /// <summary>
    /// Validates and saves the technician roster object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OTechnicianRoster techRoster = panel.SessionObject as OTechnicianRoster;
            panel.ObjectPanel.BindControlsToObject(techRoster);
            if (techRoster.IsDuplicateTechnicianRoster())
                treeLocation.ErrorMessage = Resources.Errors.TechnicianRoster_DuplicateTechnicianRoster;
            if (!panel.ObjectPanel.IsValid)
                return;
            // Save
            //
            techRoster.Save();
            c.Commit();
        }
    }
   
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        OTechnicianRoster techRoster = panel.SessionObject as OTechnicianRoster;
        return new LocationTreePopulaterForCapitaland(techRoster.LocationID,false, true,Security.Decrypt(Request["TYPE"]),false,false);
    }

    protected void TechnicianRosterItem_SubPanel_PopulateForm(object sender, EventArgs e)
    {
        OTechnicianRosterItem techItem = TechnicianRosterItem_SubPanel.SessionObject as OTechnicianRosterItem;
        ddlDay.Bind(BindDay(), "day", "day");
        List<OShift> shifts = TablesLogic.tShift.LoadList(TablesLogic.tShift.IsNonWorkingShift == null | TablesLogic.tShift.IsNonWorkingShift == 0, TablesLogic.tShift.StartTime.Asc);
        ddlShift.Bind(shifts);
        OTechnicianRoster techRoster = panel.SessionObject as OTechnicianRoster;
        panel.ObjectPanel.BindControlsToObject(techRoster);
        List<OUser> users = OUser.GetUsersByRoleAndAboveLocation(techRoster.Location, "WORKTECHNICIAN,WORKSUPERVISOR");
        //tech1.Bind(users);
        //tech2.Bind(users);
        //tech3.Bind(users);
        //tech4.Bind(users);
        ddlTechnician.Bind(users);
        TechnicianRosterItem_SubPanel.ObjectPanel.BindObjectToControls(techItem);
    }

    protected void TechnicianRosterItem_SubPanel_ValidateAndUpdate(object sender, EventArgs e)
    {
        //if(ValidateAssignedTech())
        //{
            OTechnicianRosterItem techItem = TechnicianRosterItem_SubPanel.SessionObject as OTechnicianRosterItem;
            TechnicianRosterItem_SubPanel.ObjectPanel.BindControlsToObject(techItem);
            OTechnicianRoster techRoster = panel.SessionObject as OTechnicianRoster;
            panel.ObjectPanel.BindControlsToObject(techRoster);
            foreach (OTechnicianRosterItem item in techRoster.TechnicianRosterItems)
            {
                if (item.Day == techItem.Day && item.ShiftID == techItem.ShiftID  && item.ObjectID != techItem.ObjectID)
                {
                    ddlDay.ErrorMessage = Resources.Errors.TechnicianRoster_DuplicateTechnicianRosterITem;
                    ddlShift.ErrorMessage = Resources.Errors.TechnicianRoster_DuplicateTechnicianRosterITem;
                    return;
                }
            }
            techItem.ShiftStartDateTime = new DateTime(techRoster.Year.Value, techRoster.Month.Value, techItem.Day.Value, techItem.Shift.StartTime.Value.Hour, techItem.Shift.StartTime.Value.Minute, techItem.Shift.StartTime.Value.Second);
            DateTime end = new DateTime(techRoster.Year.Value, techRoster.Month.Value,techItem.Day.Value, techItem.Shift.EndTime.Value.Hour, techItem.Shift.EndTime.Value.Minute, techItem.Shift.EndTime.Value.Second);
            if (techItem.Shift.StartTime > techItem.Shift.EndTime)
                techItem.ShiftEndDateTime = end.AddDays(1);
            else
                techItem.ShiftEndDateTime = end;
            techRoster.TechnicianRosterItems.Add(techItem);
            panel.ObjectPanel.BindObjectToControls(techRoster);
        //}
    }
    //protected bool ValidateAssignedTech()
    //{
    //    Hashtable tbl = new Hashtable();
    //    tbl.Add(tech1.SelectedValue, "1");

    //    if (tech2.SelectedValue != "")
    //    {
    //        if(tbl.ContainsKey((object)tech2.SelectedValue))
    //        {
    //        string techkey = Convert.ToString(tbl[(object)tech2.SelectedValue]);
    //        tech2.ErrorMessage = String.Format(Resources.Errors.TechnicianRoster_DuplicatedAssignedTechnicians,2,techkey);
    //        return false;
    //        }
    //        else
    //            tbl.Add((object)tech2.SelectedValue, "2");
    //    }

    //    if (tech3.SelectedValue != "")
    //    {
    //        if (tech2.SelectedValue == "")
    //        {
    //            tech2.ErrorMessage = String.Format(Resources.Errors.TechnicianRoster_AssignedTechnicians,2,3);
    //            return false;
    //        }
    //        if (tbl.ContainsKey((object)tech3.SelectedValue))
    //        {
    //            string techkey = Convert.ToString(tbl[(object)tech3.SelectedValue]);
    //            tech3.ErrorMessage = String.Format(Resources.Errors.TechnicianRoster_DuplicatedAssignedTechnicians, 3, techkey);
    //            return false;
    //        }
    //        else
    //            tbl.Add((object)tech3.SelectedValue, "3");
    //    }
            
    //    if (tech4.SelectedValue != "")
    //    {
    //        if (tech3.SelectedValue == "")
    //        {
    //            tech3.ErrorMessage = String.Format(Resources.Errors.TechnicianRoster_AssignedTechnicians, 3, 4);
    //            return false;
    //        }
    //        if (tbl.ContainsKey((object)tech4.SelectedValue))
    //        {
    //            string techkey = Convert.ToString(tbl[(object)tech4.SelectedValue]);
    //            tech4.ErrorMessage = String.Format(Resources.Errors.TechnicianRoster_DuplicatedAssignedTechnicians, 4, techkey);
    //            return false;
    //        }
    //        else
    //            tbl.Add((object)tech3.SelectedValue, "4");
    //    }
    //    return true;
    //}
    protected void tech1_SelectedIndexChanged(object sender, EventArgs e)
    {
        
    }
    public List<OUser> GetUsersByRoleAndAboveLocation(List<object> UserIDs)
    {
        OTechnicianRoster techRoster = panel.SessionObject as OTechnicianRoster;
        panel.ObjectPanel.BindControlsToObject(techRoster);
        if (techRoster.Location != null)
        {
            return TablesLogic.tUser.LoadList(
                TablesLogic.tUser.Positions.Role.RoleCode == "WORKTECHNICIAN" &
                ((ExpressionDataString)techRoster.Location.HierarchyPath).Like(TablesLogic.tUser.Positions.LocationAccess.HierarchyPath + "%") &
                !TablesLogic.tUser.ObjectID.In(UserIDs));
        }
        return null;
    }


    protected void tech2_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    protected void tech3_SelectedIndexChanged(object sender, EventArgs e)
    {

    }
    protected DataTable BindDay()
    {
        DataTable days = new DataTable();
        days.Columns.Add("day");
        if (ddlYear.SelectedValue != "" && ddlMonth.SelectedValue != "")
        {
            int dayEnd = daysofmonth();
            for (int i = 1; i <= dayEnd; i++)
            {
               days.Rows.Add(new object[] {i });
            }
               
        }
        return days;
    }
    private int daysofmonth()
    {
        int dayEnd = 0;
        if (ddlYear.SelectedValue != "" && ddlMonth.SelectedValue != "")
        {
            dayEnd = DateTime.DaysInMonth(Convert.ToInt16(ddlYear.SelectedValue), Convert.ToInt16(ddlMonth.SelectedValue));
        }
        return dayEnd;
    }
       
    
    protected void btnUpdateItem_Click(object sender, EventArgs e)
    {
        panelUpload.Visible = true;
    }

    protected void btnUploadCancel_Click(object sender, EventArgs e)
    {
        panelUpload.Visible = false;
    }

    protected void btnUploadConfirm_Click(object sender, EventArgs e)
    {
        panel.Message = "";
        OTechnicianRoster techRoster = panel.SessionObject as OTechnicianRoster;
        panel.ObjectPanel.BindControlsToObject(techRoster);
        if (ValidateInputFile())
        {
            //read data from excel
            try
            {
                Guid id = Guid.NewGuid();
                string filePath = ConfigurationManager.AppSettings["ReportTempFolder"] + id.ToString().Replace("-", "") + ".xls";

                this.InputFile.Control.PostedFile.SaveAs(filePath);
                DataTable dtExceldata = new DataTable();

                string connString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties='Excel 8.0;HDR=Yes;IMEX=1;Notify=True'";

                OleDbCommand excelCommand = new OleDbCommand();
                OleDbDataAdapter excelDataAdapter = new OleDbDataAdapter();

                OleDbConnection excelConn = new OleDbConnection(connString);
                excelConn.Open();

                String sheetName = "";

                DataTable dtExcelSheets = new DataTable();
                dtExcelSheets = excelConn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
                if (dtExcelSheets.Rows.Count > 0)
                {
                    sheetName = dtExcelSheets.Rows[0]["TABLE_NAME"].ToString();
                }
                OleDbCommand OleCmdSelect = new OleDbCommand("SELECT * FROM [" + sheetName + "]", excelConn);
                OleDbDataAdapter OleAdapter = new OleDbDataAdapter(OleCmdSelect);

                OleAdapter.FillSchema(dtExceldata, System.Data.SchemaType.Source);
                OleAdapter.Fill(dtExceldata);
                excelConn.Close();

                if (dtExceldata.Rows.Count == 0)
                {
                    panel.Message = Resources.Errors.Reading_InvalidFile;
                    dtExceldata.Clear();
                    TechnicianRosterItems.DataBind();
                    return;
                }
                if (techRoster.Location == null)
                {
                    panel.Message = Resources.Errors.TechnicianRoster_EmptyLocation;
                    return;
                }
                techRoster.TechnicianRosterItems.Clear();
                List<OUser> users = OUser.GetUsersByRoleAndAboveLocation(techRoster.Location, "WORKTECHNICIAN,WORKSUPERVISOR");
                if (users == null)
                {
                    panel.Message = Resources.Errors.TechnicianRoster_NoTechnicianInLocation;
                    return; 
                }
                //validate header
                int enddate =  daysofmonth();
                if (!ValidateColumnExistInExcelFile(dtExceldata, enddate))
                {
                    panel.Message = Resources.Errors.Reading_InvalidFile;
                    return;
                }
                foreach (DataRow dr in dtExceldata.Rows)
                {
                   
                    //if (!dr.Table.Columns.Contains("Day") | !dr.Table.Columns.Contains("Shift") | !dr.Table.Columns.Contains("Technician 1"))
                    //{
                    //    panel.Message = Resources.Errors.Reading_InvalidFile;
                    //    return;
                    //}
                    if (dtExceldata.Rows.IndexOf(dr) == 0)
                        continue;
                    //if (dr["Day"].ToString() != "" && dr["Shift"].ToString() != "" && dr["Technician 1"].ToString() != "")
                    //{
                    //    ///validate shift
                    //    OShift shift = TablesLogic.tShift.Load(TablesLogic.tShift.ObjectName == dr["Shift"].ToString());
                    //    if (shift == null)
                    //    {
                    //        panel.Message = String.Format(Resources.Errors.General_ItemNotExist, dr["Shift"].ToString());
                    //        return; 
                    //    }
                    //    ///validate day of month
                    //    int Day = Convert.ToInt16(dr["Day"].ToString());
                    //    if (!ValidateDayOfMonth(Day))
                    //    {
                    //        panel.Message = "Invalid Day";
                    //        return; 
                    //    }

                    //    ///validate Assignment Type
                    //    //int intType =0;
                    //    //string strType = dr["Type"].ToString();
                    //    //if(strType == "All")
                    //    //    intType= 0 ;
                    //    //else if(strType =="Round-Robin")
                    //    //    intType= 1;
                    //    //else if(strType  == "Manual")
                    //    //    intType = 2;
                    //    //else
                    //    //{
                    //    //    panel.Message = "Invalid Assignment Type";
                    //    //    return;
                    //    //}
                    //    ///validate technician 1
                    //    OUser technician1 = getUserbyUserName(dr["Technician 1"].ToString());
                    //    if (technician1 == null)
                    //    {
                    //        panel.Message = String.Format(Resources.Errors.General_ItemNotExist, dr["Technician 1"].ToString());
                    //        return;
                    //    }
                    //    else if (users.Find((r) => r.ObjectID == technician1.ObjectID) == null)
                    //    {
                    //        panel.Message = "Technician " + technician1.ObjectName + " is not a technician of the Location";
                    //        return;
                    //    }
                    //    OTechnicianRosterItem item = techRoster.TechnicianRosterItems.Find((r) => r.ShiftID == shift.ObjectID &&
                    //                                                                              r.Day ==  Day);
                    //    if (item == null)
                    //        item = TablesLogic.tTechnicianRosterItem.Create();
                    //    item.ShiftID = shift.ObjectID;
                    //    item.Day = Day;
                    //    //item.AssignmentType = intType;
                    //    item.Technician1ID = technician1.ObjectID;
                    //    if (dr["Technician 2"].ToString() != "")
                    //    {
                    //        OUser technician2 = getUserbyUserName(dr["Technician 2"].ToString());
                    //        if (technician2 == null)
                    //        {
                    //            panel.Message = String.Format(Resources.Errors.General_ItemNotExist, dr["Technician 2"].ToString());
                    //            return;
                    //        }
                    //        else if (users.Find((r) => r.ObjectID == technician2.ObjectID) == null)
                    //        {
                    //            panel.Message = "Technician " + technician2.ObjectName + " is not a technician of the Location";
                    //            return;
                    //        }
                    //        else
                    //            item.Technician2ID = technician2.ObjectID;

                    //    }
                    //    if (dr["Technician 3"].ToString() != "")
                    //    {
                    //        OUser technician3 = getUserbyUserName(dr["Technician 3"].ToString());
                    //        if (technician3== null)
                    //        {
                    //            panel.Message = String.Format(Resources.Errors.General_ItemNotExist, dr["Technician 3"].ToString());
                    //            return;
                    //        }
                    //        else if(users.Find((r) => r.ObjectID == technician3.ObjectID)==null)
                    //        {
                    //            panel.Message = "Technician " + technician3.ObjectName + " is not a technician of the Location";
                    //            return;
                    //        }
                    //        else
                    //            item.Technician3ID = technician3.ObjectID;

                    //    }
                    //    if (dr["Technician 4"].ToString() != "")
                    //    {
                    //        OUser technician4 = getUserbyUserName(dr["Technician 4"].ToString());
                    //        if (technician4 == null)
                    //        {
                    //            panel.Message = String.Format(Resources.Errors.General_ItemNotExist, dr["Technician 4"].ToString());
                    //            return;
                    //        }
                    //        else if (users.Find((r) => r.ObjectID == technician4.ObjectID) == null)
                    //        {
                    //            panel.Message = "Technician " + technician4.ObjectName + " is not a technician of the Location";
                    //            return;
                    //        }
                    //        else
                    //            item.Technician4ID = technician4.ObjectID;

                    //    }
                    //    techRoster.TechnicianRosterItems.Add(item);
                    //}
                    if (dr["Day"].ToString() != "")
                    {
                        if (dr["Day"].ToString() != "User")
                        {
                            OUser tech = getUserbyUserName(dr["Day"].ToString());
                            if (tech == null)
                            {
                                panel.Message = String.Format(Resources.Errors.General_ItemNotExist, dr["Day"].ToString());
                                return;
                               
                            }
                            else if (users.Find((r) => r.ObjectID == tech.ObjectID) == null)
                            {
                                panel.Message = String.Format(Resources.Errors.TechnicianRoster_TechnicianNotExisting, tech.ObjectName);
                                return;
                            }
                            else
                            {
                                for (int i = 1; i <= enddate; i++)
                                {
                                    if (dr[i.ToString()].ToString() != "")
                                    {
                                        //check whether the shift exists.
                                        OShift shift = TablesLogic.tShift.Load(TablesLogic.tShift.ObjectName == dr[i.ToString()].ToString());
                                        if (shift == null)
                                        {
                                            panel.Message = String.Format(Resources.Errors.General_ItemNotExist, dr[i.ToString()].ToString());
                                            return;
                                        }
                                        if (shift.IsNonWorkingShift == 1)
                                            continue;
                                        
                                        OTechnicianRosterItem item = techRoster.TechnicianRosterItems.Find((r) => r.ShiftID == shift.ObjectID &&
                                                                                                  r.Day == i);
                                        if (item == null)
                                        {
                                            item = TablesLogic.tTechnicianRosterItem.Create();
                                            item.ShiftID = shift.ObjectID;
                                            item.Day = i;
                                        }
                                        //check duplicate techinician in same day and shift 
                                        if (item.Technicians.Count > 0)
                                        {
                                            OUser existingUser = item.Technicians.Find((r) => r.ObjectID == tech.ObjectID);
                                            if (existingUser != null)
                                            {
                                                panel.Message = String.Format(Resources.Errors.TechnicianRoster_DuplicatedAssignedTechnicians, tech.ObjectName);
                                                return;
                                            }
                                        }
                                        item.Technicians.Add(tech);

                                        item.ShiftStartDateTime = new DateTime(techRoster.Year.Value, techRoster.Month.Value, item.Day.Value, item.Shift.StartTime.Value.Hour, item.Shift.StartTime.Value.Minute, item.Shift.StartTime.Value.Second);
                                        DateTime end = new DateTime(techRoster.Year.Value, techRoster.Month.Value, item.Day.Value, item.Shift.EndTime.Value.Hour, item.Shift.EndTime.Value.Minute, item.Shift.EndTime.Value.Second);
                                        if (item.Shift.StartTime > item.Shift.EndTime)
                                            item.ShiftEndDateTime = end.AddDays(1);
                                        else
                                            item.ShiftEndDateTime = end;
                                        techRoster.TechnicianRosterItems.Add(item);
                                    }
                                }
                            }
                        }
                        else
                            continue;
                    }
                    
                    
                }
                panel.ObjectPanel.BindObjectToControls(techRoster);
                panelUpload.Visible = false;

            }
            catch (Exception ex) { panel.Message = ex.Message; }
        }
        
    }
    private bool ValidateColumnExistInExcelFile(DataTable dt,int day)
    {
        if (!dt.Columns.Contains("Day"))
            return false;
        for(int i=1;i <= day;i++)
        {
            if (!dt.Columns.Contains(i.ToString()))
                return false;
        }
        return true;
         
    }
    
    private OUser getUserbyUserName(string userName)
    {
        return TablesLogic.tUser.Load(TablesLogic.tUser.ObjectName == userName & (TablesLogic.tUser.isTenant == null | TablesLogic.tUser.isTenant == 0));
    }
    private bool ValidateDayOfMonth(int Day)
    {
        if(Day > DateTime.DaysInMonth(Convert.ToInt16(ddlYear.SelectedValue), Convert.ToInt16(ddlMonth.SelectedValue)))
            return false;
        return true;
    }
    private bool ValidateInputFile()
    {
        bool validate = true;
        if (this.InputFile.Control.PostedFile.FileName == "" || this.InputFile.Control.PostedFile == null
            || this.InputFile.Control.PostedFile.ContentLength == 0
            || !this.InputFile.Control.PostedFile.FileName.ToLower().EndsWith(".xls"))
        {
            validate = false;
            panel.Message = Resources.Errors.Reading_InvalidFile;
        }
        return validate;
    }
    /// <summary>
    /// Initializes the control.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        // Register the btnUploadConfirm button to force a full
        // postback whenever a file is uploaded.
        //
        if (Page is UIPageBase)
        {
            ((UIPageBase)Page).ScriptManager.RegisterPostBackControl(btnUploadConfirm);
        }
    }

    protected void btnDownload_Click(object sender, EventArgs e)
    {
        OTechnicianRoster techRoster = panel.SessionObject as OTechnicianRoster;
        panel.ObjectPanel.BindControlsToObject(techRoster);
        Guid id = Guid.NewGuid();
        string filePath = ConfigurationManager.AppSettings["ReportTempFolder"] + id.ToString().Replace("-", "") + ".xls";
        string worksheetname = "Shift";
        int compulsoryColumns = 0;
        DataTable dt = GenerateExcelData();

        OAttachment file = ExcelWriter.GenerateExcelFile(dt, filePath, worksheetname, compulsoryColumns);

        panel.FocusWindow = false;
        Window.Download(file.FileBytes, file.Filename, file.ContentType);
    }
    //protected DataTable GenerateExcelData()
    //{
    //    OTechnicianRoster techRoster = panel.SessionObject as OTechnicianRoster;
    //    DataTable dt = new DataTable();
    //    dt.Columns.Add("Day");
    //    dt.Columns.Add("Shift");
    //    dt.Columns.Add("Technician 1");
    //    dt.Columns.Add("Technician 2");
    //    dt.Columns.Add("Technician 3");
    //    dt.Columns.Add("Technician 4");

    //    foreach (OTechnicianRosterItem item in techRoster.TechnicianRosterItems)
    //    {
    //        dt.Rows.Add(new object[]{item.Day,item.Shift.ObjectName,
    //                                (item.Technician1!=null?item.Technician1.ObjectName:""),(item.Technician2!=null?item.Technician2.ObjectName:""),
    //                                (item.Technician3!=null?item.Technician3.ObjectName:""),(item.Technician4!=null?item.Technician4.ObjectName:"")}); 
    //    }
        


    //    DataView dv = dt.DefaultView;
    //    dv.Sort = "Day asc";
    //    return dv.ToTable();
    //}
    protected DataTable GenerateExcelData()
    {
        OTechnicianRoster techRoster = panel.SessionObject as OTechnicianRoster;
        panel.ObjectPanel.BindControlsToObject(techRoster);
        DataTable dt = new DataTable();
        dt.Columns.Add("Serial No");
        dt.Columns.Add("Day");
        for (int i =1; i <= 31; i++)
        {
            dt.Columns.Add(i.ToString());
        }
        DataRow row = dt.NewRow();
        row["Day"] = "User";
        dt.Rows.Add(row);
        //this list to save a temporary object which save all shifts of a technician in a month
        List<TemporaryTechnicianRosterItem> temp = new List<TemporaryTechnicianRosterItem>();
        foreach (OTechnicianRosterItem item in techRoster.TechnicianRosterItems)
        {
            foreach (OUser tech in item.Technicians)
            {
                TemporaryTechnicianRosterItem tempItem = null;
                    
                if (temp.Count > 0)
                {
                    List<TemporaryTechnicianRosterItem> t = temp.FindAll((r) => r.TechID == tech.ObjectID);
                    
                    if (t.Count <= 0)
                    {
                        tempItem = CreateTemporaryTechnicianRosterItem(tempItem, tech, item);
                        temp.Add(tempItem);

                    }
                    else
                    {
                        tempItem = OTechnicianRosterItem.validateSameTechnicianwithDifferentShift(t, item);
                        // if there is same technician in a day with different shift, create new temporary object
                        if (tempItem == null)
                        {
                            tempItem = CreateTemporaryTechnicianRosterItem(tempItem, tech, item);
                            temp.Add(tempItem);
                        }
                        else
                            assignShift(tempItem, item);
                    }

                }
                else
                {
                    tempItem = CreateTemporaryTechnicianRosterItem(tempItem, tech, item);
                    temp.Add(tempItem);
                }
            }
        }
        int no = 0;
        
       
        foreach (TemporaryTechnicianRosterItem item in temp)
        {
            DataRow r = dt.NewRow();
            no++;
            r["Serial No"] = no;
            r["Day"]= item.Name;
            r["1"] = item.Day1;
            r["2"] = item.Day2;
            r["3"] = item.Day3;
            r["4"] = item.Day4;
            r["5"] = item.Day5;
            r["6"] = item.Day6;
            r["7"] = item.Day7;
            r["8"] = item.Day8;
            r["9"] = item.Day9;
            r["10"] = item.Day10;
            r["11"] = item.Day11;
            r["12"] = item.Day12;
            r["13"] = item.Day13;
            r["14"] = item.Day14;
            r["15"] = item.Day15;
            r["16"] = item.Day16;
            r["17"] = item.Day17;
            r["18"] = item.Day18;
            r["19"] = item.Day19;
            r["20"] = item.Day20;
            r["21"] = item.Day21;
            r["22"] = item.Day22;
            r["23"] = item.Day23;
            r["24"] = item.Day24;
            r["25"] = item.Day25;
            r["26"] = item.Day26;
            r["27"] = item.Day27;
            r["28"] = item.Day28;
            r["29"] = item.Day29;
            r["30"] = item.Day30;
            r["31"] = item.Day31;
            dt.Rows.Add(r);
        }


        DataView dv = dt.DefaultView;
        dv.Sort = "Serial No asc";
        
        return dv.ToTable();
    }
    public TemporaryTechnicianRosterItem CreateTemporaryTechnicianRosterItem(TemporaryTechnicianRosterItem tempItem, OUser tech, OTechnicianRosterItem item)
    {
        tempItem = new TemporaryTechnicianRosterItem();
        tempItem.TechID = tech.ObjectID.Value;
        tempItem.Name = tech.ObjectName;
        assignShift(tempItem, item);
        return tempItem;
    }
    
    public void assignShift(TemporaryTechnicianRosterItem tempItem, OTechnicianRosterItem item)
    {
        switch (item.Day)
        {
            case 1:
                tempItem.Day1 = item.Shift.ObjectName;
                break;
            case 2:
                tempItem.Day2 = item.Shift.ObjectName;
                break;
            case 3:
                tempItem.Day3 = item.Shift.ObjectName;
                break;
            case 4:
                tempItem.Day4 = item.Shift.ObjectName;
                break;
            case 5:
                tempItem.Day5 = item.Shift.ObjectName;
                break;
            case 6:
                tempItem.Day6 = item.Shift.ObjectName;
                break;
            case 7:
                tempItem.Day7 = item.Shift.ObjectName;
                break;
            case 8:
                tempItem.Day8 = item.Shift.ObjectName;
                break;
            case 9:
                tempItem.Day9 = item.Shift.ObjectName;
                break;
            case 10:
                tempItem.Day10 = item.Shift.ObjectName;
                break;
            case 11:
                tempItem.Day11 = item.Shift.ObjectName;
                break;
            case 12:
                tempItem.Day12 = item.Shift.ObjectName;
                break;
            case 13:
                tempItem.Day13 = item.Shift.ObjectName;
                break;
            case 14:
                tempItem.Day14 = item.Shift.ObjectName;
                break;
            case 15:
                tempItem.Day15 = item.Shift.ObjectName;
                break;
            case 16:
                tempItem.Day16 = item.Shift.ObjectName;
                break;
            case 17:
                tempItem.Day17 = item.Shift.ObjectName;
                break;
            case 18:
                tempItem.Day18 = item.Shift.ObjectName;
                break;
            case 19:
                tempItem.Day19 = item.Shift.ObjectName;
                break;
            case 20:
                tempItem.Day20 = item.Shift.ObjectName;
                break;
            case 21:
                tempItem.Day21 = item.Shift.ObjectName;
                break;
            case 22:
                tempItem.Day22 = item.Shift.ObjectName;
                break;
            case 23:
                tempItem.Day23 = item.Shift.ObjectName;
                break;
            case 24:
                tempItem.Day24 = item.Shift.ObjectName;
                break;
            case 25:
                tempItem.Day25 = item.Shift.ObjectName;
                break;
            case 26:
                tempItem.Day26 = item.Shift.ObjectName;
                break;
            case 27:
                tempItem.Day27 = item.Shift.ObjectName;
                break;
            case 28:
                tempItem.Day28 = item.Shift.ObjectName;
                break;
            case 29:
                tempItem.Day29 = item.Shift.ObjectName;
                break;
            case 30:
                tempItem.Day30 = item.Shift.ObjectName;
                break;
            case 31:
                tempItem.Day31 = item.Shift.ObjectName;
                break;

        } 
    }
    protected void ddlTechnician_SelectedIndexChanged(object sender, EventArgs e)
    {
        OTechnicianRosterItem roster = TechnicianRosterItem_SubPanel.SessionObject as OTechnicianRosterItem;
        TechnicianRosterItem_SubPanel.ObjectPanel.BindControlsToObject(roster);
        ddlTechnician.ErrorMessage = "";
        panel.Message = "";
        if ( ddlTechnician.SelectedValue!="")
        {
            if (roster.Technicians.Count > 0)
            {
                OUser user = roster.Technicians.Find((r) => r.ObjectID == new Guid(ddlTechnician.SelectedValue));
                if (user == null)
                    roster.Technicians.AddGuid(new Guid(ddlTechnician.SelectedValue));
                else
                {
                    ddlTechnician.ErrorMessage = String.Format(Resources.Errors.TechnicianRoster_DuplicatedAssignedTechnicians, user.ObjectName);
                    panel.Message = String.Format(Resources.Errors.TechnicianRoster_DuplicatedAssignedTechnicians, user.ObjectName);
                }
            }
            else
            {
                roster.Technicians.AddGuid(new Guid(ddlTechnician.SelectedValue));
                
            }
        }
        
        Technicians_Panel.BindObjectToControls(roster);
    }

    protected void gridTechnicians_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "DeleteTechnician")
        {
            OTechnicianRosterItem item = TechnicianRosterItem_SubPanel.SessionObject as OTechnicianRosterItem;
            TechnicianRosterItem_SubPanel.ObjectPanel.BindControlsToObject(item);
            foreach (Guid id in objectIds)
                item.Technicians.RemoveGuid(id);
            TechnicianRosterItem_SubPanel.ObjectPanel.BindObjectToControls(item);
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
            <web:object runat="server" ID="panel" Caption="Technician Roster" BaseTable="tTechnicianRoster" 
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView ID="uitabview1" runat="server"  Caption="Details"
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <web:base ID="objectBase" runat="server" ObjectNumberVisible="false" ObjectNameVisible="false" meta:resourcekey="objectBaseResource1" >
                        </web:base>
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" PropertyName="LocationID"
                                ValidateRequiredField="True" ShowCheckBoxes="None"
                                TreeValueMode="SelectedNode" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" meta:resourcekey="treeLocationResource1">
                         </ui:UIFieldTreeList>
                         <ui:UIFieldDropDownList runat="server" ID="ddlYear" Caption="Year" PropertyName="Year" ValidateRequiredField="True" Span="Half" meta:resourcekey="ddlYearResource1"></ui:UIFieldDropDownList>
                         <ui:UIFieldDropDownList runat="server" ID="ddlMonth" Caption="Month" PropertyName="Month" ValidateRequiredField = "True" Span="Half" meta:resourcekey="ddlMonthResource1"></ui:UIFieldDropDownList>
                          <ui:UIFieldRadioList ID="UIFieldRadioList1" runat="server" PropertyName="DefaultAssignmentMode" ValidateRequiredField="True" Caption="Assignment Type" meta:resourcekey="UIFieldRadioList1Resource1" TextAlign="Right">
                                <Items>
                                    <asp:ListItem Value="0" meta:resourcekey="ListItemResource1" Text="Manually Assign Technicians by Roster"></asp:ListItem>
                                    <asp:ListItem Value="1" meta:resourcekey="ListItemResource2" Text="Automatically Assign All"></asp:ListItem>
                                    <asp:ListItem Value="2" meta:resourcekey="ListItemResource3" Text="Automatically Assign One (in Round-Robin Fashion)"></asp:ListItem>
                                </Items>
                            </ui:UIFieldRadioList>
                         <ui:UISeparator runat="server" Caption="Technician Roster Items" meta:resourcekey="UISeparatorResource1"/>
                         <ui:UIButton runat="server" ID="btnDownload" ImageUrl="~/images/download.png" 
                            Text="Download Excel template"  
                            AlwaysEnabled="True"  OnClick="btnDownload_Click" meta:resourcekey="btnDownloadResource1" />
                      <ui:UIButton runat="server" Text="Upload Excel Data" ID="btnUpdateItem" ImageUrl="~/images/upload.png" OnClick="btnUpdateItem_Click" meta:resourcekey="btnUpdateItemResource1" />

                         <ui:UIPanel runat="server" ID="panelUpload" Visible="False" BackColor="#FFFFCC" 
                            Height="25px" meta:resourcekey="panelUploadResource1" BorderStyle="NotSet" >
                            <ui:UIFieldInputFile runat="server" ID="InputFile" Caption="Budget Adjustment" 
                                Width="50%" meta:resourcekey="InputFileResource1" />
                            <ui:UIButton runat="server" ID="btnUploadConfirm" Text="Confirm" ImageUrl="~/images/tick.gif" ConfirmText="All existing technician roster items will be lost and new items will be created based on the Excel spreadsheet. Are you sure you wish to continue?" OnClick="btnUploadConfirm_Click" meta:resourcekey="btnUploadConfirmResource1" />
                            <ui:UIButton runat="server" ID="btnUploadCancel" Text="Cancel" ImageUrl="~/images/remove.gif" OnClick="btnUploadCancel_Click" meta:resourcekey="btnUploadCancelResource1" />
                        </ui:UIPanel>
                         <ui:UIPanel runat="server" ID="panelTechnicianRosterItems"  BorderStyle="NotSet" meta:resourcekey="panelTechnicianRosterItemsResource1">
                                                
                        <ui:UIGridView ID="TechnicianRosterItems" runat="server" Caption="Items" 
                                 PropertyName="TechnicianRosterItems" ValidateRequiredField="True"
                            KeyName="ObjectID" Width="100%" PagingEnabled="True" DataKeyNames="ObjectID" 
                                 GridLines="Both" RowErrorColor=""
                            Style="clear: both;" SortExpression="Day ASC, Shift.ObjectName ASC" 
                                 meta:resourcekey="TechnicianRosterItemsResource2" ImageRowErrorUrl="">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject" CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddObject" CommandText="Add" ImageUrl="~/images/add.gif" meta:resourceKey="UIGridViewCommandResource2" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="Day" HeaderText="Day" meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="Day" ResourceAssemblyName="" SortExpression="Day">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Shift.ObjectName" HeaderText="Shift" meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="Shift.ObjectName" ResourceAssemblyName="" SortExpression="Shift.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Names" HeaderText="User(s)" 
                                    PropertyName="Names" ResourceAssemblyName="" SortExpression="Names" 
                                    meta:resourcekey="UIGridViewBoundColumnResource7">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel ID="TechnicianRosterItem_Panel" runat="server" BorderStyle="NotSet" meta:resourcekey="TechnicianRosterItem_PanelResource1">
                            <web:subpanel runat="server" ID="TechnicianRosterItem_SubPanel" GridViewID="TechnicianRosterItems" OnPopulateForm="TechnicianRosterItem_SubPanel_PopulateForm" OnValidateAndUpdate="TechnicianRosterItem_SubPanel_ValidateAndUpdate" />
                            <ui:UIFieldDropDownList runat="server" ID="ddlDay" PropertyName="Day" Caption="Day" Span="Half"  ValidateRequiredField="True" meta:resourcekey="ddlDayResource1"></ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="ddlShift" PropertyName="ShiftID" Caption="Shift" ValidateRequiredField="True" Span="Half" meta:resourcekey="ddlShiftResource1"></ui:UIFieldDropDownList>
                            <ui:UIFieldDropDownList runat="server" ID="ddlTechnician" Caption="Select Technician" Span="Half" OnSelectedIndexChanged="ddlTechnician_SelectedIndexChanged" meta:resourcekey="ddlTechnicianResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIPanel runat="server" ID="Technicians_Panel" BorderStyle="NotSet" 
                                meta:resourcekey="Technicians_PanelResource1">
                                <ui:UIGridView runat="server" ID="gridTechnicians" PropertyName="Technicians" 
                                    DataKeyNames="ObjectID" KeyName="ObjectID" Caption="Technicians" 
                                    OnAction="gridTechnicians_Action" GridLines="Both" 
                                    meta:resourcekey="gridTechniciansResource1" RowErrorColor="" 
                                    style="clear:both;">
                                    <PagerSettings Mode="NumericFirstLast" />
                                    <Commands>
                                        <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                            CommandName="DeleteTechnician" CommandText="Delete" 
                                            ConfirmText="Are you sure you wish to delete the selected items?" 
                                            ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource3" />
                                    </Commands>
                                    <Columns>
                                        <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteTechnician" 
                                            ConfirmText="Are you sure you wish to delete this item?" 
                                            ImageUrl="~/images/delete.gif" 
                                            meta:resourcekey="UIGridViewButtonColumnResource1">
                                            <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewButtonColumn>
                                        <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Technician" 
                                            meta:resourcekey="UIGridViewBoundColumnResource8" PropertyName="ObjectName" 
                                            ResourceAssemblyName="" SortExpression="ObjectName">
                                            <HeaderStyle HorizontalAlign="Left" />
                                            <ItemStyle HorizontalAlign="Left" />
                                        </cc1:UIGridViewBoundColumn>
                                    </Columns>
                                </ui:UIGridView>
                            </ui:UIPanel>
                        </ui:UIObjectPanel>
                    </ui:UIPanel>
                         
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo"  meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
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
