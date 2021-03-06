using System;
using System.IO;
using System.Data;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;
using LogicLayer;


namespace DataMigration.Logic

{
   
    public class TypeOfServiceHandler : Migratable
    {
        public TypeOfServiceHandler(string mapfrom, string mapto)
            : base(mapfrom, mapto)
        {
        }
        public TypeOfServiceHandler(string mapfrom, string mapto, string sourcefile)
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
                    string codeTypeName = "TypeOfWork";
                    string mapColName = map["Work Type"];
                    string workTypeName = ConvertToString(var[mapColName]);
                    if (workTypeName == null) continue;
                    OCode workTypeCode = CreateCode(workTypeName, codeTypeName, workCode.ObjectID);


                    //step 2 import TypeOfService 
                    codeTypeName = "TypeOfService";
                    string mapColService = map["Type of Service"];
                    string toService = ConvertToString(var[mapColService]);
                    //throw error if typeofservice is null
                    if (toService == null || toService.ToString() == string.Empty) {
                        throw new Exception("Type of service is null");
                    }
                    OCode serviceTypeCode = CreateCode(toService, codeTypeName, workTypeCode.ObjectID); 

                    //step 3 import TypeOfProblem
                    codeTypeName = "TypeOfProblem";
                    string mapColProblem = map["Problem Code"];
                    string toProblem = ConvertToString(var[mapColProblem]);
                    //throw error if typeofproblem is null
                    if (toProblem == null || toProblem.ToString() == string.Empty)
                    {
                        throw new Exception("Type of Problem is null");
                    }

                    //not required for MOE
                    //string codeTypeName2 = "Priority";
                    //string mapColName2 = map["Priority"];
                    //string prio = ConvertToString(var[mapColName2]);

                    OCode problemTypeCode = CreateCode(toProblem, codeTypeName, serviceTypeCode.ObjectID);

                    //step4 import CauseOfProblem
                    codeTypeName = "CauseOfProblem";
                    string mapColCause = map["Cause of Problem"];
                    string CauseOfp = ConvertToString(var[mapColCause]);
                    OCode CauseOfProblem = null;
                    //throw error if CauseOfProblem is null
                   
                    if (CauseOfp != null && CauseOfp.Length > 0 && !CauseOfp.Equals("-"))
                        CauseOfProblem = CreateCode(CauseOfp, codeTypeName, problemTypeCode.ObjectID);

                    codeTypeName = "Resolution";
                    string mapColRe = map[codeTypeName];
                    string re = ConvertToString(var[mapColRe]);

                    if (re == null || re.Trim().Length == 0)
                        continue;
                    else if (re != null && CauseOfProblem == null)
                        throw new Exception("Cause of Problem is null or not found");
                    
                    OCode Resolution = CreateCode(re, codeTypeName, CauseOfProblem.ObjectID);
                   

                }
                catch (Exception ex)
                {
                    var[ERROR_MSG_COL] = ex.Message;
                }
            }


        }

        private OCode CreateCode(string codeName, string codeTypeName, Guid? parentID)
        {
            OCode code = null;
            OCodeType codeType = TablesLogic.tCodeType.Load(TablesLogic.tCodeType.ObjectName == codeTypeName);
                  
            if (null == codeType)
                throw new Exception("Code type name:" + codeTypeName + " Can't be found!");
            
            code = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == codeName 
                & TablesLogic.tCode.ParentID == parentID 
                & TablesLogic.tCode.CodeType.ObjectName == codeTypeName, true);
            
            if (code == null)//create new code
            {
                code = TablesLogic.tCode.Create();
                code.ObjectName = codeName;
                code.CodeTypeID = codeType.ObjectID;                
                code.ParentID = parentID;
            }

            SaveObject(code);
            ActivateObject(code);
            
            return code;
        } 

        #endregion

    }
}
