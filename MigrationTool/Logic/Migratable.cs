using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Data;

using DataMigration.Infrastructure;
using System.IO;
using Anacle.DataFramework;

namespace DataMigration.Logic
{
    public class Migratable
    {
        public const string ERROR_MSG_COL = "ErrorMessage";
        public Migratable(string mapfrom, string mapto)
        {
            this.mapTo = mapto;
            this.mapfrom = mapfrom;
        }

        public Migratable(string mapfrom, string mapto, string sourcefile)
        {
            this.mapTo = mapto;
            this.mapfrom = mapfrom;
            this.sourcefile = sourcefile;
        }

        public virtual void Migarate()
        { }

        protected virtual DataTable GetDatasource()
        {

            DataTable table = ExcelHelper.GetTableData(mapfrom);
            if (null == table)
            {
                table = Data.Import(sourcefile, ',');
                if (table == null)
                    throw new Exception("Can't load data from " + mapfrom + "!");
            }
            table.Columns.Add(ERROR_MSG_COL, typeof(string));

            return table;
        }

        protected string mapfrom = string.Empty;

        public string MapFrom
        {
            get { return mapfrom; }
        }

        protected string mapTo = string.Empty;

        public string MapTo
        {
            get { return mapTo; }
        }

        protected string sourcefile = string.Empty;

        public string SourceFile
        {
            get { return sourcefile; }
        }


        //protected List<string> columns = new List<string>();

        public List<string> Columns
        {
            get { return Configuration.GetMigrateConfig(this.mapTo).Fields; }
        }

        protected IDictionary<string, string> map = null;

        public IDictionary<string, string> Map
        {
            get { return map; }
            set { map = value; }
        }

        protected string ConvertToString(object obj)
        {
            string result = null;
            if (null == obj) return null;
            if (DBNull.Value == obj) return null;
            result = Convert.ToString(obj);
            if (result == null || result == String.Empty) return null;
            return result.Trim().Replace("，", ",");
        }

        protected ArrayList ConvertIEnumerableToArrayList(IEnumerable list)
        {
            ArrayList l = new ArrayList();
            foreach (object o in list)
                l.Add(o);
            return l;
        }

        protected Guid? ConvertToGuidByObject(PersistentObject obj)
        {
            if (obj == null)
                return null;

            return obj.ObjectID;
        }

        protected Guid? ConvertToGuidByObjectName(DataRow dr, string columnName, bool isRequired, SchemaBase mainTable)
        {
            object obj = dr[map[columnName]];

            if (isRequired && (obj == null || obj == DBNull.Value))
                throw new Exception("'" + map[columnName] + "' is required and cannot be left empty.");
            if (obj == null || obj == DBNull.Value)
                return null;

            string value = obj.ToString().Trim();

            ArrayList list = ConvertIEnumerableToArrayList(mainTable.LoadObjects(mainTable.ObjectName == value));
            if (list.Count == 0)
                throw new Exception("Unable to find a record in the table '" + mainTable.SchemaInfo.tableName + "' where the ObjectName = '" + value + "'.");
            if (list.Count > 1)
                throw new Exception("Found multiple records in the table '" + mainTable.SchemaInfo.tableName + "' where the ObjectName = '" + value + "'.");
            return ((PersistentObject)list[0]).ObjectID;
        }


        protected Guid? ConvertToGuidByHierarchicalPath(DataRow dr, string columnName, bool isRequired, char delimiter, SchemaBase mainTable)
        {
            object obj = dr[map[columnName]];

            if (isRequired && (obj == null || obj == DBNull.Value))
                throw new Exception("'" + map[columnName] + "' is required and cannot be left empty.");
            if (obj == null || obj == DBNull.Value)
                return null;

            string[] values = obj.ToString().Split(delimiter);

            ExpressionCondition cond = Query.True;
            SchemaBase currentTable = mainTable;
            for (int i = values.Length - 1; i >= 0; i--)
            {
                cond = cond & currentTable.ObjectName == values[i].Trim();
                currentTable = currentTable.ParentSchemaBase;
            }

            ArrayList list = ConvertIEnumerableToArrayList(mainTable.LoadObjects(cond));
            if (list.Count == 0)
                throw new Exception("Unable to find a record in the table '" + mainTable.SchemaInfo.tableName + "' where the path corresponds to '" + obj.ToString() + "'.");
            if (list.Count > 1)
                throw new Exception("Found multiple records in the table '" + mainTable.SchemaInfo.tableName + "' where the path corresponds to '" + obj.ToString() + "'.");
            return ((PersistentObject)list[0]).ObjectID;
        }


