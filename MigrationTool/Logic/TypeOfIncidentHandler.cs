using System;
using System.IO;
using System.Data;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;
using LogicLayer;


namespace DataMigration.Logic

{
   
    public class TypeOfIncidentHandler : Migratable
    {
        int i = 0;
        public TypeOfIncidentHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        {
        }
        public TypeOfIncidentHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        {
        }

        #region Migratable

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportTypes(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void ImportTypes(DataTable table)
        {
            OCode workCode = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == Strings.TypeOfWorkRootName, true, null);
            foreach (DataRow var in table.Rows)
            {
                try
                {//check Resolution CodeType whether it exists before migrating
                    //not overwrite priority if the type of problem exists

                    //step 1 import TypeOfWork 
                    string codeTypeName = "TypeOfIncident";
                    string mapColName = map[codeTypeName];
                    string codeData = ConvertToString(var[mapColName]);
                    if (codeData == null) continue;
                    OCode IncidentTypeCode = CreateCode(codeData, codeTypeName, workCode.ObjectID, true, null);

                }
                catch (Exception ex)
                {
                    var[ERROR_MSG_COL] = ex.Message;
                }
            }


        }
        private OCode ImportType(DataRow var, string codeTypeName, OCode parentCode,string pri)
        {
            string mapColName = map[codeTypeName];
            string typeName = ConvertToString(var[mapColName]);
            OCode code = null;
            //if (typeName == null)
            //{
            //    typeName = Strings.Types_Others;
            //}

            code = CreateCode(typeName, codeTypeName, parentCode.ObjectID, true,pri);
            return code;
        }

        private OCode CreateCode(string codeName, string codeTypeName, Guid? parentID, bool isNeedParent,string pri)
        {
            OCode code = null;
            OCodeType codeType = TablesLogic.tCodeType.Load(TablesLogic.tCodeType.ObjectName == codeTypeName & TablesLogic.tCodeType.IsDeleted==0, true, null);
                    if (null == codeType)
                throw new Exception("Code type name:" + codeTypeName + " Can't be found!");
            if (isNeedParent)
            {
                code = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == codeName & TablesLogic.tCode.ParentID == parentID & TablesLogic.tCode.CodeType.ObjectName == codeTypeName & TablesLogic.tCode.IsDeleted==0, true, null);
            }
            else
            {
                code = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == codeName & TablesLogic.tCode.CodeType.ObjectName == codeTypeName & TablesLogic.tCode.IsDeleted == 0, true, null);
            }
            if (null == code)//create new code
            {
                code = TablesLogic.tCode.Create();
                code.ObjectName = codeName;
                code.CodeTypeID = codeType.ObjectID;
                i = 0;
                
                /*if(pri!=null && pri!= string.Empty){
                    //create priority for type of problem
                    code.Priority=Convert.ToInt16(pri);
                    i = 1;
                }*/

                if (isNeedParent) code.ParentID = parentID;
                SaveObject(code);
            }
            ActivateObject(code);
            
            return code;
        }


        #endregion

    }
}
