//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
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
    /// Summary description for OVendor
    /// </summary>
    [Database("#database"), Map("Contract")]
    public partial class TContract : LogicLayerSchema<OContract>
    {
        [Size(255)]
        public SchemaString Description;
        public SchemaDateTime ContractStartDate;
        public SchemaDateTime ContractEndDate;
        [Size(255)]
        public SchemaString Terms;
        [Size(255)]
        public SchemaString Warranty;
        [Size(255)]
        public SchemaString Insurance;

        public SchemaGuid ContractManagerID;
        public SchemaDecimal ContractSum;
        public SchemaGuid VendorID;
        public SchemaInt ProvideMaintenance;
        public SchemaInt ProvidePricingAgreement;
        public SchemaGuid PurchaseOrderID;

        [Size(255)]
        public SchemaString ContactPerson;
        public SchemaString ContactFax;
        public SchemaString ContactEmail;
        public SchemaString ContactCellphone;
        public SchemaString ContactPhone;

        public SchemaGuid Reminder1UserID;
        public SchemaGuid Reminder2UserID;
        public SchemaGuid Reminder3UserID;
        public SchemaGuid Reminder4UserID;

        public SchemaInt EndReminderDays1;
        public SchemaInt EndReminderDays2;
        public SchemaInt EndReminderDays3;
        public SchemaInt EndReminderDays4;

        public SchemaDateTime LastReminderDate;

        public SchemaGuid RenewedContractID;
        public SchemaGuid SurveyGroupID;

        public TPurchaseOrder PurchaseOrder { get { return OneToOne<TPurchaseOrder>("PurchaseOrderID"); } }
        public TLocation Locations { get { return ManyToMany<TLocation>("ContractLocation", "ContractID", "LocationID"); } }
        public TCode TypeOfServices { get { return ManyToMany<TCode>("ContractTypeOfService", "ContractID", "TypeOfServiceID"); } }
        public TVendor Vendor { get { return OneToOne<TVendor>("VendorID"); } }
        public TScheduledWork ScheduledWorks { get { return OneToMany<TScheduledWork>("ContractID"); } }
        
        public TUser Reminder1User { get { return OneToOne<TUser>("Reminder1UserID"); } }
        public TUser Reminder2User { get { return OneToOne<TUser>("Reminder2UserID"); } }
        public TUser Reminder3User { get { return OneToOne<TUser>("Reminder3UserID"); } }
        public TUser Reminder4User { get { return OneToOne<TUser>("Reminder4UserID"); } }
        public TUser ContractManager { get { return OneToOne<TUser>("ContractManagerID"); } }

        public TSurveyGroup SurveyGroup { get { return OneToOne<TSurveyGroup>("SurveyGroupID"); } }
        public TContractPriceService ContractPriceServices { get { return OneToMany<TContractPriceService>("ContractID"); } }
        public TContractPriceMaterial ContractPriceMaterials { get { return OneToMany<TContractPriceMaterial>("ContractID"); } }
    }


    /// <summary>
    /// Represents a contract between the user's company and the 
    /// vendor providing services to the company. Through this
    /// contract the vendor may provide maintenance works at
    /// no extra cost to the company, or the vendor may provide
    /// a fixed set of rates (purchase agreement) to the company
    /// should the company purchase services or materials from
    /// the vendor in the future through a purchase order.
    /// </summary>
    public abstract partial class OContract : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        /// <summary>
        /// [Column] Gets or sets the description of 
        /// this contract.
        /// </summary>
        public abstract string Description { get; set; }

        /// <summary>
        /// [Column] Gets or sets the start date of the 
        /// contract.
        /// </summary>
        public abstract DateTime? ContractStartDate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the end date of the 
        /// contract.
        /// </summary>
        public abstract DateTime? ContractEndDate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contract sum 
        /// in dollar value.
        /// </summary>
        public abstract decimal? ContractSum { get; set; }

        /// <summary>
        /// [Column] Gets or sets information regarding the 
        /// terms of the contract.
        /// </summary>
        public abstract string Terms { get; set; }

        /// <summary>
        /// [Column] Gets or sets information about the warranty 
        /// of this contract.
        /// </summary>
        public abstract string Warranty { get; set; }

        /// <summary>
        /// [Column] Gets or sets information 
        /// regarding insurance for this contract.
        /// </summary>
        public abstract string Insurance { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to
        /// the User table for the contract manager.
        /// </summary>
        public abstract Guid? ContractManagerID { get; set; }
        /// <summary>
        /// [Column] Gets or sets RenewedContractID
        /// </summary>
        public abstract Guid? RenewedContractID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Vendor
        /// table.
        /// </summary>
        public abstract Guid? VendorID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that 
        /// indicates whether the vendor of this 
        /// contract provides maintenance work. 
        /// If set to 1, this contract can appear 
        /// in the Work module for selection.
        /// </summary>
        public abstract int? ProvideMaintenance { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that 
        /// indicates whether this contract 
        /// specifies a purchase agreement 
        /// between the user and the vendor. If 
        /// set to 1, this contract appears in the 
        /// PurchaseOrder module for selection.
        /// </summary>
        public abstract int? ProvidePricingAgreement { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign
        /// key to the Purchase Order table that represents
        /// the purchase order that is associated this contract.
        /// </summary>
        public abstract Guid? PurchaseOrderID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact person
        /// details.
        /// </summary>
        public abstract string ContactPerson { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact person
        /// details.
        /// </summary>
        public abstract string ContactFax { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact person
        /// details.
        /// </summary>
        public abstract string ContactEmail { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact person
        /// details.
        /// </summary>
        public abstract string ContactCellphone { get; set; }

        /// <summary>
        /// [Column] Gets or sets the contact person
        /// details.
        /// </summary>
        public abstract string ContactPhone { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign 
        /// key to the User table.
        /// </summary>
        public abstract Guid? Reminder1UserID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign 
        /// key to the User table.
        /// </summary>
        public abstract Guid? Reminder2UserID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign 
        /// key to the User table.
        /// </summary>
        public abstract Guid? Reminder3UserID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign 
        /// key to the User table.
        /// </summary>
        public abstract Guid? Reminder4UserID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of 
        /// days left before the end of the 
        /// contract to send out a reminder e-mail.
        /// The user can specify up to 4 periods.
        /// </summary>
        public abstract int? EndReminderDays1 { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of 
        /// days left before the end of the 
        /// contract to send out a reminder e-mail.
        /// The user can specify up to 4 periods.
        /// </summary>
        public abstract int? EndReminderDays2 { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of 
        /// days left before the end of the 
        /// contract to send out a reminder e-mail.
        /// The user can specify up to 4 periods.
        /// </summary>
        public abstract int? EndReminderDays3 { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of 
        /// days left before the end of the 
        /// contract to send out a reminder e-mail.
        /// The user can specify up to 4 periods.
        /// </summary>
        public abstract int? EndReminderDays4 { get; set; }

        /// <summary>
        /// [Column] Gets or sets the last date
        /// that a reminder was sent.
        /// </summary>
        public abstract DateTime? LastReminderDate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key
        /// to the survey group that this contract 
        /// belongs to.
        /// </summary>
        public abstract Guid? SurveyGroupID { get; set; }


        /// <summary>
        /// Gets a reference to the OPurchaseOrder object
        /// that indicates the purchase order that is
        /// associated with this contract.
        /// </summary>
        public abstract OPurchaseOrder PurchaseOrder { get; set; }

        /// <summary>
        /// Gets a many-to-many list of OLocation objects that 
        /// represents the locations that the vendor agrees to 
        /// provide maintenance services for. This is applicable only 
        /// if ProvideMaintenance = 1.
        /// </summary>
        public abstract DataList<OLocation> Locations { get; set; }

        /// <summary>
        /// Gets a many-to-many list of OCode objects that 
        /// represents the type of services provided by the 
        /// vendor of this contract. This is applicable only if 
        /// ProvideMaintenance = 1.
        /// </summary>
        public abstract DataList<OCode> TypeOfServices { get; set; }

        /// <summary>
        /// Gets or sets the OCode object 
        /// representing the contract type of this 
        /// contract.
        /// </summary>
        public abstract OCode ContractType { get; set; }

        /// <summary>
        /// Gets or sets the OVendor object that 
        /// represents the vendor providing services under 
        /// this contract.
        /// </summary>
        public abstract OVendor Vendor { get; set; }

        /// <summary>
        /// Gets a list of OScheduledWork objects that
        /// represents the scheduled works associated
        /// with this contract.
        /// </summary>
        public abstract DataList<OScheduledWork> ScheduledWorks { get; }

        /// <summary>
        /// Gets or sets the OUser object that 
        /// represents the user to be reminded 
        /// when the number of days before 
        /// the end of the contract are up.
        /// </summary>
        public abstract OUser Reminder1User { get; set; }

        /// <summary>
        /// Gets or sets the OUser object that 
        /// represents the user to be reminded 
        /// when the number of days before 
        /// the end of the contract are up.
        /// </summary>
        public abstract OUser Reminder2User { get; set; }

        /// <summary>
        /// Gets or sets the OUser object that 
        /// represents the user to be reminded 
        /// when the number of days before 
        /// the end of the contract are up.
        /// </summary>
        public abstract OUser Reminder3User { get; set; }

        /// <summary>
        /// Gets or sets the OUser object that 
        /// represents the user to be reminded 
        /// when the number of days before 
        /// the end of the contract are up.
        /// </summary>
        public abstract OUser Reminder4User { get; set; }

        /// <summary>
        /// Gets or sets the OUser object that 
        /// represents the user responsible for 
        /// managing this contract
        /// </summary>
        public abstract OUser ContractManager { get; set; }

        /// <summary>
        /// Gets or sets the OSurveyGroup object that
        /// represents the survey group that this
        /// contract is associated with.
        /// </summary>
        public abstract OSurveyGroup SurveyGroup { get; set; }

        /// <summary>
        /// Gets a one-to-many list of 
        /// OContractPriceServices objects that 
        /// represents the list of fixed rate group or 
        /// items covered by the purchase 
        /// agreement of this contract. This is only 
        /// applicable if ProvidePricingAgreement = 
        /// 1.
        /// </summary>
        public abstract DataList<OContractPriceService> ContractPriceServices { get; }

        /// <summary>
        /// Gets a one-to-many list of 
        /// OContractPriceMaterials objects that 
        /// represents the list of catalogue group or 
        /// items covered by the purchase 
        /// agreement of this contract. This is only 
        /// applicable if ProvidePricingAgreement = 
        /// 1.
        /// </summary>
        public abstract DataList<OContractPriceMaterial> ContractPriceMaterials { get; }


        /// <summary>
        /// Gets a list of all locations applicable to this task.
        /// </summary>
        public override List<OLocation> TaskLocations
        {
            get
            {
                List<OLocation> locations = new List<OLocation>();
                foreach (OLocation location in this.Locations)
                    locations.Add(location);
                return locations;
            }
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Gets a list of all accessible contracts (not implemented).
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static List<OContract> GetAccessibleContracts(OUser user)
        {
            /*
             * TODO: Resolve user access control later
            ExpressionCondition c = Query.False;
            foreach (OLocation location in user.LocationAccess)
                c = c | (TablesLogic.tContract.Locations.HierarchyPath.Like(location.HierarchyPath + "%") & TablesLogic.tContract.Locations.IsDeleted == 0);

            return TablesLogic.tContract[c];
             * */
            return null;
        }


        // kf begin: 
        // bug fix to select only contracts that are attached to locations 
        // that are not deleted.
        /// --------------------------------------------------------------
        /// <summary>
        /// Get a list of all accessible contracts.
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static DataTable GetAccessibleContracts2(OUser user)
        {
            return null;
            /*
             * TODO: Resolve user access control later
            ExpressionCondition c = Query.False;
            foreach (OLocation location in user.LocationAccess)
                c = c | (TablesLogic.tContract.Locations.HierarchyPath.Like(location.HierarchyPath + "%") & TablesLogic.tContract.Locations.IsDeleted == 0);

            return (DataTable)
                Query.Select(
                TablesLogic.tContract.ObjectID,
                TablesLogic.tContract.ObjectName,
                TablesLogic.tContract.Locations.IsDeleted.Sum(),
                TablesLogic.tContract.Locations.ObjectName.Count())
                .Where(
                c & TablesLogic.tContract.IsDeleted == 0)
                .GroupBy(
                TablesLogic.tContract.ObjectID,
                TablesLogic.tContract.ObjectName)
                .Having(
                TablesLogic.tContract.Locations.IsDeleted.Sum() !=
                TablesLogic.tContract.Locations.ObjectName.Count());*/

        }
        // kf end

        
        /// --------------------------------------------------------------
        /// <summary>
        /// Get the contracts that can apply to the work, and the 
        /// contracts that apply are:
        /// 1. The work's scheduled start must be within contract's start/end date.
        /// 2. The work's type of service must be covered by the contract's type of service.
        /// 3. The work's location must be covered by at least one of the contract's specified location.
        /// </summary>
        /// <param name="work"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static List<OContract> GetContractsByWork(OWork work)
        {
            if (work.TypeOfServiceID == null || work.LocationID == null)
                return null;

            DateTime d;
            if (work.ScheduledStartDateTime != null)
                d = work.ScheduledStartDateTime.Value;
            else if (work.ActualStartDateTime != null)
                d = work.ActualStartDateTime.Value;
            else
                return null;

            // 2010.10.12 CheeMeengs
            // Added to exclude contracts with status Expired/Cancelled/Close
            //
            return TablesLogic.tContract[
                TablesLogic.tContract.ProvideMaintenance == 1 &
                ((ExpressionDataString)work.Location.HierarchyPath).Like(TablesLogic.tContract.Locations.HierarchyPath + "%") &
                TablesLogic.tContract.TypeOfServices.ObjectID == work.TypeOfServiceID &
                TablesLogic.tContract.ContractStartDate <= d & d <= TablesLogic.tContract.ContractEndDate &
                TablesLogic.tContract.CurrentActivity.ObjectName != "Closed" & 
                TablesLogic.tContract.CurrentActivity.ObjectName != "Expired" & 
                TablesLogic.tContract.CurrentActivity.ObjectName != "Cancelled"];
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Get the contracts that can apply to the scheduled work, and
        /// the contracts that apply are:
        /// 1. The work's scheduled start must be within contract's start/end date.
        /// 2. The work's type of service must be covered by the contract's type of service.
        /// 3. The work's location must be covered by at least one of the contract's specified location.
        /// </summary>
        /// <param name="scheduledWork"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static DataTable GetContractsByScheduledWork(OScheduledWork scheduledWork, Guid? includingContractId)
        {
            DateTime? d;
            d = scheduledWork.FirstWorkStartDateTime;

            return TablesLogic.tContract.SelectDistinct(
                TablesLogic.tContract.ObjectID,
                TablesLogic.tContract.ObjectNumber,
                (TablesLogic.tContract.ObjectNumber + ": " + TablesLogic.tContract.ObjectName).As("Contract"))
                .Where(
                (TablesLogic.tContract.IsDeleted == 0 &
                TablesLogic.tContract.ProvideMaintenance == 1 &
                (scheduledWork.Location != null ?
                scheduledWork.Location.HierarchyPath.Like(TablesLogic.tContract.Locations.HierarchyPath + "%") : Query.False) &
                TablesLogic.tContract.TypeOfServices.ObjectID == scheduledWork.TypeOfServiceID &
                TablesLogic.tContract.ContractStartDate <= d & d <= TablesLogic.tContract.ContractEndDate) |
                TablesLogic.tContract.ObjectID == includingContractId)
                .OrderBy(
                TablesLogic.tContract.ObjectNumber.Asc)
                ;
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Get all contracts that provide purchasing agreement.
        /// </summary>
        /// <param name="purchaseOrder"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static List<OContract> GetContractsByPurchaseOrder(OPurchaseOrder purchaseOrder)
        {
            DateTime d;
            if (purchaseOrder.DateOfOrder != null)
                d = purchaseOrder.DateOfOrder.Value;
            else
                return null;

            return TablesLogic.tContract.LoadList(
                (TablesLogic.tContract.ProvidePricingAgreement == 1 &
                TablesLogic.tContract.ContractStartDate <= d & d <= TablesLogic.tContract.ContractEndDate &
                TablesLogic.tContract.IsDeleted == 0) |
                TablesLogic.tContract.ObjectID == purchaseOrder.ContractID);
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Get the reminder date = ContractEndDate - reminderDays.
        /// </summary>
        /// <param name="reminderDays"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public DateTime GetReminderDate(int? reminderDays)
        {
            if (reminderDays == null || ContractStartDate==null)
                return DateTime.MaxValue;

            return ContractEndDate.Value.AddDays(-reminderDays.Value);
        }

        //public int GetPriority(OContract contract)
        //{
        //    return contract.ContractEndDate.Value.AddMonths(-1) < DateTime.Now ? 3 :
        //    contract.ContractEndDate.Value.AddMonths(-2) < DateTime.Now ? 2 :
        //    contract.ContractEndDate.Value.AddMonths(-3) < DateTime.Now ? 1 : 0;
        //}

        /// --------------------------------------------------------------
        /// <summary>
        /// Renew this current contract to a new contract with the exact
        /// same terms, but the contract start and end date of the new
        /// contract will take the current contract's 'renewed contract
        /// start/end date'.
        /// </summary>
        /// --------------------------------------------------------------
        public OContract CreateContractWithSameTerms()
        {
            OContract newContract = TablesLogic.tContract.Create();

            newContract.ContactCellphone = this.ContactCellphone;
            newContract.ContactEmail = this.ContactEmail;
            newContract.ContactFax = this.ContactFax;
            newContract.ContactPerson = this.ContactPerson;
            newContract.ContactPhone = this.ContactPhone;
            newContract.ContractSum = this.ContractSum;
            //newContract.ContractTypeID = this.ContractTypeID;
            newContract.Description = this.Description;

            newContract.EndReminderDays1 = this.EndReminderDays1;
            newContract.EndReminderDays2 = this.EndReminderDays2;
            newContract.EndReminderDays3 = this.EndReminderDays3;
            newContract.EndReminderDays4 = this.EndReminderDays4;
            newContract.Insurance = this.Insurance;
            newContract.ObjectName = this.ObjectName;

            newContract.Reminder1UserID = this.Reminder1UserID;
            newContract.Reminder2UserID = this.Reminder2UserID;
            newContract.Reminder3UserID = this.Reminder3UserID;
            newContract.Reminder4UserID = this.Reminder4UserID;
            newContract.Terms = this.Terms;
            newContract.VendorID = this.VendorID;
            newContract.Warranty = this.Warranty;

            foreach (OCode typeOfService in this.TypeOfServices)
                newContract.TypeOfServices.Add(typeOfService);

            foreach (OLocation location in this.Locations)
                newContract.Locations.Add(location);

            return newContract;
        }



        /// --------------------------------------------------------------
        /// <summary>
        /// Find if a price agreement was defined for the specified catalogue.
        /// </summary>
        /// <param name="catalogueId"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        private OContractPriceMaterial FindContractPriceMaterial(Guid catalogueId)
        {
            foreach (OContractPriceMaterial m in ContractPriceMaterials)
                if (m.CatalogueID == catalogueId)
                    return m;
            return null;
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Get the unit price of materials based on the pricing 
        /// agreement in this contract.
        /// </summary>
        /// <param name="catalogueId"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public decimal GetMaterialUnitPrice(Guid catalogueId)
        {
            OCatalogue catalogue = TablesLogic.tCatalogue[catalogueId];
            OCatalogue catalogueItem = catalogue;

            while (catalogue != null)
            {
                OContractPriceMaterial m = FindContractPriceMaterial(catalogue.ObjectID.Value);

                if (m != null && m.PriceFactor != null && catalogueItem.UnitPrice != null)
                    return m.PriceFactor.Value * catalogueItem.UnitPrice.Value;
                catalogue = catalogue.Parent;
            }
            return 0;
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Find if a price agreement was defined for the specified catalogue.
        /// </summary>
        /// <param name="catalogueId"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        private OContractPriceService FindContractPriceService(Guid fixedRateId)
        {
            foreach (OContractPriceService m in ContractPriceServices)
                if (m.FixedRateID == fixedRateId)
                    return m;
            return null;
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Get the unit price of materials based on the pricing 
        /// agreement in this contract.
        /// </summary>
        /// <param name="catalogueId"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public decimal GetServiceUnitPrice(Guid fixedRateId)
        {
            OFixedRate fixedRate = TablesLogic.tFixedRate[fixedRateId];
            OFixedRate fixedRateItem = fixedRate;

            while (fixedRate != null)
            {
                OContractPriceService m = FindContractPriceService(fixedRate.ObjectID.Value);

                if (m != null && m.PriceFactor != null && fixedRateItem.UnitPrice != null)
                    return m.PriceFactor.Value * fixedRateItem.UnitPrice.Value;
                fixedRate = fixedRate.Parent;
            }
            return 0;
        }

        //201109
        //public List<OSurveyRespondentPortfolio> GetListOfApplicableSurveyRespondentPortfolio(int? SurveyTargetType,
        //    DateTime? ExpiryDateAfterInclusive, DateTime? ExpiryDateBeforeExclusive)
        //{
        //    List<OSurveyRespondentPortfolio> list = new List<OSurveyRespondentPortfolio>();

        //    list = TablesLogic.tSurveyRespondentPortfolio.LoadList(
        //        TablesLogic.tSurveyRespondentPortfolio.Contracts.ObjectID == this.ObjectID &
        //        (ExpiryDateAfterInclusive == null ? Query.True : TablesLogic.tSurveyRespondentPortfolio.ExpiryDate == null | TablesLogic.tSurveyRespondentPortfolio.ExpiryDate >= ExpiryDateAfterInclusive) &
        //        (ExpiryDateBeforeExclusive == null ? Query.True : TablesLogic.tSurveyRespondentPortfolio.ExpiryDate == null | TablesLogic.tSurveyRespondentPortfolio.ExpiryDate < ExpiryDateBeforeExclusive) &
        //        (SurveyTargetType == null ? Query.True : TablesLogic.tSurveyRespondentPortfolio.SurveyType == SurveyTargetType)
        //        ,TablesLogic.tSurveyRespondentPortfolio.ObjectName.Asc);//201109

        //    return list;
        //}


    }
}

