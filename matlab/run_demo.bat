@echo off
REM ============================================================
REM   AERIS-10 CFAR MATLAB Demo - tek tik calistir
REM   MATLAB.exe nin yolunu kendine gore ayarla.
REM ============================================================

setlocal

REM MATLAB yolunu otomatik bul (en yeni surum)
set MATLAB_EXE=
for /d %%D in ("C:\Program Files\MATLAB\R*") do (
    if exist "%%D\bin\matlab.exe" set MATLAB_EXE=%%D\bin\matlab.exe
)
for /d %%D in ("C:\Program Files (x86)\MATLAB\R*") do (
    if exist "%%D\bin\matlab.exe" set MATLAB_EXE=%%D\bin\matlab.exe
)
for /d %%D in ("D:\Program Files\MATLAB\R*") do (
    if exist "%%D\bin\matlab.exe" set MATLAB_EXE=%%D\bin\matlab.exe
)

if "%MATLAB_EXE%"=="" (
    echo HATA: MATLAB.exe bulunamadi.
    echo Lutfen MATLAB_EXE degiskenini bu dosyada elle ayarla.
    pause
    exit /b 1
)

echo Calisiyor: %MATLAB_EXE%
echo.
cd /d "%~dp0"
"%MATLAB_EXE%" -batch "radar_cfar_demo; exit"

endlocal
