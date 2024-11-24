@echo off
setlocal enabledelayedexpansion

:: Prompt for project name and version
set /p projectName=Enter project name: 
set /p version=Enter version: 

:: Get the current directory
set currentDir=%cd%

:: Define the new folder name
set newFolder=[CS2] %projectName% %version%

:: Handle folder creation step by step
echo Creating directory structure...
mkdir "%currentDir%\%newFolder%\plugins"
mkdir "%currentDir%\%newFolder%\plugins\%projectName%"
mkdir "%currentDir%\%newFolder%\source"
mkdir "%currentDir%\%newFolder%\source\%projectName%"

:: Copy all .cs files
echo Copying .cs files...
for %%F in ("%currentDir%\*.cs") do (
    echo Copying: %%F
    copy "%%F" "%currentDir%\%newFolder%\source\%projectName%\"
)

:: Copy .csproj file
echo Copying .csproj file...
for %%F in ("%currentDir%\*.csproj") do (
    echo Copying: %%F
    copy "%%F" "%currentDir%\%newFolder%\source\%projectName%\"
)

:: Copy .dll files from bin\Debug\net8.0 to plugins/%projectName%/
echo Copying .dll files from bin\Debug\net8.0...

set "sourceDir=%currentDir%\bin\Debug\net8.0"
set "targetDir=%currentDir%\%newFolder%\plugins\%projectName%"

:: Check if source directory exists
if not exist "%sourceDir%" (
    echo Source directory "%sourceDir%" does not exist! Skipping .dll copy.
) else (
    :: Create the target directory if it doesn't exist
    if not exist "%targetDir%" (
        mkdir "%targetDir%"
    )

    :: Copy only .dll files from bin\Debug\net8.0
    for %%F in ("%sourceDir%\*.dll") do (
        echo Copying: %%F
        copy "%%F" "%targetDir%\"
    )

    :: Use robocopy to copy all folders and their contents, excluding .pdb and .deps.json files
    echo Copying folders from bin\Debug\net8.0...
    robocopy "%sourceDir%" "%targetDir%" /e /NFL /NDL /NJH /NJS /R:1 /W:1 /XF *.pdb *.deps.json
)

:: Now, zip the created folder using 7-Zip
echo Zipping the folder "%newFolder%" using 7-Zip...

:: Define the path to 7z.exe (update if needed)
set "zipPath=C:\Program Files\7-Zip\7z.exe"

:: Check if 7z.exe exists
if not exist "%zipPath%" (
    echo 7-Zip not found. Please install 7-Zip or update the path.
    pause
    exit /b
)

:: Zip the folder using 7-Zip
"%zipPath%" a -tzip "%currentDir%\%newFolder%.zip" "%currentDir%\%newFolder%\*"

:: Check if the zip file exists
if exist "%currentDir%\%newFolder%.zip" (
    echo Zip file created successfully: %newFolder%.zip
) else (
    echo Failed to create zip file. Check for errors.
)

:: Delete the temporary project structure folder
echo Deleting project structure folder...
rmdir /s /q "%currentDir%\%newFolder%"

pause
