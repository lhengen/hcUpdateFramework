# hcUpdateFramework
An AutoUpdate Framework for Windows Applications

Requirements:
-------------
JCL  
JVCL  
FastMM4  
The DeploymentManager project requires the Developer Express Quantuum Grid and Editor controls.  It also makes use of the hcOPF project. 
FireDAC or ADO must be used for database access 
SQL Server and Firebird databases are supported, but the SQL Server scripts need to be updated
Colin Wilson's NTLowLevel library for the NTService project

Getting Started
---------------
1) Create Environment variables in Delphi for the JVCL and JCL as shown in the Compiler Search Path below:
2) Adjust the Delphi version to the one you are using in each project search path or add it to the Library Path

Current Delphi Compiler Search path present in each project:
  ..\Common;..\Register;$(jvcl)\lib\d27\win32;$(jcl)\lib\d27\win32
  
You may wish to delete the DPPROJ file and have the IDE re-create it, depending on the version of Delphi you're using.  If so, be sure to add the search paths.

Documentation is of course in the Docs folder...

Acknowledgements
---------------
 Colin Wilson -for his NTLowLevel library which sadly seemed to disappear from the Net so it's included here   
 The DelphiDabbler - for his SysInfo units used to generate a fingerprint for the machine registering the application   
 Glen Vlotman - for the the Patching API translation and Delphi implementation   
 And Of course the contributors to the JCL/JVCL   
