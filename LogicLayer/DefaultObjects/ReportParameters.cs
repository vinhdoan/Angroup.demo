//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace LogicLayer
{
    //--------------------------------------------------------------------
    /// <summary>
    /// This is the Reports class that will be used by the Report 
    /// Builder to call methods within this class. All reports that are 
    /// to be exposed to the Report Builder at the Web Application layer 
    /// must declare one of the following prototypes:
    /// 
    ///     public static DataTable ReportMethodName(Hashtable 
    ///         parameters);
    /// 
    ///     public static DataSet ReportMethodName(Hashtable 
    ///         parameters);
    /// 
    /// </summary>
    //--------------------------------------------------------------------
    public class ReportParameters
    {
        private Hashtable ht = new Hashtable();


        //--------------------------------------------------------------------
        /// <summary>
        /// Get the list of parameter names currently stored in the
        /// parameter list.
        /// </summary>
        //--------------------------------------------------------------------
        public ICollection ParameterNames
        {
            get
            {
                return ht.Keys;
            }
        }


        //--------------------------------------------------------------------
        /// <summary>
        /// Returns the value of the parameterName stored in this list.
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        //--------------------------------------------------------------------
        public object this[string parameterName]
        {
            get
            {
                if (ht[parameterName] == null)
                    return DBNull.Value;
                else
                    return ht[parameterName];
            }
        }

        /// <summary>
        /// Constructor.
        /// </summary>
        public ReportParameters()
        {
        }

        public void AddParameter(string parameterName, object value)
        {
            ht[parameterName] = value;
        }

        public int? GetInteger(string parameterName)
        {
            try { return Convert.ToInt32(ht[parameterName]); }
            catch { return null; }
        }

        public double? GetDouble(string parameterName)
        {
            try { return Convert.ToDouble(ht[parameterName]); }
            catch { return null; }
        }

        public decimal? GetDecimal(string parameterName)
        {
            try { return Convert.ToDecimal(ht[parameterName]); }
            catch { return null; }
        }

        public DateTime? GetDateTime(string parameterName)
        {
            try { return Convert.ToDateTime(ht[parameterName]); }
            catch { return null; }
        }

        public string GetString(string parameterName)
        {
            try { return Convert.ToString(ht[parameterName]); }
            catch { return null; }
        }   

        public List<object> GetList(string parameterName)
        {
            try { return (List<object>)(ht[parameterName]); }
            catch { return null; }
        }
    }
}
