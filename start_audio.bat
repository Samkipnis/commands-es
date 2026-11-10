@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
cd /d "%~dp0"
set "LOG=%~dp0run_audio_log.txt"
set "PYTHONIOENCODING=utf-8"
echo ==== %date% %time% ==== > "%LOG%"
echo Looking for Python...

echo --- diagnostics --- >> "%LOG%"
dir /b "%LOCALAPPDATA%\Programs\Python" >> "%LOG%" 2>&1
dir /b "%LOCALAPPDATA%\Programs\Python\Python313" >> "%LOG%" 2>&1
where python >> "%LOG%" 2>&1
where py >> "%LOG%" 2>&1
echo ------------------- >> "%LOG%"

set "PY="
for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python3*") do (
  if not defined PY if exist "%%~fD\python.exe" set "PY=%%~fD\python.exe"
)
if not defined PY if exist "%USERPROFILE%\anaconda3\python.exe" set "PY=%USERPROFILE%\anaconda3\python.exe"
if not defined PY if exist "%USERPROFILE%\miniconda3\python.exe" set "PY=%USERPROFILE%\miniconda3\python.exe"
if not defined PY if exist "%LOCALAPPDATA%\Programs\Python\Launcher\py.exe" set "PY=%LOCALAPPDATA%\Programs\Python\Launcher\py.exe"
if not defined PY if exist "%WINDIR%\py.exe" set "PY=%WINDIR%\py.exe"

if not defined PY (
  set "WG=%LOCALAPPDATA%\Microsoft\WindowsApps\winget.exe"
  if exist "!WG!" (
    echo Python not found. Installing Python 3.12 for this user with winget...
    echo Installing Python with winget >> "%LOG%"
    "!WG!" install -e --id Python.Python.3.12 --scope user --silent --accept-package-agreements --accept-source-agreements >> "%LOG%" 2>&1
    for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python3*") do if not defined PY if exist "%%~fD\python.exe" set "PY=%%~fD\python.exe"
  ) else (
    echo WINGET_MISSING >> "%LOG%"
  )
)
if not defined PY (
  echo PYTHON_MISSING >> "%LOG%"
  echo Could not find or install Python. See run_audio_log.txt
  goto end
)

echo Using Python: !PY!
echo PYTHON=!PY! >> "%LOG%"
"!PY!" --version >> "%LOG%" 2>&1

echo Installing edge-tts...
"!PY!" -m pip install --disable-pip-version-check --upgrade edge-tts >> "%LOG%" 2>&1
if errorlevel 1 (
  echo PIP_FAILED >> "%LOG%"
  echo pip install failed. See run_audio_log.txt
  goto end
)

echo Generating 132 audio files, about 1-2 minutes...
"!PY!" generate_audio.py >> "%LOG%" 2>&1
echo SCRIPT_EXIT=!errorlevel! >> "%LOG%"

:end
echo ==== FINISHED ==== >> "%LOG%"
echo.
echo Finished. You can close this window.
pause
