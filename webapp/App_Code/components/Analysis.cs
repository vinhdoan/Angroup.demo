//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 5.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.Odbc;
using System.Data.Common;
using System.Configuration;
using System.Reflection;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;
using LogicLayer;

/// <summary>
/// Summary description for Analysis
/// </summary>
public class Analysis
{
    /// ------------------------------------------------------------------
    /// <summary>
    /// This is a workaround function to build positional parameters, since
    /// ODBC cannot accept named parameters.
    /// 
    /// All SQL queries provided to this method must encapsulate their
    /// named parameters within the braces { } tag. For example:
    /// 
    ///     select * from user where user.objectid={userid}
    ///   is converted to:
    ///     select * from user where user.objectid=?
    /// 
    /// To escape the first '{' tag, use a double brace, even if the braces
    /// appear within the single quotes. For example:
    /// 
    ///     select * from user where user.objectname like '{{chow}' + '%'
    ///   is converted to:
    ///     select * from user where user.objectname like '{chow}' + '%'
    ///     
    /// </summary>
    /// <param name="queryString"></param>
    /// <returns></returns>
    /// ------------------------------------------------------------------
    public static SqlQueryString BuildPositionalParameters(string queryString, params Parameter[] parameters)
    {
        List<DbParameter> dbParameter = new List<DbParameter>();
        StringBuilder sb = new StringBuilder();
        string paramName = "";

        queryString += " ";
        for (int i = 0; i < queryString.Length - 1; i++)
        {
            if (queryString[i] == '{')
            {
                if (queryString[i + 1] == '{')
                {
                    i++;
                    sb.Append("{");
                }
                else
                {
                    // this is where we capture the parameter name
                    //
                    for (int j = i + 1; j < queryString.Length - 1; j++)
                    {
                        if (queryString[j] == '}')
                        {
                            bool found = false;
                            foreach (Parameter p in parameters)
                            {
                                if (paramName == p.ParameterName || paramName == p.ParameterName + ":COUNT")
                                {
                                    if (p.IsSingleValue)
                                    {
                                        DbParameter dbParam = Connection.GetProviderFactory().CreateParameter();
                                        dbParam.ParameterName = "p" + dbParameter.Count;
                                        dbParam.DbType = (DbType)p.DataType;
                                        dbParam.Size = p.Size;
                                        dbParam.Value = p.Value;

                                        // KF BEGIN 2007.05.08
                                        // This makes sure that we don't pass the C# null value, but the database
                                        // null value to the underlying database.
                                        //
                                        // This solves the bug where in the Work Order History report where the
                                        // dropdown list becomes highlighted with error immediately when the report
                                        // search page appears.
                                        //
                                        if (p.Value == null)
                                            dbParam.Value = DBNull.Value;
                                        // KF END

                                        dbParameter.Add(dbParam);
                                        sb.Append("@" + dbParam.ParameterName);
                                    }
                                    else
                                    {
                                        if (paramName == p.ParameterName)
                                        {
                                            // this is a multi-value list of items, so what we do here, is convert
                                            // it into a list and insert it into the SQL string.
                                            //
                                            sb.Append("(null");
                                            if (p.List != null)
                                            {
                                                int count = 0;
                                                foreach (object o in p.List)
                                                {
                                                    DbParameter dbParam = Connection.GetProviderFactory().CreateParameter();
                                                    dbParam.ParameterName = "p" + dbParameter.Count;
                                                    dbParam.DbType = (DbType)p.DataType;
                                                    dbParam.Size = p.Size;
                                                    dbParam.Value = o;
                                                    if (o == null)
                                                        dbParam.Value = DBNull.Value;
                                                    dbParameter.Add(dbParam);
                                                    //sb.Append(",");
                                                    sb.Append(",@" + dbParam.ParameterName);
                                                    //sb.Append(p.Value.ToString());
                                                    count++;
                                                }
                                            }
                                            sb.Append(")");
                                        }
                                        else
                                        {
                                            DbParameter dbParam = Connection.GetProviderFactory().CreateParameter();
                                            dbParam.ParameterName = "p" + dbParameter.Count;
                                            dbParam.DbType = DbType.Int32;
                                            dbParam.Size = 4;
                                            if (p.List != null)
                                                dbParam.Value = p.List.Count;
                                            else
                                                dbParam.Value = 0;
                                            dbParameter.Add(dbParam);
                                            sb.Append("@" + dbParam.ParameterName);
                                            //sb.Append(p.Value.ToString());
                                        }
                                    }
                                    found = true;
                                }
                            }
                            if (!found)
                                throw new Exception("The parameter name '" + paramName + "' does not exist in the list of parameters available for this query.");

                            paramName = "";
                            i = j;
                            break;
                        }
                        else
                            paramName += queryString[j];
                    }
                }
            }
            else
                sb.Append(queryString[i]);
        }

        SqlQueryString sqlQuery = new SqlQueryString();
        sqlQuery.QueryString = sb.ToString();
        sqlQuery.Parameters = new DbParameter[dbParameter.Count];
        for (int i = 0; i < dbParameter.Count; i++)
            sqlQuery.Parameters[i] = dbParameter[i];

        return sqlQuery;
    }


