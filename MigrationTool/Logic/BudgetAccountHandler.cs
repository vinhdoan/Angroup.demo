using System;
using System.Collections.Generic;
using System.Text;
using System.Data;

using LogicLayer;

namespace DataMigration.Logic
{
    public class BudgetAccountHandler : Migratable
    {
        public BudgetAccountHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        { }

        public BudgetAccountHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportBudgetAccountHandler(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, this.Map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void ImportBudgetAccountHandler(DataTable table)
        {
            foreach (DataRow dr in table.Rows)
            {
                try
                {
                    string BudgetAccount = ConvertToString(dr[map["BudgetAccount"]]);
                    //string GroupName = ConvertToString(dr[map["GroupName"]]);
                    string AccountType = ConvertToString(dr[map["AccountType"]]);
                    string AccountCode = ConvertToString(dr[map["AccountCode"]]);
                    string Description = ConvertToString(dr[map["Description"]]);
                    string parentID = "";

                    OAccount account;

                    if (BudgetAccount == null || BudgetAccount.Trim().Length == 0)
                        throw new Exception("Budget Account is blank.");


                    string[] list = BudgetAccount.Trim('>').Split('>');
                    OAccountType AccountTypeSearch = null;
                    if(AccountType != null)
                        AccountTypeSearch  = TablesLogic.tAccountType.Load(TablesLogic.tAccountType.ObjectName == AccountType.Trim() &
                                                                                   TablesLogic.tAccountType.IsDeleted == 0);

                    //if (AccountTypeSearch == null)
                    //    throw new Exception("This Location Type does not exist");

                    string msg = "";
                    for (int i = 0; i < list.Length; i++)
                    {
                        string strBudgetAccount = list[i].Trim();

                        if (parentID != null && parentID.ToString() != string.Empty)
                        {
                            account = TablesLogic.tAccount.Load(
                                        TablesLogic.tAccount.ObjectName == strBudgetAccount &
                                        TablesLogic.tAccount.ParentID == new Guid(parentID) &
                                        TablesLogic.tAccount.IsDeleted == 0);
                        }
                        else
                        {
                            account = TablesLogic.tAccount.Load(
                                        TablesLogic.tAccount.ObjectName == strBudgetAccount &
                                        TablesLogic.tAccount.ParentID == null &
                                        TablesLogic.tAccount.IsDeleted == 0);
                        }
                        //if (account == null && i != list.Length - 1)
                        //    //throw new Exception("Account '" + strBudgetAccount + "' does not exist");
                        //else if (i == list.Length - 1)
                        //{

                            if (account == null)
                            {
                                account = TablesLogic.tAccount.Create();
                                account.ObjectName = strBudgetAccount;
                                if (parentID != null && parentID.ToString() != string.Empty)
                                    account.ParentID = new Guid(parentID);
                                

                                if (i + 1 == list.Length)
                                {
                                    if (AccountTypeSearch != null)
                                        account.AccountTypeID = AccountTypeSearch.ObjectID;
                                    account.Description = Description;
                                    account.AccountCode = AccountCode;
                                    //account.ReallocationGroupName = GroupName;
                                    account.AppliesToAllPurchaseTypes = 1;
                                    account.Type = 1;
                                }
                                else
                                    account.Type = 0;

                                SaveObject(account);
                                ActivateObject(account);
                                msg = "Created!";
                                
                            }
                            else
                            {
                                account.ObjectName = strBudgetAccount;
                                if (i + 1 == list.Length)
                                {
                                    if (AccountTypeSearch != null)
                                        account.AccountTypeID = AccountTypeSearch.ObjectID;
                                    account.Description = Description;
                                    account.AccountCode = AccountCode;
                                    //account.ReallocationGroupName = GroupName;
                                    account.AppliesToAllPurchaseTypes = 1;
                                    account.Type = 1;
                                }
                                else
                                    account.Type = 0;

                                SaveObject(account);
                                ActivateObject(account);
                                msg = "updated!!";
                            }

                            
                        //}
                        parentID = account.ObjectID.ToString();  
                    }
                    throw new Exception(msg);

                }

                catch (Exception ex)
                {
                    dr[ERROR_MSG_COL] = ex.Message;
                }
            }
        }


    }
}