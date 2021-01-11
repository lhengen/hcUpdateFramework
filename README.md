# hcUpdateFramework
An AutoUpdate Framework for Windows Applications

Requirements:
-------------
JCL
JVCL
FastMM4 
The DeploymentManager project requires the Developer Express Quantuum Grid and Editor controls
FireDAC or ADO must be used for database access
Colin Wilson's NTLowLevel library for the NTService project

Getting Started
---------------
1) created Environment variables in Delphi for the JVCL and JCL as shown in the Compiler Search Path below:
2) Adjust the Delphi version to one you are using in each project search path or add it to the Library Path

Current Delphi Compiler Search path in each project
..\Common;..\Register;$(jvcl)\lib\d27\win32;$(jcl)\lib\d27\win32
