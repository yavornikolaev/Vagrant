@echo off
REM Change to the folder where this script lives
cd /d %~dp0
echo Starting Kubernetes cluster...

echo Starting master...
vagrant up k8s-master
echo Waiting 15 seconds for master to stabilize...
timeout /t 15 /nobreak >nul

echo Starting worker1...
vagrant up k8s-worker1 
echo Waiting 10 seconds...
timeout /t 10 /nobreak >nul

echo Starting worker2...
vagrant up k8s-worker2

echo All nodes started successfully.
pause
