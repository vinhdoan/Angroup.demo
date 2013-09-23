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
    [Database("#database"), Map("Checklist")]
    [Serializable] public partial class TChecklist : LogicLayerSchema<OChecklist>
    {
        public SchemaInt IsChecklist;
        public SchemaInt Type;
        public SchemaDecimal Benchmark;
        
        public TChecklist Parent { get { return OneToOne<TChecklist>("ParentID"); } }
        public TChecklist Children { get { return OneToMany<TChecklist>("ParentID"); } }

        public TChecklistItem ChecklistItems { get { return OneToMany<TChecklistItem>("ChecklistID"); } }
    }


    /// <summary>
    /// Represents a checklist of many items, each item being a step
    /// in the checklist that must be performed as an action, or an item
    /// that must be inspected.
    /// </summary>
    public abstract partial class OChecklist : LogicLayerPersistentObject, IHierarchy
    {
        /// <summary>
        /// [Column] Gets or sets a flag that indicates whether this is a
        /// checklist group or a physical check with items within.
        /// <para></para>
        /// 0 - This is a checklist group.
        /// 1 - This is an actual physical checklist.
        /// </summary>
        public abstract int? IsChecklist { get; set; }

        /// <summary>
        /// [Column] Gets or sets the flag that indicates whether this is
        /// a checklist for work or for survey.
        /// <para></para>
        /// 0 - This checklist is for work.
        /// 1 - This checklist is for survey.
        /// </summary>
        public abstract int? Type { get; set; }

        /// <summary>
        /// [Column] Gets or set the minimum score that total score of 
        /// the checklist should attain. This currently is information and
        /// does not affect any processing logic.
        /// </summary>
        public abstract decimal? Benchmark { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag that indicates whether this is a
        /// </summary>
        public abstract OChecklist Parent { get; set; }

        /// <summary>
        /// Gets a list of children OChecklist objects.
        /// <para></para>
        /// Note: A checklist group can contain checklist groups
        /// and physical checklists as children, but a physical checklist
        /// CANNOT have anything below it.
        /// </summary>
        public abstract DataList<OChecklist> Children { get; }

        /// <summary>
        /// Gets a list of OCheckListItems objects.
        /// </summary>
        public abstract DataList<OChecklistItem> ChecklistItems { get; }

        public OChecklist()
        {
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Reorder the checklist items by their step number.
        /// </summary>
        /// <param name="obj"></param>
        /// --------------------------------------------------------------
        public void ReorderItem(PersistentObject obj)
        {
            // kf begin: 
            // consolidated all reorder function into Global.ReorderItems
            /*
            // assuming adding from interface, a negative step number indicates
            // a new step inserted at that point
            //
            Dictionary<int, OChecklistItem> h = new Dictionary<int, OChecklistItem>();
            int max = 0;
            foreach (OChecklistItem item in ChecklistItems)
            {
                // kf bug fix
                if (item != null && obj != null && item.ObjectID == obj.ObjectID)
                    item.StepNumber = item.StepNumber * 2 - 1;
                else
                    item.StepNumber = item.StepNumber * 2;
                if (item.StepNumber == null)
                    item.StepNumber = max + 1;
                h[item.StepNumber.Value] = item;

                if (item.StepNumber > max)
                    max = item.StepNumber.Value;
            }

            int c = 1;
            for (int i = 0; i <= max; i++)
                if (h.ContainsKey(i))
                    h[i].StepNumber = c++;
             */

            Global.ReorderItems(ChecklistItems, obj, "StepNumber");
            // kf end
        }

        public string ChecklistTypeText
        {
            get
            {
                return TranslateChecklistType(this.Type);
            }
        }

        public static string TranslateChecklistType(int? type)
        {
            switch (type)
            {
                case ChecklistType.Work:
                    return "Work";
                case ChecklistType.Survey:
                    return "Survey";
                case ChecklistType.Others:
                    return "Others";
                default:
                    return "Error";

            }
        }

        public static List<OChecklist> GetSurveyChecklist()
        {
            return TablesLogic.tChecklist.LoadList(
                TablesLogic.tChecklist.IsChecklist == 1 &
                TablesLogic.tChecklist.Type == ChecklistType.Survey);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="type"></param>
        /// <returns></returns>
        public static List<OChecklist> GetChecklistsByType(int? type)
        {
            return
                TablesLogic.tChecklist.LoadList
                (TablesLogic.tChecklist.IsChecklist == 1 &
                TablesLogic.tChecklist.Type == type);
        }

        /// <summary>
        /// check if checklist changeable
        /// </summary>
        public bool IsDesignChangeable
        {
            get
            {
                bool IsDesignChangeable = true;
                if (this.Type == ChecklistType.Survey)
                {
                    int Count = (int)TablesLogic.tSurveyChecklistItem.Select(TablesLogic.tSurveyChecklistItem.ObjectID.Count())
                                    .Where(TablesLogic.tSurveyChecklistItem.ChecklistID == this.ObjectID &
                                           TablesLogic.tSurveyChecklistItem.IsDeleted == 0);
                    if (Count > 0)
                        IsDesignChangeable = false;
                }
                return IsDesignChangeable;
            }
        }

    }

    public static class ChecklistType
    {
        public const int Work = 0;
        public const int Survey = 1;
        public const int Others = 2;
    }

}
