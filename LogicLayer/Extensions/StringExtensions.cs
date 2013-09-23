using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace LogicLayer
{
    public static class Extensions
    {
        /// <summary>
        /// Checks if the source string is contained in any of the items
        /// as specified in the items.
        /// </summary>
        /// <param name="s"></param>
        /// <returns></returns>
        public static bool Is(this string source, params string[] items)
        {
            if (items != null)
                foreach (string item in items)
                    if (source == item)
                        return true;
            return false;
        }
        /// <summary>
        /// Translates the object type based on resource file
        /// </summary>
        /// <param name="source"></param>
        /// <returns></returns>
        public static string TranslateObjectType(this string source)
        {
            string name = Resources.Objects.ResourceManager.GetString(source);

            if (name != null && name != "")
                return name;

            return source;

        }
        /// <summary>
        /// Translates the workflow state based on resource file
        /// </summary>
        /// <param name="source"></param>
        /// <returns></returns>
        public static string TranslateWorkflowState(this string source)
        {
            string name = Resources.WorkflowStates.ResourceManager.GetString(source);

            if (name != null && name != "")
                return name;

            return source;
        }
    }
}
