@echo off
echo Stopping Flask...
taskkill /f /im python.exe 2>nul
timeout /t 2 /nobreak >nul

echo Starting Flask...
start /b python app.py
timeout /t 3 /nobreak >nul

echo Running Newman...
newman run SCSS_API_Tests.postman_collection.json -e SCSS_Environment.postman_environment.json --reporters cli,htmlextra --reporter-htmlextra-export reports/api_test_report.html --delay-request 200