//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
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
    [Database("#database"), Map("ChecklistItem")]
    [Serializable] public partial class TChecklistItem : LogicLayerSchema<OChecklistItem>
    {
        public SchemaGuid ChecklistID;
        public SchemaGuid ChecklistResponseSetID;
        
        public SchemaInt StepNumber;
        
        public SchemaInt ChecklistType;

        [Default(0)]
        public SchemaInt HasSingleTextboxField;

        [Default(0)]
        public SchemaInt IsMandatoryField;
        public SchemaInt IsOverall;
        
        public TChecklist Checklist { get { return OneToOne<TChecklist>("ChecklistID"); } }
        public TChecklistResponseSet ChecklistResponseSet { get { return OneToOne<TChecklistResponseSet>("ChecklistResponseSetID"); } }
    }


    /// <summary>
    /// Represents an item that specifies an action to be performed 
    /// or an item that must be inspected. Examples of checklist items
    /// are "Clean the air-conditioning filter," or "Check if the
    /// EXIT signs of the buildings meet the statutory requirements." 
    /// <para>
    /// </para>
    /// The user who performs the actions in a checklist may then
    /// indicate a response either by choosing it from a list of
    /// choices, or by typing a free-text comment.
    /// </summary>
    [Serializable]
    public abstract partial class OChecklistItem : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Checklist table.
        /// </summary>
        public abstract Guid? ChecklistID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the 
        /// ChecklistResponseSet table. 
        /// <para></para>
        /// If the ChecklistType of this object is set to 0, or 
        /// ChecklistItemType.Choice, then this field must not be null.
        /// </summary>
        public abstract Guid? ChecklistResponseSetID { get; set; }

        public abstract int? HasSingleTextboxField { get; set; }

        /// <summary>
        /// [Column] Gets or sets the step number of the checklist item.
        /// </summary>
        public abstract int? StepNumber { get; set; }

        /// <summary>
        /// [Column] Gets or sets the item type for this checklist item.
        /// <para></para>
        /// <list>
        /// <item>0 - Choice: the user can select the response from a list of choices</item>
        /// <item>1 - Remarks: the user can input remarks</item>
        /// <item>2 - None: the user need not input any remarks or select any response.</item>
        /// </list>
        /// </summary>
        public abstract int? ChecklistType { get; set; }

        public abstract int? IsMandatoryField { get; set; }
        public abstract int? IsOverall { get; set; }

        /// <summary>
        /// Gets or sets the checklist that contains this checklist item.
        /// </summary>
        public abstract OChecklist Checklist { get; }

        /// <summary>
        /// Gets the ChecklistResponseSet object associated with this
        /// checklist item.
        /// </summary>
        public abstract OChecklistResponseSet ChecklistResponseSet { get; }

        /// <summary>
        /// Gets the checklist item type as a localized text.
        /// </summary>
        public string ChecklistTypeString
        {
            get
            {    
                if (ChecklistType == ChecklistItemType.Choice)
                    return Resources.Strings.CheckItemType_Choice;
                else if (ChecklistType == ChecklistItemType.Remarks)
                    return Resources.Strings.CheckItemType_Remarks;
                else if (ChecklistType == ChecklistItemType.None)
                    return Resources.Strings.CheckItemType_None;
                else if (ChecklistType == ChecklistItemType.MultipleSelections)
                    return "Mutiple Choice (Only One Answer)";
                else if (ChecklistType == ChecklistItemType.SingleLineFreeText)
                    return "Single Line Texbox";
                else
                    return "Error";
            }
        }

        /// <summary>
        /// Gets the checklist item IsOverall in text.
        /// </summary>
        public string IsOverallText
        {
            get
            {
                if (this.IsOverall == 1)
                    return "Yes";
                else
                    return "No";
            }
        }
        
        /// <summary>
        /// Gets the checklist item IsMandatoryField in text.
        /// </summary>=
        public string IsMandatoryFieldText
        {
            get
            {
                if (this.IsMandatoryField == 1)
                    return "Yes";
                else
                    return "No";
            }
        }
    }


    public class ChecklistItemType
    {
        /// <summary>
        /// Indicates that the checklist item consists of a choice of answers.
        /// </summary>
        public const int Choice = 0;
        /// <summary>
        /// Indicates that the checklist item requires only remarks for input.
        /// </summary>
        public const int Remarks = 1;
        /// <summary>
        /// Indicates that the checklist item does not require any input.
        /// </summary>
        public const int None = 2;
        /// <summary>
        /// Indicates that the checklist item consists of a choice of answers.
        /// </summary>
        public const int MultipleSelections = 3;
        /// <summary>
        /// Indicates that the checklist item requires only free text (single line) for input.
        /// </summary>
        public const int SingleLineFreeText = 4;
    }
}
