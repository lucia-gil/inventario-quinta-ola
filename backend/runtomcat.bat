@echo off

set TOMCAT_DIR=%CATALINA_HOME%
set WAR_FILE=target\inventario.war
call mvn clean package

copy /Y %WAR_FILE% %TOMCAT_DIR%\webapps\

call %TOMCAT_DIR%\bin\startup.bat

echo.
echo Tomcat started!
echo Open:
echo http://localhost:8080/inventario
pause