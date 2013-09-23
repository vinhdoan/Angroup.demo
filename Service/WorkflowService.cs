using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

using Anacle.DataFramework;
using Anacle.WorkflowFramework;

namespace Service
{
    /// <summary>
    /// This service is responsible for running workflows
    /// whose timers are due.
    /// </summary>
    public class WorkflowService : AnacleServiceBase
    {
        /// <summary>
        /// Loads and runs the workflow.
        /// </summary>
        public override void OnExecute()
        {
            //DataTable dt = TablesWorkflow.tWorkflowInstanceState.Select(
            //    TablesWorkflow.tWorkflowInstanceState.InstanceID)
            //    .Where(
            //    TablesWorkflow.tWorkflowInstanceState.Status == 0 &
            //    TablesWorkflow.tWorkflowInstanceState.NextTimer <= DateTime.UtcNow);

            //foreach (DataRow dr in dt.Rows)
            //{
            //    try
            //    {
            //        WorkflowEngine.Engine.RunWorkflow(dr["InstanceID"].ToString());
            //        LogEvent("Workflow Instance '" + dr["InstanceID"].ToString() + "' executed successfully.");
            //    }
            //    catch(Exception ex)
            //    {
            //        LogEvent("Workflow Instance '" + dr["InstanceID"].ToString() + "' execution failed with the following Exception:\n" + ex.Message + "\n" + ex.StackTrace);
            //    }
            //}
        }
    }
}
