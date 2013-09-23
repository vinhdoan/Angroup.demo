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
using System.Web.UI;
using System.Web.UI.WebControls;
using Anacle.UIFramework;

namespace LogicLayer
{
    public class OCustomizedObjectConsumer
    {
        /// <summary>
        /// 
        /// </summary>
        /// <param name="attachedObjectName"></param>
        /// <param name="attachedPropertyID"></param>
        /// <param name="excludeNoneField">indicate whether to include field without value such as separator</param>
        public static List<OCustomizedAttributeField> GetCustomizedAttributeFields(string attachedObjectName, Guid attachedPropertyID, bool includeNoneField)
        {
            return TablesLogic.tCustomizedAttributeField[TablesLogic.tCustomizedAttributeField.AttachedObjectName == attachedObjectName & TablesLogic.tCustomizedAttributeField.MainObjectID == attachedPropertyID & (includeNoneField ? Query.True : TablesLogic.tCustomizedAttributeField.ControlType != "Separator")];

        }
        /// <summary>
        /// Populate data of all list in the object record
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="fields"></param>

        public static void PopulateCustomizedFieldList(OCustomizedField field, Control control)
        {      
            if (control != null)
            {
                if (field.ControlType == "DropDownList")
                {
                    BindToList(control as UIFieldDropDownList, field);                
                }
                else if (field.ControlType == "RadioList")
                {                  
                   BindToList(control as UIFieldRadioList, field);                  
                }
            }            
            
          
        }

        /// ------------------------------------------------------------------
        /// <summary>
        /// Bind to a dropdown list
        /// </summary>
        /// <param name="c"></param>
        /// <param name="dataSource"></param>
        /// <param name="textField"></param>
        /// <param name="valueField"></param>
        /// ------------------------------------------------------------------
        private static void BindToList<T>(UIFieldDropDownList c, T field) where T : OCustomizedField
        {

            if (field.IsPopulatedByCode == 1)
            {
                c.Bind(TablesLogic.tCode[TablesLogic.tCode.CodeTypeID == field.CodeTypeID], true);
            }

            else
                c.Bind(field.ConstructTextValueTable(), "Text", "Value", true);

        }


        /// ------------------------------------------------------------------
        /// <summary>
        /// Bind to a radio list
        /// </summary>
        /// <param name="c"></param>
        /// <param name="dataSource"></param>
        /// <param name="textField"></param>
        /// <param name="valueField"></param>
        /// ------------------------------------------------------------------
        private static void BindToList<T>(UIFieldRadioList c, T field) where T : OCustomizedField
        {

            if (field.IsPopulatedByCode == 1)
            {
                c.Bind(TablesLogic.tCode[TablesLogic.tCode.CodeTypeID == field.CodeTypeID]);
            }

            else
                c.Bind(field.ConstructTextValueTable(), "Text", "Value");

        }

        /// <summary>
        /// return setting on attached property name, tabview ID of the attribute object
        /// </summary>
        /// <param name="editObjectTable"></param>
        /// <returns></returns>
        public static string[] GetAttachedObjectSetting(string editObjectTable)
        {
            //Check if the currently editting object (with the specific location Type ID ) has any attribute object attached to it            
            List<OCustomizedAttributeField> allFields = TablesLogic.tCustomizedAttributeField[TablesLogic.tCustomizedAttributeField.AttachedObjectName == editObjectTable];
            if (allFields == null || allFields.Count == 0)
                return null;
            string[] setting = new string[2];
            setting[0] = allFields[0].AttachedPropertyName;
            setting[1] = allFields[0].TabViewID;
            return setting;
        }

        /// <summary>
        /// return the attribute id of the edit object from database
        /// </summary>
        /// <param name="mainObject"></param>
        /// <param name="editObjectTable"></param>
        /// <param name="mainObjectID"></param>
        /// <returns></returns>
        public static Guid? GetAttachedObjectAttributeID(string editObjectTable, string propertyName, Guid mainObjectID)
        {
            //get the schema of the main object table
            SchemaBase mainTable = (SchemaBase)UIBinder.GetValue(typeof(TablesLogic), editObjectTable, true);
            if (mainTable == null)
                throw new Exception("Error encounterred while building object attribute component: No schema object " + editObjectTable + " found");
            //retrieve the main object
            PersistentObject obj = mainTable.LoadObject(mainObjectID);
            try
            {
                if (obj == null )
                    return null;
                //retrieve the attribute type ID of the main object
                if (obj.DataRow[propertyName] == null || obj.DataRow[propertyName].ToString() == "")
                    return null;
                return (Guid?)obj.DataRow[propertyName];

            }
            catch
            {
                throw new Exception("Error encounterred while building object attribute component: property " + propertyName + " is not a value of type GUID, or it does not exist in the schema " + editObjectTable);
            }
        }

