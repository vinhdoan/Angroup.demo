using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using Anacle.DataFramework;
using DataMigration.Infrastructure;
using LogicLayer;


namespace DataMigration.Logic
{
    public class TransationHistoryHandler : Migratable
    {
        public TransationHistoryHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        { }

        public TransationHistoryHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        { }

        #region Migratable

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportStores(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void ImportStores(DataTable transactionTable)
        {
            int count = 0;
            foreach (DataRow dr in transactionTable.Rows)
            {
                try
                {
                    count++;
                    string AccountNumber = ConvertToString(dr[Map["Account Number"]]);
                    int Ticket = Convert.ToInt32(dr[Map["Ticket"]]);
                    DateTime OpenTime = Convert.ToDateTime(dr[Map["Open Time"]]);
                    string Type = ConvertToString(dr[Map["Type"]]);
                    decimal Size = Convert.ToDecimal(dr[Map["Size"]]);
                    string Item = ConvertToString(dr[Map["Item"]]);
                    decimal OpenPrice = Convert.ToDecimal(dr[Map["Price"]]);
                    decimal StopLoss = Convert.ToDecimal(dr[Map["S / L"]]);
                   
                    decimal TakeProfit = Convert.ToDecimal(dr[Map["T / P"]]);
                    DateTime CloseTime = Convert.ToDateTime(dr[Map["Close Time"]]);
                    decimal ClosePrice = Convert.ToDecimal(dr[Map["Price1"]]);
                    decimal Comission = Convert.ToDecimal(dr[Map["Commission"]]);
                    decimal Tax = Convert.ToDecimal(dr[Map["Taxes"]]);
                    decimal Swap = Convert.ToDecimal(dr[Map["Swap"]]);
                    decimal Profit = Convert.ToDecimal(dr[Map["Profit"]]);
                    if (AccountNumber == null || Ticket == null || (!Type.ToLower().Is("buy","sell"))) continue;
                    //OTransactionHistory transaction = CreateTransaction(storeName, locationName, bins, null);
                    OCustomerAccount custacc = TablesLogic.tCustomerAccount.Load(TablesLogic.tCustomerAccount.AccountNumber == AccountNumber);
                    if (custacc != null)
                    {
                        OTransactionHistory trans = TablesLogic.tTransactionHistory.Load(TablesLogic.tTransactionHistory.Ticket == Ticket);
                        if (trans == null)
                        {
                            using (Connection c = new Connection())
                            {
                                trans = TablesLogic.tTransactionHistory.Create();
                                trans.ItemNumber = count;
                                trans.CustomerAccountID = custacc.ObjectID;
                                trans.Ticket = Ticket;
                                trans.OpenTime = OpenTime;
                                if (Type.Is("sell")) trans.Type = OTransactionHistory.TransactionHistoryType.Sell;
                                else if (Type.Is("buy")) trans.Type = OTransactionHistory.TransactionHistoryType.Buy;
                                trans.OpenPrice = OpenPrice;
                                trans.StopLoss = StopLoss;
                                trans.TakeProfit = TakeProfit;
                                trans.CloseTime = CloseTime;
                                trans.ClosePrice = ClosePrice;
                                trans.Commission = Comission;
                                trans.Tax = Tax;
                                trans.Swap = Swap;
                                trans.Profit = Profit;
                                trans.Size = Size;
                                OCode item = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == Item);
                                if (item != null) trans.ItemID = item.ObjectID;
                                custacc.TransactionHistories.Add(trans);
                                custacc.Save();
                                c.Commit();
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    dr[ERROR_MSG_COL] = ex.Message;
                }
            }
        }

       

        #endregion Migratable
    }
}