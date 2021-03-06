using System;
using System.IO;
using System.Data;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;
using LogicLayer;


namespace DataMigration.Logic

{
   
    public class WorkCodeHandler : Migratable
    {
        int i = 0;
        public WorkCodeHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        {
        }
        public WorkCodeHandler(string mapfrom, string mapto, string sourcefile)
            : base(mapfrom, mapto, sourcefile)
        {
        }

        #region Migratable

        public override void Migarate()
        {
            try
            {
                DataTable table = GetDatasource();
                ImportWorkCodeHandler(table);
                Infrastructure.LogHelper.LogDataImport(mapfrom, table, map.Values);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void ImportWorkCodeHandler(DataTable table)
        {
            OCode workCode = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == Strings.TypeOfWorkRootName, true, null);
            foreach (DataRow var in table.Rows)
            {
                try
                {//check Resolution CodeType whether it exists before migrating
                    //not overwrite priority if the type of problem exists

                    //step 1 import TypeOfWork 
                    string codeTypeName = "TypeOfWork";
                    string mapColName = map[codeTypeName];
                    string workTypeName = ConvertToString(var[mapColName]);
                    if (workTypeName == null) continue;
                    OCode workTypeCode = CreateCode(workTypeName, codeTypeName, workCode.ObjectID, true, null);


                    //step 2 import TypeOfService 
                    codeTypeName = "TypeOfService";
                    string mapColService = map[codeTypeName];
                    string toService = ConvertToString(var[mapColService]);
                    //throw error if typeofservice is null
                    if (toService == null || toService.ToString() == string.Empty)
                    {
                        throw new Exception("Type of service is null");
                    }
                    OCode serviceTypeCode = ImportType(var, codeTypeName, workTypeCode, null);

                    //step 3 import TypeOfProblem
                    codeTypeName = "TypeOfProblem";
                    string mapColProblem = map[codeTypeName];
                    string toProblem = ConvertToString(var[mapColProblem]);
                    //throw error if typeofproblem is null
                    if (toProblem == null || toProblem.ToString() == string.Empty)
                    {
                        throw new Exception("Problem code is null");
                    }

                    //not required for MOE
                    string codeTypeName2 = "Priority";
                    string mapColName2 = map[codeTypeName2];
                    string prio = ConvertToString(var[mapColName2]);

                    OCode problemTypeCode = ImportType(var, codeTypeName, serviceTypeCode, prio);

                    //step4 import CauseOfProblem
                    codeTypeName = "CauseOfProblem";
                    string mapColCause = map[codeTypeName];
                    string CauseOfp = ConvertToString(var[mapColCause]);
                    OCode CauseOfProblem = null;
                    //throw error if CauseOfProblem is null

                    if (CauseOfp != null && CauseOfp.Length > 0 && !CauseOfp.Equals("-"))
                        CauseOfProblem = ImportType(var, codeTypeName, problemTypeCode, null);

                    codeTypeName = "Resolution";
                    string mapColRe = map[codeTypeName];
                    string re = ConvertToString(var[mapColRe]);
                    if (re == null || re.ToString() == string.Empty)
                    {
                        continue;
                    }
                    if (re != null && CauseOfp == null)
                    {
                        throw new Exception("Cause of Problem is null");
                    }
                    OCode Resolution = ImportType(var, codeTypeName, CauseOfProblem, null);

                    if (i == 1)
                        throw new Exception("This is new type of problem");

                }
                catch (Exception ex)
                {
                    var[ERROR_MSG_COL] = ex.Message;
                }
            }


        }
        private OCode ImportType(DataRow var, string codeTypeName, OCode parentCode, string pri)
        {
            string mapColName = map[codeTypeName];
            string typeName = ConvertToString(var[mapColName]);
            OCode code = null;
           
            code = CreateCode(typeName, codeTypeName, parentCode.ObjectID, true, pri);
            return code;
        }

        private OCode CreateCode(string codeName, string codeTypeName, Guid? parentID, bool isNeedParent, string pri)
        {
            OCode code = null;
            OCodeType codeType = TablesLogic.tCodeType.Load(TablesLogic.tCodeType.ObjectName == codeTypeName & TablesLogic.tCodeType.IsDeleted == 0, true, null);
            if (null == codeType)
                throw new Exception("Code type name:" + codeTypeName + " Can't be found!");
            if (isNeedParent)
            {
                code = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == codeName & TablesLogic.tCode.ParentID == parentID & TablesLogic.tCode.CodeType.ObjectName == codeTypeName & TablesLogic.tCode.IsDeleted == 0, true, null);
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

                if (isNeedParent) code.ParentID = parentID;
                SaveObject(code);
            }
            ActivateObject(code);

            return code;
        } 

        #endregion

    }
}
