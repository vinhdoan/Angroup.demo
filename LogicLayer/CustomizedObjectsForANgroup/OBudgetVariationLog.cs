using System;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Created by TVO
    /// </summary>
    public partial class TBudgetVariationLog : LogicLayerSchema<OBudgetVariationLog>
    {
        public SchemaGuid RequestForQuotationID;
        public SchemaInt VariationStatus;

        public TBudget Budget { get { return OneToOne<TBudget>("BudgetID"); } }
        public TBudgetPeriod BudgetPeriod { get { return OneToOne<TBudgetPeriod>("BudgetPeriodID"); } }
    }


    /// <summary>
    /// Represents a variation log on the budget.
    /// </summary> 
    public abstract partial class OBudgetVariationLog : LogicLayerPersistentObject
    {        
        /// <summary>
        /// [Column] Gets or sets the foreign key to the 
        /// RequestForQuotation table that indicates the budget
        /// adjustment record that committed this variation.
        /// </summary>
        public abstract Guid? RequestForQuotationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the status of variation.
        /// <list>
        ///     <para>1 - Pending </para>
        ///     <para>2 - Reallocation </para>
        /// </list>
        /// </summary>
        public abstract int? VariationStatus { get; set; }

        public abstract OBudget Budget { get; set; }

        public abstract OBudgetPeriod BudgetPeriod { get; set; }

        /// <summary>
        /// Sets the purchase budget transaction log's transaction types.
        /// </summary>
        /// <param name="purchaseBudgets"></param>
        /// <returns></returns>
        public static List<OBudgetVariationLog> SetBudgetVariationLogsStatusByRequestForQuotationID(
            Guid rfqID, int variationStatus)
        {
            using (Connection c = new Connection())
            {
                List<OBudgetVariationLog> logs = TablesLogic.tBudgetVariationLog.LoadList(
                TablesLogic.tBudgetVariationLog.RequestForQuotationID == rfqID);

                foreach (OBudgetVariationLog log in logs)
                {
                    log.VariationStatus = variationStatus;
                    log.Save();
                }
                c.Commit();

                return logs;
            }
        }

        /// <summary>
        /// Deactivates all budget transactions that belongs
        /// to the specified itemNumber, but it does not
        /// transfer the amount back to the originating
        /// purchase document.
        /// <para></para>
        /// This method is called when (a) an RFQ is rejected
        /// or closed, (b) a PO is rejected or closed, (c)
        /// an Invoice is rejected.
        /// </summary>
        /// <param name="purchaseBudgets"></param>
        /// <param name="itemNumber"></param>
        public static void ClearBudgetVariationLogsByRequestForQuotationID(Guid rfqID)
        {
            List<OBudgetVariationLog> logs = TablesLogic.tBudgetVariationLog.LoadList(
                TablesLogic.tBudgetVariationLog.RequestForQuotationID == rfqID);

            using (Connection c = new Connection())
            {
                // Then deactivate all the logs so that they
                // are no longer committed to the budget.
                //
                foreach (OBudgetVariationLog log in logs)
                {
                    log.VariationAmount = 0;
                    log.Save();
                    log.Deactivate();
                }
                c.Commit();
            }
        }

    }

    /// <summary>
    /// Represents the different staus of transactions.
    /// </summary>
    public class BudgetVariationStatus
    {
        public const int PendingApproval = 1;
        public const int Approved = 0;
    }

}
