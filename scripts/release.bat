@echo off
setlocal enabledelayedexpansion

REM Gotify Client Flutter 发布脚本 (Windows版本)
REM 用于快速创建和发布新版本

REM 检查是否在项目根目录
if not exist "pubspec.yaml" (
    echo [ERROR] 请在项目根目录运行此脚本
    pause
    exit /b 1
)

REM 检查是否有未提交的更改
git status --porcelain > temp_status.txt
for /f %%i in (temp_status.txt) do (
    echo [WARNING] 检测到未提交的更改:
    git status --short
    echo.
    set /p "continue=是否继续? (y/N): "
    if /i not "!continue!"=="y" (
        echo [INFO] 发布已取消
        del temp_status.txt
        pause
        exit /b 1
    )
    goto :continue
)
:continue
del temp_status.txt

REM 获取当前版本
for /f "tokens=2 delims= " %%a in ('findstr "^version:" pubspec.yaml') do (
    set "full_version=%%a"
)
for /f "tokens=1 delims=+" %%a in ("!full_version!") do (
    set "current_version=%%a"
)
echo [INFO] 当前版本: !current_version!

REM 获取新版本号
if "%1"=="" (
    echo.
    echo 请输入新版本号 (格式: x.y.z, 例如: 1.0.0):
    set /p "new_version=新版本: "
) else (
    set "new_version=%1"
)

REM 验证版本号格式 (简单验证)
echo !new_version! | findstr /r "^[0-9]*\.[0-9]*\.[0-9]*$" >nul
if errorlevel 1 (
    echo [ERROR] 版本号格式无效。请使用 x.y.z 格式 (例如: 1.0.0)
    pause
    exit /b 1
)

REM 检查版本号是否已存在
git tag | findstr "^v!new_version!$" >nul
if not errorlevel 1 (
    echo [ERROR] 版本 v!new_version! 已存在
    pause
    exit /b 1
)

echo [INFO] 准备发布版本: !new_version!

REM 确认发布
echo.
echo [WARNING] 即将执行以下操作:
echo   1. 更新 pubspec.yaml 中的版本号
echo   2. 运行代码生成和测试
echo   3. 提交更改
echo   4. 创建并推送版本标签
echo   5. 触发 GitHub Actions 自动构建和发布
echo.
set /p "confirm=确认继续? (y/N): "
if /i not "!confirm!"=="y" (
    echo [INFO] 发布已取消
    pause
    exit /b 1
)

echo [INFO] 开始发布流程...

REM 1. 更新版本号
echo [INFO] 更新版本号到 !new_version!
for /f "tokens=2 delims=+" %%a in ("!full_version!") do (
    set /a "new_build_number=%%a+1"
)

REM 创建临时文件来更新版本
powershell -Command "(Get-Content pubspec.yaml) -replace '^version: .*', 'version: !new_version!+!new_build_number!' | Set-Content pubspec.yaml"

REM 2. 获取依赖
echo [INFO] 获取依赖包...
flutter pub get
if errorlevel 1 (
    echo [ERROR] 获取依赖失败
    pause
    exit /b 1
)

REM 3. 运行代码生成
echo [INFO] 运行代码生成...
flutter packages pub run build_runner build --delete-conflicting-outputs
if errorlevel 1 (
    echo [ERROR] 代码生成失败
    pause
    exit /b 1
)

REM 4. 代码分析
echo [INFO] 运行代码分析...
flutter analyze
if errorlevel 1 (
    echo [ERROR] 代码分析失败，请修复问题后重试
    pause
    exit /b 1
)

REM 5. 运行测试
echo [INFO] 运行测试...
flutter test
if errorlevel 1 (
    echo [ERROR] 测试失败，请修复问题后重试
    pause
    exit /b 1
)

REM 6. 提交更改
echo [INFO] 提交版本更新...
git add pubspec.yaml
git commit -m "chore: bump version to !new_version!"
if errorlevel 1 (
    echo [ERROR] 提交失败
    pause
    exit /b 1
)

REM 7. 创建标签
echo [INFO] 创建版本标签 v!new_version!
git tag -a "v!new_version!" -m "Release version !new_version!"
if errorlevel 1 (
    echo [ERROR] 创建标签失败
    pause
    exit /b 1
)

REM 8. 推送更改和标签
echo [INFO] 推送到远程仓库...
git push origin main
if errorlevel 1 (
    echo [ERROR] 推送主分支失败
    pause
    exit /b 1
)

git push origin "v!new_version!"
if errorlevel 1 (
    echo [ERROR] 推送标签失败
    pause
    exit /b 1
)

echo [SUCCESS] 版本 v!new_version! 发布成功!
echo [INFO] GitHub Actions 将自动开始构建和发布流程
echo [INFO] 请访问 GitHub Actions 页面查看构建进度
echo [INFO] 发布完成后，可在 GitHub Releases 页面下载构建产物

echo.
echo 按任意键退出...
pause >nul