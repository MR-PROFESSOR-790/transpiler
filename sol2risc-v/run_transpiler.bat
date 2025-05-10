@echo off
setlocal

:: Check if Python is available
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Python not found in PATH
    exit /b 1
)

:: Run the transpiler with proper parameters
python src\transpiler\main.py %*

if %errorlevel% neq 0 (
    echo Transpilation failed with error code %errorlevel%
    exit /b %errorlevel%
)

echo Transpilation completed successfully
