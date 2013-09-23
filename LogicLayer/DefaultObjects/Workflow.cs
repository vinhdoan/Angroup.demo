using System;
using System.IO;
using System.Collections.Generic;
using System.Text;
using Anacle.WorkflowFramework;
using Anacle.DataFramework;

namespace LogicLayer
{
    public class Workflow
    {
        /// <summary>
        /// An OUser object of the user currently logged on 
        /// to the system.
        /// </summary>
        [ThreadStatic]
        private static OUser currentUser;


        /// <summary>
        /// Gets or sets the User object of the user
        /// currently logged on to the system.
        /// </summary>
        public static OUser CurrentUser
        {
            get { return currentUser; }
            set { currentUser = value; }
        }


        /// <summary>
        /// Creates a persistent object and a workflow instance.
        /// </summary>
        /// <returns></returns>
        public static LogicLayerPersistentObject CreateWorkflowForPersistentObject(LogicLayerPersistentObject persistentObject)
        {
            string currentStateName = "-";
			//string workflowInstanceId = WorkflowEngine.Engine.CreateWorkflow(persistentObject, ref currentStateName);
            int workflowVersionNumber = 0;
            string workflowInstanceId = WorkflowEngine.Engine.CreateWorkflow(persistentObject, ref currentStateName, out workflowVersionNumber);

            if (persistentObject.CurrentActivity == null)
            {
                persistentObject.CurrentActivity = TablesLogic.tActivity.Create();
                persistentObject.CurrentActivity.ObjectTypeName = persistentObject.GetType().BaseType.Name;
                persistentObject.CurrentActivity.ObjectName = currentStateName;
                persistentObject.CurrentActivity.WorkflowVersionNumber = workflowVersionNumber;
            }
            persistentObject.CurrentActivity.WorkflowInstanceID = workflowInstanceId;
            return persistentObject;
        }
        public static LogicLayerPersistentObject CreateWorkflowForPersistentObjecttemp(LogicLayerPersistentObject persistentObject)
        {
            string currentStateName = persistentObject.CurrentActivity.CurrentStateName;
			//string workflowInstanceId = WorkflowEngine.Engine.CreateWorkflow(persistentObject, ref currentStateName);
            int workflowVersionNumber = 0;
            string workflowInstanceId = WorkflowEngine.Engine.CreateWorkflow(persistentObject, ref currentStateName, out workflowVersionNumber);
            persistentObject.CurrentActivity.WorkflowInstanceID = workflowInstanceId;
            return persistentObject;
        }
    }
}
