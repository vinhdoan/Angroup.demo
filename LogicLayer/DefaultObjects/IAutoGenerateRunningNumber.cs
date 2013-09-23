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
    /// <summary>
    /// Represents an interface that can be tagged to any persistent
    /// object class so that it can have the capability to auto
    /// generate running numbers.
    /// <para></para>
    /// This interface should only be used sparingly on top-level
    /// objects like contract, work, scheduled work, store adjustment,
    /// store check-in, budget adjustment, budget reallocation,
    /// purchase orders.
    /// <para></para>
    /// It should never be used on sub-level objects like work cost
    /// items, purchase order items, etc, as the generation of running
    /// numbers can potentially slow the saving process.
    /// </summary>
    public interface IAutoGenerateRunningNumber
    {
    }
}
