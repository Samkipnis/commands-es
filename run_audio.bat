@echo off
setlocal EnableExtensions
chcp 65001 >nul
cd /d "%~dp0"
set "LOG=%~dp0run_audio_log.txt"
set "PYTHONIOENCODING=utf-8"
echo ==== %date% %time% ==== > "%LOG%"
echo Looking for Python...

set "PY="
for %%R in ("%USERPROFILE%\anaconda3" "%USERPROFILE%\miniconda3" "%LOCALAPPDATA%\anaconda3" "%LOCALAPPDATA%\miniconda3" "%PROGRAMDATA%\anaconda3" "%PROGRAMDATA%\miniconda3") do (
  if not defined PY if exist "%%~R\python.exe" (
    set "PY=%%~R\python.exe"
    set "PATH=%%~R;%%~R\Library\bin;%%~R\Scripts;%PATH%"
  )
)
if not defined PY (
  for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python3*") do if not defined PY if exist "%%~D\python.exe" set "PY=%%~D\python.exe"
)
if not defined PY (
  where py >nul 2>&1 && set "PY=py"
)

if not defined PY (
  echo Python not found. Installing Python 3.12 for this user with winget...
  echo Python not found - installing with winget >> "%LOG%"
  winget install -e --id Python.Python.3.12 --scope user --silent --accept-package-agreements --accept-source-agreements >> "%LOG%" 2>&1
  for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python3*") do if not defined PY if exist "%%~D\python.exe" set "PY=%%~D\python.exe"
)
if not defined PY (
  echo PYTHON_MISSING >> "%LOG%"
  echo Could not find or install Python. See run_audio_log.txt
  goto end
)

echo Using Python: %PY%
echo PYTHON=%PY% >> "%LOG%"
"%PY%" --version >> "%LOG%" 2>&1

echo Installing edge-tts...
"%PY%" -m pip install --disable-pip-version-check --upgrade edge-tts >> "%LOG%" 2>&1
if errorlevel 1 (
  echo PIP_FAILED >> "%LOG%"
  echo pip install failed. See run_audio_log.txt
  goto end
)

echo Generating 132 audio files, about 1-2 minutes...
"%PY%" generate_audio.py >> "%LOG%" 2>&1
echo SCRIPT_EXIT=%errorlevel% >> "%LOG%"

:end
echo ==== FINISHED ==== >> "%LOG%"
echo.
echo Finished. You can close this window.
pause
