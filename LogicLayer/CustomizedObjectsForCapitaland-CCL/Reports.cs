using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Data.Odbc;
using System.Data.Sql;
using System.Data.SqlClient;
using System.Text;
using System.Globalization;
using Anacle.DataFramework;

namespace LogicLayer
{
    //--------------------------------------------------------------------
    /// <summary>
    /// This is the Reports class that will be used by the Report 
    /// Builder to call methods within this class. 
    /// <para></para>
    /// All reports/dashboards that are to be exposed to the Report 
    /// Builder at the Web Application layer must declare one of the 
    /// following prototypes:
    /// <para></para>
    ///     public static DataTable ReportMethodName(ReportParameters 
    ///         parameters);
    /// <para></para>
    ///     public static DataSet ReportMethodName(ReportParameters 
    ///         parameters);
    /// 
    /// </summary>
    //--------------------------------------------------------------------
    public partial class Reports
    {
        #region Survey

        public static DataTable SurveyAverageRatingReport(ReportParameters parameters)
        {

            int F_SurveyYear = DateTime.Today.Year;
            string F_SurveyPlannerIDs = "";
            if (parameters.GetString("F_SurveyYear") != "")
                F_SurveyYear = parameters.GetInteger("F_SurveyYear").Value;
            if (parameters.GetList("F_SurveyPlannerIDs").Count > 0)
            {
                F_SurveyPlannerIDs = "(";
                for (int i = 0; i < parameters.GetList("F_SurveyPlannerIDs").Count; i++)
                {
                    if (i == ((parameters.GetList("F_SurveyPlannerIDs").Count) - 1))
                        F_SurveyPlannerIDs += "'" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "')";
                    else
                        F_SurveyPlannerIDs += "'" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "',";
                }
            }

            DateTime Year = new DateTime(F_SurveyYear, 1, 1);
            SqlParameter p1 = new SqlParameter("Year", Year);
            //SqlParameter p2 = new SqlParameter("SurveyPlannerID", F_SurveyPlanner);
            DataSet dts = Connection.ExecuteQuery("#database",
                @"
declare @sdate datetime
declare @edate datetime
set @sdate = @Year
set @edate = DateAdd(year,1,@sdate)

declare  @tbl table(CheckListName nvarchar(255),CheckListID uniqueidentifier,TotalSurvey int, TotalResponde int,spYear int)

insert into @tbl
select cl.ObjectName,cl.ObjectID,(select count(ObjectID) from Survey where SurveyPlannerID = pl.ObjectID) as 'TotalSurvey',
(select count(ObjectID) from Survey where SurveyPlannerID = pl.ObjectID and Status in (2,3)) as 'TotalRespond',
DatePart(year,pl.ValidStartDate) as 'Year'
from SurveyPlanner pl
--left join SurveyGroupServiceLevel sgl on pl.ObjectID = sgl.SurveyPlannerID
--left join SurveyGroup sg on sgl.SurveyGroupID = sg.ObjectID
left join Survey s on s.SurveyPlannerID = pl.ObjectID
left join SurveyCheckListItem scli on scli.SurveyID = s.ObjectID
left join CheckList cl on scli.CheckListID = cl.ObjectID
where (
(pl.ValidStartDate >= @sdate and pl.ValidEndDate <= @edate)
--or (pl.ValidStartDate >= dateadd(year,-1,@sdate) and pl.ValidEndDate <= dateadd(year,-1,@edate))
)
and pl.IsDeleted = 0 and s.IsDeleted = 0 and cl.IsDeleted = 0 and scli.IsDeleted = 0
and pl.Objectid in " + F_SurveyPlannerIDs + @"
order by pl.CreatedDateTime

select CheckListName as 'CheckListItem',spYear as 'Year',
Convert(decimal(19,2),Convert(decimal(19,2),sum(totalResponde))/Convert(decimal(19,2),sum(totalSurvey))*100) as 'Percentage'
from @tbl
group by CheckListID,CheckListName,spYear
order by spYear", p1);

            //DataTable dttemp = dts.Tables[0];

            DataTable dt = new DataTable();
            dt.Columns.Add("Year", typeof(int));
            dt.Columns.Add("Percentage", typeof(Decimal));
            dt.Columns.Add("CheckListItem");
            dt = dts.Tables[0];
            //foreach (DataRow row in dttemp.Rows)
            //{
            //    DataRow r = dt.NewRow();
            //    r["Year"] = row["Year"];
            //    r["Percentage"] = row["Percentage"];
            //    r["CheckListItem"] = row["CheckListItem"];
            //}
            return dt;
        }

        public static DataTable SurveyYear()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("YearText", typeof(string));
            dt.Columns.Add("YearValue", typeof(int));
            for (int i = 1; i <= 10; i++)
            {
                dt.Rows.Add(new object[] { i.ToString(), i });
            }
            return dt;
        }

