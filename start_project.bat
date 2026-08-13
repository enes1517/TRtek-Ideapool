@echo off
title TRtek Fikir Havuzu - Proje Baslatici

:: Flutter PATH tanimini ekle (C:\flutter\bin)
set PATH=%PATH%;C:\flutter\bin

echo ========================================================
echo  TRtek Fikir Havuzu Web API ve Flutter Baslatiliyor...
echo ========================================================
echo.

echo [1/2] ASP.NET Core Web API baslatiliyor (HTTPS)...
start "Backend - Web API" cmd /k "cd /d "%~dp0IdeaPool\IdeaPool" && dotnet run --launch-profile https"

echo [2/2] Flutter Frontend uygulamasi baslatiliyor...
start "Frontend - Flutter" cmd /k "set PATH=%%PATH%%;C:\flutter\bin && cd /d "%~dp0IdeaPoolMobile" && flutter run -d chrome --web-port 53035"

echo.
echo ========================================================
echo  Hem Backend hem Frontend ayri pencerelerde baslatildi!
echo ========================================================
pause
