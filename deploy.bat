@echo off
REM Windows deployment script for CSC Rahti
REM This is a simplified version of the bash script for Windows users

setlocal enabledelayedexpansion

REM Configuration
set PROJECT_NAME=csc-rahti-demo
set NAMESPACE=

REM Colors (basic Windows console)
set RED=[91m
set GREEN=[92m
set YELLOW=[93m
set BLUE=[94m
set NC=[0m

echo %BLUE%[INFO]%NC% CSC Rahti Deployment Script for Windows
echo.

REM Check if oc command is available
where oc >nul 2>nul
if %errorlevel% neq 0 (
    echo %RED%[ERROR]%NC% OpenShift CLI ^(oc^) is not installed or not in PATH
    echo %BLUE%[INFO]%NC% Please install OpenShift CLI from: https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/getting-started-cli.html
    pause
    exit /b 1
)

REM Check if logged in to OpenShift
oc whoami >nul 2>nul
if %errorlevel% neq 0 (
    echo %RED%[ERROR]%NC% Not logged in to OpenShift cluster
    echo %BLUE%[INFO]%NC% Please login using: oc login ^<cluster-url^>
    pause
    exit /b 1
)

echo %GREEN%[SUCCESS]%NC% Prerequisites check passed
echo.

REM Get current namespace if not set
if not defined NAMESPACE (
    for /f "tokens=*" %%i in ('oc project -q 2^>nul') do set NAMESPACE=%%i
)

if not defined NAMESPACE set NAMESPACE=default

echo %BLUE%[INFO]%NC% Using namespace: %NAMESPACE%
echo.

REM Parse command line argument
set COMMAND=%1
if not defined COMMAND set COMMAND=deploy

if "%COMMAND%"=="deploy" goto :deploy
if "%COMMAND%"=="build" goto :build
if "%COMMAND%"=="status" goto :status
if "%COMMAND%"=="logs" goto :logs
if "%COMMAND%"=="cleanup" goto :cleanup
if "%COMMAND%"=="help" goto :help
goto :unknown_command

:deploy
echo %BLUE%[INFO]%NC% Starting deployment...
call :build_image
call :deploy_application
call :wait_for_deployment
call :show_access_info
goto :end

:build
echo %BLUE%[INFO]%NC% Building image only...
call :build_image
goto :end

:status
echo %BLUE%[INFO]%NC% Showing deployment status...
call :show_status
goto :end

:logs
echo %BLUE%[INFO]%NC% Showing application logs...
oc logs -l app=%PROJECT_NAME% --tail=100 -f
goto :end

:cleanup
echo %YELLOW%[WARNING]%NC% This will delete all resources!
set /p CONFIRM="Are you sure you want to delete all resources? (y/N): "
if /i "%CONFIRM%"=="y" (
    echo %BLUE%[INFO]%NC% Cleaning up resources...
    oc delete all,configmap,secret,pvc,networkpolicy,hpa -l app=%PROJECT_NAME%
    oc delete imagestream,buildconfig %PROJECT_NAME% 2>nul
    echo %GREEN%[SUCCESS]%NC% Resources cleaned up
) else (
    echo %BLUE%[INFO]%NC% Cleanup cancelled
)
goto :end

:help
echo CSC Rahti Deployment Script for Windows
echo.
echo Usage: %0 [COMMAND]
echo.
echo Commands:
echo   deploy    Build and deploy the application ^(default^)
echo   build     Build the Docker image only
echo   status    Show deployment status
echo   logs      Show application logs
echo   cleanup   Remove all deployed resources
echo   help      Show this help message
echo.
echo Examples:
echo   %0 deploy
echo   %0 build
goto :end

:unknown_command
echo %RED%[ERROR]%NC% Unknown command: %COMMAND%
call :help
exit /b 1

:build_image
echo %BLUE%[INFO]%NC% Building Docker image...

REM Check if Dockerfile exists
if not exist "Dockerfile" (
    echo %RED%[ERROR]%NC% Dockerfile not found in current directory
    exit /b 1
)

REM Create ImageStream if it doesn't exist
oc get imagestream %PROJECT_NAME% >nul 2>nul
if %errorlevel% neq 0 (
    echo %BLUE%[INFO]%NC% Creating ImageStream...
    oc create imagestream %PROJECT_NAME%
)

REM Create BuildConfig if it doesn't exist
oc get buildconfig %PROJECT_NAME% >nul 2>nul
if %errorlevel% neq 0 (
    echo %BLUE%[INFO]%NC% Creating BuildConfig...
    oc new-build --name=%PROJECT_NAME% --binary --strategy=docker
)

REM Start build
echo %BLUE%[INFO]%NC% Starting binary build...
oc start-build %PROJECT_NAME% --from-dir=. --follow

echo %GREEN%[SUCCESS]%NC% Image built successfully
goto :eof

:deploy_application
echo %BLUE%[INFO]%NC% Deploying application to Rahti...

REM Apply Kubernetes manifests
echo %BLUE%[INFO]%NC% Applying ConfigMap and Secrets...
oc apply -f k8s/configmap.yaml

echo %BLUE%[INFO]%NC% Applying Deployment...
REM Note: Windows doesn't have sed, so we need to handle this differently
REM For now, users need to manually update the image in deployment.yaml
echo %YELLOW%[WARNING]%NC% Please update the image in k8s/deployment.yaml to:
echo image-registry.openshift-image-registry.svc:5000/%NAMESPACE%/%PROJECT_NAME%:latest
pause
oc apply -f k8s/deployment.yaml

echo %BLUE%[INFO]%NC% Applying Service and Route...
oc apply -f k8s/service.yaml

echo %BLUE%[INFO]%NC% Applying HPA...
oc apply -f k8s/hpa.yaml 2>nul || echo %YELLOW%[WARNING]%NC% HPA might not be supported in this cluster

echo %BLUE%[INFO]%NC% Applying Storage and Network policies...
oc apply -f k8s/storage-and-network.yaml 2>nul || echo %YELLOW%[WARNING]%NC% Some resources might not be supported

echo %GREEN%[SUCCESS]%NC% Application deployed successfully
goto :eof

:wait_for_deployment
echo %BLUE%[INFO]%NC% Waiting for deployment to be ready...
oc rollout status deployment/%PROJECT_NAME% --timeout=300s
echo %GREEN%[SUCCESS]%NC% Deployment is ready
goto :eof

:show_access_info
echo %BLUE%[INFO]%NC% Getting access information...

for /f "tokens=*" %%i in ('oc get route %PROJECT_NAME%-route -o jsonpath^="{.spec.host}" 2^>nul') do set ROUTE_URL=%%i

if defined ROUTE_URL (
    echo %GREEN%[SUCCESS]%NC% Application is accessible at: https://!ROUTE_URL!
    echo %BLUE%[INFO]%NC% Health check: https://!ROUTE_URL!/health
    echo %BLUE%[INFO]%NC% API endpoint: https://!ROUTE_URL!/api/data
) else (
    echo %YELLOW%[WARNING]%NC% Could not determine route URL. Check manually with: oc get routes
)

echo %BLUE%[INFO]%NC% Pod status:
oc get pods -l app=%PROJECT_NAME%
goto :eof

:show_status
echo %BLUE%[INFO]%NC% Deployment status:
echo.

echo Pods:
oc get pods -l app=%PROJECT_NAME%
echo.

echo Services:
oc get svc -l app=%PROJECT_NAME%
echo.

echo Routes:
oc get routes -l app=%PROJECT_NAME%
echo.

echo HPA:
oc get hpa -l app=%PROJECT_NAME% 2>nul || echo No HPA found
goto :eof

:end
echo.
echo %GREEN%[SUCCESS]%NC% Script completed
pause