        public static void BuildCustomizedControls(Control c1, IEnumerable fields)
        {
            ControlCollection containerControls = c1.Controls;
            if (c1 is UITabView)
                containerControls = ((UITabView)c1).Controls;

            if (fields == null)
                return;
            //Order the field based on display order
            ArrayList sortFields = new ArrayList();
            foreach (object field in (IEnumerable)fields)
            {             
                 sortFields.Add(field);
            }            
            sortFields.Sort(new PersistentObjectComparer("DisplayOrder"));

            //build control
            foreach (OCustomizedField field in sortFields)
            {
               /* //avoid rebuilding the same fields
                Control existingControl = container.FindControl(field.ColumnName);

                if (existingControl != null)
                {
                    //must set enable viewstate to false
                    if (existingControl is UIFieldBase)
                        existingControl.EnableViewState = false;
                    existingControl.Visible = true;
                    continue;
                }*/
                if (field.ControlType == "Separator")
                {
                    UISeparator sep = new UISeparator();
                    sep.ID = field.ColumnName;
                    containerControls.Add(sep);
                    sep.Caption = field.ControlCaption;
                }
                else
                {
                    UIFieldBase control = null;

                    if (field.ControlType == "TextBox")
                    {
                        control = new UIFieldTextBox();
                        if (field.MaxLength != null)
                            ((UIFieldTextBox)control).MaxLength = field.MaxLength.Value;
                        if (field.MultiLineTextBox == 1)
                        {
                            ((UIFieldTextBox)control).TextMode = TextBoxMode.MultiLine;
                            ((UIFieldTextBox)control).Rows = 3;
                        }
                    }
                    else if (field.ControlType == "DateTime" || field.ControlType == "Date")
                    {
                        control = new UIFieldDateTime();
                        ((UIFieldDateTime)control).ShowTimeControls = (field.ControlType == "DateTime");
                    }
                    else if (field.ControlType == "CheckBox")
                    {
                        control = new UIFieldCheckBox();
                        ((UIFieldCheckBox)control).Text = field.CheckboxCaption;
                    }
                    else if (field.ControlType == "DropDownList")
                        control = new UIFieldDropDownList();
                    else if (field.ControlType == "RadioList")
                        control = new UIFieldRadioList();

                    if (control != null)
                    {
                        //this has to be called before adding the control into page
                        control.EnableViewState = false;           
                        //Add control 
                        containerControls.Add(control);
                        control.ID = field.ColumnName;                                    
                        control.ControlInfo = field.ColumnName;
                        //caption
                        control.Caption = field.ControlCaption;
                        //span
                        if (field.ControlSpan == "Half")
                            control.Span = Span.Half;
                        else if (field.ControlSpan == "Full")
                            control.Span = Span.Full;
                        //Active
                        if (field.IsActive == 1)
                            control.Enabled = true;
                        else
                            control.Enabled = false;

                        //tooltip
                        if (field.ToolTip != "")
                            control.ToolTip = field.ToolTip;

                        // set up validation. No validation is done for string                   

                        if (field.DataType == "String")
                            control.ValidateDataTypeCheck = false;
                        else
                            control.ValidateDataTypeCheck = true;

                        if (field.DataType == "Integer")
                        {
                            control.ValidationDataType = ValidationDataType.Integer;

                        }
                        else if (field.DataType == "Decimal")
                        {
                            control.ValidationDataType = ValidationDataType.Currency;
                        }
                        else if (field.DataType == "Double")
                        {
                            control.ValidationDataType = ValidationDataType.Double;
                        }
                        else if (field.DataType == "DateTime")
                        {
                            control.ValidationDataType = ValidationDataType.Date;
                        }
                        //if the field is disable, do not check for required field
                        if (field.ValidateRequiredField == 1 && field.IsActive == 1)
                            control.ValidateRequiredField = true;
                        else
                            control.ValidateRequiredField = false;

                        if (field.ValidateRangeField == 1)
                        {
                            control.ValidateRangeField = true;
                            if (field.DataType == "Double")
                                control.ValidationRangeType = ValidationDataType.Double;
                            else if (field.DataType == "DateTime")
                                control.ValidationRangeType = ValidationDataType.Date;
                            else if (field.DataType == "Decimal")
                                control.ValidationRangeType = ValidationDataType.Currency;
                            else if (field.DataType == "Integer")
                                control.ValidationRangeType = ValidationDataType.Integer;
                            control.ValidationRangeMin = field.ValidateRangeMin;
                            control.ValidationRangeMax = field.ValidateRangeMax;
                        }
                        else
                            control.ValidateRangeField = false;

                    }
                    //populate the field if it's list type
                    if (field.ControlType == "DropDownList" || field.ControlType == "RadioList")
                    {
                        PopulateCustomizedFieldList(field, control);
                    }
                }
            }

        }
    }
}
