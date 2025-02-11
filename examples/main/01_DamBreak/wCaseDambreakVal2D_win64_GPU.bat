@echo off

rem "name" and "dirout" are named according to the testcase

set name=CaseDambreakVal2D
set dirout=%name%_out
set diroutdata=%dirout%\data

rem "executables" are renamed and called from their directory

set dirbin=../../../bin/windows
set gencase="%dirbin%/GenCase4_win64.exe"
set dualsphysicscpu="%dirbin%/DualSPHysics4.4CPU_win64.exe"
set dualsphysicsgpu="%dirbin%/DualSPHysics4.4_win64.exe"
set boundaryvtk="%dirbin%/BoundaryVTK4_win64.exe"
set partvtk="%dirbin%/PartVTK4_win64.exe"
set partvtkout="%dirbin%/PartVTKOut4_win64.exe"
set measuretool="%dirbin%/MeasureTool4_win64.exe"
set computeforces="%dirbin%/ComputeForces4_win64.exe"
set isosurface="%dirbin%/IsoSurface4_win64.exe"
set flowtool="%dirbin%/FlowTool4_win64.exe"
set floatinginfo="%dirbin%/FloatingInfo4_win64.exe"

rem "dirout" to store results is removed if it already exists
if exist %dirout% rd /s /q %dirout%

rem CODES are executed according the selected parameters of execution in this testcase

rem Executes GenCase4 to create initial files for simulation.
%gencase% %name%_Def %dirout%/%name% -save:all
if not "%ERRORLEVEL%" == "0" goto fail

rem Executes DualSPHysics to simulate SPH method.
%dualsphysicsgpu% -gpu %dirout%/%name% %dirout% -dirdataout data -svres
if not "%ERRORLEVEL%" == "0" goto fail

rem Executes PartVTK4 to create VTK files with particles.
set dirout2=%dirout%\particles
%partvtk% -dirin %diroutdata% -savevtk %dirout2%/PartFluid -onlytype:-all,fluid -vars:+idp,+vel,+rhop,+press,+vor
if not "%ERRORLEVEL%" == "0" goto fail

%partvtk% -dirin %diroutdata% -savevtk %dirout2%/PartBound -onlytype:-all,bound -vars:-all -last:0
if not "%ERRORLEVEL%" == "0" goto fail

rem Executes PartVTKOut4 to create VTK files with excluded particles.
%partvtkout% -dirin %diroutdata% -savevtk %dirout2%/PartFluidOut -SaveResume %dirout2%/_ResumeFluidOut
if not "%ERRORLEVEL%" == "0" goto fail

rem Executes IsoSurface4 to create VTK files with slices of surface.
set dirout2=%dirout%\surface
%isosurface% -dirin %diroutdata% -saveslice %dirout2%/Slices 
if not "%ERRORLEVEL%" == "0" goto fail


:success
echo All done
goto end

:fail
echo Execution aborted.

:end
pause

