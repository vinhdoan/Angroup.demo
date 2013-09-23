//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;
using System.Collections;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OAccount
    /// </summary>
    public partial class TAccount : LogicLayerSchema<OAccount>
    {
        [Default(0)]
        public SchemaInt Type;
        [Size(50)]
        public SchemaString AccountCode;
        [Size(255)]
        public SchemaString Description;

        public SchemaInt AllowsBudgeting;

        public TAccount Parent { get { return OneToOne<TAccount>("ParentID"); } }

    }


    /// <summary>
    /// Represents a financial account 
    /// </summary>
    [Serializable]
    public abstract partial class OAccount : LogicLayerPersistentObject, IHierarchy
    {
        /// <summary>
        /// [Column] Gets or sets the type of account.
        /// <list>
        ///     <item>0 - Category </item>\
        ///     <item>1 - Line Item </item>
        /// </list>
        /// </summary>
        public abstract int? Type { get; set; }

        /// <summary>
        /// [Column] Gets or sets the financial account code
        /// for this account.
        /// </summary>
        public abstract string AccountCode { get; set; }

        /// <summary>
        /// [Column] Gets or sets the description 
        /// for this account.
        /// </summary>
        public abstract string Description { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating
        /// whether a budget can be created against
        /// this account.
        /// </summary>
        public abstract int? AllowsBudgeting { get; set; }

        /// <summary>
        /// [One-to-one join] Gets a reference to the
        /// OAccount object representing the parent
        /// category of this account.
        /// </summary>
        public abstract OAccount Parent { get; }


        /// <summary>
        /// Gets the type name of this 
        /// </summary>
        /// <returns>string</returns>
        public string TypeText
        {
            get
            {
                switch (this.Type.Value)
                {
                    case 0: return Resources.Strings.Account_Group;
                    case 1: return Resources.Strings.Account_LineItem;
                }
                return "";
            }
        }

        /// <summary>
        /// Gets the text indicating whether a budget
        /// can be created against this account.
        /// </summary>
        public string AllowsBudgetingText
        {
            get
            {
                if (AllowsBudgeting == 0)
                    return Resources.Strings.General_No;
                else if (AllowsBudgeting == 1)
                    return Resources.Strings.General_No;
                return "";
            }
        }


        /// <summary>
        /// Tests if the object's parent is a cyclical reference back
        /// to itself.
        /// </summary>
        /// <returns></returns>
        public bool IsCyclicalReference()
        {
            OAccount cat = this;
            while (true)
            {
                cat = cat.Parent;
                if (cat == null)
                    return false;
                if (cat.ObjectID == this.ObjectID)
                    return true;
            }
        }


        /// <summary>
        /// Gets a list of accounts that match the
        /// search criteria.
        /// </summary>
        /// <param name="value"></param>
        /// <returns>List:OAccount</returns>
        public static List<OAccount> FindAccounts(string value)
        {
            return TablesLogic.tAccount.LoadList(
                TablesLogic.tAccount.ObjectName.Like("%" + value + "%"),
                TablesLogic.tAccount.Type.Asc,
                TablesLogic.tAccount.ObjectName.Asc);
        }


        /// <summary>
        /// Returns false if: 
        /// <list>
        ///     <item>1. The number of children accounts below this one is greater than 0.</item>
        /// </list>
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            // Ensure no children accounts.
            //
            int count = TablesLogic.tAccount.Select(
                TablesLogic.tAccount.ObjectID.Count())
                .Where(
                // 2010.07.10
                // Kim Foong
                // Bug fix to exclude this current account from the search.
                TablesLogic.tAccount.ObjectID != this.ObjectID &
                TablesLogic.tAccount.IsDeleted == 0 &
                TablesLogic.tAccount.HierarchyPath.Like(this.HierarchyPath + "%"));
            if (count > 0)
                return false;

            // Ensure that the account has not been included in any budget periods'
            // opening balance.
            //
            count = TablesLogic.tBudgetPeriodOpeningBalance.Select(
                TablesLogic.tBudgetPeriodOpeningBalance.ObjectID.Count())
                .Where(
                TablesLogic.tBudgetPeriodOpeningBalance.IsDeleted == 0 &
                TablesLogic.tBudgetPeriodOpeningBalance.AccountID == this.ObjectID &
                TablesLogic.tBudgetPeriodOpeningBalance.BudgetPeriodID != null);
            if (count > 0)
                return false;

            return true;
        }


        /// <summary>
        /// Moves a list of accounts specified in the accountIds
        /// parameter under an account specified by moveToAccountId.
        /// When complete, it returns the number of accounts that
        /// cannot be moved successfully due to cyclical references.
        /// </summary>
        /// <param name="accountIds"></param>
        /// <param name="moveToAccountId"></param>
        public static void MoveAccounts(List<object> accountIds, Guid moveToAccountId, ref int cyclicalCount, ref int count)
        {
            cyclicalCount = 0;
            count = 0;
            using (Connection c = new Connection())
            {
                foreach (Guid id in accountIds)
                {
                    OAccount account = TablesLogic.tAccount.Load(id);

                    account.ParentID = moveToAccountId;
                    if (account.IsCyclicalReference())
                        cyclicalCount++;
                    else
                    {
                        count++;
                        account.Save();
                    }
                }
                c.Commit();
            }
        }

        /// <summary>
        /// Extract AccountID from Account hierachy string
        /// 20120119 bug fix ptb
        /// Only accept lineitem
        /// </summary>
        /// <param name="path"></param>
        /// <returns>Guid</returns>
        public static Guid GetAccountByPath(String path, bool IsLineItem)
        {
            String[] strList = path.Split('>');
            for (int i = 0; i < strList.Length; i++)
                strList[i] = strList[i].Trim();
            int accLevel = strList.Length - 1;
            List<OAccount> accList = new List<OAccount>();

            if (IsLineItem)
                accList = TablesLogic.tAccount.LoadList(TablesLogic.tAccount.ObjectName == strList[accLevel]
                    & TablesLogic.tAccount.Type == 1);
            else
                accList = TablesLogic.tAccount.LoadList(TablesLogic.tAccount.ObjectName == strList[accLevel]);
            if (accList.Count == 1)
                return (Guid)accList[0].ObjectID;
            else
            {
                foreach (OAccount acc in accList)
                    if (IsAccountInList(acc, strList, accLevel))
                        return (Guid)acc.ObjectID;
                return Guid.Empty;
            }
        }


        /// <summary>
        /// Extract AccountID from Account hierachy string
        /// </summary>
        /// <param name="path"></param>
        /// <returns>Guid</returns>
        public static Guid GetAccountByPath(String path)
        {
            return GetAccountByPath(path, false);
        }

        /// <summary>
        /// Check if the Account in the hierachy string
        /// </summary>
        /// <param name="loc"></param>
        /// <param name="strList"></param>
        /// <param name="locLevel"></param>
        /// <returns>Boolean</returns>
        private static Boolean IsAccountInList(OAccount acc, String[] strList, int accLevel)
        {
            // recersive call to check if the Account name is in the list, start from bottom level
            // accLevel 0 is the top level of Account tree
            if (accLevel == 0)
                return acc.ObjectName == strList[accLevel];
            if (acc.Parent.ObjectName != strList[accLevel - 1])
                return false;
            else
                return IsAccountInList(acc.Parent, strList, accLevel - 1);
        }
    }
}
