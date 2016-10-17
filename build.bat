@echo off

call defvars %~1

echo Copying ExtensionsFeaturesBuild.wxs
copy ExtensionsFeatures.wxs ExtensionsFeaturesBuild.wxs > NUL

echo Copying ExtensionsComponentsBuild.wxs
copy ExtensionsComponents.wxs ExtensionsComponentsBuild.wxs > NUL

echo Copying PHPInstallerCommonBuild.wxs
copy PHPInstallerCommon.wxs PHPInstallerCommonBuild.wxs > NUL

echo Copying PHPInstallerBuild.wxs
copy PHPInstallerBase.wxs PHPInstallerBuild.wxs > NUL

echo Copying WebServerConfigBuild.wxs
copy WebServerConfig.wxs WebServerConfigBuild.wxs > NUL

echo Copying WixUI_en-us_Build.wxl
copy WixUI_en-us.wxl WixUI_en-us_Build.wxl > NUL

echo Preprocessing Thread safe conditionals
Files\%distver%\php.exe -n PreprocessConditionals.wxs.php "%extrants%" "%version%" "%distver%"

echo Building ExtensionsComponentsBuild.wxs
Files\%distver%\php.exe -n GenExtensionsFeatures.wxs.php "%distver%" "%icuver%"

echo Building PHPInstallerBuild.wxs
Files\%distver%\php.exe -n GenPHPInstaller.wxs.php "PHPInstallerBuild.wxs" "%version%" "%vcver%" "%distver%"

echo Compiling Installer....
Wix\candle.exe -nologo -arch %distver% -dPlatform=%distver% -dVersion=%version% ExtensionsComponentsBuild.wxs ExtensionsFeaturesBuild.wxs WebServerConfigBuild.wxs PHPInstallerBuild.wxs PHPInstallerCommonBuild.wxs
if not %ERRORLEVEL% == 0 pause

echo Linking Installer....
Wix\light.exe -nologo -out "%msiname%" ExtensionsComponentsBuild.wixobj ExtensionsFeaturesBuild.wixobj WebServerConfigBuild.wixobj PHPInstallerBuild.wixobj PHPInstallerCommonBuild.wixobj -loc WixUI_en-us_Build.wxl

if not %ERRORLEVEL% == 0 pause
call clear %~1

:end