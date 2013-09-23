using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using Anacle.DataFramework;
using LogicLayer;

namespace DataMigration.Logic
{
    public class CheckListHandler : Migratable
    {
        public CheckListHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        { }

        public CheckListHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }


        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportCheckLists(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public void ImportCheckLists(DataTable table)
        {
            foreach (DataRow dr in table.Rows)
            {
                try
                {
                    string checklistName = ConvertToString(dr[map["ChecklistName"]]);
                    string physicalChecklistType = ConvertToString(dr[map["PhysicalChecklistType"]]);
                    string stepNumber = ConvertToString(dr[map["StepNumber"]]);
                    string stepDescription = ConvertToString(dr[map["StepDescription"]]);
                    string checklistResponseSet = ConvertToString(dr[map["ChecklistResponseSet"]]);
                    string checklistItemType = ConvertToString(dr[map["ChecklistItemType"]]);
                    string[] list = null;
                    string parentID = "";
                    OChecklist checklist;


                    if (checklistName == null || checklistName.Trim().Length == 0)
                        throw new Exception("Checklist Name is blank.");

                    if (physicalChecklistType == null || physicalChecklistType.Trim().Length == 0)
                        throw new Exception("Invalid Physical Checklist");




                    list = checklistName.Trim(',').Split(',');
                    for (int i = 0; i < list.Length; i++)
                    {
                        string strChecklistName = list[i].Trim();
                        if (parentID != null && parentID.ToString() != string.Empty)
                        {
                            checklist = TablesLogic.tChecklist.Load(
                                            TablesLogic.tChecklist.ObjectName == strChecklistName &
                                            TablesLogic.tChecklist.ParentID == new Guid(parentID) &
                                            TablesLogic.tChecklist.IsDeleted == 0);
                        }
                        else
                        {
                            checklist = TablesLogic.tChecklist.Load(
                                            TablesLogic.tChecklist.ObjectName == strChecklistName &
                                            TablesLogic.tChecklist.ParentID == null &
                                            TablesLogic.tChecklist.IsDeleted == 0);
                        }

                        if (checklist == null && i != list.Length - 1)
                            throw new Exception("Checklist Folder '" + strChecklistName + "' not exist");
                        else if (i == list.Length - 1)
                        {


                            if (physicalChecklistType.ToUpper() == "NO" || physicalChecklistType.ToUpper() == "N")
                            {
                                if (checklist == null)
                                {
                                    checklist = TablesLogic.tChecklist.Create();
                                    checklist.ObjectName = strChecklistName.Trim();
                                    if (parentID != null && parentID.ToString() != string.Empty)
                                        checklist.ParentID = new Guid(parentID);
                                }
                                checklist.IsChecklist = 0;
                                SaveObject(checklist);
                                ActivateObject(checklist);

                            }
                            else if (physicalChecklistType.ToUpper() == "YES" || physicalChecklistType.ToUpper() == "Y")
                            {
                                if (stepNumber == null || stepNumber.Trim().Length == 0)
                                    throw new Exception("Step Number is blank");

                                if (stepDescription == null || stepDescription.Trim().Length == 0)
                                    throw new Exception("Step Description is blank.");

                                if (checklistItemType == null || checklistItemType.Trim().Length == 0)
                                    throw new Exception("Checklist Item Type is blank");

                                if (checklistItemType == "CHOICE" &&
                                (checklistResponseSet == null || checklistResponseSet.Trim().Length == 0))
                                    throw new Exception("Checklist Response set is blank.");
                                if (checklist == null)
                                {
                                    checklist = TablesLogic.tChecklist.Create();
                                    checklist.ObjectName = strChecklistName.Trim();
                                    if (parentID != null && parentID.ToString() != string.Empty)
                                        checklist.ParentID = new Guid(parentID);
                                }

                                checklist.IsChecklist = 1;
                                checklist.Type = 0;
                                SaveObject(checklist);
                                ActivateObject(checklist);
                                importChecklistItem(checklist.ObjectID, Convert.ToInt16(stepNumber), stepDescription, checklistItemType.Trim(), checklistResponseSet==null ? null : checklistResponseSet.Trim());


                            }
                        }
                        parentID = checklist.ObjectID.ToString();
                    }
                }
                catch (Exception ex)
                {
                    dr[ERROR_MSG_COL] = ex.Message;
                }
            }
        }

        public void importChecklistItem(Guid? checklistID, int stepNumber, string stepDescription, string checklistType, string responseSet)
        {
            OChecklistItem checklistItem;
            OChecklistResponseSet checklistResponseSet;
            checklistItem = TablesLogic.tChecklistItem.Load(
                                TablesLogic.tChecklistItem.ChecklistID == checklistID &
                                TablesLogic.tChecklistItem.StepNumber == stepNumber);

            if (checklistItem == null)
            {
                checklistItem = TablesLogic.tChecklistItem.Create();
                checklistItem.ChecklistID = checklistID;
                checklistItem.StepNumber = stepNumber;
            }
            checklistItem.ObjectName = stepDescription.Trim();
            checklistItem.ChecklistType = 0;

            if (checklistType.ToUpper() == "CHOICE")
                checklistItem.ChecklistType = 0;
            else if (checklistType.ToUpper() == "REMARK")
                checklistItem.ChecklistType = 1;
            else if (checklistType.ToUpper() == "NONE")
                checklistItem.ChecklistType = 2;

            if (checklistItem.ChecklistType == 0)
            {
                checklistResponseSet = TablesLogic.tChecklistResponseSet.Load(TablesLogic.tChecklistResponseSet.ObjectName == responseSet);
                if (checklistResponseSet != null)
                {
                    checklistItem.ChecklistResponseSetID = checklistResponseSet.ObjectID;
                }
                else
                {
                    checklistResponseSet = TablesLogic.tChecklistResponseSet.Create();
                    checklistResponseSet.ObjectName = responseSet;
                    SaveObject(checklistResponseSet);
                    ActivateObject(checklistResponseSet);
                    checklistItem.ChecklistResponseSetID = checklistResponseSet.ObjectID;
                }


            }
            SaveObject(checklistItem);
            ActivateObject(checklistItem);


        }

        public Guid? CreateResponseSet(string responseSet)
        {
            if (String.IsNullOrEmpty(responseSet.Trim()))
            {
                throw new ApplicationException("No repsonseset specified,please add it manually.");
            }

            OChecklistResponseSet chklstResponseSet = TablesLogic.tChecklistResponseSet.Load(TablesLogic.tChecklistResponseSet.ObjectName == responseSet);

            if (chklstResponseSet != null)
            {
                ActivateObject(chklstResponseSet);
            }
            else
            {
                chklstResponseSet = TablesLogic.tChecklistResponseSet.Create();

                chklstResponseSet.ObjectName = responseSet.Trim();

                SaveObject(chklstResponseSet);
            }

            string[] items = responseSet.Split('/');

            //add OChecklistResponse
            for (int i = 0; i < items.Length; i++)
            {
                OChecklistResponse response = TablesLogic.tChecklistResponse.Load(TablesLogic.tChecklistResponse.ObjectName == items[i] & TablesLogic.tChecklistResponse.ChecklistResponseSetID == chklstResponseSet.ObjectID);

                if (response == null)
                {
                    response = TablesLogic.tChecklistResponse.Create();

                    response.ObjectName = items[i];
                    response.ChecklistResponseSetID = chklstResponseSet.ObjectID;

                    SaveObject(response);
                }
                else
                {
                    ActivateObject(response);
                }
            }

            return chklstResponseSet.ObjectID;
        }
    }
}
