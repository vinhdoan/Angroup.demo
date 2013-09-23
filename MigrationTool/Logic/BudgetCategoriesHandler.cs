using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using Anacle.DataFramework;
using LogicLayer;

namespace DataMigration.Logic
{
    public class BudgetCategoriesHandler : Migratable
    {
        public BudgetCategoriesHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        { }

        public BudgetCategoriesHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportBudgetCategoriesHandler(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        //migrate both budget category (type = 0) and budget line item, which is budget category with type = 1
        private void ImportBudgetCategoriesHandler(DataTable table)
        {
            /*
            foreach (DataRow dr in table.Rows)
            {
                try
                {
                    string budgetCategoryL1 = ConvertToString(dr[map["Budget Category Group L1*"]]);
                    string budgetCategoryL2 = dr[map["Budget Category Group L2(Optional)"]].ToString() == string.Empty ? "" : 
                        ConvertToString(dr[map["Budget Category Group L2(Optional)"]]);
                    string budgetCategoryL3 = dr[map["Budget Category Group L3(Optional)"]].ToString() == string.Empty ? "" : 
                        ConvertToString(dr[map["Budget Category Group L3(Optional)"]]);
                    string budgetCategoryL4 = dr[map["Budget Category Group L4(Optional)"]].ToString() == string.Empty ? "" : 
                        ConvertToString(dr[map["Budget Category Group L4(Optional)"]]);
                    string budgetLineItem = ConvertToString(dr[map["Budget Line Item*"]]);
                    string accountCode = ConvertToString(dr[map["Account Code"]]);
                    string costCenter = ConvertToString(dr[map["Cost Center"]]);
                    string projectID = ConvertToString(dr[map["Project ID"]]);

                    string parent = "";

                    if (budgetCategoryL1 == string.Empty || budgetLineItem == string.Empty)
                        throw new Exception("Budget Category Name / Budget Line Item can not be empty");

                    OBudgetCategory categoryL1 = TablesLogic.tAccount.Load(
                        TablesLogic.tAccount.ObjectName == budgetCategoryL1 &
                        TablesLogic.tAccount.Type == 0 &
                        TablesLogic.tAccount.IsDeleted == 0);

                    OBudgetCategory categoryL2 = null;
                    if (budgetCategoryL2 != "")
                    {
                        categoryL2 = TablesLogic.tAccount.Load(
                            TablesLogic.tAccount.ObjectName == budgetCategoryL2 &
                            TablesLogic.tAccount.Type == 0 &
                            TablesLogic.tAccount.IsDeleted == 0);
                    }

                    OBudgetCategory categoryL3 = null;
                    if (budgetCategoryL3 != "")
                    {
                        categoryL3 = TablesLogic.tAccount.Load(
                            TablesLogic.tAccount.ObjectName == budgetCategoryL3 &
                            TablesLogic.tAccount.Type == 0 &
                            TablesLogic.tAccount.IsDeleted == 0);
                    }

                    OBudgetCategory categoryL4 = null;
                    if (budgetCategoryL4 != "")
                    {
                        categoryL4 = TablesLogic.tAccount.Load(
                            TablesLogic.tAccount.ObjectName == budgetCategoryL4 &
                            TablesLogic.tAccount.Type == 0 &
                            TablesLogic.tAccount.IsDeleted == 0);
                    }
                    

                    if (categoryL1 == null)
                    {
                        categoryL1 = TablesLogic.tAccount.Create();
                        categoryL1.ObjectName = budgetCategoryL1;
                        categoryL1.Type = 0;
                    }
                    parent = categoryL1.ObjectID.ToString();

                    if (budgetCategoryL2 != "" && categoryL2 == null)
                    {
                        categoryL2 = TablesLogic.tAccount.Create();
                        categoryL2.ObjectName = budgetCategoryL2;
                        categoryL2.Type = 0;
                        categoryL2.ParentID = categoryL1.ObjectID;
                    }
                    parent = categoryL2 == null ? parent : categoryL2.ObjectID.ToString();

                    if (budgetCategoryL3 != "" && categoryL3 == null)
                    {
                        categoryL3 = TablesLogic.tAccount.Create();
                        categoryL3.ObjectName = budgetCategoryL3;
                        categoryL3.Type = 0;
                        categoryL3.ParentID = categoryL2.ObjectID;
                    }
                    parent = categoryL3 == null ? parent : categoryL3.ObjectID.ToString();

                    if (budgetCategoryL4 != "" && categoryL4 == null)
                    {
                        categoryL4 = TablesLogic.tAccount.Create();
                        categoryL4.ObjectName = budgetCategoryL4;
                        categoryL4.Type = 0;
                        categoryL4.ParentID = categoryL3.ObjectID;
                    }
                    parent = categoryL4 == null ? parent : categoryL4.ObjectID.ToString();

                    OBudgetCategory item = TablesLogic.tAccount.Load(
                        TablesLogic.tAccount.ObjectName == budgetLineItem &
                        TablesLogic.tAccount.Type == 1 &
                        TablesLogic.tAccount.ParentID == new Guid(parent) &
                        TablesLogic.tAccount.IsDeleted == 0);

                    if (item == null)
                    {
                        item = TablesLogic.tAccount.Create();
                        item.ObjectName = budgetLineItem;
                        item.Type = 1; 
                    }

                    //item.ParentID = categoryL4 != null ? categoryL4.ObjectID :
                    //    categoryL3 != null ? categoryL3.ObjectID :
                    //    categoryL2 != null ? categoryL2.ObjectID : categoryL1.ObjectID;

                    if(item.ParentID != new Guid(parent))
                    {
                        item = TablesLogic.tAccount.Create();
                        item.ObjectName = budgetLineItem;
                        item.Type = 1;
                        item.ParentID = new Guid(parent);
                    }
                    item.AccountCode = accountCode;
                    item.CostCenter = costCenter;
                    item.ProjectID = projectID;
                    
                    SaveObject(categoryL1);
                    ActivateObject(categoryL1);
                    SaveObject(item);
                    ActivateObject(item);
                    if (categoryL2 != null)
                    {
                        SaveObject(categoryL2);
                        ActivateObject(categoryL2);
                    }
                    if (categoryL3 != null)
                    {
                        SaveObject(categoryL3);
                        ActivateObject(categoryL3);
                    }
                    if (categoryL4 != null)
                    {
                        SaveObject(categoryL4);
                        ActivateObject(categoryL4);
                    }
                }
                catch (Exception ex)
                {
                    dr[ERROR_MSG_COL] = ex.Message;
                }
            }*/

        }
    }
}