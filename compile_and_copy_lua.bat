@echo off
set HKSC=.\hksc.exe
set FRONTEND=.\Lua\Frontend Side
set INGAME=.\Lua\In-Game Side
REM could be set to "internals" instead of "mods", but mods for faster reload
set OUT=C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua
REM -g also writes <name>.luacallstackdb (function names and lines for the client's Lua stacks) and <name>.luadebug (not used)
set DEBUG=-g "--file-prefix-map=%CD%\="

echo [Frontend]
for /r "%FRONTEND%" %%F in (*.Lua) do (
    echo Compiling %%~nxF...
    "%HKSC%" "%%F" %DEBUG% -o "%OUT%\Frontend\%%~nF.luac"
    if errorlevel 1 (
        echo [FAIL] %%~nxF
        exit /b 1
    )
)

echo.
echo [In-Game]
for /r "%INGAME%" %%F in (*.Lua) do (
    echo Compiling %%~nxF...
    "%HKSC%" "%%F" %DEBUG% -o "%OUT%\Game\%%~nF.luac"
    if errorlevel 1 (
        echo [FAIL] %%~nxF
        exit /b 1
    )
)

echo.
del /q "%OUT%\Frontend\*.luadebug" "%OUT%\Game\*.luadebug" 2>nul

echo All files compiled successfully.