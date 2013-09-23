//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for TCustomer
    /// </summary>
    public partial class TCustomerAccountRegistration : LogicLayerSchema<OCustomerAccountRegistration>
    {
        // customer information
        public SchemaString CMND;
        public SchemaString CustomerName;
        public SchemaDateTime CustomerDateOfBirth;
        [Size(255)]
        public SchemaString CustomerAddress;
        // public TCustomerAccount CustomerAccounts { get { return OneToMany<TCustomerAccount>("CustomerID"); } }
        // account information
        public SchemaString AccountNumber;
        public SchemaDecimal Deposit;
        public SchemaDecimal Equity;
        public SchemaGuid IBID;
        public TUser IB { get { return OneToOne<TUser>("IBID"); } }
        public SchemaGuid CustomerID;
        public TCustomer Customer { get { return OneToOne<TCustomer>("CustomerID"); } }
        public SchemaGuid CustomerAccountID;
        public TCustomerAccount CustomerAccount { get { return OneToOne<TCustomerAccount>("CustomerAccountID"); } }
    }

    /// <summary>
    /// Summary description for OCustomer
    /// </summary>
    public abstract partial class OCustomerAccountRegistration : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        //customer information
        public abstract string CMND { get; set; }
        public abstract string CustomerName { get; set; }
        public abstract DateTime? CustomerDateOfBirth { get; set; }
        public abstract string CustomerAddress { get; set; }
        // public abstract DataList<OCustomerAccount> CustomerAccounts { get; set; }
        // account information
        public abstract string AccountNumber { get; set; }
        public abstract decimal? Deposit { get; set; }
        public abstract decimal? Equity { get; set; }
        public abstract Guid? IBID { get; set; }
        public abstract OUser IB { get; set; }
        public abstract Guid? CustomerID { get; set; }
        public abstract OCustomer Customer { get; set; }
        public abstract Guid? CustomerAccountID { get; set; }
        public abstract OCustomerAccount CustomerAccount { get; set; }
        public List<OUser> GetIB()
        {
            List<OUser> usr = TablesLogic.tUser.LoadList(TablesLogic.tUser.ObjectID == IBID);
            if (usr != null) return usr;
            else return TablesLogic.tUser.LoadList(TablesLogic.tUser.UserBase.LoginName == "sa");
        }
        public List<OUser> AssignUserForApproved()
        {
            List<OUser> usrs = OUser.GetUsersByRole("IBADMIN");
            if (usrs != null) return usrs;
            else return TablesLogic.tUser.Load(TablesLogic.tUser.UserBase.LoginName == "sa");
        }
        /// <summary>
        /// inform IB via email / sms and create User Account
        /// </summary>
        public void Approve()
        {
            using (Connection c = new Connection())
            {
                if (this.IB != null && this.IBID != Workflow.CurrentUser.ObjectID)
                {
                    //send email to user
                    // create customer (if needed) and account
                    OCustomer cust = TablesLogic.tCustomer.Load(TablesLogic.tCustomer.CMND == this.CMND);
                    if (cust == null)
                    {
                        cust = TablesLogic.tCustomer.Create();
                        cust.CMND = this.CMND;
                        cust.CustomerName = this.CustomerName;
                        //cust.CustomerDateOfBirth = this.CustomerDateOfBirth;
                        cust.CustomerAddress = this.CustomerAddress;
                    }
                    OCustomerAccount ca = TablesLogic.tCustomerAccount.Create();
                    ca.AccountNumber = this.AccountNumber;
                    ca.Deposit = this.Deposit;
                    //ca.Equity = this.Deposit;
                    ca.CustomerID = cust.ObjectID;
                    cust.CustomerAccounts.Add(ca);
                    cust.Save();
                    ca.Save();
                }
            }
        }
        /// <summary>
        /// inform IB via email / sms
        /// </summary>
        public void Rejected()
        {
        }
        /// <summary>
        /// inform IBADMIN for approval
        /// </summary>
        public void SubmitForApproval()
        {
        }
        /// <summary>
        /// 
        /// </summary>
        public void Cancel()
        {
        }
        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public List<OUser> AssignUserAtCancelState()
        {
            List<OUser> usr = TablesLogic.tUser.LoadList(TablesLogic.tUser.ObjectID == IBID);
            if (usr != null) return usr;
            else return TablesLogic.tUser.LoadList(TablesLogic.tUser.UserBase.LoginName == "sa");
        }
    }
}

