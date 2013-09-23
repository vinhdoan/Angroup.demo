//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 5.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration.Install;

namespace Service
{
    [RunInstaller(true)]
    public partial class ProjectInstaller : Installer
    {
        public ProjectInstaller()
        {
            InitializeComponent();
            this.serviceInstaller1.ServiceName = GlobalService.ServiceName;
            this.serviceInstaller1.Description = GlobalService.ServiceDescription;
            this.serviceInstaller1.StartType = System.ServiceProcess.ServiceStartMode.Automatic;
            
        }

        private void serviceInstaller1_AfterInstall(object sender, InstallEventArgs e)
        {

        }
    }
}