        protected string ConvertToString(DataRow dr, string columnName, bool isRequired)
        {
            object obj = dr[map[columnName]];

            if (isRequired && (obj == null || obj == DBNull.Value))
                throw new Exception("'" + map[columnName] + "' is required and cannot be left empty.");
            if (obj == null || obj == DBNull.Value)
                return null;

            string result = Convert.ToString(obj);
            if (result == null) return null;

            return result.Trim().Replace("，", ",");
        }


        protected decimal? ConvertToDecimal(DataRow dr, string columnName, bool isRequired)
        {
            object obj = dr[map[columnName]];

            if (isRequired && (obj == null || obj == DBNull.Value))
                throw new Exception("'" + map[columnName] + "' is required and cannot be left empty.");
            if (obj == null || obj == DBNull.Value)
                return null;

            try
            {
                return Convert.ToDecimal(obj);
            }
            catch
            {
                throw new Exception("Unable to convert '" + obj.ToString() + "' to decimal in the column '" + map[columnName] + "'.");
            }
        }

        protected DateTime? ConvertToDateTime(DataRow dr, string columnName, bool isRequired)
        {
            object obj = dr[map[columnName]];

            if (isRequired && (obj == null || obj == DBNull.Value))
                throw new Exception("'" + map[columnName] + "' is required and cannot be left empty.");
            if (obj == null || obj == DBNull.Value)
                return null;

            try
            {
                return Convert.ToDateTime(obj);
            }
            catch
            {
                throw new Exception("Unable to convert '" + obj.ToString() + "' to DateTime in the column '" + map[columnName] + "'.");
            }
        }

        protected Int32? ConvertToInt32(DataRow dr, string columnName, bool isRequired)
        {
            object obj = dr[map[columnName]];

            if (isRequired && (obj == null || obj == DBNull.Value))
                throw new Exception("'" + map[columnName] + "' is required and cannot be left empty.");
            if (obj == null || obj == DBNull.Value)
                return null;

            try
            {
                return Convert.ToInt32(obj);
            }
            catch
            {
                throw new Exception("Unable to convert '" + obj.ToString() + "' to Int32 in the column '" + map[columnName] + "'.");
            }
        }

        protected Int32? ConvertToEnumeratedInt(DataRow dr, string columnName, bool isRequired, string[] enumeratedStrings, int[] intValues)
        {
            object obj = dr[map[columnName]];

            if (isRequired && (obj == null || obj == DBNull.Value))
                throw new Exception("'" + map[columnName] + "' is required and cannot be left empty.");
            if (obj == null || obj == DBNull.Value)
                return null;

            for (int i = 0; i < enumeratedStrings.Length && i < intValues.Length; i++)
                if (obj.ToString().Trim().ToUpper() == enumeratedStrings[i].Trim().ToUpper())
                    return intValues[i];

            string expectedStrings = "";
            foreach (string enumeratedString in enumeratedStrings)
                expectedStrings += (expectedStrings == "" ? "" : ", ") + enumeratedStrings;

            throw new Exception("Could not recognize the following string '" + obj.ToString() + "' in the column '" + map[columnName] + "'. Expected: " + expectedStrings);
        }

        protected static void ActivateObject(PersistentObject obj)
        {
            //if it was deleted,activate it.
            if (obj.IsDeleted != 0)
            {
                using (Connection c = new Connection())
                {
                    obj.Activate();
                    obj.Save();
                    c.Commit();
                }
            }
        }

        protected static void SaveObject(PersistentObject obj)
        {
            using (Connection c = new Connection())
            {
                obj.Save();
                c.Commit();
            }
        }


    }
}
