//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace LogicLayer
{
    public class WorkflowAssignmentException : Exception
    {
        public WorkflowAssignmentException(string message)
            : base(message)
        {
        }
    }
}