    //--------------------------------------------------------------------
    /// <summary>
    /// Invokes a method in the LogicLayer.Reports class and returns 
    /// the result from that method as datasource for the report.
    /// </summary>
    /// <param name="methodName"></param>
    /// <param name="parameters"></param>
    /// <returns></returns>
    //--------------------------------------------------------------------
    public static object InvokeMethod(string methodName, params Parameter[] parameters)
    {
        // construct the parameters Hashtable
        //
        ReportParameters reportParameters = new ReportParameters();
        if (parameters != null)
        {
            foreach (Parameter parameter in parameters)
            {
                if (parameter.IsSingleValue)
                {
                    if (parameter.Value == DBNull.Value)
                        reportParameters.AddParameter(parameter.ParameterName, null);
                    else
                        reportParameters.AddParameter(parameter.ParameterName, parameter.Value);
                }
                else
                    reportParameters.AddParameter(parameter.ParameterName, parameter.List);
            }
        }

        // get the method pointer and invoke the method immediately.
        //
        Type t = typeof(LogicLayer.Reports);
        MethodInfo mi = t.GetMethod(methodName, System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.Public);
        if (mi != null)
            return mi.Invoke(null, new object[] { reportParameters });
        else
            throw new Exception("Unable to invoke method '" + methodName + "' to generate the report.");
    }

    public static DataTable DoQuery(string queryString, params Parameter[] parameters)
    {
        if (queryString.Trim() != "")
        {

            SqlQueryString sqlQuery = BuildPositionalParameters(queryString, parameters);

            DataSet ds = Connection.ExecuteQuery("#database_readonly", sqlQuery.QueryString, sqlQuery.Parameters);
            return ds.Tables[0];
        }
        else
            return new DataTable();
    }


    public static DataTable DoQuery(string queryString, string v)
    {
        return DoQuery(
            queryString,
            Parameter.New("UserID", DbType.Guid, 16, AppSession.User.ObjectID.Value),
            Parameter.New("Input", DbType.String, 255, v));
    }


    public static DataTable DoQuery(string queryString)
    {
        return DoQuery(
            queryString,
            Parameter.New("UserID", DbType.Guid, 16, AppSession.User.ObjectID.Value));
    }


    public Analysis()
    {
        //
        // TODO: Add constructor logic here
        //
    }
}


public class Parameter
{
    public string ParameterName;
    //show display name for displaying value in Drag and drop report
    public string ParameterDisplay;
    public DbType DataType;
    public int Size;
    public object Value;
    public List<object> List;
    public bool IsSingleValue;

    public Parameter(string parameterName, List<object> list)
    {
        ParameterName = parameterName;
        List = list;
        IsSingleValue = false;
    }

    public Parameter(string parameterName, DbType dataType, int size, object value)
    {
        ParameterName = parameterName;
        DataType = dataType;
        Size = size;
        Value = value;
        IsSingleValue = true;
    }

    public Parameter(string parameterName, DbType dataType, int size, object value, string displayName)
    {
        ParameterName = parameterName;
        DataType = dataType;
        Size = size;
        Value = value;
        IsSingleValue = true;
        ParameterDisplay = displayName;
    }

    public static Parameter New(string parameterName, List<object> list)
    {
        return new Parameter(parameterName, list);
    }

    public static Parameter New(string parameterName, DbType dataType, int size, object value)
    {
        return new Parameter(parameterName, dataType, size, value);
    }

    public static Parameter New(string parameterName, DbType dataType, int size, object value, string displayName)
    {
        return new Parameter(parameterName, dataType, size, value, displayName);
    }
}


public class SqlQueryString
{
    public string QueryString;

    public DbParameter[] Parameters;
}

