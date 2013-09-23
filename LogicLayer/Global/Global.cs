//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Globalization;
using System.Collections;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;
using Anacle.UIFramework;

namespace LogicLayer
{
    public class Global
    {

        public static void SetCulture(CultureInfo culture)
        {
            Resources.Strings.Culture = culture;
            Resources.Errors.Culture = culture;
            Resources.Notifications.Culture = culture;
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Global function to reorder items in a list.
        /// </summary>
        /// <param name="objects">List of objects</param>
        /// <param name="objToReorder">Object that has just been updated. This should be null, or it should be one of the objects in the list.</param>
        /// <param name="propertyName"></param>
        //----------------------------------------------------------------
        public static void ReorderItems(IEnumerable objects, PersistentObject objToReorder, string propertyName)
        {
            try
            {
                int totalCount = 0;
                List<PersistentObject> list = new List<PersistentObject>();
                foreach (PersistentObject o in objects)
                {
                    totalCount++;
                    if (o != objToReorder)
                        list.Add(o);
                }
                list.Sort(new PersistentObjectComparer(propertyName));

                int? reorderNumber = null;
                if (objToReorder != null)
                {
                    reorderNumber = (int?)(objToReorder.DataRow[propertyName]);
                    if (reorderNumber != null && reorderNumber > totalCount)
                    {
                        objToReorder.DataRow[propertyName] = totalCount;
                        objToReorder.Touch();
                    }
                }

                int c = 1;
                for (int i = 0; i < list.Count; i++)
                {
                    if (reorderNumber != null && reorderNumber.Value == c)
                        c++;
                    list[i].DataRow[propertyName] = c++;
                    list[i].Touch();
                }
            }
            catch
            {
            }
        }
    }


    //----------------------------------------------------------------
    /// <summary>
    /// Class to sort objects based on an integer field
    /// </summary>
    //----------------------------------------------------------------
    public class PersistentObjectComparer : Comparer<PersistentObject>
    {
        string propertyName = "";
        public PersistentObjectComparer(string intPropertyName)
        {
            propertyName = intPropertyName;
        }

        public override int Compare(PersistentObject x, PersistentObject y)
        {
            try
            {
                int? xv = (int?)x.DataRow[propertyName];
                int? yv = (int?)y.DataRow[propertyName];

                return xv.Value - yv.Value;
            }
            catch 
            {
                return 0;
            }
            
        }
    }
}
