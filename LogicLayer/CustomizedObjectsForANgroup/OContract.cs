using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Collections;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using BarcodeLib;
using Anacle.DataFramework;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;

namespace LogicLayer
{
    public partial class TContract : LogicLayerSchema<OContract>
    {
        public TContractReminder ContractReminders { get { return OneToMany<TContractReminder>("ContractID"); } }
        public TContractServiceLevelSurvey ContractServiceLevelSurveys { get { return OneToMany<TContractServiceLevelSurvey>("ContractID"); } }
    }


    public partial class OContract : LogicLayerPersistentObject, IAuditTrailEnabled
    {
        /// --------------------------------------------------------------
        /// <summary>
        /// Get the applicable ContractPriceMaterial object given
        /// the catalog ID.
        /// </summary>
        /// <param name="catalogueId"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public abstract DataList<OContractReminder> ContractReminders { get; set; }
        public abstract DataList<OContractServiceLevelSurvey> ContractServiceLevelSurveys { get; set; }
        public OContractPriceMaterial GetContractPriceMaterial(Guid catalogueId)
        {
            OCatalogue catalogue = TablesLogic.tCatalogue[catalogueId];
            OCatalogue catalogueItem = catalogue;

            while (catalogue != null)
            {
                OContractPriceMaterial m = FindContractPriceMaterial(catalogue.ObjectID.Value);

                if (m != null)
                    return m;
                catalogue = catalogue.Parent;
            }
            return null;
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Get the applicable ContractPriceService object given
        /// the fixed rate ID.
        /// </summary>
        /// <param name="fixedRateId"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public OContractPriceService GetContractPriceService(Guid fixedRateId)
        {
            OFixedRate fixedRate = TablesLogic.tFixedRate[fixedRateId];
            OFixedRate fixedRateItem = fixedRate;

            while (fixedRate != null)
            {
                OContractPriceService m = FindContractPriceService(fixedRate.ObjectID.Value);

                if (m != null)
                    return m;
                fixedRate = fixedRate.Parent;
            }
            return null;
        }

        public static List<OContract> GetContractsByVendor(OVendorEvaluation eval, Guid? includingContractId)
        {
            DateTime d;
            if (eval.StartDate != null)
                d = eval.StartDate.Value;
            else
                return null;

            return TablesLogic.tContract[
                (TablesLogic.tContract.VendorID == eval.VendorID &
                TablesLogic.tContract.ContractStartDate <= d & d <= TablesLogic.tContract.ContractEndDate &
                TablesLogic.tContract.CurrentActivity.ObjectName != "Cancelled") |
                TablesLogic.tContract.ObjectID == includingContractId];
        }

        public string ContractNumberWithContractName
        {
            get
            {
                return this.ObjectNumber + ": " + this.ObjectName;
            }
        }


    }
}
