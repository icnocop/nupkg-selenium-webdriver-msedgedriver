@echo off

if [%~1]==[] goto :noversion

set version=%1
set nugetFile=Selenium.WebDriver.MSEdgeDriver.nuspec

mkdir .\download\%version%
echo  Downloading %version%

if [%~2]==[] copy Selenium.WebDriver.MSEdgeDriver.template.nuspec %nugetFile%
if [%~2]==[pre] copy Selenium.WebDriver.MSEdgeDriver.template-pre.nuspec %nugetFile%
if not exist %nugetFile% GOTO :finish

curl -fL https://msedgedriver.microsoft.com/%version%/edgedriver_win32.zip -o .\download\%version%\edgedriver_win32.zip || exit /b 1
curl -fL https://msedgedriver.microsoft.com/%version%/edgedriver_win64.zip -o .\download\%version%\edgedriver_win64.zip || exit /b 1
curl -fL https://msedgedriver.microsoft.com/%version%/edgedriver_mac64.zip -o .\download\%version%\edgedriver_mac64.zip || exit /b 1
curl -fL https://msedgedriver.microsoft.com/%version%/edgedriver_linux64.zip -o .\download\%version%\edgedriver_linux64.zip || exit /b 1

PowerShell -Command "Expand-Archive -Path .\download\%version%\edgedriver_win32.zip -DestinationPath .\download\%version%\edgedriver_win32"
if not exist .\download\%version%\edgedriver_win32\msedgedriver.exe PowerShell -Command "(Get-Content -path %nugetFile% -Raw) -replace '<file src=\"download\\_version_\\edgedriver_win32\\msedgedriver.exe\" target=\"driver/win32\"/>','' | Set-Content -Path %nugetFile% "

PowerShell -Command "Expand-Archive -Path .\download\%version%\edgedriver_win64.zip -DestinationPath .\download\%version%\edgedriver_win64"
if not exist .\download\%version%\edgedriver_win64\msedgedriver.exe PowerShell -Command "(Get-Content -path %nugetFile% -Raw) -replace '<file src=\"download\\_version_\\edgedriver_win64\\msedgedriver.exe\" target=\"driver/win64\"/>','' | Set-Content -Path %nugetFile% "

PowerShell -Command "Expand-Archive -Path .\download\%version%\edgedriver_mac64.zip -DestinationPath .\download\%version%\edgedriver_mac64"
if not exist .\download\%version%\edgedriver_mac64\msedgedriver PowerShell -Command "(Get-Content -path %nugetFile% -Raw) -replace '<file src=\"download\\_version_\\edgedriver_mac64\\msedgedriver\" target=\"driver/mac64/msedgedriver\"/>','' | Set-Content -Path %nugetFile% "

PowerShell -Command "Expand-Archive -Path .\download\%version%\edgedriver_linux64.zip -DestinationPath .\download\%version%\edgedriver_linux64"
if not exist .\download\%version%\edgedriver_linux64\msedgedriver PowerShell -Command "(Get-Content -path %nugetFile% -Raw) -replace '<file src=\"download\\_version_\\edgedriver_linux64\\msedgedriver\" target=\"driver/linux64/msedgedriver\"/>','' | Set-Content -Path %nugetFile% "

PowerShell -Command "(Get-Content -path %nugetFile% -Raw) -replace '_version_','%version%' | Set-Content -Path %nugetFile% "

nuget pack %nugetFile% -OutputDirectory .\dist

echo Removing temp files ...
del /F /Q /S download\%version%
rmdir /S /Q download\%version%
del %nugetFile%
echo Done
echo to publish run:
if [%~2]==[] echo nuget push -Source nuget.org -ApiKey %NUGETPUSHAPIKEY% .\dist\Selenium.WebDriver.MSEdgeDriver.%version%.nupkg
if [%~2]==[pre] echo nuget push -Source nuget.org -ApiKey %NUGETPUSHAPIKEY% .\dist\Selenium.WebDriver.MSEdgeDriver.%version%-pre.nupkg
goto :finish

:noversion
echo .
echo .
echo missing version parameter
echo usage: getPackage.bat VERSION [pre]
echo Example
echo getPackage.bat 81.12.654
echo or
echo getPackage.bat 81.12.654 pre   ----- this generates a nuget package with a pre release version for testing.
echo .
echo .
echo to get your system's MsEdge version:
echo powershell.exe (Get-Item '"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"').VersionInfo
:finish
