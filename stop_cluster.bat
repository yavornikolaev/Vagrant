@echo off
REM Change to the folder where this script lives
cd /d %~dp0
echo Shutting down Kubernetes cluster...

echo Stopping worker1...
vagrant halt k8s-worker1

echo Stopping worker2...
vagrant halt k8s-worker2

echo Stopping master...
vagrant halt k8s-master

echo All nodes stopped safely.
pause