        public static DataTable SurveySummaryReport(ReportParameters parameters)
        {

            int F_SurveyYear = DateTime.Today.Year;
            string F_SurveyPlannerIDs = "";
            if (parameters.GetString("F_SurveyYear") != "")
                F_SurveyYear = parameters.GetInteger("F_SurveyYear").Value;
            if (parameters.GetList("F_SurveyPlannerIDs").Count > 0)
            {
                F_SurveyPlannerIDs = "(";
                for (int i = 0; i < parameters.GetList("F_SurveyPlannerIDs").Count; i++)
                {
                    if (i == ((parameters.GetList("F_SurveyPlannerIDs").Count) - 1))
                        F_SurveyPlannerIDs += "'" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "')";
                    else
                        F_SurveyPlannerIDs += "'" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "',";
                }
            }
            DateTime Year = new DateTime(F_SurveyYear, 1, 1);
            SqlParameter p1 = new SqlParameter("Year", Year);
            DataSet dts = Connection.ExecuteQuery("#database",
                @"
declare @sdate datetime
declare @edate datetime
set @sdate = @Year
set @edate = DateAdd(year,1,@sdate)

select cl.ObjectName as CheckListItem,scli.ObjectName as Question,
sum(case when  clrp.ScoreNumerator = 1 then 1 else 0 end) as Poor ,
sum(case when  clrp.ScoreNumerator = 2 then 1 else 0 end) as Average ,
sum(case when  clrp.ScoreNumerator = 3 then 1 else 0 end) as Good ,
sum(case when  clrp.ScoreNumerator = 4 then 1 else 0 end) as Excellent,
DatePart(year,@Year) as Year
from SurveyPlanner sp
left join Survey s on s.SurveyPlannerID = sp.ObjectID
left join SurveyCheckListItem scli on scli.SurveyID = s.ObjectID
left join CheckList cl on scli.CheckListID = cl.ObjectID
left join SurveyChecklistItemChecklistResponse scrp on scrp.SurveyCheckListItemID = scli.ObjectID
left join ChecklistResponse clrp on clrp.ObjectID = scrp.CheckListResponseID
where (sp.ValidStartDate >= @sdate and sp.ValidEndDate <= @edate)
and sp.IsDeleted = 0
and sp.ObjectID in " + F_SurveyPlannerIDs + @"
group by 
scli.CheckListID,scli.ObjectName,cl.ObjectName", p1);


            DataTable dt = new DataTable();
            dt.Columns.Add("CheckListItem", typeof(string));
            dt.Columns.Add("Question", typeof(string));
            dt.Columns.Add("Poor", typeof(int));
            dt.Columns.Add("Average", typeof(int));
            dt.Columns.Add("Good", typeof(int));
            dt.Columns.Add("Excellent", typeof(int));
            dt.Columns.Add("Year", typeof(int));
            dt = dts.Tables[0];

            return dt;
        }

        /// <summary>
        /// Datatable for Report that return SurveyPlannerResultTotalScore        
        /// </summary>
        /// <returns>DataTable</returns>
        public static DataTable SurveyPlannerResultTotalScoreCCL(ReportParameters parameters)
        {
            //string F_SurveyGroupID = "";
            string F_SurveyPlannerIDs = "";
            string F_SurveyPlanner2IDs = "";

            //if (parameters.GetString("F_SurveyGroupID") != "")
            //    F_SurveyGroupID = parameters.GetString("F_SurveyGroupID");

            if (parameters.GetList("F_SurveyPlannerIDs").Count > 0)
            {
                F_SurveyPlannerIDs = "(";
                F_SurveyPlanner2IDs = "(";
                for (int i = 0; i < parameters.GetList("F_SurveyPlannerIDs").Count; i++)
                {
                    if (i == ((parameters.GetList("F_SurveyPlannerIDs").Count) - 1))
                    {
                        F_SurveyPlannerIDs += "'" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "')";
                        F_SurveyPlanner2IDs += "''" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "'')";
                    }
                    else
                    {
                        F_SurveyPlannerIDs += "'" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "',";
                        F_SurveyPlanner2IDs += "''" + parameters.GetList("F_SurveyPlannerIDs")[i].ToString() + "'',";
                    }
                }
            }

            //if (F_SurveyGroupID == "" || F_SurveyPlannerIDs == "")
            if (F_SurveyPlannerIDs == "")
            {
                DataTable ErrorDT = new DataTable();
                ErrorDT.Columns.Add("Error Message");
                ErrorDT.Rows.Add(new Object[] { "Please select all filters in order to generate the report correctly." });
                return ErrorDT;
            }

            //SqlParameter p1 = new SqlParameter("SurveyGroupID", F_SurveyGroupID);
            SqlParameter p2 = new SqlParameter("NA", (object)("'N.A.'"));
            SqlParameter p3 = new SqlParameter("Remaining", (object)("'...'"));
            SqlParameter p4 = new SqlParameter("Percentage", (object)("'%'"));
            SqlParameter p5 = new SqlParameter("dash", (object)("'-'"));

            DataSet dts = Connection.ExecuteQuery("#database",
                @"
-- To generate the columns --

DECLARE @cols NVARCHAR(2000)
SELECT  @cols = COALESCE (@cols + ',[' + case when len(a.objectname) > 50 then substring(a.objectname,1,50) + '...' else a.objectname end + ']',
                         '[' + case when len(a.objectname) > 50 then substring(a.objectname,1,50) + '...' else a.objectname end + ']')
FROM    SurveyChecklistItem a
WHERE	a.SurveyRespondentID = (select top 1 t1.surveyrespondentid
                                from
                                surveychecklistitem t1
                                where
                                t1.isdeleted = 0
                                and t1.surveyplannerid in " + F_SurveyPlannerIDs + @")
AND     a.SurveyPlannerID in " + F_SurveyPlannerIDs + @"
ORDER BY a.stepnumber asc

IF (@cols is not null)
BEGIN
EXECUTE(N'SELECT 
					  scli.objectname as question
                      , scli.objectid as surveychecklistitemid  
                      , scli.checklistid
					  , sr.objectname as surveyrespondentname
                      , splan.ObjectName as plannerName                        
					  , case when scli.checklistitemtype in (1,4) then scli.description
							 when scli.checklistitemtype in (0,3) then 
								  (select 
								  cast(sum(clr.scorenumerator) as nvarchar(50)) 
								  from [surveychecklistitemchecklistresponse] scliclr
								  left join [checklistresponse] clr on scliclr.checklistresponseid = clr.objectid
								  where scliclr.surveychecklistitemid = scli.objectid			
								  )
							 else '+@NA+' 
						end as score
                FROM    [surveychecklistitem] scli
                LEFT JOIN [surveyplanner] splan on (scli.surveyplannerid = splan.objectid and splan.isdeleted = 0)
                LEFT JOIN [survey] s on (scli.surveyid = s.objectid and s.isdeleted = 0)
				LEFT JOIN [surveyrespondent] sr on (scli.surveyrespondentid = sr.objectid and sr.isdeleted = 0)
                WHERE   
						scli.isdeleted = 0
						and	scli.surveyrespondentid in
                            (select distinct
                            t1.surveyrespondentid
                            from
                            surveychecklistitem t1
                            where
                            t1.isdeleted = 0
                            and t1.surveyplannerid in " + F_SurveyPlanner2IDs + @")
				        and scli.surveyplannerid in " + F_SurveyPlanner2IDs + @"
                        and s.Status <> 0
            '
    )
END
                    ",
                 p2, p3, p4, p5
                 );

            DataSet dts2 = Connection.ExecuteQuery("#database",
                @"
SELECT  a.objectname
FROM    SurveyChecklistItem a
WHERE	a.SurveyRespondentID = (select top 1 t1.surveyrespondentid
                                from
                                surveychecklistitem t1
                                where
                                t1.isdeleted = 0
                                and t1.surveyplannerid in " + F_SurveyPlannerIDs + @")
AND     a.SurveyPlannerID in " + F_SurveyPlannerIDs + @"
ORDER BY a.stepnumber asc
");

            if (dts.Tables.Count > 0)
            {
                DataTable t = dts.Tables[0];
                DataTable dt = GetInversedDataTable(dts.Tables[0], "question", "surveyrespondentname", "score", "", false);

                dt.Columns[0].ColumnName = "Respondent";
                //dt.Columns.Add("Checklist ObjectID");
                //dt.Columns.Add("Respondent");
                //dt.Columns.Add("Survey Planner Name");

                List<Guid?> checkListID = new List<Guid?>();
                foreach (DataRow r in t.Rows)
                {
                    OSurveyChecklistItem scli = TablesLogic.tSurveyChecklistItem[new Guid(r[1].ToString())];
                    //r["Checklist ObjectID"] = scli.ChecklistID.Value.ToString();
                    //r["Respondent"] = scli.SurveyRespondent.ObjectName;
                    //r["Survey Planner Name"] = scli.SurveyPlanner.ObjectName;

                    if (!checkListID.Contains(scli.ChecklistID.Value))
                        checkListID.Add(scli.ChecklistID.Value);
                }

                int TotalNumberOfQuestions = (dt.Columns.Count - 1);
                dt.Columns.Add("Total Score", typeof(decimal));
                dt.Columns["Total Score"].ExtendedProperties["DataFormatString"] = "{0:#,##0.00}";

                List<OChecklistItem> list = TablesLogic.tChecklistItem.LoadList(
                    TablesLogic.tChecklistItem.ChecklistID.In(checkListID)
                    ,
                    TablesLogic.tChecklistItem.StepNumber.Asc
                    );

                DataTable dt2 = dt.Clone();

                foreach (OChecklistItem i in list)
                {
                    if (i.ChecklistType == ChecklistItemType.Choice || i.ChecklistType == ChecklistItemType.MultipleSelections)
                        dt2.Columns[i.ObjectName].DataType = typeof(decimal);
                }

                //for (int i = 0; i < TotalNumberOfQuestions; i++)
                //{
                //    if (((OChecklistItem)list[i]).ChecklistType == ChecklistItemType.Choice ||
                //        ((OChecklistItem)list[i]).ChecklistType == ChecklistItemType.MultipleSelections)
                //        dt2.Columns[1 + i].DataType = typeof(decimal);
                //}

                foreach (DataRow dr in dt.Rows)
                {
                    dr["Total Score"] = 0M;
                    foreach (OChecklistItem i in list)
                    {
                        //for (int i = 0; i < TotalNumberOfQuestions; i++)
                        //{
                        //    if (((OChecklistItem)list[i]).ChecklistType == ChecklistItemType.Choice ||
                        //        ((OChecklistItem)list[i]).ChecklistType == ChecklistItemType.MultipleSelections)
                        //        dr["Total Score"] = (decimal)dr["Total Score"] + (dr[1 + i] == DBNull.Value || dr[1 + i].ToString() == "" ? 0 : Convert.ToDecimal(dr[1 + i].ToString()));
                        //}

                        if (i.ChecklistType == ChecklistItemType.Choice ||
                            i.ChecklistType == ChecklistItemType.MultipleSelections)
                            dr["Total Score"] = (decimal)dr["Total Score"] + (dr[i.ObjectName] == DBNull.Value || dr[i.ObjectName].ToString() == "" ? 0 : Convert.ToDecimal(dr[i.ObjectName].ToString()));
                    }
                    dt2.ImportRow(dr);
                }

                //dt2.Columns.Remove(dt2.Columns["Checklist ObjectID"]);
                //dt2.Columns.Remove(dt2.Columns["Contract ObjectID"]);
                //dt2.Columns.Remove(dt2.Columns["Contract Reference No."]);
                //dt2.Columns.Remove(dt2.Columns["Survey ObjectID"]);
                return dt2;
            }
            else
            {
                DataTable ErrorDT = new DataTable();
                ErrorDT.Columns.Add("Error Message");
                ErrorDT.Rows.Add(new Object[] { "Query returns zero table." });
                return ErrorDT;
            }
        }

        #endregion

        #region ACG Report

        /// <summary>
        /// Returns a Data Set containing multiple Data Tables reresenting sub-reports table structures.
        /// </summary>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static DataSet ACGReport(ReportParameters parameters)
        {
            OApplicationSetting appconfig = OApplicationSetting.Current;
            DataSet ACGDataSet = new DataSet("ACG Report");

            DateTime? filterYTD = parameters.GetDateTime("FILTER_YTD");
            DateTime YTD = (filterYTD != null) ? filterYTD.Value : DateTime.Now;

            Guid filterLocation = new Guid(parameters.GetString("FILTER_Location"));
            OLocation location = TablesLogic.tLocation.Load(filterLocation);
            DataTable LocationName = new DataTable();
            LocationName.Columns.Add("Location", typeof(string));
            LocationName.Rows.Add(location.ObjectName.ToUpper());
            LocationName.TableName = "Location";

            DataTable BudgetDetailSummaryRRAccounts = BudgetDetailSummaryReport(location, YTD, "Repairs & Replacements", true, 0);
            DataTable BudgetDetailSummaryMiscAccounts = BudgetDetailSummaryReport(location, YTD, "Miscellaneous", false, 0);
            DataTable BudgetDetailSummaryStatutoryAccounts = BudgetDetailSummaryReport(location, YTD, "Statutory Fee", true, 0);

            DataTable BudgetDetailSummary = BudgetDetailSummaryRRAccounts.Clone();
            BudgetDetailSummary.Merge(BudgetDetailSummaryRRAccounts);
            BudgetDetailSummary.Merge(BudgetDetailSummaryMiscAccounts);
            BudgetDetailSummary.Merge(BudgetDetailSummaryStatutoryAccounts);

            DataTable BudgetDetailSummaryTenancyAccount = BudgetDetailSummaryReport(location, YTD, "Tenancy Works", false, 0);
            BudgetDetailSummaryTenancyAccount.TableName = "BudgetDetailSummaryTenancyAccount";

            DataTable BudgetDetailSummaryTermContractAccount = BudgetDetailSummaryReport(location, YTD, "Term Contract", true, 0);
            BudgetDetailSummaryTermContractAccount.TableName = "BudgetDetailSummaryTermContractAccount";

            DataTable Capex = CapexReport(location, YTD);

            //DataTable PreventiveMaintenanceProgramme = PreventiveMaintenanceReport(YTD);
            DataTable PreventiveMaintenanceProgramme = new DataTable("PreventiveMaintenanceProgramme");

            DataTable ServiceContracts = ServiceContractsReport(location, YTD);

            DataTable ServiceToTenants = ServiceToTenantsReport(location, YTD);

            ACGDataSet.Tables.Add(BudgetDetailSummary);
            ACGDataSet.Tables.Add(Capex);
            ACGDataSet.Tables.Add(PreventiveMaintenanceProgramme);
            ACGDataSet.Tables.Add(ServiceContracts);
            ACGDataSet.Tables.Add(ServiceToTenants);
            ACGDataSet.Tables.Add(new DataTable("Dummy"));
            ACGDataSet.Tables.Add(LocationName);
            ACGDataSet.Tables.Add(BudgetDetailSummaryTenancyAccount);
            ACGDataSet.Tables.Add(BudgetDetailSummaryTermContractAccount);

            return ACGDataSet;
        }

        /// <summary>
        /// Returns a Data Table representing the Capex Report table structure.
        /// </summary>
        /// <param name="location"></param>
        /// <param name="YTD"></param>
        /// <returns>DataTable</returns>
        public static DataTable CapexReport(OLocation location, DateTime YTD)
        {
            DateTime formattedYTD = new DateTime(YTD.Year, YTD.Month, 1);
            DataTable result = new DataTable("Capex");
            // Table structure: Description | Year Budget | Current Month Actual
            result.Columns.Add("Description");
            result.Columns.Add("YearBudget", typeof(decimal));
            result.Columns.Add("CurrentMonthActual", typeof(decimal));
            result.Columns.Add("YTDActual", typeof(decimal));
            result.Columns.Add("YTDBudget", typeof(decimal));
            //if (location.ParentPath.StartsWith(EnumCCLGroup.Admin.ToString()))
            //{
            //    OAccount acc = TablesLogic.tAccount.Load(
            //        TablesLogic.tAccount.ObjectName == EnumCCLGroup.Admin.ToString()
            //        & TablesLogic.tAccount.Type == 0);
            //}

            // From Location & year get the Budget Period 
            //OBudgetPeriod BP = TablesLogic.tBudgetPeriod.Load(
            //    TablesLogic.tBudgetPeriod.Budget.ApplicableLocations.ObjectID == location.ObjectID
            //    & TablesLogic.tBudgetPeriod.ObjectName.Like("%" + year + "%"));
            OBudgetPeriod budgetPeriod = TablesLogic.tBudgetPeriod.Load(
                TablesLogic.tBudgetPeriod.Budget.ApplicableLocations.ObjectID == location.ObjectID
                &
                TablesLogic.tBudgetPeriod.StartDate <= formattedYTD
                &
                TablesLogic.tBudgetPeriod.EndDate >= formattedYTD
                );

            //From BP get List BPOB
            if (budgetPeriod != null)
            {
                DataList<OBudgetPeriodOpeningBalance> BPOB = budgetPeriod.BudgetPeriodOpeningBalances;
                //From BPOB get All Accounts then for loop and only get Account under Capex
                List<OBudgetPeriodOpeningBalance> FinalBPOB = new List<OBudgetPeriodOpeningBalance>();
                foreach (OBudgetPeriodOpeningBalance OB in BPOB)
                {
                    if (OB.Account.Path.Contains("Capex"))
                        FinalBPOB.Add(OB);
                }

                foreach (OBudgetPeriodOpeningBalance fOB in FinalBPOB)
                {
                    DataRow row = result.NewRow();
                    if (string.IsNullOrEmpty(fOB.Account.Description))
                        row["Description"] = fOB.Account.ObjectName;
                    else
                        row["Description"] = fOB.Account.Description;
                    row["YearBudget"] = fOB.TotalOpeningBalance;

                    decimal currentMonthActual = TablesLogic.tBudgetTransactionLog
                        .Select(TablesLogic.tBudgetTransactionLog.TransactionAmount.Sum())
                        .Where(TablesLogic.tBudgetTransactionLog.IsDeleted == 0
                               &
                               TablesLogic.tBudgetTransactionLog.BudgetID == fOB.BudgetPeriod.Budget.ObjectID
                               &
                               TablesLogic.tBudgetTransactionLog.AccountID == fOB.AccountID
                               &
                               TablesLogic.tBudgetTransactionLog.TransactionType.In(1, 2, 12, 13, 14)
                               &
                               TablesLogic.tBudgetTransactionLog.DateOfExpenditure >= formattedYTD
                               &
                               TablesLogic.tBudgetTransactionLog.DateOfExpenditure < formattedYTD.AddMonths(1));

                    row["CurrentMonthActual"] = currentMonthActual;

                    decimal YTDActual = TablesLogic.tBudgetTransactionLog
                    .Select(TablesLogic.tBudgetTransactionLog.TransactionAmount.Sum())
                    .Where(TablesLogic.tBudgetTransactionLog.IsDeleted == 0
                           &
                           TablesLogic.tBudgetTransactionLog.BudgetID == fOB.BudgetPeriod.Budget.ObjectID
                           &
                           TablesLogic.tBudgetTransactionLog.AccountID == fOB.AccountID
                           &
                           TablesLogic.tBudgetTransactionLog.TransactionType.In(1, 2, 12, 13, 14)
                           &
                           TablesLogic.tBudgetTransactionLog.DateOfExpenditure >= budgetPeriod.StartDate
                           &
                           TablesLogic.tBudgetTransactionLog.DateOfExpenditure < formattedYTD.AddMonths(1));
                    row["YTDActual"] = YTDActual;

                    decimal YTDBudget = 0;
                    switch (formattedYTD.Month)
                    {
                        case 12: YTDBudget += fOB.OpeningBalance12.Value;
                            goto case 11;
                        case 11: YTDBudget += fOB.OpeningBalance11.Value;
                            goto case 10;
                        case 10: YTDBudget += fOB.OpeningBalance10.Value;
                            goto case 9;
                        case 9: YTDBudget += fOB.OpeningBalance09.Value;
                            goto case 8;
                        case 8: YTDBudget += fOB.OpeningBalance08.Value;
                            goto case 7;
                        case 7: YTDBudget += fOB.OpeningBalance07.Value;
                            goto case 6;
                        case 6: YTDBudget += fOB.OpeningBalance06.Value;
                            goto case 5;
                        case 5: YTDBudget += fOB.OpeningBalance05.Value;
                            goto case 4;
                        case 4: YTDBudget += fOB.OpeningBalance04.Value;
                            goto case 3;
                        case 3: YTDBudget += fOB.OpeningBalance03.Value;
                            goto case 2;
                        case 2: YTDBudget += fOB.OpeningBalance02.Value;
                            goto case 1;
                        case 1: YTDBudget += fOB.OpeningBalance01.Value;
                            break;
                    }

                    row["YTDBudget"] = YTDBudget;

                    result.Rows.Add(row);
                }
            }

            return result;
        }

        /// <summary>
        /// Return a Data Table representing the Budget Detail Summary Report table structure.
        /// </summary>
        /// <param name="location"></param>
        /// <param name="YTD"></param>
        /// <returns>DataTable</returns>
        public static DataTable BudgetDetailSummaryReport(OLocation location, DateTime YTD, OAccount account)
        {
            // Validate User Access Right
            // TO DO

            // Create Account Condition
            ExpressionCondition cond = Query.True;
            if (null != account)
                cond = cond & TablesLogic.tBudgetTransactionLog.Account.HierarchyPath.Like(account.HierarchyPath + "%");

            DateTime formattedYTD = new DateTime(YTD.Year, YTD.Month, 1);
            DataTable result = new DataTable("BudgetDetailSummary");
            // Table structure: Expenses | Y____ Budget (a) | Current Month Actual | 
            // YTD Actual (b) | YTD Budget (c) | Variance (=(e)/(a)) | Budget Balance ((a)-(b))
            result.Columns.Add("ParentAccount");
            result.Columns.Add("Expenses");
            result.Columns.Add("YearBudget", typeof(decimal));
            result.Columns.Add("CurrentMonthActual", typeof(decimal));
            result.Columns.Add("YTDActual", typeof(decimal));
            result.Columns.Add("YTDBudget", typeof(decimal));
            result.Columns.Add("Variance", typeof(decimal));
            result.Columns.Add("BudgetBalance", typeof(decimal));

            OBudgetPeriod budgetPeriod = TablesLogic.tBudgetPeriod.Load(
                TablesLogic.tBudgetPeriod.Budget.ApplicableLocations.ObjectID == location.ObjectID
                &
                TablesLogic.tBudgetPeriod.StartDate <= formattedYTD
                &
                TablesLogic.tBudgetPeriod.EndDate >= formattedYTD
                );

            if (budgetPeriod == null) return result;

            OBudget budget = budgetPeriod.Budget;

            DataList<OBudgetPeriodOpeningBalance> openingBalances = budgetPeriod.BudgetPeriodOpeningBalances;

            int count = 1;

            foreach (OBudgetPeriodOpeningBalance balance in openingBalances)
            {
                DataRow row = result.NewRow();

                row["Expenses"] = balance.Account.Parent.ObjectName;
                row["ParentAccount"] = balance.Account.ObjectName;
                row["YearBudget"] = balance.TotalOpeningBalance;

                decimal currentMonthActual = TablesLogic.tBudgetTransactionLog
                    .Select(TablesLogic.tBudgetTransactionLog.TransactionAmount.Sum())
                    .Where(TablesLogic.tBudgetTransactionLog.IsDeleted == 0
                           &
                           TablesLogic.tBudgetTransactionLog.BudgetID == budget.ObjectID
                           &
                           TablesLogic.tBudgetTransactionLog.AccountID == balance.AccountID
                           &
                           TablesLogic.tBudgetTransactionLog.TransactionType.In(1, 2, 12, 13, 14)
                           &
                           TablesLogic.tBudgetTransactionLog.DateOfExpenditure >= formattedYTD
                           &
                           TablesLogic.tBudgetTransactionLog.DateOfExpenditure <= formattedYTD.AddMonths(1)
                           &
                           cond);
                row["CurrentMonthActual"] = currentMonthActual;

                decimal YTDActual = TablesLogic.tBudgetTransactionLog
                    .Select(TablesLogic.tBudgetTransactionLog.TransactionAmount.Sum())
                    .Where(TablesLogic.tBudgetTransactionLog.IsDeleted == 0
                           &
                           TablesLogic.tBudgetTransactionLog.BudgetID == budget.ObjectID
                           &
                           TablesLogic.tBudgetTransactionLog.AccountID == balance.AccountID
                           &
                           TablesLogic.tBudgetTransactionLog.TransactionType.In(1, 2, 12, 13, 14)
                           &
                           TablesLogic.tBudgetTransactionLog.DateOfExpenditure >= budgetPeriod.StartDate
                           &
                           TablesLogic.tBudgetTransactionLog.DateOfExpenditure <= formattedYTD.AddMonths(1)
                           &
                           cond);
                row["YTDActual"] = YTDActual;

                decimal YTDBudget = 0;
                switch (formattedYTD.Month)
                {
                    case 12: YTDBudget += balance.OpeningBalance12.Value;
                        goto case 11;
                    case 11: YTDBudget += balance.OpeningBalance11.Value;
                        goto case 10;
                    case 10: YTDBudget += balance.OpeningBalance10.Value;
                        goto case 9;
                    case 9: YTDBudget += balance.OpeningBalance09.Value;
                        goto case 8;
                    case 8: YTDBudget += balance.OpeningBalance08.Value;
                        goto case 7;
                    case 7: YTDBudget += balance.OpeningBalance07.Value;
                        goto case 6;
                    case 6: YTDBudget += balance.OpeningBalance06.Value;
                        goto case 5;
                    case 5: YTDBudget += balance.OpeningBalance05.Value;
                        goto case 4;
                    case 4: YTDBudget += balance.OpeningBalance04.Value;
                        goto case 3;
                    case 3: YTDBudget += balance.OpeningBalance03.Value;
                        goto case 2;
                    case 2: YTDBudget += balance.OpeningBalance02.Value;
                        goto case 1;
                    case 1: YTDBudget += balance.OpeningBalance01.Value;
                        break;
                }

                row["YTDBudget"] = YTDBudget;

                decimal budgetBalance = balance.TotalOpeningBalance.Value - Convert.ToDecimal(row["YTDActual"]);

                row["BudgetBalance"] = budgetBalance;

                row["Variance"] = (balance.TotalOpeningBalance.Value != 0)
                                    ? budgetBalance / balance.TotalOpeningBalance.Value
                                    : 0;

                result.Rows.Add(row);
            }

            return result;
        }

        /// <summary>
        /// Return a Data Table representing the Budget Detail Summary Report table structure.
        /// </summary>
        /// <param name="location"></param>
        /// <param name="YTD"></param>
        /// <returns>DataTable</returns>
        public static DataTable BudgetDetailSummaryReport(OLocation location, DateTime YTD, string accountName, Boolean reverse, int parentLevel)
        {
            // Validate User Access Right
            // TO DO

            // Create Account Condition
            ExpressionCondition cond = Query.True;
            //List<OAccount> lst = new List<OAccount>();
            //if (!String.IsNullOrEmpty(accountName))
            //{
            //    ExpressionCondition cond2 = Query.False;
            //    foreach (OAccount acc in account)
            //        cond2 = cond2 | TablesLogic.tAccount.HierarchyPath.Like(acc.HierarchyPath + "%");
            //    lst.AddRange(TablesLogic.tAccount.LoadList(cond2));
            //}

            DateTime formattedYTD = new DateTime(YTD.Year, YTD.Month, 1);
            DataTable result = new DataTable("BudgetDetailSummary");
            // Table structure: Expenses | Y____ Budget (a) | Current Month Actual | 
            // YTD Actual (b) | YTD Budget (c) | Variance (=(e)/(a)) | Budget Balance ((a)-(b))
            result.Columns.Add("ParentAccount");
            result.Columns.Add("Expenses");
            result.Columns.Add("YearBudget", typeof(decimal));
            result.Columns.Add("CurrentMonthActual", typeof(decimal));
            result.Columns.Add("YTDActual", typeof(decimal));
            result.Columns.Add("YTDBudget", typeof(decimal));
            result.Columns.Add("Variance", typeof(decimal));
            result.Columns.Add("BudgetBalance", typeof(decimal));

            OBudgetPeriod budgetPeriod = TablesLogic.tBudgetPeriod.Load(
                TablesLogic.tBudgetPeriod.Budget.ApplicableLocations.ObjectID == location.ObjectID
                &
                TablesLogic.tBudgetPeriod.StartDate <= formattedYTD
                &
                TablesLogic.tBudgetPeriod.EndDate >= formattedYTD
                );

            if (budgetPeriod == null) return result;

            OBudget budget = budgetPeriod.Budget;

            DataList<OBudgetPeriodOpeningBalance> openingBalances = budgetPeriod.BudgetPeriodOpeningBalances;
            List<OBudgetPeriodOpeningBalance> finalOpeningBalances = new List<OBudgetPeriodOpeningBalance>();
            //foreach (OAccount a in lst)
            //{
            //    finalOpeningBalances.AddRange(openingBalances.FindAll(lf => lf.AccountID == a.ObjectID));
            //}

            foreach (OBudgetPeriodOpeningBalance balance in openingBalances)
            {
                if (balance.Account.Path.Contains(accountName))
                    finalOpeningBalances.Add(balance);
            }

            int count = 1;

            foreach (OBudgetPeriodOpeningBalance balance in finalOpeningBalances)
            {
                DataRow row = result.NewRow();
                if (reverse)
                {
                    OAccount acc;
                    if (balance.Account.ObjectName == accountName)
                        acc = findParentLevel(balance.Account, parentLevel);
                    else
                        acc = findParentLevel(balance.Account, parentLevel + 1);
                    row["Expenses"] = acc.Parent != null ? acc.Parent.ObjectName : "n/a";
                    row["ParentAccount"] = acc.ObjectName;
                }
                else
                {
                    row["Expenses"] = balance.Account.ObjectName;
                    row["ParentAccount"] = balance.Account.Parent.ObjectName;
                }


                row["YearBudget"] = balance.TotalOpeningBalance;

                decimal currentMonthActual = TablesLogic.tBudgetTransactionLog
                    .Select(TablesLogic.tBudgetTransactionLog.TransactionAmount.Sum())
                    .Where(TablesLogic.tBudgetTransactionLog.IsDeleted == 0
                           &
                           TablesLogic.tBudgetTransactionLog.BudgetID == budget.ObjectID
                           &
                           TablesLogic.tBudgetTransactionLog.AccountID == balance.AccountID
                           &
                           TablesLogic.tBudgetTransactionLog.TransactionType.In(1, 2, 12, 13, 14)
                           &
                           TablesLogic.tBudgetTransactionLog.DateOfExpenditure >= formattedYTD
                           &
                           TablesLogic.tBudgetTransactionLog.DateOfExpenditure <= formattedYTD.AddMonths(1)
                           &
                           cond);
                row["CurrentMonthActual"] = currentMonthActual;

                decimal YTDActual = TablesLogic.tBudgetTransactionLog
                    .Select(TablesLogic.tBudgetTransactionLog.TransactionAmount.Sum())
                    .Where(TablesLogic.tBudgetTransactionLog.IsDeleted == 0
                           &
                           TablesLogic.tBudgetTransactionLog.BudgetID == budget.ObjectID
                           &
                           TablesLogic.tBudgetTransactionLog.AccountID == balance.AccountID
                           &
                           TablesLogic.tBudgetTransactionLog.TransactionType.In(1, 2, 12, 13, 14)
                           &
                           TablesLogic.tBudgetTransactionLog.DateOfExpenditure >= budgetPeriod.StartDate
                           &
                           TablesLogic.tBudgetTransactionLog.DateOfExpenditure <= formattedYTD.AddMonths(1)
                           &
                           cond);
                row["YTDActual"] = YTDActual;

                decimal YTDBudget = 0;
                switch (formattedYTD.Month)
                {
                    case 12: YTDBudget += balance.OpeningBalance12.Value;
                        goto case 11;
                    case 11: YTDBudget += balance.OpeningBalance11.Value;
                        goto case 10;
                    case 10: YTDBudget += balance.OpeningBalance10.Value;
                        goto case 9;
                    case 9: YTDBudget += balance.OpeningBalance09.Value;
                        goto case 8;
                    case 8: YTDBudget += balance.OpeningBalance08.Value;
                        goto case 7;
                    case 7: YTDBudget += balance.OpeningBalance07.Value;
                        goto case 6;
                    case 6: YTDBudget += balance.OpeningBalance06.Value;
                        goto case 5;
                    case 5: YTDBudget += balance.OpeningBalance05.Value;
                        goto case 4;
                    case 4: YTDBudget += balance.OpeningBalance04.Value;
                        goto case 3;
                    case 3: YTDBudget += balance.OpeningBalance03.Value;
                        goto case 2;
                    case 2: YTDBudget += balance.OpeningBalance02.Value;
                        goto case 1;
                    case 1: YTDBudget += balance.OpeningBalance01.Value;
                        break;
                }

                row["YTDBudget"] = YTDBudget;

                decimal budgetBalance = balance.TotalOpeningBalance.Value - Convert.ToDecimal(row["YTDActual"]);

                row["BudgetBalance"] = budgetBalance;

                row["Variance"] = (balance.TotalOpeningBalance.Value != 0)
                                    ? budgetBalance / balance.TotalOpeningBalance.Value
                                    : 0;

                result.Rows.Add(row);
            }

            return result;
        }

        private static OAccount findParentLevel(OAccount acc, int levelRemain)
        {
            while (levelRemain > 0)
            {
                OAccount result = findParentLevel(acc.Parent, levelRemain - 1);
                return result;
            }
            return acc;
        }

        /// <summary>
        /// Return a Data Table representing the Preventive Maintenance Report table structure.
        /// </summary>
        /// <param name="YTD"></param>
        /// <returns>DataTable</returns>
        public static DataTable PreventiveMaintenanceReport(DateTime YTD)
        {
            // Validate User Access Right
            // TO DO

            DataTable result = new DataTable("PreventiveMaintenanceProgramme");
            // Table structure: TypeOfService | TypeOfProblem |
            // Jan | Feb | Mar | Apr | May | Jun |
            // Jul | Aug | Sep | Oct | Nov | Dec | 
            // Frequency
            result.Columns.Add("TypeOfService");
            result.Columns.Add("TypeOfProblem");
            result.Columns.Add("Jan");
            result.Columns.Add("Feb");
            result.Columns.Add("Mar");
            result.Columns.Add("Apr");
            result.Columns.Add("May");
            result.Columns.Add("Jun");
            result.Columns.Add("Jul");
            result.Columns.Add("Aug");
            result.Columns.Add("Sep");
            result.Columns.Add("Oct");
            result.Columns.Add("Nov");
            result.Columns.Add("Dec");
            result.Columns.Add("Frequency");

            DateTime YTDStartOfYear = new DateTime(YTD.Year, 1, 1);
            DateTime YTDEndOfYear = new DateTime(YTD.Year, 12, 31);

            //List<OWork> workList = TablesLogic.tWork.LoadList(
            //    TablesLogic.tWork.TypeOfService.ObjectName == "Feedback"
            //    &
            //    TablesLogic.tWork.TypeOfService.CodeType.ObjectName == "TypeOfWork"
            //    &
            //    TablesLogic.tWork.ScheduledStartDateTime >= YTDStartOfYear
            //    &
            //    TablesLogic.tWork.ScheduledEndDateTime <= YTDEndOfYear
            //    );

            List<OCode> typesOfProblem = TablesLogic.tCode.LoadList(
                TablesLogic.tCode.CodeType.ObjectName == "TypeOfProblem"
                &
                TablesLogic.tCode.Parent.Parent.ObjectName == "Feedback"
                &
                TablesLogic.tCode.Parent.Parent.CodeType.ObjectName == "TypeOfWork"
                );

            int count = 1;

            foreach (OCode typeOfProblem in typesOfProblem)
            {
                DataRow row = result.NewRow();

                row["TypeOfService"] = typeOfProblem.Parent.ObjectName;
                row["TypeOfProblem"] = typeOfProblem.ObjectName;

                string[] occurrences = { "", "", "", "", "", "", "", "", "", "", "", "" };

                List<OWork> workList = TablesLogic.tWork.LoadList(
                    TablesLogic.tWork.ActualTypeOfProblemID == typeOfProblem.ObjectID
                    &
                    TablesLogic.tWork.ActualStartDateTime >= YTDStartOfYear
                    &
                    TablesLogic.tWork.ActualEndDateTime <= YTDEndOfYear
                    );

                foreach (OWork work in workList)
                {
                    DateTime endDate = work.ActualEndDateTime.Value;
                    if (!occurrences[endDate.Month - 1].Contains(endDate.Day.ToString()))
                        occurrences[endDate.Month - 1] += "," + endDate.Day;
                }

                for (int i = 0; i < occurrences.Length; i++)
                {
                    if (occurrences[i].Length > 0)
                    {
                        occurrences[i] = occurrences[i].Substring(1);

                        String[] occurrencesArray = occurrences[i].Split(',');
                        int[] sortedOccurrencesArray = new int[occurrencesArray.Length];

                        for (int j = 0; j < occurrencesArray.Length; j++)
                        {
                            sortedOccurrencesArray[j] = Convert.ToInt16(occurrencesArray[j]);
                        }

                        Array.Sort(sortedOccurrencesArray);

                        if (IsOfMonWedFriPattern(sortedOccurrencesArray, YTD.Year, i + 1))
                            occurrences[i] = "Mon, Wed, Fri";
                        else if (IsOfTueThuSatPattern(sortedOccurrencesArray, YTD.Year, i + 1))
                            occurrences[i] = "Tue, Thu, Sat";
                        else
                        {
                            // Reformat the occurrence string if any of the days 
                            // span continuously for more than 3 days.
                            // Such as: 1,2,3,7,8,9,10,23,24,27,28,29,30,31 => 1,2,3,(7-10),23,24,(27-31)
                            int startOfDayRange = 0;
                            int endOfDayRange = 0;
                            String current = "";
                            String final = "";

                            for (int j = 0; j < sortedOccurrencesArray.Length; j++)
                            {
                                if (startOfDayRange == 0)
                                    startOfDayRange = sortedOccurrencesArray[j];

                                if (sortedOccurrencesArray[j] > endOfDayRange + 1)
                                {
                                    // The span has ended, concatenate the formatted string
                                    if (endOfDayRange - startOfDayRange > 2)
                                    {
                                        current = ",(" + startOfDayRange + "-" + endOfDayRange + ")";
                                    }
                                    final += current;
                                    current = "";
                                    startOfDayRange = sortedOccurrencesArray[j];
                                }

                                endOfDayRange = sortedOccurrencesArray[j];
                                current += "," + endOfDayRange;

                                if (j == sortedOccurrencesArray.Length - 1)
                                {
                                    // End of occurrences string, add in the formatted string if any
                                    if (endOfDayRange - startOfDayRange > 2)
                                    {
                                        current = ",(" + startOfDayRange + "-" + endOfDayRange + ")";
                                    }
                                    final += current;
                                }
                            }

                            if (final.Length > 0) occurrences[i] = final.Substring(1);
                            else occurrences[i] = "-";
                        }
                    }
                    else
                        occurrences[i] = "-";
                }

                row["Jan"] = occurrences[0];
                row["Feb"] = occurrences[1];
                row["Mar"] = occurrences[2];
                row["Apr"] = occurrences[3];
                row["May"] = occurrences[4];
                row["Jun"] = occurrences[5];
                row["Jul"] = occurrences[6];
                row["Aug"] = occurrences[7];
                row["Sep"] = occurrences[8];
                row["Oct"] = occurrences[9];
                row["Nov"] = occurrences[10];
                row["Dec"] = occurrences[11];

                row["Frequency"] = "";

                result.Rows.Add(row);
            }

            return result;
        }

        /// <summary>
        /// Return a Data Table representing the Service Contract Report table structure.
        /// </summary>
        /// <param name="location"></param>
        /// <param name="YTD"></param>
        /// <returns>DataTable</returns>
        public static DataTable ServiceContractsReport(OLocation location, DateTime YTD)
        {
            // Validate User Access Right
            // TO DO

            DateTime formattedYTD = new DateTime(YTD.Year, YTD.Month, 1);
            DataTable result = new DataTable("ServiceContracts");
            // Table structure: BudgetSubHead | Contractor | 
            // ContractStart | ContractEnd | Contract_noofmth |
            // ContractSum_permth | ContractSum_perannum | TotalContractSum |
            // RemarksStatusofRenewal
            result.Columns.Add("BudgetSubHead");
            result.Columns.Add("Contractor");
            result.Columns.Add("ContractStart", typeof(DateTime));
            result.Columns.Add("ContractEnd", typeof(DateTime));
            result.Columns.Add("Contract_noofmth", typeof(int));
            result.Columns.Add("ContractSum_permth", typeof(decimal));
            result.Columns.Add("ContractSum_perannum", typeof(decimal));
            result.Columns.Add("TotalContractSum", typeof(decimal));
            result.Columns.Add("RemarksStatusofRenewal");

            List<OContract> contractList = TablesLogic.tContract.LoadList(
                TablesLogic.tContract.Locations.ObjectID == location.ObjectID
                &
                TablesLogic.tContract.ContractStartDate <= formattedYTD
                &
                TablesLogic.tContract.ContractEndDate >= formattedYTD
                );

            if (contractList == null || contractList.Count == 0) return result;

            int count = 1;

            foreach (OContract contract in contractList)
            {
                if (contract.PurchaseOrderID != null)
                {
                    DataRow row = result.NewRow();

                    OAccount account = null;

                    if (contract.Vendor != null)
                        row["Contractor"] = contract.Vendor.ObjectName;
                    else
                        row["Contractor"] = "";
                    row["ContractStart"] = contract.ContractStartDate;
                    row["ContractEnd"] = contract.ContractEndDate;

                    int contractDurationInMonths = 0;
                    DateTime timeCursor = contract.ContractStartDate.Value;
                    while (true)
                    {
                        if (timeCursor >= contract.ContractEndDate.Value)
                            break;
                        timeCursor = timeCursor.AddMonths(1);
                        contractDurationInMonths++;
                    }

                    int contractDurationInYears = contract.ContractEndDate.Value.Year - contract.ContractStartDate.Value.Year + 1;
                    row["Contract_noofmth"] = contractDurationInMonths;

                    decimal? contractSum = 0;

                    DataList<OPurchaseBudget> purchaseBudgetList = contract.PurchaseOrder.PurchaseBudgets;

                    foreach (OPurchaseBudget purchaseBudget in purchaseBudgetList)
                    {
                        account = purchaseBudget.Account;

                        contractSum += purchaseBudget.Amount;
                    }

                    if (account != null)
                    {
                        row["BudgetSubHead"] = account.ParentID == null ? account.ObjectName : account.Parent.ObjectName;

                        row["ContractSum_permth"] = (contractDurationInMonths != 0)
                                                             ? contractSum / contractDurationInMonths
                                                             : 0;
                        row["ContractSum_perannum"] = (contractDurationInYears != 0)
                                                           ? contractSum / contractDurationInYears
                                                           : 0;
                        row["TotalContractSum"] = contractSum;// contract.ContractSum;

                        row["RemarksStatusofRenewal"] = "";

                        result.Rows.Add(row);
                    }
                }
            }

            return result;
        }

        /// <summary>
        /// Return a Data Table representing the Service to Tenants Report table structure.
        /// </summary>
        /// <param name="location"></param>
        /// <param name="YTD"></param>
        /// <returns>DataTable</returns>
        public static DataTable ServiceToTenantsReport(OLocation location, DateTime YTD)
        {
            // Validate User Access Right
            // TO DO

            DateTime formattedYTD = new DateTime(YTD.Year, 1, 1);
            DataTable result = new DataTable("ServiceToTenants");
            // Table structure: TypeOfService | YearBudget | 
            // Jan | Feb | Mar | Apr | May | Jun |
            // Jul | Aug | Sep | Oct | Nov | Dec | 
            // YTDActual | YTDBudget | BudgetBalance
            result.Columns.Add("TypeOfService");
            result.Columns.Add("YearBudget", typeof(decimal));
            result.Columns.Add("Jan", typeof(decimal));
            result.Columns.Add("Feb", typeof(decimal));
            result.Columns.Add("Mar", typeof(decimal));
            result.Columns.Add("Apr", typeof(decimal));
            result.Columns.Add("May", typeof(decimal));
            result.Columns.Add("Jun", typeof(decimal));
            result.Columns.Add("Jul", typeof(decimal));
            result.Columns.Add("Aug", typeof(decimal));
            result.Columns.Add("Sep", typeof(decimal));
            result.Columns.Add("Oct", typeof(decimal));
            result.Columns.Add("Nov", typeof(decimal));
            result.Columns.Add("Dec", typeof(decimal));
            result.Columns.Add("YTDActual", typeof(decimal));
            result.Columns.Add("YTDBudget", typeof(decimal));
            result.Columns.Add("BudgetBalance", typeof(decimal));

            OCode handymanServiceTypeOfWork = TablesLogic.tCode.Load(
                TablesLogic.tCode.ObjectName == "Handyman Services"
                &
                TablesLogic.tCode.CodeType.ObjectName == "TypeOfWork"
                );

            DateTime YTDStartOfYear = new DateTime(YTD.Year, 1, 1);
            DateTime YTDEndOfYear = new DateTime(YTD.Year, 12, 31);

            List<OWork> workList = TablesLogic.tWork.LoadList(
                TablesLogic.tWork.ActualTypeOfWorkID == handymanServiceTypeOfWork.ObjectID
                &
                TablesLogic.tWork.IsChargedToCaller == 1
                &
                TablesLogic.tWork.ActualStartDateTime >= YTDStartOfYear
                &
                TablesLogic.tWork.ActualEndDateTime <= YTDEndOfYear
                );

            string[] monthIndices = { "", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };

            foreach (OWork work in workList)
            {
                DataRow row = result.NewRow();

                row["TypeOfService"] = work.TypeOfService.ObjectName;

                row["YearBudget"] = 0;

                row["YTDBudget"] = 0;

                row["BudgetBalance"] = 0;

                row["Jan"] = row["Feb"] = row["Mar"] = row["Apr"] = row["May"] = row["Jun"] =
                    row["Jul"] = row["Aug"] = row["Sep"] = row["Oct"] = row["Nov"] = row["Dec"] = 0;

                DataList<OWorkCost> workCostList = work.WorkCost;

                decimal totalWorkCost = 0;

                foreach (OWorkCost workCost in workCostList)
                {
                    totalWorkCost += workCost.ActualCostTotal.Value;
                }

                // Assuming Work only last within a day
                if (work.ActualStartDateTime != null)
                    row[monthIndices[work.ActualStartDateTime.Value.Month]] = totalWorkCost;

                if (YTD.Month >= work.ActualStartDateTime.Value.Month)
                    row["YTDActual"] = totalWorkCost;
                else
                    row["YTDActual"] = 0;

                result.Rows.Add(row);
            }

            return result;
        }

        /// <summary>
        /// Checks if an occurrence of days in a month follows a Monday/Wednesday/Friday pattern.
        /// True if so, false otherwise.
        /// </summary>
        /// <param name="occurrences"></param>
        /// <param name="year"></param>
        /// <param name="month"></param>
        /// <returns></returns>
        private static bool IsOfMonWedFriPattern(int[] occurrences, int year, int month)
        {
            if (occurrences.Length == 0) return false;

            DateTime current;

            DayOfWeek expectingDayOfWeek = (new DateTime(year, month, occurrences[0])).DayOfWeek;
            if (expectingDayOfWeek != DayOfWeek.Monday
                && expectingDayOfWeek != DayOfWeek.Wednesday
                && expectingDayOfWeek != DayOfWeek.Friday)
                return false;

            for (int i = 1; i < occurrences.Length; i++)
            {
                if (expectingDayOfWeek == DayOfWeek.Monday)
                    expectingDayOfWeek = DayOfWeek.Wednesday;
                else if (expectingDayOfWeek == DayOfWeek.Wednesday)
                    expectingDayOfWeek = DayOfWeek.Friday;
                else if (expectingDayOfWeek == DayOfWeek.Friday)
                    expectingDayOfWeek = DayOfWeek.Monday;

                current = new DateTime(year, month, occurrences[i]);
                if (current.DayOfWeek != expectingDayOfWeek) return false;
            }

            return true;
        }

        /// <summary>
        /// Checks if an occurrence of days in a month follows a Tuesday/Thursday/Saturday pattern.
        /// True if so, false otherwise.
        /// </summary>
        /// <param name="occurrences"></param>
        /// <param name="year"></param>
        /// <param name="month"></param>
        /// <returns></returns>
        private static bool IsOfTueThuSatPattern(int[] occurrences, int year, int month)
        {
            if (occurrences.Length == 0) return false;

            DateTime current;

            DayOfWeek expectingDayOfWeek = (new DateTime(year, month, occurrences[0])).DayOfWeek;
            if (expectingDayOfWeek != DayOfWeek.Tuesday
                && expectingDayOfWeek != DayOfWeek.Thursday
                && expectingDayOfWeek != DayOfWeek.Saturday)
                return false;

            for (int i = 1; i < occurrences.Length; i++)
            {
                if (expectingDayOfWeek == DayOfWeek.Tuesday)
                    expectingDayOfWeek = DayOfWeek.Thursday;
                else if (expectingDayOfWeek == DayOfWeek.Thursday)
                    expectingDayOfWeek = DayOfWeek.Saturday;
                else if (expectingDayOfWeek == DayOfWeek.Saturday)
                    expectingDayOfWeek = DayOfWeek.Tuesday;

                current = new DateTime(year, month, occurrences[i]);
                if (current.DayOfWeek != expectingDayOfWeek) return false;
            }

            return true;
        }

        /// <summary>
        /// Validates the user access to the specific report and location.
        /// </summary>
        /// <param name="user"></param>
        /// <param name="report"></param>
        /// <param name="LocationID"></param>
        /// <returns></returns>
        private static bool validateUserAccessRight(OUser user, OReport report, Guid locationID)
        {
            bool locationAccess = false, reportAccess = false;

            DataList<OPosition> positions = user.Positions;

            List<Guid> roles = new List<Guid>();

            foreach (OPosition position in positions)
            {
                if (position.LocationAccess.Find(locationID) != null)
                {
                    locationAccess = true;
                    break;
                }
                roles.Add(position.RoleID.Value);
            }

            foreach (Guid roleID in roles)
            {
                if (report.Roles.Find(roleID) != null)
                {
                    reportAccess = true;
                    break;
                }
            }

            return locationAccess && reportAccess;
        }

        public enum EnumCCLGroup
        {
            Admin = 0,
            Marcom = 1,
            Operations = 2
        }

        #endregion

        /// <summary>
        /// Gets a Inverted DataTable
        /// </summary>
        /// <param name="table">Provided DataTable</param>
        /// <param name="columnX">X Axis Column</param>
        /// <param name="columnY">Y Axis Column</param>
        /// <param name="columnZ">Z Axis Column (values)</param>
        /// <param name="columnsToIgnore">Whether to ignore some column, it must be 
        /// provided here</param>
        /// <param name="nullValue">null Values to be filled</param> 
        /// <returns>C# Pivot Table Method  - Felipe Sabino</returns>
        public static DataTable GetInversedDataTable(DataTable table, string columnX,
             string columnY, string columnZ, string nullValue, bool sumValues)
        {
            //Create a DataTable to Return
            DataTable returnTable = new DataTable();

            if (columnX == "")
                columnX = table.Columns[0].ColumnName;

            //Add a Column at the beginning of the table
            returnTable.Columns.Add(columnY);


            //Read all DISTINCT values from columnX Column in the provided DataTale
            List<string> columnXValues = new List<string>();

            foreach (DataRow dr in table.Rows)
            {

                string columnXTemp = dr[columnX].ToString();
                if (!columnXValues.Contains(columnXTemp))
                {
                    //Read each row value, if it's different from others provided, add to 
                    //the list of values and creates a new Column with its value.
                    columnXValues.Add(columnXTemp);
                    returnTable.Columns.Add(columnXTemp);
                }
            }

            //Verify if Y and Z Axis columns re provided
            if (columnY != "" && columnZ != "")
            {
                //Read DISTINCT Values for Y Axis Column
                List<string> columnYValues = new List<string>();

                foreach (DataRow dr in table.Rows)
                {
                    if (!columnYValues.Contains(dr[columnY].ToString()))
                        columnYValues.Add(dr[columnY].ToString());
                }

                //Loop all Column Y Distinct Value
                foreach (string columnYValue in columnYValues)
                {
                    //Creates a new Row
                    DataRow drReturn = returnTable.NewRow();
                    drReturn[0] = columnYValue;
                    //foreach column Y value, The rows are selected distincted
                    DataRow[] rows = table.Select(columnY + "='" + columnYValue + "'");

                    //Read each row to fill the DataTable
                    foreach (DataRow dr in rows)
                    {
                        string rowColumnTitle = dr[columnX].ToString();

                        //Read each column to fill the DataTable
                        foreach (DataColumn dc in returnTable.Columns)
                        {
                            if (dc.ColumnName == rowColumnTitle)
                            {
                                //If Sum of Values is True it try to perform a Sum
                                //If sum is not possible due to value types, the value 
                                // displayed is the last one read
                                if (sumValues)
                                {
                                    try
                                    {
                                        drReturn[rowColumnTitle] =
                                             Convert.ToDecimal(drReturn[rowColumnTitle]) +
                                             Convert.ToDecimal(dr[columnZ]);
                                    }
                                    catch
                                    {
                                        drReturn[rowColumnTitle] = dr[columnZ];
                                    }
                                }
                                else
                                {
                                    drReturn[rowColumnTitle] = dr[columnZ];
                                }
                            }
                        }
                    }
                    returnTable.Rows.Add(drReturn);
                }
            }
            else
            {
                throw new Exception("The columns to perform inversion are not provided");
            }

            //if a nullValue is provided, fill the datable with it
            if (nullValue != "")
            {
                foreach (DataRow dr in returnTable.Rows)
                {
                    foreach (DataColumn dc in returnTable.Columns)
                    {
                        if (dr[dc.ColumnName].ToString() == "")
                            dr[dc.ColumnName] = nullValue;
                    }
                }
            }

            return returnTable;
        }

        private static OAccount findAccount(string[] list)
        {
            string parentID = "";
            OAccount account;

            for (int i = 0; i < list.Length; i++)
            {
                string strBudgetAccount = list[i].Trim();

                if (parentID != null && parentID.ToString() != string.Empty)
                {
                    if (i == list.Length - 1)
                        account = TablesLogic.tAccount.Load(
                                    TablesLogic.tAccount.ObjectName == strBudgetAccount &
                                    TablesLogic.tAccount.ParentID == new Guid(parentID) &
                                    TablesLogic.tAccount.Type == 1 &
                                    TablesLogic.tAccount.IsDeleted == 0);
                    else
                        account = TablesLogic.tAccount.Load(
                                TablesLogic.tAccount.ObjectName == strBudgetAccount &
                                TablesLogic.tAccount.ParentID == new Guid(parentID) &
                                TablesLogic.tAccount.Type == 0 &
                                TablesLogic.tAccount.IsDeleted == 0);
                }
                else
                {
                    if (i == list.Length - 1)
                        account = TablesLogic.tAccount.Load(
                                    TablesLogic.tAccount.ObjectName == strBudgetAccount &
                                    TablesLogic.tAccount.ParentID == null &
                                    TablesLogic.tAccount.Type == 1 &
                                    TablesLogic.tAccount.IsDeleted == 0);
                    else
                        account = TablesLogic.tAccount.Load(
                                    TablesLogic.tAccount.ObjectName == strBudgetAccount &
                                    TablesLogic.tAccount.ParentID == null &
                                    TablesLogic.tAccount.Type == 0 &
                                    TablesLogic.tAccount.IsDeleted == 0);
                }
                if (account == null)
                    throw new Exception("Account '" + strBudgetAccount + "' does not exist");
                else if (i == list.Length - 1)
                    return account;

                parentID = account.ObjectID.ToString();
            }

            return null;
        }
    }


}
