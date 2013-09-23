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

namespace LogicLayer
{
    public class TRunningNumber : LogicLayerSchema<ORunningNumber>
    {
        [Size(100)]
        public SchemaString ObjectTypeName;
        [Size(100)]
        public SchemaString Codes;
        public SchemaInt LastNumber;
        public SchemaInt LastMonth;
        public SchemaInt LastYear;
    }

    /// <summary>
    /// Represents sets of running numbers used by various modules throughout
    /// the system. This class also contains methods for other modules to 
    /// automatically generate different sets of running numbers by specifying
    /// an 'running number type' identifier.
    /// </summary>
    [Serializable]
    public abstract partial class ORunningNumber : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the name of the persistent object
        /// type.
        /// </summary>
        public abstract String ObjectTypeName { get;set;}

        /// <summary>
        /// [Column] Gets or sets the prefixes associated with
        /// this running number entry.
        /// </summary>
        public abstract String Codes { get; set; }

        /// <summary>
        /// [Column] Gets or sets the last number that was generated
        /// for this set.
        /// </summary>
        public abstract int? LastNumber { get;set;}

        /// <summary>
        /// [Column] Gets or sets the month the last number for this 
        /// set was generated.
        /// </summary>
        public abstract int? LastMonth { get;set;}

        /// <summary>
        /// [Column] Gets or sets the year the last number for this 
        /// set was generated.
        /// </summary>
        public abstract int? LastYear { get;set;}

        /// <summary>
        /// This method creates a global running number based on the object type specified,
        /// the prefixes, and the last generated month/year number.
        /// <param name="date">The date the running number is generated for.</param>
        /// <param name="objectTypeName">The persistent object type name</param>
        /// <param name="codes">Any prefixes generated that requires a different
        /// sequence of numbers.</param>
        /// <returns>Returns the running number as an integer</returns>
        /// </summary>
        public static int GenerateNextNumber(DateTime date, string objectTypeName, string codes)
        {
            using (Connection c = new Connection())
            {
                c.SetLockMode(LockMode.UpdateLock);
                ORunningNumber rn = TablesLogic.tRunningNumber.Load(
                    TablesLogic.tRunningNumber.ObjectTypeName == objectTypeName &
                    TablesLogic.tRunningNumber.Codes == codes &
                    TablesLogic.tRunningNumber.LastMonth == date.Month &
                    TablesLogic.tRunningNumber.LastYear == date.Year);
                c.SetLockMode(LockMode.Default);

                // if this prefix has not yet been created in the database,
                // then we create a new entry in the running number table.
                //
                if (rn == null)
                {
                    rn = TablesLogic.tRunningNumber.Create();
                    rn.ObjectTypeName = objectTypeName;
                    rn.Codes = codes;
                    rn.LastNumber = 0;
                    rn.LastMonth = date.Month;
                    rn.LastYear = date.Year;
                }

                // Get the next number and the month and year.
                rn.LastNumber = rn.LastNumber + 1;
                int nextNumber = rn.LastNumber.Value;

                rn.Save();
                c.Commit();

                return nextNumber;
            }
        }


        /// <summary>
        /// This method creates a global running number based on the type specified,
        /// and the last generated month/year number.
        ///<para></para>
        /// The format string should specify the output format of the string, for example:
        ///	“INV-{2:00}{1:00}-{0:0000}?
        /// where 
        /// <list>
        ///   <item>{0} is the running Number</item>
        ///   <item>{1} is the month</item>
        ///   <item>{2} is the year</item>
        /// </list>        
        /// <para></para>
        /// The following are some examples on how to use this method:
        ///    string NewPONumber = ORunningNumber.GenerateNextNumber("PurchaseOrder", "PO-{2:00}{1:00}-{0:0000}", true);
        /// The above will generate something like: "PO-0709-1234"
        /// <para></para>
        ///    string NewPONumber = ORunningNumber.GenerateNextNumber("PurchaseOrder", "PO-{4:00}{1:00}-{0:0000}", false);
        /// The above will generate something like: "PO-200709-1234"
        /// </summary>
        /// <param name="objectTypeName">The type of running number.</param>
        /// <param name="formatString">The C# format string for the output.</param>
        /// <param name="twoDigitYear">A flag to indicate whether the year should be generated in two digits, or four digits.</param>
        /// <returns>The running number in a format that is specified using the formatString.</returns>
        public static string GenerateNextNumber(string objectTypeName, string formatString, bool twoDigitYear)
        {
            DateTime now =DateTime.Now;
            int month = now.Month;
            int year = now.Year;
            int number = GenerateNextNumber(now, objectTypeName, "");

            if (twoDigitYear)
                // 2010.07.09
                // Fixed to perform modulo on the year instead of the month.
                year = year % 100;

            return String.Format(formatString, number, month, year);

        }
    }
}
