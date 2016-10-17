@echo off

call defvars %~1

del ExtensionsComponentsBuild.wxs
del ExtensionsComponentsBuild.wixobj
del ExtensionsFeaturesBuild.wxs
del ExtensionsFeaturesBuild.wixobj
del PHPInstallerBuild.wxs
del PHPInstallerBuild.wixobj
del PHPInstallerCommonBuild.wxs
del PHPInstallerCommonBuild.wixobj
del WebServerConfigBuild.wxs
del WebServerConfigBuild.wixobj
del WixUI_en-us_Build.wxl
del %basename%.wixpdb
